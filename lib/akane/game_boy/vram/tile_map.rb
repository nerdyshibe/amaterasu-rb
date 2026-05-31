# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Maps that live in the VRAM.
      class TileMap
        GRID_WIDTH  = 32
        GRID_HEIGHT = 32

        def initialize(vram_data:, offset:)
          @vram_data = vram_data
          @offset = offset
        end

        def tile_index(tile_x:, tile_y:)
          tile_x = tile_x * GRID_WIDTH

          @vram_data[@offset + tile_x + tile_y]
        end
      end
    end
  end
end
