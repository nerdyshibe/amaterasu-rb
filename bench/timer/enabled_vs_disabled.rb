# frozen_string_literal: true

require 'benchmark/ips'

require_relative '../../lib/akane'

interrupts = Akane::GameBoy::Interrupts.new
enabled_timer = Akane::GameBoy::Timer.new(interrupts, trace_timer: false)
disabled_timer = Akane::GameBoy::Timer.new(interrupts, trace_timer: false)

enabled_timer.tac = 0x05
disabled_timer.tac = 0x00

Benchmark.ips do |x|
  x.config(warmup: 5, time: 10)

  x.report('Timer#tick with Timer enabled') { enabled_timer.tick }
  x.report('Timer#tick with Timer disabled') { disabled_timer.tick }

  x.json! 'bench/timer/results/ips-enabled-vs-disabled.json'
  x.compare!
end
