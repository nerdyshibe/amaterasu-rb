# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the Ppu during OAM Scan mode.
        class OamScan
          TOTAL_DOTS = 80

          attr_reader :name, :number

          # Creates the OamScan object that will be re-used by the Ppu.
          #
          # @param ppu [Akane::GameBoy::Ppu]
          def initialize(ppu, oam)
            @ppu = ppu
            @oam = oam

            @name = 'OAM SCAN'
            @number = 2

            @sprite_count = 0
            @sprite_index = 0
            @current_sprite = nil
          end

          # This method is called by the Ppu each dot (T-cycle).
          # It takes exactly 80 dots to scan OAM which has 40 sprite entries.
          # This means that it takes exactly 2 dots to scan each sprite.
          def tick
            if @ppu.dots.odd? && @sprite_count < Ppu::MAX_SPRITES_PER_SCANLINE
              @current_sprite = @oam.sprite(@sprite_index)
              @sprite_index += 1

              return unless @current_sprite.y_pos + 16 == @ppu.registers.ly

              @ppu.sprite_buffer[@sprite_count] = @current_sprite
              @sprite_count += 1
            end

            return unless @ppu.dots == TOTAL_DOTS

            @ppu.set_mode(:drawing)
          end

          # Custom inspect to prevent circular dependency issues.
          def inspect
            '#<Akane::GameBoy::Ppu::Modes::OamScan ' \
              "@name='#{@name}' " \
              "@number=#{@number} " \
              "@sprite_buffer=#{@sprite_buffer}"
          end

          # Custom to_s method to use in the Ppu#log_state method.
          def to_s
            if @current_sprite.nil?
              "#{@name} (#{@number}) | Sprite wasn't fetched yet"
            else
              "#{@name} (#{@number}) | " \
                "#{@current_sprite.inspect} (##{format('%02d', @sprite_index)}) " \
                "Count: #{@sprite_count}"
            end
          end
        end
      end
    end
  end
end
