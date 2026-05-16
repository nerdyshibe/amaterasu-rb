# frozen_string_literal: true

require 'optparse'

module Akane
  # Handles arguments parsing when launching the emulator.
  class CLI
    def self.parse(arguments)
      options = {
        audio: nil,
        cycles: nil,
        debug: false,
        profile: nil,
        steps: nil,
        trace: nil,
        video: nil
      }

      opt_parser = OptionParser.new do |parser|
        parser.banner = 'Usage: akane [options] ROM_PATH'

        parser.on('-a', '--audio=AUDIO', 'Define the audio backend') do |audio|
          options[:audio] = audio
        end

        parser.on('-c', '--cycles=n', Integer, 'Amount of dots to tick') do |n|
          options[:cycles] = n
        end

        parser.on('-d', '--debug', 'Enable debug mode for serial port output') do
          options[:debug] = true
        end

        parser.on('-p', '--profile=MODE', 'Enable Stackprof profiling') do |mode|
          options[:profile] = mode.to_sym
        end

        parser.on('-s', '--steps=n', Integer, 'Amount of CPU steps to run') do |n|
          options[:steps] = n
        end

        parser.on('-t', '--trace=COMPONENTS', 'Enable logging for specific components') do |values|
          options[:trace] = values.split(',')
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
