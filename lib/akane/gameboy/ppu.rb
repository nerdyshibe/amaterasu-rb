# frozen_string_literal: true

module Akane
  module GameBoy
    # This class models the Pixel Processing Unit from the Original Game Boy.
    #
    # The Ppu outputs a 160x144 pixel framebuffer each frame.
    # This framebuffer will be used by the rendered to display the graphics.
    # The Ppu should not care about how the pixels are rendered, just output them.
    #
    # Specifications:
    # - The frame consists of 154 scanlines, 144 visible + 10 vblank (Cpu can access VRAM).
    # - Scanlines are drawn from top to bottom, left to right.
    # - Updating registers mid-frame can cause effects since the pixels are still being drawn.
    # - Dots per scanline = 456 t-cycles (114 m-cycles) -> Hardware spec.
    # - Dots per frame = 154 * 456 = 70_224 t-cycles (17_556 m-cycles).
    # - OAM search takes 80 dots (20 m-cycles) -> 40 sprites, 2 dots each.
    class Ppu
      include Utils::BitOps

      DOTS_PER_SCANLINE = 456
      MAX_SPRITES_PER_SCANLINE = 10

      WINDOW_TILE_MAPS = {
        0 => { start: 0x9800, end: 0x9BFF },
        1 => { start: 0x9C00, end: 0x9FFF }
      }.freeze
      BG_TILE_MAPS = {
        0 => { start: 0x9800, end: 0x9BFF },
        1 => { start: 0x9C00, end: 0x9FFF }
      }.freeze

      attr_reader :registers, :dots, :sprite_buffer

      def initialize(
        vram,
        oam,
        display,
        interrupts,
        skip_boot_rom: true,
        trace_ppu: false
      )
        @vram = vram
        @oam = oam
        @display = display
        @interrupts = interrupts
        @trace_ppu = trace_ppu

        @modes = Modes.build_hash(ppu: self, oam: @oam)
        @mode = @modes[:oam_scan]
        @registers = Registers.new(@mode, update_shades, skip_boot_rom:)
        @dots = 0
        @framebuffer = Array.new
        @scanline_drawn = false
        @sprite_buffer = Array.new(MAX_SPRITES_PER_SCANLINE)

        @shades = [0b00, 0b00, 0b00, 0b00]
      end

      # Returns a 8-bit value stored in VRAM in a given address.
      #
      # VRAM data:
      # $8000-$97FF: Tile data (up to 384 tiles × 16 bytes each)
      # $9800-$9BFF: Tile map 0 (32×32 = 1024 tile indices)
      # $9C00-$9FFF: Tile map 1 (alternative map)
      def read_vram(address:)
        return 0xFF if @mode == @modes[:drawing]

        @vram.read_byte(address:)
      end

      # Stores a 8-bit value in VRAM in a given address.
      def write_vram(address:, value:)
        @vram.write_byte(address:, value:)
      end

      # Returns a 8-bit value stored in OAM in a given address.
      def read_oam(address:)
        return 0xFF if [@modes[:oam_scan], @modes[:drawing]].include?(@mode)

        @oam.read_byte(address:)
      end

      # Stores a 8-bit value in OAM in a given address.
      def write_oam(address:, value:)
        @oam.write_byte(address:, value:)
      end

      def update_shades
        lambda do |bgp|
          @shades[0] = bgp & 0b11
          @shades[1] = (bgp >> 2) & 0b11
          @shades[2] = (bgp >> 4) & 0b11
          @shades[3] = (bgp >> 6) & 0b11
        end
      end

      def set_mode(mode)
        @mode = @modes[mode]
      end

      def tick
        if lcd_off?
          @registers.ly = 0x00
          @dots = 0
          @mode = @modes[:oam_scan]
          return
        end

        @mode.tick
        log_state
        @dots += 1

        # Core state machine.
        # if @dots < DOTS_PER_OAM_SCAN && @registers.ly < 144
        #   @mode = Modes::OAM_SCAN
        # elsif @dots < 252 && @registers.ly < 144
        #   @mode = Modes::DRAWING
        #   draw_scanline unless @scanline_drawn
        #   @scanline_drawn = true
        # elsif @dots < DOTS_PER_SCANLINE && @registers.ly < 144
        #   @mode = Modes::H_BLANK
        # elsif @dots >= DOTS_PER_SCANLINE # -> Scanline completed.
        #   @dots = 0
        #   @registers.ly = (@registers.ly + 1) % 154
        #   @interrupts.request(:lcd_stat) if @registers.ly == @registers.lyc && bit(@registers.stat, 6) == 1
        #   @scanline_drawn = false
        #   # @framebuffer << "\n"

        #   if @registers.ly == 144 # -> Frame completed
        #     @mode = Modes::V_BLANK
        #     @interrupts.request(:v_blank)
        #     # @framebuffer << "\e[H"
        #     # print @framebuffer.join if @video == 'console'
        #     @display&.draw(@framebuffer)
        #     @framebuffer = Array.new
        #   end
        # end
      end

      private

      # Game Boy only cares about tiles.
      #
      # Background is 256x256 pixels (256 / 8 => 32x32 tiles).
      # Screen is 160x144 pixels positioned by SCX/SCY within the background.
      # 160 / 8 = 20 tiles. 144 / 8 = 18 tiles.
      # Tiles are 8x8 pixels (64).
      # Each pixel uses 2 bits for defining the color pallete (0-3).
      # 64 pixels * 2 bits = 128 bits (16 bytes).
      # 16 bytes -> 2 bytes per row (8 rows).
      #
      # byte1 => 1 1 1 1 1 1 1 1
      # byte2 => 1 1 1 1 1 1 1 1
      def draw_scanline
        # Loops through 20 tiles (20 * 8 px = 160px = width of the scanline)
        # Tile map is a grid of 32 x 32 tiles.
        # You need a x and y coordinate to get the tile index.
        # Each entry in the grid is a single byte with the tile index.
        tile_map_base_address = bg_tile_map[:start]
        map_tile_x = @registers.scx / 8
        map_tile_y = (@registers.ly + @registers.scy) / 8

        (0..19).each do |tile_pos|
          tile_index_address = tile_map_base_address + ((map_tile_x + tile_pos) % 32) + ((map_tile_y % 32) * 32)
          tile_index = @vram.read_byte(address: tile_index_address)

          row_in_tile_data = (@registers.ly + @registers.scy) % 8

          if addressing_mode == 1
            tile_data_address = 0x8000 + (tile_index * 16) + (row_in_tile_data * 2)
          else
            signed_index = tile_index >= 128 ? tile_index - 256 : tile_index
            tile_data_address = 0x9000 + (signed_index * 16) + (row_in_tile_data * 2)
          end

          byte1 = @vram.read_byte(address: tile_data_address)
          byte2 = @vram.read_byte(address: tile_data_address + 1)

          bit_pos = 7
          while bit_pos >= 0
            pixel_color_index = (bit(byte2, bit_pos) << 1) | bit(byte1, bit_pos)
            pixel_shade = @shades[pixel_color_index]
            # @framebuffer << CONSOLE_CHARS[pixel_shade]
            @framebuffer << pixel_shade
            bit_pos -= 1
          end
        end
      end

      def lcd_on?
        bit(@registers.lcdc, 7) == 1
      end

      def lcd_off?
        bit(@registers.lcdc, 7).zero?
      end

      def window_tile_map
        WINDOW_TILE_MAPS[bit(@registers.lcdc, 6)]
      end

      def bg_tile_map
        BG_TILE_MAPS[bit(@registers.lcdc, 3)]
      end

      # Tile data addressing mode.
      #
      # - LCDC Bit 4 is 1 -> Base address = $8000 (Unsigned byte).
      # - LCDC Bit 4 is 0 -> Base address = $9000 (Sign byte offset -128 to +127).
      def addressing_mode
        bit(@registers.lcdc, 4)
      end

      # Prints the current state of the PPU into the console for debugging.
      def log_state
        return unless @trace_ppu

        $stdout.printf(
          "Dots: %<dots>04d | Mode: %<mode>s | LY: $%<ly>02X (%<ly>d)\n",
          dots: @dots,
          mode: @mode.to_s,
          ly: @registers.ly
        )
      end
    end
  end
end
