# frozen_string_literal: true

module CpuHelper
  # Setup the CPU to be in a testable state.
  def build_cpu(rom_data)
    rom = Amaterasu::Cartridge::Rom.new(rom_data)
    cartridge = Amaterasu::Cartridge.new(rom: rom)
    wram = Amaterasu::GameBoy::Ram.new(size: 8192, offset: 0x8000)
    hram = Amaterasu::GameBoy::Ram.new(size: 127, offset: 0xFF80)
    apu = Amaterasu::GameBoy::Apu.new
    interrupts = Amaterasu::GameBoy::Interrupts.new

    ppu = Amaterasu::GameBoy::Ppu.new(interrupts)
    timer = Amaterasu::GameBoy::Timer.new(interrupts)
    serial = Amaterasu::GameBoy::Serial.new(interrupts)
    joypad = Amaterasu::GameBoy::Joypad.new(interrupts)

    bus = Amaterasu::GameBoy::Bus.new(
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

    Amaterasu::GameBoy::Cpu.new(bus, interrupts, -> {})
  end
end
