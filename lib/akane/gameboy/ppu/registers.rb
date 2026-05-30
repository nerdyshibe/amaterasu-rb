# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Models the behavior of the Ppu registers.
      class Registers
        include Utils::BitOps

        attr_reader :lcdc, :scy, :scx, :ly, :lyc, :bgp, :obp0, :obp1, :wy, :wx

        def initialize(ppu_mode, update_shades, skip_boot_rom: true)
          @ppu_mode = ppu_mode
          @update_shades = update_shades

          @lcdc = skip_boot_rom ? 0x91 : 0x00
          @stat = skip_boot_rom ? 0x85 : 0x00
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

        def lcdc=(value)
          @lcdc = value & 0xFF
        end

        def stat=(value)
          @stat = value & 0xFF
        end

        # Bits: [7][6][5][4][3][2]([1][0])
        #                          @mode
        def stat
          @stat = if @ly == @lyc
                    set_bit(@stat, 2)
                  else
                    clear_bit(@stat, 2)
                  end

          @stat | @ppu_mode.number
        end

        def scy=(value)
          @scy = value & 0xFF
        end

        def scx=(value)
          @scx = value & 0xFF
        end

        def ly=(value)
          @ly = value & 0xFF
        end

        def lyc=(value)
          @lyc = value & 0xFF
        end

        def bgp=(value)
          @bgp = value & 0xFF

          @update_shades.call(@bgp)
        end

        def obp0=(value)
          @obp0 = value & 0xFF
        end

        def obp1=(value)
          @obp1 = value & 0xFF
        end

        def wy=(value)
          @wy = value & 0xFF
        end

        def wx=(value)
          @wx = value & 0xFF
        end
      end
    end
  end
end
