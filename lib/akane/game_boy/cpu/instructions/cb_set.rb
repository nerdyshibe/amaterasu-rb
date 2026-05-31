# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the SET instructions.
        #
        # - SET u3, r8
        # - SET u3, [HL]
        class CbSet < Base
          include Utils::BitOps

          # Creates a new CbSet object containing the mnemonic (String) and logic (Proc).
          def initialize(cpu:, bit_pos:, target:)
            super(cpu:)

            @mnemonic = "SET #{bit_pos}, #{format_operand(target)}"
            @logic    = build_logic(bit_pos, target)
          end

          private

          # @param bit_pos [Integer] Integer between 0 and 7.
          # @param target [Symbol] Either a 8-bit register (:a, :b, :c, ...) or :mem_hl.
          #
          # @return [Proc] Setups what the instruction should execute at runtime.
          #
          def build_logic(bit_pos, target)
            case target
            when :a      then -> { @registers.a = set_bit(@registers.a, bit_pos) }
            when :b      then -> { @registers.b = set_bit(@registers.b, bit_pos) }
            when :c      then -> { @registers.c = set_bit(@registers.c, bit_pos) }
            when :d      then -> { @registers.d = set_bit(@registers.d, bit_pos) }
            when :e      then -> { @registers.e = set_bit(@registers.e, bit_pos) }
            when :h      then -> { @registers.h = set_bit(@registers.h, bit_pos) }
            when :l      then -> { @registers.l = set_bit(@registers.l, bit_pos) }
            when :mem_hl
              lambda do
                result = set_bit(@cpu.bus_read(address: @registers.hl), bit_pos)
                @cpu.bus_write(address: @registers.hl, value: result)
              end
            else
              raise ArgumentError, 'Unknown CbSet target'
            end
          end
        end
      end
    end
  end
end
