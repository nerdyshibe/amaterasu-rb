# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Defines the mnemonic, bytes and logic for the NOP instruction.
        class Nop < Base
          def initialize(cpu:)
            super

            @mnemonic = 'NOP'
            @logic = -> {}
          end
        end
      end
    end
  end
end
