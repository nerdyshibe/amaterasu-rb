# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models each Tile that lives in the VRAM.
      class Tile
        SIZE_IN_BYTES = 16
        SIZE_BIT_MASK = 0b111

        # Pre-computes all possible 8 pixel values
        # for the Game Boy address range (0x0000 - 0xFFFF).
        #
        # Usage:
        #   Memory values: $3C (Low), $7E (High)
        #   PIXELS_LOOKUP[(0x7E << 8) | 0x3C] #=> [0, 2, 3, 3, 3, 3, 2, 0]
        PIXELS_LOOKUP = Array.new(0xFFFF) do |idx|
          low_byte  = idx & 0xFF
          high_byte = (idx >> 8) & 0xFF

          Array.new(8) do |i|
            bit = 7 - i
            low_bit = (low_byte >> bit) & 1
            high_bit = (high_byte >> bit) & 1

            (high_bit << 1) | low_bit
          end
        end.freeze

        attr_reader :data

        def initialize(vram_data:, tile_index:)
          @vram_data = vram_data
          @tile_index = tile_index
          @base_offset = tile_index * SIZE_IN_BYTES
        end

        # @return [Integer] The low byte of the tile at a given row.
        def data_low(current_y)
          current_tile_y = current_y & SIZE_BIT_MASK
          row_within_tile = current_tile_y * 2

          @vram_data[@base_offset + row_within_tile]
        end

        # @return [Integer] The high byte of the tile at a given row.
        def data_high(current_y)
          current_tile_y = current_y & SIZE_BIT_MASK
          row_within_tile = current_tile_y * 2

          @vram_data[@base_offset + row_within_tile + 1]
        end

        def pixel_row(low_byte, high_byte)
          PIXELS_LOOKUP[(high_byte << 8) | low_byte]
        end

        def inspect
          '#<Tile ' \
            "@tile_index=#{@tile_index} " \
            "@base_offset=#{@base_offset}>"
        end
      end
    end
  end
end
