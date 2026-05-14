# frozen_string_literal: true

module Akane
  module Utils
    # Bit Operation utility module.
    module BitOperations
      refine Integer do
        def set_bit(pos) # rubocop:disable Naming/AccessorMethodName
          self | (1 << pos)
        end

        def clear_bit(pos)
          self & ~(1 << pos)
        end

        def bit(pos)
          (self >> pos) & 1
        end
      end
    end
  end
end
