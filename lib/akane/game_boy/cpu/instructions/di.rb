# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of the DI (Disable Interrupts) instruction.
        class Di < Base
          def initialize(cpu:)
            super

            @mnemonic = 'DI'
            @bytes    = 1
            @m_cycles = 1
            @logic    = -> { @cpu.disable_interrupts }
          end
        end
      end
    end
  end
end
