# frozen_string_literal: true

module Akane
  module Utils
    # Bit Operation utility module.
    module BitOps
      module_function

      def set_bit(value, pos)
        value | (1 << pos)
      end

      def clear_bit(value, pos)
        value & ~(1 << pos)
      end

      def bit(value, pos)
        (value >> pos) & 1
      end
    end
  end
end
