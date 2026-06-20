# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Ppu
      module Modes
        # Defines the behavior of the PPU during Rendering mode.
        #
        # The Rendering mode does not have a fixed duration,
        # it can vary between 172 and 289 dots.
        #
        # This mode can be considered completed when 160 pixels
        # are outputted to the LCD. Normally, the PPU can output
        # a pixel per dot, but this is not always the case, there are
        # several scenarios in which "penalties" occur and this
        # causes the mode to take longer.
        class Rendering
          attr_reader :name, :number

          def initialize(ppu)
            @ppu = ppu

            @name = 'RENDERING'
            @number = 3

            @bg_win_fifo    = PixelFifo.new
            @sprite_fifo    = PixelFifo.new
            @bg_win_fetcher = BgWinFetcher.new(ppu, @bg_win_fifo)
            @sprite_fetcher = SpriteFetcher.new(ppu, @sprite_fifo)
            @pixel_emitter  = PixelEmitter.new(ppu, @bg_win_fifo, @sprite_fifo)

            @sprite_found = nil
            @mode = :fetch_bg
            @lcd_x = 0
          end

          def tick
            if any_sprites? && @mode != :fetch_sprite
              @mode = :fetch_sprite
              @sprite_found = @ppu.sprite_buffer.shift
              @sprite_fetcher.start_for(@sprite_found) unless sprite_offscreen?(@sprite_found)
            elsif @mode == :fetch_sprite
              @sprite_fetcher.tick
              @mode = :fetch_bg if @sprite_fetcher.done?
            else
              @bg_win_fetcher.activate_window! if window_reached?

              @bg_win_fetcher.tick
              pixel_drawn = @pixel_emitter.tick?
            end

            @lcd_x += 1 if pixel_drawn
            return unless @lcd_x == PIXELS_PER_SCANLINE && @bg_win_fetcher.step == :sleep

            @bg_win_fetcher.reset_for_scanline
            @pixel_emitter.reset_for_scanline
            @lcd_x = 0
            @sprite_fifo.clear
            @bg_win_fifo.clear
            @ppu.set_mode(:h_blank)
          end

          def inspect
            '#<Amaterasu::GameBoy::Ppu::Modes::Rendering ' \
              "@name='#{@name}' " \
              "@number=#{@number} "
          end

          def to_s
            if @mode == :fetch_bg
              "#{@name} (##{@number}) | " \
                "LCD X: #{@lcd_x} | " \
                "#{@bg_win_fetcher} | " \
                "#{@pixel_emitter}"
            else
              "#{@name} (##{@number}) | " \
                "LCD X: #{@lcd_x} | " \
                "Sprite: #{@sprite_fetcher}"
            end
          end

          private

          def any_sprites?
            return false if @ppu.sprite_buffer.empty?
            return false unless @ppu.registers.lcdc.obj_enabled?
            return false unless @lcd_x >= @ppu.sprite_buffer.first.x_screen_pos

            true
          end

          def sprite_offscreen?(sprite)
            sprite.x < 0 || sprite.x >= 168 # @lcd_x stops at 160
          end

          def window_reached?
            return false if @bg_win_fetcher.fetch_mode == :window
            return false unless @ppu.wy_eq_ly
            return false unless @ppu.registers.lcdc.window_enabled?
            return false unless @lcd_x == @ppu.registers.wx - 7

            true
          end
        end
      end
    end
  end
end
