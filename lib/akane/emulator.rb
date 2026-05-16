# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    def self.start(options)
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

      cpu = Gameboy::Cpu.new(bus, interrupts, advance_components, options[:verbose])

      if options[:cycles]
        i = 0
        while i < options[:cycles]
          cpu.step
          i += 1
        end
      else
        Kernel.loop do
          cpu.step
        end
      end
    end

    def self.advance_components
      proc do
        @timer.tick
        @ppu.tick
        @apu.tick
      end
    end
  end
end
