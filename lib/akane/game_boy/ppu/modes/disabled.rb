# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the PPU when LCD Control Bit 7 is 0.
        class Disabled
          def initialize
            @name = 'DISABLED'
            @number = 0
          end

          def tick
            # no-op
          end
        end
      end
    end
  end
end
