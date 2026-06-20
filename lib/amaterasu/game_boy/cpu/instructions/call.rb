# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the CALL instructions.
        class Call < Base
          # Creates a Call instruction object with a mnemonic and logic to be executed.
          def initialize(cpu:, condition: nil)
            super(cpu:)

            @mnemonic = "CALL #{format_operand(condition)}, imm16"
            @logic    = build_logic(condition)
          end

          private

          # Returns a Proc object to be executed by the CPU at runtime.
          def build_logic(condition)
            case condition
            when :nz then -> { call(@registers.z_flag.zero?) }
            when :z  then -> { call(@registers.z_flag == 1) }
            when :nc then -> { call(@registers.c_flag.zero?) }
            when :c  then -> { call(@registers.c_flag == 1) }
            else -> { call(true) }
            end
          end

          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Fetches next immediate byte (lsb).
          # M-cycle 3: Fetches next immediate byte (msb).
          # ---------- Return early if condition not met.
          # M-cycle 4: Pushes the msb of the PC onto the stack.
          # M-cycle 5: Pushes the lsb of the PC onto the stack.
          # M-cycle 6: Jumps to the call address.
          def call(condition)
            call_address = @cpu.fetch_next_word
            return unless condition

            @cpu.stack_push(value: @registers.pc)
            @cpu.jump_to(address: call_address)
          end
        end
      end
    end
  end
end
