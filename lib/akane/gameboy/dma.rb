# frozen_string_literal: true

module Akane
  module Gameboy
    # Models the RAM chip within the Game Boy.
    #
    # On the real Game Boy, the CPU and DMA share the same physical bus.
    # During DMA, the DMA controller physically takes over the bus lines — the CPU is
    # electrically disconnected from the bus (except HRAM, which is on a separate internal path).
    # Both are clocked by the same 4MHz crystal, and each
    class DMA
      OAM_START_ADDRESS = 0xFE00
      DMA_START_DELAY = 1
      DMA_TOTAL_CYCLES = 160 + DMA_START_DELAY

      # Receiving value 0xC0
      def initialize(trace_dma: false)
        @trace_dma = trace_dma

        @source_address = nil
        @target_address = OAM_START_ADDRESS
        @status = :inactive
        @dma_delay = false
        @cycles = 0
      end

      # This method is called once per M-cycle, Cpu drives this.
      #
      # - DMA uses the bus to transfer one byte
      # - CPU can still execute from HRAM (it doesn't need the bus for that)
      def tick
        case @status
        when :inactive then nil
        when :pending
          log_state if @trace_dma
          @status = :transfer
          @cycles += 1
        when :transfer
          source_byte = bus_read(address: @source_address)
          bus_write(address: @target_address, value: source_byte)

          log_state if @trace_dma

          @source_address += 1
          @target_address += 1
          @cycles += 1

          if @cycles == DMA_TOTAL_CYCLES
            @cycles = 0
            @source_address = nil
            @target_address = OAM_START_ADDRESS
            @status = :inactive
          end
        end
      end

      def start_transfer(bus:, source_value:)
        @bus = bus
        @source_address = source_value * 0x100
        @status = :pending
      end

      def active?
        @status == :transfer
      end

      def bus_read(address:)
        @bus.read_byte(address:)
      end

      def bus_write(address:, value:)
        @bus.write_byte(address:, value:)
      end

      def log_state
        if @cycles.zero?
          puts 'DMA: #000 || START DELAY'
        else
          $stdout.printf(
            "DMA: #%<n>03d || $%<sa>04X ($%<sb>02X) -> $%<ta>04X ($%<tb>02X)\n",
            n: @cycles,
            sa: @source_address,
            sb: @bus.read_byte(address: @source_address),
            ta: @target_address,
            tb: @bus.read_byte(address: @target_address)
          )
        end
      end
    end
  end
end
