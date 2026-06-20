# frozen_string_literal: true

require 'ffi'

module Amaterasu
  module HAL
    class SDL2
      # Implement all SDL2 bindings needed.
      module Bindings
        extend FFI::Library

        ffi_lib 'SDL2'

        INIT_VIDEO              = 0x00000020
        WINDOWPOS_CENTERED      = 0x2FFF0000
        WINDOW_SHOWN            = 0x00000004
        PIXELFORMAT_ARGB8888    = 0x16362004
        TEXTUREACCESS_STREAMING = 1
        RENDERER_ACCELERATED    = 0x00000002
        QUIT                    = 0x100
        EVENT_SIZE              = 56

        SCANCODE_UP    = 82
        SCANCODE_DOWN  = 81
        SCANCODE_LEFT  = 80
        SCANCODE_RIGHT = 79

        SCANCODE_Z = 29
        SCANCODE_X = 27
        SCANCODE_RETURN = 40
        SCANCODE_RSHIFT = 229

        attach_function :init, :SDL_Init, [:uint32], :int
        attach_function :quit, :SDL_Quit, [], :void
        attach_function :get_error, :SDL_GetError, [], :string

        attach_function :create_window, :SDL_CreateWindow, %i[string int int int int uint32], :pointer
        attach_function :set_window_title, :SDL_SetWindowTitle, %i[pointer string], :void
        attach_function :destroy_window, :SDL_DestroyWindow, [:pointer], :void

        attach_function :create_renderer, :SDL_CreateRenderer, %i[pointer int uint32], :pointer
        attach_function :destroy_renderer, :SDL_DestroyRenderer, [:pointer], :void

        attach_function :create_texture, :SDL_CreateTexture, %i[pointer uint32 int int int], :pointer
        attach_function :update_texture, :SDL_UpdateTexture, %i[pointer pointer pointer int], :int
        attach_function :destroy_texture, :SDL_DestroyTexture, [:pointer], :void

        attach_function :render_copy, :SDL_RenderCopy, %i[pointer pointer pointer pointer], :int
        attach_function :render_present, :SDL_RenderPresent, [:pointer], :void
        attach_function :render_clear, :SDL_RenderClear, [:pointer], :int

        attach_function :poll_event, :SDL_PollEvent, [:pointer], :int

        attach_function :get_keyboard_state, :SDL_GetKeyboardState, [:pointer], :pointer
        attach_function :pump_events, :SDL_PumpEvents, [], :void
      end
    end
  end
end
