# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the 8-bit Load instructions.
        class Load8 < Base
          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LD #{format_operand(target)}, #{format_operand(source)}"
            @bytes    = 1 + fetch_cost(target) + fetch_cost(source)
            @m_cycles = 1 + memory_cost(target) + memory_cost(source)
            @logic    = define_logic(target, source)
          end

          private

          def define_logic(target, source)
            return load_into_a(source) if target == :a
            return load_into_b(source) if target == :b
            return load_into_c(source) if target == :c
            return load_into_d(source) if target == :d
            return load_into_e(source) if target == :e
            return load_into_h(source) if target == :h
            return load_into_l(source) if target == :l

            load_into_mem_hl(source)
          end

          def load_into_a(source)
            case source
            when :a      then -> {}
            when :b      then -> { @registers.a = @registers.b }
            when :c      then -> { @registers.a = @registers.c }
            when :d      then -> { @registers.a = @registers.d }
            when :e      then -> { @registers.a = @registers.e }
            when :h      then -> { @registers.a = @registers.h }
            when :l      then -> { @registers.a = @registers.l }
            when :imm8   then -> { @registers.a = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.a = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_b(source)
            case source
            when :a      then -> { @registers.b = @registers.a }
            when :b      then -> {}
            when :c      then -> { @registers.b = @registers.c }
            when :d      then -> { @registers.b = @registers.d }
            when :e      then -> { @registers.b = @registers.e }
            when :h      then -> { @registers.b = @registers.h }
            when :l      then -> { @registers.b = @registers.l }
            when :imm8   then -> { @registers.b = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.b = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_c(source)
            case source
            when :a      then -> { @registers.c = @registers.a }
            when :b      then -> { @registers.c = @registers.b }
            when :c      then -> {}
            when :d      then -> { @registers.c = @registers.d }
            when :e      then -> { @registers.c = @registers.e }
            when :h      then -> { @registers.c = @registers.h }
            when :l      then -> { @registers.c = @registers.l }
            when :imm8   then -> { @registers.c = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.c = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_d(source)
            case source
            when :a      then -> { @registers.d = @registers.a }
            when :b      then -> { @registers.d = @registers.b }
            when :c      then -> { @registers.d = @registers.c }
            when :d      then -> {}
            when :e      then -> { @registers.d = @registers.e }
            when :h      then -> { @registers.d = @registers.h }
            when :l      then -> { @registers.d = @registers.l }
            when :imm8   then -> { @registers.d = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.d = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_e(source)
            case source
            when :a      then -> { @registers.e = @registers.a }
            when :b      then -> { @registers.e = @registers.b }
            when :c      then -> { @registers.e = @registers.c }
            when :d      then -> { @registers.e = @registers.d }
            when :e      then -> {}
            when :h      then -> { @registers.e = @registers.h }
            when :l      then -> { @registers.e = @registers.l }
            when :imm8   then -> { @registers.e = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.e = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_h(source)
            case source
            when :a      then -> { @registers.h = @registers.a }
            when :b      then -> { @registers.h = @registers.b }
            when :c      then -> { @registers.h = @registers.c }
            when :d      then -> { @registers.h = @registers.d }
            when :e      then -> { @registers.h = @registers.e }
            when :h      then -> {}
            when :l      then -> { @registers.h = @registers.l }
            when :imm8   then -> { @registers.h = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.h = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_l(source)
            case source
            when :a      then -> { @registers.l = @registers.a }
            when :b      then -> { @registers.l = @registers.b }
            when :c      then -> { @registers.l = @registers.c }
            when :d      then -> { @registers.l = @registers.d }
            when :e      then -> { @registers.l = @registers.e }
            when :h      then -> { @registers.l = @registers.h }
            when :l      then -> {}
            when :imm8   then -> { @registers.l = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.l = @cpu.bus_read(@registers.hl) }
            end
          end

          def load_into_mem_hl(source)
            case source
            when :a    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.a) }
            when :b    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.b) }
            when :c    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.c) }
            when :d    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.d) }
            when :e    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.e) }
            when :h    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.h) }
            when :l    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.l) }
            when :imm8 then -> { @cpu.bus_write(address: @registers.hl, value: @cpu.fetch_next_byte) }
            end
          end
        end
      end
    end
  end
end
