# SG9 Studio — Setup & Reference Manual

**Document Version:** 2.0 | **Last Updated:** 2026-01-19

This manual documents the SG9 Studio broadcast workflow using Ardour 8, the Focusrite Vocaster Two,
and FLOSS plugins. It standardizes on **software monitoring** in Ardour while the Vocaster provides
clean I/O and physical volume control.

## Quick Start (Daily)

- Power on the Vocaster Two and confirm your saved routing in `alsa-scarlett-gui`.
- Open Ardour and load the SG9 session/template.
- Monitor on **Guest headphones** (primary reference). Set comfortable levels with the hardware knobs.
- Arm what you need:
  - Track 1: Host Mic (processed)
  - Track 2: Host Mic (raw safety)
  - Track 5: Aux input (phone/tablet)
  - Track 7: Remote guest
- Pre-show checks (30–60 seconds):
  - No double monitoring (voice sounds clean, not phasey)
  - Remote echo check (guest does not hear themselves)
  - Loudness check: play 30 seconds and verify **-16 LUFS ±2 LU** and **TP ≤ -1.0 dBTP**

## Quick Start (First-Time Setup)

1. Configure hardware routing in [ALSA routing](#alsa-routing-vocaster--alsa-scarlett-gui).
2. Follow the comprehensive [Ardour 8 Template Setup Guide](ARDOUR-SETUP.md) to configure your session, tracks, busses, VCAs, and processing chains.
3. Verify loudness targets in [Loudness, LRA, & Metering](#loudness-lra--metering).

## Signal Flow

```mermaid
flowchart LR
    Mic[Mic] --> VocADC[Vocaster ADC]
    VocADC --> ALSADrv[ALSA Driver]
    ALSADrv --> PW[PipeWire Audio Server]
    PW --> JACK[JACK API]
    JACK --> ArdIn[Ardour Input]
    ArdIn --> Chain[Plugin Chain]
    Chain --> Master[Master Bus]
    Master --> JACKOut[JACK API]
    JACKOut --> PWOut[PipeWire]
    PWOut --> ALSAOut[ALSA Driver]
    ALSAOut --> VocDAC[Vocaster DAC]
    VocDAC --> Mon[Monitors + Host HP]
    VocDAC --> Guest[Guest HP]
    ArdIn -. "Software monitoring in Ardour" .-> Master
```

**Audio Stack:** Hardware (Vocaster) → ALSA driver → PipeWire → JACK API → Ardour  
**Hardware Routing:** ALSA (via alsa-scarlett-gui) | **Audio Server:** PipeWire | **Ardour Backend:** JACK

## Hardware Overview

### Vocaster Two I/O

**Inputs**

- Host XLR (rear): primary mic
- Guest XLR (rear): optional guest mic
- Aux (front, 3.5 mm): phone/tablet
- Bluetooth: optional wireless audio
- USB: multichannel I/O to/from computer

**Outputs**

- Monitor L/R (rear TRS)
- Host headphones (front)
- Guest headphones (front, primary monitoring)

**Output topology**

- **Destination A:** Monitors + Host headphones (shared)
- **Destination B:** Guest headphones (independent)

## Monitoring Model (Software Monitoring)

SG9 Studio uses **software monitoring in Ardour**.

- Ardour controls **monitoring content** (what you hear).
- The Vocaster controls **physical loudness** only.
- Do **not** rely on the Vocaster mixer for monitoring content.

**Practical rule**: Set hardware knobs once for comfort, then mix entirely in Ardour.

## ALSA Routing (Vocaster + alsa-scarlett-gui)

**Goal:** Route raw inputs to Ardour and route Ardour’s master output to all destinations.

### Minimal routing map

| Source (Hardware) | → | Sink (USB to Ardour) | Purpose |
| --- | --- | --- | --- |
| Analogue 1 | → | PCM 01 | Host mic → Track 1 |
| Analogue 2 | → | PCM 05 | Guest mic → Track 2 |

| Source (USB from Ardour) | → | Sink (Hardware Output) | Purpose |
| --- | --- | --- | --- |
| PCM 01/02 | → | Analogue 1/2 | Monitors L/R |
| PCM 01/02 | → | Analogue 3/4 | Host HP L/R |
| PCM 01/02 | → | Analogue 5/6 | Guest HP L/R |

**Optional loopback for music capture**

| Source | → | Sink | Purpose |
| --- | --- | --- | --- |
| PCM 03/04 | → | PCM 03/04 | External audio → Ardour loopback track |

## Ardour Configuration

For complete Ardour 8 session setup including tracks, busses, VCAs, processing chains, MIDI controllers, and modern workflow features, see the [Ardour 8 Template Setup Guide](ARDOUR-SETUP.md).

**Quick reference:**
- **Monitoring Model:** Software Monitoring (Ardour controls content, Vocaster controls volume)
- **Audio System:** JACK (via PipeWire) with Vocaster Two
- **Sample Rate:** 48 kHz
- **Buffer Size:** 128–256 samples (adjustable based on CPU)
- **Processing Order:** HPF → Gate → De-esser (LSP SC) → EQ → Compressor → Limiter

## Loudness, LRA, & Metering

### Platform targets

| Platform | Integrated Loudness | True Peak Max | Notes |
| --- | --- | --- | --- |
| Apple Podcasts | -16 LUFS | -1.0 dBTP | Stereo target |
| Spotify | -14 LUFS | -1.0 dBTP | Normalized playback |
| YouTube | -14 LUFS | -1.0 dBTP | Loudness normalized |
| Amazon | -14 LUFS | -2.0 dBTP | More conservative TP |
| EBU R128 | -23 LUFS ±0.5 | -1.0 dBTP | Broadcast standard |

**Recommendation:** Produce at **-16 LUFS** for broadest compatibility, then derive other targets if needed.

### LRA targets

- Podcast: **4–10 LU**
- Broadcast: **5–15 LU**

If LRA is too low, ease compression. If too high, increase compression or tighten thresholds.

### Metering recommendations

- **Ardour Loudness Analyzer** (EBU R128)
- **x42-meter** for True Peak
- **Calf Analyzer** for spectrum + phase

## Redundancy Recording (Raw Safety)

Record a raw, unprocessed mono track in parallel with the processed chain.

- **Why:** Recovery from over-processing, clipping, or plugin issues.
- **Disk budget:** 48 kHz / 24-bit mono ≈ 8.2 MB per minute.
- **Recovery workflow:** Align the raw track, then reprocess with the canonical chain.

## Operational Workflows

### Solo recording

1. Arm Host Mic (DSP) and Host Mic (Raw).
2. Verify monitoring is from Ardour (no hardware mix).
3. Record.

### Remote interview

1. Arm Host Mic, Raw, and Remote Guest tracks.
2. Confirm mix-minus is generated in Ardour (no return in VoIP send).
3. Record.

### Aux guest

1. Plug device into Aux.
2. Arm Aux track.
3. Level match and record.

### Preflight validation

- Send test tone to Playback 1–2 and 3–4 to confirm destination mapping.
- Verify no echo on remote call (guest does not hear themselves).
- Play 30 seconds of content and verify **-16 LUFS ±2** and **TP ≤ -1.0 dBTP**.

## Troubleshooting

**Voice sounds phasey**

- Ensure hardware monitoring is off and Ardour is monitoring.

**Remote guest hears themselves**

- Remove return audio from the VoIP send bus.

**Levels feel inconsistent**

- Re-check gain staging: input peaks -18 to -12 dBFS pre-plugins.

**True Peak overs**

- Increase limiter oversampling and lower ceiling to -1.5 dBTP if needed.

## Appendices

### Appendix: Audio Backend Architecture (PipeWire/JACK)

**SG9 Studio uses PipeWire with JACK compatibility layer.**

**Audio Stack Layers:**

1. **Hardware Layer:** Focusrite Vocaster Two (USB audio interface)
2. **ALSA Driver:** Low-level kernel driver for hardware communication
3. **PipeWire:** Modern audio server providing JACK API compatibility
4. **JACK API:** Industry-standard pro audio interface used by Ardour
5. **Application Layer:** Ardour 8 DAW

**Key Configuration:**

- **Sample Rate:** 48 kHz (configurable via PipeWire)
- **Buffer Size:** 128–256 samples (typical for broadcast)
- **Quantum:** PipeWire's equivalent to JACK buffer size
- **CPU Governor:** Should be set to "performance" mode for low-latency

**PipeWire Quantum Settings:**

```conf
# ~/.config/pipewire/pipewire.conf.d/custom.conf
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 1024     # Default buffer size
    default.clock.min-quantum = 32   # Minimum allowed
    default.clock.max-quantum = 8192 # Maximum allowed
}
```

**Why PipeWire + JACK?**

- **Unified Audio:** Single server handles both desktop audio and pro audio
- **JACK Compatibility:** Ardour sees standard JACK API
- **Low Latency:** Comparable to native JACK (<10 ms typical)
- **Session Management:** WirePlumber handles routing and connections
- **Modern Features:** Better device hotplug, Bluetooth, network audio

**ALSA Routing Coexistence:**

- ALSA layer still handles Vocaster hardware routing (via alsa-scarlett-gui)
- PipeWire sits above ALSA, providing JACK API to Ardour
- Hardware routing (PCM → Analogue outputs) configured in ALSA
- Application routing (Ardour → PipeWire → ALSA → Hardware) handled by PipeWire

**Ardour Backend Selection:**

In Ardour 8.10+, select "JACK/Pipewire" as your audio backend. This connects Ardour to PipeWire's JACK-compatible API.

**Troubleshooting:**

- **High latency:** Reduce quantum size (e.g., 512 → 256)
- **Xruns/dropouts:** Increase quantum size or set CPU governor to "performance"
- **Connection issues:** Verify PipeWire services are running: `systemctl --user status pipewire pipewire-pulse wireplumber`

### Appendix: Hardware Monitoring vs Software Monitoring

**SG9 Studio uses Software Monitoring in Ardour.**

**Software Monitoring:**
- Ardour controls monitoring content (what you hear)
- Vocaster controls physical loudness only
- Enables plugin processing in monitor path
- Slight latency (typically <10 ms at 128 samples)

**Hardware Monitoring (not used):**
- Interface handles monitoring directly
- Zero-latency monitoring
- Cannot hear plugin processing during recording

For detailed Ardour monitoring configuration, see [Ardour 8 Template Setup Guide](ARDOUR-SETUP.md).

### Appendix: Plugin Technical Reference

**SG9 plugin stack:** LSP + Calf + ZAM + x42

**De-essing methods**

| Method | Status | Notes |
| --- | --- | --- |
| LSP Compressor (SC) | **SG9 Primary** | Professional, precise, transparent |
| Calf Deesser | Legacy/quick | Useful for fast setup |
| LSP Multiband | Advanced | Use for complex multi-band control |

**Installation (NixOS):**

```nix
environment.systemPackages = with pkgs; [
    ardour
    lsp-plugins
    calf
    zam-plugins
    x42-plugins
];
```

### Plugin Versions Tested

**Last Verified:** 2026-01-20

SG9 Studio is designed to be reproducible via Nix: the exact `nixpkgs` revision is pinned in the repository's `flake.lock`.

| Package | Version | Pinned nixpkgs | Notes |
| --- | --- | --- | --- |
| Ardour | 8.12 | e4bae1bd10c9c57b2cf517953ab70060a828ee6f | Clips/cue workflow; scripting enabled |
| LSP Plugins | 1.2.26 | e4bae1bd10c9c57b2cf517953ab70060a828ee6f | Primary dynamics + de-essing tools |
| Calf | 0.90.6 | e4bae1bd10c9c57b2cf517953ab70060a828ee6f | Analyzer + legacy quick tools |
| x42-plugins | 20251025 | e4bae1bd10c9c57b2cf517953ab70060a828ee6f | Metering (True Peak / loudness) |
| ZAM Plugins | 4.4 | e4bae1bd10c9c57b2cf517953ab70060a828ee6f | Optional / specialized dynamics |

**Query versions from the pinned `nixpkgs` revision:**

```bash
REV=e4bae1bd10c9c57b2cf517953ab70060a828ee6f
nix eval --raw github:NixOS/nixpkgs/$REV#legacyPackages.x86_64-linux.lsp-plugins.version
```

### Appendix: Ardour Clips & Cue Workflow

**SG9 Studio integrates Ardour's clips/cue feature for non-linear content triggering.**

**Use Cases:**
- **Jingles:** Intro/outro music, show IDs, sponsored content
- **Music Beds:** Background music for segments
- **SFX:** Transition sounds, button presses, applause
- **Ad Breaks:** Pre-recorded sponsor messages

**Clip Library:** `/Users/alios/src/sg9-studio/clips/`

Subdirectories:
- `Jingles/` - Intro/outro clips (10-30s)
- `Music-Beds/` - Background music (30-180s)
- `SFX/` - Sound effects (<10s)

**File Requirements:**
- **Sample Rate:** 48 kHz (matches session)
- **Loudness:** -16 LUFS ±1 (matches broadcast target)
- **Format:** WAV, FLAC, or MP3
- **Naming:** `YYYY-MM-DD_descriptive-name.wav`

**Ardour Configuration:**

1. `Edit → Preferences → Triggering`
2. **Custom Clips Folder:** `/Users/alios/src/sg9-studio/clips/`
3. Restart Ardour

**Clip Launch Styles:**

| Style | Behavior | Use Case |
|-------|----------|----------|
| **Trigger** | One-shot playback, stop at end | Jingles, SFX |
| **Toggle** | Start/stop on successive presses | Music beds |
| **Repeat** | Loop until stopped | Ambient loops |

**Quantization:** Set to **None** for instant triggering (broadcast workflow).

**Follow Actions:** Configure per-clip:
- Jingles: **Stop** (do nothing after playback)
- Music beds: **Continue** (fade out on stop)
- SFX: **Stop** + **Cue Isolate ON** (don't stop other clips)

**Launchpad MK2 Integration:**

| Row | Cue | Purpose | Pads |
|-----|-----|---------|------|
| 4 | A | Jingles | 51-58 |
| 5 | B | Music Beds | 41-48 |
| 6 | C | SFX | 31-38 |
| 7 | D | Ad Breaks | 21-28 |
| 8 | E | Extras | 11-18 |

**Scene Column (Right):** Pads 89, 79, 69, 59, 49 trigger entire cue rows.

**LED Feedback:**
- **Off:** Empty slot
- **Green (solid):** Clip loaded, ready
- **Green (pulse):** Clip playing
- **Yellow:** Clip queued (quantized)

**Hybrid Workflow (Timeline + Cues):**

Add **Cue Markers** to timeline for automated triggering:

1. Right-click timeline → **Add Cue Marker**
2. Select cue letter (A-E)
3. On playback, clip triggers at marker timecode

**Example Timeline:**
```
00:00:00 - Cue A (Intro jingle)
00:00:30 - Stop All Cues
05:00:00 - Cue C (Segment transition SFX)
15:00:00 - Cue B (Music bed starts)
25:00:00 - Stop All Cues
26:00:00 - Cue A (Outro jingle)
```

**Export Testing:** Always export 2-3 times to verify cue markers trigger (known Ardour 8.12 bug may cause first export to fail).

**Performance:** Clip triggering adds <5% CPU overhead with 40 loaded clips.

**Documentation:**
- [clips/README.md](clips/README.md) - Clip library workflow
- [CLIPS-INTEGRATION-RESEARCH.md](CLIPS-INTEGRATION-RESEARCH.md) - Community best practices
- [TESTING-CUE-INTEGRATION.md](TESTING-CUE-INTEGRATION.md) - Testing protocol
- [CUE-INTEGRATION-STATUS.md](CUE-INTEGRATION-STATUS.md) - Implementation status

### Changelog

- **v2.0 (2026-01-19):** Consolidated documentation, standardized on software monitoring model,
  removed TAP plugins, updated de-essing hierarchy and canonical chain order. Extracted Ardour-specific
  configuration to dedicated [ARDOUR-SETUP.md](ARDOUR-SETUP.md) document.
- **v2.1 (2026-01-19):** Added Clips & Cue Workflow appendix, integrated Launchpad MK2 cue triggering,
  documented hybrid timeline/non-linear workflow.
