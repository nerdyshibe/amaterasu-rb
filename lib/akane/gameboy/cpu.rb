# frozen_string_literal: true

module Akane
  module Gameboy
    class Cpu
      def initialize
        @registers = Cpu::Registers.new
        @ime = false
      end
    end
  end
end
