# frozen_string_literal: true

module Amaterasu
  module GameBoy
    # Models the CPU behavior from the Game Boy.
    class Cpu
      attr_reader :registers, :m_cycles

      def initialize(bus, hram, interrupts, advance_cycle, trace_cpu: false)
        @bus = bus
        @hram = hram
        @interrupts = interrupts
        @advance_cycle = advance_cycle
        @trace_cpu = trace_cpu

        @registers = Registers.new
        @ime = false
        @ime_scheduled = false
        @halted = false
        @opcode = nil
        @instruction = nil

        @m_cycles = 0

        @instructions = Instructions.load_base_instructions(cpu: self)
        @cb_instructions = Instructions.load_cb_instructions(cpu: self)
      end

      # Core CPU loop:
      #
      # - Checks IME and any interrupts pending to be serviced.
      # - Fetches the current Opcode at the Program Counter.
      # - Decodes which instruction based on the Opcode fetched.
      # - Executes the instruction.
      def step
        if @interrupts.any_pending?
          @halted = false if @halted

          if @ime
            handle_interrupts
            return
          end
        end

        if @ime_scheduled
          @ime = true
          @ime_scheduled = false
        end

        if @halted
          @m_cycles = @advance_cycle.call
          return
        end

        old_pc = @registers.pc
        old_cycles = @m_cycles
        @opcode = fetch_next_byte
        decode_instruction
        execute_instruction
        log_state(old_pc, old_cycles, @instruction)
      end

      # Reads a byte from the Bus at a given address.
      def bus_read(address:)
        byte = @bus.read_byte(address:, caller: self)
        @m_cycles = @advance_cycle.call

        byte
      end

      # Requests a Bus write at a given address with a given value.
      def bus_write(address:, value:)
        @bus.write_byte(address:, value:, caller: self)
        @m_cycles = @advance_cycle.call
      end

      # Fetches the next immediate byte from memory pointed to by the Program Counter.
      # Every time a byte is fetched, the PC is incremented by 1.
      def fetch_next_byte
        byte = bus_read(address: @registers.pc)
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

      # Pushes a 16-bit value into the Stack.
      #
      # @param value [Integer] 16-bit value to be stored in the Stack.
      def stack_push(value:)
        @registers.sp -= 1
        bus_write(address: @registers.sp, value: (value >> 8) & 0xFF)
        @registers.sp -= 1
        bus_write(address: @registers.sp, value: value & 0xFF)
      end

      # Pops a 16-bit value from the Stack.
      def stack_pop
        lsb = bus_read(address: @registers.sp)
        @registers.sp += 1
        msb = bus_read(address: @registers.sp)
        @registers.sp += 1

        (msb << 8) | lsb
      end

      # Jumps execution to a given address by setting the address value into the PC.
      #
      # @param address [Integer] 16-bit memory address value.
      def jump_to(address:)
        @registers.pc = address
        internal_processing
      end

      # Converts an unsigned byte into a value between -128 to 127 to use as an offset.
      #
      # @param byte [Integer] 8-bit unsigned value.
      def sign_value(byte)
        byte >= 128 ? (byte - 256) : byte
      end

      # Performs an addition envolving a 16-bit value,
      # CPU consumes an additional cycle to handle 16-bit values.
      def add16(value1, value2)
        result = value1 + value2
        internal_processing

        result
      end

      # Performs a subtraction envolving a 16-bit value,
      # CPU consumes an additional cycle to handle 16-bit values.
      def sub16(value1, value2)
        result = value1 - value2
        internal_processing

        result
      end

      # Used by the DI instruction.
      def disable_interrupts
        @ime = false
      end

      # Used by the EI instruction.
      def enable_interrupts
        @ime_scheduled = true
      end

      def halt
        @halted = true
      end

      # Emulates CPU internal processing which advance cycles without Bus access.
      def internal_processing
        @m_cycles = @advance_cycle.call
      end

      private

      # Is only called if IME and any interrupt is pending.
      # Takes 5 cycles to complete.
      def handle_interrupts
        @m_cycles = @advance_cycle.call
        @m_cycles = @advance_cycle.call
        @ime = false
        stack_push(value: @registers.pc)
        address_vector = @interrupts.priority_vector
        @interrupts.priority_service
        jump_to(address: address_vector)
      end

      # Determines which instruction should be executed for each Opcode.
      def decode_instruction
        if @opcode == 0xCB
          @opcode = fetch_next_byte
          @instruction = @cb_instructions[@opcode]
        else
          @instruction = @instructions[@opcode]
        end
      end

      # Executes the logic for the current instruction.
      def execute_instruction
        @instruction.execute
      end

      def log_state(old_pc, old_cycles, instruction)
        return unless @trace_cpu

        $stdout.printf(
          '%<cycles>04d | PC: $%<pc>04X | %<im>-14s (took %<ic>d) | ' \
          '$%<b1>02X $%<b2>02X $%<b3>02X | F: %<f>04b | ' \
          "A: $%<a>02X BC: $%<bc>04X DE: $%<de>04X HL: $%<hl>04X | [HL]: $%<mem_hl>02X\n",
          cycles: @m_cycles,
          pc: old_pc,
          im: instruction.mnemonic,
          ic: @m_cycles - old_cycles,
          b1: @bus.read_byte(address: old_pc),
          b2: @bus.read_byte(address: old_pc + 1),
          b3: @bus.read_byte(address: old_pc + 2),
          f: @registers.f >> 4,
          a: @registers.a,
          bc: @registers.bc,
          de: @registers.de,
          hl: @registers.hl,
          mem_hl: @bus.read_byte(address: @registers.hl)
        )
      end

      # Custom inspect method to facilitate debugging, prevents circular references
      # since all instructions hold the Cpu object and the Cpu holds instruction objects.
      def inspect
        '#<Amaterasu::GameBoy::Cpu ' \
          "@pc=$#{@registers.pc} " \
          "@instructions_size=#{@instructions.compact.size} " \
          "@cb_instructions_size=#{@cb_instructions.compact.size}>"
      end
    end
  end
end
