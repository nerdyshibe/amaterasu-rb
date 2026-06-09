# frozen_string_literal: true

require_relative '../../lib/akane'

def build_ppu
  vram = Akane::GameBoy::Vram.new
  oam  = Akane::GameBoy::Oam.new
  interrupts = Akane::GameBoy::Interrupts.new

  Akane::GameBoy::Ppu.new(vram, oam, nil, interrupts, trace_ppu: false)
end
