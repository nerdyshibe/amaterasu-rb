# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        include Loads

        Instruction = Data.define(:mnemonic, :execute)

        private

        def wire_instructions
          @instructions[0x00] = Instruction.new(mnemonic: 'NOP', execute: -> { nil })

          @instructions[0x3E] = Instruction.new(mnemonic: 'LD A,n8', execute: -> { load_a_n8 })

          @instructions[0x42] = Instruction.new(mnemonic: 'LD B,D', execute: -> { load_b_d })
        end
      end
    end
  end
end
