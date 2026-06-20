# frozen_string_literal: true

module Amaterasu
  module HAL
    # Console display renderer.
    class Console
      LCD_WIDTH  = 160
      LCD_HEIGHT = 144

      DOUBLE_CHAR = '▀'
      CONSOLE_CHARS = [' ', '░', '▒', '█'].freeze
      # CONSOLE_CHARS = [' ', ':', '#', '@'].freeze

      def initialize
        $stdout.print("\e[?1049h")
      end

      def shutdown
        $stdout.print("\e[?1049l")
      end
    end
  end
end
