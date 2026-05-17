# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Handles the logic related to all possible OR instructions
        #
        # - OR A, r8
        # - OR A, [HL]
        # - OR A, n8
        class Or < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "OR A, #{source}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all OR instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { or_a(@registers.a) }
            when :b      then -> { or_a(@registers.b) }
            when :c      then -> { or_a(@registers.c) }
            when :d      then -> { or_a(@registers.d) }
            when :e      then -> { or_a(@registers.e) }
            when :h      then -> { or_a(@registers.h) }
            when :l      then -> { or_a(@registers.l) }
            when :mem_hl then -> { or_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { or_a(@cpu.fetch_next_byte) }
            end
          end

          # Performs a Bitwise OR between a given value and the A register.
          #
          def or_a(value)
            result = @registers.a | value

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)

            @registers.a = result
          end
        end
      end
    end
  end
end
