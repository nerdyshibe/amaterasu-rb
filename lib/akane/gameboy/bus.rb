# frozen_string_literal: true

module Akane
  module Gameboy
    # | 0x0000-0x7FFF | 32 KB | Cartridge ROM | Bank 0 fixed, Bank N switchable |
    # | 0x8000-0x9FFF | 8 KB | Video RAM (VRAM) | Tile data + tile maps |
    # | 0xA000-0xBFFF | 8 KB | External RAM | Cartridge RAM, battery-backed |
    # | 0xC000-0xDFFF | 8 KB | Work RAM (WRAM) | General purpose |
    # | 0xE000-0xFDFF | ~8 KB | Echo RAM | Mirror of WRAM (0xC000-0xDDFF) |
    # | 0xFE00-0xFE9F | 160 B | OAM | Sprite attribute table |
    # | 0xFEA0-0xFEFF | 96 B | Unusable | Prohibited area |
    # | 0xFF00-0xFF7F | 128 B | I/O Registers | Hardware control |
    # | 0xFF80-0xFFFE | 127 B | High RAM (HRAM) | Fast RAM, accessible during DMA |
    # | 0xFFFF | 1 B | IE Register | Interrupt Enable |
    class Bus
      def initialize
        # @cartridge = cartridge
        # @ppu = ppu
        # @wram = wram
        # @io
        # @hram = hram
        # @interrupts = interrupts
      end

      def read_byte(address)
        if address >= 0x0000 && address <= 0x7FFF
          0xFF
          # @cartridge.read_rom(address)
        elsif address >= 0x8000 && address <= 0x9FFF
          0xFF
          # @ppu.read_vram(address)
        elsif address >= 0xA000 && address <= 0xBFFF
          0xFF
          # @cartridge.read_ram(address)
        elsif address >= 0xC000 && address <= 0xDFFF
          0xFF
          # @wram.read_byte(address)
        elsif address >= 0xE000 && address <= 0xFDFF
          0xFF
          # @wram.read_byte(address - 0x2000)
        elsif address >= 0xFE00 && address <= 0xFE9F
          0xFF
          # @ppu.read_oam(address)
        elsif address >= 0xFEA0 && address <= 0xFEFF
          0xFF
        elsif address >= 0xFF00 && address <= 0xFF7F
          0xFF
          # @io.read_registers(address)
        elsif address >= 0xFF80 && address <= 0xFFFE
          0xFF
          # @hram.read_byte(address)
        elsif address == 0xFFFF
          0xFF
          # @interrupts.ie
        else
          # create a custom error class?
          # raise MemoryOutOfBounds
          0xFF
        end
      end

      def write_byte(address, value)
        if address >= 0x0000 && address <= 0x7FFF
          # @cartridge.write_rom(address, value)
        elsif address >= 0x8000 && address <= 0x9FFF
          # @ppu.write_vram(address, value)
        elsif address >= 0xA000 && address <= 0xBFFF
          # @cartridge.write_ram(address, value)
        elsif address >= 0xC000 && address <= 0xDFFF
          # @wram.write_byte(address, value)
        elsif address >= 0xE000 && address <= 0xFDFF
          # @wram.write_byte(address - 0x2000, value)
        elsif address >= 0xFE00 && address <= 0xFE9F
          # @ppu.write_oam(address, value)
        elsif address >= 0xFEA0 && address <= 0xFEFF
        elsif address >= 0xFF00 && address <= 0xFF7F
          # @io.write_registers(address, value)
        elsif address >= 0xFF80 && address <= 0xFFFE
          # @hram.write_byte(address, value)
        elsif address == 0xFFFF
          # @interrupts.ie = value
        else
          # create a custom error class?
          # raise MemoryOutOfBounds
          raise StandardError, 'memory out of bounds'
        end
      end
    end
  end
end
