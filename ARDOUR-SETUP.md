# SG9 Studio — Ardour 8 Template Setup Guide

**Document Version:** 1.0 | **Last Updated:** 2026-01-19

This guide provides comprehensive step-by-step instructions for configuring Ardour 8 as the digital audio workstation for SG9 Studio broadcast workflows. It integrates modern Ardour 8 features including track groups, VCAs, labels, color schemas, and advanced routing to create a professional podcast/broadcast production environment.

## Prerequisites

Before starting this guide, ensure:

- Vocaster Two is connected and ALSA routing is configured (see [STUDIO.md](STUDIO.md#alsa-routing-vocaster--alsa-scarlett-gui))
- Required plugins are installed: LSP, Calf, ZAM, x42
- You have basic familiarity with Ardour's interface

## Session Creation & Audio Setup

### Step 1: Create New Session

1. Launch Ardour 8
2. Click **Session → New** (or `Ctrl+N`)
3. Configure session parameters:
   - **Session name:** `SG9-Studio-Template`
   - **Sample rate:** 48000 Hz
   - **Audio system:** JACK (via PipeWire)
     - *Note: In Ardour 8.10+, select "JACK/Pipewire" from the backend dropdown*
   - **Device:** Vocaster Two
   - **Input channels:** 16 (or maximum available)
   - **Output channels:** 16 (or maximum available)
   - **Buffer size:** 128–256 samples
     - *Note: Start with 128. Increase to 256 or 512 if you experience xruns/dropouts*
     - *PipeWire quantum: This corresponds to PipeWire's quantum setting (see [PipeWire Configuration](#pipewire-configuration))*

### Step 2: Configure Global Monitoring

1. Open **Edit → Preferences** (`Alt+P`)
2. Navigate to **Audio** tab
3. Set **Monitoring Model:** Software Monitoring
   - This ensures Ardour controls monitoring content while Vocaster handles physical volume
4. Navigate to **Editor** tab
5. Enable **Auto Input**
   - Stopped + armed: input monitoring
   - Rolling + not recording: disk monitoring
   - Rolling + recording: input monitoring

### Step 3: Configure I/O Naming (Optional but Recommended)

1. Open **Window → Audio Connections**
2. Click **Hardware** tab
3. Rename inputs for clarity:
   - Capture 1 → "Host Mic"
   - Capture 2 → "Guest Mic"
   - Capture 3–4 → "Aux L/R"
   - Capture 5–6 → "Bluetooth L/R"
   - Capture 11–12 → "Music Loopback L/R"
   - Capture 13–14 → "Remote Guest L/R"

### PipeWire Configuration

**Audio Backend Architecture:**

SG9 Studio uses **PipeWire** as the audio server with **JACK compatibility** for Ardour. This provides:

- Low-latency professional audio (comparable to native JACK)
- Unified audio server for desktop and pro applications
- Modern session management via WirePlumber
- Better device hotplug and Bluetooth support

**Configuration File Location:**

Create or edit `~/.config/pipewire/pipewire.conf.d/custom.conf`:

```conf
# PipeWire configuration for SG9 Studio broadcast workflow
context.properties = {
    default.clock.rate = 48000           # 48 kHz sample rate
    default.clock.quantum = 1024         # Default buffer size
    default.clock.min-quantum = 32       # Minimum allowed
    default.clock.max-quantum = 8192     # Maximum allowed
    
    # Optional: Allow dynamic sample rate switching (not enabled by default)
    # default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
}
```

**Buffer Size / Quantum Relationship:**

- **Quantum** = PipeWire's buffer size (in samples)
- **Latency** = quantum / sample_rate (in seconds)
- Examples at 48 kHz:
  - 128 samples = ~2.7 ms latency (ultra-low, may cause xruns)
  - 256 samples = ~5.3 ms latency (recommended for broadcast)
  - 512 samples = ~10.7 ms latency (safe for most systems)
  - 1024 samples = ~21.3 ms latency (default, very stable)

**Tuning Recommendations:**

1. **Start with default (1024 samples)** — ensures stability
2. **Reduce gradually** if you need lower latency (e.g., 512 → 256)
3. **Monitor for xruns** using `pw-top` in a terminal
4. **Set CPU governor** to "performance" mode for low-latency:
   ```bash
   # Check current governor
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   
   # Set to performance (temporary, lost on reboot)
   echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

**Verify PipeWire Services:**

```bash
# Check PipeWire services are running
systemctl --user status pipewire pipewire-pulse wireplumber

# Monitor real-time performance
pw-top
```

**Ardour Backend Selection:**

- In Ardour 8.10+, the JACK backend is labeled **"JACK/Pipewire"**
- Ardour connects to PipeWire's JACK-compatible API
- No additional configuration needed in Ardour once PipeWire is running

**ALSA Routing Coexistence:**

- ALSA (via `alsa-scarlett-gui`) still handles Vocaster hardware routing (PCM inputs/outputs)
- PipeWire sits **above** ALSA, providing the JACK API to Ardour
- Audio flow: `Ardour → JACK API → PipeWire → ALSA driver → Vocaster hardware`

For more details on the audio stack architecture, see [STUDIO.md Appendix: Audio Backend Architecture](STUDIO.md#appendix-audio-backend-architecture-pipewirejack).

## Track Structure & Organization

### Step 4: Create Track Hierarchy

**Color Schema:** All track colors follow the [SG9 Color Schema Standard](docs/COLOR-SCHEMA-STANDARD.md) for consistency across Ardour, Launchpad LEDs, and visual feedback.

- **Red:** Voice tracks (Host Mic)
- **Blue:** Guest/auxiliary inputs (Guest Mic, Remote Guest, Aux, Bluetooth)
- **Cyan:** Technical/loopback (Music Loopback)
- **Green:** Music content (Music 1/2, Jingles)
- **Yellow:** SFX tracks

Ardour 8 supports track folders for logical organization. We'll create:

```
📁 INPUTS (folder)
  ├─ Host Mic (DSP)
  ├─ Host Mic (Raw)
  ├─ Guest Mic
  ├─ Aux Input
  ├─ Bluetooth
  ├─ Remote Guest
  └─ Music Loopback
📁 CONTENT (folder)
  ├─ Music 1
  ├─ Music 2
  ├─ Jingles
  └─ SFX
```

#### Create Input Tracks

1. **Host Mic (DSP) — Track 1**
   - `Ctrl+Shift+N` → Add Track/Bus
   - Type: Audio Track
   - Channels: Mono
   - Track mode: Normal
   - Name: "Host Mic (DSP)"
   - Input: Capture 1 (Host Mic)
   - I/O Policy: **Strict I/O** (mono stays mono)
   - Color: Red (#E74C3C)

2. **Host Mic (Raw) — Track 2**
   - Type: Audio Track (Mono)
   - Name: "Host Mic (Raw)"
   - Input: Capture 1 (Host Mic) — *same as Track 1*
   - I/O Policy: **Strict I/O**
   - Color: Dark Red (#A93226)
   - *Purpose: Raw safety recording without processing*

3. **Guest Mic — Track 3**
   - Type: Audio Track (Mono)
   - Name: "Guest Mic"
   - Input: Capture 2
   - I/O Policy: **Strict I/O**
   - Color: Blue (#3498DB)

4. **Aux Input — Track 4**
   - Type: Audio Track (Stereo)
   - Name: "Aux Input"
   - Input: Capture 3–4
   - I/O Policy: Flexible I/O
   - Color: Blue (#3498DB)

5. **Bluetooth — Track 5**
   - Type: Audio Track (Stereo)
   - Name: "Bluetooth"
   - Input: Capture 5–6
   - I/O Policy: Flexible I/O
   - Color: Cyan (#1ABC9C)

6. **Remote Guest — Track 6**
   - Type: Audio Track (Stereo)
   - Name: "Remote Guest"
   - Input: Capture 13–14
   - I/O Policy: Flexible I/O
   - Color: Blue (#3498DB)

7. **Music Loopback — Track 7**
   - Type: Audio Track (Stereo)
   - Name: "Music Loopback"
   - Input: Capture 11–12
   - I/O Policy: Flexible I/O
   - Color: Cyan (#1ABC9C)
   - Monitor mode: **Disk** (not Auto)

#### Create Content Tracks

8. **Music 1, Music 2 — Tracks 8–9**
   - Type: Audio Track (Stereo, ×2)
   - Names: "Music 1", "Music 2"
   - Input: None (file playback)
   - Color: Green (#27AE60)

9. **Jingles — Track 10**
   - Type: Audio Track (Stereo)
   - Name: "Jingles"
   - Color: Light Green (#58D68D)

10. **SFX — Track 11**
    - Type: Audio Track (Stereo)
    - Name: "SFX"
    - Color: Yellow (#F1C40F)

#### Create Backup Recording Tracks

These tracks record continuously for safety/redundancy purposes.

11. **Master Bus Record — Track 12**
    - Type: Audio Track (Stereo)
    - Name: "Master Bus Record"
    - Input: Master Bus (post-fader send)
    - Color: Gray (#95A5A6)
    - **Always armed:** ✅
    - **Purpose:** Record final mix as safety backup (instant export, no bouncing needed)
    - **Setup:** Create post-fader send from Master bus to this track's input

12. **Mix-Minus Record — Track 13**
    - Type: Audio Track (Stereo)
    - Name: "Mix-Minus Record"
    - Input: Mix-Minus bus (post-fader send)
    - Color: Purple (#9B59B6)
    - **Always armed:** ✅
    - **Purpose:** Record what remote guest heard (for troubleshooting echo/routing issues)
    - **Setup:** Create post-fader send from Mix-Minus bus (see [Mix-Minus Setup](#step-17-mix-minus-remote-guest-routing))

**Benefit of Backup Recording Tracks:**
- **Master Bus Record:** No post-show bounce needed, instant 2-track export for distribution
- **Mix-Minus Record:** Diagnose remote guest issues (echo, levels, routing errors)
- **Disk overhead:** ~16.5 MB/min for both tracks (48kHz/24-bit stereo × 2)

### Step 5: Create Track Folders

1. Select Tracks 1–7 (Host Mic through Music Loopback)
2. Right-click → **Group → New Group** → Name: "INPUTS"
3. Right-click on "INPUTS" group → **Convert to Folder**
4. Select Tracks 8–11 (Music through SFX)
5. Right-click → **Group → New Group** → Name: "CONTENT"
6. Right-click on "CONTENT" group → **Convert to Folder**
7. Select Tracks 12–13 (Master Bus Record, Mix-Minus Record)
8. Right-click → **Group → New Group** → Name: "BACKUP RECORDINGS"
9. Right-click on "BACKUP RECORDINGS" group → **Convert to Folder**

**Track Organization Summary:**
- **INPUTS folder:** All hardware inputs (mics, aux, remote, loopback)
- **CONTENT folder:** All file-based playback (music, jingles, SFX)
- **BACKUP RECORDINGS folder:** Safety recording tracks (always armed)

### Step 6: Create Bus Structure

#### Voice Bus

1. `Ctrl+Shift+N` → Add Bus
   - Type: Audio Bus
   - Channels: Stereo
   - Name: "Voice Bus"
   - Color: Pink (#EC7063)

2. Route voice tracks to Voice Bus:
   - Host Mic (DSP) → Voice Bus
   - Guest Mic → Voice Bus
   - Remote Guest → Voice Bus
   - Aux Input → Voice Bus

#### Music Bus

1. Add Bus (Stereo)
   - Name: "Music Bus"
   - Color: Dark Green (#1E8449)

2. Route music tracks to Music Bus:
   - Music 1 → Music Bus
   - Music 2 → Music Bus
   - Jingles → Music Bus
   - SFX → Music Bus
   - Music Loopback → Music Bus

### Step 7: Create VCAs (Volume Control Automation)

VCAs allow unified control of multiple tracks/busses without audio routing.

1. **Voice VCA**
   - `Ctrl+Shift+N` → Add VCA
   - Name: "Voice Master"
   - Color: Red (#C0392B)
   - Assign: Voice Bus

2. **Music VCA**
   - Add VCA
   - Name: "Music Master"
   - Color: Green (#229954)
   - Assign: Music Bus

3. **Master VCA**
   - Add VCA
   - Name: "Master Control"
   - Color: Gray (#566573)
   - Assign: Voice Bus, Music Bus, Master Out

**VCA Workflow Benefit:** Adjust Voice Master VCA to control all voice levels simultaneously without affecting individual processing.

## Plugin Configuration

### Step 8: Host Mic (DSP) Processing Chain

**Canonical Order:** HPF → Gate → De-esser → EQ → Compressor → Limiter

1. Select "Host Mic (DSP)" track
2. Open Mixer window (`Alt+M`)
3. Click **Processor Box** (plugin insert area)

#### Insert 1: HPF (High-Pass Filter)

1. Add **LSP Parametric Equalizer x8 Mono**
2. Configure Filter 1:
   - Mode: High-pass (HPF)
   - Frequency: 90 Hz
   - Slope: 18 dB/oct
   - Q: 0.707 (Butterworth)
3. Bypass filters 2–8

#### Insert 2: Gate

1. Add **LSP Gate Mono**
2. Configure:
   - **Threshold:** -38 dB (adjust per voice)
   - **Reduction:** -40 dB
   - **Attack:** 5 ms
   - **Release:** 100 ms
   - **Hold:** 50 ms
   - **Hysteresis:** Enable
   - **Hysteresis Threshold:** -45 dB (6–10 dB below main threshold)
   - **Hysteresis Zone:** 6 dB

**Hysteresis Tip:** Prevents gate chatter on quiet words. Adjust the zone if you hear unnatural cutting.

#### Insert 3: De-esser (Sidechain Compression)

1. Add **LSP Compressor Mono**
2. Enable **Sidechain** section
3. Configure Sidechain:
   - **SC Mode:** Internal
   - **SC HPF:** Enable
   - **SC HPF Frequency:** 6 kHz
   - **SC HPF Slope:** 12 dB/oct
4. Configure Compression:
   - **Threshold:** -18 dB
   - **Ratio:** 4:1
   - **Attack:** 1 ms
   - **Release:** 50 ms
   - **Knee:** 6 dB
5. Monitor reduction meter: target 3–6 dB on sibilants

#### Insert 4: EQ (Presence Boost)

1. Add **LSP Parametric Equalizer x8 Mono**
2. Configure Filter 1 (Presence):
   - Mode: Bell
   - Frequency: 4 kHz
   - Gain: +4 dB
   - Q: 2.0
3. Optional Filter 2 (De-mud):
   - Mode: Bell
   - Frequency: 250 Hz
   - Gain: -2 dB
   - Q: 1.0

#### Insert 5: Compressor

1. Add **LSP Compressor Mono**
2. Configure:
   - **Threshold:** -18 dB
   - **Ratio:** 3.5:1
   - **Attack:** 15 ms
   - **Release:** 150 ms (auto-release if available)
   - **Knee:** 6 dB
   - **Makeup gain:** Auto or manual to target -12 dBFS average

#### Insert 6: Limiter

1. Add **LSP Limiter Mono**
2. Configure:
   - **Ceiling:** -1.0 dBTP
   - **Threshold:** -3 dB
   - **Lookahead:** 5 ms
   - **Oversampling:** 4x (or 8x if CPU allows)
   - **Release:** 100 ms

### Step 9: Host Mic (Raw) — No Processing

Leave this track **empty** (no plugins). This is your safety recording.

### Step 10: Guest Mic Processing Chain

Use the same chain as Host Mic (DSP) with adjusted parameters:

- HPF: 150 Hz
- Gate: Threshold -35 dB, Reduction -40 dB
- De-esser: SC HPF 6–8 kHz
- EQ: +3 dB at 2.5 kHz
- Compressor: Ratio 4:1
- Limiter: Same as host

**Time-Saving Tip:** Copy the entire plugin chain from Host Mic (DSP):
1. Right-click Host Mic (DSP) processor box → **Copy Processor Configuration**
2. Right-click Guest Mic processor box → **Paste**
3. Adjust parameters as listed above

### Step 11: Remote Guest Processing Chain

Remote guests often have unpredictable audio quality. Use heavier processing:

- HPF: 180 Hz
- Gate: Threshold -32 dB, Reduction -35 dB
- De-esser: SC HPF 7 kHz, Ratio 6:1
- EQ: +4 dB at 2.5 kHz, -3 dB at 200 Hz (combat phone muddiness)
- Compressor: Ratio 6:1
- Limiter: Same settings

### Step 12: Aux Input Processing

Phone/tablet audio benefits from aggressive processing:

1. **LSP EQ x8 Stereo**: HPF 120 Hz
2. **LSP Gate Stereo**: Threshold -35 dB
3. **LSP EQ x8 Stereo**: +3 dB at 2.5 kHz
4. **LSP Compressor Stereo**: Ratio 6:1
5. **LSP Limiter Stereo**: Ceiling -1.0 dBTP

### Step 13: Music Bus — Ducking (Sidechain Compression)

Music should automatically reduce when voices are present.

1. Select **Music Bus**
2. Add **Calf Sidechain Compressor Stereo**
3. Configure:
   - **Sidechain Input:** Voice Bus (send from Voice Bus)
   - **Threshold:** -25 dB
   - **Ratio:** 4:1
   - **Attack:** 15 ms
   - **Release:** 400 ms
   - **Knee:** 6 dB
   - **Makeup:** 0 dB

4. Create sidechain send:
   - Open Voice Bus mixer strip
   - Click **Sends** (post-fader)
   - Add send → Music Bus (Sidechain)
   - Set send level to 0 dB

### Step 14: Master Bus Processing

Light glue compression and final limiting:

1. Select **Master** bus
2. Add **LSP Compressor Stereo**:
   - Threshold: -6 dB
   - Ratio: 2:1
   - Attack: 30 ms
   - Release: 300 ms (auto)
   - Knee: 6 dB
   - Makeup: Auto

3. Add **LSP Limiter Stereo**:
   - Ceiling: -1.0 dBTP
   - Threshold: -2 dB
   - Oversampling: 4x

4. Add metering:
   - **x42-meter EBU R128** (Loudness)
   - **x42-meter True Peak**

## Advanced Ardour 8 Features

### Step 15: Session Snapshots & Arrangements

Ardour 8 introduces powerful session management tools.

#### Snapshots

Snapshots preserve session states without duplicating audio files:

1. **Create Initial Snapshot**
   - `Session → Snapshot (keep working on current version)`
   - Name: `SG9-Template-v1.0`
   - Description: Initial template state

2. **Per-Episode Snapshots**
   - Before each recording: `Session → Snapshot`
   - Naming: `YYYY-MM-DD-Episode-Name`
   - Example: `2026-01-19-Interview-John-Smith`

3. **Recovery Snapshots**
   - Before major edits: Create snapshot
   - Allows non-destructive experimentation
   - Revert by loading older snapshot

**Best Practice:** Create snapshots at key milestones (pre-recording, post-recording, pre-export).

#### Arrangement Sections (Ardour 8.7+)

Arrangement markers define broadcast segments:

1. **Create Arrangement Workflow**
   - Enable **Ranges** ruler (`View → Rulers → Ranges`)
   - Right-click ruler → **New Range**
   - Name sections: INTRO, SEGMENT-1, AD-BREAK, SEGMENT-2, OUTRO

2. **Section Benefits**
   - Visual navigation
   - Non-linear editing (move sections)
   - Export by section

3. **Section Navigation**
   - `Ctrl+Right Arrow`: Next section
   - `Ctrl+Left Arrow`: Previous section
   - Double-click section: Select all regions in section

**Broadcast Use Case:** Pre-define sections for consistent show structure.

### Step 16: Track Groups

Track groups synchronize operations across multiple tracks.

#### Create Voice Group

1. Select tracks: Host Mic (DSP), Guest Mic, Remote Guest
2. Right-click → **Group → New Group**
3. Name: `Voice Tracks`
4. Enable properties:
   - ☑ Gain
   - ☑ Mute
   - ☑ Solo
   - ☑ Record Enable
   - ☑ Selection
   - ☑ Editing
   - ☐ Active (leave unchecked — allows individual track deactivation)
5. Assign color: Red (#E74C3C)

#### Create Music Group

1. Select: Music 1, Music 2, Jingles, SFX
2. Create group: `Music Tracks`
3. Enable: Gain, Mute, Solo, Selection
4. Color: Green (#27AE60)

#### Group Benefits

- **Unified control:** Mute/solo all voice tracks simultaneously
- **Synchronized editing:** Move/trim regions across grouped tracks
- **Level matching:** Adjust relative balance, then control overall level via group

#### Group Operations

- **Temporarily disable group:** Right-click track → **Remove from Group**
- **Edit group properties:** Right-click group tab → **Edit Group**
- **Sub-groups:** Groups can contain other groups (nested hierarchy)

### Step 17: VCAs (Volume Control Automation)

VCAs provide master control without audio routing.

#### What are VCAs?

- Control faders without passing audio
- Independent from bus routing
- Automation-friendly
- Industry-standard mixing technique

#### Create VCA Structure

1. **Voice Master VCA**
   - `Ctrl+Shift+N` → Add VCA
   - Name: `Voice Master`
   - Color: Red (#C0392B)
   - Assign: Voice Bus

2. **Music Master VCA**
   - Add VCA
   - Name: `Music Master`
   - Color: Green (#229954)
   - Assign: Music Bus

3. **Master Control VCA**
   - Add VCA
   - Name: `Master Control`
   - Color: Gray (#566573)
   - Assign: Voice Bus, Music Bus, Master Out

#### Assign Tracks to VCAs

1. Open mixer window (`Alt+M`)
2. Find "VCA" dropdown on each track/bus
3. Host Mic (DSP) → Assign to Voice Master VCA
4. Music Bus → Assign to Music Master VCA
5. Voice Bus + Music Bus → Assign to Master Control VCA

#### VCA Workflow Benefits

- **Real-time mixing:** Adjust Voice Master to control all voice levels during recording
- **Nested control:** Music Master → Master Control provides two-stage control
- **Automation:** Automate VCA faders for broadcast-style mixing (voice up during talk, music down)
- **No DSP cost:** VCAs consume no CPU (control-only)

**Example Workflow:** During intro music, Music Master at 0 dB. When host speaks, automate Music Master to -12 dB (ducking).

### Step 18: Track Folders & Organization

Ardour 8 supports track folders for visual organization.

#### Create Folder Structure

1. **Inputs Folder**
   - Select Tracks 1–7 (Host Mic through Music Loopback)
   - Right-click → **Group → New Group**
   - Name: `INPUTS`
   - Right-click group → **Convert to Folder**
   - Color: Blue (#3498DB)

2. **Content Folder**
   - Select Tracks 8–11 (Music, Jingles, SFX)
   - Create group → `CONTENT`
   - Convert to folder
   - Color: Green (#27AE60)

3. **Busses Folder (Optional)**
   - Select: Voice Bus, Music Bus
   - Create group → `BUSSES`
   - Convert to folder
   - Color: Orange (#E67E22)

#### Folder Benefits

- **Visual clarity:** Collapse folders to reduce clutter
- **Batch operations:** Show/hide entire folders
- **Consistent layout:** Every session has same structure

#### Folder Operations

- **Expand/collapse:** Click triangle icon next to folder name
- **Move tracks into folder:** Drag track onto folder name
- **Remove from folder:** Drag track out of folder
- **Nested folders:** Folders can contain other folders

**Best Practice:** Use folders + groups + VCAs together for maximum organizational clarity.

### Step 19: Labels & Markers

Ardour 8 simplified marker/ruler system (v8.7+).

#### Marker Types

| Type | Ruler | Purpose |
|------|-------|---------|
| **Location** | Locations | Single point in time (intro start, topic change) |
| **Range** | Ranges | Start/end pair (ad break, interview segment) |
| **Arrangement** | Arrangement | Broadcast sections (movable, non-linear editing) |

#### Create Broadcast Label Set

1. **Enable Rulers**
   - `View → Rulers → Locations` (☑)
   - `View → Rulers → Ranges` (☑)
   - `View → Rulers → Arrangement` (☑)

2. **Add Location Markers**
   - Position playhead at 0:00
   - Press `Tab` or right-click Locations ruler → **New Location Marker**
   - Name: `SHOW-START`
   - Color: Green

3. **Standard Markers**
   - 0:00 — SHOW-START (Green)
   - 0:15 — INTRO-END (Blue)
   - 0:30 — TOPIC-1 (Yellow)
   - 5:00 — AD-BREAK-IN (Red)
   - 5:30 — AD-BREAK-OUT (Red)
   - 6:00 — TOPIC-2 (Yellow)
   - 15:00 — OUTRO-START (Purple)
   - 16:00 — SHOW-END (Green)

4. **Create Range Markers**
   - Click-drag on Ranges ruler to define range
   - Right-click → **Name Range**
   - Example: 5:00–5:30 → "Advertisement"

5. **Create Arrangement Sections**
   - Right-click Arrangement ruler → **New Range**
   - Sections auto-named "section 1", "section 2"
   - Rename: INTRO, SEGMENT-1, AD, SEGMENT-2, OUTRO

#### Marker Navigation

- `Tab` or `Ctrl+Right Arrow`: Next marker
- `Shift+Tab` or `Ctrl+Left Arrow`: Previous marker
- `Ctrl+1` through `Ctrl+9`: Jump to marker 1–9 (configure in Preferences)

#### Marker Benefits

- **Fast navigation:** Jump between segments instantly
- **Visual reference:** See show structure at a glance
- **Export markers:** Use for chapter markers in podcasts

**Broadcast Workflow:** Create marker template and reuse across episodes.

### Step 20: Color Schema & Visual Design

### Step 20: Color Schema & Visual Design

Consistent colors improve workflow efficiency and reduce cognitive load.

#### SG9 Studio Color Schema

| Track/Bus Type | Color | Hex Code | Visual Rationale |
|----------------|-------|----------|------------------|
| Host Mic (DSP) | Red | #E74C3C | Primary attention |
| Host Mic (Raw) | Dark Red | #A93226 | Safety/backup indication |
| Guest Mic | Orange | #E67E22 | Secondary voice |
| Aux Input | Yellow | #F39C12 | External/phone input |
| Bluetooth | Blue | #3498DB | Wireless connection |
| Remote Guest | Purple | #9B59B6 | Internet/remote source |
| Music Loopback | Cyan | #1ABC9C | System audio |
| Music Tracks | Green | #27AE60 | Content/music |
| Jingles | Light Green | #58D68D | Short-form content |
| SFX | Lime | #A9DFBF | Effects/accents |
| Voice Bus | Pink | #EC7063 | Voice submix |
| Music Bus | Dark Green | #1E8449 | Music submix |
| Master | Black | #1C2833 | Final output |

#### Apply Colors

**Method 1: Per-Track Properties**
1. Right-click track name → **Properties**
2. Click color swatch (top of dialog)
3. Enter hex code: `#E74C3C`
4. Click **OK**

**Method 2: Bulk Color Assignment**
1. Select multiple tracks (Shift+click)
2. Right-click → **Properties**
3. Set color → applies to all selected

**Method 3: Track Templates**
- Save template with colors pre-defined
- New sessions inherit color scheme

#### Color Theme Consistency

Ardour 8.10+ includes multiple UI themes. SG9 Studio recommendation:

1. **Edit → Preferences → Theme**
2. Select theme: **Dark** (default) or **Captain Light** (light mode)
3. Enable **Boxy Buttons** for cleaner interface (optional)

**Do not customize track colors beyond the schema** — consistency aids muscle memory.

#### Waveform Display Colors

1. **Edit → Preferences → Editor**
2. **Waveform Coloring:** Gradient (shows loudness)
3. **Waveform Clipping:** Highlight peaks above -1.0 dBFS in red

### Step 21: MIDI Controller Mapping

Integrate hardware controllers for tactile mixing.

#### Korg nanoKONTROL Studio Setup

1. **Connect Hardware**
   - Connect nanoKONTROL via USB
   - Power on (should auto-detect)

2. **Enable MIDI Control Surface**
   - `Edit → Preferences → Control Surfaces`
   - Click **Add**
   - Select **Generic MIDI**
   - Name: `nanoKONTROL SG9`

3. **Create MIDI Binding Map**
   - `Session → MIDI Bindings → New Binding`
   - File location: `~/.config/ardour8/midi_maps/nanoKONTROL-SG9.map`

4. **Map Controls**

   **Faders:**
   - Fader 1 → Voice Master VCA Gain
   - Fader 2 → Music Master VCA Gain
   - Fader 3 → Host Mic (DSP) Gain
   - Fader 4 → Guest Mic Gain
   - Fader 5 → Remote Guest Gain
   - Fader 6 → Music Bus Gain
   - Fader 7 → Aux Input Gain
   - Fader 8 → SFX Gain
   - Fader 9 → Master Control VCA Gain

   **S Buttons (Solo):**
   - S1 → Voice Bus Solo
   - S2 → Music Bus Solo

   **M Buttons (Mute):**
   - M1 → Voice Bus Mute
   - M2 → Music Bus Mute

   **R Buttons (Record):**
   - R1 → Host Mic (DSP) Rec Enable
   - R2 → Host Mic (Raw) Rec Enable
   - R3 → Guest Mic Rec Enable
   - R4 → Remote Guest Rec Enable

5. **Save Binding**
   - `Session → MIDI Bindings → Save`

6. **Enable Binding**
   - `Edit → Preferences → Control Surfaces → Generic MIDI`
   - **Incoming MIDI:** nanoKONTROL
   - **Outgoing MIDI:** nanoKONTROL (for LED feedback)
   - **Binding Map:** nanoKONTROL-SG9.map

#### Novation Launchpad Pro Mk2 Setup

The Launchpad provides clip triggering and scene launching.

1. **Configure Launchpad Mode**
   - Press **Setup** button on Launchpad
   - Select **Programmer Mode** (Port 3)
   - Launchpad displays grid in rainbow colors

2. **Enable in Ardour**
   - `Edit → Preferences → Control Surfaces`
   - Add **Generic MIDI**
   - Name: `Launchpad Pro Mk2`
   - Device: Launchpad Pro Mk2 (Programmer)

3. **MIDI Learn Mode**
   - Ardour: `Ctrl+Middle-Click` on any control → MIDI Learn
   - Press pad on Launchpad → Assignment created
   - Repeat for multiple controls

4. **Suggested Mappings**

   **Row 8 (Top):**
   - Pad 1 → Transport Play/Stop
   - Pad 2 → Transport Record
   - Pad 3 → Loop Enable
   - Pad 4 → Click Enable
   - Pad 5 → Host Mic Solo
   - Pad 6 → Music Bus Solo
   - Pad 7 → Snapshot (create)
   - Pad 8 → Save Session

   **Grid (Clip Triggers):**
   - Map pads to region/clip triggers
   - Useful for jingles, SFX, music beds

5. **LED Feedback (Advanced)**
   - Requires SysEx programming
   - See Novation Programmer Mode documentation
   - Example: Light pad green when armed, red when recording

**Note:** Launchpad integration is most powerful with Ardour's **Cue** page (live performance mode), but also useful for quick triggering in Editor mode.

#### MIDI Controller Benefits

- **Tactile control:** Faster than mouse for live mixing
- **Two-handed workflow:** Faders + mouse simultaneously
- **Muscle memory:** Physical positions become intuitive
- **Performance mixing:** Real-time level rides during recording

**Best Practice:** Map most-used controls to easiest-to-reach faders/buttons.

### Step 22: Mixer Window Layout

Optimize mixer view for broadcast workflow.

#### Mixer Strip Configuration

1. **Open Mixer:** `Alt+M`

2. **Show Essential Strips Only**
   - Right-click mixer background → **Show/Hide Strips**
   - Deselect all individual tracks
   - Select only:
     - ☑ Voice Bus
     - ☑ Music Bus
     - ☑ Master
     - ☑ Voice Master VCA
     - ☑ Music Master VCA
     - ☑ Master Control VCA

3. **Strip Width**
   - Right-click mixer strip → **Strip Width**
   - Options: Narrow, Normal, Wide
   - SG9 recommendation: **Normal** for VCAs/busses, **Narrow** for tracks

4. **Meter Position**
   - `Edit → Preferences → Metering`
   - Meter position: **Post-fader** (see output level)
   - Meter type: **Peak + RMS**

5. **Group Tabs**
   - `View → Show Group Tabs` (☑)
   - Displays Voice Tracks and Music Tracks groups on left edge
   - Click group tab to select all group members

#### Mixer View Modes

Ardour offers multiple mixer views:

1. **Editor Mixer (Inline)**
   - `Shift+E` → Toggle editor mixer strip
   - Shows mixer for currently selected track
   - Saves screen space

2. **Detached Mixer (Separate Window)**
   - `Alt+M` → Open mixer window
   - Drag to second monitor
   - Full mixer view while editing in editor window

3. **Mixer in Editor (Tabbed)**
   - `View → Editor Mixer → On`
   - Mixer appears in editor window's sidebar
   - Click track → mixer strip updates

**SG9 Workflow Recommendation:**
- **Single monitor:** Use Editor Mixer (inline) for selected track
- **Dual monitor:** Detached mixer on second screen

### Step 23: Advanced Routing — Mix-Minus for Remote Guests

Remote guests must not hear themselves to avoid echo/feedback.

#### Problem

Standard routing sends Master output to all destinations, including Remote Guest. If Remote Guest's audio is in the mix, they hear themselves with latency = echo.

#### Solution: Mix-Minus Bus

Create a separate mix for Remote Guest that excludes their own audio.

1. **Create Mix-Minus Bus**
   - `Ctrl+Shift+N` → Add Bus (Stereo)
   - Name: `Mix-Minus (Remote Guest)`
   - Color: Purple (#9B59B6)

2. **Route to Mix-Minus**
   - Host Mic (DSP) → Add send (post-fader) → Mix-Minus
   - Guest Mic → Add send (post-fader) → Mix-Minus
   - Music Bus → Add send (post-fader) → Mix-Minus
   - Aux Input → Add send (post-fader) → Mix-Minus
   - **DO NOT send Remote Guest to Mix-Minus**

3. **Send Mix-Minus to VoIP Software**
   - Open **Window → Audio Connections → Outputs**
   - Mix-Minus L → Hardware Out (Playback) → VoIP app input L
   - Mix-Minus R → Hardware Out (Playback) → VoIP app input R

4. **Configure VoIP Software**
   - Zoom/Skype/etc. audio settings
   - **Microphone:** Ardour Mix-Minus L/R
   - **Speakers:** Ardour Remote Guest Capture 13-14

5. **Test**
   - Remote guest speaks → You hear them in Master mix
   - You speak → Remote guest hears you in Mix-Minus
   - Remote guest does NOT hear themselves = no echo

#### Alternative: Loopback Routing

If VoIP software doesn't support arbitrary inputs, use system loopback:

- Linux: `snd-aloop` kernel module
- macOS: BlackHole or Loopback app
- Windows: VB-Audio Virtual Cable

### Step 24: Session Templates

Save all configuration as a reusable template.

1. **Final Checks Before Saving**
   - ☑ All tracks created and colored
   - ☑ All busses and VCAs configured
   - ☑ Plugin chains inserted and saved
   - ☑ MIDI controllers mapped
   - ☑ Monitoring model set to Software Monitoring
   - ☑ Markers/labels created
   - ☑ Groups and folders organized

2. **Save as Template**
   - `Session → Save Template`
   - **Template name:** `SG9 Studio Broadcast Template v1.0`
   - **Description:**
     ```
     Complete SG9 Studio broadcast setup:
     - Voice + Music tracks with processing chains
     - VCAs for Voice, Music, Master control
     - Mix-minus bus for remote guests
     - MIDI controller mappings (nanoKONTROL + Launchpad)
     - Broadcast markers and sections
     - Optimized for podcast/interview recording
     Version: 1.0 | Date: 2026-01-19
     ```
   - Click **Save**

3. **Template Location**
   - Saved to: `~/.config/ardour8/templates/`
   - Filename: `SG9 Studio Broadcast Template v1.0.template`

4. **Use Template for New Sessions**
   - `Session → New`
   - **From Template:** Select `SG9 Studio Broadcast Template v1.0`
   - Session name: Episode name (e.g., `2026-01-19-Interview-Jane-Doe`)
   - Click **Open**

5. **Template Versioning**
   - Update template when improving workflow
   - Save as: `SG9 Studio Broadcast Template v1.1`
   - Keep previous versions for rollback

**Pro Tip:** Export template file and version control it (Git) for team collaboration and backup.

### Step 25: Monitoring & Metering Windows

Configure comprehensive monitoring for broadcast-quality output.

#### Loudness Metering (EBU R128)

1. **Open Loudness Analyzer**
   - `Window → Loudness Analyzer`
   - Dock on right side of editor window

2. **Configure Settings**
   - Click **Settings** (gear icon)
   - **Standard:** EBU R128 (European)/ATSC A/85 (US)
   - **Target:** -16 LUFS (podcast standard)
   - **Max LRA:** 10 LU
   - **Max TP:** -1.0 dBTP

3. **Reading the Display**
   - **M (Momentary):** 400ms average (real-time fluctuation)
   - **S (Short-term):** 3s average (current loudness)
   - **I (Integrated):** Full program loudness (target -16 LUFS)
   - **LRA:** Loudness Range (dynamic range)
   - **TP (True Peak):** Absolute peak level (must be ≤ -1.0 dBTP)

4. **Usage Workflow**
   - **During recording:** Monitor M and S for real-time levels
   - **After recording:** Check I (Integrated) is -16 ±2 LUFS
   - **Before export:** Reset analyzer, play full session, verify targets

#### True Peak Metering

1. **Add x42 True Peak Meter**
   - Select **Master** bus
   - Add plugin: **x42-meter > True Peak Meter**
   - Position: Post-limiter (last plugin in chain)

2. **Configure**
   - **Max TP threshold:** -1.0 dBTP
   - **Hold time:** 3 seconds
   - **Oversampling:** 4x

3. **Monitor**
   - Green: Safe (<-6 dBTP)
   - Yellow: Caution (-6 to -1 dBTP)
   - Red: Over (-1.0+ dBTP) = Fix immediately

#### Spectrum Analyzer

1. **Add Calf Analyzer**
   - Master bus → Add **Calf > Analyzer**
   - Position: Pre-master limiter (before limiting)

2. **Uses**
   - **Frequency balance:** Check for excessive bass/treble
   - **Sibilance check:** Watch 6–8 kHz range during de-essing
   - **Phase correlation:** Goniometer shows stereo width (center = mono, wide = stereo)

3. **Target Response**
   - Podcast voice: Gentle roll-off below 80 Hz, smooth 200 Hz–8 kHz, gentle HF roll-off above 10 kHz
   - Avoid excessive energy at 200–400 Hz (muddiness) or 6–8 kHz (harshness)

#### Monitor Section (Optional)

Ardour's monitor section provides studio-style monitoring control.

1. **Enable Monitor Section**
   - `Session → Properties → Monitoring`
   - ☑ **Use Monitor Section**
   - Click **OK** → Ardour creates monitor section bus

2. **Monitor Section Features**
   - **Dim:** Reduce monitor level temporarily (e.g., during phone calls)
   - **Cut/Mute:** Silence monitors entirely
   - **Mono:** Sum to mono (check mono compatibility)
   - **Solo:** Override monitor bus with solo'd tracks
   - **Channel controls:** Independent level for L/R monitors

3. **SG9 Usage**
   - **Dim:** -20 dB during VoIP calls
   - **Mono check:** Before export, enable Mono to verify voice clarity in mono playback
   - **Solo isolation:** Monitor section allows AFL/PFL (after-fader listen/pre-fader listen)

**Note:** Monitor section is independent from Master bus. Master bus → Recording/Export, Monitor section → Physical monitoring only.

### Step 26: Workflow Optimizations

Ardour 8 workflow enhancements for efficiency.

#### Keybindings for Speed

Essential keyboard shortcuts:

| Action | Default Shortcut | Alternative |
|--------|------------------|-------------|
| Play/Stop | `Spacebar` | `Numpad 3` |
| Record | `Shift+Spacebar` | `Numpad Enter` |
| Arm selected track | `Shift+B` | — |
| Solo selected track | `Ctrl+Alt+S` | — |
| Mute selected track | `Ctrl+Alt+M` | — |
| Next marker | `Tab` | `Ctrl+Right Arrow` |
| Previous marker | `Shift+Tab` | `Ctrl+Left Arrow` |
| Zoom in | `=` | `Shift++` |
| Zoom out | `-` | `Shift+-` |
| Zoom to session | `Ctrl+0` | — |
| Undo | `Ctrl+Z` | — |
| Redo | `Ctrl+Shift+Z` | — |
| Import audio | `Ctrl+I` | — |
| Export audio | `Ctrl+Shift+E` | — |
| Save session | `Ctrl+S` | — |
| Snapshot | `Shift+Ctrl+S` | — |

**Customize Keybindings:**
1. `Edit → Preferences → Keyboard/Mouse`
2. Search for action (e.g., "transport play")
3. Click binding column → Press new key combination
4. Click **OK**

#### Grid Snap Settings

Configure snap/grid for precise editing:

1. **Grid Mode Selector** (top toolbar)
   - **No Grid:** Free positioning
   - **Grid:** Snap to grid
   - **Magnetic:** Snap to nearby grid points

2. **Grid Type**
   - **Bars:** Musical bars (1/4, 1/8, 1/16 notes)
   - **Timecode:** SMPTE frames
   - **Seconds:** 1s, 10s, 1 minute intervals
   - **Regions:** Snap to region boundaries

3. **SG9 Recommendation**
   - **Recording/editing:** Grid = 1 second
   - **Precise cuts:** No Grid (free edit)
   - **Music alignment:** Grid = 1/4 note (if using music time)

**Toggle Grid:** `Ctrl+3` (cycles through grid modes)

#### Region Editing Modes

Ardour 8 offers multiple edit modes:

1. **Smart Mode** (Recommended)
   - Top half of region: Grabber (move region)
   - Bottom half: Trimmer (adjust region boundaries)
   - Reduces mode switching

2. **Grabber Mode**
   - Click-drag to move regions
   - Shift-click to select multiple

3. **Range Mode**
   - Click-drag to select time range
   - Useful for cutting/deleting sections

4. **Stretch/Shrink Mode**
   - Time-stretch audio without changing pitch
   - Useful for fitting music beds to exact durations

**Switch Modes:** `E` (Grabber), `R` (Range), `T` (Trimmer), `D` (Smart)

#### Auto-Return

Enable auto-return for iterative editing:

1. `Transport → Auto Return` (☑)
2. Behavior:
   - Press Play → Playback starts from playhead
   - Press Stop → Playhead returns to starting position
3. Benefit: Quickly re-audition same section after edits

#### Input Monitoring Shortcuts

Fast-toggle input monitoring per track:

- `Ctrl+Alt+Shift+M` → Toggle monitor mode (Auto/Input/Disk)
- Right-click track record button → Monitor mode submenu

**Use Case:** Switch to **Disk** monitoring on Music Loopback to prevent feedback when playing system audio.

### Step 27: Backup & Session Management

Protect your work with robust backup strategies.

#### Automatic Backups

Ardour automatically backs up sessions:

1. **Configure Backup Interval**
   - `Edit → Preferences → Misc`
   - **Periodic Backup Interval:** 120 seconds (2 minutes)
   - **Minimum Diskspace (GB):** 5 GB

2. **Backup Location**
   - Session folder: `<session_name>/instant.xml.bak`
   - Automatic backups: `<session_name>/interchange/<session_name>/` (audio)

3. **Recovery**
   - If session corrupted: `Session → Open`
   - Select session folder
   - Ardour detects crash → Offers recovery from last backup

#### Manual Backups

1. **Full Session Archive**
   - `Session → Export → Archive`
   - Options:
     - ☑ Include audio files
     - ☑ FLAC compression (lossless, saves space)
   - Destination: External drive or cloud storage
   - Filename: `SG9-2026-01-19-Episode-Name-Archive.tar.xz`

2. **Incremental Backups**
   - Use `rsync` or `rclone` to sync session folder to NAS/cloud
   - Example script:
     ```bash
     rsync -avz --progress ~/audio/sessions/ /mnt/nas/ardour-backups/
     ```

3. **Version Control (Git)**
   - Initialize Git repo in session folder
   - `.gitignore`:
     ```
     interchange/
     peaks/
     analysis/
     export/
     plugins/
     *.wav
     *.flac
     ```
   - Commit snapshots and session XML files
   - Benefit: Track configuration changes over time

**Backup Schedule:**
- **During session:** Automatic every 2 minutes
- **After recording:** Manual snapshot
- **End of day:** Archive to external drive
- **Weekly:** Cloud backup of archives

#### Disk Space Management

Podcast sessions accumulate audio files. Manage disk usage:

1. **Check Session Size**
   - `Session → Properties → Statistics`
   - Shows total audio file size

2. **Remove Unused Sources**
   - `Session → Clean Up → Clean Up Unused Sources`
   - Preview list of unused files
   - Click **Delete** to free space

3. **Consolidate Regions**
   - Select regions → Right-click → **Consolidate Range**
   - Bounces regions to single file → Simplifies session

**Warning:** Only clean up unused sources after final export. Keep raw recordings until project is complete.

### Step 28: Export Workflow

Prepare final audio for distribution.

#### Standard Export Settings

1. **Open Export Dialog**
   - `Session → Export → Export to Audio File(s)`

2. **Time Span**
   - Select: **Session range** (entire session)
   - Or: Select specific range/section

3. **Format Settings**
   - **Format:** WAV
   - **Sample Rate:** 48 kHz (match session)
   - **Bit Depth:** 24-bit (16-bit for distribution after processing)
   - **Mapping:** Stereo (Master L/R)

4. **Normalization**
   - ☑ **Normalize to -1.0 dBTP**
   - Ensures no clipping in final file

5. **Filename**
   - Template: `%S-Export-%D` (Session name - Export - Date)
   - Example: `SG9-2026-01-19-Episode-Name-Export-20260119.wav`

6. **Export**

#### Multi-Format Export

Export multiple formats simultaneously:

1. **Add Export Preset**
   - Click **+** (Add Preset)
   - Name: `Podcast Distribution`
   - Settings:
     - WAV 48k/24-bit (archival master)
     - WAV 48k/16-bit (distribution master)
     - MP3 320 kbps (podcast hosting)

2. **Batch Export**
   - Enable all three presets (☑)
   - Click **Export**
   - Ardour exports all formats in one pass

#### Stem Export

Export individual tracks for remixing or editing:

1. **Select Tracks to Export**
   - `Session → Export → Export to Audio File(s)`
   - Click **Tracks** tab

2. **Select Stems**
   - ☑ Host Mic (DSP)
   - ☑ Guest Mic
   - ☑ Remote Guest
   - ☑ Music Bus
   - ☐ (Deselect: Host Mic Raw, Aux, etc.)

3. **Export Settings**
   - Format: WAV 48k/24-bit
   - Filename: `%S-%n` (Session name - Track name)
   - Example: `SG9-Episode-1-Host-Mic.wav`

4. **Export**
   - Ardour creates separate file per track
   - Useful for sending to external editor or archival

#### Post-Export Analysis

Ardour 8 includes post-export analysis:

1. **Enable Post-Export Hook**
   - `Edit → Preferences → Export`
   - ☑ **Analyze Exported Audio**

2. **After Export**
   - Ardour displays:
     - Loudness (LUFS)
     - True Peak (dBTP)
     - Spectrum graph
     - Waveform overview

3. **Verify**
   - Integrated loudness: -16 LUFS ±2
   - True peak: ≤ -1.0 dBTP
   - LRA: 4–10 LU

**If out of spec:** Return to session, adjust levels, re-export.

Consistent colors improve visual navigation:

| Track Type | Color | Hex Code |
|------------|-------|----------|
| Host Mic (DSP) | Red | #E74C3C |
| Host Mic (Raw) | Dark Red | #A93226 |
| Guest Mic | Orange | #E67E22 |
| Aux Input | Yellow | #F39C12 |
| Bluetooth | Blue | #3498DB |
| Remote Guest | Purple | #9B59B6 |
| Music Loopback | Cyan | #1ABC9C |
| Music Tracks | Green | #27AE60 |
| Jingles | Light Green | #58D68D |
| SFX | Lime | #A9DFBF |
| Voice Bus | Pink | #EC7063 |
| Music Bus | Dark Green | #1E8449 |

**Apply Color:**
1. Right-click track name → **Properties**
2. Click color swatch
3. Enter hex code or choose from palette

### Step 18: MIDI Controller Mapping

#### Korg nanoKONTROL Studio

1. Connect nanoKONTROL via USB
2. **Edit → Preferences → Control Surfaces**
3. Add **Generic MIDI**
4. Create custom binding:
   - `Session → MIDI Bindings → New Binding`
   - Map faders to VCAs:
     - Fader 1 → Voice Master VCA
     - Fader 2 → Music Master VCA
     - Fader 9 → Master Control VCA
   - Map buttons:
     - S1 → Voice Bus Mute
     - S2 → Music Bus Mute
     - R1 → Host Mic Rec Enable

5. Save binding: `~/.config/ardour8/midi_maps/nanoKONTROL-SG9.map`

#### Novation Launchpad Pro Mk2

1. Set Launchpad to **Programmer Mode** (Port 3)
2. In Ardour: **Edit → Preferences → Control Surfaces**
3. Add **Generic MIDI**
4. Map clip triggers:
   - Use **MIDI Learn** mode
   - Press pad on Launchpad
   - Click Ardour region/clip
   - Assign note trigger

**Advanced:** Use SysEx messages for LED feedback (requires scripting).

### Step 19: Session Snapshots

Snapshots preserve session states without duplicating audio files.

1. **Create Pre-Show Snapshot**
   - `Session → Snapshot (keep working on current version)`
   - Name: "SG9-Template-v1.0"

2. **Snapshot Strategy**
   - Create snapshot before each recording session
   - Name format: `YYYY-MM-DD-Episode-Name`
   - Allows non-destructive experimentation

### Step 20: Save as Template

1. **Session → Save Template**
   - Template name: `SG9 Studio Broadcast Template`
   - Description: "Complete SG9 Studio setup with VCAs, busses, processing chains, and MIDI mapping"

2. Template is saved to: `~/.config/ardour8/templates/`

3. **Use Template:**
   - `Session → New → From Template → SG9 Studio Broadcast Template`

## Monitoring & Metering

### Step 21: Configure Monitoring Windows

1. **Loudness Analyzer**
   - `Window → Loudness Analyzer`
   - Mode: EBU R128
   - Target: -16 LUFS
   - Dock on right side of editor window

2. **Mixer Window Layout**
   - `Alt+M` → Open mixer
   - Show: Master, Voice Bus, Music Bus, VCAs
   - Hide individual tracks for cleaner view
   - Use **Foldback** feature to monitor specific tracks

3. **Meters on Master**
   - Insert x42 True Peak Meter (post-limiter)
   - Monitor for peaks above -1.0 dBTP

## Operational Workflows

### Pre-Flight Checklist (Before Each Recording)

Execute this checklist 5–10 minutes before each recording session:

1. **☑ Hardware Check**
   - Vocaster Two powered on
   - Microphones connected (Host + Guest if applicable)
   - Headphones connected (Guest = primary reference, Host = secondary)
   - ALSA routing verified in `alsa-scarlett-gui`

2. **☑ Session Preparation**
   - Load template or previous episode snapshot
   - Create new snapshot: `2026-01-19-Episode-Name`
   - Save immediately (`Ctrl+S`)

3. **☑ Track Arming**
   - Host Mic (DSP): **Armed**
   - Host Mic (Raw): **Armed** (safety recording)
   - Guest Mic: Armed if local guest present
   - Remote Guest: Armed if remote guest present
   - Aux Input: Armed if phone/tablet guest present
   - All other tracks: **Disarmed**

4. **☑ Monitor Configuration**
   - Monitoring model: **Software Monitoring** (verify in Preferences)
   - Auto Input: **Enabled**
   - Monitor output: **Guest headphones** (primary reference)
   - Host headphones: Comfortable level (secondary monitoring)

5. **☑ Level Check**
   - Speak into Host mic at normal level
   - Input meter: Peak -18 to -12 dBFS (pre-plugins)
   - Output meter (Master): -20 to -12 dBFS (average), peaks -6 dBFS
   - Loudness Analyzer (S): -16 to -14 LUFS during speech

6. **☑ Monitoring Test**
   - Host speaks → Voice sounds clean, not doubled/phasey
   - If phasey: Disable hardware monitoring in Vocaster mixer
   - Remote guest speaks → Check for echo
   - Remote guest should NOT hear themselves

7. **☑ Loudness Pre-Test**
   - Record 30 seconds of dialogue
   - Stop, play back
   - Loudness Analyzer (I): -16 LUFS ±2 LU
   - True Peak: ≤ -1.0 dBTP
   - Adjust input gain or compressor makeup if out of range

8. **☑ Marker Setup**
   - Position playhead at 0:00
   - Add marker: `SHOW-START`
   - Add section markers if pre-planned (INTRO, TOPIC-1, etc.)

9. **☑ Controller Check**
   - nanoKONTROL faders respond to movement
   - Launchpad pads trigger actions (if mapped)

10. **☑ Final Confirmation**
    - All participants on VoIP call (if remote)
    - Mix-minus bus routed correctly (remote guest does not echo)
    - Recording destination: Correct folder with sufficient disk space (≥10 GB)
    - Buffer size: 128 or 256 samples (no xruns during test)

**Total Time:** 5–10 minutes | **Frequency:** Every recording session

### Recording Workflow

1. **Start Recording**
   - `Shift+Spacebar` or click **Record** button
   - Verify all armed tracks show red **Rec** indicator
   - Playhead begins moving

2. **During Recording**
   - **Primary monitoring:** Guest headphones
   - **Level riding:** Use VCA faders for real-time mix adjustments
     - Voice Master VCA: Adjust overall voice level
     - Music Master VCA: Duck music during dialogue
   - **Mark segments:** Press `Tab` to add markers during recording
     - Example: Mark when topic changes, ad breaks, important moments
   - **Watch meters:**
     - Momentary loudness (M): Should fluctuate -20 to -10 LUFS during speech
     - True Peak: Must stay below -1.0 dBTP (red = stop and fix)

3. **Handling Issues Mid-Recording**
   - **Mic pop/noise:** Mark with colored flag (`L` key → Select color)
   - **Long pause:** Mark with range (for easy deletion later)
   - **Technical glitch:** Continue recording, fix in post

4. **Stop Recording**
   - `Spacebar` → Stop transport
   - Verify recording length matches expected duration
   - All tracks show recorded regions (waveforms visible)

5. **Immediate Post-Recording**
   - Create snapshot: `Session → Snapshot`
   - Name: `[Episode-Name]-RAW-Recording`
   - Save session (`Ctrl+S`)

### Post-Recording Workflow

1. **Preliminary Playback**
   - Disable input monitoring (all tracks: Monitor = Disk)
   - Play from beginning
   - Listen for: Clipping, dropouts, phase issues, echo

2. **Basic Editing**
   - Remove long silence (>3 seconds):
     - Use **Range Mode** (`R`)
     - Select silence range
     - `Delete` key
   - Remove false starts:
     - Use **Grabber Mode** (`E`)
     - Select unwanted region
     - `Delete` key
   - Trim ends:
     - Zoom to end of session (`=` key)
     - Trim final region to clean ending

3. **Normalization Check**
   - Reset Loudness Analyzer
   - Play entire session
   - After playback:
     - **Integrated (I):** -16 LUFS ±2 LU ✓
     - **LRA:** 4–10 LU ✓
     - **True Peak:** ≤ -1.0 dBTP ✓
   - If out of spec:
     - **Too quiet:** Increase compressor makeup gain or master fader
     - **Too loud:** Reduce master fader or limiter ceiling
     - **LRA too high:** Increase compression ratio
     - **LRA too low:** Reduce compression ratio (over-compressed)

4. **Region Normalization (Optional)**
   - Select all voice regions
   - Right-click → **Loudness Analysis and Normalization**
   - Target: -16 LUFS
   - Ardour adjusts region gain to match target
   - Useful for matching levels across different speakers

5. **Create Final Snapshot**
   - `Session → Snapshot`
   - Name: `[Episode-Name]-FINAL-EDIT`

### Export Workflow

1. **Pre-Export Verification**
   - Play last 30 seconds
   - Check for fade-out (if needed)
   - Verify Master bus limiter is active

2. **Export**
   - `Ctrl+Shift+E` → Export dialog
   - Time span: **Session range** (or custom range)
   - Format: **Podcast Distribution** preset (if created)
   - Or manual:
     - WAV 48k/24-bit (master)
     - MP3 320 kbps (distribution)
   - Normalization: ☑ -1.0 dBTP
   - Click **Export**

3. **Post-Export Analysis**
   - Review Ardour's analysis:
     - Loudness graph: Should be flat around -16 LUFS
     - Spectrum: Balanced frequency response
     - True peak: All green (no red peaks)
   - If issues: Return to session, adjust, re-export

4. **Final Deliverables**
   - Export folder contains:
     - `Episode-Name-Master-48k-24bit.wav` (archival)
     - `Episode-Name-Distribution-48k-16bit.wav` (distribution)
     - `Episode-Name-Podcast-320k.mp3` (hosting)
   - Add ID3 tags to MP3 (external tool: `id3v2`, `Kid3`, `Picard`)

5. **Archive Session**
   - `Session → Export → Archive`
   - ☑ Include audio
   - ☑ FLAC compression
   - Save to: External drive or NAS
   - Filename: `SG9-Episode-Name-Archive-YYYY-MM-DD.tar.xz`

### Solo Recording (Single Host)

1. Arm: Host Mic (DSP) + Host Mic (Raw)
2. Verify monitoring from Ardour (no hardware mix)
3. Record
4. Post-process: Standard workflow

### Remote Interview (Host + Remote Guest)

1. Arm: Host Mic (DSP), Host Mic (Raw), Remote Guest
2. Verify mix-minus bus routed to VoIP app
3. Test: Remote guest should NOT hear themselves
4. Record
5. Post-process:
   - Check sync between local and remote tracks
   - If remote track has echo: Mute Remote Guest track, use local recording only

### Aux Guest (Phone/Tablet via 3.5mm)

1. Connect device to Aux input (front panel)
2. Arm: Host Mic (DSP), Host Mic (Raw), Aux Input
3. Level match: Aux Input should peak similar to Host Mic (-18 to -12 dBFS)
4. Record
5. Post-process:
   - Aux Input may need extra EQ (phones often lack bass)
   - Increase compression ratio on Aux Input if levels vary

### Live Music/Sound Bed Integration

1. Prepare music file in Music 1 track
2. Set Music 1 fader to -6 dB (starting level)
3. Automate Music Bus fader:
   - Start of intro: Music Bus = 0 dB (full music)
   - Host begins speaking: Music Bus = -12 dB (ducked)
   - Host stops: Music Bus = 0 dB (music returns)
4. Alternative: Use music ducking sidechain compressor (auto-duck)

## Troubleshooting

### Voice sounds phasey or doubled

**Symptoms:** Voice has chorus/flanger effect, sounds like two sources slightly out of sync

**Cause:** Hardware monitoring (Vocaster mixer) is active simultaneously with software monitoring (Ardour)

**Solution:**
1. Open `alsa-scarlett-gui`
2. Navigate to routing matrix
3. Verify Analogue Input 1 is **NOT** routed directly to Analogue Output 1–6
4. Only route **PCM** (Ardour output) to Analogue Outputs
5. In Ardour: `Edit → Preferences → Audio → Monitoring Model: Software Monitoring`

**Prevention:** Always use Software Monitoring in Ardour, disable hardware mixer routing

### Remote guest hears themselves (echo)

**Symptoms:** Remote guest complains of hearing their own voice with delay

**Cause:** Remote Guest track is being sent back to VoIP application via Master bus or incorrect routing

**Solution:**
1. Create Mix-Minus bus (see [Step 23](#step-23-advanced-routing--mix-minus-for-remote-guests))
2. Send Host Mic, Guest Mic, Music to Mix-Minus
3. **Do NOT** send Remote Guest track to Mix-Minus
4. Route Mix-Minus output to VoIP app input (not Master bus)
5. VoIP app output → Ardour Remote Guest track input

**Test:** Remote guest speaks → You hear them, they do NOT hear themselves

### Plugins cause xruns (audio dropouts)

**Symptoms:** Crackling, pops, dropouts during playback/recording. Message: "xruns detected"

**Cause:** CPU cannot process audio fast enough at current buffer size

**Solution (in order of preference):**
1. **Increase buffer size:**
   - `Session → Properties → Audio`
   - Buffer size: 256 → 512 samples
   - Trade-off: Higher latency, but more stable
2. **Reduce plugin oversampling:**
   - LSP Limiter: 8x → 4x → 2x
   - De-esser: Reduce FFT size if applicable
3. **Disable unnecessary plugins:**
   - Bypass plugins on unarmed tracks
   - Remove spectrum analyzers during recording
4. **CPU governor (Linux):**
   - Set CPU to "performance" mode:
     ```bash
     sudo cpupower frequency-set -g performance
     ```
5. **Close background apps:**
   - Browser, email, video players consume CPU

**Prevention:** Test session with all plugins active before recording. Monitor CPU usage in Ardour status bar.

### Loudness too low despite proper gain staging

**Symptoms:** Integrated loudness < -18 LUFS, audio sounds quiet

**Cause:** Insufficient makeup gain after compression, or over-use of dynamics processing

**Solution:**
1. **Check compressor makeup gain:**
   - LSP Compressor → Makeup gain: Auto or manual +6 to +12 dB
   - Target: Average level post-compression -12 dBFS
2. **Check limiter threshold:**
   - LSP Limiter → Threshold: -3 to -2 dB (not -6 dB)
   - Ceiling: -1.0 dBTP
3. **Check master fader:**
   - Master fader should be at 0 dB (unity gain)
   - If below 0 dB, increase source levels instead
4. **Reduce compression ratio:**
   - If over-compressed: 6:1 → 4:1 → 3:1
   - Over-compression reduces dynamic range but also overall level

**Verification:** Play 30 seconds → Loudness Analyzer (S) should read -16 to -14 LUFS during speech

### Loudness too high / distorted

**Symptoms:** Integrated loudness > -14 LUFS, audio sounds crushed or distorted

**Cause:** Excessive makeup gain, insufficient limiting, or clipping at input stage

**Solution:**
1. **Check input levels:**
   - Reduce Vocaster mic gain (physical knob)
   - Input meter (pre-plugins): Peak -18 to -12 dBFS (not higher)
2. **Reduce compressor makeup gain:**
   - LSP Compressor → Makeup gain: Lower by 3–6 dB
3. **Enable/verify limiter:**
   - LSP Limiter → Ceiling: -1.0 dBTP
   - Threshold: -3 dB
   - Verify limiter is **last** plugin in chain
4. **Check for clipping:**
   - Look for red peaks in waveform (clipped samples)
   - If present: Re-record with lower input gain

### MIDI controller not responding

**Symptoms:** nanoKONTROL faders or Launchpad pads do not control Ardour

**Cause:** MIDI port not connected, binding map not loaded, or incorrect port assignment

**Solution:**
1. **Verify hardware connection:**
   - Reconnect USB cable
   - Linux: Check `aconnect -l` for MIDI ports
   - macOS: Check Audio MIDI Setup app
2. **Check control surface settings:**
   - `Edit → Preferences → Control Surfaces`
   - Verify **Generic MIDI** is enabled (☑)
   - Click **Show Protocol Settings**
   - **Incoming MIDI:** Select correct device port
   - **Outgoing MIDI:** Select correct device port (for LED feedback)
3. **Verify binding map:**
   - Binding map file: `~/.config/ardour8/midi_maps/nanoKONTROL-SG9.map`
   - If missing: Recreate using MIDI Learn
4. **Restart Ardour:**
   - Close and reopen session
   - MIDI devices re-scan on startup

**Test:** Move fader on controller → Corresponding Ardour fader should move

### True Peak overs (> -1.0 dBTP)

**Symptoms:** x42 True Peak Meter shows red peaks, Loudness Analyzer TP > -1.0 dBTP

**Cause:** Insufficient limiting, inter-sample peaks, or incorrect limiter settings

**Solution:**
1. **Increase limiter oversampling:**
   - LSP Limiter → Oversampling: 4x → 8x
   - Higher oversampling catches inter-sample peaks
2. **Lower limiter ceiling:**
   - Ceiling: -1.0 dBTP → -1.5 dBTP
   - Provides safety margin for encoding/conversion
3. **Reduce limiter threshold:**
   - Threshold: -3 dB → -4 dB
   - More aggressive limiting
4. **Check plugin order:**
   - Limiter must be **last** plugin on Master bus
   - No plugins after limiter that could increase level
5. **Verify true peak metering:**
   - x42 True Peak Meter → Oversampling: 4x
   - EBU R128 standard requires oversampled peak detection

**Prevention:** Always monitor True Peak meter during recording and export

### Latency / Monitoring delay

**Symptoms:** Noticeable delay between speaking and hearing voice in headphones

**Cause:** Buffer size too high, or additional latency from plugin processing

**Solution:**
1. **Reduce buffer size:**
   - `Session → Properties → Audio`
   - Buffer size: 512 → 256 → 128 samples
   - Trade-off: Lower latency, higher CPU load
2. **Use hardware monitoring (not recommended for SG9):**
   - Alternative: Monitor directly from Vocaster mixer
   - Disadvantage: Cannot hear plugin processing
3. **Disable high-latency plugins during recording:**
   - Bypass reverb, complex modulation effects
   - Re-enable for mixdown
4. **Use PDC (Plugin Delay Compensation):**
   - `Edit → Preferences → Misc → Compensate for Plugin Latency` (☑)
   - Ardour auto-compensates for plugin latency

**Typical latency at 48 kHz:**
- 128 samples: ~2.7 ms (imperceptible)
- 256 samples: ~5.3 ms (barely noticeable)
- 512 samples: ~10.7 ms (noticeable delay)

**SG9 Recommendation:** 128 samples if CPU allows, 256 samples otherwise

### Session won't load / Corrupted session

**Symptoms:** Error message when opening session, missing regions, or Ardour crashes on load

**Cause:** Power loss during save, disk corruption, or incompatible session format

**Solution:**
1. **Load backup session:**
   - `Session → Open`
   - Select session folder
   - Ardour offers: "Session appears to have been damaged. Restore from backup?"
   - Click **Yes**
2. **Manual recovery:**
   - Navigate to session folder
   - Locate `instant.xml.bak` (backup file)
   - Rename to `<session_name>.ardour`
   - Open session
3. **Load older snapshot:**
   - `Session → Open`
   - Select session folder
   - Choose older snapshot from dropdown
4. **Recover audio files:**
   - Even if session XML is corrupted, audio files are intact
   - Located in: `<session>/interchange/<session>/audiofiles/`
   - Create new session, import audio files manually

**Prevention:**
- Save frequently (`Ctrl+S`)
- Create snapshots at milestones
- Enable automatic backups (every 120 seconds)
- Use UPS (uninterruptible power supply) for desktop

### Mix-Minus not working / Remote guest still hears themselves

**Symptoms:** Remote guest reports hearing echo despite mix-minus bus configuration

**Causes & Solutions:**

1. **VoIP app using wrong audio source:**
   - Zoom/Skype settings → Microphone: Select "Mix-Minus" or "Ardour Playback"
   - **Not** "Master" or "System Default"

2. **Remote Guest track routed to Mix-Minus:**
   - Check Mix-Minus bus sends
   - Verify Remote Guest track has **NO** send to Mix-Minus
   - Only Host Mic, Guest Mic, Music should send to Mix-Minus

3. **System-level audio routing:**
   - Linux: Use `pavucontrol` or `qpwgraph` (PipeWire) to verify routing
   - macOS: Check Audio MIDI Setup → Aggregate Device routing
   - Ensure VoIP app input = Mix-Minus output

4. **Loopback/monitor routing:**
   - If using loopback device (e.g., `snd-aloop`), verify routing:
     - Ardour Mix-Minus → Loopback input
     - VoIP app input → Loopback output
     - No feedback path from VoIP output → VoIP input

**Test procedure:**
1. Remote guest mutes their microphone in VoIP app
2. Host speaks
3. Remote guest should hear host clearly
4. Remote guest unmutes and speaks
5. Remote guest should **NOT** hear their own voice

### PipeWire/JACK Connection Issues

**Symptoms:** Ardour can't find audio interface, "JACK is not running" error, or no sound

**Solutions:**

1. **Verify PipeWire services are running:**
   ```bash
   systemctl --user status pipewire pipewire-pulse wireplumber
   ```
   - If not running: `systemctl --user start pipewire pipewire-pulse wireplumber`
   - Enable on boot: `systemctl --user enable pipewire pipewire-pulse wireplumber`

2. **Check JACK backend in Ardour:**
   - In Ardour 8.10+, backend should show **"JACK/Pipewire"**
   - If not available, reinstall pipewire-jack: `sudo pacman -S pipewire-jack`

3. **Verify PipeWire is providing JACK API:**
   ```bash
   # Should show PipeWire version, not native JACK
   pw-cli info 0
   ```

4. **Check for conflicting JACK daemon:**
   ```bash
   # Ensure native JACK is not running
   killall jackd
   systemctl --user stop jack
   ```

### Xruns / Dropouts (PipeWire)

**Symptoms:** Audio glitches, pops, clicks, or "xrun" messages in Ardour or terminal

**Causes & Solutions:**

1. **Buffer size too small:**
   - Increase quantum in `~/.config/pipewire/pipewire.conf.d/custom.conf`:
     ```conf
     context.properties = {
         default.clock.quantum = 512  # or 1024
     }
     ```
   - Restart PipeWire: `systemctl --user restart pipewire`

2. **CPU governor not set to performance:**
   ```bash
   # Check governor
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   
   # Set to performance (temporary)
   echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

3. **High system load:**
   - Close unnecessary applications
   - Disable desktop effects (KDE: `Alt+Shift+F12`)
   - Monitor with: `pw-top` (shows PipeWire graph in real-time)

4. **Adjust PipeWire headroom:**
   ```conf
   # ~/.config/wireplumber/wireplumber.conf.d/alsa-config.conf
   monitor.alsa.rules = [
     {
       matches = [ { node.name = "~alsa_output.*" } ]
       actions = {
         update-props = {
           api.alsa.period-size = 1024
           api.alsa.headroom = 8192
         }
       }
     }
   ]
   ```

### High Latency (PipeWire)

**Symptoms:** Noticeable delay between speaking into mic and hearing output

**Current latency check:**
```bash
pw-top  # Look at "Quantum" column for current buffer size
```

**Solutions:**

1. **Reduce PipeWire quantum:**
   ```conf
   # ~/.config/pipewire/pipewire.conf.d/custom.conf
   context.properties = {
       default.clock.quantum = 256  # or 128 for ultra-low latency
       default.clock.min-quantum = 32
   }
   ```

2. **Monitor for stability:**
   - After reducing quantum, record for 5 minutes
   - Watch `pw-top` for xruns (shown as "errors" or "xruns")
   - If unstable, increase quantum back to 512 or 1024

3. **Per-application buffer size:**
   ```bash
   # Launch Ardour with custom quantum (for testing)
   PIPEWIRE_LATENCY="128/48000" ardour8
   ```

**Latency reference at 48 kHz:**
- 128 samples = ~2.7 ms (excellent, may cause xruns on slower CPUs)
- 256 samples = ~5.3 ms (great, recommended for broadcast)
- 512 samples = ~10.7 ms (good, very stable)
- 1024 samples = ~21.3 ms (acceptable for non-realtime work)

### ALSA/PipeWire Routing Problems

**Symptoms:** Sound from Ardour not reaching Vocaster outputs, or wrong channels

**Cause:** ALSA routing (alsa-scarlett-gui) and PipeWire routing conflict

**Solution:**

1. **Verify ALSA hardware routing:**
   - Open `alsa-scarlett-gui`
   - Check PCM 01/02 (from Ardour) → Analogue 1–6 (to speakers/headphones)
   - **Do NOT route** Analogue Inputs directly to Analogue Outputs (causes feedback)

2. **Check PipeWire connections:**
   ```bash
   pw-link -l  # List all PipeWire links
   ```
   - Ardour outputs should connect to "Vocaster Two" sink
   - If missing, use `pw-link` to connect manually (or use `qpwgraph` GUI)

3. **Verify Vocaster is default PipeWire sink:**
   ```bash
   pactl list sinks  # Look for Vocaster Two
   pactl set-default-sink <vocaster_sink_name>
   ```

## Reference: Ardour 8 Monitoring Models

### Global Monitoring Models

Ardour offers three monitoring approaches:

| Mode | How It Works | Latency | Hear Plugins | Use Case |
|------|--------------|---------|--------------|----------|
| **Hardware Monitoring** | Interface handles monitoring | None (0 ms) | No | Low-latency hardware mixers (RME, MOTU with CueMix) |
| **Software Monitoring** | Ardour handles monitoring | Buffer-dependent (~2–10 ms) | Yes | **SG9 Studio (recommended)** |
| **External Monitoring** | External mixer/patchbay | None | No | Advanced setups with dedicated monitor controller |

### SG9 Studio Monitoring Configuration

- **Model:** Software Monitoring
- **Rationale:** Hear plugin processing during recording (essential for voice work)
- **Latency:** 2.7 ms @ 128 samples, 5.3 ms @ 256 samples (imperceptible)
- **Hardware role:** Vocaster controls physical volume only

### Auto Input Behavior

Auto Input automatically switches between input and disk monitoring:

| Transport State | Track Armed | Recording | Monitoring Source | Use Case |
|-----------------|-------------|-----------|-------------------|----------|
| **Stopped** | Yes | — | Input (live mic) | Pre-recording setup |
| **Stopped** | No | — | Disk (file) | Not used |
| **Playing** | Yes | No | Disk (file) | Playback during pause |
| **Playing** | Yes | Yes | Input (live mic) | Active recording |

**SG9 Setting:** Auto Input = **Enabled** (default)

### Per-Track Monitor Modes

Each track has independent monitor mode:

| Mode | Behavior | SG9 Usage |
|------|----------|-----------|
| **Auto** | Follows Auto Input rules | Voice/input tracks (default) |
| **Input** | Always monitor input | Not used |
| **Disk** | Always monitor disk playback | Music Loopback, Music tracks |

**Right-click track record button → Monitor Mode** to change

## Reference: Ardour 8 Track Types

### Audio Tracks

- **Purpose:** Record and playback audio
- **I/O:** Mono, Stereo, or Multichannel
- **SG9 Usage:** Voice tracks (mono), Music tracks (stereo)

### MIDI Tracks

- **Purpose:** Record and playback MIDI notes/CC
- **I/O:** MIDI in/out
- **SG9 Usage:** Not used (no MIDI instruments in broadcast workflow)

### Audio Busses

- **Purpose:** Submix/group audio without recording capability
- **I/O:** Stereo or multichannel
- **SG9 Usage:** Voice Bus, Music Bus, Mix-Minus Bus

### VCAs (Control Masters)

- **Purpose:** Control multiple faders without passing audio
- **I/O:** Control-only (no audio routing)
- **SG9 Usage:** Voice Master, Music Master, Master Control

### Master Bus

- **Purpose:** Final stereo output
- **I/O:** Stereo
- **SG9 Usage:** Final processing (glue compression, limiting, metering)

## Reference: Plugin Processing Order (Canonical Chain)

```
Input → HPF → Gate → De-esser → EQ → Compressor → Limiter → Output
```

### Rationale for Order

1. **HPF (High-Pass Filter)** first
   - Removes rumble/low-frequency noise
   - Prevents gate/compressor from reacting to subsonic energy

2. **Gate** second
   - Works on clean signal (post-HPF)
   - Removes background noise during silence

3. **De-esser** before EQ
   - Prevents presence boost from amplifying sibilance
   - Sidechain compression technique is frequency-selective

4. **EQ** after dynamic processing
   - Shapes tone after noise/sibilance removed
   - Presence boost adds clarity without harshness

5. **Compressor** after EQ
   - Compresses the tonal-balanced signal
   - Evens out dynamic range

6. **Limiter** last
   - Final safety net for peaks
   - Ensures no output exceeds -1.0 dBTP

**Do not deviate from this order** without specific reason. Changing order affects tone and dynamics significantly.

## Reference: Loudness Standards (Quick Lookup)

| Platform | Integrated Loudness | Max True Peak | Max LRA | Format |
|----------|---------------------|---------------|---------|--------|
| **Apple Podcasts** | -16 LUFS | -1.0 dBTP | — | Stereo WAV/AAC |
| **Spotify** | -14 LUFS | -1.0 dBTP | — | Stereo WAV/OGG |
| **YouTube** | -14 LUFS | -1.0 dBTP | — | Stereo WAV/AAC |
| **Amazon Music** | -14 LUFS | -2.0 dBTP | — | Stereo WAV/MP3 |
| **EBU R128 (Broadcast)** | -23 LUFS ±0.5 | -1.0 dBTP | 5–15 LU | Stereo WAV |
| **ATSC A/85 (US Broadcast)** | -24 LKFS | -2.0 dBTP | — | Stereo WAV |

**SG9 Studio Target:** -16 LUFS (broadest compatibility)

**Conversion:** LUFS = LKFS (identical measurement, different naming)

## Reference: File Formats & Codecs

### Recording/Archival

- **Format:** WAV (BWF)
- **Sample Rate:** 48 kHz
- **Bit Depth:** 24-bit
- **Channels:** Mono (voice), Stereo (music/master)
- **Why:** Uncompressed, lossless, maximum quality

### Distribution Master

- **Format:** WAV
- **Sample Rate:** 48 kHz
- **Bit Depth:** 16-bit (dithered from 24-bit)
- **Channels:** Stereo
- **Why:** Lossless, compatible with all platforms

### Podcast Hosting

- **Format:** MP3
- **Sample Rate:** 48 kHz
- **Bitrate:** 320 kbps (CBR) or V0 (VBR)
- **Channels:** Stereo (or joint-stereo)
- **Why:** Small file size, universal compatibility

### Alternative: AAC/M4A

- **Format:** AAC (MPEG-4 Audio)
- **Sample Rate:** 48 kHz
- **Bitrate:** 256 kbps VBR
- **Channels:** Stereo
- **Why:** Better quality than MP3 at same bitrate, Apple ecosystem native

### Archival Compression

- **Format:** FLAC (Free Lossless Audio Codec)
- **Sample Rate:** 48 kHz
- **Bit Depth:** 24-bit
- **Compression:** Level 8 (maximum)
- **Why:** Lossless compression (~50% size reduction), open standard

## Appendix: Plugin Reference

### LSP Plugin Suite (Primary Toolkit)

**LSP Parametric Equalizer x8 (Mono/Stereo)**
- **Use:** HPF, presence EQ, de-mud
- **Features:** 8 bands, HPF/LPF, bell/shelf/notch filters
- **Settings:** HPF @ 90 Hz 18dB/oct, Presence +4 dB @ 4 kHz Q=2.0

**LSP Gate (Mono/Stereo)**
- **Use:** Remove background noise during silence
- **Features:** Hysteresis, sidechain, envelope follower
- **Settings:** Threshold -38 dB, Hysteresis -45 dB, Hold 50 ms

**LSP Compressor (Mono/Stereo)**
- **Use:** Voice compression, de-essing (with sidechain)
- **Features:** Sidechain HPF/LPF, auto-makeup, knee, RMS/Peak
- **Settings:** 
  - Voice: Ratio 3.5:1, Threshold -18 dB, Attack 15 ms, Release 150 ms
  - De-esser: SC HPF 6 kHz, Ratio 4:1, Threshold -18 dB

**LSP Limiter (Mono/Stereo)**
- **Use:** Final peak control
- **Features:** True-peak detection, oversampling (2x/4x/8x), lookahead
- **Settings:** Ceiling -1.0 dBTP, Threshold -3 dB, Oversampling 4x

### Calf Plugin Suite (Supplementary)

**Calf Sidechain Compressor (Stereo)**
- **Use:** Music ducking
- **Features:** External sidechain input, HPF/LPF
- **Settings:** Ratio 4:1, Attack 15 ms, Release 400 ms

**Calf Analyzer**
- **Use:** Spectrum + phase visualization
- **Features:** FFT spectrum, goniometer, live display
- **Settings:** FFT size 8192, Window: Blackman-Harris

### x42 Plugin Suite (Metering)

**x42-meter EBU R128**
- **Use:** Loudness metering (LUFS/LU/LRA)
- **Features:** Integrated/Short-term/Momentary, LRA, True Peak
- **Settings:** Target -16 LUFS, Max TP -1.0 dBTP

**x42-meter True Peak Meter**
- **Use:** True peak monitoring
- **Features:** Oversampled peak detection, hold time
- **Settings:** Oversampling 4x, Hold 3 seconds

### ZAM Plugin Suite (Backup/Alternative)

**ZamComp**
- **Use:** Alternative compressor
- **Features:** RMS/Peak, knee, auto-makeup

**ZamGate**
- **Use:** Alternative gate
- **Features:** Envelope follower, sidechain

**Not recommended for SG9** — LSP plugins are more feature-complete and transparent

## Appendix: Ardour 8 Keyboard Shortcuts (Essential)

### Transport Control

| Action | Shortcut | Notes |
|--------|----------|-------|
| Play/Stop toggle | `Spacebar` | Primary transport control |
| Record | `Shift+Spacebar` | Start recording |
| Fast Forward | `→` | Nudge forward |
| Rewind | `←` | Nudge backward |
| Go to Start | `Home` | Jump to session start |
| Go to End | `End` | Jump to session end |
| Loop Toggle | `L` | Enable/disable loop |

### Track/Region Control

| Action | Shortcut | Notes |
|--------|----------|-------|
| Arm selected track | `Shift+B` | Record-enable |
| Solo selected track | `Ctrl+Alt+S` | Isolate track |
| Mute selected track | `Ctrl+Alt+M` | Silence track |
| Duplicate region | `Shift+D` | Copy + paste at playhead |
| Split region at playhead | `S` | Cut region |
| Delete region | `Delete` | Remove selected region |

### Navigation

| Action | Shortcut | Notes |
|--------|----------|-------|
| Next marker | `Tab` | Jump forward |
| Previous marker | `Shift+Tab` | Jump backward |
| Zoom in | `=` | Increase timeline zoom |
| Zoom out | `-` | Decrease timeline zoom |
| Zoom to session | `Ctrl+0` | Fit entire session in window |

### Edit Modes

| Action | Shortcut | Notes |
|--------|----------|-------|
| Grabber mode | `E` | Move regions |
| Range mode | `R` | Select time range |
| Smart mode | `D` | Hybrid grab/trim mode (recommended) |

### Windows

| Action | Shortcut | Notes |
|--------|----------|-------|
| Mixer window | `Alt+M` | Open/close mixer |
| Editor window | `Alt+E` | Focus editor |
| Preferences | `Alt+P` | Open preferences dialog |

### Session Management

| Action | Shortcut | Notes |
|--------|----------|-------|
| Save | `Ctrl+S` | Save session |
| Snapshot | `Shift+Ctrl+S` | Create snapshot |
| Export | `Ctrl+Shift+E` | Export dialog |
| Undo | `Ctrl+Z` | Undo last action |
| Redo | `Ctrl+Shift+Z` | Redo undone action |

**Customize:** `Edit → Preferences → Keyboard/Mouse`

## Changelog

- **v1.0 (2026-01-19):** Initial release — Comprehensive Ardour 8 setup guide extracted from STUDIO.md and enhanced with:
  - Step-by-step session creation (28 steps)
  - Modern Ardour 8 features (VCAs, track folders, arrangement sections, snapshots)
  - Advanced routing (mix-minus, sidechain ducking, aux sends)
  - MIDI controller integration (nanoKONTROL, Launchpad Pro Mk2)
  - Color schema and visual organization
  - Detailed operational workflows (pre-flight, recording, post-production, export)
  - Comprehensive troubleshooting (10+ common issues)
  - Reference sections (monitoring models, track types, loudness standards, keyboard shortcuts)

---

**Next Steps:** After completing this setup, refer to [STUDIO.md](STUDIO.md) for:
- Daily operational workflows
- Hardware setup (Vocaster Two, ALSA routing)
- Loudness targets and platform specifications
- Plugin tuning and fine-tuning parameters

---

**Next Steps:** After completing this setup, refer to [STUDIO.md](STUDIO.md) for daily operational workflows, loudness targets, and troubleshooting.
