# frozen_string_literal: true

require 'benchmark/ips'

require_relative '../../lib/akane'

interrupts = Akane::GameBoy::Interrupts.new
timer = Akane::GameBoy::Timer.new(interrupts, trace_timer: false)

Benchmark.ips do |x|
  x.report('Timer#tick with Timer disabled') { timer.tick }

  timer.tac = 0x05

  x.report('Timer#tick with Timer enabled') { timer.tick }

  x.json! 'bench/timer/results/enabled-vs-disabled.json'
  x.compare!
end
