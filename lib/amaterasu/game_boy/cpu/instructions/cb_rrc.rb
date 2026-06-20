# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the RRC (Rotate Right Circular) instructions.
        #
        # - RRC r8
        # - RRC [HL]
        class CbRrc < Base
          include Utils::BitOps

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
            else
              raise ArgumentError, 'Unknown CbRrc target'
            end
          end

          # [0] -> [7][6][5][4][3][2][1][0] -> [C]
          #        [0][7][6][5][4][3][2][1] -> [C=0]
          #
          def rrc_reg8(reg8_value)
            old_bit0 = bit(reg8_value, 0)
            result = (old_bit0 << 7) | (reg8_value >> 1)

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit0 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def rrc_mem_hl
            value_at_mem_hl = @cpu.bus_read(address: @registers.hl)
            old_bit0 = bit(value_at_mem_hl, 0)
            result = (old_bit0 << 7) | (value_at_mem_hl >> 1)

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
