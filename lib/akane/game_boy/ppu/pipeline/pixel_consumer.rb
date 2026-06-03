# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for emitting pixels from the Pixel FIFO to the Display.
        class PixelConsumer
          PIXELS_PER_SCANLINE = 160

          def initialize(ppu:)
            @ppu = ppu

            @state = :popping_pixels
            @pixels_emitted = 0
          end

          # TODO: Implement mixing logic from both Fifos.
          # Called each T-cycle.
          def tick
            return unless @pixels_emitted < PIXELS_PER_SCANLINE

            popped_pixel = @ppu.bg_win_fifo.pop_pixel
            return if popped_pixel.nil?

            # TODO: Implement framebuffer fixed size
            @ppu.framebuffer << @ppu.registers.pixel_shades[popped_pixel]
            @pixels_emitted += 1
            return unless @pixels_emitted == PIXELS_PER_SCANLINE

            @pixels_emitted = 0
            @ppu.pixel_fetcher.reset_progress
            @ppu.bg_win_fifo.clear
            @ppu.set_mode(:h_blank) # remove from here
          end

          def to_s
            "#{@state.upcase} Popped: #{@pixels_emitted}"
          end
        end
      end
    end
  end
end
