# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    CYCLES_PER_FRAME = 17_556

    def initialize(
      audio:,
      cycles:,
      profiling:,
      steps:,
      trace:,
      video:,
      rom_path:
    )
      @audio = audio
      @video = video
      @stop_cycles = cycles
      @stop_steps = steps
      @profiling_mode = profiling

      @trace_cpu    = trace == 'cpu'
      @trace_ppu    = trace == 'ppu'
      @trace_dma    = trace == 'dma'
      @trace_serial = trace == 'serial'

      @rom_path = rom_path

      @cycles = 0
      @steps = 0
    end

    def start
      @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      load_cartridge
      add_memory
      add_components

      Kernel.loop do
        stop if @steps == @stop_steps

        @cpu.step
        @steps += 1
      end
    end

    def advance_cycle
      stop if @cycles == @stop_cycles

      @timer.tick
      @ppu.tick
      @apu.tick
      @dma.tick

      @cycles += 1
    end

    private

    def load_cartridge
      @cartridge = Cartridge.load_rom(@rom_path)
    end

    def add_memory
      @wram = Gameboy::Ram.new(size: 8192, offset: 0xC000)
      @hram = Gameboy::Ram.new(size: 127, offset: 0xFF80)
      @vram = Gameboy::Ram.new(size: 8192, offset: 0x8000)
      @oam  = Gameboy::Ram.new(size: 160, offset: 0xFE00)
    end

    def add_components
      @bus = Gameboy::Bus.new
      @lcd = HAL::SDL2.new unless @video == 'null'
      @apu = Gameboy::Apu.new
      @dma = Gameboy::DMA.new(@bus, trace_dma: @trace_dma)
      @interrupts = Gameboy::Interrupts.new
      @ppu = Gameboy::Ppu.new(@vram, @oam, @lcd, @interrupts, trace_ppu: @trace_ppu)
      @timer = Gameboy::Timer.new(@interrupts)
      @serial = Gameboy::Serial.new(@interrupts, trace_serial: @trace_serial)
      @joypad = Gameboy::Joypad.new(@interrupts)
      @bus.wire_components(
        cartridge: @cartridge,
        ppu: @ppu,
        wram: @wram,
        hram: @hram,
        interrupts: @interrupts,
        apu: @apu,
        timer: @timer,
        serial: @serial,
        joypad: @joypad,
        dma: @dma
      )
      @cpu = Gameboy::Cpu.new(
        @bus,
        @hram,
        @interrupts,
        -> { advance_cycle },
        trace_cpu: @trace_cpu
      )
    end

    def stop
      @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start

      frames = @cycles.to_f / 17_556
      fps = frames / @elapsed

      puts "#{@steps} steps / #{@cycles} cycles in #{@elapsed.round(2)}s"
      puts "#{fps.round(2)} FPS (Target: 59.73)"
      puts "#{(fps / 59.73).round(2)}x real-time Game Boy"

      exit
    end
  end
end
