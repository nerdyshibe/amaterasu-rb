# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Defines the mnemonic, bytes and logic for the NOP instruction.
        class Base
          attr_reader :mnemonic

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
            return '[C]'   if operand == :mem_c
            return '[a8]'  if operand == :mem_unsig8

            operand.to_s.upcase
          end
        end
      end
    end
  end
end
