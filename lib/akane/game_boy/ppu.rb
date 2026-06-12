# frozen_string_literal: true

module Akane
  module GameBoy
    # This class models the Pixel Processing Unit from the Original Game Boy.
    #
    # The Ppu outputs a 160x144 pixel framebuffer each frame.
    # This framebuffer will be used by the chosen Renderer to display the graphics.
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

      PIXELS_PER_SCANLINE = 160
      VISIBLE_SCANLINES = 144
      TOTAL_SCANLINES = 154
      DOTS_PER_SCANLINE = 456
      MAX_SPRITES_PER_SCANLINE = 10

      attr_accessor :wy_eq_ly, :window_y_count

      attr_reader :registers,
                  :dots,
                  :framebuffer,
                  :sprite_buffer

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
        @sprite_buffer = Array.new(MAX_SPRITES_PER_SCANLINE).clear

        @modes = Modes.build_hash(self)
        @mode  = set_mode(:disabled)
        @wy_eq_ly = false
        @window_y_count = 0
        @dots = 0
      end

      # Core PPU state machine.
      #
      # Each mode is responsible for its own logic and
      # also switching to the next mode.
      def tick
        @mode.tick
        log_state if @trace_ppu
        @dots += 1
      end

      # Sets the current PPU mode to be ticked.
      #
      # @param mode [Symbol]
      def set_mode(mode)
        @mode = @modes[mode]
        @registers.stat.set_mode_bits(@mode.number)
        request_interrupt(:lcd_stat) if @registers.stat.rising_edge?

        @mode
      end

      def reset_for_scanline
        @dots = 0
        @sprite_buffer.clear unless @sprite_buffer.empty?
      end

      # Restarts the rendering pipeline state.
      def reset_states
        reset_for_scanline
        @registers.ly = 0x00
        @wy_eq_ly = false # here?
        @window_y_count = 0
        @framebuffer.clear

        ly_compare
      end

      # Delegates the draw to the chosen Renderer.
      def draw_frame
        @display&.draw(@framebuffer)
      end

      def request_interrupt(interrupt_type)
        @interrupts.request(interrupt_type)
      end

      def increment_ly
        @registers.ly += 1

        ly_compare
      end

      def ly_compare
        if @registers.ly == @registers.lyc
          @registers.stat.set_lyc_bit
        else
          @registers.stat.clear_lyc_bit
        end

        request_interrupt(:lcd_stat) if @registers.stat.rising_edge?
      end

      # Returns a 8-bit value stored in VRAM in a given address.
      #
      # @param address [Integer]
      # @return [Integer]
      def read_vram(address:)
        return 0xFF if @mode == @modes[:rendering]

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
        return 0xFF if [@modes[:oam_scan], @modes[:rendering]].include?(@mode)

        @oam.read_byte(address:)
      end

      # Stores a 8-bit value in OAM in a given address.
      def write_oam(address:, value:)
        @oam.write_byte(address:, value:)
      end

      def fetch_sprite_at(index)
        @oam.sprite(index)
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
        $stdout.printf(
          '#%<dots>03d | ' \
          'LY: $%<ly>02X (%<ly>d) | ' \
          'LCDC: $%<lcdc>02X | ' \
          'STAT: $%<stat>02X | ' \
          "MODE: %<mode>s\n",
          dots: @dots,
          ly: @registers.ly,
          lcdc: @registers.lcdc.value,
          stat: @registers.stat.value,
          mode: @mode.to_s
        )
      end
    end
  end
end
