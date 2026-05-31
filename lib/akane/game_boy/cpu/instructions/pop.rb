# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the POP instructions.
        class Pop < Base
          # Creates a Pop instruction object with a mnemonic and logic to be executed.
          def initialize(cpu:, reg16:)
            super(cpu:)

            @mnemonic = "POP #{format_operand(reg16)}"
            @logic    = build_logic(reg16)
          end

          private

          # Returns a Proc object to be executed by the CPU at runtime.
          #
          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Gets the reg16 lsb from the stack.
          # M-cycle 3: Gets the reg16 msb from the stack.
          #            Assigns the 16-bit value to a given reg16 (same cycle).
          def build_logic(reg16)
            case reg16
            when :bc then -> { @registers.bc = @cpu.stack_pop }
            when :de then -> { @registers.de = @cpu.stack_pop }
            when :hl then -> { @registers.hl = @cpu.stack_pop }
            when :af then -> { @registers.af = @cpu.stack_pop }
            else
              raise ArgumentError, 'Unknown Pop reg16'
            end
          end
        end
      end
    end
  end
end
