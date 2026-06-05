# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for fetching Background and Window tiles,
        # decoding the pixels and outputting them into the BG/WIN FIFO.
        #
        # Despite the similarity it behaves differently than the SpriteFetcher.
        class BgWinFetcher
          def initialize(ppu, bg_win_fifo)
            @ppu = ppu
            @bg_win_fifo = bg_win_fifo

            @step = :fetch_tile_index
            @action = 'Fetch IDX'
            @bg_fetcher_x = 0

            @fetch_duration = 6
            @sleep_duration = 2
            @retry_attempts = 2 # confirm
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

          def reset_for_scanline
            reset_cycle
            @warming_up = true
            @bg_fetcher_x = 0
          end

          private

          # Fetches the BG Tile index at the current Tile map.
          def fetch_tile_index
            @fetch_duration -= 1
            return unless @fetch_duration == 4

            @tile_index = current_tile_map.tile_index_at(
              tile_x: current_bg_tile_x,
              tile_y: current_bg_tile_y
            )

            @step = :fetch_tile_data_low
            @action = 'Fetch DL'
          end

          # Fetches the BG Tile low byte.
          def fetch_tile_data_low
            @fetch_duration -= 1
            return unless @fetch_duration == 2

            @tile_data_low = current_tile_data.tile_at(@tile_index).data_low(current_bg_y)

            @step = :fetch_tile_data_high
            @action = 'Fetch DH'
          end

          # Fetches the BG Tile high byte.
          def fetch_tile_data_high
            @fetch_duration -= 1
            return unless @fetch_duration == 0

            @tile_data_high = current_tile_data.tile_at(@tile_index).data_high(current_bg_y)
            fetch_tile_pixels
            @warming_up ? discard_pixels : attempt_push_into_fifo
          end

          # Fetches the BG Tile pixels.
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

            @step =
              if push_successful
                @bg_fetcher_x += 1
                :sleep
              else
                :push
              end
          end

          def push
            attempt_push_into_fifo
            @retry_attempts -= 1
            reset_cycle if @retry_attempts == 0
          end

          def sleep
            @sleep_duration -= 1
            reset_cycle if @sleep_duration == 0
          end

          def reset_cycle
            @step = :fetch_tile_index
            @action = 'Fetch IDX'
            @fetch_duration = 6
            @sleep_duration = 2
            @retry_attempts = 2
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
            (@ppu.registers.ly + @ppu.registers.scy) / Vram::Tile::PIXEL_HEIGHT
          end

          # @return [Vram::TileMap]
          def current_tile_map
            @ppu.bg_tile_map
          end

          # @return [Vram::TileData]
          def current_tile_data
            @ppu.bg_win_tile_data
          end

          def to_s
            "Step: #{format('%-10s', @action)} | " \
              "IDX: #{@tile_index.nil? ? 'Nil' : format('%02X', @tile_index)} | " \
              "DL: #{@tile_data_low.nil? ? 'Nil' : format('%02X', @tile_data_low)} | " \
              "DH: #{@tile_data_high.nil? ? 'Nil' : format('%02X', @tile_data_high)} | " \
              "PIX: #{@tile_pixels}"
          end
        end
      end
    end
  end
end
