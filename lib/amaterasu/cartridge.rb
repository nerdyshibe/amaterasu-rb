# frozen_string_literal: true

module Amaterasu
  # Models a Game Boy cartridge.
  class Cartridge
    ROM_BANK_SIZE = 16 * 1024
    RAM_BANK_SIZE = 8 * 1024

    # Loads a Rom from a file path.
    #
    # @param file_path [String]
    # @param trace_rom [Boolean]
    # @return [Cartridge] New Cartridge object.
    #
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

    # Reads a 8-bit value from a given address in Cartrige ROM,
    # if the Cartridge has more than 32KiB (not ROM-ONLY),
    # the MBC needs to be involved for bank switching.
    #
    # @param address [Integer] 16-bit address value.
    # @return [Integer] 8-bit value stored at that address.
    #
    def read_rom(address)
      @mbc.nil? ? @rom.read_byte(address) : @mbc.read_rom(address:)
    end

    # Writes a 8-bit value into Cartridge ROM,
    # this is only possible if a MBC is present.
    #
    # @param address [Integer] 16-bit memory address to write to.
    # @param value [Integer] 8-bit value to be written.
    # @return [void]
    #
    def write_rom(address, value)
      return unless @mbc

      @mbc.write_rom(address:, value:)
    end

    # Reads a 8-bit value from a given address in Cartrige RAM,
    # if the Cartridge doesn't have RAM, returns 0xFF.
    #
    # @param address [Integer] 16-bit address value.
    # @return [Integer] 8-bit value stored at that address.
    #
    def read_ram(address)
      return 0xFF if @ram.nil?

      @mbc.nil? ? @ram.read_byte(address) : @mbc.read_ram(address:)
    end

    # Writes a 8-bit value into Cartridge RAM,
    # this is only possible if a MBC is present.
    #
    # @param address [Integer] 16-bit memory address to write to.
    # @param value [Integer] 8-bit value to be written.
    # @return [void]
    #
    def write_ram(address, value)
      return unless @mbc

      @mbc.write_ram(address:, value:)
    end
  end
end
