# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Ppu
      module Modes
        class Rendering
          # Responsible for emitting pixels from the Pixel FIFO to the Display.
          class PixelEmitter
            PIXELS_PER_SCANLINE = 160

            def initialize(ppu, bg_win_fifo, sprite_fifo)
              @ppu = ppu
              @bg_win_fifo = bg_win_fifo
              @sprite_fifo = sprite_fifo

              @pixels_discarded = 0
              @pixels_emitted = 0
            end

            # Called each T-cycle.
            def tick?
              return false if @bg_win_fifo.empty?
              return false unless @pixels_emitted < PIXELS_PER_SCANLINE

              @popped_sprite_pixel = @sprite_fifo.pop_pixel
              @popped_bg_win_pixel = @bg_win_fifo.pop_pixel

              shaded_priority_pixel = define_pixel_priority

              # TODO: Implement framebuffer fixed size [lcd_y * width + lcd_x]
              @ppu.framebuffer << shaded_priority_pixel
              @pixels_emitted += 1

              true
            end

            def reset_for_scanline
              @pixels_emitted = 0
              @pixels_discarded = 0
            end

            def to_s
              "BG WIN FIFO: #{@bg_win_fifo.pixels} | " \
                "Popped: #{@popped_pixel} (##{format('%d', @pixels_discarded)})"
            end

            private

            def define_pixel_priority
              return shaded_sprite_pixel if show_sprite?

              shaded_bg_pixel
            end

            def show_sprite?
              return false unless @ppu.registers.lcdc.obj_enabled?
              return false if @popped_sprite_pixel.nil?
              return false if (@popped_sprite_pixel & 0b11) == 0b00
              return false if ((@popped_sprite_pixel & 0b1000) != 0) && (@popped_bg_win_pixel != 0b00)

              true
            end

            def shaded_sprite_pixel
              if (@popped_sprite_pixel & 0b100) == 0
                @ppu.registers.sprite_palettes0[@popped_sprite_pixel & 0b11]
              else
                @ppu.registers.sprite_palettes1[@popped_sprite_pixel & 0b11]
              end
            end

            def shaded_bg_pixel
              return 0b00 unless @ppu.registers.lcdc.bg_win_enabled?

              @ppu.registers.bg_palettes[@popped_bg_win_pixel]
            end
          end
        end
      end
    end
  end
end
