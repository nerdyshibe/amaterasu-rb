# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of the DI (Disable Interrupts) instruction.
        class Ei < Base
          def initialize(cpu:)
            super

            @mnemonic = 'EI'
            @logic    = -> { @cpu.enable_interrupts }
          end
        end
      end
    end
  end
end
