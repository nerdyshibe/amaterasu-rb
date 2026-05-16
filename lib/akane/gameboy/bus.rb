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
      def initialize( # rubocop:disable Metrics/ParameterLists
        cartridge:,
        ppu:,
        wram:,
        hram:,
        interrupts:,
        apu:,
        timer:,
        serial:,
        joypad:
      )
        @cartridge = cartridge
        @ppu = ppu
        @wram = wram
        @hram = hram
        @interrupts = interrupts
        @apu = apu
        @timer = timer
        @serial = serial
        @joypad = joypad
      end

      # Delegates the read to the proper component based on the address
      # and returns the 8-bit value that was stored there.
      def read_byte(address:)
        if address <= 0x7FFF
          @cartridge.read_rom(address)
        elsif address <= 0x9FFF
          @ppu.read_vram(address - 0x8000)
        elsif address <= 0xBFFF
          @cartridge.read_ram(address - 0xA000)
        elsif address <= 0xDFFF
          @wram.read_byte(address - 0xC000)
        elsif address <= 0xFDFF
          @wram.read_byte(address - 0xE000)
        elsif address <= 0xFE9F
          @ppu.read_oam(address - 0xFE00)
        elsif address <= 0xFEFF
          0xFF
        elsif address <= 0xFF7F
          read_io(address)
        elsif address <= 0xFFFE
          @hram.read_byte(address - 0xFF80)
        elsif address == 0xFFFF
          @interrupts.ie_register
        else
          raise 'MemoryOutOfBounds error'
        end
      end

      # Delegates the write to the proper component based on the address
      # and stores a 8-bit value at that location.
      def write_byte(address:, value:)
        if address <= 0x7FFF
          @cartridge.write_rom(address, value)
        elsif address <= 0x9FFF
          @ppu.write_vram(address - 0x8000, value)
        elsif address <= 0xBFFF
          @cartridge.write_ram(address - 0xA000, value)
        elsif address <= 0xDFFF
          @wram.write_byte(address - 0xC000, value)
        elsif address <= 0xFDFF
          @wram.write_byte(address - 0xE000, value)
        elsif address <= 0xFE9F
          @ppu.write_oam(address - 0xFE00, value)
        elsif address <= 0xFEFF
          nil
        elsif address <= 0xFF7F
          write_io(address, value)
        elsif address <= 0xFFFE
          @hram.write_byte(address - 0xFF80, value)
        elsif address == 0xFFFF
          @interrupts.ie_register = value
        else
          raise 'MemoryOutOfBounds error'
        end
      end

      private

      # Extracts the IO registers read logic for organization.
      def read_io(address)
        case address
        when 0xFF00 then @joypad.p1
        when 0xFF01 then @serial.sb
        when 0xFF02 then @serial.sc
        when 0xFF04 then @timer.div
        when 0xFF05 then @timer.tima
        when 0xFF06 then @timer.tma
        when 0xFF07 then @timer.tac
        when 0xFF0F then @interrupts.if_register
        when 0xFF40 then @ppu.lcdc
        when 0xFF41 then @ppu.stat
        when 0xFF42 then @ppu.scy
        when 0xFF43 then @ppu.scx
        when 0xFF44
          @ppu.ly += 1
        else
          0xFF
        end
      end

      # Extracts the IO registers write logic for organization.
      def write_io(address, value)
        case address
        when 0xFF00 then @joypad.p1 = value
        when 0xFF01 then @serial.sb = value
        when 0xFF02 then @serial.sc = value
        when 0xFF04 then @timer.div = value
        when 0xFF05 then @timer.tima = value
        when 0xFF06 then @timer.tma = value
        when 0xFF07 then @timer.tac = value
        when 0xFF0F then @interrupts.if_register = value
        when 0xFF44 then @ppu.ly = value
        end
      end
    end
  end
end
