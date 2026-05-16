# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the RRC (Rotate Right Circular) instructions.
        #
        # - RRC r8
        # - RRC [HL]
        class CbRrc < Base
          using Akane::Utils::BitOperations

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "RRC #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = rrc_reg8(@registers.b) }
            when :c      then -> { @registers.c = rrc_reg8(@registers.c) }
            when :d      then -> { @registers.d = rrc_reg8(@registers.d) }
            when :e      then -> { @registers.e = rrc_reg8(@registers.e) }
            when :h      then -> { @registers.h = rrc_reg8(@registers.h) }
            when :l      then -> { @registers.l = rrc_reg8(@registers.l) }
            when :mem_hl then -> { rrc_mem_hl }
            when :a      then -> { @registers.a = rrc_reg8(@registers.a) }
            end
          end

          # [0] -> [7][6][5][4][3][2][1][0] -> [C]
          #        [0][7][6][5][4][3][2][1] -> [C=0]
          #
          def rrc_reg8(reg8)
            old_bit0 = reg8.bit(0)
            result = (old_bit0 << 7) | (reg8 >> 1)

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit0 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def rrc_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            old_bit0 = byte.bit(0)
            result = (old_bit0 << 7) | (byte >> 1)

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
