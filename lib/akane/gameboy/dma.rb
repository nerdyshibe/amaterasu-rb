# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the RAM chip within the Game Boy.
    #
    # On the real Game Boy, the CPU and DMA share the same physical bus.
    # During DMA, the DMA controller physically takes over the bus lines — the CPU is
    # electrically disconnected from the bus (except HRAM, which is on a separate internal path).
    class DMA
      OAM_START_ADDRESS = 0xFE00
      DMA_START_DELAY = 1
      DMA_TOTAL_CYCLES = 160 + DMA_START_DELAY

      attr_reader :internal_latch

      def initialize(bus, trace_dma: false)
        @bus = bus
        @trace_dma = trace_dma

        @internal_latch = 0xFF
        @source_address = nil
        @target_address = OAM_START_ADDRESS
        @status = :inactive
        @active = false
        @cycles = 0
      end

      # This method is called once per M-cycle, CPU drives this.
      #
      # - DMA transfer 1 byte per M-cycle, totalling 160 bytes.
      # - It fills the OAM memory range from 0xFE00 - 0xFE9F
      # - While DMA is transferring, the CPU should not be able to use the Bus (except for HRAM).
      def tick
        case @status
        when :inactive then nil
        when :pending
          log_state if @trace_dma
          @status = :transferring
          @cycles += 1
        when :transferring
          @active = true
          source_byte = bus_read(address: @source_address)
          bus_write(address: @target_address, value: source_byte)

          log_state if @trace_dma

          @source_address += 1
          @target_address += 1
          @cycles += 1

          @status = :complete if @cycles == DMA_TOTAL_CYCLES
        when :complete
          @cycles = 0
          @source_address = nil
          @target_address = OAM_START_ADDRESS
          @status = :inactive
          @active = false
        end
      end

      def start_transfer(source_value:)
        @internal_latch = source_value
        @source_address = source_value * 0x100
        @status = :pending
        @cycles = 0
      end

      def active?
        @active
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
