# frozen_string_literal: true

module Akane
  module Gameboy
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
