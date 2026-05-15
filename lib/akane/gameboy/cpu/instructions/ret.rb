# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the RET + RETI instructions.
        class Ret < Base
          # Creates a Ret instruction object with a mnemonic and logic to be executed.
          def initialize(cpu:, condition: nil, enable_ime: false)
            super(cpu:)

            @mnemonic = enable_ime ? 'RETI' : "RET #{format_operand(condition)}".trim
            @logic    = build_logic(condition, enable_ime)
          end

          private

          # Returns a Proc object to be executed by the CPU at runtime.
          def build_logic(condition, enable_ime)
            return -> { reti } if enable_ime
            return -> { ret }  if condition.nil?

            case condition
            when :nz then -> { ret(@registers.z_flag.zero?) }
            when :z  then -> { ret(@registers.z_flag == 1) }
            when :nc then -> { ret(@registers.c_flag.zero?) }
            when :c  then -> { ret(@registers.c_flag == 1) }
            end
          end

          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Spends 1 cycle to evaluate condition.
          # ---------- This cycle is only for RET cc instructions.
          # ---------- Returns early if condition not met.
          # M-cycle 3: Pops the lsb from the Stack.
          # M-cycle 4: Pops the msb from the Stack.
          # M-cycle 5: Jumps to the return address.
          def ret(condition: true)
            @cpu.internal_processing
            return unless condition

            return_address = @cpu.stack_pop
            @cpu.jump_to(address: return_address)
          end

          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Pops the lsb from the Stack.
          # M-cycle 3: Pops the msb from the Stack.
          # M-cycle 4: Jumps to the return address
          #            Enable interrupts (same cycle).
          def reti
            ret
            @cpu.enable_interrupts
          end
        end
      end
    end
  end
end
