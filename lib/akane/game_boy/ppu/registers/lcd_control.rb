# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Registers
        # Models the behavior of the LCD Control PPU Register.
        class LcdControl
          BIT_MASK_LCD_ENABLE      = 1 << 7
          BIT_MASK_WINDOW_TILE_MAP = 1 << 6
          BIT_MASK_WINDOW_ENABLE   = 1 << 5
          BIT_MASK_BG_WINDOW_TILES = 1 << 4
          BIT_MASK_BG_TILE_MAP     = 1 << 3
          BIT_MASK_OBJ_SIZE        = 1 << 2
          BIT_MASK_OBJ_ENABLE      = 1 << 1
          BIT_MASK_BG_WIN_ENABLED  = 1 << 0

          attr_reader :value

          def initialize(skip_boot_rom:)
            @value = skip_boot_rom ? 0x91 : 0x00

            update_derived_states
          end

          # @param value [Integer] 8-bit value written into 0xFF40.
          def value=(value)
            @value = value & 0xFF

            update_derived_states
          end

          # Computes new state and caches the value on the Register write.
          def update_derived_states
            @lcd_enabled          = (@value & BIT_MASK_LCD_ENABLE) != 0
            @window_tile_map_high = (@value & BIT_MASK_WINDOW_TILE_MAP) != 0
            @window_enabled       = (@value & BIT_MASK_WINDOW_ENABLE) != 0
            @tile_data_at_0x8000  = (@value & BIT_MASK_BG_WINDOW_TILES) != 0
            @bg_tile_map_high     = (@value & BIT_MASK_BG_TILE_MAP) != 0
            @obj_size_8x16        = (@value & BIT_MASK_OBJ_SIZE) != 0
            @obj_enabled          = (@value & BIT_MASK_OBJ_ENABLE) != 0
            @bg_win_enabled       = (@value & BIT_MASK_BG_WIN_ENABLED) != 0
          end

          def lcd_enabled?          = @lcd_enabled
          def window_tile_map_high? = @window_tile_map_high
          def window_enabled?       = @window_enabled
          def tile_data_at_0x8000?  = @tile_data_at_0x8000
          def bg_tile_map_high?     = @bg_tile_map_high
          def obj_size_8x16?        = @obj_size_8x16
          def obj_enabled?          = @obj_enabled
          def bg_win_enabled?       = @bg_win_enabled
        end
      end
    end
  end
end
