# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the VRAM (Video RAM) from the DMG Game Boy.
    #
    # The VRAM address range can be divided into 2 main parts.
    # 1. Tile Data:
    #   - Lives in 0x8000 -> 0x97FF (6144 bytes)
    #   - Each tile is composed of 8 x 8 = 64 pixels
    #   - Each pixel is encoded as 2 bits in the DMG Game Boy
    #   - So each tile has 64 * 2 = 128 bits (16 bytes)
    # 2. Tile Maps:
    #   - Has a total of 2 Tile Maps (0x9800 -> 0x9BFF) / (0x9C00 -> 0x9FFF)
    #   - Each Tile Map is a 32 x 32 grid of Tile indices (each index is 1 byte)
    #   - So each Tile Map has exactly 1024 bytes (1 KiB)
    class Vram < Ram
      START_ADDRESS = 0x8000
      END_ADDRESS   = 0x9FFF
      SIZE_IN_BYTES = (END_ADDRESS - START_ADDRESS) + 1 #=> 8192 bytes (8 KiB)

      TILE_DATA_START_ADDRESS = 0x8000
      TILE_DATA_END_ADDRESS   = 0x97FF
      TILE_DATA_SIZE_IN_BYTES = (TILE_DATA_END_ADDRESS - TILE_DATA_START_ADDRESS) + 1

      TILE_SIZE_IN_BYTES = 16
      TILE_ENTRIES = TILE_DATA_SIZE_IN_BYTES / TILE_SIZE_IN_BYTES #=> 384 tiles

      attr_reader :unsigned_tile_data,
                  :signed_tile_data,
                  :tile_map_low,
                  :tile_map_high

      # Creates "lens objects" passing the original VRAM @data Array,
      # when a value is written into VRAM it will be correctly read
      # by all the Tile Data and Tile Maps.
      def initialize
        super(size: SIZE_IN_BYTES, offset: START_ADDRESS)

        @unsigned_tile_data = TileData.new(
          vram_data: @data,
          addressing_mode: :unsigned
        )
        @signed_tile_data = TileData.new(
          vram_data: @data,
          addressing_mode: :signed
        )

        @tile_map_low  = TileMap.new(vram_data: @data, offset: 0x1800)
        @tile_map_high = TileMap.new(vram_data: @data, offset: 0x1C00)
      end
    end
  end
end
