# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel FIFO from the original Game Boy (DMG).
      class PixelFifo
        MAX_PIXELS = 16

        attr_reader :pixels

        def initialize
          @pixels = Array.new(MAX_PIXELS)
        end

        # @return [true, false] If the push was successful or not.
        def push?(pixels)
          return false unless @pixels.empty?

          pixels.each_with_index do |pixel, index|
            @pixels[index] = pixel
          end

          true
        end

        # @return [Integer] 2 bit number representing the color id of the pixel.
        def pop_pixel
          return if @pixels.empty?

          @pixels.shift
        end

        def clear
          @pixels.clear
        end
      end
    end
  end
end
