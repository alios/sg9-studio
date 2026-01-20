# SG9 Studio — Ardour Lua Scripts

This directory contains Ardour 8 Lua scripts used to automate and control the SG9 Studio broadcast workflow (Launchpad Mk2 LEDs, nanoKONTROL layers, emergency actions, etc.).

## How Ardour Lua Scripts Work

SG9 scripts are written for Ardour 8’s Lua scripting system and typically fall into these categories:

- **Session scripts**: run on session load (setup/initial state)
- **Editor actions**: user-triggered scripts (menu action, keyboard shortcut, MIDI mapping)
- **Action hooks / polling**: periodically update state (e.g., LED feedback)

The exact enablement UI varies slightly by Ardour version, but you can always manage scripts via:

- `Window → Scripting`

## Script Inventory

### Session scripts (auto-start)

| Script | Trigger | Purpose |
| --- | --- | --- |
| [auto_arm_tracks.lua](auto_arm_tracks.lua) | Session load | Auto-arm key recording tracks |

### Editor actions (user-triggered)

| Script | Purpose |
| --- | --- |
| [auto_mix_minus.lua](auto_mix_minus.lua) | Configure mix-minus routing (N-1) |
| [launchpad_mk2_brightness.lua](launchpad_mk2_brightness.lua) | Cycle Launchpad Mk2 LED brightness (stored in session metadata) |
| [launchpad_mk2_refresh_leds.lua](launchpad_mk2_refresh_leds.lua) | Force a full Launchpad LED refresh |
| [nanokontrol_layers.lua](nanokontrol_layers.lua) | Layer switching for nanoKONTROL (tracks/busses/VCAs) |
| [test_cue_api.lua](test_cue_api.lua) | Development helper: probe Cue/Trigger API availability |
| [automation/panic_cut_to_music.lua](automation/panic_cut_to_music.lua) | Emergency action: cut voices / route to music (failsafe) |

### Polling / feedback

| Script | Purpose | Notes |
| --- | --- | --- |
| [launchpad_mk2_feedback.lua](launchpad_mk2_feedback.lua) | Launchpad Mk2 RGB LED feedback (transport + cue status) | Uses adaptive polling (faster when rolling) |

## Enable / Use Scripts in Ardour

1. Open your SG9 Ardour session.
2. Open `Window → Scripting`.
3. Add/enable the relevant script depending on its type:

- For **session scripts**: add it to session scripts and enable auto-start.
- For **editor actions**: add it as an action script.
- For **feedback/polling scripts**: enable it as a hook/poller.

## Development Workflow

### Lint

From repo root (in the dev shell):

- `luacheck --no-color scripts/*.lua scripts/automation/*.lua`

### Format

- `stylua scripts/`

## Dependencies / Assumptions

Some scripts assume the SG9 session structure and specific names (tracks/busses/VCAs).

- Session structure: see [docs/ARDOUR-SETUP.md](../docs/ARDOUR-SETUP.md)
- MIDI controller mappings: see [docs/MIDI-CONTROLLERS.md](../docs/MIDI-CONTROLLERS.md)

## Troubleshooting

- If a MIDI controller is connected but does not trigger scripts, confirm connections in `Window → Audio/MIDI Connections`.
- If Launchpad LEDs do not update, ensure the feedback script is enabled and SysEx output is not blocked by the MIDI routing layer.

See also: [docs/LAUNCHPAD-MK2-QUICKSTART.md](../docs/LAUNCHPAD-MK2-QUICKSTART.md)
