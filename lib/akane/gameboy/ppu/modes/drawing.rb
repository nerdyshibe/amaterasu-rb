# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during Drawing mode.
        class Drawing
          attr_reader :name, :number

          def initialize(ppu:)
            @ppu = ppu

            @name = 'DRAWING'
            @number = 3
            @frame_buffer = Array.new
          end

          def tick
            puts 'Drawing mode ticked'
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::Drawing ' \
              "@name='#{@name}' " \
              "@number=#{@number} " \
              "@sprite_buffer=#{@frame_buffer}"
          end

          def to_s
            "#{@name} (#{@number})"
          end
        end
      end
    end
  end
end
