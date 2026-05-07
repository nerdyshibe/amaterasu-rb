# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the Serial Port present in the Game Boy.
    #
    # - Very useful for performing community accuracy tests, they use the serial to output results.
    class Serial
      # Returns the 8-bit value stored in the SB (Serial Transfer Data) register.
      attr_reader :sb

      # Returns an Array with all the bytes from the serial transfer.
      attr_reader :message_buffer

      # Creates a serial port instance.
      #
      # - Needs to hold an instance of interrupts to request a :serial interrupt.
      # - Holds the state of the Transfer Data and Control registers.
      def initialize(interrupts)
        @interrupts = interrupts
        @sb = 0x00
        @sc = 0x00

        @message_buffer = Array.new
      end

      # Returns the 8-bit value stored in the SC (Serial Transfer Control) register.
      #
      # - In the actual hardware only Bit 7 and Bit 0 are wired.
      # - Bits 6-1 always return 1 when read.
      def sc
        @sc | 0b01111110
      end

      # Sets a 8-bit value into the SB register.
      def sb=(value)
        @sb = value & 0xFF
      end

      # Sets a 8-bit value into the SC register.
      #
      # - Bits 6-1 are ignored since they are not wired to anything.
      # - If bit 7 goes from 0 -> 1, a transfer is started.
      def sc=(value)
        @sc = value & 0b10000001

        start_transfer if transfer_enabled?
      end

      private

      # Bit 7 from the SC register determines if the transfer is enabled.
      def transfer_enabled?
        (@sc >> 7).allbits?(1)
      end

      # Bit 0 from the SC register determines which clock controls the transfer.
      #
      # - If Bit 0 is set, the internal clock from the receiving Game Boy controls the transfer.
      # - If Bit 0 is cleared, the Game Boy waits for an external clock pulse.
      def clock_bit
        @sc & 1
      end

      # Transfers the byte from the SB register.
      #
      # - For the transfer to actually begin bits 7 and 0 need to be set.
      # - Internal clock must be selected, otherwise it just waits.
      def start_transfer
        return if clock_bit.zero?

        @message_buffer << @sb
        @sb = 0xFF

        complete_transfer
      end

      # Completes the transfer immediately after.
      #
      # - Transfer enable flag (Bit 7) is cleared.
      # - Requests a :serial interrupt.
      def complete_transfer
        @sc &= 0b01111111
        @interrupts.request(:serial)
      end
    end
  end
end
