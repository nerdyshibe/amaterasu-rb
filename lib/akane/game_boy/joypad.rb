# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the joypad inputs and logic.
    class Joypad
      BIT_MASK_UNUSED_BITS = 0b11000000

      BIT_MASK_BUTTONS_SELECT_BIT = 0b00100000
      BIT_MASK_DPAD_SELECT_BIT    = 0b00010000

      # Maps all face buttons to its relevant bit.
      FACE_BUTTONS = {
        a: 0,
        b: 1,
        select: 2,
        start: 3
      }.freeze

      # Maps all D-pad buttons to its relevant bit.
      DPAD_BUTTONS = {
        right: 0,
        left: 1,
        up: 2,
        down: 3
      }.freeze

      # Creates a joypad object.
      #
      # - Holds interrupts instance to request a :joypad interrupt.
      # - @p1 register only holds the relevant selection bits (Bits 5 and 4).
      # - Dpad and button state are tracked as separate nibbles.
      def initialize(interrupts, skip_boot_rom: true)
        @interrupts = interrupts
        @p1 = skip_boot_rom ? 0xCF : 0x00

        @dpad = 0xF
        @buttons = 0xF
      end

      # Returns the 8-bit value stored in the P1 register.
      #
      # - Bits 7 and 6 are unused, they always read 1.
      # - The actual @p1 register only holds the 2 selection bits (Bit 5 and 4).
      # - Calculate the buttons state based on the pressed buttons and use it as the lower nibble.
      def p1
        BIT_MASK_UNUSED_BITS | @p1 | buttons_state
      end

      # Sets a 8-bit value into the P1 register.
      #
      # - The lower nibble is read-only.
      # - Bit 5 is used to select the face buttons.
      # - Bit 4 is used to select the d-pad.
      def p1=(value)
        old_state = buttons_state
        @p1 = value & 0b00110000
        new_state = buttons_state

        falling_edges = old_state & ~new_state # checks for bits that went 1 -> 0
        request_interrupt if falling_edges.anybits?(0x0F)
      end

      # @param button [Symbol] Dpad button pressed (:up, :down, :left, :right).
      def press_dpad(button)
        relevant_bit = DPAD_BUTTONS[button]
        return if (@dpad >> relevant_bit).nobits?(1) # already pressed

        clear_mask = ~(1 << relevant_bit)
        @dpad &= clear_mask

        request_interrupt if dpad_selected?
      end

      # @param button [Symbol] Dpad button released (:up, :down, :left, :right).
      def release_dpad(button)
        relevant_bit = DPAD_BUTTONS[button]
        return if (@dpad >> relevant_bit).anybits?(1) # already released

        set_mask = (1 << relevant_bit)
        @dpad |= set_mask
      end

      # @param button [Symbol] Face button pressed (:a, :b, :start, :select).
      def press_face(button)
        relevant_bit = FACE_BUTTONS[button]
        return if (@buttons >> relevant_bit).nobits?(1) # already pressed

        clear_mask = ~(1 << relevant_bit)
        @buttons &= clear_mask

        request_interrupt if buttons_selected?
      end

      # @param button [Symbol] Face button released (:a, :b, :start, :select).
      def release_face(button)
        relevant_bit = FACE_BUTTONS[button]
        return if (@buttons >> relevant_bit).anybits?(1) # already released

        set_mask = (1 << relevant_bit)
        @buttons |= set_mask
      end

      private

      def request_interrupt
        @interrupts.request(:joypad)
      end

      def dpad_selected?
        (@p1 >> 4).nobits?(1)
      end

      def buttons_selected?
        (@p1 >> 5).nobits?(1)
      end

      def buttons_state
        return @dpad & @buttons if dpad_selected? && buttons_selected?
        return @dpad if dpad_selected?
        return @buttons if buttons_selected?

        0xF
      end
    end
  end
end
