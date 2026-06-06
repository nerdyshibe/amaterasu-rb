# frozen_string_literal: true

module Akane
  module GameBoy
    class Oam
      # Models each Sprite that is stored inside the Object Attribute Memory (OAM).
      class Sprite
        SIZE_IN_BYTES = 4

        BIT_MASK_BG_WIN_PRIORITY_SET = 1 << 7
        BIT_MASK_OBJ_Y_FLIPPED       = 1 << 6
        BIT_MASK_OBJ_X_FLIPPED       = 1 << 5
        BIT_MASK_USE_OBP1_PALETTE    = 1 << 4

        # @param oam_data [Array] Reference to the original OAM @data.
        # @param index [Integer] Sprite index within OAM (0 - 39).
        def initialize(oam_data:, index:)
          @oam_data    = oam_data
          @base_offset = index * SIZE_IN_BYTES
        end

        # @return [Integer] Screen Y position + 16.
        def y
          @oam_data[@base_offset]
        end

        # Where the top pixel starts at (top row).
        #
        def y_screen_pos
          y - 16
        end

        # @return [Integer] Byte 1 of the Sprite.
        def x
          @oam_data[@base_offset + 1]
        end

        def x_screen_pos
          x - 8
        end

        # @return [Integer] Byte 2 of the Sprite.
        def tile_index(obj_size_8x16, y_flipped, current_obj_y)
          return @oam_data[@base_offset + 2] unless obj_size_8x16

          if current_obj_y >= 0 && current_obj_y < 8
            y_flipped ? bottom_half : top_half
          else
            y_flipped ? top_half : bottom_half
          end
        end

        def top_half
          @oam_data[@base_offset + 2] & 0xFE
        end

        def bottom_half
          @oam_data[@base_offset + 2] | 0x01
        end

        # @return [Integer] Byte 3 of the Sprite.
        def attributes
          @oam_data[@base_offset + 3]
        end

        def bg_win_priority_set?
          (attributes & BIT_MASK_BG_WIN_PRIORITY_SET) != 0
        end

        def y_flipped?
          (attributes & BIT_MASK_OBJ_Y_FLIPPED) != 0
        end

        def x_flipped?
          (attributes & BIT_MASK_OBJ_X_FLIPPED) != 0
        end

        def use_obp1_palette?
          (attributes & BIT_MASK_USE_OBP1_PALETTE) != 0
        end

        # @return [String] Custom inspect for easier debugging.
        def inspect
          '#<Sprite ' \
            "y_pos=$#{format('%02X', y)} " \
            "x_pos=$#{format('%02X', x)} " \
            "tile_index=$#{format('%02X', top_half)} " \
            "attributes=#{format('%08b', attributes)}>"
        end
      end
    end
  end
end
