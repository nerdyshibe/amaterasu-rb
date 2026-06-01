# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Data that lives in the VRAM.
      class TileData
        UNSIGNED_BASE_POINTER = 0x8000
        SIGNED_BASE_POINTER = 0x9000
        UNSIGNED_BASE_OFFSET = 0x0000
        SIGNED_BASE_OFFSET = 0x1000

        # @param vram_data [Array] Original VRAM @data array object
        # @param addressing_mode [Symbol] Either :signed or :unsigned
        def initialize(vram_data:, addressing_mode:)
          @vram_data = vram_data
          @addressing_mode = addressing_mode

          @base_offset =
            if addressing_mode == :unsigned
              UNSIGNED_BASE_OFFSET
            else
              SIGNED_BASE_OFFSET
            end

          @tile_index = nil
        end

        # @param tile_index [Integer] 8-bit value that represents the Tile index
        # @return [Integer] 8-bit value that represents the low byte of the Tile
        def low_byte(tile_index)
          @tile_index = tile_index
          @tile_index = sign_value(tile_index) if @addressing_mode == :signed

          @vram_data[@base_offset + @tile_index]
        end

        # @param tile_index [Integer] 8-bit value that represents the Tile index
        # @return [Integer] 8-bit value that represents the high byte of the Tile
        def high_byte(tile_index)
          @tile_index = tile_index
          @tile_index = sign_value(tile_index) if @addressing_mode == :signed

          @vram_data[@base_offset + @tile_index + 1]
        end

        private

        # @return [Integer] Signed value between -128 and +127
        def sign_value(tile_index)
          tile_index >= 128 ? tile_index - 256 : tile_index
        end

        # @return [String] Custom inspect method for debugging
        def inspect
          '#<TileData ' \
            "base_offset=$#{format('%04X', @base_offset)} " \
            "tile_index=$#{format('%02X', @tile_index)} " \
            "data_low=$#{format('%02X', low_byte)} " \
            "data_high=$#{format('%02X', high_byte)}>"
        end
      end
    end
  end
end
