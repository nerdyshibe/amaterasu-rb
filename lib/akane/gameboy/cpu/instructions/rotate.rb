# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the Rotate instructions.
        #
        # - RLCA: Rotate Left Circular A.
        # - RRCA: Rotate Right Circular A.
        # - RLA: Rotate Left Through Carry A.
        # - RRA: Rotate Right Through Carry A.
        class Rotate < Base
          using Akane::Utils::BitOperations

          def initialize(cpu:, operation:)
            super(cpu:)

            @mnemonic = format_operand(operation).to_s
            @logic    = build_logic(operation)
          end

          private

          # Returns a lambda object containing the instruction logic.
          def build_logic(operation)
            case operation
            when :rlca then -> { rlca }
            when :rrca then -> { rrca }
            when :rla  then -> { rla }
            when :rra  then -> { rra }
            end
          end

          # Rotate Left Circular.
          # Rotate all bits from the A register to the left.
          # Bit 7 falls off the left and at the same time:
          # - Either sets or clears the Carry flag depending on it's value.
          # - Wraps around the A register and becomes Bit 0.
          #
          # Before:  [C] <- [7][6][5][4][3][2][1][0]
          # After : [C=7]   [6][5][4][3][2][1][0][7] <-
          #
          # M-cycle 1: Fetches the opcode and performs the rotate.
          #
          def rlca
            old_bit7 = @registers.a.bit(7)

            @registers.clear_flags
            @registers.c_flag = old_bit7

            @registers.a = (@registers.a << 1) | old_bit7
          end

          # Rotate Right Circular.
          # Rotate all bits from the A register to the right.
          # Bit 0 falls off the right side and at the same time:
          # - Either sets or clears the Carry flag depending on it's value.
          # - Wraps around the A register and becomes Bit 7.
          #
          # Before:    [7][6][5][4][3][2][1][0] -> [C]
          # After : -> [0][7][6][5][4][3][2][1]    [C=0]
          #
          # M-cycle 1: Fetches the opcode and performs the rotate.
          #
          def rrca
            old_bit0 = @registers.a.bit(0)

            @registers.clear_flags
            @registers.c_flag = old_bit0

            @registers.a = (@registers.a >> 1) | (old_bit0 << 7)
          end

          # Rotate Left Through Carry.
          # - Rotate all bits from the A register to the left.
          # - Bit 7 falls off the left side and becomes the Carry flag.
          # - The value of Carry flag becomes the new Bit 0.
          #
          # Before:  [C] <- [7][6][5][4][3][2][1][0]
          # After :  [7]    [6][5][4][3][2][1][0][C] <-
          #
          # M-cycle 1: Fetches the opcode and performs the rotate.
          #
          def rla
            carry_in = @registers.c_flag
            old_bit7 = @registers.a.bit(7)

            @registers.clear_flags
            @registers.c_flag = old_bit7

            @registers.a = (@registers.a << 1) | carry_in
          end

          # Rotate Right Through Carry.
          # - Rotate all bits from the A register to the right.
          # - Bit 0 falls off the right side and becomes the Carry flag.
          # - The previous value of Carry flag becomes the new Bit 0.
          #
          # Before:    [7][6][5][4][3][2][1][0] -> [C]
          # After : -> [C][7][6][5][4][3][2][1]
          #
          # M-cycle 1: Fetches the opcode and performs the rotate.
          #
          def rra
            carry_in = @registers.c_flag
            old_bit0 = @registers.a.bit(0)

            @registers.clear_flags
            @registers.c_flag = old_bit0

            @registers.a = (@registers.a >> 1) | (carry_in << 7)
          end
        end
      end
    end
  end
end
