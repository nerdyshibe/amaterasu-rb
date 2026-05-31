# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the SLA instructions.
        #
        # - SLA r8
        # - SLA [HL]
        class CbSla < Base
          include Utils::BitOps

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "SLA #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = sla_reg8(@registers.b) }
            when :c      then -> { @registers.c = sla_reg8(@registers.c) }
            when :d      then -> { @registers.d = sla_reg8(@registers.d) }
            when :e      then -> { @registers.e = sla_reg8(@registers.e) }
            when :h      then -> { @registers.h = sla_reg8(@registers.h) }
            when :l      then -> { @registers.l = sla_reg8(@registers.l) }
            when :mem_hl then -> { sla_mem_hl }
            when :a      then -> { @registers.a = sla_reg8(@registers.a) }
            else
              raise ArgumentError, 'Unknown CbSla target'
            end
          end

          # Shift Left Arithmetically.
          #
          # C <- [7][6][5][4][3][2][1][0] <- 0
          #
          def sla_reg8(reg8_value)
            old_bit7 = bit(reg8_value, 7)
            result = reg8_value << 1

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)
            @registers.c_flag = old_bit7 == 1

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def sla_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            old_bit7 = bit(byte, 7)
            result = byte << 1

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
