# frozen_string_literal: true

module Akane
  module GameBoy
    class Vram
      # Models a single Tile that live inside the VRAM Tile Data area.
      #
      # - Each Tile is composed of 8 x 8 (64) pixels.
      # - The Game Boy encodes a Tile pixel as 2 bits (color id).
      # - So each Tile has a width of 8 pixels * 2 bits = 16 bits (2 bytes).
      #
      # During each scanline the PPU fetches tile data,
      # but it can only see 1 single row of a given tile
      # that overlaps that specific scanline.
      #
      # This is the Tile representation:
      #
      #      Low Bytes           High Bytes
      #
      #   0b00000001 (0x01)   0b00000010 (0x02) -> Tile row 0
      #
      #   0b00000011 (0x03)   0b00000100 (0x04) -> Tile row 1
      #
      #   0b00000101 (0x05)   0b00000110 (0x06) -> Tile row 2
      #
      #   0b00000111 (0x07)   0b00001000 (0x08) -> Tile row 3
      #
      #   0b00001001 (0x09)   0b00001010 (0x10) -> Tile row 4
      #
      #   0b00001011 (0x11)   0b00001100 (0x12) -> Tile row 5
      #
      #   0b00001101 (0x13)   0b00001110 (0x14) -> Tile row 6
      #
      #   0b00001111 (0x15)   0b00010000 (0x16) -> Tile row 7
      #
      class Tile
        def initialize(vram_data, offset:)
          @vram_data = vram_data
          @offset = offset

          @data_low = 0x00
          @data_high = 0x00
          @row_pixels = Array.new
        end

        def data_low(current_line)
          row_offset = current_line * 2

          @data_low = @vram_data[@offset + row_offset]
        end

        def data_high(current_line)
          row_offset = current_line * 2

          @data_high = @vram_data[@offset + row_offset + 1]
        end

        def pixels
          @row_pixels.clear unless @row_pixels.empty?
          bit = 7

          while bit >= 0
            low_bit = @data_low[bit]
            high_bit = @data_high[bit]
            color_id = (high_bit << 1) | low_bit
            @row_pixels << color_id

            bit -= 1
          end

          @row_pixels
        end

        def inspect
          '#<Vram::Tile ' \
            "@offset=#{@offset} " \
            "@data_low=#{@data_low} " \
            "@data_high=#{@data_high}>"
        end
      end
    end
  end
end
