# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic for DAA instruction.
        class Daa < Base
          def initialize(cpu:)
            super

            @mnemonic = 'DAA'
            @logic    = -> { daa }
          end

          private

          # Decimal Adjust Accumulator.
          #
          # Is used after performing a given arithmetic operation (ADD, SUB, ADC, SBC)
          # whose inputs were in Binary-Coded Decimal (BCD).
          # So after running this instruction the numbers would be adjusted to BCD format.
          #
          # This instruction never clears the Carry flag (1 => 0).
          # It either preserves the value (0 => 0), (1 => 1) or sets it (0 => 1).
          #
          def daa
            acc = @registers.a
            carry_in = @registers.c_flag
            new_carry = carry_in == 1
            bcd_correction = 0x00

            if @registers.n_flag.zero?
              bcd_correction |= 0x06 if @registers.h_flag == 1 || (acc & 0x0F) > 0x09

              if @registers.c_flag == 1 || (acc & 0xFF) > 0x99
                bcd_correction |= 0x60
                new_carry = true
              end

              bcd_adjusted = acc + bcd_correction
            else
              bcd_correction |= 0x06 if @registers.h_flag == 1
              bcd_correction |= 0x60 if @registers.c_flag == 1

              bcd_adjusted = acc - bcd_correction
            end

            @registers.z_flag = bcd_adjusted.nobits?(0xFF)
            @registers.h_flag = false
            @registers.c_flag = new_carry

            @registers.a = bcd_adjusted
          end
        end
      end
    end
  end
end
