# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      module Instructions
        # Holds the logic of all the load instructions.
        class Jp < Base
          def initialize(cpu:, location:, condition: nil)
            super(cpu:)

            @mnemonic = "JP #{format_operand(condition)}, #{format_operand(location)}"
            @logic    = build_logic(location, condition)
          end

          private

          def build_logic(location, condition)
            if condition.nil?
              case location
              when :imm16 then -> { @cpu.jump_to(address: @cpu.fetch_next_word) }
              when :hl then -> { @registers.pc = @registers.hl } # No extra cycle
              else
                raise ArgumentError, 'Unknown Jp location'
              end
            else
              case condition
              when :nz then -> { jp(condition: @registers.z_flag.zero?) }
              when :nc then -> { jp(condition: @registers.c_flag.zero?) }
              when :z  then -> { jp(condition: @registers.z_flag == 1) }
              when :c  then -> { jp(condition: @registers.c_flag == 1) }
              else
                raise ArgumentError, 'Unknown Jp condition'
              end
            end
          end

          # M-cycle 1: Fetches the opcode.
          # M-cycle 2: Fetches next immediate byte (lsb).
          # M-cycle 3: Fetches next immediate byte (msb).
          # ---------  Returns early if condition is not met.
          # M-cycle 4: Jumps to the address (takes 1 internal cycle).
          #
          def jp(condition:)
            address = @cpu.fetch_next_word
            return unless condition

            @cpu.jump_to(address:)
          end
        end
      end
    end
  end
end
