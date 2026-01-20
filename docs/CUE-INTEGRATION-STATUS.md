# Cue Integration Status

**Last Updated:** 2026-01-20

## Current State

- **Generic MIDI cue triggering:** Implemented via [midi_maps/sg9-launchpad-mk2.map](midi_maps/sg9-launchpad-mk2.map)
- **Cue action names:** Updated to verified Ardour actions (`trigger-slot-*` / `trigger-cue-*`)
- **Cue LED feedback:** Implemented in [scripts/launchpad_mk2_feedback.lua](scripts/launchpad_mk2_feedback.lua) but depends on Ardour Lua TriggerBox API availability

## What To Verify Next

- Run the full testing protocol: [TESTING-CUE-INTEGRATION.md](TESTING-CUE-INTEGRATION.md)
- If cue LEDs do not respond, run: [scripts/test_cue_api.lua](scripts/test_cue_api.lua) and record findings.

## Notes

- Cue action IDs were extracted from Ardour source and recorded in [.copilot-tracking/research/2026-01-19-ardour-cue-action-names.md](.copilot-tracking/research/2026-01-19-ardour-cue-action-names.md).
