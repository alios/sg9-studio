# Launchpad Mk2 Quick Start Guide

**For:** SG9 Studio broadcast workflows with Ardour 8  
**Hardware:** Novation Launchpad Mk2 (8×8 RGB grid, 80 LEDs total)

## 5-Minute Setup

### 1. Hardware Connection

```bash
# Connect Launchpad Mk2 via USB
# Verify connection (Linux):
aconnect -l | grep Launchpad
# Should show: Launchpad MK2 (client XX:0)

# Verify connection (macOS):
# Check Audio MIDI Setup → MIDI Studio
```

**Put Launchpad in Programmer Mode:**
- Press **Setup** button (top-right corner)
- LED matrix should show mode selection
- Use arrow pads to select "Programmer" mode
- Press pad to confirm
- All LEDs should turn off (ready state)

### 2. Install Scripts & Map

```bash
# Copy Lua scripts to Ardour config
mkdir -p ~/.config/ardour8/scripts
cp scripts/launchpad_mk2_*.lua ~/.config/ardour8/scripts/

# Copy MIDI binding map
mkdir -p ~/.config/ardour8/midi_maps
cp ~/.config/ardour8/midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/
```

### 3. Configure Ardour

**Enable Lua Scripts:**

1. Open Ardour 8
2. `Edit → Preferences → Scripting → Manage Scripts`
3. Click **Add Script** → Select `launchpad_mk2_feedback.lua`
4. Check **Active** checkbox
5. Close preferences (script starts automatically)

**Enable Generic MIDI:**

1. `Edit → Preferences → Control Surfaces`
2. Check **Generic MIDI**
3. Click **Show Protocol Settings**
4. Set **Incoming MIDI:** `Launchpad Mk2:Launchpad Mk2 MIDI 1`
5. Set **Outgoing MIDI:** `Launchpad Mk2:Launchpad Mk2 MIDI 1`
6. Click **MIDI Binding File** → Browse to `sg9-launchpad-mk2.map`
7. Click **OK**
8. Restart Ardour

### 4. Quick Test

1. Create 8 audio tracks named B1-B8 (or use SG9 template)
2. Arm track B1 (click rec-enable button in mixer)
3. **Pad 81** (top-left of grid) should light **solid red**
4. Start recording (`Ctrl+R`)
5. **Pad 81** should **pulse red**
6. Stop recording
7. **Pad 81** should return to **solid red**
8. Disarm track B1
9. **Pad 81** should turn **green** (ready state)

**Transport Test:**

- Press **pad 104** (top row, leftmost) → Ardour should play/pause
- Press **pad 105** → Ardour should stop
- Press **pad 106** → Ardour record-arm should toggle

✅ **Success!** If LEDs respond correctly, integration is working.

## Grid Layout Cheat Sheet

```
┌─────────────────────────────────────────────┬──────┐
│ Top Row: Transport                          │ 89   │
│ 104  105  106  107  108  109  110  111      │      │
│ Play Stop Rec  Loop Rew  FFwd Home End      │      │
├─────────────────────────────────────────────┼──────┤
│ Row 1: TRACK ARM (Auto RGB Feedback)        │ 79   │
│  81   82   83   84   85   86   87   88      │ Save │
│  B1   B2   B3   B4   B5   B6   B7   B8      │      │
├─────────────────────────────────────────────┼──────┤
│ Row 2: MUTE                                 │ 69   │
│  71   72   73   74   75   76   77   78      │ Undo │
│  B1   B2   B3   B4   B5   B6   B7   B8      │      │
├─────────────────────────────────────────────┼──────┤
│ Row 3: SOLO                                 │ 59   │
│  61   62   63   64   65   66   67   68      │ Redo │
│  B1   B2   B3   B4   B5   B6   B7   B8      │      │
├─────────────────────────────────────────────┼──────┤
│ Row 4-6: Cue Triggers (Ardour 8.0+)         │ ...  │
│ Row 7: Mixer Navigation                     │ 19   │
│ Row 8: Markers                              │ 9    │
└─────────────────────────────────────────────┴──────┘
```

## LED Color Meanings

| Color | State | Example |
|-------|-------|---------|
| 🔴 Red (solid) | Track armed, ready to record | Track B1 armed, not recording |
| 🔴 Red (pulsing) | **Actively recording** | Track B1 recording audio |
| 🟠 Orange | Track muted | Track B2 muted |
| 🟡 Yellow | Track soloed | Track B3 solo active |
| 🟢 Green | Track ready (unarmed) | Track B4 idle, ready for input |
| ⚫ Off | Track inactive or no track | Slot B5 empty or disabled |

## Manual Actions (Lua Scripts)

**Refresh All LEDs (Desync Recovery):**

- `Edit → Lua Scripts → Launchpad Mk2: Refresh All LEDs`
- Use when: LEDs stuck in wrong color after hardware reset

**Cycle Brightness:**

- `Edit → Lua Scripts → Launchpad Mk2: Cycle Brightness`
- Levels: Dim (25%) → Medium (50%) → Bright (100%)
- Brightness saved in session metadata (persists across saves)

## Troubleshooting

**LEDs don't update:**

1. Check Launchpad in Programmer Mode (not Live Mode)
2. Verify Generic MIDI ports connected: `Edit → Preferences → Control Surfaces → Generic MIDI → Show Protocol Settings`
3. Verify Lua script active: `Edit → Preferences → Scripting → Manage Scripts`
4. Manual refresh: `Edit → Lua Scripts → Launchpad Mk2: Refresh All LEDs`

**Pads trigger multiple times (bouncy):**

- Install x42 MIDI Duplicate Blocker plugin (200ms debounce)
- See [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#advanced-mapping-with-x42-midi-tools)

**Pads too sensitive:**

- Install x42 MIDI Velocity Gamma plugin (gamma=2.0)
- See [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#advanced-mapping-with-x42-midi-tools)

**Script errors in Ardour log:**

```bash
# Check Lua script syntax
nix develop --command luacheck scripts/launchpad_mk2_feedback.lua

# View Ardour log
tail -f ~/.config/ardour8/ardour.log | grep Launchpad
```

## Advanced Usage

**Customize Track Names:**

If your tracks aren't named B1-B8, edit the MIDI map:

```bash
$EDITOR ~/.config/ardour8/midi_maps/sg9-launchpad-mk2.map

# Find lines like:
# <Binding channel="1" note="81" function="rec-enable" uri="/route/B1"/>
# Replace "B1" with your track name (e.g., "/route/Host Mic")
```

**Adjust Polling Interval (CPU optimization):**

Edit `scripts/launchpad_mk2_feedback.lua`:

```lua
CONFIG = {
  poll_interval_active = 200,  -- Default: 100ms (increase to reduce CPU)
  poll_interval_idle = 1000,   -- Default: 500ms
}
```

**Disable Performance Metrics Logging:**

```lua
CONFIG = {
  log_metrics_interval = 0,  -- Default: 60000 (60 seconds)
}
```

## Full Documentation

- **Complete Integration Guide:** [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#launchpad-mk2-integration)
- **Lua Script Details:** [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#rgb-led-feedback-via-lua-scripts)
- **Testing Workflow:** [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#testing-workflow)
- **MIDI Protocol Reference:** [MIDI-CONTROLLERS.md](MIDI-CONTROLLERS.md#midi-protocol-programmer-mode)

## Support

**Logs Location:**

- Ardour: `~/.config/ardour8/ardour.log`
- Script output: Ardour console (`Window → Audio/MIDI Setup → Log`)

**Report Issues:**

Include in bug reports:
- Ardour version: `ardour8 --version`
- Launchpad mode: Programmer (not Live)
- Relevant log excerpts with `[Launchpad Mk2]` prefix
- Steps to reproduce
