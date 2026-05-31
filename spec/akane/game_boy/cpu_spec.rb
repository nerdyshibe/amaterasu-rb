# frozen_string_literal: true

describe Akane::GameBoy::Cpu do
  include CpuHelper

  subject(:cpu) { build_cpu(rom_data) }

  let(:rom_data) { Array.new(0x8000, 0x00) }
  let(:registers) { cpu.registers }

  describe '#initialize' do
    it 'initializes the cpu' do
      expect(cpu).not_to be_nil
    end
  end
end
