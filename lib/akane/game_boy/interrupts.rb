# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the Interrupts Controller inside the Game Boy
    class Interrupts
      # Interrupt types sorted by highest to lowest priority.
      TYPES = {
        v_blank: 0,
        lcd_stat: 1,
        timer: 2,
        serial: 3,
        joypad: 4
      }.freeze

      # Address vectors to jump to for each interrupt type.
      VECTORS = {
        v_blank: 0x0040,
        lcd_stat: 0x0048,
        timer: 0x0050,
        serial: 0x0058,
        joypad: 0x0060
      }.freeze

      # Creates a new interrupts object holding the registers state.
      #
      # - IF register value changes based on the Boot ROM being skipped.
      def initialize(skip_boot_rom: true)
        @if = skip_boot_rom ? 0xE1 : 0x00
        @ie = 0x00
      end

      # Returns the 8-bit value of the IF (Interrupt Flag) register.
      #
      # - When read, it always returns 1 for Bits 7, 6 and 5.
      def if_register
        @if | 0b11100000
      end

      # TODO: convert to attr_reader
      # Returns the 8-bit value of the IE (Interrupt Enable) register.
      def ie_register
        @ie
      end

      # Sets a 8-bit value into the IF register.
      #
      # - Bits 7, 6 and 5 are set to 0 when writing to it.
      # - Components are responsible for requesting their own interrupts.
      # - Controls whether or not a given interrupt is currently requested.
      def if_register=(value)
        @if = value & 0b00011111
      end

      # Sets a 8-bit value into the IE register.
      #
      # - Values are set by the game's code during CPU fetch-decode.
      # - Controls whether or not a given interrupt is enabled and can be serviced.
      def ie_register=(value)
        @ie = value & 0xFF
      end

      # Checks if any interrupt is requested and enabled at the same time.
      #
      # - Ignores the 3 upper bits that are not bound to any interrupt type.
      def any_pending?
        (@if & @ie).anybits?(0b00011111)
      end

      # Returns which interrupt is currently requested and enabled, sorted by priority.
      def highest_pending
        TYPES.each_key do |type|
          return type if pending?(type)
        end

        raise ArgumentError, 'No interrupts found for highest pending'
      end

      # Sets the correct Bit in the IF register based on the interrupt type.
      def request(type)
        set_mask = 1 << TYPES[type]
        @if |= set_mask
      end

      # Clears the correct Bit in the IF register based on the interrupt type.
      def service(type)
        clear_mask = ~(1 << TYPES[type])
        @if &= clear_mask
      end

      def priority_service
        service(highest_pending)
      end

      def priority_vector
        VECTORS[highest_pending]
      end

      private

      # Checks if a given interrupt is requested and enabled at the same time.
      def pending?(type)
        set_mask = (1 << TYPES[type])
        ((@if & set_mask) & (@ie & set_mask)).anybits?(0b00011111)
      end
    end
  end
end
