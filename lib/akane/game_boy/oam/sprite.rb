# frozen_string_literal: true

module Akane
  module GameBoy
    class Oam
      # Models each Sprite that is stored inside the Object Attribute Memory (OAM).
      class Sprite
        SIZE_IN_BYTES = 4

        # @param oam_data [Array] Reference to the original OAM @data.
        # @param index [Integer] Sprite index within OAM (0 - 39).
        def initialize(oam_data:, index:)
          @oam_data    = oam_data
          @base_offset = index * SIZE_IN_BYTES
        end

        # @return [Integer] Byte 0 of the Sprite.
        def y_pos
          @oam_data[@base_offset]
        end

        # @return [Integer] Byte 1 of the Sprite.
        def x_pos
          @oam_data[@base_offset + 1]
        end

        # @return [Integer] Byte 2 of the Sprite.
        def tile_index
          @oam_data[@base_offset + 2]
        end

        # @return [Integer] Byte 3 of the Sprite.
        def flags
          @oam_data[@base_offset + 3]
        end

        private

        # @return [String] Custom inspect for easier debugging.
        def inspect
          '#<Sprite ' \
            "y_pos=$#{format('%02X', y_pos)} " \
            "x_pos=$#{format('%02X', x_pos)} " \
            "tile_index=$#{format('%02X', tile_index)} " \
            "flags=#{format('%08b', flags)}>"
        end
      end
    end
  end
end
