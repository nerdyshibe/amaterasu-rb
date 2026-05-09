# frozen_string_literal: true

module Akane
  # Handles the core emulation loop.
  class Emulator
    def self.start(file_path)
      puts "Emulator started with #{file_path}"
      cartridge = Cartridge.load_rom(file_path)
      ppu = Gameboy::Ppu.new
      wram = Gameboy::Ram.new(8 * 1_024)
      hram = Gameboy::Ram.new(127)
      interrupts = Gameboy::Interrupts.new
      timer = Gameboy::Timer.new(interrupts)
      serial = Gameboy::Serial.new(interrupts)
      joypad = Gameboy::Joypad.new(interrupts)
      Gameboy::Bus.new(
        cartridge, ppu, wram, hram, interrupts, timer, serial, joypad
      )
    end
  end
end
