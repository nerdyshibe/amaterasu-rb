# frozen_string_literal: true

require 'stackprof'

require_relative '../../lib/akane'

interrupts = Akane::GameBoy::Interrupts.new
timer = Akane::GameBoy::Timer.new(interrupts, trace_timer: false)
timer.tac = 0x05 # enable

if ARGV.empty?
  puts 'Cycles missing'
  return
end

cycles = ARGV[0].to_i

StackProf.run(mode: :cpu, out: 'bench/timer/ticking-enabled.dump') do
  i = 0

  while i < cycles
    timer.tick

    i += 1
  end
end
