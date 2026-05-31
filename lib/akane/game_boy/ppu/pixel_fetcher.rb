# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel Fetcher from the original Game Boy (DMG).
      class PixelFetcher
        def initialize(ppu, vram)
          @ppu = ppu
          @vram = vram

          @fetcher_x = 0
          @fetcher_y = @ppu.registers.ly
          @state = :get_tile_index
          @dots = 0
          @action = 'Getting tile index'
        end

        def tick
          case @state
          when :get_tile_index
            tile_map = @ppu.bg_tile_map
            @tile_index = tile_map.tile_index(tile_x: @fetcher_x, tile_y: @fetcher_y)
            @dots += 1

            if @dots == 2
              @action = 'Getting tile data low'
              @state = :get_tile_data_low
            end
          when :get_tile_data_low
            tile = @vram.tile(@tile_index)
            @tile_data_low = tile.data_low
            @dots += 1

            if @dots == 4
              @action = 'Getting tile data high'
              @state = :get_tile_data_high
            end
          when :get_tile_data_high
            tile = @vram.tile(@tile_index)
            @tile_data_low = tile.data_low
            @dots += 1

            if @dots == 6
              @action = 'Going to sleep'
              @state = :sleep
            end
          when :sleep
            @dots += 1

            if @dots == 8
              @action = 'Pushing pixels to the fifo'
              @state = :pushing_pixels
            end
          end
        end

        def to_s
          @action
        end
      end
    end
  end
end
