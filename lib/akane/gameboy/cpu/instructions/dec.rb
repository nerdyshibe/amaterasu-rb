# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the Decrement instructions.
        class Dec < Base
          def initialize(cpu:, operand:)
            super(cpu:)

            @mnemonic = "DEC #{format_operand(operand)}"
            @bytes    = 1 + fetch_cost(operand)
            @m_cycles = 1 + memory_cost(operand)
            @logic    = define_logic(operand)
          end

          private

          def define_logic(operand)
            case operand
            when :a      then -> { @registers.a = dec(@registers.a) }
            when :b      then -> { @registers.b = dec(@registers.b) }
            when :c      then -> { @registers.c = dec(@registers.c) }
            when :d      then -> { @registers.d = dec(@registers.d) }
            when :e      then -> { @registers.e = dec(@registers.e) }
            when :h      then -> { @registers.h = dec(@registers.h) }
            when :l      then -> { @registers.l = dec(@registers.l) }
            when :mem_hl
              lambda {
                value_at_mem_hl = @cpu.bus_read(address: @registers.hl)
                @cpu.bus_write(address: @registers.hl, value: dec(value_at_mem_hl))
              }
            end
          end

          def dec(value)
            result = value - 1

            @registers.z_flag = result.zero?
            @registers.n_flag = true
            @registers.h_flag = value.nobits?(0x0F)

            result
          end
        end
      end
    end
  end
end
