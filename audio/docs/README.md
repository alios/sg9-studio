# Audio Documentation

This directory contains audio-specific operational documentation for SG9 Studio broadcast workflows.

## Quick Navigation

### Operational Procedures

- **[EMERGENCY-PROCEDURES.md](EMERGENCY-PROCEDURES.md)** - Emergency failsafe workflows, panic button procedures
- **[MIX-MINUS-OPERATIONS.md](MIX-MINUS-OPERATIONS.md)** - Remote interview routing, echo prevention
- **[QUICK-REFERENCE-CARD.md](QUICK-REFERENCE-CARD.md)** - At-a-glance reference for live production

### Related Documentation

- **[../../docs/STUDIO.md](../../docs/STUDIO.md)** - Complete studio reference manual (hardware, signal flow, monitoring)
- **[../../docs/ARDOUR-SETUP.md](../../docs/ARDOUR-SETUP.md)** - Ardour 8 template configuration guide
- **[../../docs/MIDI-CONTROLLERS.md](../../docs/MIDI-CONTROLLERS.md)** - MIDI controller integration (Launchpad, nanoKONTROL)
- **[../../docs/LAUNCHPAD-MK2-QUICKSTART.md](../../docs/LAUNCHPAD-MK2-QUICKSTART.md)** - Launchpad Mk2 quick start guide
- **[../sessions/README.md](../sessions/README.md)** - Session management and template organization

## Document Relationships

```
Root Documentation:
├── README.md                         # Project overview
├── AGENTS.md                         # AI assistant overview
├── ISSUES.md                         # Known issues / backlog
└── docs/
	├── STUDIO.md (1,500+ lines)          # Master reference
	└── ARDOUR-SETUP.md (2,600+ lines)    # Setup guide

Audio-Specific Documentation:
audio/docs/
├── EMERGENCY-PROCEDURES.md           # Crisis management (implementation: ../../scripts/automation/panic_cut_to_music.lua)
├── MIX-MINUS-OPERATIONS.md           # Remote guest workflows
└── QUICK-REFERENCE-CARD.md           # Live production cheat sheet

Hardware/MIDI Documentation:
├── docs/MIDI-CONTROLLERS.md          # Controller architecture
├── docs/LAUNCHPAD-MK2-QUICKSTART.md  # RGB LED feedback, cue triggering
└── midi_maps/README.md               # Generic MIDI binding documentation

Developer Documentation:
└── docs/                             # System-level docs (HMI, context-aware controls)
```

## Usage Guidelines

**For AI Assistants (Audio Engineer Agent):**
- Emergency procedures = `audio/docs/EMERGENCY-PROCEDURES.md`
- Mix-minus troubleshooting = `audio/docs/MIX-MINUS-OPERATIONS.md`
- Quick reference = `audio/docs/QUICK-REFERENCE-CARD.md`
- Session templates = `audio/sessions/README.md`

**For Live Production:**
1. Pre-show: Read [QUICK-REFERENCE-CARD.md](QUICK-REFERENCE-CARD.md)
2. Remote interviews: Reference [MIX-MINUS-OPERATIONS.md](MIX-MINUS-OPERATIONS.md)
3. Emergency: Follow [EMERGENCY-PROCEDURES.md](EMERGENCY-PROCEDURES.md)

**For Systems Engineering:**
- Panic script implementation: `../../scripts/automation/panic_cut_to_music.lua`
- MIDI controller setup: `../../docs/MIDI-CONTROLLERS.md`
- Hardware routing: `../../docs/STUDIO.md` (Appendix: ALSA Routing)

## Changelog

- **v1.0 (2026-01-19):** Created audio/docs/ directory, migrated audio-specific documentation from docs/
