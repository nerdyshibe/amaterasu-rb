# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the SRA instructions.
        #
        # - SRA r8
        # - SRA [HL]
        class CbSra < Base
          include Utils::BitOps

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "SRA #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = sra_reg8(@registers.b) }
            when :c      then -> { @registers.c = sra_reg8(@registers.c) }
            when :d      then -> { @registers.d = sra_reg8(@registers.d) }
            when :e      then -> { @registers.e = sra_reg8(@registers.e) }
            when :h      then -> { @registers.h = sra_reg8(@registers.h) }
            when :l      then -> { @registers.l = sra_reg8(@registers.l) }
            when :mem_hl then -> { sra_mem_hl }
            when :a      then -> { @registers.a = sra_reg8(@registers.a) }
            else
              raise ArgumentError, 'Unknown CbSra target'
            end
          end

          # Shift Right Arithmetically.
          #
          # [7][6][5][4][3][2][1][0] -> C
          #
          def sra_reg8(reg8)
            old_bit0 = bit(reg8, 0)
            old_bit7 = bit(reg8, 7)
            result = (old_bit7 << 7) | (reg8 >> 1)

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit0 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def sra_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            old_bit0 = bit(byte, 0)
            old_bit7 = bit(byte, 7)
            result = (old_bit7 << 7) | (byte >> 1)

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit0 == 1

            @cpu.bus_write(address: @registers.hl, value: result)
          end
        end
      end
    end
  end
end
