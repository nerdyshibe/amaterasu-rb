# frozen_string_literal: true

module Akane
  # Models a Game Boy cartridge.
  class Cartridge
    # Loads a Rom from a file path.
    def self.load_rom(file_path)
      rom = Akane::Cartridge::Rom.from_file(file_path)

      case rom.cartridge_type
      when :rom_only
        new(rom: rom)
      else
        raise "#{rom.cartridge_type} not implemented yet"
      end
    end

    # Creates a cartridge object based on the cartridge type.
    def initialize(rom:, mbc: nil, ram: nil)
      @rom = rom
      @mbc = mbc
      @ram = ram
    end

    # Delegates the read byte to either the ROM or the MBC (Not implemented yet).
    def read_rom(address)
      @rom.read_byte(address)
    end

    # Delegates the read byte to the MBC (Not implemented yet).
    def write_rom(address, value); end

    def read_ram(address)
      return 0xFF if @ram.nil?

      @ram.read_byte(address)
    end

    # Delegates the read byte to the MBC (Not implemented yet).
    def write_ram(address, value); end
  end
end
