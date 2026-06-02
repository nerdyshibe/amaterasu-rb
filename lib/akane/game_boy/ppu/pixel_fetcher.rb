# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the PPU Pixel Fetcher from the original Game Boy (DMG).
      class PixelFetcher
        def initialize(ppu:)
          @ppu = ppu

          @bg_fetcher_x = 0
          @window_fetcher_x = 0
          @window_fetcher_y = 0
          @state = :get_tile_index
          @dots = 0
          @mode = :bg
          @pixels_pushed = false
        end

        def tick
          case @state
          when :get_tile_index
            tile_map = @mode == :bg ? @ppu.bg_tile_map : @ppu.window_tile_map

            if @mode == :bg
              current_x = (@ppu.registers.scx / 8) + @bg_fetcher_x
              current_y = (@ppu.registers.ly + @ppu.registers.scy) / 8
            else
              current_x = @window_fetcher_x
              current_y = @window_fetcher_y / 8
            end

            @tile_index = tile_map.tile_index(
              tile_x: current_x,
              tile_y: current_y
            )

            @dots += 1
            @state = :get_tile_data_low if @dots == 2
          when :get_tile_data_low
            @tile = @ppu.bg_win_tile_data.tile(@tile_index)
            @current_y = (@ppu.registers.ly + @ppu.registers.scy) & 0b111

            @tile_data_low = @tile.data_low(@current_y)

            @dots += 1
            @state = :get_tile_data_high if @dots == 4
          when :get_tile_data_high
            @tile_data_high = @tile.data_high(@current_y)

            @dots += 1
            attempt_to_push_pixels if @dots == 6
          when :pushing_pixels
            attempt_to_push_pixels

            @dots += 1
          when :sleep
            @dots += 1
            reset_cycle if @dots == 8
          end
        end

        def attempt_to_push_pixels
          @pixels_pushed = @ppu.bg_win_fifo.push?(@tile.pixels)
          @state = :pushing_pixels
          return unless @pixels_pushed

          @bg_fetcher_x += 1
          @state = :sleep
        end

        def reset_cycle
          @dots = 0
          @state = :get_tile_index
          @pixels_decoded = false
          @pixels_pushed = false
        end

        def reset_progress
          reset_cycle
          @bg_fetcher_x = 0
        end

        def to_s
          if @mode == :bg
            "#{@mode.upcase} " \
              "#{@state.upcase} " \
              "AT BG_X: #{@bg_fetcher_x} " \
              "Tile Index: #{@tile_index} " \
              "Tile Data Low: #{@tile_data_low} " \
              "Tile Data High: #{@tile_data_high} " \
              "(##{@dots})"
          else
            "#{@mode.upcase} MODE: #{@state.upcase} AT W_X: #{@window_fetcher_x} (##{@dots})"
          end
        end
      end
    end
  end
end
