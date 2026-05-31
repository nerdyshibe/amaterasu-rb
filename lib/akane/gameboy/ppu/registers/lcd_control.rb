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
          BIT_MASK_BG_PRIORITY     = 1 << 0

          attr_reader :value

          def initialize(skip_boot_rom:)
            @value = skip_boot_rom ? 0x91 : 0x00
          end

          def value=(value)
            @value = value & 0xFF
          end

          # @return [true, false]
          def lcd_enabled?
            @value.anybits?(BIT_MASK_LCD_ENABLE)
          end

          def window_tile_map_high?
            @value.anybits?(BIT_MASK_WINDOW_TILE_MAP)
          end

          def window_enabled?
            @value.anybits?(BIT_MASK_WINDOW_ENABLE)
          end

          def tile_data_at_0x8000?
            @value.anybits?(BIT_MASK_BG_WINDOW_TILES)
          end

          def bg_tile_map_high?
            @value.anybits?(BIT_MASK_BG_TILE_MAP)
          end

          def obj_size_8x16?
            @value.anybits?(BIT_MASK_OBJ_SIZE)
          end

          def obj_enabled?
            @value.anybits?(BIT_MASK_OBJ_ENABLE)
          end

          def bg_priority_set?
            @value.anybits?(BIT_MASK_BG_PRIORITY)
          end
        end
      end
    end
  end
end
