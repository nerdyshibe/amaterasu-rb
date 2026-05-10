# frozen_string_literal: true

require 'debug'

module Akane
  module Gameboy
    # Models the CPU behavior from the Game Boy.
    class Cpu
      include Instructions

      def initialize(bus, interrupts, advance_components)
        @bus = bus
        @interrupts = interrupts
        @advance_components = advance_components

        @registers = Registers.new
        @instructions = Array.new(256)
        # @cb_instructions = Instructions.wire_cb_opcodes
        @ime = false
        @opcode = nil
        @instruction = nil

        wire_instructions
      end

      # Core CPU loop:
      #
      # - Checks IME and any interrupts pending to be serviced.
      # - Fetches the current Opcode at the Program Counter.
      # - Decodes which instruction based on the Opcode fetched.
      # - Executes the instruction.
      def run
        handle_interrupts if @ime && @interrupts.any_pending?

        old_pc = @registers.pc
        @opcode = fetch_byte
        decode_instruction
        execute_instruction
        log(old_pc, @instruction)
      end

      private

      # Checks if any interrupt is enabled and requested to service.
      def handle_interrupts
        puts 'Interrupts handled'
      end

      # Special read that gets the byte pointed to by the Program Counter.
      def fetch_byte
        byte = bus_read(@registers.pc)
        @registers.pc += 1

        byte
      end

      # Determines which instruction should be executed for each Opcode.
      def decode_instruction
        @instruction = @instructions[@opcode]
        raise "Opcode not implemented yet: #{format('$%02X', @opcode)}" if @instruction.nil?
      end

      # Executes the logic for the current instruction.
      def execute_instruction
        @instruction.execute.call
      end

      # Reads a byte from the Bus at a given address.
      def bus_read(address)
        byte = @bus.read_byte(address)
        advance_cycles(4)

        byte
      end

      # Requests a Bus write at a given address with a given value.
      def bus_write(address, value)
        @bus.write_byte(address, value)
        advance_cycles(4)
      end

      # Emulates CPU internal processing which advance cycles without Bus access.
      def internal_processing
        advance_cycles(4)
      end

      # Syncs all components after each M-cycle.
      def advance_cycles(t_cycles)
        @advance_components.call(t_cycles)
      end

      def log(old_pc, instruction)
        puts "#{format('$%04X', old_pc)}  |  " \
             "#{instruction.mnemonic}  |  " \
             "#{format('$%02X', bus_read(old_pc))} " \
             "#{format('$%02X', bus_read(old_pc + 1))} " \
             "#{format('$%02X', bus_read(old_pc + 1))}  |  " \
             "AF: $#{format('%04X', @registers.af)}  |  " \
             "BC: $#{format('%04X', @registers.bc)}  |  " \
             "DE: $#{format('%04X', @registers.de)}  |  " \
             "HL: $#{format('%04X', @registers.hl)}  |  "
      end
    end
  end
end
