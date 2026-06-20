# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible SBC instructions
        #
        # - SBC A, r8
        # - SBC A, [HL]
        # - SBC A, n8
        class Sbc < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "SBC A, #{source}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all SBC instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { sbc_a(@registers.a) }
            when :b      then -> { sbc_a(@registers.b) }
            when :c      then -> { sbc_a(@registers.c) }
            when :d      then -> { sbc_a(@registers.d) }
            when :e      then -> { sbc_a(@registers.e) }
            when :h      then -> { sbc_a(@registers.h) }
            when :l      then -> { sbc_a(@registers.l) }
            when :mem_hl then -> { sbc_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { sbc_a(@cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown Sbc source'
            end
          end

          # Subtracts a given value + Carry flag from register A and stores it back into A.
          #
          # - Sets the Zero flag if the result is zero, otherwise clears it.
          # - Always sets the SBCtraction flag.
          # - Sets the Half Carry flag if it needed to borrow from Bit 4.
          # - Sets the Carry flag if it needed to borrow (acc < value).
          def sbc_a(value)
            acc = @registers.a
            carry_in = @registers.c_flag
            result = @registers.a - (value + carry_in)

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = true
            @registers.h_flag = (acc & 0x0F) < ((value & 0x0F) + carry_in)
            @registers.c_flag = acc < (value + carry_in)

            @registers.a = result
          end
        end
      end
    end
  end
end
