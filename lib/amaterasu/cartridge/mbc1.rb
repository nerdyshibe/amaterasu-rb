# frozen_string_literal: true

module Amaterasu
  class Cartridge
    # Models the MBC1 chip inside the Game Boy cartridge.
    #
    # 0x0000 - 0x3FFF => ROM Bank X0
    # 0x4000 - 0x7FFF => ROM Bank 01-7F (1 - 127)
    #
    # Can switch between Modes 0 and 1.
    class Mbc1
      def initialize(rom, ram)
        @rom = rom
        @ram = ram

        @rom_banks = rom.rom_size / ROM_BANK_SIZE
        @ram_enabled = false
        @banking_mode = 0
        @rom_banking_reg1 = 0b00001
        @rom_banking_reg2 = 0b00
      end

      # TODO: Split write_byte into write_rom and write_ram
      def write_byte(address, value)
        if address <= 0x1FFF
          @ram_enabled = true if (value & 0xF) == 0xA
        elsif address <= 0x3FFF
          value &= 0b11111
          @rom_banking_reg1 = value.zero? ? 1 : value
        elsif address <= 0x5FFF
          @rom_banking_reg2 = value & 0b11
        elsif address <= 0x7FFF
          @banking_mode = value & 1
        else
          return 0xFF if @ram.nil? || !@ram_enabled

          @ram.write_byte(address:, value:)
        end
      end

      # TODO: Split read_byte into read_rom and read_ram
      # TODO: Implement banking mode logic for reads
      def read_byte(address)
        if address <= 0x3FFF
          @rom.read_byte(address)
        elsif address <= 0x7FFF
          selected_bank = (@rom_banking_reg2 << 5) | @rom_banking_reg1
          bank_offset = selected_bank * ROM_BANK_SIZE
          @rom.read_byte(address - 0x4000 + bank_offset)
        else
          return 0xFF if @ram.nil? || !@ram_enabled

          @ram.read_byte(address:)
        end
      end
    end
  end
end
