# frozen_string_literal: true

module Akane
  module GameBoy
    # Models the OAM (Object Attribute Memory) from the DMG Game Boy.
    class Oam < Ram
      START_ADDRESS  = 0xFE00
      END_ADDRESS    = 0xFE9F
      SPRITE_ENTRIES = 40
      SIZE = (END_ADDRESS - START_ADDRESS) + 1 #=> 160 bytes

      def initialize
        super(size: SIZE, offset: START_ADDRESS)

        @sprites = Array.new(SPRITE_ENTRIES) do |sprite_index|
          Sprite.new(oam_data: @data, index: sprite_index)
        end
      end

      def sprite(index)
        @sprites[index]
      end

      def each_sprite(&)
        @sprites.each(&)
      end
    end
  end
end
