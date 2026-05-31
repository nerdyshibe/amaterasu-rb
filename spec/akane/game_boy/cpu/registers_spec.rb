# frozen_string_literal: true

describe Akane::GameBoy::Cpu::Registers do
  subject(:registers) { described_class.new(skip_boot_rom: true) }

  describe 'initialize' do
    it 'clears all register values if boot rom is not skipped', :aggregate_failures do
      registers = described_class.new(skip_boot_rom: false)

      expect(registers.a).to eq(0x00)
      expect(registers.f).to eq(0b00000000)
      expect(registers.b).to eq(0x00)
      expect(registers.c).to eq(0x00)
      expect(registers.d).to eq(0x00)
      expect(registers.e).to eq(0x00)
      expect(registers.h).to eq(0x00)
      expect(registers.l).to eq(0x00)
      expect(registers.sp).to eq(0x0000)
      expect(registers.pc).to eq(0x0000)
    end

    it 'sets the correct values if the boot rom is skipped', :aggregate_failures do
      expect(registers.a).to eq(0x01)
      expect(registers.f).to eq(0b10110000)
      expect(registers.b).to eq(0x00)
      expect(registers.c).to eq(0x13)
      expect(registers.d).to eq(0x00)
      expect(registers.e).to eq(0xD8)
      expect(registers.h).to eq(0x01)
      expect(registers.l).to eq(0x4D)
      expect(registers.sp).to eq(0xFFFE)
      expect(registers.pc).to eq(0x0100)
    end
  end

  describe '#a=' do
    it 'sets the correct value in the A register' do
      registers.a = 0x99

      expect(registers.a).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.a = 0xFF + 1

      expect(registers.a).to eq(0x00)
    end
  end

  describe '#f=' do
    it 'ignores the lower nibble from the F register' do
      registers.f = 0b11111111

      expect(registers.f).to eq(0b11110000)
    end
  end

  describe '#b=' do
    it 'sets the correct value in the B register' do
      registers.b = 0x99

      expect(registers.b).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.b = 0xFF + 1

      expect(registers.b).to eq(0x00)
    end
  end

  describe '#c=' do
    it 'sets the correct value in the C register' do
      registers.c = 0x99

      expect(registers.c).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.c = 0xFF + 1

      expect(registers.c).to eq(0x00)
    end
  end

  describe '#d=' do
    it 'sets the correct value in the D register' do
      registers.d = 0x99

      expect(registers.d).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.d = 0xFF + 1

      expect(registers.d).to eq(0x00)
    end
  end

  describe '#e=' do
    it 'sets the correct value in the E register' do
      registers.e = 0x99

      expect(registers.e).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.e = 0xFF + 1

      expect(registers.e).to eq(0x00)
    end
  end

  describe '#h=' do
    it 'sets the correct value in the H register' do
      registers.h = 0x99

      expect(registers.h).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.h = 0xFF + 1

      expect(registers.h).to eq(0x00)
    end
  end

  describe '#l=' do
    it 'sets the correct value in the L register' do
      registers.l = 0x99

      expect(registers.l).to eq(0x99)
    end

    it 'wraps all values around 0xFF' do
      registers.l = 0xFF + 1

      expect(registers.l).to eq(0x00)
    end
  end

  describe '#af=' do
    it 'sets the correct values for registers A and F', :aggregate_failures do
      registers.af = 0x9876

      expect(registers.a).to eq(0x98)
      expect(registers.f).to eq(0x70)
    end

    it 'wraps the value around 0xFFFF', :aggregate_failures do
      registers.af = 0xFFFF + 0x0999

      expect(registers.a).to eq(0x09)
      expect(registers.f).to eq(0x90)
    end
  end

  describe '#bc=' do
    it 'sets the correct values for registers B and C', :aggregate_failures do
      registers.bc = 0x1234

      expect(registers.b).to eq(0x12)
      expect(registers.c).to eq(0x34)
    end

    it 'wraps the value around 0xFFFF', :aggregate_failures do
      registers.bc = 0xFFFF + 0xFFF1

      expect(registers.b).to eq(0xFF)
      expect(registers.c).to eq(0xF0)
    end
  end

  describe '#de=' do
    it 'sets the correct values for registers D and E', :aggregate_failures do
      registers.de = 0x5678

      expect(registers.d).to eq(0x56)
      expect(registers.e).to eq(0x78)
    end

    it 'wraps the value around 0xFFFF', :aggregate_failures do
      registers.de = 0xFFFF + 0xFFF1

      expect(registers.d).to eq(0xFF)
      expect(registers.e).to eq(0xF0)
    end
  end

  describe '#hl=' do
    it 'sets the correct values for registers H and L', :aggregate_failures do
      registers.hl = 0x9123

      expect(registers.h).to eq(0x91)
      expect(registers.l).to eq(0x23)
    end

    it 'wraps the value around 0xFFFF', :aggregate_failures do
      registers.hl = 0xFFFF + 0xFFF1

      expect(registers.h).to eq(0xFF)
      expect(registers.l).to eq(0xF0)
    end
  end

  describe '#sp=' do
    it 'sets the sp register correctly' do
      registers.sp = 0x9999

      expect(registers.sp).to eq(0x9999)
    end

    it 'wraps the value around 0xFFFF' do
      registers.sp = 0xFFFF + 1

      expect(registers.sp).to eq(0x0000)
    end
  end

  describe '#pc=' do
    it 'sets the pc register correctly' do
      registers.pc = 0x9999

      expect(registers.pc).to eq(0x9999)
    end

    it 'wraps the value around 0xFFFF' do
      registers.pc = 0xFFFF + 1

      expect(registers.pc).to eq(0x0000)
    end
  end

  describe '#af' do
    it 'returns the correct 16-bit value' do
      registers.a = 0x69
      registers.f = 0xFF

      expect(registers.af).to eq(0x69F0)
    end
  end

  describe '#bc' do
    it 'returns the correct 16-bit value' do
      registers.b = 0x12
      registers.c = 0x34

      expect(registers.bc).to eq(0x1234)
    end
  end

  describe '#de' do
    it 'returns the correct 16-bit value' do
      registers.d = 0x56
      registers.e = 0x78

      expect(registers.de).to eq(0x5678)
    end
  end

  describe '#hl' do
    it 'returns the correct 16-bit value' do
      registers.h = 0x91
      registers.l = 0x23

      expect(registers.hl).to eq(0x9123)
    end
  end

  describe '#z_flag' do
    it 'returns 1 when Bit7 from the F register is set' do
      registers.f = 0b10000000

      expect(registers.z_flag).to eq(1)
    end

    it 'returns 0 when Bit7 from the F register is cleared' do
      registers.f = 0b01111111

      expect(registers.z_flag).to eq(0)
    end
  end

  describe '#n_flag' do
    it 'returns 1 when Bit6 from the F register is set' do
      registers.f = 0b01000000

      expect(registers.n_flag).to eq(1)
    end

    it 'returns 0 when Bit6 from the F register is cleared' do
      registers.f = 0b10111111

      expect(registers.n_flag).to eq(0)
    end
  end

  describe '#h_flag' do
    it 'returns 1 when Bit5 from the F register is set' do
      registers.f = 0b00100000

      expect(registers.h_flag).to eq(1)
    end

    it 'returns 0 when Bit5 from the F register is cleared' do
      registers.f = 0b11011111

      expect(registers.h_flag).to eq(0)
    end
  end

  describe '#c_flag' do
    it 'returns 1 when Bit4 from the F register is set' do
      registers.f = 0b00010000

      expect(registers.c_flag).to eq(1)
    end

    it 'returns 0 when Bit4 from the F register is cleared' do
      registers.f = 0b11101111

      expect(registers.c_flag).to eq(0)
    end
  end

  describe '#z_flag=' do
    it 'correctlies set Bit7 of the F register' do
      registers.f = 0x00
      registers.z_flag = true

      expect(registers.z_flag).to eq(1)
    end

    it 'correctlies clear Bit7 of the F register' do
      registers.f = 0xFF
      registers.z_flag = false

      expect(registers.z_flag).to eq(0)
    end
  end

  describe '#n_flag=' do
    it 'correctlies set Bit6 of the F register' do
      registers.f = 0x00
      registers.n_flag = true

      expect(registers.n_flag).to eq(1)
    end

    it 'correctlies clear Bit6 of the F register' do
      registers.f = 0xFF
      registers.n_flag = false

      expect(registers.n_flag).to eq(0)
    end
  end

  describe '#h_flag=' do
    it 'correctlies set Bit5 of the F register' do
      registers.f = 0x00
      registers.h_flag = true

      expect(registers.h_flag).to eq(1)
    end

    it 'correctlies clear Bit5 of the F register' do
      registers.f = 0xFF
      registers.h_flag = false

      expect(registers.h_flag).to eq(0)
    end
  end

  describe '#c_flag=' do
    it 'correctlies set Bit4 of the F register' do
      registers.f = 0x00
      registers.c_flag = true

      expect(registers.c_flag).to eq(1)
    end

    it 'correctlies clear Bit4 of the F register' do
      registers.f = 0xFF
      registers.c_flag = false

      expect(registers.c_flag).to eq(0)
    end
  end
end
