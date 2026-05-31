# frozen_string_literal: true

module Akane
  module GameBoy
    class Cpu
      module Instructions
        # Handles the logic related to all possible ADD 16-bit instructions.
        #
        # - ADD HL, BC
        # - ADD HL, DE
        # - ADD HL, HL
        # - ADD HL, SP
        # - ADD SP, sig8
        class Add16 < Base
          def initialize(cpu:, source:, target:)
            super(cpu:)

            @mnemonic = "ADD #{format_operand(source)}, #{format_operand(target)}"
            @logic    = build_logic(source, target)
          end

          private

          # Builds the logic for each ADD 16-bit instruction.
          # @return [Proc] A lambda object to be called by the CPU.
          def build_logic(source, target)
            return -> { add16_sig8 } if target == :sp

            case source
            when :bc     then -> { add16(@registers.bc) }
            when :de     then -> { add16(@registers.de) }
            when :hl     then -> { add16(@registers.hl) }
            when :sp     then -> { add16(@registers.sp) }
            else
              raise ArgumentError, 'Unknown Add16 source'
            end
          end

          # M-cycle 1: Fetches the instruction opcode.
          # M-cycle 2: 16-bit add operation + flag logic + set result.
          def add16(reg16_value)
            hl_value = @registers.hl
            result = @cpu.add16(@registers.hl, reg16_value)

            @registers.n_flag = false
            @registers.h_flag = (hl_value & 0x0FFF) + (reg16_value & 0x0FFF) > 0x0FFF
            @registers.c_flag = result > 0xFFFF

            @registers.hl = result
          end

          # M-cycle 1: Fetches the instruction opcode.
          # M-cycle 2: Fetches the next byte in the PC.
          # M-cycle 3: Signs the value + internal processing.
          # M-cycle 4: 16-bit Add operation + flag logic + set result.
          def add16_sig8
            sp = @registers.sp
            unsigned_byte = @cpu.fetch_next_byte
            offset = @cpu.sign_value(unsigned_byte)
            @cpu.internal_processing
            result = @cpu.add16(@registers.sp, offset)

            @registers.clear_flags
            @registers.h_flag = (sp & 0x0F) + (unsigned_byte & 0x0F) > 0x0F
            @registers.c_flag = (sp & 0xFF) + (unsigned_byte & 0xFF) > 0xFF

            @registers.sp = result
          end
        end
      end
    end
  end
end
