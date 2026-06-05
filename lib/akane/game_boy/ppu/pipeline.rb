# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Responsible for orchestrating the PPU Rendering Pipeline.
      class Pipeline
        attr_reader :tile_fetcher,
                    :bg_win_fetcher,
                    :sprite_fetcher,
                    :pixel_producer,
                    :pixel_consumer,
                    :mode

        def initialize(ppu)
          @ppu = ppu

          @bg_win_fifo    = PixelFifo.new
          @sprite_fifo    = PixelFifo.new
          @tile_fetcher   = TileFetcher.new(ppu)
          @pixel_producer = PixelProducer.new(ppu, @tile_fetcher, @bg_win_fifo, @sprite_fifo)
          @pixel_consumer = PixelConsumer.new(self, ppu, @bg_win_fifo, @sprite_fifo)

          @bg_win_fetcher = BgWinFetcher.new(ppu, @bg_win_fifo)
          @sprite_fetcher = SpriteFetcher.new(ppu, @sprite_fifo)

          @mode = :bg_win
          @lcd_x = 0
        end

        def tick
          # sprite <-> bg logic
          @mode = :sprite if any_sprites_this_x?

          if @mode == :sprite
            @sprite_fetcher.tick
            @mode = :bg_win if @sprite_fetcher.done?
          else
            @bg_win_fetcher.tick
            @pixel_consumer.tick
            @lcd_x += 1
          end
        end

        def any_sprites_this_x?
          return false if @ppu.sprite_buffer.empty?
          return false unless @lcd_x == @ppu.sprite_buffer.first.x_screen_pos

          true
        end
      end
    end
  end
end
