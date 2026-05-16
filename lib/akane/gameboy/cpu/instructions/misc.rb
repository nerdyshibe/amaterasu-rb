# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic for CPL, SCF and CCF instructions.
        class Misc < Base
          def initialize(cpu:, operation:)
            super(cpu:)

            @mnemonic = format_operand(operation)
            @logic    = build_logic(operation)
          end

          private

          def build_logic(operation)
            case operation
            when :cpl then -> { cpl }
            when :scf then -> { scf }
            when :ccf then -> { ccf }
            end
          end

          # Set Carry flag.
          def scf
            @registers.n_flag = false
            @registers.h_flag = false
            @registers.c_flag = true
          end

          # Complement the Carry flag.
          def ccf
            @registers.n_flag = false
            @registers.h_flag = false
            @registers.c_flag = @registers.c_flag.zero?
          end

          # Complement the value from the A register.
          def cpl
            @registers.a = ~@registers.a

            @registers.n_flag = true
            @registers.h_flag = true
          end
        end
      end
    end
  end
end
