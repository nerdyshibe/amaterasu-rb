# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the PUSH instructions.
        class Push < Base
          # Creates a Push instruction object with a mnemonic and logic to be executed.
          def initialize(cpu:, reg16:)
            super(cpu:)

            @mnemonic = "PUSH #{format_operand(reg16)}"
            @logic    = build_logic(reg16)
          end

          private

          # Returns a Proc object to be executed by the CPU at runtime.
          def build_logic(reg16)
            case reg16
            when :bc then -> { push(@registers.bc) }
            when :de then -> { push(@registers.de) }
            when :hl then -> { push(@registers.hl) }
            when :af then -> { push(@registers.af) }
            else
              raise ArgumentError, 'Unknown Push reg16'
            end
          end

          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Internal processing (dead cycle).
          # M-cycle 3: Writes msb from reg16 into the stack.
          # M-cycle 4: Writes lsb from reg16 into the stack.
          def push(reg16)
            @cpu.internal_processing
            @cpu.stack_push(value: reg16)
          end
        end
      end
    end
  end
end
