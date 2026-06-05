# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Responsible for orchestrating the PPU Rendering Pipeline.
      class Pipeline
        attr_accessor :lcd_x
        attr_reader :bg_win_fetcher,
                    :sprite_fetcher,
                    :pixel_consumer,
                    :mode

        def initialize(ppu)
          @ppu = ppu

          @bg_win_fifo    = PixelFifo.new
          @sprite_fifo    = PixelFifo.new

          @bg_win_fetcher = BgWinFetcher.new(ppu, @bg_win_fifo)
          @sprite_fetcher = SpriteFetcher.new(ppu, @sprite_fifo)
          @pixel_emitter  = PixelEmitter.new(self, ppu, @bg_win_fifo, @sprite_fifo)

          @sprite_found = nil
          @mode = :fetch_bg
          @lcd_x = 0
        end

        # TODO: Implement fine scroll logic @scx & 7
        # TODO: Implement BG handoff after the current cycle finishes
        def tick
          if any_sprites? && @mode != :fetch_sprite
            @mode = :fetch_sprite
            @sprite_found = @ppu.sprite_buffer.shift
            @sprite_fetcher.start_for(@sprite_found) unless sprite_offscreen?(@sprite_found)
          elsif @mode == :fetch_sprite
            @sprite_fetcher.tick
            @mode = :fetch_bg if @sprite_fetcher.done?
          else
            @bg_win_fetcher.tick
            @pixel_emitter.tick
          end
        end

        # Need to handle sprites with X < 0
        def any_sprites?
          return false if @ppu.sprite_buffer.empty?
          return false unless @ppu.registers.lcdc.obj_enabled?
          return false unless @lcd_x >= @ppu.sprite_buffer.first.x_screen_pos

          true
        end

        def sprite_offscreen?(sprite)
          sprite.x < 0 || sprite.x >= 168 # @lcd_x stops at 160
        end
      end
    end
  end
end
