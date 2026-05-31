# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the RAM chip within the Game Boy.
    class Ram
      # Memory size in bytes.
      attr_reader :size

      # Creates a new Ram object.
      #
      # @param size [Integer] Memory size in bytes.
      # @param offset [Integer] Address offset based on the Bus memory map.
      def initialize(size:, offset:)
        @size = size
        @offset = offset

        @data = Array.new(size, 0x00)
        @backup = nil
        @backed_up = false
      end

      # Returns a 8-bit value from a given address in memory.
      def read_byte(address:)
        @data[address - @offset]
      end

      # Stores a 8-bit value into a given address in memory.
      def write_byte(address:, value:)
        @data[address - @offset] = value & 0xFF
      end

      # Provides an interface to read backup data.
      def read_backup(address:)
        return 0xFF unless @backed_up

        @backup[address - @offset]
      end

      # Returns a readable string in B or KiB based on memory size.
      def disk_size
        return "#{@size} B" if @size < 1024

        "#{@size / 1024} KiB"
      end

      # Creates a copy of the current state of memory.
      def save_data
        @backup = @data.dup
        @backed_up = true
      end

      # Restores a previously backed up memory state.
      def restore_data
        @data = @backup.dup
      end

      # Clears all previously set memory values.
      def wipe_data
        @data = Array.new(@size, 0x00)
      end

      # Clears all previously set backup values.
      def wipe_backup
        @backup = Array.new
        @backed_up = false
      end
    end
  end
end
