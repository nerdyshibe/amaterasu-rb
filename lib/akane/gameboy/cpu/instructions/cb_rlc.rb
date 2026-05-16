# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the RLC (Rotate Left Circular) instructions.
        #
        # - RLC r8
        # - RLC [HL]
        class CbRlc < Base
          using Akane::Utils::BitOperations

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "RLC #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = rlc_reg8(@registers.b) }
            when :c      then -> { @registers.c = rlc_reg8(@registers.c) }
            when :d      then -> { @registers.d = rlc_reg8(@registers.d) }
            when :e      then -> { @registers.e = rlc_reg8(@registers.e) }
            when :h      then -> { @registers.h = rlc_reg8(@registers.h) }
            when :l      then -> { @registers.l = rlc_reg8(@registers.l) }
            when :mem_hl then -> { rlc_mem_hl }
            when :a      then -> { @registers.a = rlc_reg8(@registers.a) }
            end
          end

          # [C]   <- [7][6][5][4][3][2][1][0] <- [7]
          # [C=7]    [6][5][4][3][2][1][0][7]
          #
          def rlc_reg8(reg8)
            old_bit7 = reg8.bit(7)
            result = (reg8 << 1) | old_bit7

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit7 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def rlc_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            old_bit7 = byte.bit(7)
            result = (byte << 1) | old_bit7

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit7 == 1

            @cpu.bus_write(address: @registers.hl, value: result)
          end
        end
      end
    end
  end
end
