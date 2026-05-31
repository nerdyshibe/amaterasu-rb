# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Maps that live in the VRAM.
      class TileMap
        GRID_WIDTH  = 32
        GRID_HEIGHT = 32

        def initialize(vram_data:)
          @vram_data = vram_data
        end
      end
    end
  end
end
