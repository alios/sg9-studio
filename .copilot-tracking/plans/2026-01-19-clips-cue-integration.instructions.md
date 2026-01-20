# Implementation Plan: Ardour Clips/Cue Integration with Launchpad MK2

**Date:** 2026-01-19  
**Status:** Planning  
**Related Research:** [.copilot-tracking/research/CLIPS-INTEGRATION-RESEARCH.md](../research/CLIPS-INTEGRATION-RESEARCH.md)

---

## Objective

Integrate Ardour's clip/cue triggering system into SG9 Studio's broadcast workflow, extending existing Launchpad MK2 implementation to enable instant jingle/SFX triggering, automated segment transitions, and hybrid linear/non-linear production.

---

## Implementation Steps

### 1. Create Clip Library Structure and Populate Initial Cue Grid

**Actions:**
- Create organized clip library at `<repository>/clips/` with subfolders: `Jingles/`, `Music-Beds/`, `SFX/`
- Pre-render all clips at 48kHz sample rate with exact durations in seconds (no reliance on time-stretching)
- Normalize all clips to -16 LUFS integrated loudness for consistent playback levels
- Load initial clip set into Ardour cue grid (Cues A-E, Tracks 1-3)
- Configure per-slot settings:
  - **Jingles:** Launch Style = Trigger, Quantize = None, Follow Action = Stop
  - **Music Beds:** Launch Style = Toggle, Quantize = None, Follow Action = Again (loop)
  - **SFX:** Launch Style = Trigger, Quantize = None, Cue Isolate = ON

**Files Modified:**
- New directory: `<repository>/clips/` with README.md and subdirectories
- Ardour session file (cue grid data)
- Configure Ardour: `Preferences → Triggering → Custom Clips Folder` → `<repository>/clips/`

**Success Criteria:**
- 15+ clips organized in library
- All clips play at correct loudness (-16 LUFS ±2 LU)
- Manual triggering via Cue window buttons works reliably

---

### 2. Extend Generic MIDI Binding Map for Cue Triggers

**Actions:**
- Backup existing Generic MIDI map file
- Use Ardour's MIDI Learn feature to discover cue trigger URIs:
  1. Right-click Cue A, Slot 1 button in Cue window
  2. Select "MIDI Learn"
  3. Press Launchpad pad 51
  4. Inspect Ardour log for generated URI syntax
- Add bindings for Launchpad rows 4-8 (pads 51-18) → Cue slots
- Add bindings for scene column (pads 89-19) → Trigger entire cues
- Test MIDI routing via `pw-cli dump` to verify PipeWire MIDI graph

**Files Modified:**
- Generic MIDI binding map (location TBD based on Ardour config)

**Expected URI Format (verify via MIDI Learn):**
```xml
<!-- Example - actual syntax to be confirmed -->
<Binding channel="1" note="51" function="trigger-cue-slot" uri="/cues/A/1"/>
<Binding channel="1" note="89" function="trigger-cue" uri="/cues/A"/>
```

**Success Criteria:**
- All 40 cue slot pads trigger correct clips
- 8 scene buttons trigger entire cues
- MIDI latency <10ms (measure via Ardour MIDI tracer)

---

### 3. Enhance Lua Script for Cue Slot LED Feedback

**Actions:**
- Test Ardour 8.10 Lua API for cue access in Lua REPL:
  ```lua
  local cue = Session:get_cue(1)  -- Test if method exists
  if cue then
    local slot = cue:get_slot(1)
    print("API available:", slot ~= nil)
  end
  ```
- If API available: Implement event-driven updates via signal subscription
- If API unavailable: Implement polling-based monitoring with adaptive intervals:
  - Active (transport rolling): 100ms
  - Idle (transport stopped): 500ms
  - Background (no cue activity): 1000ms
- Add LED feedback logic to [launchpad_mk2_feedback.lua](../../scripts/launchpad_mk2_feedback.lua):
  - Empty slot: LED off
  - Loaded (ready): Solid green (velocity 21)
  - Playing: Pulsing green (rapid on/off cycle)
  - Queued (quantization delay): Solid yellow (velocity 13)
  - Error: Solid red (velocity 5)
- Implement state caching to reduce API calls (only update on state change)
- Add performance monitoring (log polling overhead every 60 seconds)

**Files Modified:**
- [scripts/launchpad_mk2_feedback.lua](../../scripts/launchpad_mk2_feedback.lua)

**Success Criteria:**
- LED feedback matches cue slot state in real-time
- CPU overhead <5% (measure via Ardour DSP load meter)
- No LED flicker during playback
- Graceful degradation if CPU >80% (disable LED updates)

---

### 4. Test Hybrid Workflow (Timeline + Cue Markers)

**Actions:**
- Enable Cue Markers ruler in Ardour: `View → Rulers → Cue Markers`
- Create test episode timeline with structure:
  ```
  00:00 - Cue Marker A (Intro)
  00:30 - Stop All Cues
  05:00 - Cue Marker B (Segment transition)
  15:00 - Cue Marker C (Ad break)
  25:00 - Cue Marker D (Outro)
  26:00 - Stop All Cues
  ```
- Configure session for broadcast timing:
  - **Session timecode:** SMPTE 30fps (wall-clock time)
  - **Session tempo:** 120 BPM (for grid visualization only, 1 bar = 2 seconds)
  - **Global setting:** `Preferences → Triggering → Follow Tempo = OFF` (disable time-stretching)
- Verify automated playback (cue markers trigger at correct SMPTE timecode)
- Test manual override (operator clicks Cue button while timeline playing)
- Validate LED feedback during automated and manual triggering
- **CRITICAL: Test export workflow** (community-reported bug):
  1. Export full episode (Session → Export → Export to Audio File)
  2. Listen to entire export, verify all cue markers triggered correctly
  3. If first export fails, note issue and re-export (known bug in Ardour 8.12)
  4. Document any export issues for bug report

**Files Modified:**
- Test Ardour session file

**Success Criteria:**
- Cue markers trigger at precise timecode positions (±10ms tolerance)
- Manual override works without disrupting timeline playback
- LED feedback synchronizes with both automated and manual triggers
- No audio glitches during cue transitions
- **Export includes all cue-triggered content** (verify 2-3 test exports)

---

### 5. Document Workflow and Update Quick Reference

**Actions:**
- Add new appendix to [docs/STUDIO.md](../../docs/STUDIO.md): "Appendix: Ardour Clips & Cue Workflow"
  - Cue grid layout and track assignments
  - Launchpad MK2 mapping (rows 4-8, scene column)
  - Pre-show checklist: clip loading, follow action verification, LED feedback test
  - Troubleshooting: common issues (quantization latency, LED sync, MIDI routing)
- Update [docs/LAUNCHPAD-MK2-QUICKSTART.md](../../docs/LAUNCHPAD-MK2-QUICKSTART.md):
  - Section 4: "Cue Triggering (Rows 4-8)"
  - Quick reference table: Pad → Cue/Slot mapping
- Create cue grid template diagram (ASCII art or exported image from Ardour)
- Document performance baseline metrics (CPU usage, latency measurements)

**Files Modified:**
- [docs/STUDIO.md](../../docs/STUDIO.md)
- [docs/LAUNCHPAD-MK2-QUICKSTART.md](../../docs/LAUNCHPAD-MK2-QUICKSTART.md)

**Success Criteria:**
- New operators can set up cue grid in <15 minutes using documentation
- Troubleshooting guide covers 80% of common issues
- Performance baselines documented for future comparison

---

## Industry Best Practices Applied

### 1. Lua API Verification and Fallback Strategy

**Practice:** Test assumptions before implementation; maintain backward compatibility.

**Implementation:**
- **Phase 1:** Test `Session:get_cue()` availability in Ardour 8.10 Lua REPL before writing production code
- **Phase 2:** Implement polling with exponential backoff to reduce API load:
  - Active state: 100ms (real-time feedback during performance)
  - Idle state: 500ms (transport stopped, no cue activity)
  - Background state: 1000ms (no user interaction detected)
- **Phase 3:** Cache slot states (only update LEDs on state change, not every poll)
- **Phase 4:** Document API version assumptions in script header for future Ardour upgrades
- **Fallback:** If Lua API insufficient, explore Ardour OSC protocol (more complete but adds dependency)

**Rationale:** Broadcast systems require reliability. Testing API availability prevents runtime failures. Exponential backoff reduces CPU overhead while maintaining responsiveness.

---

### 2. Broadcast-Compliant Timing (SMPTE, Not Musical Tempo)

**Practice:** Use industry-standard timecode for broadcast; avoid reliance on time-stretching.

**Implementation:**
- **Session timecode:** SMPTE 30fps (or 25fps for PAL regions) for wall-clock synchronization
- **Session tempo:** 120 BPM (cosmetic only, for grid visualization; 1 bar = 2 seconds at 4/4)
- **Clip preparation:**
  - Pre-render all clips at 48kHz sample rate (broadcast standard)
  - Calculate exact durations in **seconds** (not bars/beats)
  - Normalize to -16 LUFS integrated loudness (Apple Podcasts standard)
- **Global settings:**
  - `Preferences → Triggering → Follow Tempo = OFF` (disable time-stretching by default)
  - Individual clips can override if needed (rare for broadcast)
- **Quantization:** Set to **None** for all broadcast clips (instant triggering, no musical grid delay)

**Rationale:** 
- Broadcast timing is **absolute** (wall-clock), not relative (musical)
- Time-stretching introduces artifacts on spoken-word content
- SMPTE ensures frame-accurate synchronization with video/external systems
- 120 BPM session tempo provides 0.5-second grid resolution (fine enough for visual editing, coarse enough to avoid clutter)

---

### 3. Complementary MIDI Tools for Ardour Blind Spots

**Practice:** Use Ardour core features first; supplement with JACK-connected MIDI tools only where Ardour has limitations.

**Ardour Blind Spots Identified (from community research):**
- **Live loop recording to cue slots:** Cannot record directly to trigger slots during performance
- **Advanced MIDI sequencing:** Limited step sequencer capabilities compared to dedicated tools
- **Live MIDI clip manipulation:** No real-time clip editing/quantization during playback

**FLOSS MIDI Tools Integration Strategy:**

**1. Live Loop Recording → Luppp (JACK loop recorder)**
- **Use Case:** Record live audio loops, trigger via MIDI
- **Integration:** JACK audio routing → Luppp → Ardour timeline recording
- **Workflow:** Record loop in Luppp → bounce to Ardour → add to clips library
- **SG9 Application:** Limited need (broadcast uses pre-recorded content)

**2. MIDI Sequencing → Hydrogen (drum sequencer)**
- **Use Case:** Create rhythmic beds/backing tracks
- **Integration:** Hydrogen MIDI out → Ardour MIDI track → Cue slot
- **Workflow:** Pattern in Hydrogen → export MIDI → import to Ardour cue
- **SG9 Application:** Background music beds for episode structure

**3. Sample Triggering → LinuxSampler / Sfizz (SFZ/SoundFont samplers)**
- **Use Case:** Trigger SFX via MIDI pads (alternative to audio clips)
- **Integration:** Launchpad MIDI → Sampler plugin in Ardour → Audio output
- **Advantage:** Lower disk I/O than audio clips (samples loaded to RAM)
- **SG9 Application:** High-density SFX triggering (>50 sounds)

**Priority Hierarchy:**
1. **First:** Use Ardour cue/clip system (native, integrated, reliable)
2. **Second:** Use Ardour MIDI tracks + virtual instruments (ACE plugins, etc.)
3. **Third:** Use JACK-connected external tools (Hydrogen, Luppp) only if Ardour insufficient
4. **Last Resort:** Commercial/proprietary plugins

**Rationale:**
- Ardour core features = session-portable, well-tested, officially supported
- External JACK tools = additional failure points, session complexity
- MIDI samplers (LinuxSampler/Sfizz) = acceptable compromise (run as LV2 plugins inside Ardour)

---

### 4. Production-Grade Performance Monitoring

**Practice:** Establish performance baselines; implement graceful degradation; validate under production load.

**Implementation:**

**Performance Targets:**
- **CPU overhead (cue system):** <5% (measured via Ardour DSP load meter)
- **MIDI latency (pad press → audio):** <10ms (measured via Ardour MIDI tracer + audio analysis)
- **LED update latency:** <50ms (measured via visual observation)
- **Memory overhead:** <50MB additional RAM (measured via `ps aux | grep ardour`)

**Monitoring Strategy:**
- **Pre-deployment:** Run stress test with production load:
  - 8 tracks recording simultaneously (Host mic, Guest mic, Raw safety, Aux, Remote, etc.)
  - 20 active cue slots (5 cues × 4 tracks)
  - Launchpad LED feedback enabled
  - Measure CPU/latency for 30-minute session
- **Runtime monitoring:**
  - Log Lua script performance every 60 seconds (timestamp, poll count, API call duration)
  - Ardour DSP load meter visible in Cue window
  - Set CPU threshold alert at 80% (visual warning in Ardour)

**Graceful Degradation:**
- **If CPU >80%:** Disable LED feedback (prioritize audio processing over visual feedback)
- **If MIDI latency >25ms:** Increase poll interval to 200ms (reduce API load)
- **If audio dropouts occur:** Increase buffer size (128 → 256 samples) and disable Lua script

**Performance Logging (add to Lua script):**
```lua
-- Performance monitoring (log every 60 seconds)
local perf_log_interval = 60
local perf_last_log = 0
local perf_poll_count = 0

function track_performance()
  perf_poll_count = perf_poll_count + 1
  local now = os.time()
  if now - perf_last_log >= perf_log_interval then
    print(string.format("[PERF] Polls: %d, Avg: %.2f/sec", 
      perf_poll_count, perf_poll_count / perf_log_interval))
    perf_poll_count = 0
    perf_last_log = now
  end
end
```

**Rationale:**
- Broadcast audio cannot afford dropouts or glitches (live content is unforgiving)
- Proactive monitoring identifies issues before they impact production
- Graceful degradation ensures system remains usable even under stress
- Performance logs enable post-mortem analysis and optimization

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Lua API incomplete for cue access | High | Medium | Test in REPL before implementation; fallback to polling |
| MIDI URI syntax undocumented | Medium | Low | Use MIDI Learn to discover syntax; test extensively |
| LED feedback causes CPU spikes | High | Low | Implement adaptive polling; graceful degradation at 80% CPU |
| Time-stretching artifacts on speech | High | Medium | Disable Follow Tempo globally; pre-render clips at 48kHz |
| Quantization latency unacceptable | Medium | Low | Set Quantize=None for all broadcast clips |
| Clip library grows unmanageably | Low | High | Document file naming convention; periodic library cleanup |
| **Cue triggers missing on first export** | **High** | **Medium** | **Always test export; use stem export as backup; verify with community bug tracker** |
| External MIDI tools add complexity | Medium | Low | Prefer Ardour core features; only use external tools for proven blind spots |

---

## Success Metrics

- **Operator efficiency:** Pre-show setup time reduced from 20 minutes → 10 minutes
- **Production quality:** Zero audio glitches during cue triggering (100 episode sample)
- **System reliability:** <1% cue trigger failures (manual override available as backup)
- **Performance overhead:** <5% CPU, <10ms latency (measured under production load)
- **Operator satisfaction:** Positive feedback from 2+ operators after 10-episode trial

---

## Rollback Plan

If implementation fails or causes production issues:

1. **Immediate:** Disable Lua cue LED feedback script (keep Generic MIDI bindings)
2. **Short-term:** Use Ardour Cue window manually (no Launchpad integration)
3. **Long-term:** Revert to timeline-only workflow (remove cue grid, use regions)

**Rollback triggers:**
- Audio dropouts/glitches during live production
- CPU usage >80% sustained
- Operator confusion/errors causing on-air mistakes
- MIDI latency >25ms consistently

---

## Timeline Estimate

- **Phase 1 (Basic Cue Integration):** 4 hours (clip library setup, cue grid population, testing)
- **Phase 2 (Launchpad MIDI):** 3 hours (MIDI Learn, binding map creation, testing)
- **Phase 3 (Lua LED Feedback):** 6 hours (API testing, script modification, performance validation)
- **Phase 4 (Hybrid Workflow Testing):** 2 hours (timeline markers, automation testing)
- *Appendix: Ardour Blind Spots & MIDI Tool Alternatives

### When to Consider External MIDI Tools

**Guideline:** Only use external tools if Ardour core features cannot achieve the workflow requirement.

| Requirement | Ardour Core Solution | External MIDI Tool Alternative | Recommendation |
|-------------|---------------------|-------------------------------|----------------|
| **Trigger pre-recorded clips** | ✅ Cue/Clip system (native) | ❌ Not needed | **Use Ardour** |
| **Live loop recording** | ⚠️ Must record to timeline first | Luppp (JACK loop recorder) | **Use Ardour** (bounce workflow acceptable) |
| **Step sequencing** | ⚠️ MIDI regions + quantize | Hydrogen, QTractor | **Use Ardour** (sufficient for broadcast) |
| **Sample triggering (50+ sounds)** | ⚠️ Cue slots (disk I/O heavy) | LinuxSampler/Sfizz LV2 | **Consider plugin sampler** (RAM-based) |
| **MIDI clip manipulation** | ✅ MIDI regions + inline editor | ❌ Not needed | **Use Ardour** |
| **DJ-style mixing** | ⚠️ Cues + follow actions | Mixxx (JACK DJ software) | **Not SG9 use case** |

### Recommended FLOSS MIDI Tools (if needed)

**Integrated (LV2 Plugins - preferred):**
- **Sfizz:** SFZ sampler (load SoundFonts/SFZ libraries)
- **DrumGizmo:** Multi-sampled drums (high-quality kits)
- **ACE plugins:** Ardour bundled instruments (Reasonable Synth, etc.)

**Standalone (JACK integration - use sparingly):**
- **Hydrogen:** Drum machine/step sequencer (export patterns to MIDI)
- **Luppp:** Live looper (if live loop recording essential)
- **QTractor:** MIDI sequencer (alternative to timeline MIDI editing)

**SG9 Studio Decision:** Prefer ACE plugins and Sfizz (LV2) over standalone tools. Only integrate Hydrogen if background music bed sequencing required.

---

## References

- [.copilot-tracking/research/CLIPS-INTEGRATION-RESEARCH.md](../research/CLIPS-INTEGRATION-RESEARCH.md) - Comprehensive research report + community findings
- [Ardour Manual: Clips Overview](https://manual.ardour.org/clips/clips-overview/)
- [Ardour Manual: Cue Window](https://manual.ardour.org/cue/cue-window-elements/)
- [docs/STUDIO.md](../../docs/STUDIO.md) - Current broadcast workflow
- [docs/MIDI-CONTROLLERS.md](../../docs/MIDI-CONTROLLERS.md) - Launchpad MK2 implementation details
- [Ardour Discourse: Community Workflows](https://discourse.ardour.org/) - Real-world usage stories

---

**Next Steps:**
1. Review plan with stakeholders
2. Schedule Phase 1 implementation (non-disruptive, can test offline)
3. Validate Phase 1 with test episode before proceeding to Phase 2
4. Evaluate need for external MIDI tools after Phase 3 (likely unnecessary for broadcast workflow)
---

**Next Steps:**
1. Review plan with stakeholders
2. Schedule Phase 1 implementation (non-disruptive, can test offline)
3. Validate Phase 1 with test episode before proceeding to Phase 2

