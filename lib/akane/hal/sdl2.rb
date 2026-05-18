# frozen_string_literal: true

require 'ffi'

module Akane
  module HAL
    class SDL2
      LCD = Bindings
      LCD_WIDTH  = 160
      LCD_HEIGHT = 144
      SCALE = 3

      PALETTE = [0xFFFFFFFF, 0xFFAAAAAA, 0xFF555555, 0xFF000000].freeze

      def initialize
        LCD.init(LCD::INIT_VIDEO)
        @window = LCD.create_window(
          'Akane',
          LCD::WINDOWPOS_CENTERED,
          LCD::WINDOWPOS_CENTERED,
          LCD_WIDTH * SCALE,
          LCD_HEIGHT * SCALE,
          LCD::WINDOW_SHOWN
        )
        @renderer = LCD.create_renderer(@window, -1, LCD::RENDERER_ACCELERATED)
        @texture = LCD.create_texture(
          @renderer,
          LCD::PIXELFORMAT_ARGB8888,
          LCD::TEXTUREACCESS_STREAMING,
          LCD_WIDTH,
          LCD_HEIGHT
        )

        @pixel_buffer = FFI::MemoryPointer.new(:uint32, LCD_WIDTH * LCD_HEIGHT)
        @event = FFI::MemoryPointer.new(:uint8, LCD::EVENT_SIZE)
        @frame_count = 0
        @fps_timer = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def draw(framebuffer)
        @pixel_buffer.write_array_of_uint32(framebuffer.map { |shade| PALETTE[shade] })
        LCD.update_texture(@texture, FFI::Pointer::NULL, @pixel_buffer, LCD_WIDTH * 4)
        LCD.render_copy(@renderer, @texture, FFI::Pointer::NULL, FFI::Pointer::NULL)
        LCD.render_present(@renderer)

        @frame_count += 1
        @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @fps_timer

        if @elapsed >= 1.0
          fps = @frame_count / @elapsed
          # LCD.set_window_title(@window, "Akane | FPS: #{fps.round(2)}")
          $stdout.print "\rFPS: #{fps.round(2)}  "
          $stdout.flush
        end

        while LCD.poll_event(@event) == 1
          # first 4 bytes of the event struct are the event type (uint32)
          type = @event.read_uint32
          if type == LCD::QUIT
            shutdown
            exit
          end
        end
      end

      def shutdown
        LCD.destroy_texture(@texture)
        LCD.destroy_renderer(@renderer)
        LCD.destroy_window(@window)
        LCD.quit
      end
    end
  end
end
