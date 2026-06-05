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
            @number = 3
          end

          def tick
            @ppu.increment_ly if @ppu.dots == 455
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
            "#{@name} (#{@number}) | WAITING UNTIL THE FRAME IS COMPLETED"
          end
        end
      end
    end
  end
end
