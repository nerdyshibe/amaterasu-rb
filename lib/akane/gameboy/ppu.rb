# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the PPU behavior from the Game Boy.
    class Ppu
      attr_reader :lcdc, :stat, :scy, :scx
      attr_accessor :ly

      def initialize(interrupts)
        @interrupts = interrupts

        @vram = Ram.new(8192)
        @oam  = Ram.new(160)

        @lcdc = 0x00
        @stat = 0x00
        @scy  = 0x00
        @scx  = 0x00
        @ly   = 0x00
        @lyc  = 0x00

        @wy = 0x00
        @wx = 0x00
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

      def tick
        # l
      end
    end
  end
end
