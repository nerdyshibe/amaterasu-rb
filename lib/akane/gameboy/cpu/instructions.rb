# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/ModuleLength
module Akane
  module Gameboy
    class Cpu
      # Responsible to group all instruction types and load the CPU instructions array.
      module Instructions
        private

        def load_base_instructions
          instructions = Array.new(256)

          # Opcodes 0x00 - 0x0F
          instructions[0x00] = Nop.new(cpu: self)

          instructions[0x04] = Inc.new(cpu: self, operand: :b)
          instructions[0x05] = Dec.new(cpu: self, operand: :b)
          instructions[0x06] = Load8.new(cpu: self, target: :b, source: :imm8)

          instructions[0x0C] = Inc.new(cpu: self, operand: :c)
          instructions[0x0D] = Dec.new(cpu: self, operand: :c)
          instructions[0x0E] = Load8.new(cpu: self, target: :c, source: :imm8)

          # Opcodes 0x10 - 0x1F
          instructions[0x14] = Inc.new(cpu: self, operand: :d)
          instructions[0x15] = Dec.new(cpu: self, operand: :d)
          instructions[0x16] = Load8.new(cpu: self, target: :d, source: :imm8)

          instructions[0x18] = Jr.new(cpu: self)

          instructions[0x1C] = Inc.new(cpu: self, operand: :e)
          instructions[0x1D] = Dec.new(cpu: self, operand: :e)
          instructions[0x1E] = Load8.new(cpu: self, target: :e, source: :imm8)

          # Opcodes 0x20 - 0x2F
          instructions[0x20] = Jr.new(cpu: self, condition: :nz)
          instructions[0x21] = Load16.new(cpu: self, target: :hl, source: :imm16)
          instructions[0x22] = Load8.new(cpu: self, target: :mem_hli, source: :a)

          instructions[0x24] = Inc.new(cpu: self, operand: :h)
          instructions[0x25] = Dec.new(cpu: self, operand: :h)
          instructions[0x26] = Load8.new(cpu: self, target: :h, source: :imm8)

          instructions[0x28] = Jr.new(cpu: self, condition: :z)

          instructions[0x2A] = Load8.new(cpu: self, target: :a, source: :mem_hli)

          instructions[0x2C] = Inc.new(cpu: self, operand: :l)
          instructions[0x2D] = Dec.new(cpu: self, operand: :l)
          instructions[0x2E] = Load8.new(cpu: self, target: :l, source: :imm8)

          # Opcodes 0x30 - 0x3F
          instructions[0x30] = Jr.new(cpu: self, condition: :nc)
          instructions[0x32] = Load8.new(cpu: self, target: :mem_hld, source: :a)

          instructions[0x34] = Inc.new(cpu: self, operand: :mem_hl)
          instructions[0x35] = Dec.new(cpu: self, operand: :mem_hl)
          instructions[0x36] = Load8.new(cpu: self, target: :mem_hl, source: :imm8)

          instructions[0x38] = Jr.new(cpu: self, condition: :c)

          instructions[0x3A] = Load8.new(cpu: self, target: :a, source: :mem_hld)

          instructions[0x3C] = Inc.new(cpu: self, operand: :a)
          instructions[0x3D] = Dec.new(cpu: self, operand: :a)
          instructions[0x3E] = Load8.new(cpu: self, target: :a, source: :imm8)

          # Opcodes 0x40 - 0x4F
          instructions[0x40] = Load8.new(cpu: self, target: :b, source: :b)
          instructions[0x41] = Load8.new(cpu: self, target: :b, source: :c)
          instructions[0x42] = Load8.new(cpu: self, target: :b, source: :d)
          instructions[0x43] = Load8.new(cpu: self, target: :b, source: :e)
          instructions[0x44] = Load8.new(cpu: self, target: :b, source: :h)
          instructions[0x45] = Load8.new(cpu: self, target: :b, source: :l)
          instructions[0x46] = Load8.new(cpu: self, target: :b, source: :mem_hl)
          instructions[0x47] = Load8.new(cpu: self, target: :b, source: :a)
          instructions[0x48] = Load8.new(cpu: self, target: :c, source: :b)
          instructions[0x49] = Load8.new(cpu: self, target: :c, source: :c)
          instructions[0x4A] = Load8.new(cpu: self, target: :c, source: :d)
          instructions[0x4B] = Load8.new(cpu: self, target: :c, source: :e)
          instructions[0x4C] = Load8.new(cpu: self, target: :c, source: :h)
          instructions[0x4D] = Load8.new(cpu: self, target: :c, source: :l)
          instructions[0x4E] = Load8.new(cpu: self, target: :c, source: :mem_hl)
          instructions[0x4F] = Load8.new(cpu: self, target: :c, source: :a)

          # Opcodes 0x50 - 0x5F
          instructions[0x50] = Load8.new(cpu: self, target: :d, source: :b)
          instructions[0x51] = Load8.new(cpu: self, target: :d, source: :c)
          instructions[0x52] = Load8.new(cpu: self, target: :d, source: :d)
          instructions[0x53] = Load8.new(cpu: self, target: :d, source: :e)
          instructions[0x54] = Load8.new(cpu: self, target: :d, source: :h)
          instructions[0x55] = Load8.new(cpu: self, target: :d, source: :l)
          instructions[0x56] = Load8.new(cpu: self, target: :d, source: :mem_hl)
          instructions[0x57] = Load8.new(cpu: self, target: :d, source: :a)
          instructions[0x58] = Load8.new(cpu: self, target: :e, source: :b)
          instructions[0x59] = Load8.new(cpu: self, target: :e, source: :c)
          instructions[0x5A] = Load8.new(cpu: self, target: :e, source: :d)
          instructions[0x5B] = Load8.new(cpu: self, target: :e, source: :e)
          instructions[0x5C] = Load8.new(cpu: self, target: :e, source: :h)
          instructions[0x5D] = Load8.new(cpu: self, target: :e, source: :l)
          instructions[0x5E] = Load8.new(cpu: self, target: :e, source: :mem_hl)
          instructions[0x5F] = Load8.new(cpu: self, target: :e, source: :a)

          # Opcodes 0x60 - 0x6F
          instructions[0x60] = Load8.new(cpu: self, target: :h, source: :b)
          instructions[0x61] = Load8.new(cpu: self, target: :h, source: :c)
          instructions[0x62] = Load8.new(cpu: self, target: :h, source: :d)
          instructions[0x63] = Load8.new(cpu: self, target: :h, source: :e)
          instructions[0x64] = Load8.new(cpu: self, target: :h, source: :h)
          instructions[0x65] = Load8.new(cpu: self, target: :h, source: :l)
          instructions[0x66] = Load8.new(cpu: self, target: :h, source: :mem_hl)
          instructions[0x67] = Load8.new(cpu: self, target: :h, source: :a)
          instructions[0x68] = Load8.new(cpu: self, target: :l, source: :b)
          instructions[0x69] = Load8.new(cpu: self, target: :l, source: :c)
          instructions[0x6A] = Load8.new(cpu: self, target: :l, source: :d)
          instructions[0x6B] = Load8.new(cpu: self, target: :l, source: :e)
          instructions[0x6C] = Load8.new(cpu: self, target: :l, source: :h)
          instructions[0x6D] = Load8.new(cpu: self, target: :l, source: :l)
          instructions[0x6E] = Load8.new(cpu: self, target: :l, source: :mem_hl)
          instructions[0x6F] = Load8.new(cpu: self, target: :l, source: :a)

          # Opcodes 0x70 - 0x7F
          instructions[0x70] = Load8.new(cpu: self, target: :mem_hl, source: :b)
          instructions[0x71] = Load8.new(cpu: self, target: :mem_hl, source: :c)
          instructions[0x72] = Load8.new(cpu: self, target: :mem_hl, source: :d)
          instructions[0x73] = Load8.new(cpu: self, target: :mem_hl, source: :e)
          instructions[0x74] = Load8.new(cpu: self, target: :mem_hl, source: :h)
          instructions[0x75] = Load8.new(cpu: self, target: :mem_hl, source: :l)

          instructions[0x77] = Load8.new(cpu: self, target: :mem_hl, source: :a)
          instructions[0x78] = Load8.new(cpu: self, target: :a, source: :b)
          instructions[0x79] = Load8.new(cpu: self, target: :a, source: :c)
          instructions[0x7A] = Load8.new(cpu: self, target: :a, source: :d)
          instructions[0x7B] = Load8.new(cpu: self, target: :a, source: :e)
          instructions[0x7C] = Load8.new(cpu: self, target: :a, source: :h)
          instructions[0x7D] = Load8.new(cpu: self, target: :a, source: :l)
          instructions[0x7E] = Load8.new(cpu: self, target: :a, source: :mem_hl)
          instructions[0x7F] = Load8.new(cpu: self, target: :a, source: :a)

          # Opcodes 0x80 - 0x8F
          instructions[0x80] = Add8.new(cpu: self, source: :b)
          instructions[0x81] = Add8.new(cpu: self, source: :c)
          instructions[0x82] = Add8.new(cpu: self, source: :d)
          instructions[0x83] = Add8.new(cpu: self, source: :e)
          instructions[0x84] = Add8.new(cpu: self, source: :h)
          instructions[0x85] = Add8.new(cpu: self, source: :l)
          instructions[0x86] = Add8.new(cpu: self, source: :mem_hl)
          instructions[0x87] = Add8.new(cpu: self, source: :a)
          instructions[0x88] = Adc.new(cpu: self, source: :b)
          instructions[0x89] = Adc.new(cpu: self, source: :c)
          instructions[0x8A] = Adc.new(cpu: self, source: :d)
          instructions[0x8B] = Adc.new(cpu: self, source: :e)
          instructions[0x8C] = Adc.new(cpu: self, source: :h)
          instructions[0x8D] = Adc.new(cpu: self, source: :l)
          instructions[0x8E] = Adc.new(cpu: self, source: :mem_hl)
          instructions[0x8F] = Adc.new(cpu: self, source: :a)

          # Opcodes 0x90 - 0x9F
          instructions[0x90] = Sub.new(cpu: self, source: :b)
          instructions[0x91] = Sub.new(cpu: self, source: :c)
          instructions[0x92] = Sub.new(cpu: self, source: :d)
          instructions[0x93] = Sub.new(cpu: self, source: :e)
          instructions[0x94] = Sub.new(cpu: self, source: :h)
          instructions[0x95] = Sub.new(cpu: self, source: :l)
          instructions[0x96] = Sub.new(cpu: self, source: :mem_hl)
          instructions[0x97] = Sub.new(cpu: self, source: :a)

          # Opcodes 0xA0 - 0xAF
          instructions[0xA0] = And.new(cpu: self, source: :b)
          instructions[0xA1] = And.new(cpu: self, source: :c)
          instructions[0xA2] = And.new(cpu: self, source: :d)
          instructions[0xA3] = And.new(cpu: self, source: :e)
          instructions[0xA4] = And.new(cpu: self, source: :h)
          instructions[0xA5] = And.new(cpu: self, source: :l)
          instructions[0xA6] = And.new(cpu: self, source: :mem_hl)
          instructions[0xA7] = And.new(cpu: self, source: :a)
          instructions[0xA8] = Xor.new(cpu: self, source: :b)
          instructions[0xA9] = Xor.new(cpu: self, source: :c)
          instructions[0xAA] = Xor.new(cpu: self, source: :d)
          instructions[0xAB] = Xor.new(cpu: self, source: :e)
          instructions[0xAC] = Xor.new(cpu: self, source: :h)
          instructions[0xAD] = Xor.new(cpu: self, source: :l)
          instructions[0xAE] = Xor.new(cpu: self, source: :mem_hl)
          instructions[0xAF] = Xor.new(cpu: self, source: :a)

          # Opcodes 0xB0 - 0xBF
          instructions[0xB0] = Or.new(cpu: self, source: :b)
          instructions[0xB1] = Or.new(cpu: self, source: :c)
          instructions[0xB2] = Or.new(cpu: self, source: :d)
          instructions[0xB3] = Or.new(cpu: self, source: :e)
          instructions[0xB4] = Or.new(cpu: self, source: :h)
          instructions[0xB5] = Or.new(cpu: self, source: :l)
          instructions[0xB6] = Or.new(cpu: self, source: :mem_hl)
          instructions[0xB7] = Or.new(cpu: self, source: :a)
          instructions[0xB8] = Cp.new(cpu: self, source: :b)
          instructions[0xB9] = Cp.new(cpu: self, source: :c)
          instructions[0xBA] = Cp.new(cpu: self, source: :d)
          instructions[0xBB] = Cp.new(cpu: self, source: :e)
          instructions[0xBC] = Cp.new(cpu: self, source: :h)
          instructions[0xBD] = Cp.new(cpu: self, source: :l)
          instructions[0xBE] = Cp.new(cpu: self, source: :mem_hl)
          instructions[0xBF] = Cp.new(cpu: self, source: :a)

          # Opcodes 0xC0 - 0xCF
          instructions[0xC0] = Ret.new(cpu: self, condition: :nz)
          instructions[0xC1] = Pop.new(cpu: self, reg16: :bc)

          instructions[0xC3] = Jump.new(cpu: self, location: :imm16)
          instructions[0xC4] = Call.new(cpu: self, condition: :nz)
          instructions[0xC5] = Push.new(cpu: self, reg16: :bc)
          instructions[0xC6] = Add8.new(cpu: self, source: :imm8)
          instructions[0xC7] = Rst.new(cpu: self, vector: 0x00)
          instructions[0xC8] = Ret.new(cpu: self, condition: :z)
          instructions[0xC9] = Ret.new(cpu: self)

          instructions[0xCC] = Call.new(cpu: self, condition: :z)
          instructions[0xCD] = Call.new(cpu: self)
          instructions[0xCE] = Adc.new(cpu: self, source: :imm8)
          instructions[0xCF] = Rst.new(cpu: self, vector: 0x08)

          # Opcodes 0xD0 - 0xDF
          instructions[0xD0] = Ret.new(cpu: self, condition: :nc)
          instructions[0xD1] = Pop.new(cpu: self, reg16: :de)

          instructions[0xD3] = nil # not implemented in the Game Boy
          instructions[0xD4] = Call.new(cpu: self, condition: :nc)
          instructions[0xD5] = Push.new(cpu: self, reg16: :de)
          instructions[0xD6] = Sub.new(cpu: self, source: :imm8)
          instructions[0xD7] = Rst.new(cpu: self, vector: 0x10)
          instructions[0xD8] = Ret.new(cpu: self, condition: :c)
          instructions[0xD9] = Ret.new(cpu: self, enable_ime: true)

          instructions[0xDB] = nil # not implemented in the Game Boy
          instructions[0xDC] = Call.new(cpu: self, condition: :c)
          instructions[0xDD] = nil # not implemented in the Game Boy

          instructions[0xDF] = Rst.new(cpu: self, vector: 0x18)

          # Opcodes 0xE0 - 0xEF
          instructions[0xE0] = Ldh.new(cpu: self, target: :mem_unsig8, source: :a)
          instructions[0xE1] = Pop.new(cpu: self, reg16: :hl)
          instructions[0xE2] = Ldh.new(cpu: self, target: :mem_c, source: :a)
          instructions[0xE3] = nil # not implemented in the Game Boy
          instructions[0xE4] = nil # not implemented in the Game Boy
          instructions[0xE5] = Push.new(cpu: self, reg16: :hl)
          instructions[0xE6] = And.new(cpu: self, source: :imm8)
          instructions[0xE7] = Rst.new(cpu: self, vector: 0x20)

          instructions[0xEB] = nil # not implemented in the Game Boy
          instructions[0xEC] = nil # not implemented in the Game Boy
          instructions[0xED] = nil # not implemented in the Game Boy
          instructions[0xEE] = Xor.new(cpu: self, source: :imm8)
          instructions[0xEF] = Rst.new(cpu: self, vector: 0x28)

          # Opcodes 0xF0 - 0xFF
          instructions[0xF0] = Ldh.new(cpu: self, target: :a, source: :mem_unsig8)
          instructions[0xF1] = Pop.new(cpu: self, reg16: :af)
          instructions[0xF2] = Ldh.new(cpu: self, target: :a, source: :mem_c)
          instructions[0xF3] = Di.new(cpu: self)
          instructions[0xF4] = nil # not implemented in the Game Boy
          instructions[0xF5] = Push.new(cpu: self, reg16: :af)
          instructions[0xF6] = Or.new(cpu: self, source: :imm8)
          instructions[0xF7] = Rst.new(cpu: self, vector: 0x30)

          instructions[0xFB] = Ei.new(cpu: self)
          instructions[0xFC] = nil # not implemented in the Game Boy
          instructions[0xFD] = nil # not implemented in the Game Boy
          instructions[0xFE] = Cp.new(cpu: self, source: :imm8)
          instructions[0xFF] = Rst.new(cpu: self, vector: 0x38)

          instructions.freeze
        end

        def load_cb_instructions
          cb_instructions = Array.new(256)
          cb_instructions.freeze
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ModuleLength
