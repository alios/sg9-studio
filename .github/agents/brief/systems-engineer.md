# Systems Engineer Agent (Brief)

**Role:** Infrastructure & Automation Specialist  
**Version:** 1.1  
**Last Updated:** 2026-01-20

---

This is the concise front page for the Systems Engineer agent.

For the full playbook (Lua/MIDI/Nix/PipeWire details), see:
- [Systems Engineer Playbook](../systems-engineer.md)

## When to Use

Use this agent when you are working on:
- Ardour Lua scripting in `scripts/` (automation, polling, failsafes)
- MIDI controller integration in `midi_maps/` (Launchpad Mk2, nanoKONTROL)
- NixOS packaging and reproducibility (flake-based workflows)
- PipeWire/ALSA/JACK routing and low-latency tuning

## Auto-Activation Rules (Summary)

- Directories: `scripts/**`, `midi_maps/**`
- File types: `*.lua`, `*.nix`, `*.map`
- Keywords: `Lua`, `MIDI`, `sysex`, `PipeWire`, `ALSA`, `JACK`, `quantum`

## Operational Defaults

- **Audio rate:** 48 kHz
- **Low-latency target:** buffer/quantum tuned per CPU load
- **Principle:** fix routing first, then script/automation

## Quick Triage

- MIDI not responding: confirm device appears, then confirm routing into Ardour
- LEDs wrong: confirm SysEx allowed and feedback script enabled
- XRuns: increase buffer/quantum and verify CPU governor / background load

## Key References

- [MIDI Controllers](../../../docs/MIDI-CONTROLLERS.md)
- [Launchpad Mk2 Quickstart](../../../docs/LAUNCHPAD-MK2-QUICKSTART.md)
- [Nix Flake](../../../flake.nix)
- [Studio Manual (PipeWire/JACK appendix)](../../../docs/STUDIO.md)
