# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the LDH (Load High RAM) instructions.
        class Ldh < Base
          IO_BASE_ADDRESS = 0xFF00

          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LDH #{format_operand(target)}, #{format_operand(source)}"
            @bytes    = 2
            @m_cycles = 2
            @logic    = build_logic(target, source)
          end

          private

          def build_logic(target, source)
            case target
            when :a
              case source
              when :mem_unsig8 then -> { ldh_a_mem_unsig8 }
              when :mem_c then -> { ldh_a_mem_c }
              end
            when :mem_unsig8 then -> { ldh_mem_unsig8_a }
            when :mem_c then -> { ldh_mem_c_a }
            end
          end

          def ldh_mem_unsig8_a
            unsigned_byte = @cpu.fetch_next_byte

            @cpu.bus_write(address: IO_BASE_ADDRESS + unsigned_byte, value: @registers.a)
          end

          def ldh_a_mem_unsig8
            unsigned_byte = @cpu.fetch_next_byte

            @registers.a = @cpu.bus_read(address: IO_BASE_ADDRESS + unsigned_byte)
          end

          def ldh_mem_c_a
            @cpu.bus_write(address: IO_BASE_ADDRESS + @registers.c, value: @registers.a)
          end

          def ldh_a_mem_c
            @registers.a = @cpu.bus_read(address: IO_BASE_ADDRESS + @registers.c)
          end
        end
      end
    end
  end
end
