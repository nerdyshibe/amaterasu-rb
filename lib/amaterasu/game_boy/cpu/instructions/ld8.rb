# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the 8-bit Load instructions.
        class Ld8 < Base
          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LD #{format_operand(target)}, #{format_operand(source)}"
            @logic    = build_logic(target, source)
          end

          private

          def build_logic(target, source)
            return -> { ld_a_mem_imm16 } if source == :mem_imm16
            return -> { ld_a_mem_bc } if source == :mem_bc
            return -> { ld_a_mem_de } if source == :mem_de

            case target
            when :a       then load_a(source)
            when :b       then load_b(source)
            when :c       then load_c(source)
            when :d       then load_d(source)
            when :e       then load_e(source)
            when :h       then load_h(source)
            when :l       then load_l(source)
            when :mem_hl  then load_mem_hl(source)
            when :mem_hli then -> { load_mem_hli }
            when :mem_hld then -> { load_mem_hld }
            when :mem_bc  then -> { @cpu.bus_write(address: @registers.bc, value: @registers.a) }
            when :mem_de  then -> { @cpu.bus_write(address: @registers.de, value: @registers.a) }
            when :mem_imm16 then -> { ld_mem_imm16_a }
            else
              raise ArgumentError, 'Unknown target for :build_logic in Ld8'
            end
          end

          def load_a(source)
            case source
            when :a      then -> {}
            when :b      then -> { @registers.a = @registers.b }
            when :c      then -> { @registers.a = @registers.c }
            when :d      then -> { @registers.a = @registers.d }
            when :e      then -> { @registers.a = @registers.e }
            when :h      then -> { @registers.a = @registers.h }
            when :l      then -> { @registers.a = @registers.l }
            when :imm8   then -> { @registers.a = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.a = @cpu.bus_read(address: @registers.hl) }
            when :mem_hli
              lambda do
                @registers.a = @cpu.bus_read(address: @registers.hl)
                @registers.hl += 1
              end
            when :mem_hld
              lambda do
                @registers.a = @cpu.bus_read(address: @registers.hl)
                @registers.hl -= 1
              end
            else
              raise ArgumentError, 'Unknown source for :load_a in Ld8'
            end
          end

          def load_b(source)
            case source
            when :a      then -> { @registers.b = @registers.a }
            when :b      then -> {}
            when :c      then -> { @registers.b = @registers.c }
            when :d      then -> { @registers.b = @registers.d }
            when :e      then -> { @registers.b = @registers.e }
            when :h      then -> { @registers.b = @registers.h }
            when :l      then -> { @registers.b = @registers.l }
            when :imm8   then -> { @registers.b = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.b = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_b in Ld8'
            end
          end

          def load_c(source)
            case source
            when :a      then -> { @registers.c = @registers.a }
            when :b      then -> { @registers.c = @registers.b }
            when :c      then -> {}
            when :d      then -> { @registers.c = @registers.d }
            when :e      then -> { @registers.c = @registers.e }
            when :h      then -> { @registers.c = @registers.h }
            when :l      then -> { @registers.c = @registers.l }
            when :imm8   then -> { @registers.c = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.c = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_c in Ld8'
            end
          end

          def load_d(source)
            case source
            when :a      then -> { @registers.d = @registers.a }
            when :b      then -> { @registers.d = @registers.b }
            when :c      then -> { @registers.d = @registers.c }
            when :d      then -> {}
            when :e      then -> { @registers.d = @registers.e }
            when :h      then -> { @registers.d = @registers.h }
            when :l      then -> { @registers.d = @registers.l }
            when :imm8   then -> { @registers.d = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.d = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_d in Ld8'
            end
          end

          def load_e(source)
            case source
            when :a      then -> { @registers.e = @registers.a }
            when :b      then -> { @registers.e = @registers.b }
            when :c      then -> { @registers.e = @registers.c }
            when :d      then -> { @registers.e = @registers.d }
            when :e      then -> {}
            when :h      then -> { @registers.e = @registers.h }
            when :l      then -> { @registers.e = @registers.l }
            when :imm8   then -> { @registers.e = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.e = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_e in Ld8'
            end
          end

          def load_h(source)
            case source
            when :a      then -> { @registers.h = @registers.a }
            when :b      then -> { @registers.h = @registers.b }
            when :c      then -> { @registers.h = @registers.c }
            when :d      then -> { @registers.h = @registers.d }
            when :e      then -> { @registers.h = @registers.e }
            when :h      then -> {}
            when :l      then -> { @registers.h = @registers.l }
            when :imm8   then -> { @registers.h = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.h = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_h in Ld8'
            end
          end

          def load_l(source)
            case source
            when :a      then -> { @registers.l = @registers.a }
            when :b      then -> { @registers.l = @registers.b }
            when :c      then -> { @registers.l = @registers.c }
            when :d      then -> { @registers.l = @registers.d }
            when :e      then -> { @registers.l = @registers.e }
            when :h      then -> { @registers.l = @registers.h }
            when :l      then -> {}
            when :imm8   then -> { @registers.l = @cpu.fetch_next_byte }
            when :mem_hl then -> { @registers.l = @cpu.bus_read(address: @registers.hl) }
            else
              raise ArgumentError, 'Unknown source for :load_l in Ld8'
            end
          end

          def load_mem_hl(source)
            case source
            when :a    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.a) }
            when :b    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.b) }
            when :c    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.c) }
            when :d    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.d) }
            when :e    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.e) }
            when :h    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.h) }
            when :l    then -> { @cpu.bus_write(address: @registers.hl, value: @registers.l) }
            when :imm8 then -> { @cpu.bus_write(address: @registers.hl, value: @cpu.fetch_next_byte) }
            else
              raise ArgumentError, 'Unknown source for :load_mem_hl in Ld8'
            end
          end

          def load_mem_hli
            @cpu.bus_write(address: @registers.hl, value: @registers.a)
            @registers.hl += 1
          end

          def load_mem_hld
            @cpu.bus_write(address: @registers.hl, value: @registers.a)
            @registers.hl -= 1
          end

          def ld_mem_imm16_a
            imm16_address = @cpu.fetch_next_word
            @cpu.bus_write(address: imm16_address, value: @registers.a)
          end

          def ld_a_mem_imm16
            imm16_address = @cpu.fetch_next_word
            @registers.a = @cpu.bus_read(address: imm16_address)
          end

          def ld_a_mem_bc
            @registers.a = @cpu.bus_read(address: @registers.bc)
          end

          def ld_a_mem_de
            @registers.a = @cpu.bus_read(address: @registers.de)
          end
        end
      end
    end
  end
end
