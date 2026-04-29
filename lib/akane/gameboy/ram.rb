# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the RAM chip within the Game Boy
    class Ram
      # Memory size in bytes
      attr_reader :size

      # Creates a new Ram object given a size in bytes
      #
      # - Holds an instance variable for a possible data backup, starts blank.
      def initialize(size)
        @size = size
        @data = Array.new(size, 0x00)
        @backup = Array.new
        @backed_up = false
      end

      # Returns a 8-bit value from a given address in memory.
      #
      # - If the given address is not accessible, returns 0xFF.
      def read_byte(offset)
        return 0xFF unless in_bounds?(offset)

        @data[offset]
      end

      # Stores a 8-bit value into a given address in memory.
      #
      # - Ignores addresses out of bounds.
      # - Wraps all values around 0xFF.
      def write_byte(offset, value)
        return unless in_bounds?(offset)

        @data[offset] = value & 0xFF
      end

      # Provides an interface to read backup data.
      def read_backup(offset)
        return 0xFF unless @backed_up && in_bounds?(offset)

        @backup[offset]
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

      private

      # Returns a bool value indicating if the given address is within memory bounds.
      def in_bounds?(offset)
        offset >= 0 && offset <= @size - 1
      end
    end
  end
end
