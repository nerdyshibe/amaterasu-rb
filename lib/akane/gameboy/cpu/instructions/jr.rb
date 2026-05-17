# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the JR (Jump Relative) instructions.
        class Jr < Base
          def initialize(cpu:, condition: nil)
            super(cpu:)

            @mnemonic = "JR #{format_operand(condition)}, e8"
            @logic    = build_logic(condition)
          end

          private

          def build_logic(condition)
            case condition
            when :nz then -> { jr(@registers.z_flag.zero?) }
            when :z  then -> { jr(@registers.z_flag == 1) }
            when :nc then -> { jr(@registers.c_flag.zero?) }
            when :c  then -> { jr(@registers.c_flag == 1) }
            else -> { jr(true) }
            end
          end

          # Jumps relative to a signed offset.
          #
          # - CPU always fetches the unsigned byte.
          # - Calculates the offset by signing the value between -128 and +127.
          # - If it's a conditional jump, check the condition and return early if it's false.
          # - If the condition is true or there is no condition, jump.
          def jr(cc)
            unsigned_byte = @cpu.fetch_next_byte
            offset = @cpu.sign_value(unsigned_byte)
            return unless cc

            @cpu.jump_to(address: @registers.pc + offset)
          end
        end
      end
    end
  end
end
