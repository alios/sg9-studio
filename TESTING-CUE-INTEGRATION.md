# Cue Integration Testing Guide

**Prerequisite:** Complete Phase 1-3 implementation  
**Estimated Time:** 30-45 minutes  
**Related:** [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md)

---

## Test Environment Setup

### 1. Install MIDI Bindings

```fish
cd /Users/alios/src/sg9-studio

# Copy to Ardour config directory
mkdir -p ~/.config/ardour8/midi_maps/
cp midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/

# Or symlink for live development
ln -sf (pwd)/midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/
```

### 2. Configure Ardour Clips Library

1. Open Ardour
2. `Edit → Preferences → Triggering`
3. **Custom Clips Folder:** `/Users/alios/src/sg9-studio/clips/`
4. Click **OK**, restart Ardour

### 3. Enable Generic MIDI Control Surface

1. `Edit → Preferences → Control Surfaces`
2. Check **Generic MIDI**
3. Click **Show Protocol Settings**
4. **Incoming MIDI:** `Launchpad Mk2:Launchpad Mk2 MIDI 1`
5. **Outgoing MIDI:** `Launchpad Mk2:Launchpad Mk2 MIDI 1`
6. **MIDI Binding File:** Browse to `~/.config/ardour8/midi_maps/sg9-launchpad-mk2.map`
7. Click **OK**, restart Ardour

### 4. Install Lua Feedback Script

1. Open Ardour
2. `Window → Scripting → Script Manager`
3. Click **Add/Set** → **Load**
4. Browse to `/Users/alios/src/sg9-studio/scripts/launchpad_mk2_feedback.lua`
5. Click **Activate**
6. Verify no errors in `Window → Log`

### 5. Create Test Clips

You'll need test audio files to populate the cue grid. Create simple test clips:

```fish
cd /Users/alios/src/sg9-studio/clips/Jingles/

# Generate 5-second test tones (requires SoX)
sox -n -r 48000 -c 2 test-cue-a.wav synth 5 sine 440  # A4 (440 Hz)
sox -n -r 48000 -c 2 test-cue-b.wav synth 5 sine 523  # C5 (523 Hz)
sox -n -r 48000 -c 2 test-cue-c.wav synth 5 sine 659  # E5 (659 Hz)
sox -n -r 48000 -c 2 test-cue-d.wav synth 5 sine 783  # G5 (783 Hz)
sox -n -r 48000 -c 2 test-cue-e.wav synth 5 sine 880  # A5 (880 Hz)
```

Or use existing audio files (ensure 48kHz sample rate).

---

## Test Sequence

### Test 1: MIDI Binding Verification (Action Names)

**Goal:** Verify that cue trigger action names are correct.

**⚠️ CRITICAL:** The `.map` file uses **speculative action names** that need validation.

**Procedure:**

1. Open Ardour with cue grid visible (`Window → Show Cues`)
2. Drag `test-cue-a.wav` to **Cue A, Slot 1** (top-left slot)
3. Right-click the **Cue A, Slot 1** button in Cue window
4. Select **MIDI Learn**
5. Press **Launchpad pad 51** (fourth row, leftmost pad)
6. Open `Window → Log`
7. Search for log output containing binding info

**Expected Outcome:**

- Log should show: `"Learned MIDI binding for <action-name>"`
- Note the exact `<action-name>` syntax

**If action name differs from `.map` file:**

1. Open `midi_maps/sg9-launchpad-mk2.map`
2. Find line: `<Binding channel="1" note="51" action="Cue/trigger-cue-row-0-0"/>`
3. Update `action=""` attribute with correct syntax
4. Repeat for all 40 cue trigger bindings (rows 4-8)
5. Reload MIDI bindings in Ardour (disable/re-enable Generic MIDI)

**Repeat for Scene Trigger:**

1. Right-click **Cue A** scene button (entire row trigger)
2. MIDI Learn → Press **Launchpad pad 89** (scene column, top)
3. Verify action name in log
4. Update `.map` file if needed

**Document Findings:**

Create issue or update [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md) with correct action syntax.

---

### Test 2: Individual Slot Triggering

**Goal:** Verify that each pad triggers the correct cue slot.

**Procedure:**

1. Populate cue grid with test clips:
   - **Cue A, Slot 1:** test-cue-a.wav
   - **Cue B, Slot 2:** test-cue-b.wav
   - **Cue C, Slot 3:** test-cue-c.wav
   - **Cue D, Slot 4:** test-cue-d.wav
   - **Cue E, Slot 5:** test-cue-e.wav

2. Set launch styles in Cue window:
   - All slots: **Trigger** (one-shot playback)
   - Quantization: **None** (instant trigger)

3. Test each pad:

| Pad | Expected Behavior |
|-----|-------------------|
| 51  | Cue A, Slot 1 plays (440 Hz tone) |
| 42  | Cue B, Slot 2 plays (523 Hz tone) |
| 33  | Cue C, Slot 3 plays (659 Hz tone) |
| 24  | Cue D, Slot 4 plays (783 Hz tone) |
| 15  | Cue E, Slot 5 plays (880 Hz tone) |

**Pass Criteria:**

- ✅ Correct clip plays for each pad
- ✅ Playback starts within 50ms (no latency)
- ✅ No cross-triggering (wrong slot plays)

**If test fails:**

- Check Generic MIDI bindings (note numbers may be incorrect)
- Verify MIDI Learn results from Test 1
- Check Ardour log for MIDI binding errors

---

### Test 3: Scene Triggering (Entire Cue)

**Goal:** Verify that scene buttons trigger all slots in a cue.

**Procedure:**

1. Populate **Cue A** with 8 different test clips (slots 1-8)
2. Set all slots to **Toggle** launch style
3. Press **Launchpad pad 89** (scene button, top of right column)
4. Observe playback

**Expected Outcome:**

- ✅ All 8 slots in Cue A start playing simultaneously
- ✅ Press pad 89 again → All 8 slots stop

**If test fails:**

- Verify scene trigger action name (MIDI Learn on scene button)
- Check `.map` file: `<Binding channel="1" note="89" action="Cue/trigger-scene-0"/>`

---

### Test 4: Lua LED Feedback

**Goal:** Verify that cue slot LED colors reflect clip state.

**⚠️ NOTE:** This test depends on **unverified Ardour Lua API**. If API is unavailable, LEDs will remain off.

**Procedure:**

1. Open Ardour with cue grid populated
2. Check `Window → Log` for Lua script errors
3. Load a clip into **Cue A, Slot 1**
4. Observe Launchpad **pad 51**

**Expected LED States:**

| Clip State | Expected LED Color |
|------------|-------------------|
| Empty (no clip) | **Off** (black) |
| Loaded (ready) | **Solid green** |
| Playing | **Pulsing green** (1Hz flash) |
| Queued (quantized) | **Solid yellow** |
| Error | **Solid red** |

**If LEDs do not update:**

1. Check Ardour log for Lua errors:
   ```
   Window → Log
   Filter: "launchpad" or "triggerbox"
   ```

2. Run API test script:
   ```
   Window → Scripting → Action Scripts → Add/Set
   Load: scripts/test_cue_api.lua
   Run the script
   Check log for API availability results
   ```

3. If API unavailable:
   - Document limitation in [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md)
   - Consider fallback: polling-based state queries
   - File feature request with Ardour devs

**Performance Check:**

- Open `Window → Log`
- Look for metrics log (every 60 seconds)
- Verify CPU usage <5% (check system monitor)
- Verify polling interval adjusts (100ms → 500ms when idle)

---

### Test 5: Hybrid Workflow (Timeline + Cue Markers)

**Goal:** Verify automated cue triggering from timeline markers.

**Procedure:**

1. Create new Ardour session: **Test Hybrid Workflow**
2. Populate cue grid with 5 test clips (Cues A-E, slot 1)
3. Add cue markers to timeline:

| Timecode | Marker Type | Cue | Expected Clip |
|----------|-------------|-----|---------------|
| 00:00:00:00 | Cue | A | test-cue-a.wav |
| 00:00:05:00 | Stop All Cues | - | (silence) |
| 00:00:10:00 | Cue | B | test-cue-b.wav |
| 00:00:15:00 | Cue | C | test-cue-c.wav |
| 00:00:20:00 | Stop All Cues | - | (silence) |

4. Set transport to **00:00:00:00**
5. Press **Play**
6. Listen to playback

**Expected Timeline:**

- `00:00` - Cue A plays (440 Hz tone)
- `05:00` - All cues stop (silence)
- `10:00` - Cue B plays (523 Hz tone)
- `15:00` - Cue C plays (659 Hz tone)
- `20:00` - All cues stop (silence)

**Pass Criteria:**

- ✅ Cue markers trigger at exact timecode
- ✅ Stop All Cues marker silences playback
- ✅ No drift or latency over 20-second duration

---

### Test 6: Export Workflow (CRITICAL)

**Goal:** Verify that cue markers trigger correctly during export.

**⚠️ KNOWN ISSUE:** Community reports cue triggers may fail on first export (Ardour 8.12 bug).

**Procedure:**

1. Use session from Test 5 (hybrid workflow with cue markers)
2. **Export 1:**
   - `Session → Export → Export to Audio File(s)`
   - Format: WAV, 48kHz, 24-bit
   - Range: **Session** (entire timeline)
   - Filename: `test-export-1.wav`
   - Click **Export**

3. Listen to `test-export-1.wav`:
   - Verify all cue markers triggered (440 Hz → silence → 523 Hz → 659 Hz → silence)

4. **Export 2:** Re-export without changes
   - Filename: `test-export-2.wav`
   - Click **Export**

5. **Export 3:** Third export for consistency
   - Filename: `test-export-3.wav`
   - Click **Export**

6. Compare all 3 exports:
   ```fish
   # Waveform comparison (requires SoX)
   sox test-export-1.wav -n stats
   sox test-export-2.wav -n stats
   sox test-export-3.wav -n stats
   ```

**Pass Criteria:**

- ✅ All 3 exports are identical (same RMS, peak, duration)
- ✅ All cue markers triggered in all exports
- ✅ No missing clips or silence where audio expected

**If export fails:**

- Document failure in [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md)
- File bug report with Ardour devs:
  - Ardour version: `ardour8 --version`
  - Session file (attach `.ardour` XML)
  - Export settings screenshot

**Workaround (if export fails):**

1. Use **stem export** instead:
   - Export cue tracks separately (mute timeline tracks)
   - Export timeline tracks separately (mute cue tracks)
   - Merge in DAW post-export

2. Or **render cues to timeline before export**:
   - Play session while recording master bus to new track
   - Export recorded track instead of session

---

## Validation Checklist

- [ ] Test 1: MIDI Binding Verification (action names correct)
- [ ] Test 2: Individual Slot Triggering (40 pads tested)
- [ ] Test 3: Scene Triggering (5 cues tested)
- [ ] Test 4: Lua LED Feedback (color schema validated)
- [ ] Test 5: Hybrid Workflow (timeline markers trigger)
- [ ] Test 6: Export Workflow (3 consistent exports)
- [ ] Performance: CPU usage <5%, no xruns
- [ ] Documentation: All findings recorded in status doc

---

## Troubleshooting

### Issue: Pads don't trigger clips

**Diagnosis:**
1. Check Generic MIDI control surface is enabled
2. Verify MIDI routing: Launchpad → Ardour
3. Test with `aseqdump -p "Launchpad"` (Linux) or MIDI Monitor (macOS)
4. Check Ardour log for MIDI binding errors

**Solution:**
- Re-run MIDI Learn for failing pads
- Update `.map` file with correct action names
- Restart Ardour after config changes

---

### Issue: LEDs don't update

**Diagnosis:**
1. Check Lua script is loaded: `Window → Scripting → Script Manager`
2. Check Ardour log for Lua errors
3. Run API test script: `scripts/test_cue_api.lua`

**Solution:**
- If API unavailable, document limitation (LED feedback not possible)
- If API available but errors, debug `update_cue_leds()` function
- Check MIDI routing: Ardour → Launchpad (outgoing)

---

### Issue: Cue markers don't trigger on export

**Known Issue:** Ardour 8.12 bug (community reported)

**Workaround:**
1. Export 2-3 times, use last export (may work on subsequent tries)
2. Use stem export workflow
3. Render cues to timeline before export

**Report Bug:**
- Forum: https://discourse.ardour.org/
- Include: Ardour version, session file, export settings

---

## Performance Baseline

Record these metrics after completing all tests:

| Metric | Target | Actual |
|--------|--------|--------|
| CPU usage (idle) | <2% | ___ % |
| CPU usage (8 cues playing) | <5% | ___ % |
| SysEx messages/second | <50 | ___ |
| Polling interval (idle) | 500ms | ___ ms |
| Polling interval (active) | 100ms | ___ ms |
| Trigger latency (pad press → audio) | <50ms | ___ ms |

---

## Next Steps After Testing

1. **Update Documentation:**
   - Record all findings in [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md)
   - Update [STUDIO.md](STUDIO.md) with cue workflow appendix
   - Update [LAUNCHPAD-MK2-QUICKSTART.md](LAUNCHPAD-MK2-QUICKSTART.md) with cue grid layout

2. **Fix Any Issues:**
   - Correct MIDI binding action names in `.map` file
   - Debug Lua LED feedback if API available
   - Document workarounds for export bugs

3. **Finalize Implementation:**
   - Commit all changes to repository
   - Tag release: `git tag -a v1.0-cue-integration`
   - Update README.md feature list

4. **Repository Review:**
   - Check for documentation inconsistencies
   - Verify all files in repository (no external dependencies)
   - Validate AI/MCP support files completeness
