# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Responsible for orchestrating the PPU Rendering Pipeline.
      class Pipeline
        def initialize(ppu)
          @ppu = ppu

          @bg_win_fifo   = PixelFifo.new
          @sprite_fifo   = PixelFifo.new
          @pixel_fetcher = PixelProducer.new(ppu)
          @pixel_emitter = PixelConsumer.new(ppu)
        end

        def tick
          @pixel_fetcher.tick
          @pixel_emitter.tick
        end
      end
    end
  end
end
