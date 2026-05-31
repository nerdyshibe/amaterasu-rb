# frozen_string_literal: true

describe Akane::GameBoy::Cpu::Instructions::Sub do
  include CpuHelper

  let(:rom_data) { Array.new(0x8000, 0x00) }
  let(:cpu) { build_cpu(rom_data) }
  let(:registers) { cpu.registers }

  describe '#initialize' do
    context 'when initializing SUB A, B (0x90)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :b) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, B')
      end
    end

    context 'when initializing SUB A, C (0x91)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :c) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, C')
      end
    end

    context 'when initializing SUB A, D (0x92)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :d) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, D')
      end
    end

    context 'when initializing SUB A, E (0x93)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :e) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, E')
      end
    end

    context 'when initializing SUB A, H (0x94)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :h) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, H')
      end
    end

    context 'when initializing SUB A, L (0x95)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :l) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, L')
      end
    end

    context 'when initializing SUB A, [HL] (0x96)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :mem_hl) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, [HL]')
      end
    end

    context 'when initializing SUB A, A (0x97)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :a) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, A')
      end
    end

    context 'when initializing SUB A, n8 (0xD6)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :imm8) }

      it 'defines the mnemonic correctly' do
        expect(instruction.mnemonic).to eq('SUB A, n8')
      end
    end
  end

  describe '#execute' do
    context 'when executing SUB A, B (0x90)' do
      subject(:instruction) { described_class.new(cpu: cpu, source: :b) }

      it 'subtracts the B value from A' do
        registers.a = 0x09
        registers.b = 0x01

        expect { instruction.execute }
          .to change(registers, :a).from(0x09).to(0x08)
      end

      it 'sets the zero flag if the result is zero' do
        registers.a = 0x09
        registers.b = 0x09
        registers.f = 0x00

        expect { instruction.execute }
          .to change(registers, :z_flag).from(0).to(1)
      end

      it 'clears the zero flag if the result is not zero' do
        registers.a = 0x09
        registers.b = 0x07
        registers.f = 0xFF

        expect { instruction.execute }
          .to change(registers, :z_flag).from(1).to(0)
      end

      it 'sets the subtraction flag' do
        registers.f = 0x00

        expect { instruction.execute }
          .to change(registers, :n_flag).from(0).to(1)
      end

      it 'sets the half carry flag if borrowed from bit 4' do
        registers.a = 0x0A
        registers.b = 0x0B
        registers.f = 0x00

        expect { instruction.execute }
          .to change(registers, :h_flag).from(0).to(1)
      end

      it 'clears the half carry flag if not borrowed from bit 4' do
        registers.a = 0x0F
        registers.b = 0x01
        registers.f = 0xFF

        expect { instruction.execute }
          .to change(registers, :h_flag).from(1).to(0)
      end

      it 'sets the carry flag if borrowed' do
        registers.a = 0xA0
        registers.b = 0xB0
        registers.f = 0x00

        expect { instruction.execute }
          .to change(registers, :c_flag).from(0).to(1)
      end

      it 'clears the carry flag if not borrowed' do
        registers.a = 0xB0
        registers.b = 0xA0
        registers.f = 0xFF

        expect { instruction.execute }
          .to change(registers, :c_flag).from(1).to(0)
      end
    end
  end
end
