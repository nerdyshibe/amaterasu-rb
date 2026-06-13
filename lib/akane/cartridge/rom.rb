# frozen_string_literal: true

module Akane
  class Cartridge
    # models the ROM inside the Game Boy cartridge.
    class Rom
      CARTRIDGE_TYPES = {
        0x00 => 'ROM ONLY',
        0x01 => 'MBC1',
        0x02 => 'MBC1+RAM',
        0x03 => 'MBC1+RAM+BATTERY',
        0x05 => 'MBC2'
      }.freeze

      ROM_SIZES = {
        0x00 => 32 * 1024,
        0x01 => 64 * 1024,
        0x02 => 128 * 1024,
        0x03 => 256 * 1024,
        0x04 => 512 * 1024,
        0x05 => 1024 * 1024,
        0x06 => 2 * 1024 * 1024,
        0x07 => 4 * 1024 * 1024,
        0x08 => 8 * 1024 * 1024
      }.freeze

      RAM_SIZES = {
        0x00 => 0,
        0x02 => 8 * 1024,
        0x03 => 32 * 1024,
        0x04 => 128 * 1024,
        0x05 => 64 * 1024
      }.freeze

      def self.from_file(file_path)
        new(File.binread(file_path).bytes)
      end

      # Creates a ROM object given the bytes array and freezes it (read-only).
      def initialize(data)
        @data = data
        @data.freeze
      end

      # Returns a 8-bit value stored in the given address/offset.
      def read_byte(offset)
        @data[offset]
      end

      def header
        @data[0x0100..0x014F]
      end

      # Returns a string containing the ROM title.
      def title
        @data[0x0134..0x0143].pack('C*').strip
      end

      def manufacturer_code
        @data[0x013F..0x0142]
      end

      def cgb_flag
        @data[0x0143]
      end

      def new_licensee_code
        @data[0x0144..0x0145]
      end

      def sgb_flag
        @data[0x0146]
      end

      # Returns a symbol for the cartridge type (:rom_only, :mbc1, ...).
      def cartridge_type
        CARTRIDGE_TYPES[@data[0x0147]]
      end

      # Returns an Integer indicating the ROM size.
      def rom_size
        ROM_SIZES[@data[0x0148]]
      end

      # Returns an Integer indicating the RAM size.
      def ram_size
        RAM_SIZES[@data[0x0149]]
      end

      def destination_code
        @data[0x014A]
      end

      def old_licensee_code
        @data[0x014B]
      end

      def mask_rom_version
        @data[0x014C]
      end

      # Returns a 8-bit value for the header checksum.
      def header_checksum
        @data[0x014D]
      end

      # Calculates the checksum and returns true if it matches.
      def valid_checksum?
        checksum = 0
        (0x0134..0x014C).each do |address|
          checksum = checksum - @data[address] - 1
        end

        (checksum & 0xFF) == header_checksum
      end
    end
  end
end
