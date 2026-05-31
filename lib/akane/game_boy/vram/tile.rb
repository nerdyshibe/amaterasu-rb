# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile that lives in the VRAM.
      class Tile
        def initialize(vram_data:, index:)
          @vram_data = vram_data
          @index = index
          @offset = index * TILE_SIZE_IN_BYTES
        end

        def data_low
          @vram_data[@offset]
        end

        def data_high
          @vram_data[@offset + 1]
        end

        private

        def inspect
          '#<Tile ' \
            "index=$#{format('%02X', @index)} " \
            "data_low=$#{format('%02X', data_low)} " \
            "data_high=$#{format('%02X', data_high)}>"
        end
      end
    end
  end
end
