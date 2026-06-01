# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel FIFO from the original Game Boy (DMG).
      class PixelFifo
        MAX_PIXELS    = 16
        PUSHED_PIXELS = 8

        attr_reader :pixels

        def initialize
          @pixels = Array.new
          @current_index = 0
        end

        def size
          @pixels.size
        end

        def push?(pixels)
          return false if not_enough_room?

          pixels.each do |pixel|
            @pixels[@current_index] = pixel
            @current_index += 1
          end

          true
        end

        # @return [Integer] 2 bit number
        def pop_pixel
          return if @pixels.empty?

          popped = @pixels.pop
          @current_index -= 1

          popped
        end

        private

        def not_enough_room?
          size + PUSHED_PIXELS > MAX_PIXELS
        end
      end
    end
  end
end
