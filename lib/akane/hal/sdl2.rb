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

      attr_accessor :joypad

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
          case type
          when LCD::QUIT
            shutdown
            exit
          end
        end

        keyboard_state = LCD.get_keyboard_state(nil)

        if keyboard_state.get_uint8(LCD::SCANCODE_UP) == 0
          joypad.release_dpad(:up)
        else
          joypad.press_dpad(:up)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_DOWN) == 0
          joypad.release_dpad(:down)
        else
          joypad.press_dpad(:down)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_RIGHT) == 0
          joypad.release_dpad(:right)
        else
          joypad.press_dpad(:right)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_LEFT) == 0
          joypad.release_dpad(:left)
        else
          joypad.press_dpad(:left)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_Z) == 0
          joypad.release_face(:a)
        else
          joypad.press_face(:a)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_X) == 0
          joypad.release_face(:b)
        else
          joypad.press_face(:b)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_RETURN) == 0
          joypad.release_face(:start)
        else
          joypad.press_face(:start)
        end

        if keyboard_state.get_uint8(LCD::SCANCODE_RSHIFT) == 0
          joypad.release_face(:select)
        else
          joypad.press_face(:select)
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
