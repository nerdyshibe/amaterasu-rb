# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Models the PPU Pixel FIFO from the original Game Boy (DMG).
        class PixelFifo
          MAX_PIXELS = 16 # or 8?

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

          # This is specific for Sprites.
          #
          def merge(sprite_pixels)
            idx = 0

            while idx <= 7
              transparent = @pixel_buffer[idx]&.color_id == 0b00
              @pixel_buffer[idx] = sprite_pixels[idx] if transparent || @pixel_buffer[idx].nil?
              idx += 1
            end
          end

          # To follow the FIFO rules, elements need to be popped
          # from left to right, that is why we need to use Array#shift.
          #
          # @return [Integer] 2 bit number representing the color id of the pixel.
          def pop_pixel
            return if @pixel_buffer.empty?

            @pixel_buffer.shift
          end

          # Removes all current elements of the FIFO.
          def clear
            @pixel_buffer.clear
          end

          # Removes all current elements of the FIFO.
          def empty?
            @pixel_buffer.empty?
          end
        end
      end
    end
  end
end
