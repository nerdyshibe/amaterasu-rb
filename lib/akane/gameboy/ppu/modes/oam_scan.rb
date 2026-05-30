# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during OAM Scan mode.
        class OamScan
          TOTAL_DOTS = 80

          attr_reader :name, :number

          def initialize(ppu:)
            @ppu = ppu

            @name = 'OAM SCAN'
            @number = 2
            @sprite_buffer = Array.new(10)
          end

          def tick
            @ppu.set_mode(:drawing) if @ppu.dots == TOTAL_DOTS
          end

          def inspect
            '#<Akane::GameBoy::Ppu::Modes::OamScan ' \
              "@name='#{@name}' " \
              "@number=#{@number} " \
              "@sprite_buffer=#{@sprite_buffer}"
          end

          def to_s
            "#{@name} (#{@number}) Sprites: #{@sprite_buffer}"
          end
        end
      end
    end
  end
end
