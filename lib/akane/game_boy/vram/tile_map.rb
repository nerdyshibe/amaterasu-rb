# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Map that live in VRAM.
      #
      # - Each Tile Map is a 32 x 32 grid of Tile indices.
      # - Each Tile index is exactly 1 byte.
      # - So each Tile Map has exactly 32 * 32 * 1 = 1024 bytes (1 KiB).
      #
      # Grid representation in 2 dimensions, each (X, Y) pair -> 1 byte:
      #
      #               X = 0       X = 1      X = 2          X = 31
      #
      #     Y = 0     (0, 0)     (1, 0)     (2, 0)    ...  (31, 0)   <- Row 0
      #
      #     Y = 1     (0, 1)     (1, 1)     (2, 1)    ...  (31, 1)   <- Row 1
      #
      #     Y = 2     (0, 2)     (1, 2)     (2, 2)    ...  (31, 2)   <- Row 2
      #
      #      ...       ...         ...        ...            ...         ...
      #
      #     Y = 31    (0, 31)    (1, 31)    (2, 31)   ...  (31, 31)  <- Row 31
      #
      #                  ↑          ↑          ↑              ↑
      #
      #               Column 0   Column 1   Column 2  ...  Column 31
      #
      class TileMap
        # Total number of columns in the grid.
        GRID_WIDTH  = 32

        # Total number of rows in the grid.
        GRID_HEIGHT = 32

        # @param vram_data [Array] Reference to the original VRAM data.
        # @param offset [Integer] Tile map start address within the VRAM data.
        def initialize(vram_data:, offset:)
          @vram_data = vram_data
          @offset = offset
        end

        # Fetches a Tile index from the Tile Map at a given (X, Y) position.
        #
        # Since the Memory is a flat array (single dimension) we need to
        # offset the given Y value by the WIDTH to "jump over" the rows in
        # between and reach the correct row.
        #
        # @param tile_x [Integer] Which column in the grid (0 - 31).
        # @param tile_y [Integer] Which row in the grid (0 - 31).
        # @return [Integer] 1 byte representing the given Tile index.
        def tile_index(tile_x:, tile_y:)
          row_offset = tile_y * GRID_WIDTH
          column     = tile_x

          @vram_data[@offset + row_offset + column]
        end
      end
    end
  end
end
