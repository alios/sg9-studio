# SG9 Studio

**Professional broadcast radio/podcast production environment on NixOS**

SG9 Studio is a complete FLOSS broadcast studio setup using Ardour 8 with professional voice
processing, music ducking, clip launching, and MIDI controller integration.

## What's Inside

This repository contains a single, authoritative manual for building and operating the studio:

- **Ardour 8** - Professional DAW with broadcast workflows
- **LSP Plugins** - Modern broadcast-grade audio processing
- **Calf Studio Gear** - De-essing and sidechain compression
- **ZAM Plugins** - Alternative dynamics processors
- **x42-plugins** - MIDI routing and transformation
- **NixOS** - Declarative, reproducible system configuration

## Documentation

### 🚨 [HMI-IMPLEMENTATION-GUIDE.md](docs/HMI-IMPLEMENTATION-GUIDE.md)

**Professional broadcast HMI improvements - Installation & Testing**

Complete guide to implementing Phase 1 critical features:
- PANIC button macro (F1 emergency switch to music)
- Auto-arm tracks on session load
- Transport LED feedback on Launchpad
- Backup recording tracks (Master Bus Record, Mix-Minus Record)
- VCA layer switching for nanoKONTROL
- Auto mix-minus routing configuration

**Based on research:** DHD Audio, Lawo diamond, Wheatstone LXE, Axia Livewire+

### 🎨 [COLOR-SCHEMA-STANDARD.md](docs/COLOR-SCHEMA-STANDARD.md)

**Consistent color vocabulary across all interfaces**

Systematic color coding based on professional broadcast HMI research:
- Pre-attentive perception (color → function recognition)
- Ardour track colors, Launchpad LED mappings, visual feedback
- Red = Voice, Blue = Guest, Green = Music, Yellow = SFX
- State indicators: Armed (solid), Recording (pulse), Muted (orange)

**Implements best practices from:** Lawo diamond, DHD Audio, Wheatstone LXE

### 📘 [STUDIO.md](STUDIO.md)

**Complete setup and operational manual**

Includes:

- Hardware setup (Focusrite Vocaster Two, MIDI controllers)
- Ardour session architecture and monitoring model
- Processing chains and canonical plugin order
- Music ducking with sidechain compression
- Clip launching for jingles/SFX
- MIDI integration (Korg nanoKONTROL, Novation Launchpad)
- Loudness targets, LRA guidance, and metering
- Troubleshooting and appendices

### 📡 [MIX-MINUS-OPERATIONS.md](docs/MIX-MINUS-OPERATIONS.md)

**Critical workflow for remote guest interviews**

Complete guide to mix-minus (N-1) routing:
- What is mix-minus and why it's critical
- Architecture and Ardour routing configuration
- Pre-show testing procedure (echo check, latency, ducking)
- Operational workflow (setup, during show, emergency mute)
- Troubleshooting (echo, latency, VoIP issues)
- Professional comparison (Axia, Wheatstone, DHD)

### 🎛️ [LAUNCHPAD-MK2-QUICKSTART.md](LAUNCHPAD-MK2-QUICKSTART.md)

**5-minute Novation Launchpad Mk2 setup guide**

RGB LED feedback integration for visual track monitoring and clip launching:
- Real-time LED feedback (armed/recording/muted/soloed tracks)
- Transport status LEDs (play/stop/record/loop)
- Cue slot status (rows 4-8): loaded/playing/queued clips
- Transport control and cue triggers
- Automatic error recovery and hotplug detection
- Session-persistent brightness control

**Full documentation:** [MIDI-CONTROLLERS.md § Launchpad Mk2 Integration](MIDI-CONTROLLERS.md#launchpad-mk2-integration)

## Quick Start

```bash
# NixOS (add to configuration.nix)
environment.systemPackages = with pkgs; [
  ardour
  lsp-plugins
  calf
  zam-plugins
  x42-plugins
];

# Or install imperatively
nix-env -iA nixos.ardour nixos.lsp-plugins nixos.calf \
             nixos.zam-plugins nixos.x42-plugins
```

Then read [STUDIO.md](STUDIO.md) for complete setup instructions.

## Key Features

- **Professional Voice Processing**: Broadcast-standard chain with LSP/Calf plugins
- **Music Ducking**: Automatic background music reduction during voice
- **Clips & Cue Launching**: Quick-fire jingles and sound effects with hybrid timeline/non-linear workflow
- **MIDI Control**: Hardware integration for faders, transport, and clip triggering with RGB LED feedback
- **True Peak Limiting**: ITU-R BS.1770 compliant broadcast loudness (-16 LUFS)
- **Session Persistence**: Save/load complete studio state
- **100% FLOSS**: No proprietary software required

## Hardware Requirements

- **Audio Interface**: Focusrite Vocaster Two (or similar 2-in/2-out USB interface)
- **MIDI Controllers** (optional): Korg nanoKONTROL Studio, Novation Launchpad Pro Mk2
- **Microphones**: Dynamic broadcast mics (Shure SM7B, Electro-Voice RE20, etc.)
- **OS**: NixOS x86-64 (documentation includes Arch/Debian alternatives)

## License

Documentation in this repository is provided as-is for educational and reference purposes.

All referenced software maintains its own licenses:

- Ardour: GPL-2.0
- LSP Plugins: LGPL-3.0
- Calf Studio Gear: LGPL-2.1
- ZAM Plugins: GPL-2.0
- x42-plugins: GPL-2.0

## Getting Help

1. Read [STUDIO.md](STUDIO.md) for step-by-step setup
2. See the appendices in [STUDIO.md](STUDIO.md) for plugin and monitoring references
3. Consult official plugin documentation as needed

______________________________________________________________________

Found an error or improvement? This documentation is based on verified plugin specifications from official sources. Please verify against official docs before suggesting changes.

______________________________________________________________________

**Last Updated**: January 2026\
**Verified Against**: LSP Plugins 1.2.26+, Calf 0.90.9+, Ardour 8.x, x42-plugins 20251025
