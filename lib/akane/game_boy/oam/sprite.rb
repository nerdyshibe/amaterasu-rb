# frozen_string_literal: true

module Akane
  module GameBoy
    class Oam
      # Models each Sprite that is stored inside the Object Attribute Memory (OAM).
      class Sprite
        SPRITE_SIZE = 4

        def initialize(oam_data:, index:)
          @oam_data = oam_data
          @offset = index * SPRITE_SIZE
        end

        def y_pos
          @oam_data[@offset]
        end

        def x_pos
          @oam_data[@offset + 1]
        end

        def tile_index
          @oam_data[@offset + 2]
        end

        def flags
          @oam_data[@offset + 3]
        end

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
