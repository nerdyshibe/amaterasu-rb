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
      @trace = trace
      @rom_path = rom_path

      @cycles = 0
      @steps = 0
    end

    def start
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      load_cartridge
      load_memory
      load_components

      Kernel.loop do
        stop if @stop_steps && @steps == @stop_steps

        @cpu.step
        @steps += 1
      end
    end

    # This method is called every time the CPU spends
    # exactly 1 M-cycle to advance other components.
    def advance_cycle
      stop if @stop_cycles && @cycles == @stop_cycles

      @timer.tick
      @apu.tick
      @dma.tick

      i = 0

      while i < 4
        @ppu.tick
        i += 1
      end

      @cycles += 1
    end

    private

    def load_cartridge
      @cartridge = Cartridge.load_rom(@rom_path, trace_rom: @trace == 'rom')
    end

    def load_memory
      @wram = GameBoy::Ram.new(size: 8192, offset: 0xC000)
      @hram = GameBoy::Ram.new(size: 127, offset: 0xFF80)
      @vram = GameBoy::Vram.new
      @oam  = GameBoy::Oam.new
    end

    def load_components
      @bus = GameBoy::Bus.new
      @sdl2 = HAL::SDL2.new unless @video == 'null'
      @apu = GameBoy::Apu.new
      @dma = GameBoy::Dma.new(@bus, trace_dma: @trace == 'dma')
      @interrupts = GameBoy::Interrupts.new
      @ppu = GameBoy::Ppu.new(@vram, @oam, @sdl2, @interrupts, trace_ppu: @trace == 'ppu')
      @timer = GameBoy::Timer.new(@interrupts, trace_timer: @trace == 'timer')
      @serial = GameBoy::Serial.new(@interrupts, trace_serial: @trace == 'serial')
      @joypad = GameBoy::Joypad.new(@interrupts)
      @sdl2.joypad = @joypad
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
      @cpu = GameBoy::Cpu.new(
        @bus,
        @hram,
        @interrupts,
        -> { advance_cycle },
        trace_cpu: @trace == 'cpu'
      )
    end

    def stop
      @elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time

      frames = @cycles.to_f / 17_556
      fps = frames / @elapsed_time

      puts "#{@steps} steps / #{@cycles} cycles in #{@elapsed_time.round(2)}s"
      puts "#{fps.round(2)} FPS (Target: 59.73)"
      puts "#{(fps / 59.73).round(2)}x real-time Game Boy"

      exit
    end
  end
end
