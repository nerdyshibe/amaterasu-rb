# frozen_string_literal: true

module CpuHelper
  # Setup the CPU to be in a testable state.
  def build_cpu(rom_data)
    rom = Akane::Cartridge::Rom.new(rom_data)
    cartridge = Akane::Cartridge.new(rom: rom)
    wram = Akane::GameBoy::Ram.new(size: 8192, offset: 0x8000)
    hram = Akane::GameBoy::Ram.new(size: 127, offset: 0xFF80)
    apu = Akane::GameBoy::Apu.new
    interrupts = Akane::GameBoy::Interrupts.new

    ppu = Akane::GameBoy::PPU.new(interrupts)
    timer = Akane::GameBoy::Timer.new(interrupts)
    serial = Akane::GameBoy::Serial.new(interrupts)
    joypad = Akane::GameBoy::Joypad.new(interrupts)

    bus = Akane::GameBoy::Bus.new(
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

    Akane::GameBoy::Cpu.new(bus, interrupts, -> {})
  end
end
