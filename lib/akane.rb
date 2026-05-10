# frozen_string_literal: true

require_relative 'akane/cli'
require_relative 'akane/emulator'
require_relative 'akane/cartridge'
require_relative 'akane/cartridge/rom'
require_relative 'akane/gameboy/apu'
require_relative 'akane/gameboy/bus'
require_relative 'akane/gameboy/interrupts'
require_relative 'akane/gameboy/joypad'
require_relative 'akane/gameboy/ppu'
require_relative 'akane/gameboy/ram'
require_relative 'akane/gameboy/serial'
require_relative 'akane/gameboy/timer'
require_relative 'akane/gameboy/cpu/instructions/loads'
require_relative 'akane/gameboy/cpu/instructions'
require_relative 'akane/gameboy/cpu/registers'
require_relative 'akane/gameboy/cpu'

# Base container for all Library modules and classes
module Akane
  VERSION = 0.1
end
