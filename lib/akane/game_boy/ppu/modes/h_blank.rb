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
            @dots = 0
          end

          def tick
            puts 'HBlank mode ticked'
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::HBlank ' \
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
