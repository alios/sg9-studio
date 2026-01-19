# SG9 Studio

**Professional broadcast radio/podcast production environment on NixOS**

SG9 Studio is a complete FLOSS (Free/Libre Open Source Software) broadcast studio setup using Ardour 8 DAW with professional voice processing, music ducking, clip launching, and MIDI controller integration.

## What's Inside

This repository contains comprehensive documentation for building and operating a professional broadcast studio using entirely open-source tools:

- **Ardour 8** - Professional DAW with broadcast workflows
- **LSP Plugins** - Modern broadcast-grade audio processing
- **Calf Studio Gear** - Specialized tools (Deesser, Sidechain Compression)
- **x42-plugins** - Professional MIDI routing and transformation
- **TAP/ZAM Plugins** - Alternative dynamics processors
- **NixOS** - Declarative, reproducible system configuration

## Documentation

### 📘 [STUDIO.md](STUDIO.md)
**Complete setup and operational manual** (2,953 lines)

Everything you need to build and run SG9 Studio:
- Hardware setup (Focusrite Vocaster Two, MIDI controllers)
- Ardour session architecture (19 tracks, 4 buses)
- Voice processing chains (Gate → EQ → De-esser → Compressor → Limiter)
- Music ducking with sidechain compression
- Clip launching for jingles/SFX
- MIDI integration (Korg nanoKONTROL, Novation Launchpad)
- Quick reference tables
- Troubleshooting guides

### 🔬 [broadcast-studio-research.md](broadcast-studio-research.md)
**Technical specifications and plugin verification** (729 lines)

Verified plugin documentation with official sources:
- Complete plugin lists for LSP, Calf, TAP, ZAM suites
- Exact parameters with ranges and recommendations
- De-essing methods comparison (5 approaches)
- Installation commands (NixOS, Arch, Debian/Ubuntu)
- Plugin selection rationale
- Links to official documentation

## Quick Start

```bash
# NixOS (add to configuration.nix)
environment.systemPackages = with pkgs; [
  ardour
  lsp-plugins
  calf
  tap-plugins
  zam-plugins
  x42-plugins
];

# Or install imperatively
nix-env -iA nixos.ardour nixos.lsp-plugins nixos.calf \
             nixos.tap-plugins nixos.zam-plugins nixos.x42-plugins
```

Then read [STUDIO.md](STUDIO.md) Section 2 for complete setup instructions.

## Key Features

- **Professional Voice Processing**: Broadcast-standard chain with verified LSP/Calf plugins
- **Music Ducking**: Automatic background music reduction during voice
- **Clip Launching**: Quick-fire jingles and sound effects
- **MIDI Control**: Hardware integration for faders, transport, and clip triggering
- **True Peak Limiting**: ITU-R BS.1770 compliant broadcast loudness
- **Session Persistence**: Save/load complete studio state
- **100% FLOSS**: No proprietary software required

## Hardware Requirements

- **Audio Interface**: Focusrite Vocaster Two (or similar 2-in/2-out USB interface)
- **MIDI Controllers** (optional): Korg nanoKONTROL Studio, Novation Launchpad Pro Mk2
- **Microphones**: Dynamic broadcast mics (Shure SM7B, Electro-Voice RE20, etc.)
- **OS**: NixOS x86-64 (documentation includes Arch/Debian alternatives)

## Use Cases

- Radio broadcast studios
- Podcast production
- Voice-over recording
- Live streaming with music beds
- Multi-guest remote interviews
- Sound design with organized SFX libraries

## License

Documentation in this repository is provided as-is for educational and reference purposes.

All referenced software (Ardour, LSP, Calf, TAP, ZAM, x42) maintains its own licenses:
- Ardour: GPL-2.0
- LSP Plugins: LGPL-3.0
- Calf Studio Gear: LGPL-2.1
- TAP Plugins: GPL-2.0
- ZAM Plugins: GPL-2.0
- x42-plugins: GPL-2.0

## Getting Help

1. Read [STUDIO.md](STUDIO.md) for step-by-step setup
2. Check [broadcast-studio-research.md](broadcast-studio-research.md) for plugin specs
3. See Section 12 in STUDIO.md for Quick Reference tables
4. Consult official plugin documentation (links in research doc)

## Contributing

Found an error or improvement? This documentation is based on verified plugin specifications from official sources. Please verify against official docs before suggesting changes.

---

**Last Updated**: January 2026  
**Verified Against**: LSP Plugins 1.2.26+, Calf 0.90.9+, Ardour 8.x, x42-plugins 20251025
