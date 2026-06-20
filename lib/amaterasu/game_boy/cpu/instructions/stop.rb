# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic for STOP instruction.
        class Stop < Base
          def initialize(cpu:)
            super

            @mnemonic = 'STOP'
            @logic    = -> { @cpu.fetch_next_byte }
          end
        end
      end
    end
  end
end
