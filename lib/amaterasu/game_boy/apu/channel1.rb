# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Apu
      # Models the logic and behaviors of the APU Channel 1.
      #
      # Responsible for generating 1 of the 2 Pulse waves used.
      class Channel1
        attr_reader :nr10,
                    :nr11,
                    :nr12,
                    :nr13,
                    :nr14

        def initialize
          @nr10 = 0x80
          @nr11 = 0xBF
          @nr12 = 0xF3
          @nr13 = 0xFF
          @nr14 = 0xBF

          @sweep = 0
          @duty_cycle = 12.5
          @length_timer = 0
        end

        def nr10=(value)
          @nr10 = value & 0xFF
        end

        def nr11=(value)
          @nr11 = value & 0xFF
        end

        def nr12=(value)
          @nr12 = value & 0xFF
        end

        def nr13=(value)
          @nr13 = value & 0xFF
        end

        def nr14=(value)
          @nr14 = value & 0xFF
        end
      end
    end
  end
end
