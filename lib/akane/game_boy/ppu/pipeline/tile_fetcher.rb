# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      class Pipeline
        # Responsible for fetching tiles from VRAM during
        # PPU Mode 3 (Drawing), can fetch either Background
        # or Window tiles depending on what's being displayed.
        class TileFetcher
          TILE_PIXELS = 8

          attr_accessor :bg_fetcher_x, :current_sprite
          attr_reader :current_mode

          def initialize(ppu)
            @ppu = ppu

            @current_mode     = :bg
            @bg_fetcher_x     = 0
            @window_fetcher_x = 0
            @window_fetcher_y = 0
            @current_sprite   = nil
          end

          def get_tile_index
            return if @ppu.dots.odd?

            if @current_mode == :sprite
              sprite = @ppu.sprite_buffer.shift
              return sprite.tile_index
            end

            current_tile_map.tile_index_at(
              tile_x: current_tile_x,
              tile_y: current_tile_y
            )
          end

          def get_tile_data_low(index)
            return if @ppu.dots.odd?

            current_tile_data
              .tile_at(index)
              .data_low(current_pixel_y)
          end

          def get_tile_data_high(index)
            return if @ppu.dots.odd?

            current_tile_data
              .tile_at(index)
              .data_high(current_pixel_y)
          end

          def get_tile_pixels(index, low_byte, high_byte)
            current_tile_data
              .tile_at(index)
              .pixel_row(low_byte, high_byte)
          end

          private

          # @return [Integer]
          def current_tile_x
            (@ppu.registers.scx / TILE_PIXELS) + @bg_fetcher_x
          end

          # @return [Integer]
          def current_tile_y
            (@ppu.registers.ly + @ppu.registers.scy) / TILE_PIXELS
          end

          def current_pixel_y
            @ppu.registers.ly + @ppu.registers.scy
          end

          # @return [Vram::TileMap]
          def current_tile_map
            return @ppu.bg_tile_map if @current_mode == :bg

            @ppu.window_tile_map
          end

          # @return [Vram::TileData]
          def current_tile_data
            @ppu.bg_win_tile_data
          end
        end
      end
    end
  end
end
