# MIDI Maps Directory

This directory contains Generic MIDI binding maps for Ardour control surfaces used in SG9 Studio.

## Files

### `sg9-launchpad-mk2.map`

Generic MIDI binding map for Novation Launchpad Mk2 integration with Ardour 8.

**Features:**
- Transport control (play, stop, record, loop)
- Track operations (arm, mute, solo for 8 tracks)
- Cue/clip triggering (rows 4-8 → Cues A-E, scene column → trigger entire cues)
- Marker navigation

**Installation:**

```fish
# Copy to Ardour config directory
mkdir -p ~/.config/ardour8/midi_maps/
cp midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/

# Or create symlink (changes auto-reflected)
ln -s (pwd)/midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/
```

**Ardour Configuration:**

1. `Edit → Preferences → Control Surfaces`
2. Enable **Generic MIDI**
3. Click **Show Protocol Settings**
4. **Incoming MIDI:** Select `Launchpad Mk2:Launchpad Mk2 MIDI 1`
5. **Outgoing MIDI:** Select `Launchpad Mk2:Launchpad Mk2 MIDI 1`
6. **MIDI Binding File:** Browse to `sg9-launchpad-mk2.map`
7. Restart Ardour

## Cue Trigger Action Names

Cue trigger action names are now **verified from Ardour source** and implemented in `sg9-launchpad-mk2.map`.

```xml
<!-- Individual slot triggers -->
<Binding channel="1" note="51" action="trigger-slot-0-0"/>

<!-- Entire cue (scene) triggers -->
<Binding channel="1" note="89" action="trigger-cue-0"/>
```

**Patterns:**
- Individual slot: `trigger-slot-{col}-{row}`
- Entire cue row (scene): `trigger-cue-{row}`

**Reference:** [.copilot-tracking/research/2026-01-19-ardour-cue-action-names.md](../.copilot-tracking/research/2026-01-19-ardour-cue-action-names.md)

**Still recommended (when upgrading Ardour):**

1. In Ardour, right-click a cue slot button in Cue window
2. Select **MIDI Learn**
3. Press corresponding Launchpad pad
4. Check Ardour log (`Window → Log`) for generated binding
5. Update `.map` file if syntax differs

**Alternative discovery method:**

```fish
# List all available Ardour actions (requires Ardour session open)
grep -i "cue" ~/.config/ardour8/log/ardour.log

# Or use Ardour's action list
# Window → Scripting → Lua REPL
# Type: ARDOUR.LuaAPI.get_actions()
```

## Track Naming Convention

The map file uses `/route/B1` through `/route/B8` URIs, matching SG9 Studio's broadcast template:

- **B1:** Host Mic (DSP chain)
- **B2:** Host Mic (Raw safety)
- **B3:** Guest Mic
- **B4:** (Reserved)
- **B5:** Aux Input
- **B6:** (Reserved)
- **B7:** Remote Guest (VoIP)
- **B8:** Music/Bed track

If your track names differ, edit the `.map` file URIs accordingly.

## Testing

After installation, test bindings:

1. **Transport:** Press Launchpad top row pads (play/stop should work)
2. **Track Arm:** Press row 1 pads → Track arm indicators should toggle
3. **Cue Triggers:** Load clip in Cue A, slot 1 → Press pad 51 → Clip should play

If cue triggers don't work, use MIDI Learn to discover correct action syntax.

## Validation

Ardour Generic MIDI maps are XML files. Validate syntax:

```fish
# Install xmllint (if needed)
nix-shell -p libxml2

# Validate against Ardour schema (if available)
xmllint --noout --schema /usr/share/ardour8/midi_maps/midi_map.xsd midi_maps/sg9-launchpad-mk2.map

# Or basic XML validation
xmllint --noout midi_maps/sg9-launchpad-mk2.map
echo "Valid: $status"
```

## Related Documentation

- [MIDI-CONTROLLERS.md](../docs/MIDI-CONTROLLERS.md) - Full Launchpad Mk2 integration guide
- [LAUNCHPAD-MK2-QUICKSTART.md](../docs/LAUNCHPAD-MK2-QUICKSTART.md) - 5-minute setup guide
- [Ardour Manual: Generic MIDI](https://manual.ardour.org/using-control-surfaces/generic-midi/)
- [Ardour Manual: MIDI Binding Maps](https://manual.ardour.org/using-control-surfaces/generic-midi/midi-binding-maps/)
