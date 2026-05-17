# frozen_string_literal: true

describe Akane::Gameboy::Ram do
  describe '#size' do
    it 'returns the memory size in bytes' do
      wram = described_class.new(size: 8192, offset: 0)

      expect(wram.size).to eq(8192)
    end
  end

  describe '#read_byte' do
    it 'reads a byte value in the data array', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x12)
      wram.write_byte(address: 8191, value: 0x34)

      expect(wram.read_byte(address: 0)).to eq(0x12)
      expect(wram.read_byte(address: 8191)).to eq(0x34)
    end
  end

  describe '#write_byte' do
    it 'writes a byte value into the data array' do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x99)

      expect(wram.read_byte(address: 0)).to eq(0x99)
    end

    it 'wraps any value around 0xFF before writing' do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0xFF + 1)

      expect(wram.read_byte(address: 0)).to eq(0x00)
    end
  end

  describe '#read_backup' do
    it 'returns a previously saved value from memory', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x12)
      wram.write_byte(address: 8191, value: 0x34)
      wram.save_data

      expect(wram.read_backup(address: 0)).to eq(0x12)
      expect(wram.read_backup(address: 8191)).to eq(0x34)
    end
  end

  describe '#disk_size' do
    it 'returns the size in B if the size is smaller than 1024' do
      wram = described_class.new(size: 127, offset: 0)

      expect(wram.disk_size).to eq('127 B')
    end

    it 'returns the size in KiB' do
      wram = described_class.new(size: 8192, offset: 0)

      expect(wram.disk_size).to eq('8 KiB')
    end
  end

  describe '#save_data' do
    it 'creates a backup of the current state of memory', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x12)
      wram.write_byte(address: 8191, value: 0x34)
      wram.save_data

      expect(wram.read_backup(address: 0)).to eq(0x12)
      expect(wram.read_backup(address: 8191)).to eq(0x34)
    end
  end

  describe '#restore_data' do
    it 'restore previously cleared data', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x12)
      wram.write_byte(address: 8191, value: 0x34)
      wram.save_data
      wram.wipe_data

      expect(wram.read_byte(address: 0)).to eq(0x00)
      expect(wram.read_byte(address: 8191)).to eq(0x00)

      wram.restore_data

      expect(wram.read_byte(address: 0)).to eq(0x12)
      expect(wram.read_byte(address: 8191)).to eq(0x34)
    end
  end

  describe '#wipe_data' do
    it 'clears all values already set', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x99)
      wram.write_byte(address: 1, value: 0x99)
      wram.wipe_data

      expect(wram.read_byte(address: 0)).to eq(0x00)
      expect(wram.read_byte(address: 1)).to eq(0x00)
    end
  end

  describe '#wipe_backup' do
    it 'wipes the current backup', :aggregate_failures do
      wram = described_class.new(size: 8192, offset: 0)
      wram.write_byte(address: 0, value: 0x12)
      wram.write_byte(address: 8191, value: 0x34)
      wram.save_data

      expect(wram.read_backup(address: 0)).to eq(0x12)
      expect(wram.read_backup(address: 8191)).to eq(0x34)

      wram.wipe_backup

      expect(wram.read_backup(address: 0)).to eq(0xFF)
      expect(wram.read_backup(address: 8191)).to eq(0xFF)
    end
  end
end
