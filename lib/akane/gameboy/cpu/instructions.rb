# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
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

          instructions[0x06] = Load8.new(cpu: self, target: :b, source: :imm8)

          instructions[0x0E] = Load8.new(cpu: self, target: :c, source: :imm8)

          # Opcodes 0x10 - 0x1F
          instructions[0x16] = Load8.new(cpu: self, target: :d, source: :imm8)

          instructions[0x1E] = Load8.new(cpu: self, target: :e, source: :imm8)

          # Opcodes 0x20 - 0x2F
          instructions[0x21] = Load16.new(cpu: self, target: :hl, source: :imm16)

          instructions[0x26] = Load8.new(cpu: self, target: :h, source: :imm8)

          instructions[0x2E] = Load8.new(cpu: self, target: :l, source: :imm8)

          # Opcodes 0x30 - 0x3F
          instructions[0x36] = Load8.new(cpu: self, target: :mem_hl, source: :imm8)

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

          # Opcodes 0x90 - 0x9F

          # Opcodes 0xA0 - 0xAF

          instructions[0xA8] = Xor.new(cpu: self, source: :b)
          instructions[0xA9] = Xor.new(cpu: self, source: :c)
          instructions[0xAA] = Xor.new(cpu: self, source: :d)
          instructions[0xAB] = Xor.new(cpu: self, source: :e)
          instructions[0xAC] = Xor.new(cpu: self, source: :h)
          instructions[0xAD] = Xor.new(cpu: self, source: :l)
          instructions[0xAE] = Xor.new(cpu: self, source: :mem_hl)
          instructions[0xAF] = Xor.new(cpu: self, source: :a)

          # Opcodes 0xB0 - 0xBF

          # Opcodes 0xC0 - 0xCF
          instructions[0xC3] = Jump.new(cpu: self, location: :imm16)

          # Opcodes 0xD0 - 0xDF

          # Opcodes 0xE0 - 0xEF
          instructions[0xEE] = Xor.new(cpu: self, source: :imm8)

          # Opcodes 0xF0 - 0xFF

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
# rubocop:enable Metrics/MethodLength
