# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the INC (Increment) instructions.
        class Inc < Base
          def initialize(cpu:, operand:)
            super(cpu:)

            @mnemonic = "INC #{format_operand(operand)}"
            @logic    = build_logic(operand)
          end

          private

          def build_logic(operand)
            case operand
            when :a      then -> { @registers.a = inc(@registers.a) }
            when :b      then -> { @registers.b = inc(@registers.b) }
            when :c      then -> { @registers.c = inc(@registers.c) }
            when :d      then -> { @registers.d = inc(@registers.d) }
            when :e      then -> { @registers.e = inc(@registers.e) }
            when :h      then -> { @registers.h = inc(@registers.h) }
            when :l      then -> { @registers.l = inc(@registers.l) }
            when :bc     then -> { @registers.bc = inc16(@registers.bc) }
            when :de     then -> { @registers.de = inc16(@registers.de) }
            when :hl     then -> { @registers.hl = inc16(@registers.hl) }
            when :sp     then -> { @registers.sp = inc16(@registers.sp) }
            when :mem_hl
              lambda do
                value_at_mem_hl = @cpu.bus_read(address: @registers.hl)
                @cpu.bus_write(address: @registers.hl, value: inc(value_at_mem_hl))
              end
            else
              raise ArgumentError, 'Unknown Inc operand'
            end
          end

          # M-cycle 1: Increments a 8-bit value, sets the flags.
          #
          def inc(value)
            result = value + 1

            @registers.z_flag = result.nobits?(0xFF)
            @registers.n_flag = false
            @registers.h_flag = value.allbits?(0x0F)

            result
          end

          # M-cycle 1: Increments a 16-bit register value.
          # M-cycle 2: Internal processing due to the 16-bit addition.
          # ---------  Flags are untouched in the inc16.
          #
          def inc16(reg16)
            @cpu.add16(reg16, 1)
          end
        end
      end
    end
  end
end
