# frozen_string_literal: true

require 'optparse'

module Akane
  # Handles arguments parsing when launching the emulator.
  class CLI
    def self.parse(arguments)
      options = { verbose: false, debug: false, audio: nil, video: nil }

      opt_parser = OptionParser.new do |parser|
        parser.banner = 'Usage: akane [options] ROM_PATH'

        parser.on('-d', '--debug', 'Enable debug mode') do
          options[:debug] = true
        end

        parser.on('-l', '--logs', 'Enable verbose mode') do
          options[:verbose] = true
        end

        parser.on('-a', '--audio=AUDIO', 'Define the audio backend') do |audio|
          options[:audio] = audio
        end

        parser.on('-v', '--video=VIDEO', 'Define the video backend') do |video|
          options[:video] = video
        end
      end

      opt_parser.parse!(arguments)
      options[:rom_path] = arguments.first
      options
    end
  end
end
