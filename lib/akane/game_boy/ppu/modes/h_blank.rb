# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during HBlank mode.
        class HBlank
          attr_reader :name, :number

          def initialize(ppu)
            @ppu = ppu

            @name = 'HBLANK'
            @number = 0
          end

          def tick
            return unless @ppu.dots == 455

            @ppu.increment_ly

            if @ppu.registers.ly < 144
              @ppu.set_mode(:oam_scan)
              @ppu.sprite_buffer.clear
            elsif @ppu.registers.ly == 144
              @ppu.set_mode(:v_blank)
              @ppu.request_interrupt(:v_blank)
            end
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::HBlank ' \
              "@name='#{@name}' " \
              "@number=#{@number} "
          end

          def to_s
            "#{@name} (#{@number}) | WAITING FOR SCANLINE TO FINISH"
          end
        end
      end
    end
  end
end
