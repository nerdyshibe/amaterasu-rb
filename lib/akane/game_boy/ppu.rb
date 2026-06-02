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

      attr_reader :registers,
                  :dots,
                  :framebuffer,
                  :sprite_buffer,
                  :shades,
                  :sprite_fifo,
                  :bg_win_fifo,
                  :pixel_fetcher,
                  :pixel_emitter

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

        @registers     = Registers.new(skip_boot_rom:)
        @framebuffer   = Array.new
        @sprite_buffer = Array.new(MAX_SPRITES_PER_SCANLINE)
        @dots          = 0

        @sprite_fifo   = PixelFifo.new
        @bg_win_fifo   = PixelFifo.new
        @pixel_fetcher = PixelFetcher.new(ppu: self)
        @pixel_emitter = PixelEmitter.new(ppu: self)

        @modes = Modes.build_hash(@oam, ppu: self)
        @mode  = @modes[:disabled]
      end

      # Core PPU state machine.
      #
      # Each mode is responsible for its own logic and
      # also switching to the next mode.
      def tick
        @mode.tick
        @dots = (@dots + 1) % 456
        log_state
      end

      def draw_frame
        @display.draw(@framebuffer)
      end

      def request_interrupt(interrupt_type)
        @interrupts.request(interrupt_type)
      end

      def reset_dots
        @dots = 0
        @registers.ly = 0x00
      end

      # Sets the current PPU mode to be ticked.
      #
      # @param mode [Symbol]
      def set_mode(mode)
        @mode = @modes[mode]
      end

      def increment_ly
        @registers.ly += 1
      end

      # Returns a 8-bit value stored in VRAM in a given address.
      #
      # @param address [Integer]
      # @return [Integer]
      def read_vram(address:)
        return 0xFF if @mode == @modes[:drawing]

        @vram.read_byte(address:)
      end

      # Stores a 8-bit value in VRAM in a given address.
      #
      # @param address [Integer]
      # @param value [Integer]
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

      # @return [TileMap]
      def window_tile_map
        return @vram.tile_map_high if @registers.lcdc.window_tile_map_high?

        @vram.tile_map_low
      end

      # @return [TileMap]
      def bg_tile_map
        return @vram.tile_map_high if @registers.lcdc.bg_tile_map_high?

        @vram.tile_map_low
      end

      # @return [TileData]
      def bg_win_tile_data
        @vram.tile_data.addressing_mode =
          if @registers.lcdc.tile_data_at_0x8000?
            :unsigned
          else
            :signed
          end

        @vram.tile_data
      end

      # @return [TileData]
      def obj_tile_data
        @vram.tile_data.addressing_mode = :unsigned
        @vram.tile_data
      end

      private

      # Prints the current state of the PPU into the console for debugging.
      def log_state
        return unless @trace_ppu

        $stdout.printf(
          'DOTS: %<dots>04d | ' \
          'LCDC: $%<lcdc>02X | ' \
          'LY: $%<ly>02X (%<ly>d) | ' \
          'STAT: $%<stat>02X | ' \
          "MODE: %<mode>s\n",
          dots: @dots,
          lcdc: @registers.lcdc.value,
          ly: @registers.ly,
          stat: @registers.stat.value,
          mode: @mode.to_s
        )
      end
    end
  end
end
