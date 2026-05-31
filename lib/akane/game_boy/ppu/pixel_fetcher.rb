# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel Fetcher from the original Game Boy (DMG).
      class PixelFetcher
        def initialize
          @state = :reading_vram
        end

        def tick
          case @state
          when :reading_vram then @state = :fetch_tile
          when :fetch_tile
            @vram.tile(at: location)
          end
        end
      end
    end
  end
end
