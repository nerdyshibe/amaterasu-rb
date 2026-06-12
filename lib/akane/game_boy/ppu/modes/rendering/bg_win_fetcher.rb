# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        class Rendering
          # Responsible for fetching Background and Window tiles,
          # decoding the pixels and outputting them into the BG/WIN FIFO.
          #
          # Despite the similarity it behaves differently than the SpriteFetcher.
          class BgWinFetcher
            attr_reader :fetch_mode, :step

            def initialize(ppu, bg_win_fifo)
              @ppu = ppu
              @bg_win_fifo = bg_win_fifo

              @step = :fetch_tile_index
              @bg_fetcher_x = 0
              @window_fetcher_x = 0
              @fetch_mode = :bg

              @fetch_duration = 6
              @sleep_duration = 2
              @warming_up     = true

              @tile_index     = nil
              @tile_data_low  = nil
              @tile_data_high = nil
              @tile_pixels    = nil
            end

            # Core fetch state machine.
            #
            def tick
              case @step
              when :fetch_tile_index     then fetch_tile_index
              when :fetch_tile_data_low  then fetch_tile_data_low
              when :fetch_tile_data_high then fetch_tile_data_high
              when :push  then push
              when :sleep then sleep
              end
            end

            def activate_window!
              @bg_win_fifo.clear
              @fetch_mode = :window
              reset_cycle
            end

            def increment_window_y
              return unless @window_drawed

              @ppu.window_y_count += 1
              @window_drawed = false
            end

            def reset_for_scanline
              reset_cycle
              @fetch_mode = :bg
              @warming_up = true
              @bg_fetcher_x = 0
              @window_fetcher_x = 0
              increment_window_y
            end

            private

            # Fetches the BG Tile index at the current Tile map.
            def fetch_tile_index
              @fetch_duration -= 1
              return unless @fetch_duration == 4

              tile_x = @fetch_mode == :bg ? current_bg_tile_x : current_window_tile_x
              tile_y = @fetch_mode == :bg ? current_bg_tile_y : current_window_tile_y

              @tile_index = current_tile_map.tile_index_at(
                tile_x: tile_x,
                tile_y: tile_y
              )

              @step = :fetch_tile_data_low
            end

            # Fetches the low byte of the BG or Window Tile Row
            # that overlaps with the current row/line being drawn.
            def fetch_tile_data_low
              @fetch_duration -= 1
              return unless @fetch_duration == 2

              current_y = @fetch_mode == :bg ? current_bg_y : current_window_y
              @tile_data_low = current_tile_data.tile_at(@tile_index).data_low(current_y)

              @step = :fetch_tile_data_high
            end

            # Fetches the high byte of the BG or Window Tile Row
            # that overlaps with the current row/line being drawn.
            def fetch_tile_data_high
              @fetch_duration -= 1
              return unless @fetch_duration == 0

              current_y = @fetch_mode == :bg ? current_bg_y : current_window_y
              @tile_data_high = current_tile_data.tile_at(@tile_index).data_high(current_y)
              fetch_tile_pixels
              @warming_up ? discard_pixels : attempt_push_into_fifo
            end

            # Fetches the BG or Window Tile pixels.
            def fetch_tile_pixels
              @tile_pixels = Vram::Tile::PIXELS_LOOKUP[(@tile_data_high << 8) | @tile_data_low]
            end

            def discard_pixels
              @tile_pixels = nil
              @warming_up = false
              reset_cycle
            end

            def attempt_push_into_fifo
              push_successful = @bg_win_fifo.push?(@tile_pixels)

              if push_successful
                if @fetch_mode == :bg
                  @bg_fetcher_x += 1
                else
                  @window_fetcher_x += 1
                  @window_drawed = true
                end

                @step = :sleep
              else
                @step = :push
              end
            end

            def push
              push_successful = @bg_win_fifo.push?(@tile_pixels)
              return unless push_successful

              reset_cycle
            end

            def sleep
              @sleep_duration -= 1
              reset_cycle if @sleep_duration == 0
            end

            def reset_cycle
              @step = :fetch_tile_index
              @fetch_duration = 6
              @sleep_duration = 2
              @tile_index     = nil
              @tile_data_low  = nil
              @tile_data_high = nil
              @tile_pixels    = nil
            end

            def current_bg_y
              @ppu.registers.ly + @ppu.registers.scy
            end

            def current_bg_tile_x
              (@ppu.registers.scx / Vram::Tile::PIXEL_WIDTH) + @bg_fetcher_x
            end

            def current_bg_tile_y
              current_bg_y / Vram::Tile::PIXEL_HEIGHT
            end

            def current_window_y
              @ppu.window_y_count
            end

            def current_window_tile_x
              @window_fetcher_x
            end

            def current_window_tile_y
              @ppu.window_y_count / Vram::Tile::PIXEL_HEIGHT
            end

            # @return [Vram::TileMap]
            def current_tile_map
              @fetch_mode == :bg ? @ppu.bg_tile_map : @ppu.window_tile_map
            end

            # @return [Vram::TileData]
            def current_tile_data
              @ppu.bg_win_tile_data
            end

            def to_s
              "Mode: #{@fetch_mode.upcase} | " \
                "Step: #{@step.upcase} | " \
                "PIX: #{@tile_pixels}"
            end
          end
        end
      end
    end
  end
end
