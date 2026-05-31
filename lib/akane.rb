# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect('cli' => 'CLI')
loader.inflector.inflect('hal' => 'HAL')
loader.inflector.inflect('sdl2' => 'SDL2')
loader.setup

# Base module to mirror the emulator name and group everything.
module Akane
  VERSION = '0.1'
end
