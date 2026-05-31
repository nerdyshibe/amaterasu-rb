# frozen_string_literal: true

describe Akane::GameBoy::Serial do
  subject(:serial) { described_class.new(interrupts) }

  let(:interrupts) { Akane::GameBoy::Interrupts.new(skip_boot_rom: false) }

  describe '#initialize' do
    it 'correctly sets the initial registers values', :aggregate_failures do
      expect(serial.sb).to eq(0x00)
      expect(serial.sc).to eq(0b01111110)
    end

    it 'sets an empty message buffer' do
      expect(serial.message_buffer).to eq([])
    end
  end

  describe '#sc' do
    it 'ignores writes on bits 6-1 and always reads 1' do
      serial.sc = 0b00000000

      expect(serial.sc).to eq(0b01111110)
    end
  end

  describe '#sb=' do
    it 'sets a 8-bit value into the SB register' do
      serial.sb = 0x99

      expect(serial.sb).to eq(0x99)
    end

    it 'wraps around any values higher than 0xFF' do
      serial.sb = 0xFF + 2

      expect(serial.sb).to eq(0x01)
    end
  end

  describe '#sc=' do
    context 'when transfer is enabled and internal clock selected' do
      before do
        serial.sb = 0x99
        serial.sc = 0b10000001
      end

      it 'transfers the byte in SB to the message buffer' do
        expect(serial.message_buffer).to eq([0x99])
      end

      it 'resets the value of SB to 0xFF' do
        expect(serial.sb).to eq(0xFF)
      end

      it 'requests a serial interrupt by setting Bit 3 of IF' do
        expect(interrupts.if_register).to eq(0b11101000)
      end
    end

    context 'when transfer is enabled and external clock selected' do
      before do
        serial.sb = 0x99
        serial.sc = 0b10000000
      end

      it 'does not transfer the byte in SB to the message buffer' do
        expect(serial.message_buffer).to eq([])
      end

      it 'does not reset the value of SB to 0xFF' do
        expect(serial.sb).to eq(0x99)
      end

      it 'does not request a serial interrupt' do
        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when transfer is disabled and internal clock selected' do
      before do
        serial.sb = 0x99
        serial.sc = 0b00000001
      end

      it 'does not start a transfer' do
        expect(serial.message_buffer).to eq([])
      end

      it 'does not reset the value of SB' do
        expect(serial.sb).to eq(0x99)
      end

      it 'does not request a serial interrupt' do
        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when transfer is disabled and external clock selected' do
      before do
        serial.sb = 0x99
        serial.sc = 0b00000000
      end

      it 'does not start a transfer' do
        expect(serial.message_buffer).to eq([])
      end

      it 'does not reset the value of SB' do
        expect(serial.sb).to eq(0x99)
      end

      it 'does not request a serial interrupt' do
        expect(interrupts.if_register).to eq(0b11100000)
      end
    end
  end
end
