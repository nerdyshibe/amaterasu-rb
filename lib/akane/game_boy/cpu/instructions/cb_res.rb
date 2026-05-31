# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the RES instructions.
        class CbRes < Base
          include Utils::BitOps

          # Creates a new CbRes object containing the mnemonic (String) and logic (Proc).
          def initialize(cpu:, bit_pos:, target:)
            super(cpu:)

            @mnemonic = "RES #{bit_pos}, #{format_operand(target)}"
            @logic    = build_logic(bit_pos, target)
          end

          private

          # @param bit_pos [Integer] Integer between 0 and 7.
          # @param target [Symbol] Either a 8-bit register (:a, :b, :c, ...) or :mem_hl.
          #
          # @return [Proc] Logic to be executed by the Cpu.
          #
          def build_logic(bit_pos, target)
            case target
            when :a      then -> { @registers.a = clear_bit(@registers.a, bit_pos) }
            when :b      then -> { @registers.b = clear_bit(@registers.b, bit_pos) }
            when :c      then -> { @registers.c = clear_bit(@registers.c, bit_pos) }
            when :d      then -> { @registers.d = clear_bit(@registers.d, bit_pos) }
            when :e      then -> { @registers.e = clear_bit(@registers.e, bit_pos) }
            when :h      then -> { @registers.h = clear_bit(@registers.h, bit_pos) }
            when :l      then -> { @registers.l = clear_bit(@registers.l, bit_pos) }
            when :mem_hl
              lambda do
                value_at_mem_hl = @cpu.bus_read(address: @registers.hl)
                result = clear_bit(value_at_mem_hl, bit_pos)
                @cpu.bus_write(address: @registers.hl, value: result)
              end
            else
              raise ArgumentError, 'Unknown CbRes target'
            end
          end
        end
      end
    end
  end
end
