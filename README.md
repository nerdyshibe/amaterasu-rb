<div align="center">
  <h1 style="font-size: 3em; font-weight: bold;">Akane</h1>
  <p>A <s>cycle-accurate?</s> Game Boy emulator written in Ruby.</p>
</div>

---

## 📖 About

This is, at its core, a research project. I always loved the concept of emulation and retro gaming, but as a web developer, low level development was never my strong suit. This is my first deep dive into the subject and it has been a great experience so far.

I will try to document my progress as I try to create the emulator from the ground up (as cycle accurate as I can make it), this also helps me internalize some of the concepts about hardware emulation. I am finding it extremely challenging, but also very rewarding when your code actually behaves as the hardware would. I highly recommend for whoever is interested in learning those subjects.

## 📚 Resources & Documentation

I'm heavily relying on the great work done by the community to document every possible (and obscure) behaviours that can be found in the Game Boy. I'll place here all the resources I'm using and some other relevant ones I find.

- **[Pan Docs](https://gbdev.io/pandocs/)**: The single most comprehensive technical reference for the Game Boy. An absolute must-read.
- **[Blargg's Test ROMs](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)**: A suite of essential test ROMs for verifying the accuracy of CPU instructions, timing, and memory access.
- **[The Ultimate Game Boy Talk](https://www.youtube.com/watch?v=HyzD8pNlpwI)**: An amazing talk that provides a high-level overview of the hardware architecture.
- **[GBDev Community](https://gbdev.io/)**: A fantastic hub for documentation, forums, and tools related to Game Boy development.

## ✨ My Progress

Here is a snapshot of the current implementation status of the Game Boy's hardware components.

### 🚌 Address Bus

- [x] Default ROM/RAM bank read/write implemented
- [x] VRAM, WRAM and Echo RAM read/write implemented
- [ ] MBC ROM/RAM Banks not implemented yet
- [ ] Missing some hardware registers to be mapped

### ⚙️ CPU (Sharp SM83 Core)

- [x] All instructions implemented with correct timings
- [x] Interrupts handling (IME, IE, IF registers and service routines)

### ⏳ Timer

- [x] All registers correctly implemented
- [x] TIMA overflow logic implemented
- [ ] Obscure behaviours
