# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible ADC instructions
        #
        # - ADC A, r8
        # - ADC A, [HL]
        # - ADC A, n8
        class Adc < Base
          # @param cpu [Cpu] Holds a direct reference to the main Cpu object.
          # @param source [Symbol] Operator, can be a register, :mem_hl, :imm8.
          def initialize(cpu:, source:)
            super(cpu:)

            @mnemonic = "ADC A, #{source}"
            @logic    = build_logic(source)
          end

          private

          # Builds the logic for all ADC instructions.
          # Returns a lambda object to be called by the CPU.
          def build_logic(source)
            case source
            when :a      then -> { adc_a(@registers.a) }
            when :b      then -> { adc_a(@registers.b) }
            when :c      then -> { adc_a(@registers.c) }
            when :d      then -> { adc_a(@registers.d) }
            when :e      then -> { adc_a(@registers.e) }
            when :h      then -> { adc_a(@registers.h) }
            when :l      then -> { adc_a(@registers.l) }
            when :mem_hl then -> { adc_a(@cpu.bus_read(address: @registers.hl)) }
            when :imm8   then -> { adc_a(@cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown Adc source'
            end
          end

          # ADCs a given value plus the Carry flag into register A.
          #
          # - Sets the Zero flag if the result is zero, otherwise clears it.
          # - Sets the Subtraction flag to zero.
          # - Sets the Half Carry flag if there was overflow from Bit 3, otherwise clears it.
          # - Sets the Carry flag if there was overflow from Bit 7, otherwise clears it.
          def adc_a(value)
            acc = @registers.a
            carry_in = @registers.c_flag
            result = @registers.a + value + carry_in

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = false
            @registers.h_flag = (acc & 0x0F) + (value & 0x0F) + carry_in > 0x0F
            @registers.c_flag = result > 0xFF

            @registers.a = result
          end
        end
      end
    end
  end
end
