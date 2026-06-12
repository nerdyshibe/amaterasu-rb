# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during VBlank mode.
        class VBlank
          attr_reader :name, :number

          def initialize(ppu)
            @ppu = ppu

            @name = 'VBLANK'
            @number = 1
          end

          def tick
            return unless @ppu.dots == DOTS_PER_SCANLINE

            @ppu.reset_for_scanline
            @ppu.increment_ly
            return unless @ppu.registers.ly == TOTAL_SCANLINES

            @ppu.draw_frame
            @ppu.reset_states
            @ppu.set_mode(:oam_scan)
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::VBlank ' \
              "@name='#{@name}' " \
              "@number=#{@number} "
          end

          def to_s
            "#{@name} (##{@number}) | WAITING UNTIL THE FRAME IS COMPLETED"
          end
        end
      end
    end
  end
end
