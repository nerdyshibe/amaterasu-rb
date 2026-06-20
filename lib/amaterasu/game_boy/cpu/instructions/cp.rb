# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible CP instructions
        #
        # - CP A, r8
        # - CP A, [HL]
        # - CP A, n8
        class Cp < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "CP A, #{source}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all CP instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { cp_a(@registers.a) }
            when :b      then -> { cp_a(@registers.b) }
            when :c      then -> { cp_a(@registers.c) }
            when :d      then -> { cp_a(@registers.d) }
            when :e      then -> { cp_a(@registers.e) }
            when :h      then -> { cp_a(@registers.h) }
            when :l      then -> { cp_a(@registers.l) }
            when :mem_hl then -> { cp_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { cp_a(@cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown Cp source'
            end
          end

          # Subtracts a given value from register A and discard the result.
          #
          # - Sets the Zero flag if the result is zero, otherwise clears it.
          # - Always sets the Subtraction flag.
          # - Sets the Half Carry flag if it needed to borrow from Bit 4.
          # - Sets the Carry flag if it needed to borrow (acc < value).
          def cp_a(value)
            acc = @registers.a
            result = @registers.a - value

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = true
            @registers.h_flag = (acc & 0x0F) < (value & 0x0F)
            @registers.c_flag = acc < value
          end
        end
      end
    end
  end
end
