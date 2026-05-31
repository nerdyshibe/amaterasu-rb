# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel FIFO from the original Game Boy (DMG).
      class PixelFifo
        MAX_PIXEL_SIZE = 8

        def initialize
          @pixels = Array.new(MAX_PIXEL_SIZE)
        end
      end
    end
  end
end
