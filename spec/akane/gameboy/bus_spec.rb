# frozen_string_literal: true

describe Akane::Gameboy::Bus do
  subject(:bus) do
    described_class.new(
      cartridge: cartridge,
      ppu: ppu,
      apu: apu,
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
  let(:ppu) { Akane::Gameboy::Ppu.new(interrupts) }
  let(:apu) { Akane::Gameboy::Apu.new }
  let(:wram) { Akane::Gameboy::Ram.new(size: 8192, offset: 0x8000) }
  let(:hram) { Akane::Gameboy::Ram.new(size: 127, offset: 0xFF80) }
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
        byte = bus.read_byte(address: 0x0000)

        expect(cartridge).to have_received(:read_rom).with(0x0000)
        expect(byte).to eq(0x12)
      end

      it 'delegates the read to the cartridge for address 0x7FFF', :aggregate_failures do
        byte = bus.read_byte(address: 0x7FFF)

        expect(cartridge).to have_received(:read_rom).with(0x7FFF)
        expect(byte).to eq(0x34)
      end
    end

    context 'when in the 0x8000 - 0x9FFF (PPU VRAM) range' do
      before do
        allow(ppu).to receive(:read_vram).and_call_original
      end

      it 'delegates the read to the ppu for address 0x8000', :aggregate_failures do
        bus.write_byte(address: 0x8000, value: 0xAB)
        byte = bus.read_byte(address: 0x8000)

        expect(ppu).to have_received(:read_vram).with(0x8000)
        expect(byte).to eq(0xAB)
      end

      it 'delegates the read to the ppu for address 0x9FFF', :aggregate_failures do
        bus.write_byte(address: 0x9FFF, value: 0xCD)
        byte = bus.read_byte(address: 0x9FFF)

        expect(ppu).to have_received(:read_vram).with(0x9FFF)
        expect(byte).to eq(0xCD)
      end
    end

    context 'when in the 0xA000 - 0xBFFF (Cartridge RAM) range' do
      before do
        allow(cartridge).to receive(:read_ram).and_call_original
      end

      it 'delegates the read to the cartridge for address 0xA000', :aggregate_failures do
        bus.write_byte(address: 0xA000, value: 0x88)
        byte = bus.read_byte(address: 0xA000)

        expect(cartridge).to have_received(:read_ram).with(0xA000)
        expect(byte).to eq(0xFF)
      end

      it 'delegates the read to the cartridge for address 0xBFFF', :aggregate_failures do
        bus.write_byte(address: 0xBFFF, value: 0x99)
        byte = bus.read_byte(address: 0xBFFF)

        expect(cartridge).to have_received(:read_ram).with(0xBFFF)
        expect(byte).to eq(0xFF)
      end
    end

    context 'when in the 0xC000 - 0xDFFF (WRAM) range' do
      before do
        allow(wram).to receive(:read_byte).and_call_original
      end

      it 'delegates the read to the wram for address 0xC000', :aggregate_failures do
        bus.write_byte(address: 0xC000, value: 0x66)
        byte = bus.read_byte(address: 0xC000)

        expect(wram).to have_received(:read_byte).with(0xC000)
        expect(byte).to eq(0x66)
      end

      it 'delegates the read to the wram for address 0xDFFF', :aggregate_failures do
        bus.write_byte(address: 0xDFFF, value: 0x77)
        byte = bus.read_byte(address: 0xDFFF)

        expect(wram).to have_received(:read_byte).with(0xDFFF)
        expect(byte).to eq(0x77)
      end
    end

    context 'when in the 0xE000 - 0xFDFF (Echo RAM) range' do
      before do
        allow(wram).to receive(:read_byte).and_call_original
      end

      it 'mirrors WRAM - writing in WRAM and reading in Echo on 0xE000', :aggregate_failures do
        bus.write_byte(address: 0xC000, value: 0x44)
        byte = bus.read_byte(address: 0xE000)

        expect(wram).to have_received(:read_byte).with(0xE000)
        expect(byte).to eq(0x44)
      end

      it 'mirrors WRAM - writing in WRAM and reading in Echo on 0xFDFF', :aggregate_failures do
        bus.write_byte(address: 0xDDFF, value: 0x55)
        byte = bus.read_byte(address: 0xFDFF)

        expect(wram).to have_received(:read_byte).with(0xFDFF)
        expect(byte).to eq(0x55)
      end
    end

    context 'when in the 0xFE00 - 0xFE9F (PPU OAM) range' do
      before do
        allow(ppu).to receive(:read_oam).and_call_original
      end

      it 'delegates the read to the ppu for address 0xFE00', :aggregate_failures do
        bus.write_byte(address: 0xFE00, value: 0x22)
        byte = bus.read_byte(address: 0xFE00)

        expect(ppu).to have_received(:read_oam).with(0xFE00)
        expect(byte).to eq(0x22)
      end

      it 'delegates the read to the ppu for address 0xFE9F', :aggregate_failures do
        bus.write_byte(address: 0xFE9F, value: 0x33)
        byte = bus.read_byte(address: 0xFE9F)

        expect(ppu).to have_received(:read_oam).with(0xFE9F)
        expect(byte).to eq(0x33)
      end
    end

    context 'when in the 0xFEA0 - 0xFEFF (Unusable) range' do
      it 'returns 0xFF for address 0xFEA0' do
        expect(bus.read_byte(address: 0xFEA0)).to eq(0xFF)
      end

      it 'returns 0xFF for address 0xFEFF' do
        expect(bus.read_byte(address: 0xFEFF)).to eq(0xFF)
      end
    end

    context 'when in the 0xFF00 - 0xFF7F (IO Registers) range' do
      before do
        allow(joypad).to receive(:p1).and_call_original
        allow(serial).to receive(:sb).and_call_original
        allow(serial).to receive(:sc).and_call_original
        allow(timer).to receive(:div).and_call_original
        allow(timer).to receive(:tima).and_call_original
        allow(timer).to receive(:tma).and_call_original
        allow(timer).to receive(:tac).and_call_original
        allow(interrupts).to receive(:if_register).and_call_original
      end

      it 'returns the value in Joypad P1 register for 0xFF00', :aggregate_failures do
        joypad.p1 = 0b11001111
        byte = bus.read_byte(address: 0xFF00)

        expect(joypad).to have_received(:p1)
        expect(byte).to eq(0b11001111)
      end

      it 'returns the value in Serial SB register for 0xFF01', :aggregate_failures do
        serial.sb = 0x69
        byte = bus.read_byte(address: 0xFF01)

        expect(serial).to have_received(:sb)
        expect(byte).to eq(0x69)
      end

      it 'returns the value in Serial SC register for 0xFF02', :aggregate_failures do
        serial.sc = 0b01111110
        byte = bus.read_byte(address: 0xFF02)

        expect(serial).to have_received(:sc)
        expect(byte).to eq(0b01111110)
      end

      it 'returns the value in Timer DIV register for 0xFF04', :aggregate_failures do
        timer.div = 0x00
        byte = bus.read_byte(address: 0xFF04)

        expect(timer).to have_received(:div)
        expect(byte).to eq(0x00)
      end

      it 'returns the value in Timer TIMA register for 0xFF05', :aggregate_failures do
        timer.tima = 0xF1
        byte = bus.read_byte(address: 0xFF05)

        expect(timer).to have_received(:tima)
        expect(byte).to eq(0xF1)
      end

      it 'returns the value in Timer TMA register for 0xFF06', :aggregate_failures do
        timer.tma = 0x29
        byte = bus.read_byte(address: 0xFF06)

        expect(timer).to have_received(:tma)
        expect(byte).to eq(0x29)
      end

      it 'returns the value in Timer TAC register for 0xFF07', :aggregate_failures do
        timer.tac = 0x01
        byte = bus.read_byte(address: 0xFF07)

        expect(timer).to have_received(:tac)
        expect(byte).to eq(0x01)
      end

      it 'returns the value in Interrupts IF register for 0xFF0F', :aggregate_failures do
        interrupts.if_register = 0b11100010
        byte = bus.read_byte(address: 0xFF0F)

        expect(interrupts).to have_received(:if_register)
        expect(byte).to eq(0b11100010)
      end
    end

    context 'when in the 0xFF80 - 0xFFFE (HRAM) range' do
      before do
        allow(hram).to receive(:read_byte).and_call_original
      end

      it 'delegates the read to the hram for address 0xFF80', :aggregate_failures do
        bus.write_byte(address: 0xFF80, value: 0x12)
        byte = bus.read_byte(address: 0xFF80)

        expect(hram).to have_received(:read_byte).with(0xFF80)
        expect(byte).to eq(0x12)
      end

      it 'delegates the read to the hram for address 0xFFFE', :aggregate_failures do
        bus.write_byte(address: 0xFFFE, value: 0x23)
        byte = bus.read_byte(address: 0xFFFE)

        expect(hram).to have_received(:read_byte).with(0xFFFE)
        expect(byte).to eq(0x23)
      end
    end

    context 'when reading 0xFFFF address' do
      before do
        allow(interrupts).to receive(:ie_register).and_call_original
      end

      it 'returns the interrupts IE register value', :aggregate_failures do
        interrupts.ie_register = 0x99
        byte = bus.read_byte(address: 0xFFFF)

        expect(interrupts).to have_received(:ie_register)
        expect(byte).to eq(0x99)
      end
    end

    context 'when in out of bounds memory range' do
      it 'raises an error reading address larger than 0xFFFF', :aggregate_failures do
        expect { bus.read_byte(address: 0xFFFF + 1) }.to raise_error('MemoryOutOfBounds error')
      end
    end
  end

  describe '#write_byte' do
    context 'when in the 0x0000 - 0x7FFF (Cartridge ROM) range' do
      before do
        allow(cartridge).to receive(:write_rom).and_call_original
      end

      it 'delegates the write to the Cartridge for address 0x0000', :aggregate_failures do
        bus.write_byte(address: 0x0000, value: 0x01)

        expect(cartridge).to have_received(:write_rom).with(0x0000, 0x01)
      end

      it 'delegates the write to the Cartridge for address 0x7FFF', :aggregate_failures do
        bus.write_byte(address: 0x7FFF, value: 0x02)

        expect(cartridge).to have_received(:write_rom).with(0x7FFF, 0x02)
      end
    end

    context 'when in the 0x8000 - 0x9FFF (PPU VRAM) range' do
      before do
        allow(ppu).to receive(:write_vram).and_call_original
      end

      it 'delegates the write to the PPU for address 0x8000', :aggregate_failures do
        bus.write_byte(address: 0x8000, value: 0xAB)

        expect(ppu).to have_received(:write_vram).with(0x8000, 0xAB)
        expect(bus.read_byte(address: 0x8000)).to eq(0xAB)
      end

      it 'delegates the write to the PPU for address 0x9FFF', :aggregate_failures do
        bus.write_byte(address: 0x9FFF, value: 0xCD)

        expect(ppu).to have_received(:write_vram).with(0x9FFF, 0xCD)
        expect(bus.read_byte(address: 0x9FFF)).to eq(0xCD)
      end
    end

    context 'when in the 0xA000 - 0xBFFF (Cartridge RAM) range' do
      before do
        allow(cartridge).to receive(:write_ram).and_call_original
      end

      it 'delegates the write to the Cartridge for address 0xA000', :aggregate_failures do
        bus.write_byte(address: 0xA000, value: 0x88)

        expect(cartridge).to have_received(:write_ram).with(0xA000, 0x88)
      end

      it 'delegates the write to the Cartridge for address 0xBFFF', :aggregate_failures do
        bus.write_byte(address: 0xBFFF, value: 0x99)

        expect(cartridge).to have_received(:write_ram).with(0xBFFF, 0x99)
      end
    end

    context 'when in the 0xC000 - 0xDFFF (WRAM) range' do
      before do
        allow(wram).to receive(:write_byte).and_call_original
      end

      it 'delegates the write to the WRAM for address 0xC000', :aggregate_failures do
        bus.write_byte(address: 0xC000, value: 0x66)

        expect(wram).to have_received(:write_byte).with(0xC000, 0x66)
        expect(bus.read_byte(address: 0xC000)).to eq(0x66)
      end

      it 'delegates the write to the WRAM for address 0xDFFF', :aggregate_failures do
        bus.write_byte(address: 0xDFFF, value: 0x77)

        expect(wram).to have_received(:write_byte).with(0xDFFF, 0x77)
        expect(bus.read_byte(address: 0xDFFF)).to eq(0x77)
      end
    end

    context 'when in the 0xE000 - 0xFDFF (Echo RAM) range' do
      before do
        allow(wram).to receive(:write_byte).and_call_original
      end

      it 'mirrors WRAM - writing in Echo RAM and reading WRAM on 0xE000', :aggregate_failures do
        bus.write_byte(address: 0xE000, value: 0x44)

        expect(wram).to have_received(:write_byte).with(0xE000, 0x44)
        expect(bus.read_byte(address: 0xC000)).to eq(0x44)
      end

      it 'mirrors WRAM - writing in Echo RAM and reading WRAM on 0xFDFF', :aggregate_failures do
        bus.write_byte(address: 0xFDFF, value: 0x55)

        expect(wram).to have_received(:write_byte).with(0xFDFF, 0x55)
        expect(bus.read_byte(address: 0xDDFF)).to eq(0x55)
      end
    end

    context 'when in the 0xFE00 - 0xFE9F (PPU OAM) range' do
      before do
        allow(ppu).to receive(:write_oam).and_call_original
      end

      it 'delegates the write to the PPU for address 0xFE00', :aggregate_failures do
        bus.write_byte(address: 0xFE00, value: 0x22)

        expect(ppu).to have_received(:write_oam).with(0xFE00, 0x22)
        expect(bus.read_byte(address: 0xFE00)).to eq(0x22)
      end

      it 'delegates the write to the PPU for address 0xFE9F', :aggregate_failures do
        bus.write_byte(address: 0xFE9F, value: 0x33)

        expect(ppu).to have_received(:write_oam).with(0xFE9F, 0x33)
        expect(bus.read_byte(address: 0xFE9F)).to eq(0x33)
      end
    end

    context 'when in the 0xFEA0 - 0xFEFF (Unusable) range' do
      it 'ignores writes for address 0xFEA0, still returns 0xFF' do
        bus.write_byte(address: 0xFEA0, value: 0x99)

        expect(bus.read_byte(address: 0xFEA0)).to eq(0xFF)
      end

      it 'ignores writes for address 0xFEFF, still returns 0xFF' do
        bus.write_byte(address: 0xFEFF, value: 0x99)

        expect(bus.read_byte(address: 0xFEFF)).to eq(0xFF)
      end
    end

    context 'when in the 0xFF00 - 0xFF7F (IO Registers) range' do
      before do
        allow(joypad).to receive(:p1=).and_call_original
        allow(serial).to receive(:sb=).and_call_original
        allow(serial).to receive(:sc=).and_call_original
        allow(timer).to receive(:div=).and_call_original
        allow(timer).to receive(:tima=).and_call_original
        allow(timer).to receive(:tma=).and_call_original
        allow(timer).to receive(:tac=).and_call_original
        allow(interrupts).to receive(:if_register=).and_call_original
      end

      it 'writes the value in Joypad P1 register for 0xFF00', :aggregate_failures do
        joypad.p1 = 0b11001111 # Only Bits 4 and 5 and writable
        bus.write_byte(address: 0xFF00, value: 0b00110000)

        expect(joypad).to have_received(:p1=).with(0b00110000)
        expect(bus.read_byte(address: 0xFF00)).to eq(0b11111111)
      end

      it 'writes the value in Serial SB register for 0xFF01', :aggregate_failures do
        bus.write_byte(address: 0xFF01, value: 0x29)

        expect(serial).to have_received(:sb=).with(0x29)
        expect(bus.read_byte(address: 0xFF01)).to eq(0x29)
      end

      it 'writes the value in Serial SC register for 0xFF02', :aggregate_failures do
        bus.write_byte(address: 0xFF02, value: 0b00000001) # Only Bits 0 and 7 are usable

        expect(serial).to have_received(:sc=).with(0b00000001)
        expect(bus.read_byte(address: 0xFF02)).to eq(0b01111111)
      end

      it 'resets the value in Timer DIV register on writes to 0xFF04', :aggregate_failures do
        bus.write_byte(address: 0xFF04, value: 0xFF)

        expect(timer).to have_received(:div=).with(0xFF)
        expect(bus.read_byte(address: 0xFF04)).to eq(0x00)
      end

      it 'writes the value in Timer TIMA register for 0xFF05', :aggregate_failures do
        bus.write_byte(address: 0xFF05, value: 0x49)

        expect(timer).to have_received(:tima=).with(0x49)
        expect(bus.read_byte(address: 0xFF05)).to eq(0x49)
      end

      it 'writes the value in Timer TMA register for 0xFF06', :aggregate_failures do
        bus.write_byte(address: 0xFF06, value: 0x59)

        expect(timer).to have_received(:tma=).with(0x59)
        expect(bus.read_byte(address: 0xFF06)).to eq(0x59)
      end

      it 'writes the value in Timer TAC register for 0xFF07', :aggregate_failures do
        bus.write_byte(address: 0xFF07, value: 0x69)

        expect(timer).to have_received(:tac=).with(0x69)
        expect(bus.read_byte(address: 0xFF07)).to eq(0x69)
      end

      it 'writes the value in Interrupts IF register for 0xFF0F', :aggregate_failures do
        bus.write_byte(address: 0xFF0F, value: 0b11101000)

        expect(interrupts).to have_received(:if_register=).with(0b11101000)
        expect(bus.read_byte(address: 0xFF0F)).to eq(0b11101000)
      end
    end

    context 'when in the 0xFF80 - 0xFFFE (HRAM) range' do
      before do
        allow(hram).to receive(:write_byte).and_call_original
      end

      it 'delegates the read to the hram for address 0xFF80', :aggregate_failures do
        bus.write_byte(address: 0xFF80, value: 0x12)

        expect(hram).to have_received(:write_byte).with(0xFF80, 0x12)
        expect(bus.read_byte(address: 0xFF80)).to eq(0x12)
      end

      it 'delegates the read to the hram for address 0xFFFE', :aggregate_failures do
        bus.write_byte(address: 0xFFFE, value: 0x23)

        expect(hram).to have_received(:write_byte).with(0xFFFE, 0x23)
        expect(bus.read_byte(address: 0xFFFE)).to eq(0x23)
      end
    end

    context 'when writing to 0xFFFF address' do
      before do
        allow(interrupts).to receive(:ie_register=).and_call_original
      end

      it 'writes the value to the interrupts IE register value', :aggregate_failures do
        bus.write_byte(address: 0xFFFF, value: 0x11)

        expect(interrupts).to have_received(:ie_register=).with(0x11)
        expect(bus.read_byte(address: 0xFFFF)).to eq(0x11)
      end
    end

    context 'when in out of bounds memory range' do
      it 'raises an error writing to an address larger than 0xFFFF', :aggregate_failures do
        expect { bus.write_byte(address: 0xFFFF + 1, value: 0xFF) }.to raise_error('MemoryOutOfBounds error')
      end
    end
  end
end
