# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the PPU behavior from the Game Boy.
    class Ppu
      def initialize(interrupts)
        @interrupts = interrupts

        @vram = Ram.new(8_192)
        @oam = Ram.new(160)
      end

      # Returns a 8-bit value stored in VRAM in a given offset.
      def read_vram(offset)
        @vram.read_byte(offset)
      end

      # Stores a 8-bit value in VRAM in a given offset.
      def write_vram(offset, value)
        @vram.write_byte(offset, value)
      end

      # Returns a 8-bit value stored in OAM in a given offset.
      def read_oam(offset)
        @oam.read_byte(offset)
      end

      # Stores a 8-bit value in OAM in a given offset.
      def write_oam(offset, value)
        @oam.write_byte(offset, value)
      end
    end
  end
end
