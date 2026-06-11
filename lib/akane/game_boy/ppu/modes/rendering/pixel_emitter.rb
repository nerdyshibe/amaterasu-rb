# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      module Modes
        class Rendering
          # Responsible for emitting pixels from the Pixel FIFO to the Display.
          class PixelEmitter
            PIXELS_PER_SCANLINE = 160

            def initialize(rendering, ppu, bg_win_fifo, sprite_fifo)
              @rendering = rendering
              @ppu = ppu
              @bg_win_fifo = bg_win_fifo
              @sprite_fifo = sprite_fifo

              @state = :popping_pixels
              @sprite_encountered = nil
              @pixels_emitted = 0
            end

            # Called each T-cycle.
            def tick
              return if @bg_win_fifo.empty?

              @popped_sprite_pixel = @sprite_fifo.pop_pixel
              @popped_bg_win_pixel = @bg_win_fifo.pop_pixel

              shaded_priority_pixel = define_pixel_priority

              # TODO: Implement framebuffer fixed size [lcd_y * width + lcd_x]
              @ppu.framebuffer << shaded_priority_pixel
              @pixels_emitted += 1
              @rendering.lcd_x += 1
              return unless @pixels_emitted == PIXELS_PER_SCANLINE

              @pixels_emitted = 0
              @rendering.bg_win_fetcher.increment_window_y
              @rendering.bg_win_fetcher.reset_for_scanline
              @rendering.lcd_x = 0
              @sprite_fifo.clear
              @bg_win_fifo.clear
              @ppu.set_mode(:h_blank) # remove from here
            end

            def define_pixel_priority
              return shaded_sprite_pixel if show_sprite?

              shaded_bg_pixel
            end

            def show_sprite?
              return false unless @ppu.registers.lcdc.obj_enabled?
              return false if @popped_sprite_pixel.nil?
              return false if @popped_sprite_pixel.color_id == 0b00
              return false if @popped_sprite_pixel.bg_win_priority_set && (@popped_bg_win_pixel != 0b00)

              true
            end

            def shaded_sprite_pixel
              if @popped_sprite_pixel.use_obp1_palette
                @ppu.registers.sprite_palettes1[@popped_sprite_pixel.color_id]
              else
                @ppu.registers.sprite_palettes0[@popped_sprite_pixel.color_id]
              end
            end

            def shaded_bg_pixel
              return 0b00 unless @ppu.registers.lcdc.bg_win_enabled?

              @ppu.registers.bg_palettes[@popped_bg_win_pixel]
            end

            def to_s
              "BG WIN FIFO: #{@bg_win_fifo.pixels} | " \
                "Popped: #{@popped_pixel} (##{format('%03d', @pixels_emitted)})"
            end
          end
        end
      end
    end
  end
end
