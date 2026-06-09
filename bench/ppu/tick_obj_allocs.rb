# frozen_string_literal: true

require 'stackprof'

require_relative 'build_ppu'

ppu = build_ppu

StackProf.run(mode: :object, out: 'bench/ppu/results/tick-obj-allocs.dump', interval: 1) do
  i = 0

  while i < 300_000_000
    ppu.tick

    i += 1
  end
end
