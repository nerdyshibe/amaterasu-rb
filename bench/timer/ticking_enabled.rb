# frozen_string_literal: true

require 'stackprof'

require_relative '../../lib/amaterasu'

interrupts = Amaterasu::GameBoy::Interrupts.new
timer = Amaterasu::GameBoy::Timer.new(interrupts, trace_timer: false)
timer.tac = 0x05 # enable

StackProf.run(mode: :cpu, out: 'bench/timer/results/ticking-enabled.dump') do
  i = 0

  while i < 150_000_000
    timer.tick

    i += 1
  end
end
