# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel FIFO from the original Game Boy (DMG).
      class PixelFifo
        MAX_PIXELS = 16

        # Array of raw color indices (0 - 3).
        attr_reader :pixels

        def initialize
          @pixel_buffer = Array.new
        end

        # The Pixel Fetcher is the pixel producer,
        # it produces 8 color indices (1 for each pixel) and attempts
        # to push all 8 at the same time until it succeeds.
        #
        # It will only succeed if the FIFO is empty.
        #
        # @return [Boolean] If the push was successful or not.
        def push?(pushed_pixels)
          return false unless @pixel_buffer.empty?

          pushed_pixels.each { |pp| @pixel_buffer << pp }

          true
        end

        # To follow the FIFO rules, elements need to be popped
        # from left to right, that is why we need to use Array#shift.
        #
        # @return [Integer] 2 bit number representing the color id of the pixel.
        def pop_pixel
          return if @pixel_buffer.empty?

          @pixel_buffer.shift
        end

        def clear
          @pixel_buffer.clear
        end
      end
    end
  end
end
