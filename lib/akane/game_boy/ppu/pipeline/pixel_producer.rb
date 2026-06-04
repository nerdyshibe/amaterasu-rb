# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for filling up the Pixel FIFO.
        class PixelProducer
          attr_reader :tile_fetcher

          def initialize(ppu, tile_fetcher, bg_win_fifo, sprite_fifo)
            @ppu = ppu
            @tile_fetcher = tile_fetcher
            @bg_win_fifo = bg_win_fifo
            @sprite_fifo = sprite_fifo

            @tile_index = nil
            @tile_data_low = nil
            @tile_data_high = nil
            @tile_pixels = nil

            @state = :get_tile_index
            @warming_up = true
            @sleep_duration = 2
            @retry_attempts = 2
          end

          def tick
            case @state
            when :get_tile_index
              @tile_index = @tile_fetcher.get_tile_index

              @state = :get_tile_data_low unless @tile_index.nil?
            when :get_tile_data_low
              @tile_data_low = @tile_fetcher.get_tile_data_low(@tile_index)

              @state = :get_tile_data_high unless @tile_data_low.nil?
            when :get_tile_data_high
              @tile_data_high = @tile_fetcher.get_tile_data_high(@tile_index)

              unless @tile_data_high.nil?
                @tile_pixels = @tile_fetcher.get_tile_pixels(
                  @tile_index,
                  @tile_data_low,
                  @tile_data_high
                )

                @warming_up ? discard_pixels : attempt_to_push_pixels
              end
            when :retry_push
              attempt_to_push_pixels
              @retry_attempts -= 1
              next_cycle if @retry_attempts.zero?
            when :sleep
              @sleep_duration -= 1
              next_cycle if @sleep_duration.zero?
            end
          end

          # Hardware quirk: The initial Tile fetched pixels are discarded.
          def discard_pixels
            @warming_up = false
            @state = :get_tile_index
            reset_tile
          end

          def attempt_to_push_pixels
            push_successful = @bg_win_fifo.push?(@tile_pixels)

            if push_successful
              @tile_pixels = nil
              @state = :sleep
            else
              @state = :retry_push
            end
          end

          # Normal cycle reset.
          def reset_cycle
            @state = :get_tile_index
            reset_tile
            restart_counts
          end

          # Normal cycle reset + Advances the tile count.
          def next_cycle
            reset_cycle
            @tile_fetcher.bg_fetcher_x += 1
          end

          # To be used after each scanline.
          def reset_for_scanline
            reset_cycle
            @warming_up = true
            @tile_fetcher.bg_fetcher_x = 0
          end

          def reset_tile
            @tile_index = nil
            @tile_data_low = nil
            @tile_data_high = nil
            @tile_pixels = nil
          end

          def restart_counts
            @sleep_duration = 2
            @retry_attempts = 2
          end

          def to_s
            "\n\tProducing #{@tile_fetcher.current_mode.upcase} Pixels " \
              "Step: #{@state} | " \
              "Tile Index: #{@tile_index} | " \
              "Tile Data Low: #{@tile_data_low} | " \
              "Tile Data High: #{@tile_data_high} | " \
              "Sleep: #{@sleep_duration} | " \
              "Retries: #{@retry_attempts} | "
          end
        end
      end
    end
  end
end
