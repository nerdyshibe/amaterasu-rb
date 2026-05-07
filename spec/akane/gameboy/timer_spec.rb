# frozen_string_literal: true

describe Akane::Gameboy::Timer do
  subject(:timer) { described_class.new(interrupts, skip_boot_rom: false) }

  let(:interrupts) { Akane::Gameboy::Interrupts.new }

  let(:t_cycles_per_tick) { 4 }
  let(:div_increment_ticks) { 2**8 / t_cycles_per_tick }

  describe '#initialize' do
    it 'sets the correct register values when boot rom is not skipped', :aggregate_failures do
      expect(timer.div).to eq(0x00)
      expect(timer.tima).to eq(0x00)
      expect(timer.tma).to eq(0x00)
      expect(timer.tac).to eq(0x00)
    end

    it 'sets the correct register values when boot rom is skipped', :aggregate_failures do
      timer = described_class.new(interrupts, skip_boot_rom: true)

      expect(timer.div).to eq(0xAB)
      expect(timer.tima).to eq(0x00)
      expect(timer.tma).to eq(0x00)
      expect(timer.tac).to eq(0xF8)
    end
  end

  describe '#div' do
    context 'boot rom not skipped' do
      it 'returns the correct initial value for div' do
        expect(timer.div).to eq(0x00)
      end

      it 'increments DIV after the correct amount of cycles' do
        expect { div_increment_ticks.times { timer.tick } }
          .to change { timer.div }.from(0x00).to(0x01)
      end
    end

    context 'boot rom skipped' do
      let(:timer) { described_class.new(interrupts, skip_boot_rom: true) }

      it 'returns the correct initial value for div' do
        expect(timer.div).to eq(0xAB)
      end

      it 'increments DIV after the correct amount of cycles' do
        expect { div_increment_ticks.times { timer.tick } }
          .to change { timer.div }.from(0xAB).to(0xAC)
      end
    end
  end

  describe '#div=' do
    it 'resets the global counter to 0x0000 on write', :aggregate_failures do
      timer = described_class.new(interrupts, skip_boot_rom: true)

      expect(timer.div).to eq(0xAB)
      expect { timer.div = 0xCD }.to change { timer.div }.from(0xAB).to(0x00)
    end

    it 'causes a TIMA increment if the current bit selected goes from 1 to 0 and TAC is enabled' do
      timer.tac = 0b00000101 # TAC enabled + Bit 3 selected
      2.times { timer.tick } # Sets internal counter to 8 (0b1000), Bit 3 is set
      timer.tima = 0x68

      expect { timer.div = 0x99 }.to change { timer.tima }.from(0x68).to(0x69)
    end

    it 'does not cause a TIMA increment if the current bit selected goes from 1 to 0 and TAC is disabled' do
      timer.tac = 0b00000001 # TAC disabled + Bit 3 selected
      2.times { timer.tick } # Sets internal counter to 8 (0b1000), Bit 3 is set
      timer.tima = 0x68

      expect { timer.div = 0x99 }.to_not change { timer.tima }
    end
  end

  describe '#tima=' do
    it 'sets a 8-bit value into the TIMA register' do
      timer.tima = 0x99

      expect(timer.tima).to eq(0x99)
    end

    it 'wraps values larger than 0xFF before storing than in the register' do
      timer.tima = 0xFF + 1

      expect(timer.tima).to eq(0x00)
    end

    it 'does not reload TIMA with TMA and does not request :timer interrupt if TIMA is written the same cycle it overflowed' do
      interrupts.if_register = 0b11100000
      timer.tac = 0b00000101
      timer.tma = 0x12
      timer.tima = 0xFF
      increment_cycles = 16 / 4

      expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0xFF).to(0x00)

      timer.tima = 0x34
      timer.tick

      expect(timer.tima).to eq(0x34)
      expect(interrupts.if_register).to eq(0b11100000)
    end
  end

  describe '#tma=' do
    it 'sets a 8-bit value into the TMA register' do
      timer.tma = 0x99

      expect(timer.tma).to eq(0x99)
    end

    it 'wraps values larger than 0xFF before storing than in the register' do
      timer.tma = 0xFF + 1

      expect(timer.tma).to eq(0x00)
    end
  end

  describe '#tac=' do
    it 'sets a 8-bit value into the TAC register' do
      timer.tac = 0x99

      expect(timer.tac).to eq(0x99)
    end

    it 'wraps values larger than 0xFF before storing than in the register' do
      timer.tac = 0xFF + 1

      expect(timer.tac).to eq(0x00)
    end

    it 'increments TIMA if TAC enable remains 1 and bit selected changes from 1 -> 0' do
      timer.tac = 0b00000101 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000110 # Bit 5 selected

      expect(timer.tima).to eq(0x69)
    end

    it 'does not increment TIMA if TAC enable remains 1 and bit selected changes from 0 -> 1' do
      timer.tac = 0b00000110 # Bit 5 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000101 # Bit 3 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable remains 0 and bit selected changes from 1 -> 0' do
      timer.tac = 0b00000001 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000010 # Bit 5 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable remains 0 and bit selected changes from 0 -> 1' do
      timer.tac = 0b00000010 # Bit 5 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000001 # Bit 3 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'increments TIMA if TAC enable goes from 1 -> 0 and bit selected goes from 1 -> 0' do
      timer.tac = 0b00000101 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000010 # Bit 5 selected

      expect(timer.tima).to eq(0x69)
    end

    it 'does not increment TIMA if TAC enable goes from 1 -> 0 and bit selected goes from 0 -> 1' do
      timer.tac = 0b00000110 # Bit 5 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000001 # Bit 3 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable goes from 0 -> 1 and bit selected goes from 1 -> 0' do
      timer.tac = 0b00000001 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000110 # Bit 5 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable goes from 0 -> 1 and bit selected goes from 0 -> 1' do
      timer.tac = 0b00000010 # Bit 5 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000101 # Bit 3 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'increments TIMA if TAC enable goes from 1 -> 0 and bit selected is always 1' do
      timer.tac = 0b00000101 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000001 # Bit 3 selected

      expect(timer.tima).to eq(0x69)
    end

    it 'does not increment TIMA if TAC enable goes from 0 -> 1 and bit selected is always 1' do
      timer.tac = 0b00000001 # Bit 3 selected
      timer.tima = 0x68
      2.times { timer.tick } # Sets @counter to 8 -> Bit 3 set
      timer.tac = 0b00000101 # Bit 3 selected

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable goes from 1 -> 0 and bit selected is always 0' do
      timer.div = 0x00 # Clears all bits
      timer.tac = 0b00000101 # Bit 3 selected
      timer.tima = 0x68

      timer.tac = 0b00000001 # Disables TAC

      expect(timer.tima).to eq(0x68)
    end

    it 'does not increment TIMA if TAC enable goes from 0 -> 1 and bit selected is always 0' do
      timer.div = 0x00 # Clears all bits
      timer.tac = 0b00000001 # Bit 3 selected
      timer.tima = 0x68

      timer.tac = 0b00000101 # Enables TAC

      expect(timer.tima).to eq(0x68)
    end
  end

  describe '#tick' do
    context 'counter overflow' do
      it 'wraps the counter around 0xFFFF without skipping boot rom' do
        timer = described_class.new(interrupts, skip_boot_rom: false)
        max_counter_cycles = 0xFFFF / 4

        expect(timer.div).to eq(0x00)
        expect { max_counter_cycles.times { timer.tick } }
          .to change { timer.div }.from(0x00).to(0xFF)
        expect { timer.tick }.to change { timer.div }.from(0xFF).to(0x00)
      end

      it 'wraps the counter around 0xFFFF after skipping boot rom' do
        timer = described_class.new(interrupts, skip_boot_rom: true)
        max_counter_cycles = (0xFFFF - 0xABCC) / 4

        expect(timer.div).to eq(0xAB)
        expect { max_counter_cycles.times { timer.tick } }
          .to change { timer.div }.from(0xAB).to(0xFF)
        expect { timer.tick }.to change { timer.div }.from(0xFF).to(0x00)
      end
    end

    context 'TAC 0b00' do
      let(:increment_cycles) { 1024 / 4 }

      it 'increments TIMA every 1024 T-cycles if TAC is enabled', :aggregate_failures do
        timer.tac = 0b00000100
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x00).to(0x01)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x01).to(0x02)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x02).to(0x03)
      end

      it 'does not increment TIMA every 1024 T-cycles if TAC is disabled', :aggregate_failures do
        timer.tac = 0b00000000
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
      end

      it 'reloads TIMA with TMA and requests a :timer interrupt 1 cycle after it overflows', :aggregate_failures do
        interrupts.if_register = 0b11100000
        timer.tac = 0b00000100
        timer.tma = 0x99
        timer.tima = 0xFF

        expect { increment_cycles.times { timer.tick } }
          .to change { timer.tima }.from(0xFF).to(0x00)

        expect(interrupts.if_register).to eq(0b11100000)

        expect { timer.tick }
          .to change { timer.tima }.from(0x00).to(timer.tma)
          .and change { interrupts.if_register }.from(0b11100000).to(0b11100100)
      end

      it 'handles consecutive overflows if TMA is set to 0xFF', :aggregate_failures do
        interrupts.if_register = 0b11100000
        timer.tac = 0b00000100
        timer.tma = 0xFF
        timer.tima = 0x00

        expect { (0xFF * increment_cycles).times { timer.tick } }
          .to change { timer.tima }.from(0x00).to(0xFF)

        expect { increment_cycles.times { timer.tick } }
          .to change { timer.tima }.from(0xFF).to(0x00)

        expect(interrupts.if_register).to eq(0b11100000)

        timer.tick

        expect(timer.tima).to eq(0xFF)
        expect(interrupts.if_register).to eq(0b11100100)

        (increment_cycles - 1).times { timer.tick }

        expect(timer.tima).to eq(0x00)
        expect(interrupts.if_register).to eq(0b11100100)

        timer.tick

        expect(timer.tima).to eq(0xFF)
        expect(interrupts.if_register).to eq(0b11100100)
      end
    end

    context 'TAC 0b01' do
      let(:increment_cycles) { 16 / 4 }

      it 'increments TIMA every 16 T-cycles if TAC is enabled' do
        timer.tac = 0b00000101
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x00).to(0x01)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x01).to(0x02)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x02).to(0x03)
      end

      it 'does not increment TIMA every 16 T-cycles if TAC is disabled', :aggregate_failures do
        timer.tac = 0b00000001
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
      end

      it 'reloads TIMA with TMA and requests a :timer interrupt 1 cycle after it overflows', :aggregate_failures do
        interrupts.if_register = 0b11100000
        timer.tac = 0b00000101
        timer.tma = 0x99
        timer.tima = 0xFF

        expect { increment_cycles.times { timer.tick } }
          .to change { timer.tima }.from(0xFF).to(0x00)

        expect(interrupts.if_register).to eq(0b11100000)

        expect { timer.tick }
          .to change { timer.tima }.from(0x00).to(timer.tma)
          .and change { interrupts.if_register }.from(0b11100000).to(0b11100100)
      end
    end

    context 'TAC 0b10' do
      let(:increment_cycles) { 64 / 4 }

      it 'increments TIMA every 64 T-cycles if TAC is enabled' do
        timer.tac = 0b00000110
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x00).to(0x01)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x01).to(0x02)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x02).to(0x03)
      end

      it 'does not increment TIMA every 64 T-cycles if TAC is disabled', :aggregate_failures do
        timer.tac = 0b00000010
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
      end

      it 'reloads TIMA with TMA and requests a :timer interrupt 1 cycle after it overflows', :aggregate_failures do
        interrupts.if_register = 0b11100000
        timer.tac = 0b00000110
        timer.tma = 0x99
        timer.tima = 0xFF

        expect { increment_cycles.times { timer.tick } }
          .to change { timer.tima }.from(0xFF).to(0x00)

        expect(interrupts.if_register).to eq(0b11100000)

        expect { timer.tick }
          .to change { timer.tima }.from(0x00).to(timer.tma)
          .and change { interrupts.if_register }.from(0b11100000).to(0b11100100)
      end
    end

    context 'TAC 0b11' do
      let(:increment_cycles) { 256 / 4 }

      it 'increments TIMA every 256 T-cycles if TAC is enabled' do
        timer.tac = 0b00000111
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x00).to(0x01)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x01).to(0x02)
        expect { increment_cycles.times { timer.tick } }.to change { timer.tima }.from(0x02).to(0x03)
      end

      it 'does not increment TIMA every 256 T-cycles if TAC is disabled', :aggregate_failures do
        timer.tac = 0b00000011
        timer.tima = 0x00

        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
        expect { increment_cycles.times { timer.tick } }.to_not change { timer.tima }
      end

      it 'reloads TIMA with TMA and requests a :timer interrupt 1 cycle after it overflows', :aggregate_failures do
        interrupts.if_register = 0b11100000
        timer.tac = 0b00000111
        timer.tma = 0x99
        timer.tima = 0xFF

        expect { increment_cycles.times { timer.tick } }
          .to change { timer.tima }.from(0xFF).to(0x00)

        expect(interrupts.if_register).to eq(0b11100000)

        expect { timer.tick }
          .to change { timer.tima }.from(0x00).to(timer.tma)
          .and change { interrupts.if_register }.from(0b11100000).to(0b11100100)
      end
    end
  end
end
