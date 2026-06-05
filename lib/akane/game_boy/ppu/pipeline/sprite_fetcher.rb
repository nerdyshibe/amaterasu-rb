# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for fetching Sprites tiles, decoding Sprite pixels
        # and outputting them into the Sprite FIFO.
        class SpriteFetcher
          def initialize(ppu, sprite_fifo)
            @ppu = ppu
            @sprite_fifo = sprite_fifo

            @step = :fetch_tile_index
            @completed = false
            @duration = 6

            @current_sprite = nil

            @obj_tile_data  = @ppu.obj_tile_data
            @tile_index     = nil
            @tile_data_low  = nil
            @tile_data_high = nil
            @tile_pixels    = nil
          end

          def start_fetching(sprite)
            @current_sprite = sprite
            @step = :fetch_tile_index
            @completed = false
          end

          # Core fetch state machine (Takes 2 dots per step).
          #
          def tick
            case @step
            when :fetch_tile_index     then fetch_tile_index
            when :fetch_tile_data_low  then fetch_tile_data_low
            when :fetch_tile_data_high then fetch_tile_data_high
            end
          end

          def done?
            @completed
          end

          private

          # Fetches the Tile index of the current Sprite to be rendered.
          def fetch_tile_index
            @duration -= 1
            return unless @duration == 4

            @tile_index = @current_sprite.tile_index
            @step = :fetch_tile_data_low
          end

          # Fetches the low byte from the Tile Row overlapping the current LY.
          def fetch_tile_data_low
            @duration -= 1
            return unless @duration == 2

            @tile_data_low = @obj_tile_data.tile_at(@tile_index).data_low(current_ly)
            @step = :fetch_tile_data_low
          end

          # Fetches the high byte from the Tile Row overlapping the current LY.
          def fetch_tile_data_high
            @duration -= 1
            return unless @duration == 0

            @tile_data_high = @obj_tile_data.tile_at(@tile_index).data_high(current_ly)
            fetch_tile_pixels
            add_pixel_metadata
            merge_into_fifo
            reset_steps
          end

          # @return [Array] Decodes 8 pixel color ids from the high | low bytes.
          def fetch_tile_pixels
            @tile_pixels = Vram::Tile::PIXELS_LOOKUP[(@tile_data_high << 8) | @tile_data_low]
          end

          # Encodes the current OBP color palette and BG/WIN priority into the pixel.
          # This data would be lost downstream (when drawing the pixels to the LCD)
          # if not encoded in this step.
          def add_pixel_metadata
            idx = 0

            while idx < 8
              obp_palette = @current_sprite.palette_from_obp1? ? 1 : 0
              bg_win_priority = @current_sprite.bg_win_priority? ? 1 : 0
              @tile_pixels[idx] = (bg_win_priority << 3) | (obp_palette << 2) | @tile_pixels[idx]

              ids += 1
            end
          end

          # Merges the 8 pixels into the Sprite FIFO.
          def merge_into_fifo
            @tile_pixels.reverse! if @current_sprite.x_flipped?
            @sprite_fifo.merge(@tile_pixels)
            @completed = true
          end

          def reset_steps
            @step = :fetch_tile_index
            @duration = 6

            @current_sprite = nil

            @tile_index     = nil
            @tile_data_low  = nil
            @tile_data_high = nil
            @tile_pixels    = nil
          end

          def current_ly
            @ppu.registers.ly
          end

          def to_s
            "\n\tProducing Sprite Pixels " \
              "Step: #{@step} | " \
              "Tile Index: #{@tile_index} | " \
              "Tile Data Low: #{@tile_data_low} | " \
              "Tile Data High: #{@tile_data_high} | " \
              "Tile Pixels: #{@tile_pixels}"
          end
        end
      end
    end
  end
end
