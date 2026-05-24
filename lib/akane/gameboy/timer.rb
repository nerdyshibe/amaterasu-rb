# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the built-in clock timer inside the Game Boy.
    class Timer
      include Utils::BitOps

      # Each tick advances 4 T-cycles / 1 M-cycle
      T_CYCLES = 4

      # Master clock defined by the hardware specs (in T-cycles).
      MASTER_CLOCK_FREQUENCY = 4_194_304

      # Frequency in which TIMA increments once for each clock select.
      TIMA_INCREMENT_FREQUENCIES = [
        4_096,
        262_144,
        65_536,
        16_384
      ].freeze

      # How many cycles are needed to increment TIMA once for each clock select.
      TIMA_INCREMENT_CYCLES = [
        MASTER_CLOCK_FREQUENCY / TIMA_INCREMENT_FREQUENCIES[0b00],
        MASTER_CLOCK_FREQUENCY / TIMA_INCREMENT_FREQUENCIES[0b01],
        MASTER_CLOCK_FREQUENCY / TIMA_INCREMENT_FREQUENCIES[0b10],
        MASTER_CLOCK_FREQUENCY / TIMA_INCREMENT_FREQUENCIES[0b11]
      ].freeze

      # TIMA only increments if there is a falling edge.
      # The value needs to be divided by 2 to achieve the correct value.
      # The given bit needs to flip twice to reach a falling edge (0 -> 1 and 1 -> 0).
      COUNTER_FALLING_EDGE_CYCLES = [
        TIMA_INCREMENT_CYCLES[0b00] / 2,
        TIMA_INCREMENT_CYCLES[0b01] / 2,
        TIMA_INCREMENT_CYCLES[0b10] / 2,
        TIMA_INCREMENT_CYCLES[0b11] / 2
      ].freeze

      # In binary a given Bit N always flips each 2^N ticks/cycles.
      # Based on the number of cycles derived above you can find the correct bit to watch.
      #
      # Example for clock select 0b00:
      # - 1024 T-cycles to increment TIMA.
      # - So we need to find a Bit N that flips (1024 / 2) times to achieve a falling edge.
      # - 2^N = 512 => N = log2(512) => N = 9 (Watch Bit 9 from the system counter).
      COUNTER_BITS_TO_WATCH = [
        Math.log2(COUNTER_FALLING_EDGE_CYCLES[0b00]).round,
        Math.log2(COUNTER_FALLING_EDGE_CYCLES[0b01]).round,
        Math.log2(COUNTER_FALLING_EDGE_CYCLES[0b10]).round,
        Math.log2(COUNTER_FALLING_EDGE_CYCLES[0b11]).round
      ].freeze

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

      # Reading DIV only exposes the upper byte of the system counter.
      def div
        (@counter >> 8) & 0xFF
      end

      # Writing to DIV register always resets the system counter.
      #
      # When the value is reset to 0x0000, if the current bit being "watched"
      # goes from 1 -> 0 it can trigger a TIMA increment due to a falling edge
      # in the joint signal.
      def div=(_value)
        old_signal = joint_signal
        @counter = 0x0000
        new_signal = joint_signal

        increment_tima if falling_edge?(old_signal, new_signal)
      end

      # Sets a 8-bit value into the TIMA register.
      #
      # Obscure behaviors:
      # - If the CPU tries to write to TIMA the same cycle it was already reloaded
      #   with TMA, the write is completely ignored and TIMA keeps the TMA value.
      # - If the CPU tries to write to TIMA the cycle immediately after it overflows,
      #   but hasn't been reloaded with TMA yet, the write succeeds, TIMA keeps the
      #   value written by the CPU and the reload is cancelled as if the overflow never happened.
      def tima=(value)
        return if @state == :tima_reloaded

        @state = :tima_reloaded if @state == :tima_reload_pending

        @tima = value & 0xFF
      end

      # Sets a 8-bit value into the TMA register.
      #
      # Obscure behavior:
      # - If the CPU writes to TMA the cycle after TIMA was already reloaded,
      #   TIMA is reloaded a second time with the new value because the TMA latch
      #   remains open for 2 M-cycles (the original reload + the next).
      def tma=(value)
        @tma = value & 0xFF
        @tima = @tma if @state == :tima_reloaded
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
      # - The Counter is always counting independent from all the other logic.
      # - The tick is being implemented in M-cycle precision, so each tick is 4 T-cycles.
      # - After TIMA overflows, there is a 1 M-cycle delay before
      #   setting TMA into TIMA and requesting the Timer interrupt.
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

      # Increments TIMA once, the register is 8-bit so it wraps around 0xFF.
      # Sets a new Timer state when the overflow occurs to be handled in the M-cycle after.
      def increment_tima
        @tima = (@tima + 1) & 0xFF
        @state = :tima_reload_pending if @tima.zero?
      end

      # It is 1 of 2 bits responsible for TIMA incrementing whenever a falling edge occurs.
      def tac_enable_bit
        bit(@tac, 2)
      end

      # This is the joint signal that determines if TIMA should increment or not.
      def joint_signal
        tac_enable_bit & counter_bit_value
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
      def counter_bit_position
        COUNTER_BITS_TO_WATCH[tac_clock_select]
      end

      # Returns the actual value of the bit being watched (0 or 1).
      def counter_bit_value
        @counter[counter_bit_position]
      end

      # Checks for a falling edge (1 -> 0) in the joint signal.
      # Joint signal is a bitwise AND between:
      # - TAC enable bit (Bit 2)
      # - Currently selected bit in the system counter
      #
      # @param old_signal [Integer] Either 0 or 1.
      # @param new_signal [Integer] Either 0 or 1.
      # @return [Boolean]
      def falling_edge?(old_signal, new_signal)
        old_signal == 1 && new_signal == 0
      end

      def log_state(old_signal, new_signal)
        $stdout.printf(
          '%<cy>05d || COUNTER: $%<n>04X (%<n>06d) || :%<state>-20s || ' \
          'TIMA: $%<tima>02X || TMA: $%<tma>02X || TAC: %<tac>08b || ' \
          'OLD SIGNAL: %<os>d => NEW SIGNAL: %<ns>d || ' \
          "INTERRUPT: %<int>d\n",
          cy: @m_cycles,
          n: @counter,
          state: @state.upcase,
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
