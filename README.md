<div align="center">
  <h1 style="font-size: 3em; font-weight: bold;">Akane</h1>
  <p>A <s>cycle-accurate?</s> Game Boy emulator written in Ruby.</p>
</div>

---

## About

This is, at its core, a research project. I always loved the concept of emulation and retro gaming, but as a web developer, low level development was never my strong suit. This is my first deep dive into the subject and it has been a great experience so far.

I will try to document my progress as I try to create the emulator from the ground up (as cycle accurate as I can make it), this also helps me internalize some of the concepts about hardware emulation. I am finding it extremely challenging, but also very rewarding when your code actually behaves as the hardware would. I highly recommend for whoever is interested in learning those subjects.

## Resources

I'm heavily relying on the great work done by the community to document every possible (and obscure) behaviours that can be found in the Game Boy. I'll place here all the resources I'm using and some other relevant ones I find.

### Docs

- **[Pan Docs](https://gbdev.io/pandocs/)**: The single most comprehensive technical reference for the Game Boy. An absolute must-read.
- **[GB: Complete Technical Reference](https://gekkio.fi/files/gb-docs/gbctr.pdf)**: Great documentation about how the Game Boy hardware behaves, including some of the most obscure behaviors.
- **[The Ultimate Game Boy Talk](https://www.youtube.com/watch?v=HyzD8pNlpwI)**: An amazing talk that provides a high-level overview of the hardware architecture.
- **[GBDev Community](https://gbdev.io/)**: A fantastic hub for documentation, forums, and tools related to Game Boy development.

### Tests

- **[Mooneye Test Suite](https://github.com/Gekkio/mooneye-test-suite)**: Very complete suite of ROMs to test pretty much all aspects of the Game Boy.
- **[Blargg's Test ROMs](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)**: A suite of essential test ROMs for verifying the accuracy of CPU instructions, timing, and memory access.
- **[Game Boy Test Roms](https://github.com/c-sp/game-boy-test-roms)**: A collection of different test suites for your Game Boy emulator, also has a [Wiki](https://deepwiki.com/c-sp/game-boy-test-roms/1-overview).

### Emulators

- **[Mooneye GB](https://github.com/Gekkio/mooneye-gb)**: Very accurate Game Boy emulator written in Rust.

## Current Progress

Here is a snapshot of the current implementation status of the Game Boy's hardware components.

### Address Bus

- [x] Delegates the memory read and write to the correct components.
- [ ] Pending wire PPU/APU registers addresses.

### CPU

- [x] All base opcodes implemented with the correct timing.
- [x] All CB prefixed opcodes implemented with the correct timing.
- [x] Interrupts handling (IME, IE, IF registers and service routines).

### Timer

- [x] All registers correctly implemented.
- [x] TIMA overflow logic implemented.

### Serial Port

- [x] Correctly implemented the behavior for registers SC and SB.
- [x] Captures the message received to a message buffer to allow printing.
- [x] Requests serial interrupt when transfer is completed.

## Accuracy Checks

### Blargg Tests

- [x] (Passed) `cpu_instrs/01-special.gb`
- [x] (Passed) `cpu_instrs/02-interrupts.gb`
- [x] (Passed) `cpu_instrs/03-op sp,hl.gb`
- [x] (Passed) `cpu_instrs/04-op r,imm.gb`
- [x] (Passed) `cpu_instrs/05-op rp.gb`
- [x] (Passed) `cpu_instrs/06-ld r,r.gb`
- [x] (Passed) `cpu_instrs/07-jr,jp,call,ret,rst.gb`
- [x] (Passed) `cpu_instrs/08-misc instrs.gb`
- [x] (Passed) `cpu_instrs/09-op r,r.gb`
- [x] (Passed) `cpu_instrs/10-bit ops.gb`
- [x] (Passed) `cpu_instrs/11-op a,(hl).gb`
- [x] (Passed) `instr_timing.gb`
- [x] (Passed) `mem_timing/01-read_timing.gb`
- [x] (Passed) `mem_timing/02-write_timing.gb`
- [x] (Passed) `mem_timing/03-modify_timing.gb`
- [x] (Passed) `mem_timing_2/01-read_timing.gb`
- [x] (Passed) `mem_timing_2/02-write_timing.gb`
- [x] (Passed) `mem_timing_2/03-modify_timing.gb`
- [ ] (Pending) `interrupt_time.gb`
- [ ] (Pending) `halt_bug.gb`
- [ ] (Pending) `dmg_sound.gb`