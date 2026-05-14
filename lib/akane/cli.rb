# frozen_string_literal: true

require 'optparse'

module Akane
  # Handles arguments parsing when launching the emulator.
  class CLI
    def self.parse(arguments)
      options = { verbose: false, audio: nil, video: nil }

      opt_parser = OptionParser.new do |parser|
        parser.banner = 'Usage: akane [options] ROM_PATH'

        parser.on('-l', '--logs', 'Enable verbose mode') do
          options[:verbose] = true
        end

        parser.on('-a', '--audio=AUDIO', 'Define the audio backend') do |audio|
          options[:audio] = audio
        end

        parser.on('-r', '--rom=ROM_PATH', 'path/to/the/rom.gb file') do |rom|
          options[:rom] = rom
        end

        parser.on('-v', '--video=VIDEO', 'Define the video backend') do |video|
          options[:video] = video
        end
      end

      opt_parser.parse!(arguments)
      options
    end
  end
end
