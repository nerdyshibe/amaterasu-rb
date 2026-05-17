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
            @logic    = build_logic(operand)
          end

          private

          def build_logic(operand)
            case operand
            when :a      then -> { @registers.a = dec(@registers.a) }
            when :b      then -> { @registers.b = dec(@registers.b) }
            when :c      then -> { @registers.c = dec(@registers.c) }
            when :d      then -> { @registers.d = dec(@registers.d) }
            when :e      then -> { @registers.e = dec(@registers.e) }
            when :h      then -> { @registers.h = dec(@registers.h) }
            when :l      then -> { @registers.l = dec(@registers.l) }
            when :bc     then -> { @registers.bc = dec16(@registers.bc) }
            when :de     then -> { @registers.de = dec16(@registers.de) }
            when :hl     then -> { @registers.hl = dec16(@registers.hl) }
            when :sp     then -> { @registers.sp = dec16(@registers.sp) }
            when :mem_hl
              lambda {
                value_at_mem_hl = @cpu.bus_read(address: @registers.hl)
                @cpu.bus_write(address: @registers.hl, value: dec(value_at_mem_hl))
              }
            end
          end

          # M-cycle 1: Decrements a 8-bit value, sets the flags.
          #
          def dec(value)
            result = value - 1

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = true
            @registers.h_flag = value.nobits?(0x0F)

            result
          end

          # M-cycle 1: Decrements a 16-bit register value.
          # M-cycle 2: Internal processing due to the 16-bit subtraction.
          # ---------  Flags are untouched in the dec16.
          #
          def dec16(reg16)
            @cpu.sub16(reg16, 1)
          end
        end
      end
    end
  end
end
