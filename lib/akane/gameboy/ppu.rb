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

      MODES = {
        h_blank: 0,
        v_blank: 1,
        oam_scan: 2,
        drawing: 3
      }.freeze

      OAM_SCAN = OAMScan.new.freeze

      DOTS_PER_OAM_SCAN = 80
      DOTS_PER_SCANLINE = 456

      WINDOW_TILE_MAPS = {
        0 => { start: 0x9800, end: 0x9BFF },
        1 => { start: 0x9C00, end: 0x9FFF }
      }.freeze
      BG_TILE_MAPS = {
        0 => { start: 0x9800, end: 0x9BFF },
        1 => { start: 0x9C00, end: 0x9FFF }
      }.freeze

      attr_reader :lcdc, :scy, :scx, :ly, :lyc, :dma, :bgp, :obp0, :obp1, :wy, :wx

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

        @mode = MODES[:oam_scan]
        @dots = 0
        @framebuffer = Array.new
        @scanline_drawn = false

        @lcdc = skip_boot_rom ? 0x91 : 0x00
        @stat = skip_boot_rom ? 0x85 : 0x00
        @scy  = 0x00
        @scx  = 0x00
        @ly   = 0x00
        @lyc  = 0x00
        @dma  = skip_boot_rom ? 0xFF : 0x00
        @bgp  = 0x00
        @obp0 = 0x00
        @obp1 = 0x00
        @wy   = 0x00
        @wx   = 0x00

        @shades = [0b00, 0b00, 0b00, 0b00]
      end

      def lcdc=(value)
        @lcdc = value & 0xFF
      end

      def stat=(value)
        @stat = value & 0xFF
      end

      # Bits: [7][6][5][4][3][2]([1][0])
      #                          @mode
      def stat
        @stat = if @ly == @lyc
                  set_bit(@stat, 2)
                else
                  clear_bit(@stat, 2)
                end
        @stat | @mode
      end

      def scy=(value)
        @scy = value & 0xFF
      end

      def scx=(value)
        @scx = value & 0xFF
      end

      def lyc=(value)
        @lyc = value & 0xFF
      end

      def dma=(value)
        @dma = value & 0xFF
      end

      def bgp=(value)
        @bgp = value & 0xFF

        @shades = [
          @bgp & 0b11,
          (@bgp >> 2) & 0b11,
          (@bgp >> 4) & 0b11,
          (@bgp >> 6) & 0b11
        ]
      end

      def obp0=(value)
        @obp0 = value & 0xFF
      end

      def obp1=(value)
        @obp1 = value & 0xFF
      end

      def wy=(value)
        @wy = value & 0xFF
      end

      def wx=(value)
        @wx = value & 0xFF
      end

      # Returns a 8-bit value stored in VRAM in a given address.
      #
      # VRAM data:
      # $8000-$97FF: Tile data (up to 384 tiles × 16 bytes each)
      # $9800-$9BFF: Tile map 0 (32×32 = 1024 tile indices)
      # $9C00-$9FFF: Tile map 1 (alternative map)
      def read_vram(address:)
        return 0xFF if @mode == MODES[:drawing]

        @vram.read_byte(address:)
      end

      # Stores a 8-bit value in VRAM in a given address.
      def write_vram(address:, value:)
        @vram.write_byte(address:, value:)
      end

      # Returns a 8-bit value stored in OAM in a given address.
      def read_oam(address:)
        return 0xFF if [MODES[:oam_scan], MODES[:drawing]].include?(@mode)

        @oam.read_byte(address:)
      end

      # Stores a 8-bit value in OAM in a given address.
      def write_oam(address:, value:)
        @oam.write_byte(address:, value:)
      end

      # def tick
      #   case @mode
      #   when :oam_scan
      #   when :drawing
      #   when :h_blank
      #   when :v_blank
      #   end
      # end

      def tick
        if lcd_off?
          @ly = 0
          @dots = 0
          @mode = MODES[:h_blank]
          return
        end

        @dots += 4

        # Core state machine.
        if @dots < DOTS_PER_OAM_SCAN && @ly < 144
          @mode = MODES[:oam_scan]
        elsif @dots < 252 && @ly < 144
          @mode = MODES[:drawing]
          draw_scanline unless @scanline_drawn
          @scanline_drawn = true
        elsif @dots < DOTS_PER_SCANLINE && @ly < 144
          @mode = MODES[:h_blank]
        elsif @dots >= DOTS_PER_SCANLINE # -> Scanline completed.
          @dots = 0
          @ly = (@ly + 1) % 154
          @interrupts.request(:lcd_stat) if @ly == @lyc && bit(@stat, 6) == 1
          @scanline_drawn = false
          # @framebuffer << "\n"

          if @ly == 144 # -> Frame completed
            @mode = MODES[:v_blank]
            @interrupts.request(:v_blank)
            # @framebuffer << "\e[H"
            # print @framebuffer.join if @video == 'console'
            @display&.draw(@framebuffer)
            @framebuffer = Array.new
          end
        end

        trace
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
        map_tile_x = @scx / 8
        map_tile_y = (@ly + @scy) / 8

        (0..19).each do |tile_pos|
          tile_index_address = tile_map_base_address + ((map_tile_x + tile_pos) % 32) + ((map_tile_y % 32) * 32)
          tile_index = @vram.read_byte(address: tile_index_address)

          row_in_tile_data = (@ly + @scy) % 8

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
        bit(@lcdc, 7) == 1
      end

      def lcd_off?
        bit(@lcdc, 7).zero?
      end

      def window_tile_map
        WINDOW_TILE_MAPS[bit(@lcdc, 6)]
      end

      def bg_tile_map
        BG_TILE_MAPS[bit(@lcdc, 3)]
      end

      # Tile data addressing mode.
      #
      # - LCDC Bit 4 is 1 -> Base address = $8000 (Unsigned byte).
      # - LCDC Bit 4 is 0 -> Base address = $9000 (Sign byte offset -128 to +127).
      def addressing_mode
        bit(@lcdc, 4)
      end

      def trace
        return unless @trace_ppu

        $stdout.printf(
          "Dots: %<dots>04d | Mode: %<mode>s | LY: $%<ly>02X (%<ly>d)\n",
          dots: @dots,
          mode: MODES.key(@mode)&.to_s&.upcase,
          ly: @ly
        )
      end
    end
  end
end
