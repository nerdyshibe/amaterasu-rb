# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    CYCLES_PER_FRAME = 17_556

    def self.start(options)
      @cycles = 0

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

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

      cpu = Gameboy::Cpu.new(bus, interrupts, -> { advance_components }, options[:verbose])

      if options[:iterations]
        i = 0
        while i < options[:iterations]
          cpu.step
          i += 1
        end
      else
        Kernel.loop do
          cpu.step
        end
      end

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      frames = @cycles.to_f / 17_556
      fps = frames / elapsed

      puts "#{@cycles} cycles in #{elapsed.round(2)}s"
      puts "#{fps.round(1)} FPS (Target: 59.7)"
      puts "#{(fps / 59.7).round(2)}x real-time Game Boy"
    end

    def self.advance_components
      @timer.tick
      @ppu.tick
      @apu.tick

      @cycles += 1
    end
  end
end
