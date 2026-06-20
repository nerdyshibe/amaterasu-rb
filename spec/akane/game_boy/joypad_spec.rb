# frozen_string_literal: true

describe Amaterasu::GameBoy::Joypad do
  subject(:joypad) { described_class.new(interrupts) }

  let(:interrupts) { Amaterasu::GameBoy::Interrupts.new(skip_boot_rom: false) }

  let(:two_upper_bits) { (joypad.p1 >> 6) & 0b11 }
  let(:selection_bits) { (joypad.p1 >> 4) & 0b11 }
  let(:buttons_state) { joypad.p1 & 0b1111 }

  let(:joypad_interrupt_flag) { (interrupts.if_register >> 4) & 1 }

  describe '#initialize' do
    it 'starts with both button groups selected (0)' do
      expect(selection_bits).to eq(0b00)
    end

    it 'reads no buttons pressed (all 1) on initialize' do
      expect(buttons_state).to eq(0b1111)
    end
  end

  describe '#p1' do
    it 'always reads 1 on Bits 7 and 6' do
      joypad.p1 = 0x00

      expect(two_upper_bits).to eq(0b11)
    end
  end

  describe '#press_dpad' do
    context 'when dpad group is not selected' do
      before do
        joypad.p1 = 0b00110000
      end

      context 'when :right is pressed' do
        before do
          joypad.press_dpad(:right)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if dpad group is selected after' do
          joypad.p1 = 0b00100000
          expect(buttons_state).to eq(0b1110)
        end
      end

      context 'when :left is pressed' do
        before do
          joypad.press_dpad(:left)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if dpad group is selected after' do
          joypad.p1 = 0b00100000
          expect(buttons_state).to eq(0b1101)
        end
      end

      context 'when :up is pressed' do
        before do
          joypad.press_dpad(:up)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if dpad group is selected after' do
          joypad.p1 = 0b00100000
          expect(buttons_state).to eq(0b1011)
        end
      end

      context 'when :down is pressed' do
        before do
          joypad.press_dpad(:down)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if dpad group is selected after' do
          joypad.p1 = 0b00100000
          expect(buttons_state).to eq(0b0111)
        end
      end
    end

    context 'when dpad group is selected' do
      before do
        joypad.p1 = 0b00100000
      end

      context 'when :right is pressed' do
        before do
          joypad.press_dpad(:right)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1110)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_dpad(:right)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :left is pressed' do
        before do
          joypad.press_dpad(:left)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1101)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_dpad(:left)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :up is pressed' do
        before do
          joypad.press_dpad(:up)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1011)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_dpad(:up)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :down is pressed' do
        before do
          joypad.press_dpad(:down)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b0111)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_dpad(:down)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end
    end
  end

  describe '#release_dpad' do
    context 'when dpad group is not selected' do
      before do
        joypad.p1 = 0b00110000
      end

      context 'when :right is pressed' do
        before do
          joypad.press_dpad(:right)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_dpad(:right) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :left is pressed' do
        before do
          joypad.press_dpad(:left)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_dpad(:left) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :up is pressed' do
        before do
          joypad.press_dpad(:up)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_dpad(:up) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :down is pressed' do
        before do
          joypad.press_dpad(:down)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_dpad(:down) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end
    end

    context 'when dpad group is selected' do
      before do
        joypad.p1 = 0b00100000
      end

      context 'when :right is pressed' do
        before do
          joypad.press_dpad(:right)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_dpad(:right) }
            .to change { joypad.p1 & 0b1111 }.from(0b1110).to(0b1111)
        end
      end

      context 'when :left is pressed' do
        before do
          joypad.press_dpad(:left)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_dpad(:left) }
            .to change { joypad.p1 & 0b1111 }.from(0b1101).to(0b1111)
        end
      end

      context 'when :up is pressed' do
        before do
          joypad.press_dpad(:up)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_dpad(:up) }
            .to change { joypad.p1 & 0b1111 }.from(0b1011).to(0b1111)
        end
      end

      context 'when :down is pressed' do
        before do
          joypad.press_dpad(:down)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_dpad(:down) }
            .to change { joypad.p1 & 0b1111 }.from(0b0111).to(0b1111)
        end
      end
    end
  end

  describe '#press_face' do
    context 'when face group is not selected' do
      before do
        joypad.p1 = 0b00110000
      end

      context 'when :a is pressed' do
        before do
          joypad.press_face(:a)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if face group is selected after' do
          joypad.p1 = 0b00010000
          expect(buttons_state).to eq(0b1110)
        end
      end

      context 'when :b is pressed' do
        before do
          joypad.press_face(:b)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if face group is selected after' do
          joypad.p1 = 0b00010000
          expect(buttons_state).to eq(0b1101)
        end
      end

      context 'when :select is pressed' do
        before do
          joypad.press_face(:select)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if face group is selected after' do
          joypad.p1 = 0b00010000
          expect(buttons_state).to eq(0b1011)
        end
      end

      context 'when :start is pressed' do
        before do
          joypad.press_face(:start)
        end

        it 'does not affect the lower nibble' do
          expect(buttons_state).to eq(0b1111)
        end

        it 'does not request a joypad interrupt' do
          expect(joypad_interrupt_flag).to eq(0)
        end

        it 'clears the correct bit if face group is selected after' do
          joypad.p1 = 0b00010000
          expect(buttons_state).to eq(0b0111)
        end
      end
    end

    context 'when face group is selected' do
      before do
        joypad.p1 = 0b00010000
      end

      context 'when :a is pressed' do
        before do
          joypad.press_face(:a)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1110)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_face(:a)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :b is pressed' do
        before do
          joypad.press_face(:b)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1101)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_face(:b)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :select is pressed' do
        before do
          joypad.press_face(:select)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b1011)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_face(:select)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end

      context 'when :start is pressed' do
        before do
          joypad.press_face(:start)
        end

        it 'clears the correct bit on the lower nibble' do
          expect(buttons_state).to eq(0b0111)
        end

        it 'requests a joypad interrupt by setting Bit 4 of IF' do
          expect(joypad_interrupt_flag).to eq(1)
        end

        it 'does not request interrupt if button is already pressed' do
          interrupts.if_register = 0x00
          joypad.press_face(:start)
          expect(joypad_interrupt_flag).to eq(0)
        end
      end
    end
  end

  describe '#release_face' do
    context 'when face group is not selected' do
      before do
        joypad.p1 = 0b00110000
      end

      context 'when :a is pressed' do
        before do
          joypad.press_face(:a)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_face(:a) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :b is pressed' do
        before do
          joypad.press_face(:b)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_face(:b) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :select is pressed' do
        before do
          joypad.press_face(:select)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_face(:select) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end

      context 'when :start is pressed' do
        before do
          joypad.press_face(:start)
        end

        it 'does not affect the lower nibble' do
          expect { joypad.release_face(:start) }.not_to(change { joypad.p1 & 0b1111 })
        end
      end
    end

    context 'when face group is selected' do
      before do
        joypad.p1 = 0b00010000
      end

      context 'when :a is pressed' do
        before do
          joypad.press_face(:a)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_face(:a) }
            .to change { joypad.p1 & 0b1111 }.from(0b1110).to(0b1111)
        end
      end

      context 'when :b is pressed' do
        before do
          joypad.press_face(:b)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_face(:b) }
            .to change { joypad.p1 & 0b1111 }.from(0b1101).to(0b1111)
        end
      end

      context 'when :select is pressed' do
        before do
          joypad.press_face(:select)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_face(:select) }
            .to change { joypad.p1 & 0b1111 }.from(0b1011).to(0b1111)
        end
      end

      context 'when :start is pressed' do
        before do
          joypad.press_face(:start)
        end

        it 'reverts the correct bit from the lower nibble' do
          expect { joypad.release_face(:start) }
            .to change { joypad.p1 & 0b1111 }.from(0b0111).to(0b1111)
        end
      end
    end
  end
end
