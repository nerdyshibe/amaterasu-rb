# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        # Holds the logic of all the 16-bit Load instructions.
        class Ld16 < Base
          def initialize(cpu:, target:, source:)
            super(cpu:)

            @mnemonic = "LD #{format_operand(target)}, #{format_operand(source)}"
            @logic    = build_logic(target, source)
          end

          private

          def build_logic(target, source)
            return -> { ld_mem_imm16_sp } if target == :mem_imm16

            case target
            when :bc then -> { @registers.bc = @cpu.fetch_next_word }
            when :de then -> { @registers.de = @cpu.fetch_next_word }
            when :hl
              case source
              when :imm16 then -> { @registers.hl = @cpu.fetch_next_word }
              when :sp_plus_sig8
                lambda do
                  unsigned_byte = @cpu.fetch_next_byte
                  signed_value = @cpu.sign_value(unsigned_byte)
                  sp = @registers.sp
                  result = @cpu.add16(@registers.sp, signed_value)

                  @registers.clear_flags
                  @registers.h_flag = (sp & 0x0F) + (unsigned_byte & 0x0F) > 0x0F
                  @registers.c_flag = (sp & 0xFF) + (unsigned_byte & 0xFF) > 0xFF

                  @registers.hl = result
                end
              end
            when :sp
              case source
              when :imm16 then -> { @registers.sp = @cpu.fetch_next_word }
              when :hl
                lambda do
                  @cpu.internal_processing
                  @registers.sp = @registers.hl
                end
              end
            end
          end

          # Loads the LSB from SP to the imm16 address.
          # Loads the MSB from SP to the imm16 address + 1.
          #
          # M-cycle 1: Fetches the opcode.
          # M-cycle 2: Fetches the LSB of the address to be used.
          # M-cycle 3: Fetches the MSB of the address to be used.
          # M-cycle 4: Writes the LSB of SP into the address.
          # M-cycle 5: Writes the MSB of SP into the address + 1.
          #
          def ld_mem_imm16_sp
            imm16 = @cpu.fetch_next_word
            sp = @registers.sp

            @cpu.bus_write(address: imm16, value: sp & 0xFF)
            @cpu.bus_write(address: imm16 + 1, value: (sp >> 8) & 0xFF)
          end
        end
      end
    end
  end
end
