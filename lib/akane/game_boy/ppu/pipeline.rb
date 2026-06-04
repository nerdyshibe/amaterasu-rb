# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Responsible for orchestrating the PPU Rendering Pipeline.
      class Pipeline
        attr_reader :tile_fetcher, :pixel_producer, :pixel_consumer

        def initialize(ppu)
          @ppu = ppu

          @bg_win_fifo    = PixelFifo.new
          @sprite_fifo    = PixelFifo.new
          @tile_fetcher   = TileFetcher.new(ppu)
          @pixel_producer = PixelProducer.new(ppu, @tile_fetcher, @bg_win_fifo, @sprite_fifo)
          @pixel_consumer = PixelConsumer.new(self, ppu, @bg_win_fifo, @sprite_fifo)
        end

        def pixel_within_scanline
          @pixel_consumer.pixels_emitted
        end

        def current_scanline
          @ppu.registers.ly
        end

        def tile_within_scanline
          @pixel_producer.tile_fetcher.bg_fetcher_x
        end

        def current_bg_pixel_y
          @ppu.registers.ly + @ppu.registers.scy
        end
      end
    end
  end
end
