# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    def self.start(file_path)
      puts "Emulator started with #{file_path}"
      cartridge = Cartridge.load_rom(file_path)
      wram = Gameboy::Ram.new(8192)
      hram = Gameboy::Ram.new(127)
      interrupts = Gameboy::Interrupts.new

      ppu = Gameboy::Ppu.new(interrupts)
      timer = Gameboy::Timer.new(interrupts)
      serial = Gameboy::Serial.new(interrupts)
      joypad = Gameboy::Joypad.new(interrupts)

      bus = Gameboy::Bus.new(
        cartridge: cartridge,
        ppu: ppu,
        wram: wram,
        hram: hram,
        interrupts: interrupts,
        timer: timer,
        serial: serial,
        joypad: joypad
      )

      advance_components = proc do |cycles|
        puts "All components advanced by #{cycles} t-cycles"
      end

      cpu = Gameboy::Cpu.new(bus, interrupts, advance_components)

      i = 0
      while i < 10
        cpu.run
        i += 1
      end
    end
  end
end
