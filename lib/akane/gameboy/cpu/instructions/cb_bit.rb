# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the BIT instructions.
        class CbBit < Base
          using Akane::Utils::BitOperations

          def initialize(cpu:, bit_pos:, target:)
            super(cpu:)

            @mnemonic = "BIT #{bit_pos}, #{format_operand(target)}"
            @logic    = build_logic(bit_pos, target)
          end

          private

          def build_logic(bit_pos, target)
            case target
            when :b      then -> { bit_test(bit_pos, @registers.b) }
            when :c      then -> { bit_test(bit_pos, @registers.c) }
            when :d      then -> { bit_test(bit_pos, @registers.d) }
            when :e      then -> { bit_test(bit_pos, @registers.e) }
            when :h      then -> { bit_test(bit_pos, @registers.h) }
            when :l      then -> { bit_test(bit_pos, @registers.l) }
            when :mem_hl then -> { bit_test(bit_pos, @cpu.bus_read(address: @registers.hl)) }
            when :a      then -> { bit_test(bit_pos, @registers.a) }
            end
          end

          # Checks the bit value from a given target at a given position [0-7].
          #
          # - Sets the zero flag if bit tested is 0, otherwise clears the flag.
          # - Subtraction flag is always cleared.
          # - Half Carry flag is always set.
          # - Carry flag is untouched.
          def bit_test(bit_pos, target)
            bit_value = target.bit(bit_pos)

            @registers.z_flag = bit_value.zero?
            @registers.n_flag = false
            @registers.h_flag = true
          end
        end
      end
    end
  end
end
