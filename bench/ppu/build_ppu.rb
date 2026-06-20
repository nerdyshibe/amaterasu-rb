# frozen_string_literal: true

require_relative '../../lib/amaterasu'

def build_ppu
  vram = Amaterasu::GameBoy::Vram.new
  oam  = Amaterasu::GameBoy::Oam.new
  interrupts = Amaterasu::GameBoy::Interrupts.new

  Amaterasu::GameBoy::Ppu.new(vram, oam, nil, interrupts, trace_ppu: false)
end
