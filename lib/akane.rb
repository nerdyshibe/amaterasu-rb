# frozen_string_literal: true

require_relative 'akane/hal/sdl2/bindings'
require_relative 'akane/hal/sdl2'
require_relative 'akane/version'
require_relative 'akane/cli'
require_relative 'akane/emulator'
require_relative 'akane/cartridge'
require_relative 'akane/cartridge/rom'
require_relative 'akane/utils/bit_ops'
require_relative 'akane/gameboy/apu'
require_relative 'akane/gameboy/bus'
require_relative 'akane/gameboy/dma'
require_relative 'akane/gameboy/interrupts'
require_relative 'akane/gameboy/joypad'
require_relative 'akane/gameboy/ppu/modes/drawing'
require_relative 'akane/gameboy/ppu/modes/h_blank'
require_relative 'akane/gameboy/ppu/modes/oam_scan'
require_relative 'akane/gameboy/ppu/modes/v_blank'
require_relative 'akane/gameboy/ppu/modes'
require_relative 'akane/gameboy/ppu/registers'
require_relative 'akane/gameboy/ppu'
require_relative 'akane/gameboy/ram'
require_relative 'akane/gameboy/serial'
require_relative 'akane/gameboy/timer'
require_relative 'akane/gameboy/cpu/instructions/base'

Dir.glob("#{__dir__}/akane/gameboy/cpu/instructions/*.rb").each do |file|
  require file
end

require_relative 'akane/gameboy/cpu/instructions'
require_relative 'akane/gameboy/cpu/registers'
require_relative 'akane/gameboy/cpu'
