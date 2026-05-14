# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the 8-bit Load instructions.
        class Load16 < Base
          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LD #{format_operand(target)}, #{format_operand(source)}"
            @bytes    = 1 + fetch_cost(target) + fetch_cost(source)
            @m_cycles = 1 + memory_cost(target) + memory_cost(source)
            @logic    = define_logic(target, source)
          end

          private

          def define_logic(target, source)
            case target
            when :hl
              case source
              when :imm16 then -> { @registers.hl = @cpu.fetch_next_word }
              end
            end
          end
        end
      end
    end
  end
end
