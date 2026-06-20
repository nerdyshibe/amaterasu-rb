# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the RST instructions.
        class Rst < Base
          # Creates a Call instruction object with a mnemonic and logic to be executed.
          def initialize(cpu:, vector:)
            super(cpu:)

            @mnemonic = "RST $#{format('%02X', vector)}"
            @logic    = -> { rst(vector) }
          end

          private

          # This is essentially a CALL, but jumps to a fixed address vector.
          #
          # M-cycle 1: Fetches opcode.
          # M-cycle 2: Stores the msb of the PC into the Stack.
          # M-cycle 3: Stores the lsb of the PC into the Stack.
          # M-cycle 4: Jumps to a fixed address vector.
          def rst(vector)
            @cpu.stack_push(value: @registers.pc)
            @cpu.jump_to(address: vector)
          end
        end
      end
    end
  end
end
