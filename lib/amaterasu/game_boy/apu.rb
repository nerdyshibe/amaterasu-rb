# frozen_string_literal: true

module Amaterasu
  module GameBoy
    # Models the APU behavior from the Game Boy.
    #
    # The APU is composed of 4 Channels:
    # - Channel 1: Pulse 1 Channel
    # - Channel 2: Pulse 2 Channel
    # - Channel 3: Wave Channel
    # - Channel 4: Noise Channel
    class Apu
      def initialize
        @nr50 = 0x77
        @nr51 = 0xF3
        @nr52 = 0xF1

        @enabled = @nr52[7] == 1

        @channel1 = Channel1.new
      end

      def tick
        # tick logic
      end
    end
  end
end
