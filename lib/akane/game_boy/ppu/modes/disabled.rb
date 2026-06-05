# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the PPU when LCD Control Bit 7 is 0.
        class Disabled
          attr_reader :name, :number

          def initialize(ppu)
            @ppu = ppu
            @lcd_control = @ppu.registers.lcdc

            @name = 'DISABLED'
            @number = 0
          end

          def tick
            return unless @lcd_control.lcd_enabled?

            @ppu.reset_states
            @ppu.set_mode(:oam_scan)
          end
        end
      end
    end
  end
end
