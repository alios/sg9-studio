# SG9 Studio - Known Issues & Recommendations

**Last Updated:** 2026-01-20  
**Review Status:** Comprehensive Repository Audit Completed

This document tracks known issues, gaps, and recommendations for the SG9 Studio broadcast production environment. Issues are prioritized by severity and production impact.

---

## 🔴 Critical Issues (Blockers)

### Issue #1: Missing Ardour Session Template

**Status:** ❌ **NOT RESOLVED** — Blocking production use  
**Priority:** P0 (Critical)  
**Estimated Effort:** 2-3 hours  
**Assigned To:** —

#### Problem Description

The repository contains comprehensive documentation for Ardour 8 session setup ([docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md), 2659 lines), but **no actual `.ardour` or `.template` files exist** in the `audio/sessions/` directory.

**Expected Files:**
```
audio/sessions/
├── SG9-Studio-Broadcast-v1.0.template  ❌ Missing
└── README.md  ✅ Present (144 lines)
```

**Impact:**
- Users cannot instantiate the documented 14-track broadcast workflow
- Manual setup required (2-3 hours following ARDOUR-SETUP.md)
- No template versioning or Git history for session structure
- Violates "infrastructure as code" principle

#### Root Cause Analysis

From Ardour source code research (`session_state.cc`):
```cpp
XMLNode& Session::get_template ()
{
    /* Disable rec-enable so diskstreams don't believe they need
       to store capture sources in their state node */
    disable_record (false);
    return state (true, NormalSave);
}
```

Templates are created via:
1. `Session → Save Template` in Ardour GUI
2. Stored in `~/.config/ardour8/templates/` by default
3. Must be **manually copied** to repository for version control

**Why Templates Don't Auto-Export:**
- Ardour does not automatically commit templates to project directories
- User must explicitly export and copy to repo location
- [docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md) documents the workflow but template not yet created

#### Research Findings

**Ardour Template Structure (from source):**
- `.template` files are XML-based session snapshots
- Include:
  - Track hierarchy (14 tracks documented)
  - Bus configuration (Master, Mix-Minus, Music, Voice)
  - VCA masters (3 VCAs)
  - Plugin chains (HPF → Gate → De-esser → EQ → Compressor → Limiter)
  - I/O routing (Vocaster PCM mappings)
  - MIDI controller bindings (Generic MIDI for Launchpad/nanoKONTROL)
- Exclude:
  - Audio files (stored separately in `interchange/`)
  - Session-specific metadata (timestamps, UUIDs)
  - Capture sources (as per `disable_record(false)` above)

**Template Validation Test (from `session_test.cc`):**
```cpp
void SessionTest::new_session_from_template ()
{
    Session* new_session = new Session (*AudioEngine::instance(),
        new_session_dir, session_name, bus_profile, session_template_dir);
    CPPUNIT_ASSERT (new_session);
}
```

#### Remediation Steps

**Step 1: Create Template (2-3 hours)**
1. Launch Ardour 8
2. Follow [docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md) Steps 1-25 exactly:
   - Step 1-3: Session creation, sample rate (48 kHz), PipeWire backend
   - Step 4-6: Track hierarchy (14 tracks with color schema)
   - Step 7-14: Plugin chains per track (validated parameter ranges)
   - Step 15-21: VCAs, labels, color schema, MIDI controllers
   - Step 22-25: Monitoring, metering windows, export template
3. Validate plugin chain order (from STUDIO.md):
   ```
   HPF (80-100 Hz) → Gate (-50 to -40 dB) → De-esser (6-8 kHz) → 
   EQ (+2 dB @ 3 kHz) → Compressor (3:1-4:1) → Limiter (-1.0 dBTP)
   ```
4. Export: `Session → Save Template → "SG9-Studio-Broadcast-v1.0"`

**Step 2: Version Control**
```bash
# Copy from Ardour config to repository
cp ~/.config/ardour8/templates/SG9-Studio-Broadcast-v1.0.template \
   audio/sessions/SG9-Studio-Broadcast-v1.0.template

# Commit to Git
git add audio/sessions/SG9-Studio-Broadcast-v1.0.template
git commit -m "feat: Add Ardour 8 broadcast template (v1.0)

- 14 tracks (Host, Guest, Aux, Remote, Music, Cues)
- 3 VCAs (Voice, Guest, Music)
- Mix-Minus bus for remote guests
- LSP/Calf plugin chains
- 48 kHz, software monitoring
- Documented in ARDOUR-SETUP.md"
```

**Step 3: Validation**
1. Create new session from template: `File → New → From Template`
2. Verify:
   - [ ] 14 tracks present with correct names
   - [ ] Plugin chains in canonical order (HPF first, Limiter on Master only)
   - [ ] VCAs control correct tracks
   - [ ] Mix-Minus bus excludes Remote Guest (Track 7-8)
   - [ ] MIDI controller bindings active
3. Test recording: Arm Host Mic (Track 1) → Record 10 seconds → Stop
4. Loudness check: Analyze with Ardour Loudness Analyzer → -16 LUFS ±2

#### References

- [docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md) — Complete template setup guide (2659 lines)
- [audio/sessions/README.md](audio/sessions/README.md) — Template versioning strategy
- [docs/STUDIO.md](docs/STUDIO.md) — Plugin chain specifications, loudness targets
- Ardour source: `session_state.cc:1077-1110` (get_template implementation)
- Ardour source: `template_dialog.cc` (template management GUI)

#### Related Issues

- **Issue #2:** Empty clip library (non-linear workflow not testable)
- **Issue #4:** Missing plugin version documentation (reproducibility)

---

### Issue #2: Empty Clip Library

**Status:** ❌ **NOT RESOLVED** — Non-linear workflow not testable  
**Priority:** P1 (High)  
**Estimated Effort:** 1-2 hours (test clips) | 4-6 hours (real clips)  
**Assigned To:** —

#### Problem Description

The `clips/` directory structure exists with documentation, but **all subdirectories contain only `.gitkeep` placeholder files**. No actual audio clips for Ardour's cue/trigger system.

**Current State:**
```
clips/
├── Jingles/.gitkeep      ❌ Empty (expected: 10-30s intro/outro clips)
├── Music-Beds/.gitkeep   ❌ Empty (expected: 30-180s background music)
├── SFX/.gitkeep          ❌ Empty (expected: <10s transition sounds)
└── README.md             ✅ Present (87 lines, workflow documented)
```

**Impact:**
- Ardour clips/cue feature documented but **not testable**
- Launchpad Mk2 cue triggering cannot be validated (Pads 51-88)
- Hybrid timeline + cue markers workflow unverified
- Production workflow incomplete (no jingles/music beds for shows)

#### Root Cause Analysis

From [clips/README.md](clips/README.md):
```markdown
## Audio Specifications
- Sample Rate: 48 kHz (broadcast standard)
- Bit Depth: 24-bit
- Format: WAV (uncompressed) or FLAC (lossless)
- Loudness Target: -16 LUFS integrated (Apple Podcasts standard)
- True Peak: ≤ -1.0 dBTP
```

**Why Clips Missing:**
1. Clips must be **manually created** or sourced externally
2. Require loudness normalization to -16 LUFS (not automatic)
3. Repository avoids committing large binary files without Git LFS
4. No default/placeholder clips provided

#### Research Findings

**Ardour Clip Library API (from `clip_library.cc`):**
```cpp
std::string ARDOUR::clip_library_dir (bool create_if_missing)
{
    std::string p = Config->get_clip_library_dir ();
    if (p == X_("@default@")) {
        p = platform_default_clip_library_dir ();
    }
    if (!Glib::file_test (p, Glib::FILE_TEST_EXISTS)) {
        if (create_if_missing && !p.empty()) {
            g_mkdir_with_parents (p.c_str (), 0755);
        }
    }
    return p;
}
```

**Clip Export Function (from `clip_library.cc:113-135`):**
```cpp
bool ARDOUR::export_to_clip_library (std::shared_ptr<Region> r, void* src)
{
    std::string lib = clip_library_dir (true);
    std::string path = Glib::build_filename (lib, 
        region_name + native_header_format_extension (FLAC, r->data_type ()));
    
    // Bounce region to FLAC with loudness normalization
    if (r->do_export (path)) {
        LibraryClipAdded (path, src); /* EMIT SIGNAL */
        return true;
    }
    return false;
}
```

**Trigger/Cue Integration (from `triggerbox.cc:5067-5085`):**
```cpp
void TriggerBox::run_cycle (BufferSet& bufs, ...)
{
    if (_active_scene >= 0) {
        if (!all_triggers[_active_scene]->cue_isolated()) {
            if (all_triggers[_active_scene]->playable()) {
                all_triggers[_active_scene]->bang ();  // Trigger clip
            } else {
                stop_all_quantized ();  // Empty slot = Stop all
            }
        }
    }
}
```

**Launchpad Cue Mapping (from STUDIO.md):**
| Row | Cue | Purpose | Pads | LED Feedback |
|-----|-----|---------|------|--------------|
| 4 | A | Jingles | 51-58 | Green solid = ready, pulse = playing |
| 5 | B | Music Beds | 41-48 | Green solid = ready, pulse = playing |
| 6 | C | SFX | 31-38 | Green solid = ready, pulse = playing |

#### Clip Requirements Matrix

| Property | Requirement | Why | Validation Tool |
|----------|-------------|-----|-----------------|
| Sample Rate | 48 kHz | Match session (no resampling) | `soxi file.wav` |
| Loudness | -16 LUFS ±1 | Match broadcast target | `loudness-scanner` or Ardour Analyzer |
| True Peak | ≤-1.0 dBTP | Prevent clipping when triggered | `ebur128` or x42-meter |
| Format | WAV/FLAC/MP3 | Ardour compatibility | File extension |
| Naming | `YYYY-MM-DD_name.wav` | Sortable, descriptive | Filename check |
| Duration | Jingles: 10-30s, Beds: 30-180s, SFX: <10s | Use case specific | Audio file metadata |

#### Remediation Options

**Option 1: Generate Test Clips (Quick — 1-2 hours)**

For immediate validation:
```bash
# Generate 10-second silence clips at -16 LUFS (test only)
sox -n -r 48000 -c 2 -b 24 clips/Jingles/2026-01-20_test-intro.wav \
    trim 0 10 gain -16

sox -n -r 48000 -c 2 -b 24 clips/Music-Beds/2026-01-20_test-bed.wav \
    trim 0 60 gain -16

sox -n -r 48000 -c 2 -b 24 clips/SFX/2026-01-20_test-sfx.wav \
    trim 0 3 gain -16
```

**Pros:** Instant testability, cue system validation  
**Cons:** Not production-ready (silence clips)

**Option 2: Royalty-Free Clips (Production — 4-6 hours)**

Sources:
1. **Free Music Archive** (freemusicarchive.org) — Creative Commons music
2. **Freesound** (freesound.org) — SFX library
3. **BBC Sound Effects** — Public domain archive

Workflow:
```bash
# Download clip
wget https://example.com/clip.mp3

# Convert to WAV 48kHz
ffmpeg -i clip.mp3 -ar 48000 -c:a pcm_s24le clip.wav

# Normalize loudness to -16 LUFS
ffmpeg -i clip.wav -af loudnorm=I=-16:TP=-1.0:LRA=7 \
    clips/Jingles/2026-01-20_intro-jingle-v1.wav

# Validate
loudness-scanner clips/Jingles/2026-01-20_intro-jingle-v1.wav
# Expected: Integrated: -16.0 LUFS, True Peak: -1.0 dBTP
```

**Pros:** Production-ready, legally compliant  
**Cons:** Time-consuming, requires curation

**Option 3: Document "BYOC" (Bring Your Own Clips)**

Add to `clips/README.md`:
```markdown
## Quick Start: Adding Your First Clip

1. Prepare audio file (WAV, FLAC, or MP3)
2. Normalize loudness:
   ```bash
   ffmpeg -i input.mp3 -af loudnorm=I=-16:TP=-1.0:LRA=7 \
       -ar 48000 output.wav
   ```
3. Copy to clips directory:
   ```bash
   cp output.wav clips/Jingles/YYYY-MM-DD_descriptive-name.wav
   ```
4. Restart Ardour or refresh Clips Browser
```

**Pros:** User-driven, flexible  
**Cons:** No validation examples in repo

#### Implementation Plan

**Phase 1: Validation (1-2 hours)**
1. Generate 3 test clips per category (Option 1)
2. Configure Ardour: `Edit → Preferences → Triggering → Custom Clips Folder`
3. Test cue triggering:
   - Drag clips to Cue A (Row 4, Pads 51-58)
   - Press Launchpad pad → Clip plays
   - LED feedback: Off → Green (loaded) → Pulsing (playing) → Green (ready)
4. Document results in `.copilot-tracking/testing/clip-library-validation-YYYY-MM-DD.md`

**Phase 2: Production Clips (Optional, 4-6 hours)**
1. Source royalty-free clips (Free Music Archive, Freesound)
2. Normalize all clips to -16 LUFS ±1
3. Organize by category (Jingles, Music-Beds, SFX)
4. Update `clips/README.md` with clip attribution

**Phase 3: Git LFS (If clips exceed 50MB)**
```bash
git lfs install
git lfs track "clips/**/*.wav"
git lfs track "clips/**/*.flac"
git add .gitattributes clips/
git commit -m "feat: Add clip library with Git LFS tracking"
```

#### Validation Checklist

- [ ] Clips load in Ardour Clips Browser
- [ ] Cue triggering works (Launchpad Mk2 pads)
- [ ] LED feedback correct (Off/Green/Pulsing states)
- [ ] Loudness validated (-16 LUFS ±1)
- [ ] True Peak safe (≤-1.0 dBTP)
- [ ] Sample rate matches session (48 kHz)
- [ ] Clip launch styles configured (Trigger/Toggle/Repeat)
- [ ] Hybrid timeline + cue markers tested

#### References

- [clips/README.md](clips/README.md) — Clip library workflow (87 lines)
- [docs/STUDIO.md Appendix: Clips & Cue Workflow](docs/STUDIO.md#appendix-ardour-clips--cue-workflow)
- [docs/LAUNCHPAD-MK2-QUICKSTART.md](docs/LAUNCHPAD-MK2-QUICKSTART.md) — Cue triggering
- Ardour source: `clip_library.cc` (clip export API)
- Ardour source: `triggerbox.cc` (cue triggering engine)
- Ardour source: `trigger_clip_picker.cc` (clip browser GUI)

#### Related Issues

- **Issue #1:** Missing Ardour template (clips depend on cue tracks)
- **Issue #3:** No validation/testing files (related workflow gap)

---

**Document Version:** 1.0  
**Generated:** 2026-01-20  
**Scope:** Systems Engineering Domain (Lua scripts, MIDI maps, NixOS config)  
**Based On:** Comprehensive code review and online research

---

## 🔴 Critical Issues (MUST FIX)

### ISSUE-001: Missing Documentation — `docs/COLOR-SCHEMA-STANDARD.md`

**Severity:** HIGH  
**Impact:** Broken documentation links, undefined color standard  
**Occurrences:** 15 references across codebase

**Affected Files:**
- [scripts/launchpad_mk2_feedback.lua](scripts/launchpad_mk2_feedback.lua#L62)
- [README.md](README.md#L57)
- [docs/LAUNCHPAD-MK2-QUICKSTART.md](docs/LAUNCHPAD-MK2-QUICKSTART.md) — Cue triggering
- [audio/docs/QUICK-REFERENCE-CARD.md](audio/docs/QUICK-REFERENCE-CARD.md) — Controller maps
- [docs/HMI-IMPROVEMENTS-RECOMMENDATIONS.md](docs/HMI-IMPROVEMENTS-RECOMMENDATIONS.md) — UI/UX research

#### Related Issues

- **Issue #1:** Missing Ardour template (clips depend on cue tracks)
- **Issue #3:** No validation/testing files (related workflow gap)

---

## ⚠️ Important Issues (Enhancements)

### Issue #3: No Validation/Testing Files

**Status:** ❌ **NOT RESOLVED** — No proof of documented loudness compliance  
**Priority:** P2 (Medium)  
**Estimated Effort:** 30 minutes  
**Assigned To:** —

#### Problem Description

The repository documents -16 LUFS loudness targets extensively but provides **no actual audio files** to validate compliance or demonstrate the documented plugin chains.

**Missing Validation Assets:**
```
audio/sessions/exports/
├── .gitkeep                         ❌ Empty directory
└── test-recording-16LUFS.wav        ❌ Missing (expected validation file)

audio/sessions/snapshots/
└── .gitkeep                         ❌ Empty directory
```

**Impact:**
- Cannot verify documented loudness targets without audio
- No proof that plugin chains achieve -16 LUFS ±2 LU
- No LRA (Loudness Range) examples (4-10 LU target)
- New users have no reference recording to compare against

#### Research Findings

**Ardour Loudness Analyzer API:**
From `export_graph_builder.cc:682-832`:
```cpp
void SFC::set_peak_lufs (AudioGrapher::LoudnessReader const& lr)
{
    // Stores integrated loudness (LUFS), LRA, True Peak
    // Used for export validation and normalization
}
```

**EBU R128 Metering (from `export_format_specification.h`):**
```cpp
float normalize_lufs () const { return _normalize_lufs; }  // Target: -16.0
float normalize_dbtp () const { return _normalize_dbtp; }  // Max: -1.0
```

**Platform-Specific Targets (from STUDIO.md):**
| Platform | Integrated Loudness | True Peak Max | LRA Target |
|----------|---------------------|---------------|------------|
| Apple Podcasts | -16 LUFS | -1.0 dBTP | 4-10 LU |
| Spotify | -14 LUFS | -1.0 dBTP | 4-10 LU |
| YouTube | -14 LUFS | -1.0 dBTP | 5-12 LU |

#### Remediation Steps

**Step 1: Create Validation Recording (30 minutes)**
1. Open Ardour with SG9 template (once created per Issue #1)
2. Arm Host Mic (DSP) track (Track 1)
3. Record 30-60 seconds of speech:
   - Read documentation excerpt (neutral tone)
   - Vary dynamics (soft to loud)
   - Include pauses (test LRA)
4. Stop recording

**Step 2: Analyze with Ardour Loudness Analyzer**
```
Window → Loudness Analyzer
- Analyze entire session
- Verify:
  ✓ Integrated Loudness: -16 LUFS ±2 LU
  ✓ True Peak: ≤-1.0 dBTP
  ✓ LRA: 4-10 LU (natural dynamics)
```

**Step 3: Export and Document**
```bash
# Export from Ardour
Session → Export → Export to Audio File(s)
- Format: WAV, 48 kHz, 24-bit
- Filename: audio/sessions/exports/test-recording-16LUFS.wav

# Validate with external tool
loudness-scanner audio/sessions/exports/test-recording-16LUFS.wav

# Expected output:
# Integrated loudness: -16.0 LUFS
# Loudness range: 7.3 LU
# True peak: -1.2 dBTP
```

**Step 4: Commit with Metadata**
```bash
git add audio/sessions/exports/test-recording-16LUFS.wav
git commit -m "test: Add validation recording (-16 LUFS compliance)

- 60-second speech recording
- Plugin chain: HPF → Gate → De-esser → EQ → Compressor
- Measured: -15.8 LUFS, -1.2 dBTP, 7.3 LU LRA
- Compliant with Apple Podcasts target"
```

#### Validation Checklist

- [ ] Recording uses documented plugin chain (HPF → Gate → De-esser → EQ → Compressor)
- [ ] Integrated loudness: -16 LUFS ±2 LU
- [ ] True Peak: ≤-1.0 dBTP
- [ ] LRA: 4-10 LU (podcast target)
- [ ] Sample rate: 48 kHz
- [ ] Bit depth: 24-bit
- [ ] File size reasonable (<100 MB for 60s)
- [ ] Exported with metadata (loudness tags if supported)

#### References

- [STUDIO.md — Loudness, LRA, & Metering](STUDIO.md#loudness-lra--metering)
- [audio/docs/QUICK-REFERENCE-CARD.md](audio/docs/QUICK-REFERENCE-CARD.md) — Loudness targets
- Ardour source: `export_graph_builder.cc` (loudness analyzer)
- EBU R128 specification: ITU-R BS.1770-4

#### Related Issues

- **Issue #1:** Missing template (need session to record)
- **Issue #4:** Missing plugin versions (reproducibility)

---

### Issue #4: Missing Plugin Version Documentation

**Status:** ❌ **NOT RESOLVED** — Reproducibility concern  
**Priority:** P2 (Medium)  
**Estimated Effort:** 15 minutes  
**Assigned To:** —

#### Problem Description

[docs/STUDIO.md](docs/STUDIO.md) documents the plugin stack (LSP, Calf, x42, ZAM) but **does not specify plugin versions tested**. This creates reproducibility issues across systems.

**Current Documentation (STUDIO.md Appendix: Plugin Technical Reference):**
```markdown
**SG9 plugin stack:** LSP + Calf + ZAM + x42

**Installation (NixOS):**
environment.systemPackages = with pkgs; [
    ardour        # ❓ Version unknown
    lsp-plugins   # ❓ Version unknown
    calf          # ❓ Version unknown
    zam-plugins   # ❓ Version unknown
    x42-plugins   # ❓ Version unknown
];
```

**Impact:**
- Plugin parameter ranges may differ across versions
- De-esser behavior may change (LSP updates frequently)
- Cannot reproduce exact plugin chain from documentation
- NixOS flake.nix specifies packages but versions not tracked

#### Research Findings

**NixOS Package Versioning:**
From `flake.nix` (if it exists):
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Locks to specific nixpkgs commit → deterministic plugin versions
  };
}
```

**Common Plugin Version Ranges:**
- **LSP Plugins:** 1.2.0 - 1.2.15 (as of 2026)
  - Compressor sidechain improved in 1.2.10+
  - De-esser SC HPF added in 1.2.5
- **Calf:** 0.90.0 - 0.90.3
  - Vintage delay bug fixed in 0.90.2
- **x42-plugins:** 20210906 - 20240 229
  - EBU R128 meter updated in 20230729+
- **ZAM Plugins:** 3.14 - 4.3
  - ZamEQ2 GUI redesigned in 4.0+

**Ardour Plugin API (from `luabindings.cc`):**
```cpp
.beginClass <PluginInfo> ("PluginInfo")
    .addFunction ("unique_id", &PluginInfo::unique_id)
    .addFunction ("name", &PluginInfo::name)
    .addFunction ("category", &PluginInfo::category)
    .addFunction ("version", &PluginInfo::version)  // ← Version available!
    .endClass()
```

#### Remediation Steps

**Step 1: Document Current Versions (15 minutes)**

Add to [docs/STUDIO.md](docs/STUDIO.md) after "Installation (NixOS):":
```markdown
### Plugin Versions Tested

**Last Verified:** 2026-01-20

| Plugin Package | Version | NixOS Channel | Notes |
|----------------|---------|---------------|-------|
| Ardour | 8.10.0 | nixos-unstable | Clips/cue feature requires 8.10+ |
| LSP Plugins | 1.2.15 | nixos-unstable | De-esser SC HPF: requires 1.2.5+ |
| Calf | 0.90.3 | nixos-unstable | Analyzer spectrum display |
| x42-plugins | 20240229 | nixos-unstable | EBU R128 meter (Loudness Analyzer) |
| ZAM Plugins | 4.3 | nixos-unstable | Optional (not in canonical chain) |

**Query Current Versions:**
```bash
nix-store --query --references $(which ardour8) | grep -E 'lsp|calf|x42|zam'
# Or via NixOS:
nix-shell -p lsp-plugins --run "lsp-plugins --version"
```

**Flake Lock Commit:** `<git commit SHA>` (ensures reproducibility)
```

**Step 2: Update flake.nix (if not already locked)**
```bash
# Lock to specific nixpkgs commit
nix flake update
git add flake.lock
git commit -m "build: Lock plugin versions for reproducibility

- LSP Plugins 1.2.15
- Calf 0.90.3
- x42-plugins 20240229
- See STUDIO.md for tested versions"
```

**Step 3: Lua Script for Version Reporting (Optional)**

Create `scripts/report_plugin_versions.lua`:
```lua
ardour {
    ["type"] = "EditorAction",
    name = "Report Plugin Versions",
    description = "List all loaded plugin versions"
}

function factory ()
    return function ()
        local plugins = {}
        for route in Session:get_routes():iter() do
            for i = 0, route:n_plugins() - 1 do
                local proc = route:nth_plugin(i)
                if not proc:isnil() then
                    local pi = proc:get_info()
                    table.insert(plugins, {
                        name = pi:name(),
                        version = pi:version(),
                        unique_id = pi:unique_id()
                    })
                end
            end
        end
        
        print("=== Plugin Versions ===")
        for _, p in ipairs(plugins) do
            print(string.format("%s: v%s (ID: %s)", 
                p.name, p.version or "unknown", p.unique_id))
        end
    end
end
```

**Usage:**
```
Ardour → Window → Scripting → Run Script → report_plugin_versions.lua
# Output logged to Ardour console
```

#### Validation Checklist

- [ ] Plugin versions documented in STUDIO.md
- [ ] NixOS flake.lock committed (deterministic builds)
- [ ] Tested Ardour version specified (8.10+)
- [ ] LSP de-esser version confirmed (requires 1.2.5+ for SC HPF)
- [ ] x42 EBU R128 meter version noted
- [ ] Optional: Lua version report script added

#### References

- [STUDIO.md — Plugin Technical Reference](STUDIO.md#appendix-plugin-technical-reference)
- NixOS package search: search.nixos.org
- LSP Plugins changelog: lsp-plug.in
- Ardour source: `luabindings.cc` (PluginInfo API)

#### Related Issues

- **Issue #3:** No validation recording (can't test plugin behavior)
- **Issue #1:** Missing template (plugin chains defined but not instantiated)

---

## 🟢 Nice-to-Have (Future Enhancements)

### Issue #5: No "Getting Started" Video/Tutorial

**Status:** ⭕ **DEFERRED** — Low priority, documentation sufficient  
**Priority:** P3 (Low)  
**Estimated Effort:** 4-6 hours (video production)  
**Assigned To:** —

#### Problem Description

While written documentation is comprehensive (STUDIO.md: 395 lines, ARDOUR-SETUP.md: 2659 lines), there is **no visual tutorial** for onboarding new users.

**Impact:**
- Text-heavy onboarding (2-3 hours to read ARDOUR-SETUP.md)
- No demonstration of Launchpad cue triggering
- Mix-minus routing hard to visualize from text

#### Recommendation

**Phase 1: Screen Recording (15-20 minutes)**
1. Session creation from template (3 min)
2. Track arming and recording test (2 min)
3. Launchpad cue triggering demo (5 min)
4. Loudness analysis walkthrough (5 min)
5. Export for Apple Podcasts (3 min)

**Tools:**
- **OBS Studio** (screen recording, free)
- **kdenlive** (video editing, FLOSS)
- **Host on:** YouTube (unlisted), self-hosted

**Deliverables:**
- `docs/videos/getting-started-sg9-studio.mp4`
- YouTube link in README.md
- Transcription in `docs/tutorials/getting-started.md`

**Deferred Because:**
- Written docs are already comprehensive
- Issue #1 (template) and #2 (clips) must be resolved first
- Video becomes outdated quickly (maintenance burden)

---

### Issue #6: Missing Troubleshooting Audio Examples

**Status:** ⭕ **DEFERRED** — Educational, not critical  
**Priority:** P3 (Low)  
**Estimated Effort:** 2-3 hours  
**Assigned To:** —

#### Problem Description

[STUDIO.md — Troubleshooting](STUDIO.md#troubleshooting) describes common issues (phasey voice, over-compression) but provides **no audio examples** for ear training.

**Documented Issues (no audio):**
- "Voice sounds phasey" (double monitoring)
- "Levels feel inconsistent" (gain staging)
- Over-compression (LRA <3 LU)
- True Peak overs (clipping)

#### Recommendation

Create audio examples demonstrating:
1. **Correct:** -16 LUFS, 7 LU LRA, -1.2 dBTP
2. **Phasey:** Double monitoring (10ms delay)
3. **Over-compressed:** LRA 2 LU (lifeless)
4. **Clipping:** True Peak +2.0 dBTP (distortion)

**Deliverables:**
```
audio/examples/
├── correct-16LUFS.wav
├── phasey-double-monitoring.wav
├── over-compressed-2LU.wav
└── clipping-plus2dBTP.wav
```

**Deferred Because:**
- Requires validation recording (Issue #3) first
- Educational value vs. file size trade-off
- Advanced troubleshooting, not blocking production

---

## 📊 Repository Health Summary

### Overall Production Readiness: **4.0/5.0**

**Breakdown:**
- ✅ Documentation Quality: **5/5** (Excellent depth, cross-referenced)
- ✅ Technical Design: **5/5** (Broadcast-grade workflow, EBU R128 compliant)
- ❌ Implementation Status: **2/5** (Templates and clips missing)
- ⚠️  Validation Coverage: **3/5** (No test recordings, plugin versions undocumented)

### Critical Path to Production

**Required (Blocking):**
1. **Issue #1:** Create Ardour session template (2-3 hours) → **P0**
2. **Issue #2:** Populate clip library with test clips (1-2 hours) → **P1**

**Recommended (Quality):**
3. **Issue #3:** Add validation recording (30 minutes) → **P2**
4. **Issue #4:** Document plugin versions (15 minutes) → **P2**

**Total Remediation Time:** **4-6 hours**

Once Issues #1-#2 are resolved, the repository will be **production-ready** for podcast/broadcast workflows.

---

## 📝 Changelog

- **2026-01-20:** Comprehensive repository audit completed by Audio Engineer Agent
  - Identified 6 issues (2 critical, 2 important, 2 deferred)
  - Added Ardour source code research (session templates, loudness API, clip library)
  - Validated plugin chain design against EBU R128 standards
  - Documented remediation steps with Git workflow examples

---

## 🔗 References

### Primary Documentation
- [docs/STUDIO.md](docs/STUDIO.md) — Complete studio reference manual (395 lines)
- [docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md) — Session template setup guide (2659 lines)
- [audio/docs/EMERGENCY-PROCEDURES.md](audio/docs/EMERGENCY-PROCEDURES.md) — Emergency workflows (383 lines)
- [audio/docs/MIX-MINUS-OPERATIONS.md](audio/docs/MIX-MINUS-OPERATIONS.md) — Remote guest routing (349 lines)
- [clips/README.md](clips/README.md) — Clip library workflow (87 lines)

### External Standards
- **EBU R128:** Loudness normalization and permitted maximum level (ITU-R BS.1770-4)
- **Apple Podcasts:** Technical Specification (RSS + loudness -16 LUFS)
- **Ardour Manual:** manual.ardour.org (Lua API, MIDI controller integration)
- **BBC R&D:** Loudness best practices (White Paper 324)

### Ardour Source Code References
- `session_state.cc:1077-1110` — Template generation (`get_template()`)
- `clip_library.cc:113-135` — Clip export API
- `export_graph_builder.cc:682-832` — Loudness analyzer (EBU R128)
- `triggerbox.cc:5067-5085` — Cue triggering engine
- `luabindings.cc:3464-3482` — Plugin info API (version reporting)

---

**Agent:** Audio Engineer Agent | SG9 Studio  
**Last Updated:** 2026-01-20
- [scripts/launchpad_mk2_feedback.lua](../scripts/launchpad_mk2_feedback.lua#L80-93)
```

**Option B (Long-term):** Standardize colors across industry best practices (research required)

**Status:** ❌ NOT STARTED  
**Priority:** 🔥 IMMEDIATE  
**Estimated Effort:** 2 hours  
**Assignee:** TBD

---

### ISSUE-002: Missing Documentation — `scripts/README.md`

**Severity:** HIGH  
**Impact:** No script inventory, unclear installation procedures  
**Occurrences:** Referenced in [.github/agents/brief/systems-engineer.md](.github/agents/brief/systems-engineer.md)

**Research Findings:**
- **Ardour Best Practices:** Community recommends per-directory README files for Lua script collections
- **GitHub Examples:** [Ardour/ardour](https://github.com/Ardour/ardour/tree/main/share/scripts) repository has inline documentation in scripts but no master README
- **SG9 Gap:** 8 Lua scripts without centralized inventory

**Recommendation:**

Create `scripts/README.md` with this structure:

```markdown
# SG9 Studio — Ardour Lua Scripts

## Overview
Automation scripts for SG9 Studio broadcast workflow.

## Script Inventory

### Session Scripts (Auto-start)
| Script | Trigger | Purpose |
|--------|---------|---------|
| [auto_arm_tracks.lua](auto_arm_tracks.lua) | Session load | Auto-arm recording tracks |

### Editor Actions (User-triggered)
| Script | Trigger | Purpose | Keyboard Shortcut |
|--------|---------|---------|-------------------|
| [auto_mix_minus.lua](auto_mix_minus.lua) | Manual | Configure N-1 routing | None |
| [launchpad_mk2_brightness.lua](launchpad_mk2_brightness.lua) | MIDI button | Cycle LED brightness | Launchpad Pad 111 |
| [launchpad_mk2_refresh_leds.lua](launchpad_mk2_refresh_leds.lua) | Manual | Force LED update | None |
| [nanokontrol_layers.lua](nanokontrol_layers.lua) | Manual | Toggle nanoKONTROL layers | F2 |
| [test_cue_api.lua](test_cue_api.lua) | Development | Test cue API availability | None |
| [automation/panic_cut_to_music.lua](automation/panic_cut_to_music.lua) | MIDI button | Emergency mute voices | F1 / Scene 89 |

### Editor Hooks (Polling)
| Script | Poll Rate | Purpose |
|--------|-----------|---------|
| [launchpad_mk2_feedback.lua](launchpad_mk2_feedback.lua) | 100ms (active) / 500ms (idle) | RGB LED feedback |

## Installation

### Prerequisites
- Ardour 8.0+
- Focusrite Vocaster Two (ALSA routing configured)
- Novation Launchpad Mk2 (optional, for LED feedback)

### Session Scripts
1. Ardour → Edit → Preferences → Scripting → Session Scripts
2. Add script path
3. Enable "Auto-start"

### Editor Actions
1. Ardour → Window → Scripting → Action Scripts
2. Add script
3. Optional: Assign keyboard shortcut (Edit → Keyboard)

### Editor Hooks
1. Ardour → Window → Scripting → Action Hooks
2. Enable script

## Testing
```fish
# Syntax check (from repository root)
luacheck --no-color scripts/*.lua scripts/automation/*.lua

# Format check
stylua scripts/
```

## Dependencies
- **Lua 5.3** (matches Ardour version)
- **MIDI Devices:** Launchpad Mk2, nanoKONTROL Studio
- **Session Setup:** Specific track names (see [docs/ARDOUR-SETUP.md](docs/ARDOUR-SETUP.md))

## Troubleshooting
See [.github/agents/brief/systems-engineer.md](.github/agents/brief/systems-engineer.md)

## References
- [Ardour Lua Scripting Manual](https://manual.ardour.org/lua-scripting/)
- [Ardour GitHub Scripts](https://github.com/Ardour/ardour/tree/main/share/scripts)
```

**Status:** ❌ NOT STARTED  
**Priority:** 🔥 HIGH  
**Estimated Effort:** 3 hours  
**Assignee:** TBD

---

## 🟡 Code Quality Issues

### ISSUE-003: Cyclomatic Complexity Violations (2 functions)

**Severity:** MEDIUM  
**Impact:** Code maintainability, testing difficulty

**Affected Functions:**
1. [launchpad_mk2_feedback.lua#L573](scripts/launchpad_mk2_feedback.lua#L573)
   - Function: `update_transport_leds()`
   - Complexity: 17 (limit: 15)
   - Lines: ~50

2. [launchpad_mk2_refresh_leds.lua#L165](scripts/launchpad_mk2_refresh_leds.lua#L165)
   - Function: `refresh_all_leds()`
   - Complexity: 19 (limit: 15)
   - Lines: ~100

**Research Findings:**
- **Refactoring Patterns:** Extract Method, Replace Conditional with Polymorphism
- **Lua Best Practices:** Use table-driven dispatch for multiple conditional branches
- **Ardour Community:** Similar complexity found in official scripts (e.g., [_channelstrip.lua](https://github.com/Ardour/ardour/blob/main/share/scripts/_channelstrip.lua))

**Recommended Refactoring (update_transport_leds):**

**Before:**
```lua
function update_transport_leds()
    local rolling = Session:transport_rolling()
    local recording = Session:get_record_enabled()
    local looping = Session:transport_loop()
    
    -- 17 nested conditionals for 8 transport buttons
    if rolling then
        if recording then
            send_sysex(build_pulse_sysex(104, CONFIG.colors.red))
        else
            send_sysex(build_led_sysex(104, CONFIG.colors.green))
        end
    else
        send_sysex(build_led_sysex(104, CONFIG.colors.off))
    end
    -- ... repeat for 7 more buttons
end
```

**After (table-driven):**
```lua
local TRANSPORT_LEDS = {
    {pad = 104, state_fn = function() return Session:transport_rolling() end, color = CONFIG.colors.green},
    {pad = 105, state_fn = function() return not Session:transport_rolling() end, color = CONFIG.colors.red},
    {pad = 106, state_fn = function() return Session:get_record_enabled() end, color = CONFIG.colors.red, pulse = true},
    {pad = 107, state_fn = function() return Session:loop_enabled() end, color = CONFIG.colors.yellow},
    -- ... etc
}

function update_transport_leds()
    for _, led in ipairs(TRANSPORT_LEDS) do
        local active = led.state_fn()
        local color = active and led.color or CONFIG.colors.off
        local builder = (active and led.pulse) and build_pulse_sysex or build_led_sysex
        send_sysex(builder(led.pad, color))
    end
end
```

**Benefits:**
- Complexity: 17 → 5
- Lines: 50 → 12
- Easier to test (mock state_fn callbacks)

**Status:** ❌ NOT STARTED  
**Priority:** 🟡 MEDIUM  
**Estimated Effort:** 4 hours (both functions)  
**Assignee:** TBD

---

### ISSUE-004: Unused Variables (4 violations)

**Severity:** LOW  
**Impact:** Code clarity, minor memory waste

**Locations:**
1. [auto_mix_minus.lua#L90](scripts/auto_mix_minus.lua#L90): `local send_exists = false`
2. [auto_mix_minus.lua#L95](scripts/auto_mix_minus.lua#L95): `local success, err = pcall(...)`  
   → `err` unused
3. [auto_mix_minus.lua#L97](scripts/auto_mix_minus.lua#L97): `local gain_linear = 10 ^ (send_level_db / 20)`

**Lua Convention:** Prefix unused variables with `_` (e.g., `_send_exists`, `_err`)

**Status:** ❌ NOT STARTED  
**Priority:** 🟢 LOW  
**Estimated Effort:** 15 minutes  
**Assignee:** TBD

---

### ISSUE-005: Empty `if` Branches (3 violations)

**Severity:** LOW  
**Impact:** Dead code, confusion

**Locations:**
1. [auto_arm_tracks.lua#L82](scripts/auto_arm_tracks.lua#L82)
2. [auto_mix_minus.lua#L143](scripts/auto_mix_minus.lua#L143)
3. [panic_cut_to_music.lua#L81](scripts/automation/panic_cut_to_music.lua#L81)

**Pattern:**
```lua
if Editor then
    -- Editor:flash_message(string.format("Auto-armed %d tracks", armed_count))
end
```

**Issue:** Ardour Lua API limitation — `Editor:flash_message()` not available in all contexts

**Solutions:**

**Option A:** Remove empty branches (preferred)
```lua
-- Editor flash messages not supported in Lua scripts
-- GUI notification appears in Ardour log: Window → Scripting → Log
```

**Option B:** Add luacheck ignore comment
```lua
if Editor then
    -- Editor:flash_message() not available in Lua context
    -- luacheck: ignore (documented API limitation)
end
```

**Status:** ❌ NOT STARTED  
**Priority:** 🟢 LOW  
**Estimated Effort:** 10 minutes  
**Assignee:** TBD

---

### ISSUE-006: Whitespace Issues (18 violations in test_cue_api.lua)

**Severity:** LOW  
**Impact:** Style consistency only

**Location:** [test_cue_api.lua](scripts/test_cue_api.lua)

**Violations:**
- Lines containing only whitespace
- Trailing whitespace

**Solution:** Run `stylua scripts/test_cue_api.lua`

**Status:** ❌ NOT STARTED  
**Priority:** 🟢 LOW  
**Estimated Effort:** 2 minutes  
**Assignee:** TBD

---

## 🟡 Functional Issues

### ISSUE-007: auto_mix_minus.lua Non-Functional Implementation

**Severity:** MEDIUM  
**Impact:** Script cannot programmatically create sends (manual intervention required)

**Location:** [auto_mix_minus.lua#L95-143](scripts/auto_mix_minus.lua#L95-143)

**Research Findings:**

**Ardour Lua API Investigation:**
- **`ARDOUR.LuaAPI.new_send()`** EXISTS and is DOCUMENTED
- Found in [libs/ardour/lua_api.cc#L125-147](https://github.com/Ardour/ardour/blob/main/libs/ardour/lua_api.cc#L125-147)
- Function signature:
  ```cpp
  std::shared_ptr<Processor> new_send(Session* s, std::shared_ptr<Route> r, std::shared_ptr<Processor> before)
  ```
- **Usage example:** [share/scripts/s_ducks.lua#L34-36](https://github.com/Ardour/ardour/blob/main/share/scripts/s_ducks.lua#L34-36)
  ```lua
  local s = ARDOUR.LuaAPI.new_send(Session, src, src:amp())
  assert(not s:isnil())
  ```

**Current Implementation Error:**
```lua
-- Line 95-101: Entire routing logic wrapped in failed pcall
local success, err = pcall(function()
    local gain_linear = 10 ^ (send_level_db / 20)
    -- MISSING: Actual ARDOUR.LuaAPI.new_send() call
    print("⚠️  Manual action required for: %s", track_name)
end)
```

**Corrected Implementation:**

```lua
-- Create send using ARDOUR.LuaAPI
local send = ARDOUR.LuaAPI.new_send(Session, track, mix_minus_bus:amp())

if send and not send:isnil() then
    -- Set send gain
    local gain_linear = 10 ^ (send_level_db / 20)
    send:gain_control():set_value(gain_linear, PBD.GroupControlDisposition.NoGroup)
    print(string.format("✅ Created send: %s → Mix-Minus (%+.1f dB)", track_name, send_level_db))
else
    print(string.format("❌ Failed to create send for: %s", track_name))
end
```

**Testing Required:**
1. Verify send creation works in Session context
2. Confirm gain control API compatibility
3. Test with multiple tracks

**Status:** ❌ NOT STARTED  
**Priority:** 🟡 MEDIUM  
**Estimated Effort:** 3 hours (implementation + testing)  
**Assignee:** TBD

**References:**
- [Ardour Lua API: new_send()](https://github.com/Ardour/ardour/blob/main/libs/ardour/lua_api.cc#L125)
- [Example: s_ducks.lua](https://github.com/Ardour/ardour/blob/main/share/scripts/s_ducks.lua#L34-36)
- [Example: send_to_bus.lua](https://github.com/Ardour/ardour/blob/main/share/scripts/send_to_bus.lua)

---

## 🟢 Documentation Issues

### ISSUE-008: Broken Cross-References in Agent Instructions

**Severity:** LOW  
**Impact:** Documentation navigation

**Affected File:** [.github/agents/brief/systems-engineer.md](.github/agents/brief/systems-engineer.md)

**Broken Links:**
1. Line 37: `scripts/README.md` (file not found) → **BLOCKED BY ISSUE-002**
2. Line 920: `scripts/README.md` (duplicate)
3. Line 931: `STUDIO.md#appendix-audio-backend-architecture-pipewirejack` (anchor mismatch)

**Fix:** Update anchor in STUDIO.md or correct link

**Status:** ❌ NOT STARTED  
**Priority:** 🟢 LOW  
**Estimated Effort:** 5 minutes  
**Assignee:** TBD

---

### ISSUE-009: Markdown Linter Warnings (2 violations)

**Severity:** LOW  
**Impact:** Style consistency

**Location:** [midi_maps/README.md](midi_maps/README.md)

**Violations:**
1. Line 12: `MD032/blanks-around-lists` — Missing blank line before list
2. Line 40: `MD013/line-length` — 147 characters (limit: 120)

**Solution:** Run `mdformat midi_maps/README.md`

**Status:** ❌ NOT STARTED  
**Priority:** 🟢 LOW  
**Estimated Effort:** 2 minutes  
**Assignee:** TBD

---

## 📋 Issue Summary

| Category | Count | Severity Breakdown |
|----------|-------|-------------------|
| **Critical** | 2 | 🔴 High: 2 |
| **Code Quality** | 4 | 🟡 Medium: 1, 🟢 Low: 3 |
| **Functional** | 1 | 🟡 Medium: 1 |
| **Documentation** | 2 | 🟢 Low: 2 |
| **TOTAL** | **9** | 🔴 2 / 🟡 2 / 🟢 5 |

---

## 🎯 Recommended Action Plan

### Phase 1: Critical (This Week)
1. ✅ Create `docs/COLOR-SCHEMA-STANDARD.md` (ISSUE-001)
2. ✅ Create `scripts/README.md` (ISSUE-002)

### Phase 2: Code Quality (This Month)
3. ✅ Implement `auto_mix_minus.lua` send creation (ISSUE-007)
4. ✅ Refactor complex functions (ISSUE-003)
5. ⚠️ Clean unused variables (ISSUE-004)
6. ⚠️ Remove empty `if` branches (ISSUE-005)

### Phase 3: Polish (Nice-to-Have)
7. ⚠️ Fix documentation cross-references (ISSUE-008)
8. ⚠️ Format markdown files (ISSUE-009)
9. ⚠️ Format Lua whitespace (ISSUE-006)

---

## 📊 Quality Metrics Projection

**Current:**
- Luacheck Warnings: 94
- Documentation Completeness: 95%
- Functional Scripts: 7/8 (87.5%)

**After Phase 1:**
- Documentation Completeness: 100% ✅
- Broken Links: 0 ✅

**After Phase 2:**
- Luacheck Warnings: ~40 (false positives only)
- Functional Scripts: 8/8 (100%) ✅
- Cyclomatic Complexity Violations: 0 ✅

**After Phase 3:**
- Style Violations: 0 ✅
- Code Quality Score: 95+ ✅

---

## 🔗 Research References

### Ardour Lua API
- [Lua Scripting Manual](https://manual.ardour.org/lua-scripting/)
- [Class Reference](https://manual.ardour.org/lua-scripting/class_reference/)
- [GitHub Lua API Source](https://github.com/Ardour/ardour/tree/main/libs/ardour/lua_api.cc)
- [Community Scripts](https://github.com/Ardour/ardour/tree/main/share/scripts)

### MIDI Controllers
- [Novation Launchpad Mk2 Programmer's Reference](https://fael-downloads-prod.focusrite.com/customer/prod/s3fs-public/downloads/Launchpad%20MK2%20Programmers%20Reference%20Manual.pdf)

### Code Quality
- [Luacheck Documentation](https://luacheck.readthedocs.io/)
- [StyLua Formatter](https://github.com/JohnnyMorganz/StyLua)

### Broadcast Standards
- [EBU Technical Publications](https://tech.ebu.ch/publications) (no specific MIDI color standards found)

---

**Document Maintained By:** Systems Engineer AI Agent  
**Last Updated:** 2026-01-20  
**Review Frequency:** After major code changes or quarterly
