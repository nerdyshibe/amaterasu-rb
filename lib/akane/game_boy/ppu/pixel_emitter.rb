# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Responsible for emitting pixels from the Pixel FIFO to the LCD.
      class PixelEmitter
        PIXELS_PER_SCANLINE = 160

        def initialize(ppu:)
          @ppu = ppu

          @state = :popping_pixels
          @pixels_emmited = 0
        end

        def tick
          return unless @pixels_emmited < PIXELS_PER_SCANLINE

          popped_pixel = @ppu.bg_win_fifo.pop_pixel
          return if popped_pixel.nil?

          @ppu.framebuffer << popped_pixel
          @pixels_emmited += 1
          return unless @pixels_emmited == PIXELS_PER_SCANLINE

          @pixels_emmited = 0
          @ppu.pixel_fetcher.reset_progress
          @ppu.set_mode(:h_blank)
        end

        def to_s
          "#{@state.upcase} Popped: #{@pixels_emmited}"
        end
      end
    end
  end
end
