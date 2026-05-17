# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Handles the logic related to all possible SUB instructions
        #
        # - SUB A, r8
        # - SUB A, [HL]
        # - SUB A, n8
        class Sub < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "SUB A, #{format_operand(source)}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all SUB instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { sub_a(@registers.a) }
            when :b      then -> { sub_a(@registers.b) }
            when :c      then -> { sub_a(@registers.c) }
            when :d      then -> { sub_a(@registers.d) }
            when :e      then -> { sub_a(@registers.e) }
            when :h      then -> { sub_a(@registers.h) }
            when :l      then -> { sub_a(@registers.l) }
            when :mem_hl then -> { sub_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { sub_a(@cpu.fetch_next_byte) }
            else
              -> { raise 'Not implemented Sub operation' }
            end
          end

          # Subtracts a given value from register A and stores it back into A.
          #
          # - Sets the Zero flag if the result is zero, otherwise clears it.
          # - Always sets the Subtraction flag.
          # - Sets the Half Carry flag if it needed to borrow from Bit 4.
          # - Sets the Carry flag if it needed to borrow (acc < value).
          def sub_a(value)
            acc = @registers.a
            result = @registers.a - value

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = true
            @registers.h_flag = (acc & 0x0F) < (value & 0x0F)
            @registers.c_flag = acc < value

            @registers.a = result
          end
        end
      end
    end
  end
end
