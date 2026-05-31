# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the SWAP instructions.
        #
        # - SWAP r8
        # - SWAP [HL]
        class CbSwap < Base
          include Utils::BitOps

          def initialize(cpu:, target:)
            super(cpu:)

            @mnemonic = "SWAP #{format_operand(target)}"
            @logic    = build_logic(target)
          end

          private

          def build_logic(target)
            case target
            when :b      then -> { @registers.b = swap(@registers.b) }
            when :c      then -> { @registers.c = swap(@registers.c) }
            when :d      then -> { @registers.d = swap(@registers.d) }
            when :e      then -> { @registers.e = swap(@registers.e) }
            when :h      then -> { @registers.h = swap(@registers.h) }
            when :l      then -> { @registers.l = swap(@registers.l) }
            when :mem_hl then -> { swap_mem_hl }
            when :a      then -> { @registers.a = swap(@registers.a) }
            else
              raise ArgumentError, 'Unknown CbSwap target'
            end
          end

          # Swaps the positions of the Upper and Lower 4 bits.
          #
          # 11110000 -> 00001111
          #
          def swap(target)
            upper4 = (target >> 4) & 0x0F
            result = (target << 4) | upper4

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)

            result
          end

          # Takes 2 extra cycles due to the Bus read and write operations.
          def swap_mem_hl
            byte = @cpu.bus_read(address: @registers.hl)
            upper4 = (byte >> 4) & 0x0F
            result = (byte << 4) | upper4

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)

            @cpu.bus_write(address: @registers.hl, value: result)
          end
        end
      end
    end
  end
end
