# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible XOR instructions
        #
        # - XOR A, r8
        # - XOR A, [HL]
        # - XOR A, n8
        class Xor < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = define_mnemonic(source)
            @logic    = build_logic(source)
          end

          private

          def define_mnemonic(source)
            case source
            when :mem_hl then 'XOR A, [HL]'
            when :imm8 then 'XOR A, n8'
            else "XOR A, #{source.upcase}"
            end
          end

          def build_logic(source)
            case source
            when :a      then -> { xor_a(@registers.a) }
            when :b      then -> { xor_a(@registers.b) }
            when :c      then -> { xor_a(@registers.c) }
            when :d      then -> { xor_a(@registers.d) }
            when :e      then -> { xor_a(@registers.e) }
            when :h      then -> { xor_a(@registers.h) }
            when :l      then -> { xor_a(@registers.l) }
            when :mem_hl then -> { xor_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { xor_a(@cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown Xor source'
            end
          end

          def xor_a(value)
            result = @registers.a ^ value

            @registers.clear_flags
            @registers.z_flag = result.nobits?(0xFF)

            @registers.a = result
          end
        end
      end
    end
  end
end
