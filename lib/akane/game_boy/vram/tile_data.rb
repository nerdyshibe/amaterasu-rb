# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models the Tile Data that lives in the VRAM.
      class TileData
        TILE_SIZE = 16

        # @param vram_data [Array] Original VRAM @data array object.
        def initialize(vram_data:)
          @vram_data = vram_data

          @addressing_mode = :unsigned
          @base_offset     = 0x0000
          @tile_row        = Hash.new
          @tile_row_pixels = Array.new
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
        # @param current_line [Integer] Current line being scanned in Drawing mode.
        # @return [Hash] 2 bytes from the given Tile index at that current line.
        def tile_row(tile_index, current_line)
          tile_index = sign_value(tile_index) if @addressing_mode == :signed
          current_line &= 0b111

          tile_offset     = tile_index * TILE_SIZE
          tile_row_offset = current_line * 2

          final_offset = @base_offset + tile_offset + tile_row_offset

          @tile_row[:low_byte]  = @vram_data[final_offset]
          @tile_row[:high_byte] = @vram_data[final_offset + 1]
          @tile_row[:pixels]    = decode_pixels

          @tile_row
        end

        private

        # @param index [Integer] The current Tile index.
        # @return [Integer] A value between -128 and +127.
        def sign_value(index)
          index >= 128 ? index - 256 : index
        end

        def decode_pixels
          @tile_row_pixels.clear unless @tile_row_pixels.empty?
          bit = 7

          while bit >= 0
            low_bit  = @tile_row[:low_byte][bit]
            high_bit = @tile_row[:high_byte][bit]

            color_id = (high_bit << 1) | low_bit
            @tile_row_pixels << color_id

            bit -= 1
          end

          @tile_row_pixels
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
