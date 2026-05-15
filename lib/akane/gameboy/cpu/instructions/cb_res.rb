# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the RES instructions.
        class CbRes < Base
          using Akane::Utils::BitOperations

          # Creates a new CbRes object containing the mnemonic (String) and logic (Proc).
          def initialize(cpu:, bit_pos:, target:)
            super(cpu:)

            @mnemonic = "RES #{bit_pos}, #{format_operand(target)}"
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
            when :b      then -> { @registers.b = res(bit_pos, @registers.b) }
            when :c      then -> { @registers.c = res(bit_pos, @registers.c) }
            when :d      then -> { @registers.d = res(bit_pos, @registers.d) }
            when :e      then -> { @registers.e = res(bit_pos, @registers.e) }
            when :h      then -> { @registers.h = res(bit_pos, @registers.h) }
            when :l      then -> { @registers.l = res(bit_pos, @registers.l) }
            when :mem_hl then -> { @registers.b = res(bit_pos, @cpu.bus_read(address: @registers.hl)) }
            when :a      then -> { @registers.a = res(bit_pos, @registers.a) }
            end
          end

          # Clears the bit from a given position [7..0] in a given target.
          # All flags remain untouched.
          #
          # @param bit_pos [Integer] Integer between 0 and 7.
          # @param target [Symbol] Either a 8-bit register (:a, :b, :c, ...) or :mem_hl.
          #
          def res(bit_pos, target)
            target.clear_bit(bit_pos)
          end
        end
      end
    end
  end
end
