# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the PPU when LCD Control Bit 7 is 0.
        class Disabled
          def initialize(ppu)
            @ppu = ppu

            @name = 'DISABLED'
            @number = 0
          end

          def tick
            return unless @ppu.registers.lcdc.lcd_enabled?

            @ppu.reset_dots
            @ppu.set_mode(:oam_scan)
          end
        end
      end
    end
  end
end
