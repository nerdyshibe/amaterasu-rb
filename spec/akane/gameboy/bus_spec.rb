# frozen_string_literal: true

describe Akane::Gameboy::Bus do
  subject(:bus) do
    described_class.new(
      cartridge: cartridge,
      ppu: ppu,
      wram: wram,
      hram: hram,
      interrupts: interrupts,
      timer: timer,
      serial: serial,
      joypad: joypad
    )
  end

  let(:rom_data) do
    data = Array.new(0x8000, 0x00)
    data[0x0000] = 0x12
    data[0x7FFF] = 0x34
    data
  end
  let(:cartridge) { Akane::Cartridge.new(rom: Akane::Cartridge::Rom.new(rom_data)) }
  let(:ppu) { Akane::Gameboy::Ppu.new }
  let(:wram) { Akane::Gameboy::Ram.new(8_192) }
  let(:hram) { Akane::Gameboy::Ram.new(127) }
  let(:interrupts) { Akane::Gameboy::Interrupts.new(skip_boot_rom: false) }
  let(:timer) { Akane::Gameboy::Timer.new(interrupts) }
  let(:serial) { Akane::Gameboy::Serial.new(interrupts) }
  let(:joypad) { Akane::Gameboy::Joypad.new(interrupts) }

  describe '#read_byte' do
    context 'when in the 0x0000 - 0x7FFF (Cartridge ROM) range' do
      before do
        allow(cartridge).to receive(:read_rom).and_call_original
      end

      it 'delegates the read to the cartridge for address 0x0000', :aggregate_failures do
        byte = bus.read_byte(0x0000)

        expect(cartridge).to have_received(:read_rom).with(0x0000)
        expect(byte).to eq(0x12)
      end

      it 'delegates the read to the cartridge for address 0x7FFF', :aggregate_failures do
        byte = bus.read_byte(0x7FFF)

        expect(cartridge).to have_received(:read_rom).with(0x7FFF)
        expect(byte).to eq(0x34)
      end
    end

    context 'when in the 0x8000 - 0x9FFF (PPU VRAM) range' do
      let(:offset) { 0x8000 }

      before do
        allow(ppu).to receive(:read_vram).and_call_original
      end

      it 'delegates the read to the ppu for address 0x8000', :aggregate_failures do
        bus.write_byte(0x8000, 0xAB)
        byte = bus.read_byte(0x8000)

        expect(ppu).to have_received(:read_vram).with(0x8000 - offset)
        expect(byte).to eq(0xAB)
      end

      it 'delegates the read to the ppu for address 0x9FFF', :aggregate_failures do
        bus.write_byte(0x9FFF, 0xCD)
        byte = bus.read_byte(0x9FFF)

        expect(ppu).to have_received(:read_vram).with(0x9FFF - offset)
        expect(byte).to eq(0xCD)
      end
    end

    context 'when in the 0xA000 - 0xBFFF (Cartridge RAM) range' do
      let(:offset) { 0xA000 }

      before do
        allow(cartridge).to receive(:read_ram).and_call_original
      end

      it 'delegates the read to the cartridge for address 0xA000', :aggregate_failures do
        bus.write_byte(0xA000, 0x88)
        byte = bus.read_byte(0xA000)

        expect(cartridge).to have_received(:read_ram).with(0xA000 - offset)
        expect(byte).to eq(0xFF)
      end

      it 'delegates the read to the cartridge for address 0xBFFF', :aggregate_failures do
        bus.write_byte(0xBFFF, 0x99)
        byte = bus.read_byte(0xBFFF)

        expect(cartridge).to have_received(:read_ram).with(0xBFFF - offset)
        expect(byte).to eq(0xFF)
      end
    end

    context 'when in the 0xC000 - 0xDFFF (WRAM) range' do
      let(:offset) { 0xC000 }

      before do
        allow(wram).to receive(:read_byte).and_call_original
      end

      it 'delegates the read to the wram for address 0xC000', :aggregate_failures do
        bus.write_byte(0xC000, 0x66)
        byte = bus.read_byte(0xC000)

        expect(wram).to have_received(:read_byte).with(0xC000 - offset)
        expect(byte).to eq(0x66)
      end

      it 'delegates the read to the wram for address 0xDFFF', :aggregate_failures do
        bus.write_byte(0xDFFF, 0x77)
        byte = bus.read_byte(0xDFFF)

        expect(wram).to have_received(:read_byte).with(0xDFFF - offset)
        expect(byte).to eq(0x77)
      end
    end

    context 'when in the 0xE000 - 0xFDFF (Echo RAM) range' do
      let(:offset) { 0xE000 }

      before do
        allow(wram).to receive(:read_byte).and_call_original
      end

      it 'mirrors WRAM - writing in WRAM and reading in Echo on 0xE000', :aggregate_failures do
        bus.write_byte(0xC000, 0x44)
        byte = bus.read_byte(0xE000)

        expect(wram).to have_received(:read_byte).with(0xE000 - offset)
        expect(byte).to eq(0x44)
      end

      it 'mirrors WRAM - writing in WRAM and reading in Echo on 0xFDFF', :aggregate_failures do
        bus.write_byte(0xDDFF, 0x55)
        byte = bus.read_byte(0xFDFF)

        expect(wram).to have_received(:read_byte).with(0xFDFF - offset)
        expect(byte).to eq(0x55)
      end
    end

    context 'when in the 0xFE00 - 0xFE9F (PPU OAM) range' do
      let(:offset) { 0xFE00 }

      before do
        allow(ppu).to receive(:read_oam).and_call_original
      end

      it 'delegates the read to the ppu for address 0xFE00', :aggregate_failures do
        bus.write_byte(0xFE00, 0x22)
        byte = bus.read_byte(0xFE00)

        expect(ppu).to have_received(:read_oam).with(0xFE00 - offset)
        expect(byte).to eq(0x22)
      end

      it 'delegates the read to the ppu for address 0xFE9F', :aggregate_failures do
        bus.write_byte(0xFE9F, 0x33)
        byte = bus.read_byte(0xFE9F)

        expect(ppu).to have_received(:read_oam).with(0xFE9F - offset)
        expect(byte).to eq(0x33)
      end
    end

    context 'when in the 0xFEA0 - 0xFEFF (Unusable) range' do
      it 'returns 0xFF for address 0xFEA0' do
        expect(bus.read_byte(0xFEA0)).to eq(0xFF)
      end

      it 'returns 0xFF for address 0xFEFF' do
        expect(bus.read_byte(0xFEFF)).to eq(0xFF)
      end
    end

    context 'when in the 0xFF00 - 0xFF7F (IO Registers) range' do
    end

    context 'when in the 0xFF80 - 0xFFFE (HRAM) range' do
    end

    context 'when reading 0xFFFF address' do
    end
  end
end
