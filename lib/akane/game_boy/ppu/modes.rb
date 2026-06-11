# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Instantiates the PPU mode objects that are going to be used.
      module Modes
        def self.build_hash(ppu)
          @modes = Hash.new

          @modes[:disabled]  = Disabled.new(ppu)
          @modes[:h_blank]   = HBlank.new(ppu)
          @modes[:v_blank]   = VBlank.new(ppu)
          @modes[:oam_scan]  = OamScan.new(ppu)
          @modes[:rendering] = Rendering.new(ppu)

          @modes.freeze
        end
      end
    end
  end
end
