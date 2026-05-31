# frozen_string_literal: true

describe Akane::GameBoy::Interrupts do
  subject(:interrupts) { described_class.new(skip_boot_rom: true) }

  describe '#if_register' do
    it 'returns 0xE1 if boot rom is skipped' do
      expect(interrupts.if_register).to eq(0xE1)
    end

    it 'returns 0xE0 if boot rom is not skipped' do
      interrupts = described_class.new(skip_boot_rom: false)

      expect(interrupts.if_register).to eq(0xE0)
    end
  end

  describe '#ie_register' do
    it 'returns 0x00 if boot rom is skipped' do
      expect(interrupts.ie_register).to eq(0x00)
    end

    it 'also returns 0x00 if boot rom is not skipped' do
      interrupts = described_class.new(skip_boot_rom: false)

      expect(interrupts.ie_register).to eq(0x00)
    end
  end

  describe '#if_register=' do
    it 'sets a value into the 5 lower bits, 3 upper always are set when reading' do
      interrupts.if_register = 0b00011111

      expect(interrupts.if_register).to eq(0b11111111)
    end
  end

  describe '#ie_register=' do
    it 'sets any value into the IE register' do
      interrupts.ie_register = 0x99

      expect(interrupts.ie_register).to eq(0x99)
    end

    it 'wraps around if the value is above 0xFF' do
      interrupts.ie_register = 0xFF + 2

      expect(interrupts.ie_register).to eq(0x01)
    end
  end

  describe '#any_pending?' do
    it 'returns true if Bit 0 is set on both IF and IE (VBlank)' do
      interrupts.if_register = 0b00000001
      interrupts.ie_register = 0b00000001

      expect(interrupts.any_pending?).to be true
    end

    it 'returns true if Bit 1 is set on both IF and IE (LCD)' do
      interrupts.if_register = 0b00000010
      interrupts.ie_register = 0b00000010

      expect(interrupts.any_pending?).to be true
    end

    it 'returns true if Bit 2 is set on both IF and IE (Timer)' do
      interrupts.if_register = 0b00000100
      interrupts.ie_register = 0b00000100

      expect(interrupts.any_pending?).to be true
    end

    it 'returns true if Bit 3 is set on both IF and IE (Serial)' do
      interrupts.if_register = 0b00001000
      interrupts.ie_register = 0b00001000

      expect(interrupts.any_pending?).to be true
    end

    it 'returns true if Bit 4 is set on both IF and IE (Joypad)' do
      interrupts.if_register = 0b00010000
      interrupts.ie_register = 0b00010000

      expect(interrupts.any_pending?).to be true
    end

    it 'returns false if different bits are set on IF and IE (Joypad)' do
      interrupts.if_register = 0b00000011
      interrupts.ie_register = 0b00011100

      expect(interrupts.any_pending?).to be false
    end

    it 'returns false if only Bit 5 is set on both IF and IE (No Interrupt)' do
      interrupts.if_register = 0b00100000
      interrupts.ie_register = 0b00100000

      expect(interrupts.any_pending?).to be false
    end

    it 'returns false if only Bit 6 is set on both IF and IE (No Interrupt)' do
      interrupts.if_register = 0b01000000
      interrupts.ie_register = 0b01000000

      expect(interrupts.any_pending?).to be false
    end

    it 'returns false if only Bit 7 is set on both IF and IE (No Interrupt)' do
      interrupts.if_register = 0b10000000
      interrupts.ie_register = 0b10000000

      expect(interrupts.any_pending?).to be false
    end
  end

  describe '#highest_pending' do
    context 'when :v_blank is highest' do
      it 'returns :v_blank when all 5 interrupt bits are set' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:v_blank)
      end

      it 'returns :v_blank when all bits are set on IF but only Bit 0 in IE' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00000001

        expect(interrupts.highest_pending).to eq(:v_blank)
      end

      it 'returns :v_blank when all bits are set on IE but only Bit 0 in IF' do
        interrupts.if_register = 0b00000001
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:v_blank)
      end
    end

    context 'when :lcd_stat is highest' do
      it 'returns :lcd_stat when 4 of the interrupt bits are set' do
        interrupts.if_register = 0b00011110
        interrupts.ie_register = 0b00011110

        expect(interrupts.highest_pending).to eq(:lcd_stat)
      end

      it 'returns :lcd_stat when all bits are set on IF but only Bit 1 in IE' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00000010

        expect(interrupts.highest_pending).to eq(:lcd_stat)
      end

      it 'returns :lcd_stat when all bits are set on IE but only Bit 1 in IF' do
        interrupts.if_register = 0b00000010
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:lcd_stat)
      end
    end

    context 'when :timer is highest' do
      it 'returns :timer when 3 of the interrupt bits are set' do
        interrupts.if_register = 0b00011100
        interrupts.ie_register = 0b00011100

        expect(interrupts.highest_pending).to eq(:timer)
      end

      it 'returns :timer when all bits are set on IF but only Bit 2 in IE' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00000100

        expect(interrupts.highest_pending).to eq(:timer)
      end

      it 'returns :timer when all bits are set on IE but only Bit 2 in IF' do
        interrupts.if_register = 0b00000100
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:timer)
      end
    end

    context 'when :serial is highest' do
      it 'returns :serial when 2 of the interrupt bits are set' do
        interrupts.if_register = 0b00011000
        interrupts.ie_register = 0b00011000

        expect(interrupts.highest_pending).to eq(:serial)
      end

      it 'returns :serial when all bits are set on IF but only Bit 3 in IE' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00001000

        expect(interrupts.highest_pending).to eq(:serial)
      end

      it 'returns :serial when all bits are set on IE but only Bit 3 in IF' do
        interrupts.if_register = 0b00001000
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:serial)
      end
    end

    context 'when :joypad is highest' do
      it 'returns :joypad when only its interrupt bit is set' do
        interrupts.if_register = 0b00010000
        interrupts.ie_register = 0b00010000

        expect(interrupts.highest_pending).to eq(:joypad)
      end

      it 'returns :joypad when all bits are set on IF but only Bit 4 in IE' do
        interrupts.if_register = 0b00011111
        interrupts.ie_register = 0b00010000

        expect(interrupts.highest_pending).to eq(:joypad)
      end

      it 'returns :joypad when all bits are set on IE but only Bit 4 in IF' do
        interrupts.if_register = 0b00010000
        interrupts.ie_register = 0b00011111

        expect(interrupts.highest_pending).to eq(:joypad)
      end
    end
  end

  describe '#request' do
    context 'when :v_blank is requested' do
      it 'sets Bit 0 of the IF register when requesting :v_blank interrupt' do
        interrupts.if_register = 0b11100000
        interrupts.request(:v_blank)

        expect(interrupts.if_register).to eq(0b11100001)
      end

      it 'keeps other Bits state if they were already set' do
        interrupts.if_register = 0b11111110
        interrupts.request(:v_blank)

        expect(interrupts.if_register).to eq(0b11111111)
      end
    end

    context 'when :lcd_stat is requested' do
      it 'sets Bit 1 of the IF register when requesting :lcd_stat interrupt' do
        interrupts.if_register = 0b11100000
        interrupts.request(:lcd_stat)

        expect(interrupts.if_register).to eq(0b11100010)
      end

      it 'keeps other Bits state if they were already set' do
        interrupts.if_register = 0b11111101
        interrupts.request(:lcd_stat)

        expect(interrupts.if_register).to eq(0b11111111)
      end
    end

    context 'when :timer is requested' do
      it 'sets Bit 2 of the IF register when requesting :timer interrupt' do
        interrupts.if_register = 0b11100000
        interrupts.request(:timer)

        expect(interrupts.if_register).to eq(0b11100100)
      end

      it 'keeps other Bits state if they were already set' do
        interrupts.if_register = 0b11111011
        interrupts.request(:timer)

        expect(interrupts.if_register).to eq(0b11111111)
      end
    end

    context 'when :serial is requested' do
      it 'sets Bit 3 of the IF register when requesting :serial interrupt' do
        interrupts.if_register = 0b11100000
        interrupts.request(:serial)

        expect(interrupts.if_register).to eq(0b11101000)
      end

      it 'keeps other Bits state if they were already set' do
        interrupts.if_register = 0b11110111
        interrupts.request(:serial)

        expect(interrupts.if_register).to eq(0b11111111)
      end
    end

    context 'when :joypad is requested' do
      it 'sets Bit 4 of the IF register when requesting :joypad interrupt' do
        interrupts.if_register = 0b11100000
        interrupts.request(:joypad)

        expect(interrupts.if_register).to eq(0b11110000)
      end

      it 'keeps other Bits state if they were already set' do
        interrupts.if_register = 0b11101111
        interrupts.request(:joypad)

        expect(interrupts.if_register).to eq(0b11111111)
      end
    end
  end

  describe '#service' do
    context 'when :v_blank is serviced' do
      it 'clears Bit 0 of the IF register when servicing :v_blank interrupt' do
        interrupts.if_register = 0b11111111
        interrupts.service(:v_blank)

        expect(interrupts.if_register).to eq(0b11111110)
      end

      it 'keeps other Bits state if they were already cleared' do
        interrupts.if_register = 0b11100001
        interrupts.service(:v_blank)

        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when :lcd_stat is serviced' do
      it 'clears Bit 1 of the IF register when servicing :lcd_stat interrupt' do
        interrupts.if_register = 0b11111111
        interrupts.service(:lcd_stat)

        expect(interrupts.if_register).to eq(0b11111101)
      end

      it 'keeps other Bits state if they were already cleared' do
        interrupts.if_register = 0b11100010
        interrupts.service(:lcd_stat)

        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when :timer is serviced' do
      it 'clears Bit 2 of the IF register when servicing :timer interrupt' do
        interrupts.if_register = 0b11111111
        interrupts.service(:timer)

        expect(interrupts.if_register).to eq(0b11111011)
      end

      it 'keeps other Bits state if they were already cleared' do
        interrupts.if_register = 0b11100100
        interrupts.service(:timer)

        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when :serial is serviced' do
      it 'clears Bit 3 of the IF register when servicing :serial interrupt' do
        interrupts.if_register = 0b11111111
        interrupts.service(:serial)

        expect(interrupts.if_register).to eq(0b11110111)
      end

      it 'keeps other Bits state if they were already cleared' do
        interrupts.if_register = 0b11101000
        interrupts.service(:serial)

        expect(interrupts.if_register).to eq(0b11100000)
      end
    end

    context 'when :joypad is serviced' do
      it 'clears Bit 4 of the IF register when servicing :joypad interrupt' do
        interrupts.if_register = 0b11111111
        interrupts.service(:joypad)

        expect(interrupts.if_register).to eq(0b11101111)
      end

      it 'keeps other Bits state if they were already cleared' do
        interrupts.if_register = 0b11110000
        interrupts.service(:joypad)

        expect(interrupts.if_register).to eq(0b11100000)
      end
    end
  end
end
