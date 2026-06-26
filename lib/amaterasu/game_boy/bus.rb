# frozen_string_literal: true

module Amaterasu
  module GameBoy
    # | 0x0000-0x7FFF | 32 KiB | Cartridge ROM    | Bank 0 fixed, Bank N switchable |
    # | 0x8000-0x9FFF | 8 KiB  | Video RAM (VRAM) | Tile data + tile maps           |
    # | 0xA000-0xBFFF | 8 KiB  | External RAM     | Cartridge RAM, battery-backed   |
    # | 0xC000-0xDFFF | 8 KiB  | Work RAM (WRAM)  | General purpose                 |
    # | 0xE000-0xFDFF | ~8 KiB | Echo RAM         | Mirror of WRAM (0xC000-0xDDFF)  |
    # | 0xFE00-0xFE9F | 160 B  | OAM              | Sprite attribute table          |
    # | 0xFEA0-0xFEFF | 96 B   | Unusable         | Prohibited area                 |
    # | 0xFF00-0xFF7F | 128 B  | I/O Registers    | Hardware control                |
    # | 0xFF80-0xFFFE | 127 B  | High RAM (HRAM)  | Fast RAM, accessible during DMA |
    # | 0xFFFF        | 1 B    | IE Register      | Interrupt Enable                |
    class Bus
      def wire_components(
        cartridge:,
        ppu:,
        wram:,
        hram:,
        interrupts:,
        apu:,
        timer:,
        serial:,
        joypad:,
        dma:
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
        @dma = dma
      end

      # Delegates the read to the proper component based on the address
      # and returns the 8-bit value that was stored there.
      def read_byte(address:, caller: nil)
        return 0xFF if @dma.active?
          && caller.is_a?(Cpu)
          && address < 0xFF00

        if address <= 0x7FFF
          @cartridge.read_rom(address)
        elsif address <= 0x9FFF
          @ppu.read_vram(address:)
        elsif address <= 0xBFFF
          @cartridge.read_ram(address)
        elsif address <= 0xDFFF
          @wram.read_byte(address:)
        elsif address <= 0xFDFF
          @wram.read_byte(address: address - 0x2000)
        elsif address <= 0xFE9F
          @ppu.read_oam(address:)
        elsif address <= 0xFEFF
          0xFF
        elsif address <= 0xFF7F
          read_io(address)
        elsif address <= 0xFFFE
          @hram.read_byte(address:)
        elsif address == 0xFFFF
          @interrupts.ie_register
        else
          raise "Not implemented bus read at $#{address.to_s(16)}"
        end
      end

      # Delegates the write to the proper component based on the address
      # and stores a 8-bit value at that location.
      def write_byte(address:, value:, caller: nil)
        return if @dma.active?
          && caller.is_a?(Cpu)
          && address < 0xFF00

        if address <= 0x7FFF
          @cartridge.write_rom(address, value)
        elsif address <= 0x9FFF
          @ppu.write_vram(address:, value:)
        elsif address <= 0xBFFF
          @cartridge.write_ram(address, value)
        elsif address <= 0xDFFF
          @wram.write_byte(address:, value:)
        elsif address <= 0xFDFF
          @wram.write_byte(address: address - 0x2000, value:)
        elsif address <= 0xFE9F
          @ppu.write_oam(address:, value:)
        elsif address <= 0xFEFF
          nil
        elsif address <= 0xFF7F
          write_io(address, value)
        elsif address <= 0xFFFE
          @hram.write_byte(address:, value:)
        elsif address == 0xFFFF
          @interrupts.ie_register = value
        else
          raise "Not implemented bus write at $#{address.to_s(16)}"
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
        when 0xFF40 then @ppu.registers.lcdc.value
        when 0xFF41 then @ppu.registers.stat.value
        when 0xFF42 then @ppu.registers.scy
        when 0xFF43 then @ppu.registers.scx
        when 0xFF44 then @ppu.registers.ly
        when 0xFF45 then @ppu.registers.lyc
        when 0xFF46 then @dma.internal_latch
        when 0xFF47 then @ppu.registers.bgp
        when 0xFF48 then @ppu.registers.obp0
        when 0xFF49 then @ppu.registers.obp1
        when 0xFF4A then @ppu.registers.wy
        when 0xFF4B then @ppu.registers.wx
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
        when 0xFF40 then @ppu.registers.lcdc = value
        when 0xFF41 then @ppu.registers.stat = value
        when 0xFF42 then @ppu.registers.scy = value
        when 0xFF43 then @ppu.registers.scx = value
        when 0xFF44 then nil # @ppu.registers.ly = value -> read-only
        when 0xFF45 then @ppu.registers.lyc = value
        when 0xFF46 then @dma.request_transfer(source_value: value)
        when 0xFF47 then @ppu.registers.bgp = value
        when 0xFF48 then @ppu.registers.obp0 = value
        when 0xFF49 then @ppu.registers.obp1 = value
        when 0xFF4A then @ppu.registers.wy = value
        when 0xFF4B then @ppu.registers.wx = value
        end
      end
    end
  end
end
