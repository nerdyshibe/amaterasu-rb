# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Registers
        # Models the behavior of the LCD Status PPU Register.
        class LcdStatus
          BIT_MASK_WRITABLE_BITS = 0b01111000

          BIT_MASK_LYC_INTERRUPT_SELECT    = 1 << 6
          BIT_MASK_MODE_2_INTERRUPT_SELECT = 1 << 5
          BIT_MASK_MODE_1_INTERRUPT_SELECT = 1 << 4
          BIT_MASK_MODE_0_INTERRUPT_SELECT = 1 << 3

          attr_reader :value

          def initialize(skip_boot_rom:)
            @value = skip_boot_rom ? 0x85 : 0x00

            @interrupt_line_cache = interrupt_line_signal
          end

          def value=(value)
            @value = value & BIT_MASK_WRITABLE_BITS
          end

          # @param ppu_mode [Integer] 2-bit value.
          def set_mode_bits(ppu_mode)
            @interrupt_line_cache = interrupt_line_signal
            @value = (@value & 0b11111100) | ppu_mode
          end

          def set_lyc_bit
            @interrupt_line_cache = interrupt_line_signal
            @value |= 0b100
          end

          def clear_lyc_bit
            @interrupt_line_cache = interrupt_line_signal
            @value &= 0xFB
          end

          def lyc_interrupt_selected?
            (@value & BIT_MASK_LYC_INTERRUPT_SELECT) != 0
          end

          def mode_2_interrupt_selected?
            (@value & BIT_MASK_MODE_2_INTERRUPT_SELECT) != 0
          end

          def mode_1_interrupt_selected?
            (@value & BIT_MASK_MODE_1_INTERRUPT_SELECT) != 0
          end

          def mode_0_interrupt_selected?
            (@value & BIT_MASK_MODE_0_INTERRUPT_SELECT) != 0
          end

          def interrupt_line_signal
            (@value[6] && @value[2]) ||
              (@value[5] && (@value & 0b11) == 0b10) ||
              (@value[4] && (@value & 0b11) == 0b01) ||
              (@value[3] && (@value & 0b11) == 0b00)
          end

          def rising_edge?
            @interrupt_line_cache == 0 && interrupt_line_signal == 1
          end
        end
      end
    end
  end
end
