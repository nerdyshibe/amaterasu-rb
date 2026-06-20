# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Vram
      # Models the Tile Data that lives in the VRAM.
      class TileData
        TILE_SIZE = 16
        TILE_ENTRIES = 384

        attr_reader :tiles, :addressing_mode, :base_offset

        # @param vram_data [Array] Original VRAM @data array object.
        def initialize(vram_data:)
          @addressing_mode = :unsigned
          @base_offset     = 0x0000

          @tiles = Array.new(TILE_ENTRIES) do |index|
            Tile.new(vram_data: vram_data, tile_index: index)
          end
        end

        # @param mode [Symbol] Either :unsigned or :signed.
        def addressing_mode=(mode)
          @addressing_mode = mode
          @base_offset     = mode == :unsigned ? 0x0000 : 0x1000
        end

        # Fetches a Tile based on a given index, if the addressing mode
        # is set to :signed, we need to sign the value before fetching
        # the tile.
        #
        # @param tile_index [Integer] 8-bit value representing the tile index.
        # @return [Vram::Tile]
        def tile_at(tile_index)
          tile_index = sign_value(tile_index) if @addressing_mode == :signed
          tile_offset = @base_offset / Tile::SIZE_IN_BYTES

          @tiles[tile_offset + tile_index]
        end

        private

        # @param index [Integer] The current Tile index (8-bit value).
        # @return [Integer] A value between -128 and +127.
        def sign_value(index)
          index >= 128 ? index - 256 : index
        end
      end
    end
  end
end
