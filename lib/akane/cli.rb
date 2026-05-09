# frozen_string_literal: true

module Akane
  # Handles arguments parsing when launching the emulator.
  class CLI
    def self.run(arguments)
      rom_path = arguments.first.split('=').last
      puts "Arguments used: #{arguments}"

      Emulator.start(rom_path)
    end
  end
end
