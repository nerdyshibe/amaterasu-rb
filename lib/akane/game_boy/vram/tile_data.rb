# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Data that lives in the VRAM.
      class TileData
        START_ADDRESS = 0x8000
        END_ADDRESS   = 0x97FF
        TOTAL_SIZE    = (END_ADDRESS - START_ADDRESS) + 1
        TILE_SIZE     = 16
        TILE_ENTRIES  = TOTAL_SIZE / TILE_SIZE

        attr_reader :block0_tiles, :block1_tiles, :block2_tiles

        # @param vram_data [Array] Original VRAM @data array object
        def initialize(vram_data:)
          @vram_data = vram_data

          @addressing_mode = :unsigned
          @base_pointer = 0x8000
          @base_offset  = 0x0000

          @block0_tiles = Array.new(TILE_ENTRIES / 3) do |idx|
            Tile.new(@vram_data, offset: idx * TILE_SIZE)
          end
          @block1_tiles = Array.new(TILE_ENTRIES / 3) do |idx|
            Tile.new(@vram_data, offset: 0x0800 + (idx * TILE_SIZE))
          end
          @block2_tiles = Array.new(TILE_ENTRIES / 3) do |idx|
            Tile.new(@vram_data, offset: 0x1000 + (idx * TILE_SIZE))
          end
        end

        # @param mode [Symbol] Either :unsigned or :signed
        def addressing_mode=(mode)
          @addressing_mode = mode
          @base_pointer = mode == :unsigned ? 0x8000 : 0x9000
          @base_offset  = mode == :unsigned ? 0x0000 : 0x1000
        end

        # Fetches a Tile based on a given index, if the addressing mode
        # is set to :signed, we need to sign the value before fetching
        # the tile.
        #
        # @param index [Integer] 8-bit value representing the tile index
        # @return [Tile]
        def tile(index)
          return @block0_tiles[index] if @addressing_mode == :unsigned && index < 128
          return @block1_tiles[index] if @addressing_mode == :unsigned && index >= 128
          return @block1_tiles[index] if @addressing_mode == :signed && index >= 128

          @block2_tiles[index]
        end

        def inspect
          "#<Vram::TileData \n" \
            "@block0=#{@block0_tiles}\n" \
            "@block1=#{@block1_tiles}\n" \
            "@block2=#{@block2_tiles}>"
        end
      end
    end
  end
end
