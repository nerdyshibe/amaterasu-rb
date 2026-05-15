# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the 16-bit Load instructions.
        class Ld16 < Base
          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LD #{format_operand(target)}, #{format_operand(source)}"
            @logic    = build_logic(target, source)
          end

          private

          def build_logic(target, source)
            case target
            when :bc then -> { @registers.hl = @cpu.fetch_next_word }
            when :de then -> { @registers.de = @cpu.fetch_next_word }
            when :hl
              case source
              when :imm16 then -> { @registers.hl = @cpu.fetch_next_word }
              end
            when :sp
              case source
              when :imm16 then -> { @registers.sp = @cpu.fetch_next_word }
              when :hl    then -> { @registers.sp = @registers.hl }
              end
            end
          end
        end
      end
    end
  end
end
