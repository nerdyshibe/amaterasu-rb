# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during Drawing mode.
        #
        # The Drawing mode does not have a fixed duration,
        # it can vary between 172 and 289 dots.
        #
        # This mode can be considered completed when 160 pixels
        # are outputted to the LCD. Normally, the PPU can output
        # a pixel per dot, but this is not always the case, there are
        # several scenarios in which "penalties" occur and this
        # causes the mode to take longer.
        class Drawing
          attr_reader :name, :number

          def initialize(ppu)
            @ppu = ppu

            @pixel_fetcher = @ppu.pixel_fetcher
            @pixel_emitter = @ppu.pixel_emitter

            @name = 'DRAWING'
            @number = 3
          end

          def tick
            @pixel_fetcher.tick
            @pixel_emitter.tick
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::Drawing ' \
              "@name='#{@name}' " \
              "@number=#{@number} "
          end

          def to_s
            "#{@name} (#{@number}) | #{format('%-30s', @pixel_fetcher)} | #{@pixel_emitter}"
          end
        end
      end
    end
  end
end
