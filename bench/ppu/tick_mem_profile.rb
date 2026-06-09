# frozen_string_literal: true

require 'memory_profiler'

require_relative 'build_ppu'

ppu = build_ppu

_pixels = Akane::GameBoy::Vram::Tile::PIXELS_LOOKUP

report = MemoryProfiler.report do
  15_000_000.times { ppu.tick }
end

report.pretty_print
