# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the built-in clock timer inside the Game Boy.
    class Timer
      include Utils::BitOps

      # Each tick advances 4 T-cycles / 1 M-cycle
      T_CYCLES = 4

      # Stores the Bits to watch for falling edges in the system counter.
      # Values are based on the given frequency defined by the TAC clock select.
      #
      # - 0b00: 1024 = 2^10 -> 2^10 = 2^(N+1) -> N = 9 -> Watch Bit 9 of the system counter.
      # - 0b01: 16 = 2^4    -> 2^4 = 2^(N+1)  -> N = 3 -> Watch Bit 3 of the system counter.
      # - 0b10: 64 = 2^6    -> 2^6 = 2^(N+1)  -> N = 5 -> Watch Bit 5 of the system counter.
      # - 0b11: 256 = 2^8   -> 2^8 = 2^(N+1)  -> N = 7 -> Watch Bit 7 of the system counter.
      COUNTER_BITS_TO_WATCH = [9, 3, 5, 7].freeze

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
      def initialize(interrupts, skip_boot_rom: true, trace_timer: false)
        @interrupts = interrupts
        @trace_timer = trace_timer

        @counter = skip_boot_rom ? 0xABCC : 0x0000
        @tima    = 0x00
        @tma     = 0x00
        @tac     = skip_boot_rom ? 0xF8 : 0x00

        @m_cycles = 0
        @state = :running
        @tima_overflow = false
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
        old_signal = joint_signal
        @counter = 0x0000
        new_signal = joint_signal

        increment_tima if falling_edge?(old_signal, new_signal)
      end

      # Sets a 8-bit value into the TIMA register.
      def tima=(value)
        return if @state == :tima_reloaded

        @state = :tima_reloaded if @state == :tima_reload_pending

        @tima = value & 0xFF
      end

      # Sets a 8-bit value into the TMA register.
      def tma=(value)
        return if @state == :tima_reloaded

        @tma = value & 0xFF
      end

      # Sets a 8-bit value into the TAC register.
      #
      # There are 2 distinct cases in which writing to TAC can cause
      # a sporadic TIMA increment:
      # - TAC Enable (Bit 2) going from 1 -> 0 can cause a falling edge in the joint signal.
      # - Changing the TAC Clock Select (Bits 1-0) can also cause a falling edge
      #   if the previous bit selected from the counter was 1, and the new one is 0.
      def tac=(value)
        old_signal = joint_signal
        @tac = value & 0xFF
        new_signal = joint_signal

        increment_tima if falling_edge?(old_signal, new_signal)
      end

      # Advances the system counter, increments TIMA if needed and handles TIMA overflow logic.
      #
      # - Counter value should wrap around 0xFFFF (16-bit).
      # - Each tick should advance the timer by 1 M-cycle, so 4 T-cycles.
      # - After TIMA overflows, there is a 1 M-cycle delay before setting TMA into TIMA and requesting the Timer interrupt.
      def tick
        old_signal = joint_signal
        @counter = (@counter + T_CYCLES) & 0xFFFF
        new_signal = joint_signal

        case @state
        when :running
          increment_tima if falling_edge?(old_signal, new_signal)
        when :tima_reload_pending
          @tima = @tma
          @interrupts.request(:timer)
          @state = :tima_reloaded
        when :tima_reloaded
          @state = :running
        end

        log_state(old_signal, new_signal) if @trace_timer
        @m_cycles += 1
      end

      private

      def increment_tima
        @tima = (@tima + 1) & 0xFF
        @state = :tima_reload_pending if @tima.zero?
      end

      # Controls whether or not TIMA should be incremented.
      def tac_enable
        bit(@tac, 2)
      end

      def joint_signal
        tac_enable & clock_bit_value
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

      def clock_bit_value
        @counter[clock_bit_position]
      end

      # Checks for a falling edge (1 -> 0) in the joint signal.
      # Joint signal is composed of (TAC enable bit && Currently selected bit in the Counter).
      #
      # @param old_value [Integer] Either 0 or 1.
      # @param new_value [Integer] Either 0 or 1.
      def falling_edge?(old_value, new_value)
        old_value == 1 && new_value.zero?
      end

      def log_state(old_signal, new_signal)
        $stdout.printf(
          '#%<cy>05d || COUNTER: $%<n>04X (%<n>06d) || TIMA: $%<tima>02X || TMA: $%<tma>02X || TAC: %<tac>08b || ' \
          'OLD SIGNAL: %<os>d => NEW SIGNAL: %<ns>d || ' \
          "INTERRUPT: %<int>d\n",
          cy: @m_cycles,
          n: @counter,
          tima: @tima,
          tma: @tma,
          tac: @tac,
          os: old_signal,
          ns: new_signal,
          int: @interrupts.if_register[2]
        )
      end
    end
  end
end
