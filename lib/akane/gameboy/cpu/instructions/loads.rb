# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      module Instructions
        module Loads
          private

          def load_a_n8
            @registers.a = fetch_byte
          end

          def load_b_n8
            @registers.b = fetch_byte
          end

          def load_b_d
            @registers.b = @registers.d
          end
        end
      end
    end
  end
end
