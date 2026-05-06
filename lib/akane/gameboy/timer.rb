# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the built-in clock timer inside the Game Boy.
    class Timer
      # Each tick advances 4 T-cycles / 1 M-cycle
      T_CYCLES = 4

      # Stores the Bits to watch for falling edges in the system counter.
      # Values are based on the given frequency defined by the TAC clock select.
      #
      # - 0b00: 1024 = 2^10 -> 2^10 = 2^(N+1) -> N = 9 -> Watch Bit 9 of the system counter.
      # - 0b01: 16 = 2^4    -> 2^4 = 2^(N+1)  -> N = 3 -> Watch Bit 3 of the system counter.
      # - 0b10: 64 = 2^6    -> 2^6 = 2^(N+1)  -> N = 5 -> Watch Bit 5 of the system counter.
      # - 0b11: 256 = 2^8   -> 2^8 = 2^(N+1)  -> N = 7 -> Watch Bit 7 of the system counter.
      COUNTER_BITS_TO_WATCH = [9, 3, 5, 7]

      # Returns the 8-bit value stored in the TIMA (Timer Counter) register.
      attr_reader :tima

      # Returns the 8-bit value stored in the TMA (Timer Modulo) register.
      attr_reader :tma

      # Returns the 8-bit value stored in the TAC (Timer Control) register.
      attr_reader :tac

      # Creates an instance of the timer.
      #
      # - Needs the interrupts instance to request a timer interrupt.
      # - Has an internal-only 16-bit counter that increments each T-cycle.
      def initialize(interrupts, skip_boot_rom: true)
        @interrupts = interrupts
        @counter = skip_boot_rom ? 0xABCC : 0x0000
        @tima_overflow = false

        @tima = 0x00
        @tma = 0x00
        @tac = skip_boot_rom ? 0xF8 : 0x00
      end

      # Exposes only the upper byte of the system counter.
      def div
        (@counter >> 8) & 0xFF
      end

      # Writing to DIV register resets the system counter.
      #
      # When the value is reset to 0x0000, if the current bit being "watched"
      # goes from 1 -> 0, a falling edge occurs and can trigger a TIMA increment.
      def div=(_value)
        previous_counter = @counter
        @counter = 0x0000

        @tima = (@tima + 1) & 0xFF if increment_tima?(previous_counter)
      end

      # Sets a 8-bit value into the TIMA register.
      def tima=(value)
        if @tima_overflow && @tima == 0x00
          @tima_overflow = false
        end

        @tima = value & 0xFF
      end

      # Sets a 8-bit value into the TMA register.
      def tma=(value)
        @tma = value & 0xFF
      end

      # Sets a 8-bit value into the TAC register.
      #
      # Obscure behavior:
      # - If before the write, TAC is pointing to Bit 9 which is set (1),
      # and after the write it points to Bit 3 which is not set (0),
      # this is seen as a falling edge which increments TIMA.
      def tac=(value)
        previous_bit_selected = (@counter >> clock_bit_position) & 1
        previous_tac_enable = tac_enable
        previous_signal = previous_bit_selected & previous_tac_enable

        @tac = value & 0xFF

        current_bit_selected = (@counter >> clock_bit_position) & 1
        current_tac_enable = tac_enable
        current_signal = current_bit_selected & current_tac_enable

        falling_edge = previous_signal == 1 && current_signal.zero?
        @tima = (@tima + 1) & 0xFF if falling_edge
      end

      # Advances the system counter, increments TIMA if needed and handles TIMA overflow logic.
      #
      # - Counter value should wrap around 0xFFFF (16-bit).
      # - Each tick should advance the timer by 1 M-cycle, so 4 T-cycles.
      # - After TIMA overflows, there is a 1 M-cycle delay before setting TMA into TIMA and requesting the Timer interrupt.
      def tick
        previous_counter = @counter
        @counter = (@counter + T_CYCLES) & 0xFFFF

        if @tima_overflow
          @tima = @tma
          @interrupts.request(:timer)
          @tima_overflow = false
        end

        previous_tima = @tima
        @tima = (@tima + 1) & 0xFF if increment_tima?(previous_counter)
        @tima_overflow = true if previous_tima == 0xFF && @tima == 0x00
      end

      private

      # Returns whether or not TIMA should be incremented this cycle.
      def increment_tima?(previous_counter)
        tac_enable == 1 && falling_edge?(previous_counter)
      end

      # Controls whether or not TIMA should be incremented.
      def tac_enable
        (@tac >> 2) & 1
      end

      # Controls at which frequency TIMA should be incremented.
      #
      # - 0b00: Every 1024 T-cycles
      # - 0b01: Every 16 T-cycles
      # - 0b10: Every 64 T-cycles
      # - 0b11: Every 256 T-cycles
      def tac_clock_select
        @tac & 0b00000011
      end

      # Returns which bit in the system counter we need to watch for a falling edge.
      def clock_bit_position
        COUNTER_BITS_TO_WATCH[tac_clock_select]
      end

      # Returns whether or not a falling edge was detected in the current watched bit of the counter.
      def falling_edge?(previous_counter)
        previous_clock_bit = (previous_counter >> clock_bit_position) & 1
        current_clock_bit = (@counter >> clock_bit_position) & 1

        previous_clock_bit == 1 && current_clock_bit.zero?
      end
    end
  end
end
