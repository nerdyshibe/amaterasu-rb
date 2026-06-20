# frozen_string_literal: true

module Amaterasu
  module GameBoy
    class Cpu
      # Models the behavior of the SM83 CPU registers.
      #
      # - Contains 8 8-bit core registers.
      # - 8-bit registers can be combined into 16-bit register pair.
      class Registers
        include Utils::BitOps

        # Returns the 8-bit value stored in the A (Accumulator) register.
        attr_reader :a

        # Returns the 8-bit value stored in the F (Flags) register.
        attr_reader :f

        # Returns the 8-bit value stored in the B register.
        attr_reader :b

        # Returns the 8-bit value stored in the C register.
        attr_reader :c

        # Returns the 8-bit value stored in the D register.
        attr_reader :d

        # Returns the 8-bit value stored in the E register.
        attr_reader :e

        # Returns the 8-bit value stored in the H register.
        attr_reader :h

        # Returns the 8-bit value stored in the L register.
        attr_reader :l

        # Returns the 16-bit value stored in the SP (Stack Pointer) register.
        attr_reader :sp

        # Returns the 16-bit value stored in the PC (Program Counter) register.
        attr_reader :pc

        # Sets the initial state of the CPU registers.
        #
        # - The values can change based on the Boot ROM implementation.
        # - If the Boot ROM is not skipped, all values should start as 0.
        def initialize(skip_boot_rom: true)
          @a = skip_boot_rom ? 0x01 : 0x00
          @f = skip_boot_rom ? 0b10110000 : 0b00000000
          @b = 0x00
          @c = skip_boot_rom ? 0x13 : 0x00
          @d = 0x00
          @e = skip_boot_rom ? 0xD8 : 0x00
          @h = skip_boot_rom ? 0x01 : 0x00
          @l = skip_boot_rom ? 0x4D : 0x00

          @sp = skip_boot_rom ? 0xFFFE : 0x0000
          @pc = skip_boot_rom ? 0x0100 : 0x0000
        end

        # Stores a 8-bit value into the A (Accumulator) register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def a=(value)
          @a = value & 0xFF
        end

        # Stores a 8-bit value into the F (Flags) register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        # - The lower nibble is always ignored by the CPU.
        def f=(value)
          @f = value & 0b11110000
        end

        # Stores a 8-bit value into the B register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def b=(value)
          @b = value & 0xFF
        end

        # Stores a 8-bit value into the C register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def c=(value)
          @c = value & 0xFF
        end

        # Stores a 8-bit value into the D register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def d=(value)
          @d = value & 0xFF
        end

        # Stores a 8-bit value into the E register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def e=(value)
          @e = value & 0xFF
        end

        # Stores a 8-bit value into the H register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def h=(value)
          @h = value & 0xFF
        end

        # Stores a 8-bit value into the L register.
        #
        # - CPU ignores any value larger than 255 (0xFF).
        def l=(value)
          @l = value & 0xFF
        end

        # Sets the value of the AF combined 16-bit register.
        #
        # - Higher byte is set into the A register.
        # - Lower byte is set into the F register.
        # - CPU ignores bits 0-3 of the F register.
        def af=(value)
          value &= 0xFFFF
          @a = (value >> 8) & 0xFF
          @f = value & 0xF0
        end

        # Sets the value of the BC combined 16-bit register.
        #
        # - Higher byte is set into the B register.
        # - Lower byte is set into the C register.
        def bc=(value)
          value &= 0xFFFF
          @b = (value >> 8) & 0xFF
          @c = value & 0xFF
        end

        # Sets the value of the DE combined 16-bit register.
        #
        # - Higher byte is set into the D register.
        # - Lower byte is set into the E register.
        def de=(value)
          value &= 0xFFFF
          @d = (value >> 8) & 0xFF
          @e = value & 0xFF
        end

        # Sets the value of the HL combined 16-bit register.
        #
        # - Higher byte is set into the H register.
        # - Lower byte is set into the L register.
        def hl=(value)
          value &= 0xFFFF
          @h = (value >> 8) & 0xFF
          @l = value & 0xFF
        end

        # Sets the value of the SP (Stack Pointer) register.
        #
        # - Points to the memory address in which the Stack is currently located.
        # - If something is pushed into the Stack, the SP is decreased
        # - If something is popped from the Stack, the SP is increased
        def sp=(value)
          @sp = value & 0xFFFF
        end

        # Sets the value of the PC (Program Counter) register.
        #
        # This register points to where in memory is the current instruction.
        # Every time a instruction is fetched and executed,
        # the PC is incremented to fetch the next one.
        def pc=(value)
          @pc = value & 0xFFFF
        end

        # Returns a 16-bit value stored in the combined AF register.
        #
        # - Shifts the byte stored in the A register 8 bits to the left to get the higher byte.
        # - Performs a bitwise OR with the F register value to add the lower byte.
        def af
          (@a << 8) | @f
        end

        # Returns a 16-bit value stored in the combined BC register.
        #
        # - Shifts the byte stored in the B register 8 bits to the left to get the higher byte.
        # - Performs a bitwise OR with the C register value to add the lower byte.
        def bc
          (@b << 8) | @c
        end

        # Returns a 16-bit value stored in the combined DE register.
        #
        # - Shifts the byte stored in the D register 8 bits to the left to get the higher byte.
        # - Performs a bitwise OR with the E register value to add the lower byte.
        def de
          (@d << 8) | @e
        end

        # Returns a 16-bit value stored in the combined HL register.
        #
        # - Shifts the byte stored in the H register 8 bits to the left to get the higher byte.
        # - Performs a bitwise OR with the L register value to add the lower byte.
        def hl
          (@h << 8) | @l
        end

        # Returns the current value of the Zero bit flag.
        #
        # - The Zero flag is Bit 7 of the Flags register.
        def z_flag
          bit(@f, 7)
        end

        # Returns the current value of the Subtraction bit flag.
        #
        # - The Subtraction flag is Bit 6 of the Flags register.
        def n_flag
          bit(@f, 6)
        end

        # Returns the current value of the Half Carry bit flag.
        #
        # - The Half Carry flag is Bit 5 of the Flags register.
        def h_flag
          bit(@f, 5)
        end

        # Returns the current value of the Carry bit flag.
        #
        # - The Carry flag is Bit 4 of the Flags register.
        def c_flag
          bit(@f, 4)
        end

        # Either sets or clears the value of the Zero flag (Bit 7).
        def z_flag=(set)
          @f = set ? set_bit(@f, 7) : clear_bit(@f, 7)
        end

        # Either sets or clears the value of the Subtraction flag (Bit 6).
        def n_flag=(set)
          @f = set ? set_bit(@f, 6) : clear_bit(@f, 6)
        end

        # Either sets or clears the value of the Half Carry flag (Bit 5).
        def h_flag=(set)
          @f = set ? set_bit(@f, 5) : clear_bit(@f, 5)
        end

        # Either sets or clears the value of the Carry flag (Bit 4).
        def c_flag=(set)
          @f = set ? set_bit(@f, 4) : clear_bit(@f, 4)
        end

        # Clears all 4 flags.
        def clear_flags
          @f = 0x00
        end
      end
    end
  end
end
