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
          end

          def value=(value)
            @value = value & BIT_MASK_WRITABLE_BITS
          end

          # @param ppu_mode [Integer] 2-bit value.
          def set_mode_bits(ppu_mode)
            @value |= ppu_mode
          end

          def set_lyc_bit
            @value |= 0b100
          end

          def clear_lyc_bit
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

          # TODO: setup STAT Interrupt line
          # Only fires on the rising edge
          # Line is
          # (lyc_int_selected? && lyc_bit_set?) ||
          #   (mode2_int_selected? && in_mode_2?) ||
          #   (mode1_int_selected? && in_mode_1?) ||
          #   (mode0_int_selected? && in_mode_0?) ||
        end
      end
    end
  end
end
