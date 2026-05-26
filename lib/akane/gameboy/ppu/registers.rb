# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the behavior of the Ppu registers.
      class Registers
        def initialize
          @ly = 0x00
        end
      end
    end
  end
end
