<div align="center">
  <h1 style="font-size: 3em; font-weight: bold;">Akane</h1>
  <p>A <s>cycle-accurate?</s> Game Boy emulator written in Ruby.</p>
</div>

---

## About

This is, at its core, a research project. I always loved the concept of emulation and retro gaming, but as a web developer, low level development was never my strong suit. This is my first deep dive into the subject and it has been a great experience so far.

I will try to document my progress as I try to create the emulator from the ground up (as cycle accurate as I can make it), this also helps me internalize some of the concepts about hardware emulation. I am finding it extremely challenging, but also very rewarding when your code actually behaves as the hardware would. I highly recommend for whoever is interested in learning those subjects.

### Goals

- Build a fully cycle-accurate emulator and try to replicate all the hardware quirks
- Pass all the accuracy tests I can find and also document the progress of Passed/Failed tests
- Try to optimize performance in all ways possible without losing code readability

## Resources

I'm heavily relying on the great work done by the community to document every possible (and obscure) behaviors that can be found in the Game Boy. I'll place here all the resources I'm using and some other relevant ones I find.

### Docs

- **[Pan Docs](https://gbdev.io/pandocs/)**: The single most comprehensive technical reference for the Game Boy. An absolute must-read.
- **[Opcode Table](https://gbdev.io/gb-opcodes/optables/)**: Complete Opcode table for the Game Boy CPU instruction set.
- **[RGBDS Docs](https://rgbds.gbdev.io/docs/v1.0.1/gbz80.7)**: Game Boy CPU instruction reference.
- **[GB: Complete Technical Reference](https://gekkio.fi/files/gb-docs/gbctr.pdf)**: Great documentation about how the Game Boy hardware behaves, including some of the most obscure behaviors.
- **[The Ultimate Game Boy Talk](https://www.youtube.com/watch?v=HyzD8pNlpwI)**: An amazing talk that provides a high-level overview of the hardware architecture.
- **[GBDev Community](https://gbdev.io/)**: A fantastic hub for documentation, forums, and tools related to Game Boy development.

### Tests

- **[Mooneye Test Suite](https://github.com/Gekkio/mooneye-test-suite)**: Very complete suite of ROMs to test pretty much all aspects of the Game Boy.
- **[Blargg's Test ROMs](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)**: A suite of essential test ROMs for verifying the accuracy of CPU instructions, timing, and memory access.
- **[Game Boy Test Roms](https://github.com/c-sp/game-boy-test-roms)**: A collection of different test suites for your Game Boy emulator, also has a [Wiki](https://deepwiki.com/c-sp/game-boy-test-roms/1-overview).

### Other Emulators

- **[SameBoy](https://github.com/LIJI32/SameBoy)**: Open source Game Boy (DMG) and Game Boy Color (CGB) emulator, written in portable C.
- **[Mooneye GB](https://github.com/Gekkio/mooneye-gb)**: A Game Boy research project and emulator written in Rust.
- **[LLD_gbemu](https://github.com/rockytriton/LLD_gbemu)**: A Game Boy emulator written in C as part of the Low Level Dev tutorial.
- **[Rubyboy](https://github.com/sacckey/rubyboy)**: A Game Boy emulator written in Ruby.

## Current Progress

Here is a snapshot of the current implementation status of the Game Boy's hardware components.

### Address Bus

- [x] Receives all components by dependency injection.
- [x] Creates a public API with read_byte and write_byte methods.
- [x] Delegates the memory read and write to the correct components.
- [x] Correctly mapped the address range for the Cartridge, External RAM, VRAM, Echo RAM, OAM, HRAM and most of the IO registers.
- [ ] Still pending to wire and implement all the APU registers.

### CPU

- [x] All base opcodes implemented with the correct timing.
- [x] All CB prefixed opcodes implemented with the correct timing.
- [x] Interrupts handling (IME, IE, IF registers and service routines).

### Timer

- [x] Resets the value of the internal counter on any write to DIV.

### DMA Controller

- [x] Correctly latches the value used to start the transfer, if $FF46 is read return this value.
- [x] Correctly implemented the 1 cycle delay before starting the actual transfer.
- [x] Correctly implemented the 160 cycles (1 byte per cycle) transfer.
- [x] Correctly implemented the Bus locking mechanism, whila DMA is active, the CPU should only be able to read/write in the IO + HRAM address range (0xFF00 - 0xFFFF).
- [x] Correctly implemented the DMA restart logic, should reset the cycles to 0, source address to the new source * $100 and target address to 0xFE00.

### Serial Port

- [x] Correctly implemented the behavior for registers SC and SB.
- [x] Captures the message received to a message buffer to allow printing.
- [x] Requests serial interrupt when transfer is completed.

## Accuracy Checks

| Suite    | Passed | Failed   | Total  |
|:---------|-------:|---------:|-------:|
| Blargg   |   18   |    3     |   21   |
| Mooneye  |    -   |    -     |    -   |


### Blargg Tests

| Test                                  |  Status  |
|---------------------------------------|:--------:|
| `cpu_instrs/01-special.gb`            |    ✅    |
| `cpu_instrs/02-interrupts.gb`         |    ✅    |
| `cpu_instrs/03-op sp,hl.gb`           |    ✅    |
| `cpu_instrs/04-op r,imm.gb`           |    ✅    |
| `cpu_instrs/05-op rp.gb`              |    ✅    |
| `cpu_instrs/06-ld r,r.gb`             |    ✅    |
| `cpu_instrs/07-jr,jp,call,ret,rst.gb` |    ✅    |
| `cpu_instrs/08-misc instrs.gb`        |    ✅    |
| `cpu_instrs/09-op r,r.gb`             |    ✅    |
| `cpu_instrs/10-bit ops.gb`            |    ✅    |
| `cpu_instrs/11-op a,(hl).gb`          |    ✅    |
| `instr_timing.gb`                     |    ✅    |
| `mem_timing/01-read_timing.gb`        |    ✅    |
| `mem_timing/02-write_timing.gb`       |    ✅    |
| `mem_timing/03-modify_timing.gb`      |    ✅    |
| `mem_timing_2/01-read_timing.gb`      |    ✅    |
| `mem_timing_2/02-write_timing.gb`     |    ✅    |
| `mem_timing_2/03-modify_timing.gb`    |    ✅    |
| `interrupt_time.gb`                   |    ❌    |
| `halt_bug.gb`                         |    ❌    |
| `dmg_sound.gb`                        |    ❌    |
