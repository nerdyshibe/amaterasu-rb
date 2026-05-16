# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the SRL instructions.
        #
        # - SRL r8
        # - SRL [HL]
        class CbSrl < Base
          using Akane::Utils::BitOperations

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "SRL #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = srl_reg8(@registers.b) }
            when :c      then -> { @registers.c = srl_reg8(@registers.c) }
            when :d      then -> { @registers.d = srl_reg8(@registers.d) }
            when :e      then -> { @registers.e = srl_reg8(@registers.e) }
            when :h      then -> { @registers.h = srl_reg8(@registers.h) }
            when :l      then -> { @registers.l = srl_reg8(@registers.l) }
            when :mem_hl then -> { srl_mem_hl }
            when :a      then -> { @registers.a = srl_reg8(@registers.a) }
            end
          end

          # Shift Right Logically.
          #
          # 0 -> [7][6][5][4][3][2][1][0] -> C
          #
          def srl_reg8(reg8)
            old_bit0 = reg8.bit(0)
            result = reg8 >> 1

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit0 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def srl_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            old_bit0 = byte.bit(0)
            result = byte >> 1

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
