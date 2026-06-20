# frozen_string_literal: true

module Amaterasu
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
                    :wx,
                    :bg_palettes,
                    :sprite_palettes0,
                    :sprite_palettes1

        # @param skip_boot_rom [Boolean]
        def initialize(interrupts, skip_boot_rom: true)
          @lcdc = LcdControl.new(skip_boot_rom:)
          @stat = LcdStatus.new(interrupts, skip_boot_rom:)
          @scy  = 0x00
          @scx  = 0x00
          @ly   = 0x00
          @lyc  = 0x00
          @bgp  = skip_boot_rom ? 0xFC : 0x00
          @obp0 = 0x00
          @obp1 = 0x00
          @wy   = 0x00
          @wx   = 0x00

          @bg_palettes = [
            @bgp & 0b11,
            (@bgp >> 2) & 0b11,
            (@bgp >> 4) & 0b11,
            (@bgp >> 6) & 0b11
          ]

          @sprite_palettes0 = [
            @obp0 & 0b11,
            (@obp0 >> 2) & 0b11,
            (@obp0 >> 4) & 0b11,
            (@obp0 >> 6) & 0b11
          ]

          @sprite_palettes1 = [
            @obp1 & 0b11,
            (@obp1 >> 2) & 0b11,
            (@obp1 >> 4) & 0b11,
            (@obp1 >> 6) & 0b11
          ]
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

          @bg_palettes[0] = @bgp & 0b11
          @bg_palettes[1] = (@bgp >> 2) & 0b11
          @bg_palettes[2] = (@bgp >> 4) & 0b11
          @bg_palettes[3] = (@bgp >> 6) & 0b11
        end

        # @param value [Integer]
        def obp0=(value)
          @obp0 = value & 0xFF

          @sprite_palettes0[0] = @obp0 & 0b11
          @sprite_palettes0[1] = (@obp0 >> 2) & 0b11
          @sprite_palettes0[2] = (@obp0 >> 4) & 0b11
          @sprite_palettes0[3] = (@obp0 >> 6) & 0b11
        end

        # @param value [Integer]
        def obp1=(value)
          @obp1 = value & 0xFF

          @sprite_palettes1[0] = @obp1 & 0b11
          @sprite_palettes1[1] = (@obp1 >> 2) & 0b11
          @sprite_palettes1[2] = (@obp1 >> 4) & 0b11
          @sprite_palettes1[3] = (@obp1 >> 6) & 0b11
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
