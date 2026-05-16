# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    CYCLES_PER_FRAME = 17_556

    def self.start(options)
      @cycles = 0
      @steps = 0
      @stop_cycles = options[:cycles] if options[:cycles]

      @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      cartridge = Cartridge.load_rom(options[:rom_path])
      wram = Gameboy::Ram.new(8192)
      hram = Gameboy::Ram.new(127)
      @apu = Gameboy::Apu.new
      interrupts = Gameboy::Interrupts.new

      @ppu = Gameboy::Ppu.new(interrupts)
      @timer = Gameboy::Timer.new(interrupts)
      serial = Gameboy::Serial.new(interrupts, options[:debug])
      joypad = Gameboy::Joypad.new(interrupts)

      bus = Gameboy::Bus.new(
        cartridge: cartridge,
        ppu: @ppu,
        wram: wram,
        hram: hram,
        interrupts: interrupts,
        apu: @apu,
        timer: @timer,
        serial: serial,
        joypad: joypad
      )

      trace_cpu = options[:trace].include?('cpu')
      cpu = Gameboy::Cpu.new(bus, interrupts, -> { advance_components }, trace_cpu)

      if options[:steps]
        while @steps < options[:steps]
          cpu.step
          @steps += 1
        end
      else
        Kernel.loop do
          cpu.step
        end
      end

      @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start

      stop
    end

    def self.advance_components
      @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start
      stop if @cycles == @stop_cycles

      @timer.tick
      @ppu.tick
      @apu.tick

      @cycles += 1
    end

    def self.stop
      frames = @cycles.to_f / 17_556
      fps = frames / @elapsed

      puts "#{@steps} steps / #{@cycles} cycles in #{@elapsed.round(2)}s"
      puts "#{fps.round(2)} FPS (Target: 59.73)"
      puts "#{(fps / 59.73).round(2)}x real-time Game Boy"
      exit
    end
  end
end
