# frozen_string_literal: true

require 'debug'

module Akane
  module Gameboy
    # Models the CPU behavior from the Game Boy.
    class Cpu
      include Instructions

      attr_reader :registers, :m_cycles

      def initialize(bus, interrupts, advance_components, verbose)
        @bus = bus
        @interrupts = interrupts
        @advance_components = advance_components
        @verbose = verbose

        @registers = Registers.new
        @ime = false
        @opcode = nil
        @instruction = nil

        @m_cycles = 0

        @instructions = load_base_instructions
        @cb_instructions = load_cb_instructions
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
        @opcode = fetch_next_byte
        decode_instruction
        execute_instruction
        log(old_pc, @instruction)
      end

      # Fetches the next immediate byte from memory pointed to by the Program Counter.
      def fetch_next_byte
        byte = bus_read(@registers.pc)
        @registers.pc += 1

        byte
      end

      # Fetches the next 2 immediate bytes from memory.
      #
      # - The Game Boy uses little endian format.
      # - This means that the first byte fetched is the least significant one.
      # - So if the memory has these next 2 bytes: $50 $01, the word is: $0150
      def fetch_next_word
        lsb = fetch_next_byte
        msb = fetch_next_byte

        (msb << 8) | lsb
      end

      # Jumps execution to a given address by setting the address value into the PC.
      def jump_to(address:)
        @registers.pc = address
        internal_processing
      end

      private

      # Checks if any interrupt is enabled and requested to service.
      def handle_interrupts
        puts 'Interrupts handled'
      end

      # Determines which instruction should be executed for each Opcode.
      def decode_instruction
        @instruction = @instructions[@opcode]
        raise "Opcode not implemented yet: #{format('$%02X', @opcode)}" if @instruction.nil?
      end

      # Executes the logic for the current instruction.
      def execute_instruction
        @instruction.execute
      end

      # Reads a byte from the Bus at a given address.
      def bus_read(address)
        byte = @bus.read_byte(address)
        advance_cycles(4)

        byte
      end

      # Requests a Bus write at a given address with a given value.
      def bus_write(address:, value:)
        @bus.write_byte(address, value)
        advance_cycles(4)
      end

      # Emulates CPU internal processing which advance cycles without Bus access.
      def internal_processing
        advance_cycles(4)
      end

      # Syncs all components after each M-cycle.
      def advance_cycles(t_cycles)
        @m_cycles += 1
        @advance_components.call(t_cycles)
      end

      def log(old_pc, instruction)
        return unless @verbose

        $stdout.printf(
          '%<cycles>04d | $%<pc>04X | %<im>-12s (took %<ic>d) | $%<b1>02X $%<b2>02X $%<b3>02X | ' \
          "AF: $%<af>04X BC: $%<bc>04X DE: $%<de>04X HL: $%<hl>04X\n",
          cycles: @m_cycles,
          pc: old_pc,
          im: instruction.mnemonic,
          ic: instruction.m_cycles,
          b1: @bus.read_byte(old_pc),
          b2: @bus.read_byte(old_pc + 1),
          b3: @bus.read_byte(old_pc + 2),
          af: @registers.af,
          bc: @registers.bc,
          de: @registers.de,
          hl: @registers.hl
        )
      end

      # Custom inspect method to facilitate debugging, prevents circular references
      # since all instructions hold the Cpu object and the Cpu holds instruction objects.
      def inspect
        "#<Akane::Gameboy::Cpu @pc=$#{@registers.pc} " \
          "@instructions_size=#{@instructions.compact.size} " \
          "@cb_instructions_size=#{@cb_instructions.compact.size}"
      end
    end
  end
end
