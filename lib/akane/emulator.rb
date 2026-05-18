# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    CYCLES_PER_FRAME = 17_556

    def self.start(options)
      @cycles = 0
      @steps = 0
      @stop_cycles = options[:cycles] if options[:cycles]
      @stop_steps = options[:steps] if options[:steps]

      @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      cartridge = Cartridge.load_rom(options[:rom_path])
      wram = Gameboy::Ram.new(size: 8192, offset: 0xC000)
      hram = Gameboy::Ram.new(size: 127, offset: 0xFF80)
      @apu = Gameboy::Apu.new
      interrupts = Gameboy::Interrupts.new

      display = HAL::SDL2.new unless options[:video] == 'null'
      @ppu = Gameboy::Ppu.new(
        display,
        interrupts,
        trace_ppu: options[:trace]&.include?('ppu'),
        debug_mode: options[:debug]
      )
      @timer = Gameboy::Timer.new(interrupts)
      serial = Gameboy::Serial.new(interrupts, debug_mode: options[:debug])
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

      cpu = Gameboy::Cpu.new(
        bus,
        interrupts,
        -> { advance_components },
        trace_cpu: options[:trace]&.include?('cpu')
      )

      Kernel.loop do
        if @steps == @stop_steps
          stop
          break
        end

        cpu.step

        @steps += 1
      end
    end

    def self.advance_components
      stop if @cycles == @stop_cycles

      @timer.tick
      @ppu.tick
      @apu.tick

      @cycles += 1
    end

    def self.stop
      @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start

      frames = @cycles.to_f / 17_556
      fps = frames / @elapsed

      puts "#{@steps} steps / #{@cycles} cycles in #{@elapsed.round(2)}s"
      puts "#{fps.round(2)} FPS (Target: 59.73)"
      puts "#{(fps / 59.73).round(2)}x real-time Game Boy"
    end
  end
end
