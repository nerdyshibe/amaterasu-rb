# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for filling up the Pixel FIFO.
        class PixelProducer
          def initialize(ppu:)
            @ppu = ppu

            @bg_fetcher_x = 0
            @window_fetcher_x = 0
            @window_fetcher_y = 0
            @state = :get_tile_index
            @dots = 0
            @mode = :bg
            @pixels_pushed = false
            @tile_row_pixels = Array.new
            @warming_up = true
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
              @current_y = @ppu.registers.ly + @ppu.registers.scy
              @tile_row = @ppu.bg_win_tile_data.tile_row(
                @tile_index,
                @current_y
              )

              @tile_data_low = @tile_row[:low_byte]

              @dots += 1
              @state = :get_tile_data_high if @dots == 4
            when :get_tile_data_high
              @tile_data_high = @tile_row[:high_byte]

              @dots += 1
              if @dots == 6
                @warming_up ? discard_pixels : attempt_to_push_pixels
              end
            when :pushing_pixels
              attempt_to_push_pixels

              @dots += 1
            when :sleep
              @dots += 1
              reset_cycle if @dots == 8
            end
          end

          def attempt_to_push_pixels
            if @warming_up
              discard_pixels
              return
            end

            @pixels_pushed = @ppu.bg_win_fifo.push?(@tile_row[:pixels])
            @state = :pushing_pixels
            return unless @pixels_pushed

            @state = :sleep
          end

          # Hardware quirk: The initial Tile fetched pixels are discarded.
          def discard_pixels
            @dots = 0
            @state = :get_tile_index
            @tile_row_pixels.clear
            @warming_up = false
          end

          def reset_cycle
            @dots = 0
            @bg_fetcher_x += 1
            @state = :get_tile_index
            @tile_row_pixels.clear
          end

          def reset_progress
            reset_cycle
            @bg_fetcher_x = 0
            @warming_up = true
          end

          def to_s
            if @mode == :bg
              "#{@mode} " \
                "#{@state} " \
                "AT BG_X: #{@bg_fetcher_x} " \
                "(##{@dots})"
            else
              "#{@mode.upcase} MODE: #{@state.upcase} AT W_X: #{@window_fetcher_x} (##{@dots})"
            end
          end
        end
      end
    end
  end
end
