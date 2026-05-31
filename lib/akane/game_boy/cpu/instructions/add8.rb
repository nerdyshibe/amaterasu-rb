# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible ADD instructions
        #
        # - ADD A, r8
        # - ADD A, [HL]
        # - ADD A, n8
        class Add8 < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "ADD A, #{source}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all ADD instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { add_a(@registers.a) }
            when :b      then -> { add_a(@registers.b) }
            when :c      then -> { add_a(@registers.c) }
            when :d      then -> { add_a(@registers.d) }
            when :e      then -> { add_a(@registers.e) }
            when :h      then -> { add_a(@registers.h) }
            when :l      then -> { add_a(@registers.l) }
            when :mem_hl then -> { add_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { add_a(@cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown Add8 source'
            end
          end

          # Adds a given value into register A.
          #
          # - Sets the Zero flag if the result is zero, otherwise clears it.
          # - Sets the Subtraction flag to zero.
          # - Sets the Half Carry flag if there was overflow from Bit 3, otherwise clears it.
          # - Sets the Carry flag if there was overflow from Bit 7, otherwise clears it.
          def add_a(value)
            acc = @registers.a
            result = @registers.a + value

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = false
            @registers.h_flag = (acc & 0x0F) + (value & 0x0F) > 0x0F
            @registers.c_flag = result > 0xFF

            @registers.a = result
          end
        end
      end
    end
  end
end
