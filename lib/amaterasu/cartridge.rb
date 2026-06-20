# frozen_string_literal: true

module Amaterasu
  # Models a Game Boy cartridge.
  class Cartridge
    ROM_BANK_SIZE = 16 * 1024
    RAM_BANK_SIZE = 8 * 1024

    # Loads a Rom from a file path.
    def self.load_rom(file_path, trace_rom:)
      rom = Rom.from_file(file_path)

      raise ArgumentError, 'Invalid ROM' unless rom.valid_checksum?

      if trace_rom
        puts rom.title
        puts rom.cartridge_type
        puts rom.rom_size
        puts rom.ram_size
      end

      new(rom: rom)
    end

    # Creates a cartridge object based on the cartridge type.
    def initialize(rom:, mbc: nil, ram: nil)
      @rom = rom
      @ram = ram
      @mbc = mbc

      add_ram if rom.cartridge_type.include?('RAM')
      add_mbc(Mbc1.new(@rom, @ram)) if rom.cartridge_type.include?('MBC1')
    end

    def add_mbc(mbc)
      @mbc = mbc
    end

    def add_ram
      @ram = GameBoy::Ram.new(size: @rom.ram_size, offset: 0xA000)
    end

    # Delegates the read byte to either the ROM or the MBC (Not implemented yet).
    def read_rom(address)
      @mbc.nil? ? @rom.read_byte(address) : @mbc.read_byte(address)
    end

    # Delegates the read byte to the MBC (Not implemented yet).
    def write_rom(address, value)
      return unless @mbc

      @mbc.write_byte(address, value)
    end

    def read_ram(address)
      return 0xFF if @ram.nil?

      @mbc.nil? ? @ram.read_byte(address) : @mbc.read_byte(address)
    end

    # Delegates the write byte to the MBC (Not implemented yet).
    def write_ram(address, value)
      return unless @mbc

      @mbc.write_byte(address, value)
    end
  end
end
