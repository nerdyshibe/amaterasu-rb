# frozen_string_literal: true

module Akane
  module Gameboy
    # This class models the Pixel Processing Unit from the Original Game Boy.
    #
    # The PPU outputs a 160x144 pixel framebuffer each frame.
    # This framebuffer will be used by the rendered to display the graphics.
    # The PPU should not care about how the pixels are rendered, just output them.
    #
    # Specifications:
    # - The frame consists of 154 scanlines, 144 visible + 10 vblank (Cpu can access VRAM).
    # - Scanlines are drawn from top to bottom, left to right.
    # - Updating registers mid-frame can cause effects since the pixels are still being drawn.
    # - Dots per scanline = 456 t-cycles (114 m-cycles) -> Hardware spec.
    # - Dots per frame = 154 * 456 = 70_224 t-cycles (17_556 m-cycles).
    # - OAM search takes 80 dots (20 m-cycles) -> 40 sprites, 2 dots each.
    class Ppu
      using Utils::BitOperations

      MODES = {
        h_blank: 0,
        v_blank: 1,
        drawing: 2,
        oam_search: 3
      }.freeze

      DOTS_PER_OAM_SEARCH = 80
      DOTS_PER_SCANLINE = 456

      VRAM_OFFSET = 0x8000
      WINDOW_TILE_MAPS = {
        0 => { start: 0x9800 - VRAM_OFFSET, end: 0x9BFF - VRAM_OFFSET },
        1 => { start: 0x9C00 - VRAM_OFFSET, end: 0x9FFF - VRAM_OFFSET }
      }.freeze
      BG_TILE_MAPS = {
        0 => { start: 0x9800 - VRAM_OFFSET, end: 0x9BFF - VRAM_OFFSET },
        1 => { start: 0x9C00 - VRAM_OFFSET, end: 0x9FFF - VRAM_OFFSET }
      }.freeze

      CONSOLE_CHARS = [' ', '░', '▒', '█'].freeze

      attr_reader :lcdc, :scy, :scx, :ly, :lyc, :dma, :bgp, :obp0, :obp1, :wy, :wx

      def initialize(interrupts, trace_ppu)
        @interrupts = interrupts
        @trace_ppu = trace_ppu

        @vram = Ram.new(8192)
        @oam  = Ram.new(160)
        @mode = MODES[:oam_search]
        @dots = 0
        @pixel_buffer = Array.new

        @lcdc = 0x00
        @stat = 0x00
        @scy  = 0x00
        @scx  = 0x00
        @ly   = 0x00
        @lyc  = 0x00
        @dma  = 0x00
        @bgp  = 0x00
        @obp0 = 0x00
        @obp1 = 0x00
        @wy   = 0x00
        @wx   = 0x00
      end

      def lcdc=(value)
        @lcdc = value & 0xFF
      end

      def stat=(value)
        @stat = value & 0xFF
      end

      # Reports current mode (2 bits).
      def stat
        @mode
      end

      def scy=(value)
        @scy = value & 0xFF
      end

      def scx=(value)
        @scx = value & 0xFF
      end

      def bgp=(value)
        @bgp = value & 0xFF
      end

      def wy=(value)
        @wy = value & 0xFF
      end

      def wx=(value)
        @wx = value & 0xFF
      end

      # Returns a 8-bit value stored in VRAM in a given offset.
      #
      # VRAM data:
      # $8000-$97FF: Tile data (up to 384 tiles × 16 bytes each)
      # $9800-$9BFF: Tile map 0 (32×32 = 1024 tile indices)
      # $9C00-$9FFF: Tile map 1 (alternative map)
      def read_vram(offset)
        return 0xFF if @mode == MODES[:drawing]

        @vram.read_byte(offset)
      end

      # Stores a 8-bit value in VRAM in a given offset.
      def write_vram(offset, value)
        @vram.write_byte(offset, value)
      end

      # Returns a 8-bit value stored in OAM in a given offset.
      def read_oam(offset)
        return 0xFF if [MODES[:oam_search], MODES[:drawing]].include?(@mode)

        @oam.read_byte(offset)
      end

      # Stores a 8-bit value in OAM in a given offset.
      def write_oam(offset, value)
        @oam.write_byte(offset, value)
      end

      def tick
        if lcd_off?
          @ly = 0
          @dots = 0
          @mode = MODES[:h_blank]
          return
        end

        @dots += 4

        # Core state machine.
        if @dots < DOTS_PER_OAM_SEARCH && @ly < 144
          @mode = MODES[:oam_search]
        elsif @dots < 252 && @ly < 144
          @mode = MODES[:drawing]
          draw_scanline
        elsif @dots < DOTS_PER_SCANLINE && @ly < 144
          @mode = MODES[:h_blank]
        elsif @dots >= DOTS_PER_SCANLINE
          @dots = 0
          @ly = (@ly + 1) % 154

          if @ly == 144
            @mode = MODES[:v_blank]
            @interrupts.request(:v_blank)
            puts @pixel_buffer.join
            @pixel_buffer = []
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
        check_addressing_mode
        base_address = bg_tile_map[:start]
        (0..20).each do |tile_pos|
          tile_index_address = base_address + tile_pos
          tile_index = @vram.read_byte(tile_index_address)

          check_addressing_mode
          tile_data_address = @base_pointer + (tile_index * 16)
          byte1 = @vram.read_byte(tile_data_address)
          byte2 = @vram.read_byte(tile_data_address + 1)

          bit_pos = 7
          while bit_pos >= 0
            pixel_encoded = (byte2.bit(bit_pos) << 1) | byte1.bit(bit_pos)
            @pixel_buffer << CONSOLE_CHARS[pixel_encoded]
            bit_pos -= 1
          end
        end
      end

      def lcd_on?
        @lcdc.bit(7) == 1
      end

      def lcd_off?
        @lcdc.bit(7).zero?
      end

      def window_tile_map
        WINDOW_TILE_MAPS[@lcdc.bit(6)]
      end

      def bg_tile_map
        BG_TILE_MAPS[@lcdc.bit(3)]
      end

      def check_addressing_mode
        @base_pointer = if @lcdc.bit(4) == 1
                          0x8000 - VRAM_OFFSET
                        else
                          0x9000 - VRAM_OFFSET
                        end
      end

      def trace
        return unless @trace_ppu

        $stdout.printf(
          "Dots: %<dots>04d | Mode: %<mode>s | LY: $%<ly>02X (%<ly>d)\n",
          dots: @dots,
          mode: MODES.key(@mode).upcase,
          ly: @ly
        )
      end
    end
  end
end
