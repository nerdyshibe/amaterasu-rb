# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the PPU during OAM Scan mode.
        class OamScan
          # Each Sprite takes 2 dots to scan.
          SCAN_DURATION_IN_DOTS = 80

          attr_reader :name, :number

          # @param ppu [Akane::GameBoy::Ppu] Reference to the PPU instance.
          # @param oam [Akane::GameBoy::Oam] Reference to the OAM instance.
          def initialize(ppu)
            @ppu = ppu

            @name = 'OAM SCAN'
            @number = 2

            @sprite_count = 0
            @sprite_index = 0
            @current_sprite = nil
          end

          # This method is called by the PPU each T-cycle
          # for all visible scanlines (0 - 143) and when
          # dots are between 0 and 79.
          #
          # Takes exactly 2 dots to fetch a sprite so every
          # even dot (0, 2, 4, ..., 78) is a NO-OP.
          def tick
            if @ppu.dots.odd?
              @current_sprite = @ppu.fetch_sprite_at(@sprite_index) #=> 0 - 39
              @sprite_index += 1
            end

            if sprite_within_current_scanline? && @sprite_count < Ppu::MAX_SPRITES_PER_SCANLINE
              @ppu.sprite_buffer << @current_sprite
              @sprite_count += 1
            end

            return unless @ppu.dots == SCAN_DURATION_IN_DOTS

            sort_sprites_by_x_positions unless @ppu.sprite_buffer.empty?
            @sprite_count = 0
            @sprite_index = 0
            @ppu.set_mode(:drawing)
          end

          def sprite_within_current_scanline?
            sprite_height = @ppu.registers.lcdc.obj_size_8x16? ? 16 : 8

            @ppu.registers.ly >= @current_sprite.y_screen_pos
              && @ppu.registers.ly < @current_sprite.y_screen_pos + sprite_height
          end

          def sort_sprites_by_x_positions
            @ppu.sprite_buffer.sort_by!(&:x)
          end

          # Custom inspect to prevent circular dependencies.
          def inspect
            '#<Akane::GameBoy::Ppu::Modes::OamScan ' \
              "@name='#{@name}' " \
              "@number=#{@number} " \
              "@sprite_buffer=#{@sprite_buffer}"
          end

          # Custom to_s method to use in the Ppu#log_state method.
          def to_s
            "#{@name} (##{@number}) | " \
              "SCANNED: Sprite ##{format('%02d', @sprite_index)} | " \
              "BUFFER: #{@ppu.sprite_buffer} (#{@ppu.sprite_buffer.size})"
          end
        end
      end
    end
  end
end
