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
        end
      end
    end
  end
end
