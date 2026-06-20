# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Ppu
      module Modes
        class Rendering
          # Responsible for fetching Sprites tiles, decoding Sprite pixels
          # and outputting them into the Sprite FIFO.
          class SpriteFetcher
            SpritePixel = Struct.new(:bg_win_priority_set, :use_obp1_palette, :color_id)

            BIT_MASK_BG_WIN_PRIORITY_SET = 1 << 3
            BIT_MASK_USE_OBP1_PALETTE    = 1 << 2

            def initialize(ppu, sprite_fifo)
              @ppu = ppu
              @sprite_fifo = sprite_fifo

              @step = :fetch_tile_index
              @completed = false
              @fetch_duration = 6

              @current_sprite = nil

              @tile_index     = nil
              @tile_data_low  = nil
              @tile_data_high = nil
              @tile_pixels    = nil
              @encoded_pixels = Array.new(8)
            end

            def start_for(sprite)
              @current_sprite = sprite
              @step = :fetch_tile_index
              @completed = false
              @fetch_duration = 6
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
              @fetch_duration -= 1
              return unless @fetch_duration == 4

              obj_size_8x16 = @ppu.registers.lcdc.obj_size_8x16?
              y_flipped = @current_sprite.y_flipped?

              @tile_index = @current_sprite.tile_index(obj_size_8x16, y_flipped, current_obj_y)
              @step = :fetch_tile_data_low
            end

            # Fetches the low byte from the Tile Row overlapping the current LY.
            def fetch_tile_data_low
              @fetch_duration -= 1
              return unless @fetch_duration == 2

              obj_y = @current_sprite.y_flipped? ? (7 - current_obj_y) : current_obj_y
              @tile_data_low = obj_tile_data.tile_at(@tile_index).data_low(obj_y)
              @step = :fetch_tile_data_high
            end

            # Fetches the high byte from the Tile Row overlapping the current LY.
            def fetch_tile_data_high
              @fetch_duration -= 1
              return unless @fetch_duration == 0

              obj_y = @current_sprite.y_flipped? ? (7 - current_obj_y) : current_obj_y
              @tile_data_high = obj_tile_data.tile_at(@tile_index).data_high(obj_y)
              fetch_tile_pixels
              add_pixel_metadata
              merge_into_fifo
            end

            # @return [Array] Decodes 8 pixel color ids from the high | low bytes.
            def fetch_tile_pixels
              @tile_pixels = Vram::Tile::PIXELS_LOOKUP[(@tile_data_high << 8) | @tile_data_low]
            end

            # Encodes the current OBP color palette and BG/WIN priority into the pixel.
            # This data would be lost downstream (when rendering the pixels to the LCD)
            # if not encoded in this step.
            #
            # @return [void]
            def add_pixel_metadata
              idx = 0

              while idx < 8
                pixel = @tile_pixels[idx]
                pixel = BIT_MASK_BG_WIN_PRIORITY_SET | pixel if @current_sprite.bg_win_priority_set?
                pixel = BIT_MASK_USE_OBP1_PALETTE | pixel if @current_sprite.use_obp1_palette?
                @encoded_pixels[idx] = pixel

                idx += 1
              end
            end

            # Merges the 8 pixels into the Sprite FIFO.
            def merge_into_fifo
              @encoded_pixels.reverse! if @current_sprite.x_flipped?
              @sprite_fifo.merge(@encoded_pixels)
              @completed = true
            end

            def current_obj_y
              @ppu.registers.ly - @current_sprite.y_screen_pos
            end

            def obj_tile_data
              @ppu.obj_tile_data
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
end
