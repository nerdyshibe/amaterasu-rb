# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during VBlank mode.
        class VBlank
          attr_reader :name, :number

          def initialize(ppu:)
            @ppu = ppu

            @name = 'VBLANK'
            @number = 3
            @dots = 0
          end

          def tick
            puts 'VBlank mode ticked'
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::VBlank ' \
              "@name='#{@name}' " \
              "@number=#{@number} "
          end

          def to_s
            "#{@name} (#{@number})"
          end
        end
      end
    end
  end
end
