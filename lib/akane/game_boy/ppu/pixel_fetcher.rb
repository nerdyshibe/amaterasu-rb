# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel Fetcher from the original Game Boy (DMG).
      class PixelFetcher
        def initialize(ppu, vram)
          @ppu = ppu
          @vram = vram

          @ly = @ppu.registers.ly
          @scx = @ppu.registers.scx
          @scy = @ppu.registers.scy
          @shades = @ppu.shades

          @bg_fetcher_x = 0
          @window_fetcher_x = 0
          @window_fetcher_y = 0
          @state = :get_tile_index
          @dots = 0
          @mode = :bg
          @tile_pixels = Array.new
          @pixels_decoded = false
        end

        def tick
          case @state
          when :get_tile_index
            tile_map = @mode == :bg ? @ppu.bg_tile_map : @ppu.window_tile_map

            if @mode == :bg
              current_x = (@scx / 8) + @bg_fetcher_x
              current_y = (@ly + @scy) / 8
            else
              current_x = @window_fetcher_x
              current_y = @window_fetcher_y / 8
            end

            @tile_index = tile_map.tile_index(
              tile_x: current_x,
              tile_y: current_y
            )

            @state = :get_tile_data_low if @dots == 1
          when :get_tile_data_low
            tile_data = @ppu.bg_win_tile_data
            @tile_data_low = tile_data.low_byte(@tile_index)

            @state = :get_tile_data_high if @dots == 3
          when :get_tile_data_high
            tile_data = @ppu.bg_win_tile_data
            @tile_data_high = tile_data.high_byte(@tile_index)

            @state = :sleep if @dots == 5
          when :sleep
            @state = :pushing_pixels if @dots == 7
          when :pushing_pixels
            decode_pixels unless @pixels_decoded

            if @ppu.bg_win_fifo.push?(@tile_pixels)
              @bg_fetcher_x += 1
              @state = :get_tile_index
              @tile_pixels.clear
              @pixels_decoded = false
            end
          end

          @dots += 1
        end

        def decode_pixels
          bit = 7

          while bit >= 0
            low_bit = (@tile_data_low >> bit) & 1
            high_bit = (@tile_data_high >> bit) & 1
            color_id = high_bit | low_bit
            @tile_pixels << @shades[color_id]
            bit -= 1
          end

          @pixels_decoded = true
        end

        def to_s
          "#{@state.upcase} ##{@dots}"
        end
      end
    end
  end
end
