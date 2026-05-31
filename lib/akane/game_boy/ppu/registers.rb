# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the behavior of the PPU registers.
      class Registers
        attr_reader :lcdc,
                    :stat,
                    :scy,
                    :scx,
                    :ly,
                    :lyc,
                    :bgp,
                    :obp0,
                    :obp1,
                    :wy,
                    :wx

        # @param update_shades [Proc] Updates shade values when BGP is written
        def initialize(update_shades, skip_boot_rom: true)
          @update_shades = update_shades

          @lcdc = LcdControl.new(skip_boot_rom:)
          @stat = LcdStatus.new(skip_boot_rom:)
          @scy  = 0x00
          @scx  = 0x00
          @ly   = 0x00
          @lyc  = 0x00
          @bgp  = 0x00
          @obp0 = 0x00
          @obp1 = 0x00
          @wy   = 0x00
          @wx   = 0x00
        end

        # @param value [Integer]
        def lcdc=(value)
          @lcdc.value = value
        end

        # @param value [Integer]
        def stat=(value)
          @stat.value = value
        end

        # @param value [Integer]
        def scy=(value)
          @scy = value & 0xFF
        end

        # @param value [Integer]
        def scx=(value)
          @scx = value & 0xFF
        end

        # @param value [Integer]
        def ly=(value)
          @ly = value & 0xFF
        end

        # @param value [Integer]
        def lyc=(value)
          @lyc = value & 0xFF
        end

        # @param value [Integer]
        def bgp=(value)
          @bgp = value & 0xFF

          @update_shades.call(@bgp)
        end

        # @param value [Integer]
        def obp0=(value)
          @obp0 = value & 0xFF
        end

        # @param value [Integer]
        def obp1=(value)
          @obp1 = value & 0xFF
        end

        # @param value [Integer]
        def wy=(value)
          @wy = value & 0xFF
        end

        # @param value [Integer]
        def wx=(value)
          @wx = value & 0xFF
        end
      end
    end
  end
end
