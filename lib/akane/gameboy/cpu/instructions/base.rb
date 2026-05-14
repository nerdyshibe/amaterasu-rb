# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Defines the mnemonic, bytes and logic for the NOP instruction.
        class Base
          attr_reader :mnemonic, :bytes, :m_cycles

          def initialize(cpu:)
            @cpu = cpu
            @registers = cpu.registers
          end

          def execute
            @logic.call
          end

          private

          def format_operand(operand)
            return ''      if operand.nil?
            return 'n8'    if operand == :imm8
            return 'n16'   if operand == :imm16
            return '[HL]'  if operand == :mem_hl
            return '[HL+]' if operand == :mem_hli
            return '[HL-]' if operand == :mem_hld

            operand.upcase
          end

          def fetch_cost(operand)
            return 1 if operand == :imm8
            return 2 if operand == :imm16

            0
          end

          def memory_cost(operand)
            return 1 if operand == :imm8
            return 2 if operand == :imm16
            return 1 if operand == :mem_hl

            0
          end
        end
      end
    end
  end
end
