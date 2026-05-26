# frozen_string_literal: true

module Akane
  module GameBoy
    class Ppu
      # Defines the behavior of the Ppu during OAM Scan mode.
      class OAMScan
        def tick(ppu:)
          puts 'oam scan ticked'
        end
      end
    end
  end
end
