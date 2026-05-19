# frozen_string_literal: true

require 'optparse'

module Akane
  # Handles arguments parsing when launching the emulator.
  class CLI
    def self.parse(arguments)
      # @type var options: emulator_options
      options = {
        audio: nil,
        cycles: nil,
        profiling: nil,
        steps: nil,
        trace: nil,
        video: nil,
        rom_path: nil
      }

      opt_parser = OptionParser.new do |parser|
        parser.banner = 'Usage: akane [options] ROM_PATH'

        parser.on('-a', '--audio=AUDIO', 'Define the audio backend') do |audio|
          options[:audio] = audio
        end

        parser.on('-c', '--cycles=n', Integer, 'Amount of dots to tick') do |n|
          options[:cycles] = n
        end

        parser.on('-p', '--profiling=MODE', 'Enable Stackprof profiling') do |mode|
          options[:profiling] = mode.to_sym
        end

        parser.on('-s', '--steps=n', Integer, 'Amount of CPU steps to run') do |n|
          options[:steps] = n
        end

        parser.on('-t', '--trace=COMPONENT', 'Enable logging for specific component') do |component|
          options[:trace] = component
        end

        parser.on('-v', '--video=VIDEO', 'Define the video backend') do |video|
          options[:video] = video
        end
      end

      opt_parser.parse!(arguments)
      options[:rom_path] = arguments.first
      raise ArgumentError, 'ROM_PATH must be provided' unless options[:rom_path]

      options
    end
  end
end
