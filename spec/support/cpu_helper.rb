# frozen_string_literal: true

module CpuHelper
  # Setup the CPU to be in a testable state.
  def build_cpu(rom_data)
    rom = Akane::Cartridge::Rom.new(rom_data)
    cartridge = Akane::Cartridge.new(rom: rom)
    wram = Akane::Gameboy::Ram.new(size: 8192, offset: 0x8000)
    hram = Akane::Gameboy::Ram.new(size: 127, offset: 0xFF80)
    apu = Akane::Gameboy::Apu.new
    interrupts = Akane::Gameboy::Interrupts.new

    ppu = Akane::Gameboy::Ppu.new(interrupts)
    timer = Akane::Gameboy::Timer.new(interrupts)
    serial = Akane::Gameboy::Serial.new(interrupts)
    joypad = Akane::Gameboy::Joypad.new(interrupts)

    bus = Akane::Gameboy::Bus.new(
      cartridge: cartridge,
      ppu: ppu,
      wram: wram,
      hram: hram,
      interrupts: interrupts,
      apu: apu,
      timer: timer,
      serial: serial,
      joypad: joypad
    )

    Akane::Gameboy::Cpu.new(bus, interrupts, -> {})
  end
end
