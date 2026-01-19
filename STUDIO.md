# SG9 Studio — Setup & Reference Manual

This document turns the current SG9 Studio concept into a repeatable, broadcast-style operating manual.

**Core idea:** The Focusrite **Vocaster Two** provides stable I/O + hardware mixing, while **Ardour** provides the “broadcast chain” (EQ/dynamics/limiting, music ducking, routing, recording, and deliverables). On Linux, device routing/mixes are managed via `alsa-scarlett-gui`.

---

## Quick Start (Daily)

- Power on Vocaster Two.
- Open `alsa-scarlett-gui` and confirm your saved routing/mixer state is loaded.
- Open Ardour and load the SG9 Studio session/template.
- Set monitoring volume with the **Guest headphones knob** (primary monitoring destination).
- Arm what you need:
- Always: Track 1 (Host Mic DSP)
- Optional safety: Track 2 (Host Mic Raw)
- When remote call: Track 7 (Remote Guest)
- When phone/tablet: Track 5 (Aux Input)
- Before going live/recording, run the 20‑second checks:
- No double monitoring (your voice should not sound “phasey”)
- Remote echo check (remote must not hear themselves)
- Master ceiling is respected (no true-peak overs)

## 0) What This Studio Is Optimized For

- Solo podcast / voice recording with a consistent “broadcast” voice chain
- Remote interviews (Zoom/Skype/etc.) with proper **mix-minus (N-1)** to avoid echo
- Phone/tablet/portable audio via **Aux input**
- Backup music via **Bluetooth**
- Live-style show elements: jingles, stingers, SFX, sponsor blocks

---

## 1) Hardware Overview

### 1.1 Vocaster Two physical I/O

#### Inputs

- Host XLR (rear): primary mic (often condenser w/ 48V)
- Guest XLR (rear): guest mic (optional)
- Aux (front, 3.5mm stereo): phone/tablet/portable player
- Bluetooth: optional wireless audio source
- USB: multichannel audio I/O to/from computer

#### Outputs

- Monitor L/R (rear TRS): studio monitors
- Host headphones (front): spare / guest / utility
- Guest headphones (front): **daily monitoring** (primary operator headphones)

#### Output topology (important)

In practice, treat the Vocaster Two as having **two stereo output destinations**:

- **Destination A:** Studio monitors **and** Host headphones (these share the same program feed/controls)
- **Destination B:** Guest headphones (independent feed/controls)

SG9 Studio uses **Guest headphones as the primary “control room” monitoring** for mixing/recording, because they remain independently controllable while monitors/Host headphones are tied together.

### 1.2 Front panel starting positions (baseline)

| Control | Starting point | Notes |
| --- | ---: | --- |
| Host Gain | ~12 o’clock | Aim for solid level without clipping |
| Host 48V | On (if condenser) | Off for dynamic/ribbon |
| Host Enhance | Off | Do the full chain in Ardour |
| Host Auto Gain | Off | Manual, repeatable gain staging |
| Host Volume knob | 0 / very low | Keep monitors quiet during voice work |
| Guest Volume knob | comfortable | **Primary monitoring level** |

---

## 2) Linux Driver / Control Layer (ALSA)

### 2.1 Tools

- `alsa-scarlett-gui` (ALSA Scarlett Control Panel) controls the Vocaster’s internal routing/mixer.
- Ardour handles recording, processing, buses, and monitoring.

### 2.2 Channel naming & verification (don’t guess)

In `alsa-scarlett-gui`, you’ll see numbered labels for **hardware inputs**, **hardware outputs**, **PCM inputs** (to the computer), and **PCM outputs** (from the computer). The numbering is driver-facing and can feel non-obvious when you map it back to “Aux vs headphones vs monitors”.

For SG9 Studio, you already have a clear *functional* model:

- **Two stereo output destinations**
  - **Destination A:** Studio monitors + Host headphones (shared feed/controls)
  - **Destination B:** Guest headphones (independent; primary monitoring)
- **Two loopbacks**
  - Loopback 1 = computer audio/music capture
  - Loopback 2 = remote guest/call capture

Rather than relying on label assumptions, confirm mapping once on your machine.

**Verification checklist (recommended):**

1. Open `alsa-scarlett-gui` → **Levels**.
2. **Verify Aux input:** plug a phone into Aux and play audio; note which **Hardware Input** meters move.
3. **Verify output destination A vs B:**
   - Send audio only to **Playback 1–2** (e.g., in Ardour by routing a test tone directly to outputs 1–2) and confirm it appears on **monitors/Host headphones**.
   - Send audio only to **Playback 3–4** and confirm it appears on **Guest headphones**.
4. Lock the routing and treat the mapping as stable; only change it intentionally.

Once this is confirmed, the rest of this document becomes a mechanical setup.

---

## 2.5) Initial Studio Setup (First-Time Configuration)

This section walks through the complete first-time setup of the SG9 Studio, from hardware connections to a fully configured Ardour session ready for broadcast work.

### 2.5.1 Prerequisites & Installation

Before starting, ensure you have:

**Hardware:**
- Focusrite Vocaster Two connected via USB
- Korg nanoKONTROL Studio (USB cable)
- Novation Launchpad Pro Mk2 (USB cable)
- Host microphone (XLR, condenser recommended)
- Studio monitors or headphones connected to Vocaster outputs

**Software (Linux):**
```bash
# Check ALSA Scarlett support
alsa-scarlett-gui --version

# Install if needed (Arch/Manjaro)
sudo pacman -S alsa-scarlett-gui

# Ubuntu/Debian
sudo apt install alsa-scarlett-gui

# Check Ardour 8 installation
ardour8 --version

# Install LSP Plugins (LV2)
# NixOS (declarative - add to configuration.nix)
environment.systemPackages = with pkgs; [
  lsp-plugins
  calf
  tap-plugins
  zam-plugins
  x42-plugins  # MIDI utilities
];

# NixOS (imperative)
nix-env -iA nixos.lsp-plugins nixos.calf nixos.tap-plugins nixos.zam-plugins nixos.x42-plugins

# Arch/Manjaro
sudo pacman -S lsp-plugins calf tap-plugins zam-plugins x42-plugins

# Ubuntu/Debian
sudo apt install lsp-plugins-lv2 calf-plugins tap-plugins zam-plugins x42-plugins

# Verify plugin installation
ls /usr/lib/lv2/ | grep -E '(lsp|calf|zam)'
ls /usr/lib/ladspa/ | grep -i tap
```

**MIDI Controller Permissions:**
```bash
# Check USB MIDI devices are detected
aconnect -l

# You should see entries like:
# - nanoKONTROL Studio
# - Launchpad Pro MK2

# Add user to audio group if not already
sudo usermod -a -G audio $USER
# Log out and back in for changes to take effect
```

### 2.5.2 ALSA Scarlett Routing Configuration (From Scratch)

This section configures the Vocaster Two's internal routing and mixer **from the "Clear" preset** (factory reset state). The alsa-scarlett-gui provides complete control over the Vocaster's routing matrix and internal mixer—equivalent or superior to Focusrite's proprietary software.

**What is alsa-scarlett-gui?**
- GTK4-based GUI for Linux kernel Focusrite USB drivers
- Full control over routing, mixer, phantom power, gain, and DSP features
- Settings persist in hardware (survives disconnect/reconnect)
- Repository: https://github.com/geoffreybennett/alsa-scarlett-gui

**Critical Concepts:**
- **PC_HW**: Physical hardware inputs/outputs (XLR jacks, headphone outs, etc.)
- **PC_PCM**: USB audio channels (what Ardour sees as capture/playback)
- **PC_MIX**: Internal mixer inputs/outputs (for creating custom monitor mixes)
- **PC_DSP**: DSP-processed signals (Auto Gain, Enhance, Air mode applied)
- **Sinks can only connect to ONE source** (no mixing at routing stage)
- **Sources can connect to MULTIPLE sinks** (split signals to multiple destinations)

---

#### **Step 1: System Preparation**

**Disable ALSA state restoration** (prevents conflicts with alsa-scarlett-gui):
```bash
sudo systemctl mask alsa-state alsa-restore
sudo systemctl stop alsa-state alsa-restore
sudo rm -f /var/lib/alsa/asound.state
```

**Launch alsa-scarlett-gui:**
```bash
alsa-scarlett-gui
```

**Verify device detection:**
- Window title should show: **"Vocaster Two"**
- If not detected, check USB connection and kernel driver:
```bash
lsusb | grep -i focusrite
# Should show: "Focusrite-Novation Vocaster Two"

arecord -l | grep -i vocaster
# Should show card number and device info
```

---

#### **Step 2: Load "Clear" Preset (Factory Reset)**

1. In alsa-scarlett-gui, go to **View → Startup**
2. Click **Reset Configuration**
3. Confirm the reset—this loads the "Clear" preset
4. **Result:** All routing sinks set to "Off" (source ID 0), blank routing matrix

**Alternative:** Manually select **Presets → Clear** from the menu (if available)

**What "Clear" does:**
- Disconnects ALL routing (every sink → "Off")
- Resets mixer levels to -127 dB (muted)
- Clears phantom power settings
- Returns to known blank state

**Confirm Clear State:**
- Go to **View → Routing** (Ctrl+R)
- All routing boxes should show **"Off"** or be empty
- No audio will flow anywhere until you configure routing

---

#### **Step 3: Configure Routing Matrix**

Open **View → Routing** (Ctrl+R). You'll see a matrix with sources (left) and sinks (right).

**3A. Route Microphones to Ardour (PCM Inputs)**

Drag-and-drop or click to connect:

| Source (Left Panel) | → | Sink (Right Panel) | Purpose |
| --- | --- | --- | --- |
| **Analogue 1** | → | **PCM 01** | Host mic (hardware input) → Ardour Track 1 |
| **Analogue 2** | → | **PCM 05** | Guest mic (hardware input) → Ardour Track 5 |

**Note:** We use Analogue 1/2 (raw mic signals) instead of DSP 1/2 to preserve flexibility. Apply processing in Ardour, not in hardware.

**3B. Route Ardour Outputs to Mixer Inputs**

| Source | → | Sink | Purpose |
| --- | --- | --- | --- |
| **PCM 01** | → | **Mixer A 01** | Ardour output L → Mixer input 1 |
| **PCM 02** | → | **Mixer A 02** | Ardour output R → Mixer input 2 |

**3C. Route Mixer Outputs to Headphones/Monitors**

| Source | → | Sink | Purpose |
| --- | --- | --- | --- |
| **Mixer A 01** | → | **Analogue 1** | Monitor Left (speakers) |
| **Mixer A 02** | → | **Analogue 2** | Monitor Right (speakers) |
| **Mixer B 01** | → | **Analogue 3** | Host Headphones Left |
| **Mixer B 02** | → | **Analogue 4** | Host Headphones Right |
| **Mixer C 01** | → | **Analogue 5** | Guest Headphones Left |
| **Mixer C 02** | → | **Analogue 6** | Guest Headphones Right |

**Vocaster Two Output Mapping:**
- **Analogue 1/2**: Monitor outputs (rear TRS jacks)
- **Analogue 3/4**: Headphone Output 1 (Host, front jack)
- **Analogue 5/6**: Headphone Output 2 (Guest, front jack)

**3D. Setup Loopback for Music/Jingles (Optional but Recommended)**

If you want to record computer audio (music from browser, jingles from external apps):

| Source | → | Sink | Purpose |
| --- | --- | --- | --- |
| **PCM 03** | → | **Mixer D 01** | Music source L → Loopback mixer |
| **PCM 04** | → | **Mixer D 02** | Music source R → Loopback mixer |
| **Mixer D 01** | → | **PCM 03** | Loopback L → Ardour Capture 3 |
| **Mixer D 02** | → | **PCM 04** | Loopback R → Ardour Capture 4 |

**How to use loopback:**
- Point external music player (Spotify, browser) to output to **Vocaster Playback 3+4**
- Ardour will record this on Track "Music (Loopback)"
- Prevents re-recording already-imported music (use for live streaming/recording)

**3E. Setup Mix-Minus for Remote Guests (Optional, Advanced)**

For remote calls (Zoom, Skype), create a mix-minus feed (guest hears you, NOT themselves):

| Source | → | Sink | Purpose |
| --- | --- | --- | --- |
| **Analogue 1** | → | **Mixer E 01** | Host mic → Mix-Minus L |
| **Analogue 2** | → | **Mixer E 02** | Guest mic (for routing, NOT for feedback) |
| **PCM 01** | → | **Mixer E 01** | Ardour music/jingles → Mix-Minus L |
| **PCM 02** | → | **Mixer E 02** | Ardour music/jingles → Mix-Minus R |
| **Mixer E 01** | → | **PCM 07** | Mix-Minus L → VoIP software input |
| **Mixer E 02** | → | **PCM 08** | Mix-Minus R → VoIP software input |

**Then in Mixer (Step 4):** Mute Guest mic in Mix E to create true mix-minus.

---

#### **Step 4: Configure Mixer Levels**

Open **View → Mixer** (Ctrl+M). You'll see Mix A, B, C, D, E, etc. with input faders.

**4A. Mix A (Monitor Speakers)**

This mix feeds your studio monitors.

| Input | Level | Purpose |
| --- | ---: | --- |
| **Mixer A 01 (Ardour L)** | **0 dB** | Hear Ardour's processed output |
| **Mixer A 02 (Ardour R)** | **0 dB** | Hear Ardour's processed output |
| All other inputs | **-127 dB** (muted) | Clean monitoring, no bleed |

**Why mute mics here?** Monitoring through Ardour (with processing) prevents "double monitoring" and gives you zero-latency processed sound.

**4B. Mix B (Host Headphones)**

Same as Mix A—you and monitors hear the same thing.

| Input | Level | Purpose |
| --- | ---: | --- |
| **Mixer B 01 (Ardour L)** | **0 dB** | Hear Ardour output |
| **Mixer B 02 (Ardour R)** | **0 dB** | Hear Ardour output |
| All other inputs | **-127 dB** (muted) | Clean monitoring |

**4C. Mix C (Guest Headphones - Independent Mix)**

Guest can have a different balance (e.g., more of their own voice, less music).

**Default: Same as host**
| Input | Level | Purpose |
| --- | ---: | --- |
| **Mixer C 01 (Ardour L)** | **0 dB** | Hear Ardour output |
| **Mixer C 02 (Ardour R)** | **0 dB** | Hear Ardour output |
| All other inputs | **-127 dB** (muted) | Clean monitoring |

**Advanced: Guest wants more of themselves**
| Input | Level | Purpose |
| --- | ---: | --- |
| **Analogue 2 (Guest mic)** | **-12 dB** | Direct monitoring of guest mic |
| **Mixer C 01 (Ardour L)** | **-3 dB** | Ardour output (reduced) |
| **Mixer C 02 (Ardour R)** | **-3 dB** | Ardour output (reduced) |

**Caution:** Direct monitoring + Ardour monitoring = phase issues. Use sparingly.

**4D. Mix D (Loopback Mixer)**

If using loopback for music capture:

| Input | Level | Purpose |
| --- | ---: | --- |
| **Mixer D 01 (PCM 3)** | **0 dB** | Pass music through |
| **Mixer D 02 (PCM 4)** | **0 dB** | Pass music through |
| All other inputs | **-127 dB** (muted) | Clean loopback |

**4E. Mix E (Mix-Minus for VoIP)**

**Critical for remote calls—guest hears you, NOT themselves:**

| Input | Level | Purpose |
| --- | ---: | --- |
| **Analogue 1 (Host mic)** | **0 dB** | Remote hears you |
| **Analogue 2 (Guest mic)** | **-127 dB** **(MUTED)** | **Prevents echo/feedback** |
| **Mixer E 01 (Ardour L)** | **-6 dB** | Remote hears music/jingles |
| **Mixer E 02 (Ardour R)** | **-6 dB** | Remote hears music/jingles |
| All other inputs | **-127 dB** (muted) | Clean mix-minus |

**VoIP Software Setup:**
- **Input Device:** Vocaster Capture 7+8 (Mix E output)
- **Output Device:** Vocaster Playback 5+6 (or route to Ardour Track 7)

**This creates professional mix-minus:**
- Remote guest hears: Host mic + music
- Remote guest does NOT hear: Their own voice (prevents echo)

---

#### **Step 5: Input Controls (Gain, Phantom Power, DSP)**

Open **View → Levels** (Ctrl+L).

**5A. Set Input Gain**

**Method 1: Auto Gain (Easiest)**
1. Click **Auto Gain** button for Input 1 (Host)
2. Speak at normal volume for 5 seconds
3. Vocaster sets optimal gain automatically
4. Repeat for Input 2 (Guest) if needed

**Method 2: Manual Gain**
1. Drag **Gain** slider for Input 1
2. Target: **-18 to -12 dBFS** peak during normal speech
3. Use Ardour's input meter (or alsa-scarlett-gui's meters) to verify

**5B. Phantom Power (If Using Condenser Mics)**

1. Toggle **48V** button for Input 1 and/or Input 2
2. **Warning:** Turn phantom power OFF for dynamic mics (SM7B, RE20, etc.)
3. **Recommendation:** Use dynamic mics for broadcast (no phantom power needed)

**5C. Enhance Presets (Optional)**

Vocaster has built-in voice processing presets:
- **Off**: No processing (recommended for Ardour workflow)
- **Warm**: Adds low-end warmth
- **Bright**: Boosts presence
- **Radio**: Broadcast-style compression/EQ

**SG9 Studio Recommendation:** Keep Enhance **OFF**—apply all processing in Ardour for maximum control and consistency.

---

#### **Step 6: Save Configuration**

**Auto-Save:**
alsa-scarlett-gui automatically saves your configuration to:
```bash
~/.config/alsa-scarlett-gui/Vocaster_Two.state
```

**Manual Save:**
1. **File → Save Configuration**
2. Choose a descriptive filename: `sg9-studio-vocaster.state`
3. Store in your project folder:
```bash
mv ~/.config/alsa-scarlett-gui/Vocaster_Two.state ~/sg9-studio/vocaster-config.state
```

**Backup Configuration:**
```bash
cp -r ~/.config/alsa-scarlett-gui/ ~/sg9-studio-backup/alsa-scarlett-backup-$(date +%Y%m%d)/
```

**Load Configuration Later:**
1. **File → Load Configuration**
2. Select your `.state` file
3. Routing and mixer settings restore instantly

**Settings Persistence:**
Vocaster Two stores settings in hardware—your configuration survives:
- USB disconnect/reconnect
- Computer reboots
- Switching between computers (routing persists in device)

---

#### **Step 7: Verification & Testing**

**7A. Test Microphone Routing**
```bash
# In Ardour, arm Track 1 (Host Mic)
# Speak into mic
# Verify meters move on Track 1 input
# Repeat for Track 5 (Guest Mic)
```

**7B. Test Monitoring Path**
```bash
# In Ardour, enable monitoring on Track 1
# Speak into mic
# Verify you hear processed audio in headphones/monitors
# Latency should be minimal (<10ms with 128 buffer)
```

**7C. Test Loopback (If Configured)**
```bash
# Play music in external app (set output to Vocaster Playback 3+4)
# In Ardour, arm Track "Music (Loopback)"
# Verify meters move, music records
```

**7D. Test Mix-Minus (If Configured)**
```bash
# Open Zoom/Skype, set input to Vocaster Capture 7+8
# Start test call
# Speak into Host mic—remote should hear you
# Speak into Guest mic—remote should NOT hear (muted in Mix E)
```

**Common Issues:**
- **No audio in Ardour:** Check routing (Analogue 1 → PCM 01)
- **Can't hear monitoring:** Check Mixer A levels, verify Ardour monitoring enabled
- **Echo in VoIP:** Verify Guest mic muted in Mix E
- **Loopback not working:** Confirm PCM 3/4 → Mixer D → PCM 3/4 routing

---

#### **Step 8: Disable Focusrite Control 2 (If Previously Used)**

If you previously used Focusrite's proprietary software:
1. Uninstall Focusrite Control 2 (optional, but prevents conflicts)
2. **Reset to Factory Defaults** in alsa-scarlett-gui before first use
3. Do NOT mix alsa-scarlett-gui and Focusrite Control 2 on same system

**Why alsa-scarlett-gui is better:**
- Full routing matrix control (Focusrite Control has limited routing)
- Native Linux integration (no proprietary drivers)
- Session recall (save/load `.state` files)
- Open source, actively maintained

---

#### **Quick Reference: SG9 Studio Routing Summary**

**Inputs to Ardour:**
- Analogue 1 → PCM 01 (Host Mic → Track 1)
- Analogue 2 → PCM 05 (Guest Mic → Track 5)
- Mixer D → PCM 03/04 (Loopback for music)
- Mixer E → PCM 07/08 (Mix-Minus for VoIP)

**Ardour Outputs to Monitoring:**
- PCM 01/02 → Mixer A → Analogue 1/2 (Monitors)
- PCM 01/02 → Mixer B → Analogue 3/4 (Host Headphones)
- PCM 01/02 → Mixer C → Analogue 5/6 (Guest Headphones)

**Mixer Levels:**
- Mix A/B/C: Ardour L/R at 0 dB, all else muted
- Mix D: PCM 3/4 at 0 dB (loopback pass-through)
- Mix E: Host mic 0 dB, Guest mic **muted**, Ardour -6 dB (mix-minus)

**Input Gain:**
- Use Auto Gain or manual to -18 to -12 dBFS peaks
- Phantom Power OFF (for dynamic mics)
- Enhance OFF (process in Ardour instead)

**Configuration Files:**
- Auto-saved: `~/.config/alsa-scarlett-gui/Vocaster_Two.state`
- Backup: `~/sg9-studio/vocaster-config.state`

### 2.5.3 MIDI Controller USB Setup

**Korg nanoKONTROL Studio:**
```bash
# Connect via USB
# Check detection
aconnect -l | grep -i nano

# Should show:
# client XX: 'nanoKONTROL Studio' [type=kernel,card=X]
#     0 'nanoKONTROL Studio MIDI 1'
```

The nanoKONTROL Studio operates in multiple modes. For DAW control:
1. Hold **CYCLE** button while powering on to enter DAW mode
2. Or use Korg Kontrol Editor (Windows/Mac) to set default mode
3. For SG9 Studio, we'll use **Generic MIDI** mode with custom mapping

**Novation Launchpad Pro Mk2:**
```bash
# Connect via USB  
# Check detection
aconnect -l | grep -i launchpad

# Should show:
# client XX: 'Launchpad Pro MK2' [type=kernel,card=X]
#     0 'Launchpad Pro MK2 MIDI 1'
#     1 'Launchpad Pro MK2 MIDI 2'
#     2 'Launchpad Pro MK2 MIDI 3'
```

The Launchpad Pro Mk2 has three MIDI ports:
- **Port 1 (Standalone):** For standalone sequencer mode
- **Port 2 (Live):** For Ableton Live communication
- **Port 3 (Programmer):** For custom MIDI programming

For Ardour, we'll use **Port 3 (Programmer)** for full control and LED feedback.

Programming the Launchpad:
1. Download **Novation Components** from novationmusic.com
2. Create a custom layout for SG9 Studio (clip launching + transport)
3. Upload to the Launchpad's user mode slots
4. Alternatively, use SysEx commands in Ardour for runtime control

**Verify MIDI Routing:**
```bash
# List all ALSA MIDI connections
aconnect -l

# Example connection for Ardour
# (Ardour will auto-detect when opened, but manual connection:)
aconnect <nanoKONTROL client>:<port> <Ardour client>:<port>
```

### 2.5.4 Ardour 8 Session Creation

**Step 1: Create New Session**
1. Launch Ardour 8
2. **Session → New Session**
3. Session name: `SG9-Studio-Template`
4. Sample rate: **48000 Hz** (broadcast standard)
5. Create session from: **Empty Template**

**Step 2: Audio/MIDI Setup**
1. **Edit → Preferences → Audio**
   - Audio System: **ALSA**
   - Device: **Vocaster Two**
   - Sample Rate: **48000 Hz**
   - Buffer Size: **128 samples** (start here; increase to 256/512 if CPU issues)
   - Periods: **2**

2. **Edit → Preferences → MIDI**
   - Enable **Generic MIDI** support
   - MIDI Port Setup:
     - Add **nanoKONTROL Studio** (all ports enabled)
     - Add **Launchpad Pro MK2 Port 3** (Programmer mode)

**Step 3: Plugin Verification**
1. **Window → Plugin Manager**
2. Search for `LSP` - verify you see:
   - LSP Parametric Equalizer x8 Mono/Stereo *(SG9 uses 6-7 bands)*
   - LSP Compressor Mono/Stereo *(with sidechain for de-essing)*
   - LSP Gate Mono
   - LSP Limiter Mono/Stereo
   - LSP Multiband Compressor x4 Mono/Stereo
3. Search for `Calf` - verify you see:
   - Calf Compressor
   - Calf Sidechain Compressor
   - Calf Deesser *(primary de-essing solution)*
   - Calf Multiband Compressor
4. Search for `TAP` - verify you see (LADSPA only):
   - TAP DeEsser *(legacy alternative)*
   - TAP Dynamics Mono/Stereo
5. Search for `Zam` - verify you see:
   - ZamComp/ZamCompX2
   - ZamGate/ZamGateX2
   - ZamMultiComp/ZamMultiCompX2

**Note:** LSP does not include a standalone de-esser plugin. Use Calf Deesser or configure LSP Compressor with sidechain filtering for de-essing.

If plugins are missing, revisit installation step.

**Step 4: Latency Compensation Setup**
1. **Edit → Preferences → Plugins**
   - Enable **Automatic plugin delay compensation**
   - Silence threshold: **-70 dB**
2. **Edit → Preferences → Audio**
   - Enable **Silence plugins during recording**
   - This prevents monitoring latency from plugin chains

**Step 5: Color Scheme Setup**

Establish consistent color-coding across Ardour tracks and Launchpad LEDs:

| Track Type | Ardour Color (Hex) | Launchpad RGB | Description |
| --- | --- | ---: | --- |
| Voice/Mic | `#FF4444` Red | 127, 0, 0 | Host/Guest mic tracks |
| Remote/External | `#FF8800` Orange | 127, 64, 0 | Remote guest, Aux, BT |
| Music | `#4488FF` Blue | 0, 64, 127 | Music beds, loopback |
| Production | `#AA44FF` Purple | 96, 0, 127 | Jingles, SFX, stingers |
| Content | `#44FF88` Green | 0, 127, 64 | Ads, IDs, PSAs |
| Buses | `#FFFF44` Yellow | 127, 127, 0 | Group buses |
| VCA | `#FFFFFF` White | 127, 127, 127 | VCA masters |
| Master | `#FF0000` Bright Red | 127, 0, 0 | Master bus |

To set track colors in Ardour:
1. Right-click track header
2. **Color** → choose from palette or enter hex code

**Step 6: Save Initial Session**
- **Session → Save** (Ctrl+S)
- This becomes your base template

---

## 3) Vocaster USB Channels (Conceptual Map)

### 3.1 Captures (interface → computer)

These are Ardour’s **input channels**.

| Capture channel(s) | Intended source | Use |
| --- | --- | --- |
| Capture 1 | Host mic (DSP) | Primary voice input |
| Capture 2 | Guest mic (DSP) | Guest mic (optional) |
| Capture 3–4 | **Aux input (stereo)** | Phone/tablet/portable audio |
| Capture 5–6 | Bluetooth (stereo) | Backup music / phone audio |
| Capture 7 | Host mic (raw) | Safety backup |
| Capture 9 | Guest mic (raw) | Safety backup |
| Capture 11–12 | Loopback 1 (stereo) | Computer audio/music |
| Capture 13–14 | Loopback 2 (stereo) | Remote guest (Zoom/Skype return) |

**Key change vs factory assumptions:** Capture 3–4 is repurposed for **Aux**. Remote call audio is captured via **Loopback 2 (Capture 13–14)**.

### 3.2 Playbacks (computer → interface)

These are Ardour’s **output channels**.

| Playback channel(s) | Intended destination |
| --- | --- |
| Playback 1–2 | Studio monitors **and** Host headphones (shared destination) |
| Playback 3–4 | Guest headphones (independent, primary monitoring) |

(Exact hardware mapping must be verified in `alsa-scarlett-gui` on your system.)

---

## 4) Vocaster Two Routing Philosophy

**Note:** Full step-by-step routing configuration is in Section 2.5.2. This section explains the conceptual foundation of WHY the routing is designed this way.

### 4.1 Core Routing Principles

The Vocaster Two is a sophisticated routing matrix. Via alsa-scarlett-gui, you control:

1. **Hardware I/O → USB Audio**: Physical jacks → Ardour capture channels
2. **USB Audio → Internal Mixer**: Ardour output → Monitor mixes
3. **Internal Mixer → Hardware I/O**: Monitor mixes → Headphones/speakers

**Key Principle:**
> **Route raw mic signals to Ardour. Apply ALL processing in software. Use hardware mixer ONLY for monitoring.**

**Benefits:**
- Maximum flexibility (change processing after recording)
- Consistent sound (all processing visible in Ardour)
- Professional workflow (industry standard DAW-centric approach)

### 4.2 Monitor Through Ardour (WYSIWYG)

- Route the *sources you want to record* to dedicated **PCM Inputs**.
- Route Ardour outputs to the right **hardware outputs** (guest headphones for daily monitoring).
- Create two loopbacks:
  - **Loopback 1** = general computer audio/music capture
  - **Loopback 2** = remote guest / video call capture
- Implement **Mix A** as a **mix-minus** feed for the remote call.

### 4.1.1 Reference routing map (what you’re aiming for)

The concept is easiest to keep stable if you treat routing as three layers:

1. **Recordable sources → PCM Inputs** (so Ardour can record them)
2. **Loopback buses → PCM Inputs** (so Ardour can record PC audio + call returns)
3. **Ardour outputs → output destinations**

Recommended PCM Inputs to Ardour (matches the concept):

- DSP Host → PCM Input 1 (Ardour Capture 1)
- DSP Guest → PCM Input 2 (Ardour Capture 2)
- Aux L/R → PCM Input 3/4 (Ardour Capture 3–4)
- Bluetooth L/R → PCM Input 5/6 (Ardour Capture 5–6)
- Loopback 1 L/R → PCM Input 11/12 (Ardour Capture 11–12)
- Loopback 2 L/R → PCM Input 13/14 (Ardour Capture 13–14)

If your saved `alsa-scarlett-gui` configuration already matches this, you generally do not need to touch it day-to-day.

### 4.2 Mix A = N-1 (remote guest send)

**Goal:** Remote guest hears you (+ optional studio sources), but **never hears themselves**.

Recommended Mix A levels (starting points):

| Source | Mix A | Why |
| --- | ---: | --- |
| DSP 1 (Host mic) | -6 dB | Remote hears host |
| DSP 2 (Guest mic) | -6 dB | Remote hears in-studio guest |
| Aux (stereo) | -12 dB | Optional: let remote hear phone/tablet |
| Bluetooth | muted | Usually not needed |
| **PCM / loopback returns** | **muted** | Critical: prevents echo/feedback |

### 4.3 Mix C = daily monitoring (guest headphones)

**Goal:** Hear Ardour’s processed output + important external sources, but avoid hardware mic monitoring (to avoid “double monitoring” and comb filtering).

Recommended Mix C:

| Source | Mix C | Why |
| --- | ---: | --- |
| DSP mic monitoring | muted | Monitor through Ardour instead |
| Aux | 0 dB | Hear phone/tablet |
| Bluetooth | 0 dB (optional) | Hear BT source |
| Loopback 1/2 | 0 dB | Hear PC audio + remote guest |

---

## 5) Ardour Session Template

### 5.1 Session defaults

- Sample rate: 48 kHz (broadcast friendly)
- Bit depth: 24-bit
- Buffer: start at 128–256 samples for comfortable monitoring; increase if CPU overload occurs

Latency notes:

- If you monitor through Ardour (recommended here), lower buffer = lower latency but higher CPU risk.
- If you hear crackles/dropouts, step buffer up (256 → 512) before changing anything else.
- Keep “double monitoring” out of the system: monitor either through hardware *or* through Ardour, not both.

Practical defaults:

- For live monitoring through Ardour: start at **128**.
- For heavy sessions or if you don’t need tight monitoring: **256–512**.

### 5.2 Track list (18 tracks)

| # | Track name | Type | Input |
| ---: | --- | --- | --- |
| 1 | Host Mic (DSP) | Mono | Capture 1 |
| 2 | Host Mic (Raw) | Mono | Capture 7 |
| 3 | Guest Mic (DSP) | Mono | Capture 2 |
| 4 | Guest Mic (Raw) | Mono | Capture 9 |
| 5 | Aux Input | Stereo | Capture 3–4 |
| 6 | Bluetooth Audio | Stereo | Capture 5–6 |
| 7 | Remote Guest (Zoom) | Stereo | Capture 13–14 |
| 8 | Music (Loopback 1) | Stereo | Capture 11–12 |
| 9 | Music Bed A | Stereo | Files |
| 10 | Music Bed B | Stereo | Files |
| 11 | Jingles – Intro | Stereo | Files |
| 12 | Jingles – Outro | Stereo | Files |
| 13 | Jingles – Bumpers | Stereo | Files |
| 14 | Sound FX | Stereo | Files |
| 15 | Stingers | Stereo | Files |
| 16 | Sponsor Ads | Stereo | Files |
| 17 | Station IDs | Stereo | Files |
| 18 | PSA / Promos | Stereo | Files |

**Operational note:** For live work, you typically **arm + monitor** only the inputs you actively need (Host always; remote guest when on a call; Aux when a phone/tablet is connected; BT when used).

### 5.3 Bus architecture

| Bus | Type | Receives from | Sends to |
| --- | --- | --- | --- |
| Voice Bus | Stereo | Tracks 1–4 | Mixbus |
| External Bus | Stereo | Tracks 5–7 | Mixbus |
| Music Bus | Stereo | Tracks 8–10 | Mixbus |
| Production Bus | Stereo | Tracks 11–15 | Mixbus |
| Content Bus | Stereo | Tracks 16–18 | Mixbus |
| Talkback Bus | Mono | Host send | Vocaster Playback 1–2 only |
| Mixbus | Stereo | All group buses | Master Bus |
| Master Bus | Stereo | Mixbus | Vocaster Playback 3–4 |

#### Outputs in Ardour (how to use the two destinations)

Because SG9 has two stereo destinations, it helps to treat outputs like this:

- **Primary monitoring:** route the **Master Bus** to **Vocaster Playback 3–4** (Guest headphones).
- **Optional speakers / Host headphones mirror:** create an additional post-fader send (or route Mixbus/Master) to **Vocaster Playback 1–2**.

This gives you a reliable workflow: you always hear the “truth” on Guest headphones, while speakers can be enabled only when desired.

### 5.4 Ardour 8-Specific Features & Workflow Enhancements

#### 5.4.1 Folder Tracks & Organization

Ardour 8 supports **folder tracks** for hierarchical organization.

**How to create:** Right-click in track list → **Add Track/Bus/VCA** → Select **Folder** → Name it → Drag existing tracks into folder.

**Benefits:** Cleaner mixer view, easier navigation, logical grouping matches workflow.

#### 5.4.2 Track Color-Coding

Apply consistent colors matching Launchpad LED colors (see Sections 2.5.4 and 5.5).

**How to:** Right-click track header → **Color** → Enter hex code.

#### 5.4.3 Plugin Delay Compensation

Ardour 8 automatically compensates for plugin processing latency.

**Enable:** **Edit → Preferences → Plugins** → ✅ **Automatic plugin delay compensation**

#### 5.4.4 Session Snapshots Workflow

Save multiple session versions without duplicating audio files.

**Use cases:** Different show formats, experiment safely, archive different mixes.

**How to:** **Session → Snapshot (& keep working on current version)** → Name descriptively.

#### 5.4.5 Export Presets

Save export configurations for repeatable deliverables.

**SG9 Presets:** Podcast Master (WAV, -16 LUFS), Broadcast Master (WAV, -23 LUFS), Multitrack Archive (stems), Quick Review (MP3).

**How to save:** **Session → Export** → Configure → **Save Preset**.

#### 5.4.6 Clip Launching Setup

Ardour 8 supports clip launching for live triggering of jingles/SFX.

**Enable:** **Window → Clips** (`Alt+C`)

**Load clips:** Drag audio files into clip slots on Tracks 11–18.

**Integrate with Launchpad:** Map pads via MIDI Learn (Section 5.5.6).

### 5.5 Talkback routing (off-air)

Talkback is only relevant when you have an in-studio guest wearing **Host headphones**.

Recommended approach:

1. Create a **Talkback Bus** that is **not** routed to Master.
2. Feed it from the Host mic with a pre-fader send (so talkback level is independent).
3. Route the Talkback Bus output to **Vocaster Playback 1–2** (Destination A: Host headphones + monitors).
4. Operational safety: keep monitors muted/at 0 while using talkback.

If you ever decide the guest will wear Guest headphones instead, re-route talkback accordingly.

### 5.4 VCA masters

| VCA | Name | Controls |
| ---: | --- | --- |
| 1 | All Voices | Voice Bus + External Bus |
| 2 | All Music | Music Bus + Production Bus |
| 3 | All Content | Content Bus |
| 4 | Master Fader | Mixbus + Master Bus |

---

## 5.5) Hardware Controller Integration

SG9 Studio uses two USB MIDI controllers for tactile, hands-on control during live production:
- **Korg nanoKONTROL Studio:** 8 faders + 8 knobs + transport controls + jog wheel (mixing and navigation)
- **Novation Launchpad Pro Mk2:** 8x8 RGB pad grid (clip launching, transport, scene control with visual feedback)

Both controllers integrate with Ardour via Generic MIDI protocol and custom MIDI bindings.

### 5.5.1 Korg nanoKONTROL Studio Overview

**Hardware specifications:**
- **8 motorized faders** (0–127 MIDI CC values)
- **8 rotary knobs** (endless encoders or absolute)
- **24 buttons** (8x Solo/Mute/Rec, plus Set/Track buttons)
- **Transport controls** (Play, Stop, Record, Cycle, Rewind, Fast Forward)
- **Jog wheel** (timeline scrubbing, parameter adjustment)
- **Scene button** (mode switching)
- **USB MIDI** interface (class-compliant, no drivers needed on Linux)
- **Bluetooth wireless** (not used in SG9 Studio—USB for zero latency)

**Default MIDI CC assignments (DAW mode):**

| Control | MIDI CC# | Range | Purpose in SG9 Studio |
| --- | ---: | --- | --- |
| Fader 1 | CC 0 | 0–127 | VCA 1 (All Voices) |
| Fader 2 | CC 1 | 0–127 | VCA 2 (All Music) |
| Fader 3 | CC 2 | 0–127 | VCA 3 (All Content) |
| Fader 4 | CC 3 | 0–127 | VCA 4 (Master Fader) |
| Fader 5 | CC 4 | 0–127 | Voice Bus |
| Fader 6 | CC 5 | 0–127 | Music Bus |
| Fader 7 | CC 6 | 0–127 | Production Bus |
| Fader 8 | CC 7 | 0–127 | Content Bus |
| Knob 1 | CC 16 | 0–127 | Track 1 Send (Reverb/Aux) |
| Knob 2 | CC 17 | 0–127 | Track 5 Send |
| Knob 3 | CC 18 | 0–127 | Track 7 Send |
| Knob 4 | CC 19 | 0–127 | Music Bus Send |
| Knob 5 | CC 20 | 0–127 | Reserved |
| Knob 6 | CC 21 | 0–127 | Reserved |
| Knob 7 | CC 22 | 0–127 | Reserved |
| Knob 8 | CC 23 | 0–127 | Reserved |
| Solo 1–8 | CC 32–39 | 0/127 | Solo Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Mute 1–8 | CC 48–55 | 0/127 | Mute Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Rec 1–8 | CC 64–71 | 0/127 | Arm Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Play | Note 41 | On/Off | Transport Play |
| Stop | Note 42 | On/Off | Transport Stop |
| Record | Note 45 | On/Off | Transport Record |
| Cycle | Note 46 | On/Off | Loop Enable |
| Rewind | Note 43 | On/Off | Rewind (or jump to start) |
| Fast Forward | Note 44 | On/Off | Fast Forward (or jump to end) |
| Track < | Note 58 | On/Off | Bank down (shift control focus) |
| Track > | Note 59 | On/Off | Bank up (shift control focus) |
| Set | Note 60 | On/Off | Marker/loop set |
| Jog Wheel | CC 60 | Relative | Scrub timeline |

**Setup in Ardour:**
1. **Edit → Preferences → Control Surfaces**
2. Enable **Generic MIDI**
3. Click **Show Protocol Settings**
4. **MIDI Input Device:** Select `nanoKONTROL Studio MIDI 1`
5. **MIDI Output Device:** Select `nanoKONTROL Studio MIDI 1` (for LED feedback if supported)
6. **Binding File:** Browse to `~/sg9-studio/nanokontrol-studio-sg9.xml` (see below)

### 5.5.2 nanoKONTROL Studio MIDI Binding (Ardour XML)

Save this as `~/sg9-studio/nanokontrol-studio-sg9.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ArdourMIDIBindings version="1.0.0" name="Korg nanoKONTROL Studio (SG9)">
  
  <!-- VCA Faders (1-4) -->
  <Binding channel="1" ctl="0" uri="/route/vca/1/gain"/>
  <Binding channel="1" ctl="1" uri="/route/vca/2/gain"/>
  <Binding channel="1" ctl="2" uri="/route/vca/3/gain"/>
  <Binding channel="1" ctl="3" uri="/route/vca/4/gain"/>
  
  <!-- Bus Faders (5-8) -->
  <Binding channel="1" ctl="4" uri="/route/name/Voice Bus/gain"/>
  <Binding channel="1" ctl="5" uri="/route/name/Music Bus/gain"/>
  <Binding channel="1" ctl="6" uri="/route/name/Production Bus/gain"/>
  <Binding channel="1" ctl="7" uri="/route/name/Content Bus/gain"/>
  
  <!-- Knobs (Aux Sends) -->
  <Binding channel="1" ctl="16" uri="/route/send/1/1/gain"/>
  <Binding channel="1" ctl="17" uri="/route/send/5/1/gain"/>
  <Binding channel="1" ctl="18" uri="/route/send/7/1/gain"/>
  <Binding channel="1" ctl="19" uri="/route/name/Music Bus/send/1/gain"/>
  
  <!-- Solo buttons (tracks 1, 5, 7, 9, 11, 13, 15, 17) -->
  <Binding channel="1" ctl="32" uri="/route/solo/1"/>
  <Binding channel="1" ctl="33" uri="/route/solo/5"/>
  <Binding channel="1" ctl="34" uri="/route/solo/7"/>
  <Binding channel="1" ctl="35" uri="/route/solo/9"/>
  <Binding channel="1" ctl="36" uri="/route/solo/11"/>
  <Binding channel="1" ctl="37" uri="/route/solo/13"/>
  <Binding channel="1" ctl="38" uri="/route/solo/15"/>
  <Binding channel="1" ctl="39" uri="/route/solo/17"/>
  
  <!-- Mute buttons -->
  <Binding channel="1" ctl="48" uri="/route/mute/1"/>
  <Binding channel="1" ctl="49" uri="/route/mute/5"/>
  <Binding channel="1" ctl="50" uri="/route/mute/7"/>
  <Binding channel="1" ctl="51" uri="/route/mute/9"/>
  <Binding channel="1" ctl="52" uri="/route/mute/11"/>
  <Binding channel="1" ctl="53" uri="/route/mute/13"/>
  <Binding channel="1" ctl="54" uri="/route/mute/15"/>
  <Binding channel="1" ctl="55" uri="/route/mute/17"/>
  
  <!-- Rec Arm buttons -->
  <Binding channel="1" ctl="64" uri="/route/recenable/1"/>
  <Binding channel="1" ctl="65" uri="/route/recenable/5"/>
  <Binding channel="1" ctl="66" uri="/route/recenable/7"/>
  <Binding channel="1" ctl="67" uri="/route/recenable/9"/>
  <Binding channel="1" ctl="68" uri="/route/recenable/11"/>
  <Binding channel="1" ctl="69" uri="/route/recenable/13"/>
  <Binding channel="1" ctl="70" uri="/route/recenable/15"/>
  <Binding channel="1" ctl="71" uri="/route/recenable/17"/>
  
  <!-- Transport controls -->
  <Binding channel="1" note="41" function="transport-roll"/>
  <Binding channel="1" note="42" function="transport-stop"/>
  <Binding channel="1" note="45" function="transport-record"/>
  <Binding channel="1" note="46" function="loop-toggle"/>
  <Binding channel="1" note="43" function="transport-start"/>
  <Binding channel="1" note="44" function="transport-end"/>
  
  <!-- Jog wheel (scrub) -->
  <Binding channel="1" ctl="60" function="scroll-timeline"/>
  
</ArdourMIDIBindings>
```

**Notes:**
- Adjust `/route/name/` strings to match your exact Ardour track/bus names
- VCA URIs use `/route/vca/N/` where N is VCA number
- Solo/Mute/Rec Arm use `/route/solo/N`, `/route/mute/N`, `/route/recenable/N`
- Transport functions are global

### 5.5.3 Novation Launchpad Pro Mk2 Overview

**Hardware specifications:**
- **64 RGB velocity-sensitive pads** (8x8 grid)
- **8 scene launch buttons** (right side)
- **8 function buttons** (top row)
- **4 mode buttons** (bottom row: Note, Chord, Custom, Capture MIDI)
- **Setup button** (bottom left)
- **3 MIDI ports:**
  - **Port 1 (Standalone):** Internal sequencer
  - **Port 2 (Live):** Ableton Live integration
  - **Port 3 (Programmer):** Custom MIDI programming
- **RGB LED feedback** (per-pad color control via MIDI/SysEx)
- **USB MIDI** + **MIDI DIN** I/O
- **Programmable via Novation Components** (web-based editor)

**SG9 Studio Usage:**
- **Primary:** Clip launching for jingles, SFX, music beds, stingers, ads, etc.
- **Secondary:** Transport control (Play/Stop/Record) with LED feedback
- **Scene buttons:** Launch entire rows (e.g., all intro jingles, all SFX)

### 5.5.4 Launchpad Pro Mk2 Grid Layout (SG9 Studio)

**8x8 Pad Grid Assignment:**

| Row | Tracks/Clips | Color | Purpose |
| ---: | --- | --- | --- |
| 1 | Jingles – Intro (Track 11) | Purple | Intro jingles, show openers |
| 2 | Jingles – Outro (Track 12) | Purple | Outro jingles, closers |
| 3 | Jingles – Bumpers (Track 13) | Purple | Segment transitions |
| 4 | Sound FX (Track 14) | Green | Sound effects, ambiance |
| 5 | Stingers (Track 15) | Orange | Quick hits, punctuation |
| 6 | Sponsor Ads (Track 16) | Yellow | Pre-recorded sponsor spots |
| 7 | Station IDs (Track 17) | Cyan | Station identifiers, legal IDs |
| 8 | PSA / Promos (Track 18) | Blue | Public service, promos |

**Each row has 8 pads = 8 clip slots per track.**

**Scene Launch Buttons (Right Side):**
- **Scene 1:** Launch all Row 1 clips (Intro Jingles)
- **Scene 2:** Launch all Row 2 clips (Outro Jingles)
- **Scene 3–8:** Launch corresponding rows

**Top Function Buttons:**
- **Button 1:** Transport Play
- **Button 2:** Transport Stop
- **Button 3:** Transport Record
- **Button 4:** Loop Toggle
- **Button 5:** Session Save
- **Button 6:** Undo
- **Button 7:** Redo
- **Button 8:** (Reserved)

### 5.5.5 Launchpad Pro Mk2 LED Color Coding

Launchpad Pro Mk2 supports full RGB control. Colors must match Ardour track colors for consistency.

**RGB MIDI Velocity Mapping (Simplified):**

Launchpad Pro uses **MIDI velocity** to set colors in "Programmer mode." There are 128 pre-defined colors:

| Color Name | Velocity | RGB Approx | SG9 Use |
| --- | ---: | --- | --- |
| Red | 5 | 255, 0, 0 | Voice/Mic tracks |
| Orange | 9 | 255, 128, 0 | Remote/External tracks |
| Yellow | 13 | 255, 255, 0 | Sponsor Ads |
| Green | 21 | 0, 255, 0 | Sound FX |
| Cyan | 37 | 0, 255, 255 | Station IDs |
| Blue | 45 | 0, 0, 255 | PSA/Promos |
| Purple | 53 | 255, 0, 255 | Jingles/Production |
| White | 3 | 255, 255, 255 | VCA/Master |
| Off | 0 | 0, 0, 0 | Empty/inactive |

**Full RGB control via SysEx:**
```
F0 00 20 29 02 10 0B <pad_note> <red> <green> <blue> F7
```
- `<pad_note>`: MIDI note number (0–63 for grid)
- `<red>`, `<green>`, `<blue>`: 0–127

**Example: Set pad 0 to bright red (RGB 127, 0, 0):**
```
F0 00 20 29 02 10 0B 00 7F 00 00 F7
```

**Ardour integration:** Use Ardour's MIDI automation or external scripting (Python + `python-rtmidi`) to send SysEx for LED feedback.

### 5.5.6 Launchpad Pro Mk2 MIDI Mapping (Ardour)

**Step 1: Set Launchpad to Programmer Mode**
1. Hold **Setup** button (bottom left)
2. Tap top-right pad to enter **Programmer mode**
3. Launchpad is now sending/receiving raw MIDI on **Port 3**

**Step 2: Configure Ardour Clip Launching**

Ardour 8 supports **clip launching** natively via the **Clips** view.

1. **Window → Clips** (or press `Alt+C`)
2. Drag audio files into clip slots on Tracks 11–18
3. Each track gets 8 clip slots (matching Launchpad rows)
4. Clips are triggered by MIDI notes

**Pad-to-MIDI-Note mapping (Programmer mode):**

Launchpad grid pads send MIDI notes **0–63** (bottom-left = 0, top-right = 63).

| Row | Pad Notes | Ardour Track | Clips |
| ---: | --- | ---: | --- |
| 8 (top) | 64–71 | Track 11 (Intro Jingles) | Clips 1–8 |
| 7 | 56–63 | Track 12 (Outro Jingles) | Clips 1–8 |
| 6 | 48–55 | Track 13 (Bumpers) | Clips 1–8 |
| 5 | 40–47 | Track 14 (Sound FX) | Clips 1–8 |
| 4 | 32–39 | Track 15 (Stingers) | Clips 1–8 |
| 3 | 24–31 | Track 16 (Sponsor Ads) | Clips 1–8 |
| 2 | 16–23 | Track 17 (Station IDs) | Clips 1–8 |
| 1 (bottom) | 8–15 | Track 18 (PSA/Promos) | Clips 1–8 |

**Step 3: MIDI Learn in Ardour**
1. Right-click a clip slot in the Clips view
2. Select **MIDI Learn**
3. Press corresponding Launchpad pad
4. Binding is created automatically
5. Repeat for each clip

**Alternatively, use a binding file:**

Save as `~/sg9-studio/launchpad-pro-mk2-sg9.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ArdourMIDIBindings version="1.0.0" name="Launchpad Pro Mk2 (SG9)">
  
  <!-- Transport controls (top function buttons) -->
  <Binding channel="1" note="104" function="transport-roll"/>
  <Binding channel="1" note="105" function="transport-stop"/>
  <Binding channel="1" note="106" function="transport-record"/>
  <Binding channel="1" note="107" function="loop-toggle"/>
  <Binding channel="1" note="108" function="save-state"/>
  <Binding channel="1" note="109" function="undo"/>
  <Binding channel="1" note="110" function="redo"/>
  
  <!-- Clip triggers (example for Track 11, Row 8) -->
  <Binding channel="1" note="64" uri="/route/11/clip/1/trigger"/>
  <Binding channel="1" note="65" uri="/route/11/clip/2/trigger"/>
  <Binding channel="1" note="66" uri="/route/11/clip/3/trigger"/>
  <Binding channel="1" note="67" uri="/route/11/clip/4/trigger"/>
  <Binding channel="1" note="68" uri="/route/11/clip/5/trigger"/>
  <Binding channel="1" note="69" uri="/route/11/clip/6/trigger"/>
  <Binding channel="1" note="70" uri="/route/11/clip/7/trigger"/>
  <Binding channel="1" note="71" uri="/route/11/clip/8/trigger"/>
  
  <!-- Repeat for Tracks 12-18... (abbreviated here for space) -->
  
</ArdourMIDIBindings>
```

**Note:** As of Ardour 8.0, clip launching MIDI bindings may require manual XML editing or scripting. Consult Ardour documentation for current URI syntax.

### 5.5.7 LED Feedback Implementation

**Launchpad LED States:**

| Clip State | LED Color | Velocity/RGB |
| --- | --- | --- |
| Empty | Off | 0 |
| Loaded, stopped | Dim (track color) | 1–3 (low velocity) |
| Playing | Bright (track color) | Full RGB or high velocity |
| Queued | Flashing | Pulse SysEx command |
| Recording | Red flashing | Pulse red |

**Implementing feedback in Ardour:**

Ardour 8 can send MIDI feedback via control surface protocols. For Launchpad Pro Mk2:

1. **Enable MIDI Output** in Generic MIDI settings (select Launchpad Port 3)
2. Ardour sends note-on/off messages when clips start/stop
3. Use Launchpad's **velocity-to-color mapping** to indicate state
4. For advanced control (RGB SysEx), use external scripting:

**Example Python script (using `python-rtmidi`):**

```python
#!/usr/bin/env python3
import rtmidi

midiout = rtmidi.MidiOut()
midiout.open_port(2)  # Launchpad Port 3

def set_pad_rgb(pad_note, r, g, b):
    """Set Launchpad pad to RGB color via SysEx."""
    sysex = [0xF0, 0x00, 0x20, 0x29, 0x02, 0x10, 0x0B, pad_note, r, g, b, 0xF7]
    midiout.send_message(sysex)

# Example: Set pad 0 (bottom-left) to red when clip plays
set_pad_rgb(8, 127, 0, 0)  # Bright red

midiout.close_port()
```

**Workflow:**
- Monitor Ardour's transport/clip state via OSC or MIDI
- Update Launchpad LEDs in real-time
- This requires a background script or Ardour Lua script

### 5.5.8 Color-Coding Consistency Table

| Track Type | Ardour Track Color | Launchpad Velocity | Launchpad RGB | nanoKONTROL (N/A) |
| --- | --- | ---: | --- | --- |
| Voice (Tracks 1–4) | `#FF4444` Red | 5 | 127, 0, 0 | — |
| Remote/External (5–7) | `#FF8800` Orange | 9 | 127, 64, 0 | — |
| Music (8–10) | `#4488FF` Blue | 45 | 0, 64, 127 | — |
| Jingles (11–13) | `#AA44FF` Purple | 53 | 96, 0, 127 | — |
| SFX (14) | `#44FF88` Green | 21 | 0, 127, 64 | — |
| Stingers (15) | `#FF8800` Orange | 9 | 127, 64, 0 | — |
| Ads (16) | `#FFFF44` Yellow | 13 | 127, 127, 0 | — |
| IDs (17) | `#00FFFF` Cyan | 37 | 0, 127, 127 | — |
| PSA (18) | `#4488FF` Blue | 45 | 0, 64, 127 | — |
| Voice Bus | `#FFFF44` Yellow | 13 | 127, 127, 0 | Fader 5 |
| Music Bus | `#4488FF` Blue | 45 | 0, 64, 127 | Fader 6 |
| Production Bus | `#AA44FF` Purple | 53 | 96, 0, 127 | Fader 7 |
| Content Bus | `#44FF88` Green | 21 | 0, 127, 64 | Fader 8 |
| VCA 1 (Voices) | `#FFFFFF` White | 3 | 127, 127, 127 | Fader 1 |
| VCA 2 (Music) | `#FFFFFF` White | 3 | 127, 127, 127 | Fader 2 |
| VCA 3 (Content) | `#FFFFFF` White | 3 | 127, 127, 127 | Fader 3 |
| VCA 4 (Master) | `#FF0000` Bright Red | 5 | 127, 0, 0 | Fader 4 |

### 5.5.9 Operational Workflow with Controllers

**Daily startup:**
1. Connect nanoKONTROL Studio and Launchpad Pro Mk2 via USB
2. Open Ardour session—controllers auto-detected
3. Verify fader control on nanoKONTROL (move Fader 4 = Master should respond)
4. Verify Launchpad pads light up with track colors (if feedback enabled)

**Live production workflow:**
1. **Mixing:** Use nanoKONTROL faders for VCA/Bus levels, knobs for sends
2. **Clip launching:** Tap Launchpad pads to trigger jingles/SFX
3. **Transport:** Press Play/Stop/Record on either controller
4. **Scene launching:** Press Launchpad scene buttons to fire multiple clips
5. **Solo/Mute:** Use nanoKONTROL S/M buttons for quick isolation

**Recording workflow:**
1. Arm tracks with nanoKONTROL Rec buttons (lights up when armed)
2. Start recording with nanoKONTROL or Launchpad Record button
3. Monitor levels on Ardour meters + nanoKONTROL LED feedback (if supported)

### 5.5.10 Troubleshooting Controllers

**nanoKONTROL Studio not responding:**
- Check USB connection, verify `aconnect -l` shows device
- Confirm Generic MIDI is enabled in Ardour preferences
- Check binding file path is correct and XML is valid
- Try pressing **Scene** button to cycle modes (DAW mode required)

**Launchpad Pro Mk2 pads not triggering clips:**
- Verify Programmer mode is active (not Live or Standalone mode)
- Check MIDI port in Ardour preferences (should be Port 3)
- Confirm clips are loaded in Ardour Clips view
- Use MIDI Learn to re-bind pads if needed

**LED feedback not working:**
- Ensure MIDI Output is enabled in Generic MIDI settings
- Check Launchpad is receiving MIDI (use MIDI monitor tool)
- For RGB SysEx, verify script is running and sending correct messages

**Faders/knobs controlling wrong parameters:**
- Edit binding XML file, verify URIs match track/bus names exactly
- Ardour track names are case-sensitive
- Reload Generic MIDI control surface (disable/re-enable)

---

## 5.6) Detailed Filter Setup & Plugin Parameters

This section provides exact, production-ready settings for LSP and Calf plugins used in the SG9 Studio broadcast chain. All parameters are based on LSP plugin documentation and broadcast engineering best practices.

### 5.6.1 LSP Plugin Reference

**LSP Parametric Equalizer x16 Mono/Stereo**

Filter types available:
- **Off:** Disabled
- **Bell:** Parametric peak/dip (adjustable Q)
- **Hi-pass:** High-pass filter (6, 12, 18, 24 dB/oct slopes)
- **Lo-pass:** Low-pass filter (6, 12, 18, 24 dB/oct slopes)
- **Hi-shelf:** High-frequency shelving
- **Lo-shelf:** Low-frequency shelving
- **Notch:** Narrow rejection filter
- **Resonance:** Resonant peak filter
- **Allpass:** Phase manipulation

**Key parameters:**
- **Frequency:** 10 Hz – 20 kHz
- **Gain:** -24 dB to +24 dB (for Bell/Shelf types)
- **Q (Bandwidth):** 0.1 – 10.0
  - Narrow (surgical): Q = 4.0 – 10.0
  - Medium (musical): Q = 1.0 – 2.0
  - Wide (tonal): Q = 0.5 – 1.0
- **Slope:** 6/12/18/24 dB/octave (for Hi-pass/Lo-pass)

**LSP Compressor Mono/Stereo**

Modes:
- **Downward:** Standard compression (reduces loud signals)
- **Upward:** Expands quiet signals
- **Boosting:** Makeup gain emphasis

**Key parameters:**
- **Threshold:** -60 dB to 0 dB (signal level where compression starts)
- **Ratio:** 1:1 to 100:1
  - Gentle: 2:1 – 3:1
  - Moderate: 4:1 – 6:1
  - Heavy/Limiting: 10:1 – 20:1+
- **Attack:** 0.0 ms to 2000 ms (how fast compressor responds)
  - Fast (transient control): 1–5 ms
  - Medium (vocal): 5–20 ms
  - Slow (transparent): 20–50 ms
- **Release:** 0.0 ms to 5000 ms (how fast compressor recovers)
  - Fast: 50–100 ms
  - Medium: 100–300 ms
  - Slow (program material): 300–1000 ms
- **Knee:** 0.0 dB to 30.0 dB (compression curve softness)
  - Hard knee: 0–3 dB
  - Soft knee: 6–12 dB
- **Makeup Gain:** 0 dB to +60 dB (compensate for gain reduction)
- **Sidechain:** External trigger input, filters (HPF/LPF)

**LSP Gate Mono**

**Key parameters:**
- **Threshold:** -96 dB to 0 dB (signal level to open gate)
  - Voice: typically -40 dB to -30 dB
- **Attack:** 0.0 ms to 250 ms (how fast gate opens)
  - Fast: 0.1–1 ms (preserve transients)
- **Release:** 0.0 ms to 5000 ms (how fast gate closes)
  - Medium: 100–300 ms (avoid choppy speech)
- **Hold:** 0.0 ms to 2000 ms (time gate stays open after signal drops)
  - Voice: 100–200 ms
- **Reduction:** -96 dB to 0 dB (how much to attenuate when closed)
  - Gentle: -20 dB to -12 dB
  - Aggressive: -60 dB to -∞

**Calf Deesser**

**Purpose:** Specialized de-esser for controlling sibilance ("S," "SH," "CH" sounds). Uses sidechain compression with frequency-specific detection.

**Key parameters:**
- **Detection:** Peak/RMS mode for sibilance detection
  - Peak: Instant response (typical for de-essing)
  - RMS: Averaged level (smoother)
- **Mode:** Wideband / Split
  - **Split mode (recommended):** Only affects frequencies above split point
  - Wideband: Entire signal reduced when sibilance detected
- **Threshold:** -60 dB to 0 dB (level that triggers de-essing)
  - Typical: -20 to -12 dB
- **Ratio:** 1:1 to 20:1 (compression ratio applied to sibilants)
  - Typical: 2:1 to 4:1 (gentle reduction)
- **Laxity:** 1 ms to 100 ms (reaction time)
  - Higher = ignores short peaks
  - Typical: 15–30 ms
- **Split:** 1 kHz to 16 kHz (crossover frequency in split mode)
  - Male "sss": 4500–5000 Hz
  - Male "shh": 3500–4000 Hz
  - Female "sss": 5000–5500 Hz
  - Female "shh": 4000–4500 Hz
- **Peak Freq/Level/Q:** Bell filter for precision targeting
  - Peak Freq: Target specific sibilant frequency
  - Peak Level: ±15 dB boost/cut to shape detection
  - Peak Q: 0.1 to 10.0 (width of bell filter)
- **Makeup:** 0 dB to +24 dB (in split mode, only affects high band)

**Professional Alternative: LSP Compressor with Sidechain**

LSP does not have a dedicated de-esser plugin, but sidechain compression is the professional broadcast standard for frequency-selective dynamics. This method provides excellent results:

1. Insert **LSP Compressor Mono**
2. Enable **Sidechain → Internal** (process its own signal)
3. Enable **SC High-Pass Filter**
4. Set **SC HPF Frequency: 5–7 kHz** (sibilance range)
5. Set **SC HPF Slope: 12 dB/oct** (x2)
6. Configure compressor:
   - **Threshold:** -20 to -12 dB
   - **Ratio:** 3:1 to 6:1
   - **Attack:** 1–5 ms (fast)
   - **Release:** 50–100 ms (quick recovery)
   - **Knee:** 3–6 dB (soft knee for smoothness)

This creates frequency-selective compression targeting only sibilants.

---

### 5.6.1a De-essing Methods Compared

SG9 Studio has multiple de-essing options from the installed plugin suites. Here's a comprehensive comparison to help you choose the best method for your workflow.

#### **Method 1: Calf Deesser (RECOMMENDED)**

**Pros:**
- Dedicated de-esser plugin designed specifically for sibilance control
- **Split mode:** Only affects high frequencies, leaving voice body untouched
- Precision **Peak Freq/Level/Q** controls for surgical targeting
- Visual feedback: **Gain Reduction** meter and **S/C Listen** monitoring
- Familiar broadcast-style interface

**Cons:**
- Requires Calf plugin suite (not pure LSP workflow)

**Best for:**
- Primary de-essing solution for SG9 Studio
- Users who want dedicated, visual, broadcast-quality de-essing
- Both in-studio and remote guest tracks

**Setup (Quick Start):**
1. Insert **Calf Deesser** after EQ, before compression
2. Set **Mode: Split**
3. Set **Detection: Peak**
4. Set **Split: 5–7 kHz** (male: 5 kHz, female: 7 kHz)
5. Enable **S/C Listen**, speak sibilants ("sss", "shh")
6. Adjust **Peak Freq** until you hear harsh sibilance in S/C Listen
7. Disable S/C Listen
8. Set **Threshold: -20 to -12 dB** (adjust until sibilance controlled)
9. Set **Ratio: 2:1** (increase to 4:1 if needed)
10. Watch **Gain Reduction** meter: should show 3–6 dB on "S" sounds

---

#### **Method 2: LSP Compressor with Sidechain (Professional Broadcast Standard)**

**Pros:**
- **Professional broadcast technique** (used in radio/TV studios worldwide)
- Uses LSP suite (consistent workflow)
- Same compressor plugin can be used for multiple tasks
- **Highly flexible sidechain filtering** (precise frequency targeting)
- CPU-efficient
- **More precise than fixed-algorithm de-essers**
- Learn once, apply to many scenarios (ducking, frequency-selective compression)

**Cons:**
- Requires understanding of sidechain concepts
- No visual sibilance detection feedback (use spectrum analyzer)
- No "de-essing" preset—must configure from scratch

**Best for:**
- **Professional broadcast workflows** (this is industry standard)
- Users who want maximum control and precision
- LSP-only workflows
- **SG9 Studio if you prefer professional techniques over simplified tools**

**Setup (Detailed):**
1. Insert **LSP Compressor Mono** after EQ
2. **Sidechain Section:**
   - Position: **Internal** (process its own signal)
   - Enable **High-Pass Filter**
   - SC HPF Frequency: **5–7 kHz**
   - SC HPF Slope: **12 dB/oct** (x2) or **18 dB/oct** (x3)
   - SC Type: **Peak** (instant detection)
   - Optional: Enable **Low-Pass Filter** at 10–12 kHz to narrow detection range
3. **Compressor Section:**
   - Mode: **Downward**
   - Threshold: **-20 to -12 dB**
   - Ratio: **3:1 to 6:1**
   - Attack: **1–5 ms** (fast, catch sibilants immediately)
   - Release: **50–100 ms** (quick recovery)
   - Knee: **3–6 dB** (soft knee for smoothness)
   - Makeup: **0 dB** (de-essing should not add level)
4. **Verification:**
   - Solo track, speak test phrases
   - Compressor should engage only on "S" sounds
   - Gain reduction: 3–6 dB on sibilants, minimal on normal speech

---

#### **Method 3: TAP DeEsser (Legacy, LADSPA)**

**Pros:**
- Simple, single-purpose de-esser
- Low CPU usage
- Predictable, straightforward operation
- No visual clutter—just essential controls

**Cons:**
- **LADSPA only** (no LV2, so limited in modern DAWs)
- **Fixed attack/release** (10 ms, non-adjustable)
- **Fixed ratio** (1:2 compression, non-adjustable)
- **Mono only** (stereo requires two instances)
- No visual feedback (no meters)
- Inactive project (last updated ~2014, no modern features)

**Best for:**
- Quick, simple de-essing on mono tracks
- Legacy workflows or systems limited to LADSPA
- Users who want zero-fuss, "set and forget" de-essing

**Setup (Quick Start):**
1. Insert **TAP DeEsser** (LADSPA) on mono track
2. Set **Frequency** based on voice gender:
   - Male "sss": **4500 Hz**
   - Male "shh": **3400 Hz**
   - Female "sss": **6800 Hz**
   - Female "shh": **5100 Hz**
3. Set **Sidechain Filter:**
   - **Highpass:** For general sibilance (multiple frequencies)
   - **Bandpass:** For targeting specific frequency
4. Set **Threshold Level: -20 to -10 dB** (lower = more de-essing)
5. Optional: Enable **Monitor: Sidechain** to hear detection signal
6. Disable Sidechain monitoring, verify natural sound

**Limitations:**
- Cannot adjust attack/release (fixed at 10 ms)
- Cannot adjust ratio (fixed at 1:2)
- No visual gain reduction meter

---

#### **Method 4: LSP Multiband Compressor (Advanced)**

**Pros:**
- Full multiband control (4 or 8 bands)
- Can de-ess while shaping other frequencies simultaneously
- Independent threshold/ratio/attack/release per band
- Visual spectrum analyzer

**Cons:**
- Overkill for simple de-essing
- More CPU intensive than single-band methods
- Steeper learning curve

**Best for:**
- Advanced users doing complex voice processing
- Situations requiring de-essing + multiband dynamics in one plugin
- Mastering or post-production workflows

**Setup (Advanced):**
1. Insert **LSP Multiband Compressor x4 Mono**
2. Configure crossovers:
   - Band 1 (Low): 20 Hz – 200 Hz
   - Band 2 (Low-Mid): 200 Hz – 2 kHz
   - Band 3 (Mid-High): 2 kHz – 5 kHz
   - Band 4 (High): 5 kHz – 20 kHz
3. **Band 4 (Sibilance Range):**
   - Threshold: **-20 to -12 dB**
   - Ratio: **4:1 to 6:1**
   - Attack: **1–5 ms**
   - Release: **50–100 ms**
   - Makeup: Adjust to compensate
4. **Bands 1–3:**
   - Ratio: **1:1** (no compression, or apply gentle shaping as needed)
5. Verify Band 4 is catching sibilance without affecting voice body

---

#### **Method 5: ZamDynamicEQ (Alternative - Untested)**

ZAM Plugins includes a dynamic EQ plugin that could theoretically be used for de-essing, but it's not a traditional compressor-based de-esser. This method is **experimental** and not recommended for SG9 Studio unless you have specific reasons to explore it.

---

### De-essing Method Summary Table

| Method | Difficulty | Quality | CPU | Format | When to Use |
| --- | --- | --- | --- | --- | --- |
| **Calf Deesser** | Easy | Excellent | Low | LV2 | **Default choice for SG9 Studio** |
| LSP Compressor + SC | Medium | Excellent | Low | LV2 | LSP-only workflows |
| TAP DeEsser | Easy | Good | Very Low | LADSPA | Quick/simple mono de-essing |
| LSP Multiband Comp | Hard | Excellent | Medium | LV2 | Advanced multiband processing |

**SG9 Studio Recommendation:** Use **Calf Deesser** as your primary de-essing solution. It provides the best balance of ease-of-use, visual feedback, and broadcast-quality results. Reserve LSP Compressor with sidechain for LSP-only workflows or when you need more granular control.

---

**LSP Limiter Mono/Stereo**

Modes:
- **Classic:** Traditional brick-wall limiting
- **Modern:** Enhanced lookahead algorithm
- **Gentle:** Soft-knee limiting

**Key parameters:**
- **Threshold:** -24 dB to 0 dB (input level where limiting starts)
- **Ceiling:** -24 dB to 0 dB (absolute output maximum)
  - Broadcast safety: -1.0 dBTP (True Peak)
- **Release:** 1 ms to 1000 ms
  - Fast: 50–100 ms (aggressive)
  - Slow: 200–500 ms (transparent)
- **Lookahead:** 0 ms to 20 ms (preview signal for smoother limiting)
  - Typical: 5–10 ms
- **Oversampling:** 1x, 2x, 4x, 8x (increases quality, CPU cost)
  - Recommended: 4x or 8x for True Peak compliance

### 5.6.2 Calf Plugin Reference (Selected)

**Calf Sidechain Compressor**

SG9 Studio uses this for **music ducking** (LSP lacks dedicated sidechain compression).

**Key parameters:**
- **Threshold:** -60 dB to 0 dB
- **Ratio:** 1:1 to 20:1
- **Attack:** 0.01 ms to 2000 ms
  - Ducking: 5–20 ms (fast enough to respond to speech)
- **Release:** 0.01 ms to 5000 ms
  - Ducking: 200–500 ms (music recovers smoothly)
- **Knee:** 1.0 to 8.0 (soft knee recommended for ducking)
- **Makeup:** 0 dB to +24 dB
- **Sidechain Input:** Select external trigger (e.g., Voice Bus send)
- **SC Listen:** Monitor sidechain signal for verification

**Ducking workflow:**
1. Insert Calf Sidechain Compressor on **Music Bus**
2. Create a send from **Voice Bus** to the sidechain input
3. Adjust threshold so music ducks when voice is present
4. Set attack fast enough to catch speech onset
5. Set release long enough for smooth music recovery

### 5.6.3 Complete Plugin Chain: Host Mic (Broadcast Voice)

**Track 1: Host Mic (DSP) — Professional Broadcast Chain**

This is the cornerstone of the SG9 Studio sound. Each plugin is applied in series.

---

**Plugin 1: LSP Parametric Equalizer x16 Mono (High-Pass Filter)**

*Purpose:* Remove low-frequency rumble, handling noise, and proximity effect.

| Parameter | Value | Notes |
| --- | --- | --- |
| Filter 1 Type | Hi-pass | Remove sub-bass |
| Frequency | 80–100 Hz | Adjust based on mic/voice |
| Slope | 18 dB/oct | Steep enough without ringing |
| Q | 0.707 (Butterworth) | Standard |

**Why:** Broadcast mics pick up room rumble, desk thumps, and excessive low-end proximity effect. This filter removes non-speech energy below 80 Hz without affecting voice fundamentals (male: ~100 Hz, female: ~200 Hz).

---

**Plugin 2: LSP Gate Mono (Noise Cleanup)**

*Purpose:* Suppress room noise, breaths, and ambient sound between speech.

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -40 dB to -35 dB | Adjust to room noise floor |
| Attack | 0.5–1.0 ms | Fast, preserve transients |
| Hold | 150–200 ms | Keep gate open during pauses |
| Release | 200–400 ms | Smooth close, no chopping |
| Reduction | -20 dB to -30 dB | Don't fully mute (unnatural) |

**Tuning procedure:**
1. Set threshold just above room noise floor (view with speech paused)
2. Speak naturally; gate should open cleanly without cutting word onsets
3. Adjust hold time to avoid "breathing" effect during short pauses
4. Set reduction to -20 dB first (gentle); increase if noise remains problematic

---

**Plugin 3: LSP Parametric Equalizer x16 Mono (Voice Curve)**

*Purpose:* Shape tonal balance for clarity, warmth, and broadcast presence.

| Filter | Type | Frequency | Gain | Q | Notes |
| ---: | --- | ---: | ---: | ---: | --- |
| 1 | Lo-shelf | 200 Hz | -2 to -4 dB | 0.7 | Reduce boxiness/mud |
| 2 | Bell | 300–400 Hz | -3 to -6 dB | 1.5 | Cut chest resonance if boomy |
| 3 | Bell | 1–2 kHz | +2 to +4 dB | 1.5 | Add clarity/articulation |
| 4 | Bell | 3–5 kHz | +3 to +6 dB | 1.5 | Presence peak (intelligibility) |
| 5 | Hi-shelf | 8–10 kHz | +1 to +3 dB | 0.7 | Air/sparkle (taste) |

**Critical listening notes:**
- **200 Hz shelf:** Reduces "muffled" quality and proximity bass buildup
- **300–400 Hz cut:** Addresses "boxy" resonance (male voices especially)
- **1–2 kHz boost:** Enhances consonant clarity (critical for broadcast)
- **3–5 kHz boost:** The "presence" region—makes voice cut through mix
- **8–10 kHz shelf:** Adds "air"; use sparingly to avoid sibilance boost

**Adjustment workflow:**
1. Start with EQ bypassed; listen to raw (gated) voice
2. Enable filters one at a time, adjust frequency/gain by ear
3. Use spectrum analyzer to visualize changes
4. Compare with bypassed state frequently (don't over-EQ)

---

**Plugin 4: Calf Deesser (Pre-Compression)**

*Purpose:* Tame sibilance ("S," "SH," "CH" sounds) before compression exaggerates them.

| Parameter | Value | Notes |
| --- | --- | --- |
| Detection | Peak | Instant response to sibilants |
| Mode | Split | Only affects high frequencies |
| Threshold | -20 to -12 dB | Adjust until sibilance is controlled |
| Ratio | 2:1 to 4:1 | Gentle reduction (start conservative) |
| Laxity | 15–30 ms | Ignore short peaks |
| Split | 5–7 kHz | Male: 5 kHz, Female: 7 kHz |
| Peak Freq | 5–6.5 kHz | Target specific sibilant frequency |
| Peak Level | +3 to +6 dB | Boost detection sensitivity |
| Peak Q | 2.0–4.0 | Narrow targeting |
| Makeup | 0 dB | Usually not needed in split mode |

**Tuning procedure:**
1. Solo track and speak test phrases: "Sally sells seashells," "She saw six ships"
2. Enable **S/C Listen** to hear what the de-esser is detecting
3. Adjust **Split** frequency to capture sibilance range (5–7 kHz)
4. Fine-tune **Peak Freq/Level/Q** to target specific problem frequencies
5. Set **Threshold** to engage only on sibilants, not normal speech
6. Increase **Ratio** until sibilance sits naturally in the mix (start at 2:1)
7. Disable S/C Listen and verify natural sound
8. Test with compressor engaged to ensure sibilance stays controlled

**Alternative: LSP Compressor with Sidechain**

If avoiding Calf plugins, use **LSP Compressor Mono** with these settings:
- Sidechain: Internal
- SC HPF: 5–7 kHz, 12 dB/oct slope
- Threshold: -20 to -12 dB
- Ratio: 3:1 to 6:1
- Attack: 2–5 ms
- Release: 50–100 ms
- Knee: 3–6 dB

---

**Plugin 5: LSP Compressor Mono (Main Dynamics Control)**

*Purpose:* Even out dynamic range for consistent broadcast loudness.

| Parameter | Value | Notes |
| --- | --- | --- |
| Mode | Downward | Standard compression |
| Threshold | -18 to -12 dB | Catch peaks above conversational level |
| Ratio | 3:1 to 4:1 | Moderate, natural-sounding |
| Attack | 10–20 ms | Medium: smooth without losing transients |
| Release | 100–200 ms | Auto-release also works well |
| Knee | 6–9 dB | Soft knee for transparent compression |
| Makeup Gain | +3 to +8 dB | Compensate for gain reduction |

**Target behavior:**
- Gain reduction: **3–6 dB** on normal speech
- Peaks controlled without "squashing"
- Natural breathing and dynamics preserved

**Tuning procedure:**
1. Set ratio to 4:1, knee to 6 dB
2. Lower threshold until you see 3–6 dB gain reduction on normal speech
3. Adjust attack: too fast = dulls transients; too slow = lets peaks through
4. Adjust release: too fast = pumping/breathing; too slow = slow recovery
5. Add makeup gain until output level matches bypassed state
6. Compare bypassed vs. enabled: should sound "controlled" but not "crushed"

---

**Plugin 6: Calf Saturator (Optional - Tone/Warmth)**

*Purpose:* Add harmonic richness, analog-style "glue."

| Parameter | Value | Notes |
| --- | --- | --- |
| Drive | 1.0–3.0 dB | Subtle, taste only |
| Blend | 50–100% | Mix dry/wet |

**Note:** This is optional and taste-dependent. Adds perceived "warmth" and can help voice sit better in a dense mix. Use sparingly—digital saturation is easy to overdo.

---

**Plugin 7: LSP Limiter Mono (Safety/Final Control)**

*Purpose:* Brick-wall protection against peaks, ensure True Peak compliance.

| Parameter | Value | Notes |
| --- | --- | --- |
| Mode | Modern | Lookahead algorithm |
| Threshold | -6 to -3 dB | Catch occasional peaks |
| Ceiling | -1.0 dBTP | True Peak safety |
| Release | 100–200 ms | Smooth recovery |
| Lookahead | 5–10 ms | Allows transparent limiting |
| Oversampling | 4x or 8x | True Peak compliance |

**Why:** Even with compression, sudden loud moments (laughter, emphatic speech) can cause peaks. The limiter acts as insurance, keeping the voice from clipping or exceeding broadcast ceilings.

**Tuning procedure:**
1. Set ceiling to -1.0 dBTP (non-negotiable for broadcast)
2. Set threshold high enough that limiter only engages on peaks (not constantly)
3. Verify limiter isn't working hard (occasional 1–2 dB reduction is fine; constant limiting means compression needs adjustment)

---

### 5.6.4 Complete Plugin Chain: Remote Guest (Call Enhancement)

**Track 7: Remote Guest (Zoom/Skype) — Telecom Enhancement**

Remote call audio typically suffers from codec artifacts, noise, bandwidth limitations, and inconsistent levels. This chain compensates.

---

**Plugin 1: LSP Parametric Equalizer x16 Stereo (HPF + Telecom Curve)**

| Filter | Type | Frequency | Gain | Q | Notes |
| ---: | --- | ---: | ---: | ---: | --- |
| 1 | Hi-pass | 150–200 Hz | — | 18 dB/oct | Remove codec rumble |
| 2 | Bell | 300 Hz | -4 to -6 dB | 1.5 | Cut low-mid mud |
| 3 | Bell | 2–3 kHz | +4 to +6 dB | 1.5 | Telecom presence boost |
| 4 | Hi-shelf | 8 kHz | -2 to -4 dB | 0.7 | Reduce codec artifacts |

**Why:**
- Most VoIP codecs roll off below 150 Hz and above 8 kHz
- Boosting 2–3 kHz compensates for "telephone" quality, adds intelligibility
- High shelf cut reduces harsh codec compression artifacts

---

**Plugin 2: LSP Gate Stereo (Aggressive Noise Suppression)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -35 to -30 dB | Higher than in-studio (remote is noisier) |
| Attack | 0.5 ms | Fast |
| Hold | 100–150 ms | Shorter than in-studio |
| Release | 150–250 ms | Medium |
| Reduction | -30 to -40 dB | Stronger reduction (remote background noise) |

**Why:** Remote guests often have noisy environments (fans, traffic, room echo). Aggressive gating helps.

---

**Plugin 3: LSP Compressor Stereo (Leveling Compression)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -24 to -18 dB | Catch wide dynamic range |
| Ratio | 6:1 to 8:1 | Heavier than in-studio |
| Attack | 5–10 ms | Faster (control peaks) |
| Release | 100–150 ms | Medium-fast |
| Knee | 9–12 dB | Soft knee for transparency |
| Makeup Gain | +6 to +12 dB | Bring level up to match host |

**Why:** Remote levels vary wildly (mic gain, distance, codec AGC). Heavy compression evens this out so remote guest matches host level.

---

**Plugin 4: Calf Deesser (Codec Sibilance Control)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Detection | Peak | Fast response |
| Mode | Split | High frequencies only |
| Threshold | -18 to -10 dB | Codecs often boost sibilance |
| Ratio | 3:1 to 6:1 | Moderate to heavy |
| Laxity | 20–40 ms | Ignore short peaks |
| Split | 6–8 kHz | Higher than in-studio (codec artifacts) |
| Peak Freq | 6.5–7.5 kHz | Target harsh codec frequencies |
| Peak Level | +6 to +9 dB | Aggressive detection |
| Peak Q | 3.0–5.0 | Narrow targeting |

**Why:** VoIP codecs (Opus, G.722) often exaggerate sibilance. De-essing is more aggressive than in-studio.

**Alternative:** Use LSP Compressor with sidechain HPF @ 6–8 kHz if avoiding Calf.

| Parameter | Value | Notes |
| --- | --- | --- |
| Frequency | 6–8 kHz | Codec artifacts often boost sibilance |
| Threshold | -12 to -8 dB | More aggressive than in-studio |
| Reduction | -8 to -15 dB | Strong de-essing |

**Why:** Codec compression can exaggerate sibilance. De-ess harder on remote guests.

---

**Plugin 5: LSP Limiter Stereo (Safety)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Ceiling | -1.0 dBTP | True Peak safety |
| Threshold | -6 to -4 dB | Catch post-compression peaks |
| Release | 100 ms | Fast recovery |
| Lookahead | 5 ms | Smooth limiting |
| Oversampling | 4x | True Peak compliance |

---

### 5.6.5 Music Ducking (Sidechain Compression)

**Track 8: Music (Loopback 1) — Auto-Ducking via Sidechain**

Music beds should automatically lower when the host speaks, then recover smoothly.

**Plugin: Calf Sidechain Compressor (Stereo)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -30 to -24 dB | Set so voice triggers ducking |
| Ratio | 4:1 to 6:1 | Moderate ducking depth |
| Attack | 10–20 ms | Fast enough to respond to speech onset |
| Release | 300–500 ms | Slow recovery for smooth music fade-up |
| Knee | 4–6 | Soft knee for musical ducking |
| Makeup Gain | 0 dB | Usually not needed |
| Sidechain Input | Voice Bus (send) | Trigger from all voice content |

**Setup in Ardour:**
1. Create an aux send from **Voice Bus** to a new **Ducking Send** bus
2. Route **Ducking Send** bus to the Calf Sidechain Compressor's sidechain input
3. Adjust send level if needed (usually unity gain)
4. Enable "SC Listen" to verify sidechain is receiving voice signal
5. Adjust threshold until music ducks 6–12 dB when host speaks
6. Fine-tune attack/release for natural behavior

**Expected behavior:**
- When host speaks: music drops 6–12 dB within 10–20 ms
- When host stops: music recovers smoothly over 300–500 ms
- No pumping or abrupt changes

---

### 5.6.6 Aux Input (Phone/Tablet) — Level Matching

**Track 5: Aux Input — Phone/Tablet Enhancement**

Portable devices have wildly varying output levels and tonal qualities. This chain normalizes them.

---

**Plugin 1: LSP Parametric Equalizer x16 Stereo**

| Filter | Type | Frequency | Gain | Q | Notes |
| ---: | --- | ---: | ---: | ---: | --- |
| 1 | Hi-pass | 120–150 Hz | — | 18 dB/oct | Remove device rumble |
| 2 | Bell | 200–300 Hz | -3 to -6 dB | 1.5 | Reduce muddiness |
| 3 | Bell | 2–3 kHz | +3 to +5 dB | 1.5 | Presence/clarity |

---

**Plugin 2: LSP Gate Stereo (Light)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -40 dB | Suppress device noise |
| Reduction | -20 dB | Gentle |

---

**Plugin 3: LSP Compressor Stereo (Heavy Leveling)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -20 to -15 dB | Aggressive leveling |
| Ratio | 6:1 to 8:1 | High ratio for varying sources |
| Makeup Gain | +8 to +12 dB | Match studio levels |

---

**Plugin 4: LSP Limiter Stereo (Safety)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Ceiling | -1.0 dBTP | True Peak safety |

---

### 5.6.7 Bus Processing

**Voice Bus (Tracks 1–4 combined)**

*Purpose:* Glue all voice sources together with gentle multiband compression and polish.

**Option A: LSP Compressor Stereo (Gentle Glue)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -12 dB | Gentle |
| Ratio | 2:1 to 3:1 | Light compression |
| Attack | 20–30 ms | Slow, transparent |
| Release | 200–300 ms | Auto-release works well |
| Knee | 9 dB | Soft |

**Option B: Calf Multiband Compressor**

Use this if you need independent control over low/mid/high frequencies (advanced).

---

**Music Bus (Tracks 8–10 combined)**

*Purpose:* Gentle EQ to make room for voice.

**Plugin: LSP Parametric Equalizer x16 Stereo**

| Filter | Type | Frequency | Gain | Q | Notes |
| ---: | --- | ---: | ---: | ---: | --- |
| 1 | Bell | 2–3 kHz | -2 to -4 dB | 1.5 | Carve space for voice presence |
| 2 | Hi-shelf | 10 kHz | +1 to +2 dB | 0.7 | Optional air/sparkle |

---

**Master Bus (Final Output)**

*Purpose:* Final loudness control, True Peak limiting, and stereo imaging safety.

---

**Plugin 1: LSP Compressor Stereo (Gentle Glue)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Threshold | -10 to -6 dB | Very gentle |
| Ratio | 2:1 to 3:1 | Transparent |
| Attack | 30–50 ms | Slow |
| Release | Auto | Program-dependent |
| Knee | 12 dB | Very soft |

---

**Plugin 2: LSP Limiter Stereo (Final Safety + Loudness)**

| Parameter | Value | Notes |
| --- | --- | --- |
| Mode | Modern | Lookahead + oversampling |
| Threshold | Adjust for target loudness | See loudness section |
| Ceiling | -1.0 dBTP | **Non-negotiable** |
| Release | 200–300 ms | Smooth, transparent |
| Lookahead | 10 ms | Maximum quality |
| Oversampling | 8x | True Peak compliance |

**Loudness targeting:**
- **Podcast (-16 LUFS target):** Set threshold around -10 to -6 dB; verify with Ardour Loudness Analyzer
- **Broadcast (-23 LUFS target):** Set threshold around -17 to -13 dB; verify with Loudness Analyzer

---

**Plugin 3: Ardour Built-in Meters (Monitoring)**

Add these to Master for real-time feedback:
- **EBU R128 Loudness Meter:** Integrated/Short-term/Momentary LUFS
- **Phase Correlation Meter:** Ensure stereo compatibility (should stay mostly positive)
- **True Peak Meter:** Verify ceiling compliance

---

### 5.6.8 Plugin Chain Summary Tables

**Host Mic Voice Chain:**

| Order | Plugin | Purpose | Key Settings |
| ---: | --- | --- | --- |
| 1 | LSP EQ (HPF) | Remove rumble | 80–100 Hz, 18 dB/oct |
| 2 | LSP Gate | Noise suppression | Threshold -40 dB, Reduction -20 dB |
| 3 | LSP EQ (Curve) | Tonal shaping | Presence boost 3–5 kHz |
| 4 | Calf Deesser | Sibilance control | Split 5–7 kHz, Ratio 2:1–4:1 |
| 5 | LSP Compressor | Dynamics | 4:1 ratio, -12 dB threshold, 6 dB knee |
| 6 | Calf Saturator | Warmth (optional) | Drive 1–3 dB |
| 7 | LSP Limiter | Safety | Ceiling -1.0 dBTP, 8x oversampling |

**Remote Guest Chain:**

| Order | Plugin | Purpose | Key Settings |
| ---: | --- | --- | --- |
| 1 | LSP EQ | Telecom curve | HPF 150 Hz, boost 2–3 kHz |
| 2 | LSP Gate | Heavy noise reduction | Threshold -30 dB, Reduction -40 dB |
| 3 | LSP Compressor | Aggressive leveling | 6:1 ratio, fast attack |
| 4 | Calf Deesser | Codec sibilance | Split 6–8 kHz, Ratio 3:1–6:1 |
| 5 | LSP Limiter | Safety | Ceiling -1.0 dBTP |

**Music Bus (with Ducking):**

| Order | Plugin | Purpose | Key Settings |
| ---: | --- | --- | --- |
| 1 | LSP EQ | Make room for voice | Cut 2–3 kHz by -2 to -4 dB |
| 2 | Calf Sidechain Compressor | **Professional auto-ducking** | Triggered by Voice Bus send, 4:1 ratio, 300 ms release |

**Master Bus:**

| Order | Plugin | Purpose | Key Settings |
| ---: | --- | --- | --- |
| 1 | LSP Compressor | Final glue | 2:1 ratio, -6 dB threshold, soft knee |
| 2 | LSP Limiter | Loudness + safety | Ceiling -1.0 dBTP, adjust threshold for target LUFS |
| 3 | Meters | Monitoring | EBU R128, Phase, True Peak |

---

## 6) Processing Chains (FLOSS)

All chains below use **LSP Plugins** and **Calf** plugins, both widely available on Linux as LV2.

### 6.1 Track 1: Host Mic (DSP) — broadcast voice chain

Order (recommended):

1) LSP Parametric EQ x16 (HPF ~100 Hz)
2) LSP Gate (cleanup)
3) LSP Parametric EQ (voice curve)
4) Calf Deesser (pre-compression)
5) LSP Compressor (main dynamics)
6) Calf Saturator (taste)
7) LSP Limiter (safety)

### 6.2 Track 5: Aux input — “level matching”

- HPF (~150 Hz)
- (Optional) gate
- Presence EQ (intelligibility)
- Heavier compression (phones vary wildly)
- Limiter safety

### 6.3 Track 7: Remote guest — “call enhancement”

- Gate + expander
- “Telecom intelligibility” EQ (HPF ~200 Hz, presence boost)
- Aggressive leveling compression
- De-esser (codec artifacts)
- Limiter safety

### 6.4 Track 8: Music loopback — ducking

- Gentle EQ to make room for voice
- Gentle compression
- Sidechain compressor keyed from **Voice Bus** for automatic ducking

### 6.5 Voice Bus

- Multiband compression
- De-essing safety
- Gentle polish EQ
- Optional tape glue

### 6.6 Master Bus

- Light glue compression / tone
- Limiter with true-peak ceiling
- Spectrum + phase metering
- Loudness metering via Ardour’s EBU/R128 tools

---

## 7) Monitoring Strategy (No Echo, No Double Monitoring)

### 7.1 The guiding principle

- **Do not monitor your mic directly in hardware** if you are also monitoring through Ardour.
- Monitor the *processed* mix (what you record / what you stream).

Practical SG9 rule-of-thumb:

- Keep the monitor/Host-headphone destination quiet during voice work.
- Do your real monitoring decisions on **Guest headphones**, since they’re the independent output.

### 7.2 What you should hear (daily)

- Host voice (post-processing)
- Remote guest / Aux / Bluetooth (as needed)
- Music beds, jingles, SFX
- Master output metering behavior (loudness, true peak)

---

## 8) Remote Calls (Zoom/Skype) — Practical Notes

### 8.1 Device selection

In Zoom (or similar):

- Microphone: Vocaster Two
- Speaker: Vocaster Two

### 8.2 Echo prevention checklist (N-1)

- Mix A includes **host/guest mic**
- Mix A excludes **all PCM/loopback returns**
- Remote guest audio return is recorded via **Loopback 2 (Capture 13–14)**

---

## 8.5) Fine-Tuning & Calibration Guide

Once the initial setup is complete (routing verified, plugins inserted, controllers mapped), you must calibrate and fine-tune the system for optimal broadcast quality. This section provides step-by-step procedures to dial in gain staging, EQ curves, compression behavior, and loudness targets.

### 8.5.1 Calibration Philosophy

**Goals:**
- **Consistent levels:** All sources (host, remote guest, music) should sit at comparable perceived loudness
- **Headroom preservation:** No clipping anywhere in the chain; peaks stay below -6 dBFS pre-limiter
- **Tonal balance:** Voice is clear, intelligible, and pleasant; music doesn't mask speech
- **Loudness compliance:** Final output meets -16 LUFS (podcast) or -23 LUFS (broadcast) targets
- **Phase coherence:** Stereo material remains mono-compatible

**Workflow:**
1. **Gain staging** (bottom-up: mic → track → bus → master)
2. **EQ fine-tuning** (surgical cuts, musical boosts)
3. **Compression adjustment** (attack/release optimization)
4. **Loudness measurement** (integrate analyzer into workflow)
5. **Critical listening** (A/B comparisons, fatigue test)

### 8.5.2 Gain Staging Calibration

Proper gain staging ensures every plugin in the chain operates in its optimal range, minimizing noise and distortion.

**Step 1: Set Vocaster Input Gain (Hardware)**

1. Connect host microphone, enable 48V if needed
2. Speak at normal podcast intensity (conversational, not whisper or shouting)
3. Adjust **Host Gain** knob on Vocaster Two until:
   - Vocaster **Host level meter** peaks around **-12 dB to -6 dB** (healthy level, not clipping)
   - Occasional peaks can hit -3 dB, but avoid consistent red LEDs
4. Disable **Enhance** and **Auto Gain** (we're doing this in Ardour)
5. Repeat for Guest mic if used

**Why:** Starting with clean, healthy gain from the interface reduces reliance on digital makeup gain later.

**Step 2: Verify Ardour Track Input Levels**

1. Arm Track 1 (Host Mic DSP)
2. Speak naturally, observe Ardour's track meter
3. **Target:** Peaks around **-18 dB to -12 dBFS** (pre-plugin)
4. If levels are too low/high, adjust Vocaster gain (not Ardour fader yet)

**Step 3: Set Plugin Chain Levels (Host Mic)**

Work through the plugin chain on Track 1, verifying input/output levels at each stage:

| Plugin | Input Level Target | Output Level Target | Notes |
| --- | --- | --- | --- |
| LSP EQ (HPF) | -18 to -12 dBFS | Same (EQ doesn't change level much) | Clean input, no clipping |
| LSP Gate | -18 to -12 dBFS | Same (gate only attenuates) | Gate should open cleanly |
| LSP EQ (Curve) | -18 to -12 dBFS | -15 to -9 dBFS | Boosted presence adds ~3 dB |
| Calf Deesser | -15 to -9 dBFS | Same | De-esser only reduces sibilants |
| LSP Compressor | -15 to -9 dBFS | -12 to -6 dBFS | Makeup gain brings level up |
| LSP Limiter | -12 to -6 dBFS | -6 to -3 dBFS | Limiter catches peaks, raises average |

**How to verify:**
- Most LSP plugins have **input/output level meters** in their GUI
- Bypass plugins one-by-one and observe level changes
- Goal: Each plugin adds gain OR controls dynamics, but nothing clips

**Step 4: Bus-Level Gain Staging**

1. Track 1 output (post-limiter) should peak around **-6 to -3 dBFS**
2. Sum all voice tracks (1–4) to **Voice Bus**
3. Voice Bus input should peak around **-6 to -3 dBFS** (sum of tracks)
4. Voice Bus compressor adds gentle glue; output should be similar
5. Adjust track faders (not VCAs yet) to balance individual voices

**Step 5: Master Bus Gain Staging**

1. Sum all buses (Voice, External, Music, Production, Content) to **Mixbus**
2. Mixbus input should peak around **-6 to -3 dBFS** (full mix, no music ducking)
3. Mixbus compressor adds gentle glue
4. Mixbus output → Master Bus
5. Master Bus input should peak around **-6 to -3 dBFS**
6. Master Limiter raises average level to target loudness (see loudness section)

**Pink Noise Gain Staging (Optional, Advanced)**

For precise calibration:

1. Generate pink noise at **-20 dBFS RMS** (use Ardour's built-in generator or external file)
2. Feed pink noise through Track 1 (bypass all plugins except limiter)
3. Adjust Vocaster gain + Track 1 fader until Ardour shows **-20 dBFS RMS**
4. This establishes a reference; all other sources should be gain-matched to this level
5. Re-enable plugins and verify the chain doesn't clip

**Target Summary:**
- **Mic input (Vocaster):** -12 to -6 dB (hardware meter)
- **Track input (Ardour, pre-plugin):** -18 to -12 dBFS
- **Track output (post-plugin chain):** -6 to -3 dBFS
- **Bus outputs:** -6 to -3 dBFS
- **Master input (pre-limiter):** -6 to -3 dBFS
- **Master output (post-limiter):** -1.0 dBTP ceiling, integrated loudness per target

### 8.5.3 EQ Fine-Tuning Procedure

EQ is highly voice/mic-dependent. Use the following iterative process to dial in the perfect tone.

**Step 1: Bypass all EQ, establish baseline**
1. Disable LSP EQ plugins on Track 1
2. Record 30 seconds of natural speech
3. Listen critically: What's wrong?
   - Too boomy/muddy? (low-mid excess)
   - Too thin/nasal? (low-mid deficiency)
   - Lacks clarity? (presence deficiency)
   - Too harsh/sibilant? (high-mid excess)

**Step 2: HPF adjustment**
1. Enable LSP EQ (HPF) plugin
2. Start at 100 Hz, 18 dB/oct slope
3. Sweep frequency up slowly while listening
4. Stop when you hear the voice start to thin out
5. Back off 10–20 Hz
6. Goal: Remove rumble without affecting voice body

**Step 3: Low-mid cleanup (200–500 Hz)**
1. Enable LSP EQ (Curve) plugin
2. Insert a Bell filter at 200 Hz, Q = 0.7, Gain = -3 dB
3. Sweep frequency from 150–400 Hz while listening
4. Find the "boxy" or "muddy" resonance (often 250–350 Hz)
5. Cut by -3 to -6 dB
6. Use narrow Q (1.5–2.0) for surgical cuts

**Step 4: Presence boost (2–5 kHz)**
1. Insert a Bell filter at 3 kHz, Q = 1.5, Gain = +4 dB
2. This is the "intelligibility" region
3. Sweep from 2–5 kHz to find the sweet spot
4. Male voices: often 2.5–3.5 kHz
5. Female voices: often 3.5–5 kHz
6. Boost by +3 to +6 dB, but don't overdo (harshness)

**Step 5: Air/sparkle (8–12 kHz)**
1. Insert a Hi-shelf at 10 kHz, Gain = +2 dB
2. This adds "air" and "openness"
3. Adjust gain by ear: +1 to +3 dB
4. If sibilance increases too much, reduce or skip this step

**Step 6: De-esser adjustment (complements EQ)**
1. After EQ is set, adjust Calf Deesser
2. Solo track, speak test phrases: "Sally sells seashells," "She saw six ships"
3. Enable **S/C Listen** button - this lets you hear what frequencies the de-esser is detecting
4. Adjust **Split** frequency (5–7 kHz) until you hear only sibilants in S/C Listen mode
5. Fine-tune **Peak Freq** to target the harshest part of the sibilance
6. Disable S/C Listen, adjust **Threshold** until sibilance sits naturally
7. Start with **Ratio: 2:1** and increase if needed (typical max: 4:1)
8. Watch **Gain Reduction** meter: should show 3–6 dB on "S" sounds
9. Disable de-esser, compare: sibilance should be controlled but not lispy

**Alternative (LSP-only workflow):**
- Use LSP Compressor with sidechain HPF @ 5–7 kHz instead of Calf Deesser
- Same principle: frequency-selective compression targeting sibilants
3. Adjust **Frequency** to target sibilance peak (5–7 kHz typically)
4. Increase **Reduction** until sibilance sits naturally (not over-dulled)

**Step 7: A/B comparison**
1. Bypass all EQ plugins
2. Compare raw vs. EQ'd voice
3. EQ should sound "clearer" and "more polished," not "different" or "artificial"
4. If EQ sounds unnatural, reduce boost/cut amounts by 50% and re-evaluate

**Using Spectrum Analyzer:**
1. Add a spectrum analyzer plugin to Track 1 (e.g., Calf Analyzer)
2. Observe frequency response while speaking
3. Voice fundamentals: male ~100–150 Hz, female ~200–250 Hz
4. Presence peaks: 2–5 kHz
5. Sibilance: 5–8 kHz (should be controlled, not dominant)

### 8.5.4 Compression Fine-Tuning

Compression is critical for broadcast loudness but easy to overdo. Use the following ear-training approach.

**Step 1: Set threshold**
1. Start with LSP Compressor bypassed
2. Observe peak levels on Track 1: should be around -15 to -9 dBFS (post-EQ)
3. Enable compressor, set Ratio = 4:1, Knee = 6 dB
4. Lower **Threshold** until you see **3–6 dB gain reduction** on normal speech
5. Peaks should be controlled, not crushed

**Step 2: Adjust attack time**
1. Start at 10 ms (medium)
2. Listen to consonants (T, K, P sounds)
3. **Too fast** (< 5 ms): Consonants sound dull, transients lost
4. **Too slow** (> 30 ms): Peaks get through, compressor feels sluggish
5. Optimal: 10–20 ms for natural voice compression

**Step 3: Adjust release time**
1. Start at 100 ms (medium-fast)
2. Listen to speech rhythm and gaps
3. **Too fast** (< 50 ms): "Pumping" or "breathing" artifacts (level fluctuates unnaturally)
4. **Too slow** (> 300 ms): Compressor doesn't recover between phrases, sounds "stuck"
5. Optimal: 100–200 ms for speech; **Auto-release** also works well

**Step 4: Fine-tune knee**
1. Start at 6 dB (soft knee)
2. Hard knee (0–3 dB): More aggressive, obvious compression
3. Soft knee (6–12 dB): More transparent, musical
4. For broadcast voice, soft knee (6–9 dB) is usually best

**Step 5: Set makeup gain**
1. Bypass compressor, note output level
2. Enable compressor, observe gain reduction meter
3. Add **Makeup Gain** equal to average gain reduction (e.g., if GR = 4 dB, add +4 dB makeup)
4. Output level should match bypassed level (loudness-matched comparison)

**Step 6: A/B bypass comparison**
1. Speak naturally, bypass compressor on/off
2. Compressed voice should sound "even" and "controlled," not "squashed" or "lifeless"
3. Dynamic range should be reduced, but natural inflection preserved
4. If compression is obvious, reduce ratio (4:1 → 3:1) or raise threshold

**Critical listening test: Whisper-to-Shout**
1. Record a phrase at whisper volume, then normal, then loud/emphatic
2. Compressed version should bring whisper up and loud moments down
3. All three should be roughly similar in perceived loudness
4. If compression doesn't even out levels, increase ratio or lower threshold
5. If compression kills dynamics entirely, reduce ratio or raise threshold

### 8.5.5 Ardour Loudness Analyzer Workflow

Ardour 8 includes a built-in **EBU R128-compliant loudness analyzer**. Use this to verify your final mix hits target loudness.

**Step 1: Insert Loudness Analyzer**
1. Open Master Bus mixer strip
2. Right-click plugin area → **Pin Connections → Loudness Analyzer**
3. Or: **Window → Loudness Analyzer & Inspector**

**Step 2: Understanding the Metrics**

| Metric | Symbol | Description | Use |
| --- | --- | --- | --- |
| **Integrated Loudness** | I / LUFS | Average loudness over entire program | Primary delivery target |
| **Short-term Loudness** | S / LUFS | 3-second rolling average | Real-time monitoring |
| **Momentary Loudness** | M / LUFS | 400 ms rolling average | Transient monitoring |
| **Loudness Range** | LRA / LU | Dynamic range measurement | Consistency check |
| **True Peak** | TP / dBTP | Inter-sample peak detection | Ceiling compliance |

**Step 3: Measurement Procedure**
1. Reset the analyzer (clear previous data)
2. Play the full program from start to finish (entire episode/show)
3. Do NOT pause or stop playback (integrated loudness requires continuous measurement)
4. At the end, note **Integrated Loudness (I)** and **True Peak (TP)**

**Step 4: Target Verification**

| Delivery Format | Integrated (I) Target | True Peak (TP) Max | Action if Outside Range |
| --- | --- | --- | --- |
| **Podcast (stereo)** | -16 LUFS ± 1 LU | -1.0 dBTP | Adjust Master Limiter threshold |
| **Broadcast (EBU R128)** | -23 LUFS ± 0.5 LU | -1.0 dBTP | Adjust Master Limiter threshold |

**How to adjust:**
- **Too quiet** (e.g., -18 LUFS, target -16): Lower Master Limiter threshold by ~2 dB, or add gain before limiter
- **Too loud** (e.g., -14 LUFS, target -16): Raise Master Limiter threshold by ~2 dB, or reduce gain before limiter
- **True Peak violations** (> -1.0 dBTP): Ensure limiter Oversampling is 4x or 8x, reduce ceiling if needed

**Iterative workflow:**
1. Measure integrated loudness
2. Adjust Master Limiter threshold
3. Re-export and re-measure
4. Repeat until within ±0.5 LU of target

**Step 5: Loudness Range (LRA) Check**

- **Podcast/online:** LRA = 4–10 LU (moderate compression, engaging)
- **Broadcast:** LRA = 5–15 LU (more dynamic, less fatiguing)
- **Too low** (< 3 LU): Over-compressed, lifeless
- **Too high** (> 15 LU): Inconsistent, listener adjusts volume frequently

If LRA is outside expected range:
- **Too low:** Reduce compression ratios, raise thresholds (less aggressive)
- **Too high:** Increase compression, lower thresholds (more leveling)

### 8.5.6 Phase Correlation Monitoring

Stereo content (music beds, remote guests, SFX) must remain **mono-compatible** for broadcast.

**Step 1: Insert Phase Correlation Meter**
1. Add to Master Bus (or individual stereo tracks)
2. Ardour includes built-in phase meters; alternatively use Calf Analyzer

**Step 2: Interpretation**

| Phase Correlation | Meaning | Action |
| ---: | --- | --- |
| **+1.0** | Perfect mono (L = R) | Safe, but no stereo width |
| **+0.5 to +1.0** | Good correlation, mostly in-phase | Ideal for broadcast |
| **0.0** | Uncorrelated (L and R independent) | Acceptable for stereo |
| **-0.5 to 0.0** | Partial phase cancellation | Warning: check mono compatibility |
| **-1.0** | Perfect anti-phase (L = -R) | **Dangerous:** cancels in mono |

**Step 3: Mono Compatibility Test**
1. Play stereo content (music bed, remote guest)
2. Observe phase meter: should stay mostly positive (> +0.3)
3. Enable **Mono** button on Master Bus (or use Calf Stereo Tools mono switch)
4. Listen: Does the mix sound similar, or does it change dramatically?
5. If significant elements disappear in mono, you have phase issues

**Common phase problems:**
- **Mid-side mic techniques:** Incorrect M/S decoding can invert phase
- **Plugin artifacts:** Some stereo wideners can create phase issues
- **Layered stereo tracks:** Overlapping stereo files with phase offset

**Fixes:**
- Use Calf Stereo Tools to adjust stereo width (reduce to < 100% if needed)
- Flip phase on one channel and re-check
- Use mono sources for critical content (voice, leads)

### 8.5.7 Critical Listening Checklist

After calibration, perform systematic listening tests to verify quality.

**Listening Environment Setup:**
1. Use Guest headphones (primary monitoring output) for detailed checks
2. Cross-check on studio monitors (Destination A) if available
3. Test on multiple playback systems: consumer headphones, phone speaker, car stereo

**Critical Listening Questions:**

| Aspect | Question | Fix if Problem |
| --- | --- | --- |
| **Frequency Balance** | Does voice sound natural, clear, and intelligible? | Adjust EQ (reduce excess, boost deficiency) |
| **Sibilance** | Are "S" sounds harsh or overly prominent? | Increase Calf Deesser ratio or lower split frequency |
| **Plosives** | Are "P/B/T" sounds boomy or clipping? | Increase HPF frequency, use pop filter |
| **Dynamic Range** | Does loudness feel consistent, or do levels vary wildly? | Adjust compression threshold/ratio |
| **Compression Artifacts** | Do you hear "pumping," "breathing," or unnatural level changes? | Slow compressor attack/release |
| **Noise Floor** | Is there audible hiss, room tone, or electrical noise? | Lower gate threshold, increase reduction |
| **Music Ducking** | Does music smoothly lower when voice enters, then recover naturally? | Adjust sidechain compressor attack/release |
| **Stereo Imaging** | Does stereo content sound wide but still mono-compatible? | Check phase correlation, reduce width if needed |
| **Loudness Match** | Do all sources (host, guest, music, SFX) sit at similar perceived levels? | Adjust track faders, compression makeup gain |
| **Ceiling Compliance** | Are there any true peak overs (> -1.0 dBTP)? | Enable limiter oversampling, reduce ceiling |
| **Listening Fatigue** | Can you listen for 30+ minutes without ear fatigue? | Reduce high-frequency boosts, soften compression |

**A/B Comparison Procedure:**
1. Export a 2-minute segment of your mix
2. Compare to a professional podcast/broadcast you admire (similar genre/voice)
3. Match playback levels (use loudness normalization)
4. Listen back-to-back: How does yours compare?
5. Note differences: tonal balance, dynamic range, clarity, loudness
6. Adjust your chain to close the gap

**Bypass Test:**
1. Systematically bypass each plugin in the chain
2. Compare bypassed vs. enabled
3. Each plugin should add value (clarity, control, tone)
4. If bypassing a plugin sounds better, remove it or adjust settings

### 8.5.8 Fine-Tuning Summary Workflow

**Complete calibration sequence (first-time setup):**
1. ✅ Set Vocaster input gain (hardware metering, -12 to -6 dB peaks)
2. ✅ Verify Ardour track input levels (-18 to -12 dBFS pre-plugin)
3. ✅ Insert and configure plugin chains (HPF, Gate, EQ, DeEsser, Compressor, Limiter)
4. ✅ Gain-stage plugin chain (verify levels at each stage, no clipping)
5. ✅ Fine-tune EQ (surgical cuts, musical boosts, A/B bypass)
6. ✅ Fine-tune compression (threshold, attack, release, knee, makeup)
7. ✅ Calibrate bus-level processing (Voice Bus, Music Bus with ducking)
8. ✅ Set Master Limiter for target loudness (-16 or -23 LUFS)
9. ✅ Measure integrated loudness with Ardour Analyzer (iterate until on-target)
10. ✅ Verify True Peak compliance (≤ -1.0 dBTP with 8x oversampling)
11. ✅ Check phase correlation (stereo content stays > +0.3)
12. ✅ Perform critical listening tests (checklist above)
13. ✅ A/B against professional reference
14. ✅ Test on multiple playback systems (headphones, monitors, phone, car)
15. ✅ Save session as template for future use

**Daily pre-show quick checks (5 minutes):**
1. ✅ Speak into Host mic, verify levels peak -12 to -6 dBFS (Track 1 meter)
2. ✅ Check gate is opening cleanly (no chopping)
3. ✅ Check compressor gain reduction is 3–6 dB on normal speech
4. ✅ Verify Master output is ≤ -1.0 dBTP
5. ✅ If remote guest: verify N-1 mix (no echo), check Remote Guest track levels
6. ✅ If music beds: trigger a clip, verify ducking behavior (music drops when you speak)

---

## 9) Loudness Targets (Broadcast vs Podcast)

Two common delivery targets:

- **Broadcast (EBU R128):** Integrated loudness around **-23 LUFS**, true peak max **-1 dBTP**
- **Podcast / online:** commonly around **-16 LUFS (stereo)** with true peak max **-1 dBTP**

**Rule:** Decide target *before* final limiting. Keep the limiter ceiling at **-1.0 dBTP** in both cases; adjust threshold / gain for integrated loudness.

### 9.1 Practical loudness workflow in Ardour

- Mix with healthy headroom first (don’t chase LUFS while still editing).
- On Master, keep the limiter ceiling at **-1.0 dBTP**.
- Use Ardour loudness metering/analysis to measure **Integrated LUFS** over the full program.
- Adjust final gain/limiter threshold until you hit your delivery target.

### 9.2 Suggested gain staging targets (voice-centric)

These targets keep processing stable and reduce “fighting the limiter”:

- Host mic peaks typically around **-12 to -6 dBFS** pre-limiter (normal speech)
- Avoid routinely hitting above **-3 dBFS** anywhere before the final limiter
- If you need more loudness, prefer controlled compression makeup rather than raw fader boosts

### 9.3 Export & delivery (repeatable recipes)

Decide the delivery target first (broadcast vs podcast), then export. Keep the limiter ceiling at **-1.0 dBTP**.

**Recipe A: Broadcast master (EBU R128)**

- Target: ~**-23 LUFS integrated**, **-1 dBTP**.
- Export format: **WAV**, **48 kHz**, **24-bit** (archive/master).

**Recipe B: Podcast/online master**

- Target: ~**-16 LUFS integrated (stereo)**, **-1 dBTP**.
- Export format: **WAV** (master) and optionally a distribution encode (e.g., AAC/MP3) via your publisher/tooling.

**How to export from Ardour (high level):**

1. Select the time span you want (full session or a defined range).
2. Open the export dialog (typically **Session → Export → Export to Audio File(s)**).
3. Choose **Source** as the Master bus output.
4. Export without peak-normalization.
5. Measure the exported file’s integrated loudness; if you missed the target, adjust final gain/limiter threshold and re-export.

If your Ardour build offers loudness-normalization during export, you can use it as a convenience — but treat it as a finalization step after the mix is already clean and stable.

### 9.4 Fast target picker (decision tree)

- Delivering to **broadcast** (radio/TV) or a client explicitly asking for **EBU R128**:
  - Target ~**-23 LUFS integrated**, **-1 dBTP**.
  - Export a **WAV master** at **48 kHz / 24-bit**.
- Delivering to **podcast platforms / online video**:
  - Target ~**-16 LUFS integrated (stereo)**, **-1 dBTP**.
  - Export a **WAV master**, then create an AAC/MP3 distribution file if needed.
- Not sure yet (or you want future-proofing):
  - Export and archive a **broadcast-style WAV master** first.
  - Create a separate “podcast loudness” version as a derivative deliverable.

Note: If you ever publish **mono** versions, typical podcast targets differ; keep this manual’s default as **stereo** unless you intentionally change the session output format.

### 9.5 Distribution encode (optional, after WAV master)

Recommended practice:

- Always keep a lossless **WAV master** (48 kHz / 24-bit) as your source of truth.
- Encode a distribution file only from the WAV master (not from another lossy file).
- Re-check the encoded file for obvious artifacts and ensure peaks still respect the ceiling.

Common, safe starting points:

- AAC (M4A): ~128–192 kbps stereo
- MP3: ~160–192 kbps stereo

If you use `ffmpeg`, example commands:

- AAC: `ffmpeg -i master.wav -c:a aac -b:a 160k -ar 48000 master.m4a`
- MP3: `ffmpeg -i master.wav -c:a libmp3lame -b:a 192k -ar 48000 master.mp3`

---

## 10) Operational Workflows

### 10.1 Solo recording

1. Arm Track 1 (Host DSP). Optionally arm Track 2 (Host raw) for safety.
2. Verify monitoring is from Ardour (no hardware mic monitoring).
3. Record.

### 10.2 Phone/tablet guest via Aux

1. Plug device into Aux.
2. Arm Track 5 (Aux input).
3. Level-match with Track 5 chain.
4. Record.

### 10.3 Remote interview

1. Start Zoom call.
2. Arm Track 7 (Remote guest) and Track 1 (Host).
3. Confirm Mix A is mix-minus (no PCM loopback in Mix A).
4. Record.

### 10.4 Full live show

- Arm the active live inputs.
- Trigger jingles/SFX as needed.
- Use VCA 1/2/3 for fast control.

### 10.5 Preflight validation (do this after routing changes)

- **Port mapping sanity check:** play a test tone from Ardour to Playback 1–2, then 3–4, and confirm Destination A vs B behavior.
- **N-1 echo test (remote):** on a call, ask the remote guest to speak; they must not hear their own voice returning.
- **Double-monitoring test (local):** speak into the Host mic; your voice should not sound “phasey” or flanged.
- **End-to-end record test:** record 30–60 seconds (host + any active sources), then play back and confirm the Master chain sounds correct.
- **Peak/loudness check:** confirm the limiter ceiling is respected and integrated loudness is in the right neighborhood for the intended delivery.
- **Talkback isolation test (if used):** talkback must not appear on the Master export/record; monitors must be muted when talkback is active.

---

## 11) Troubleshooting

### 11.1 “Remote guest hears themselves” (echo)

- Confirm Mix A mutes PCM/loopback returns.
- Confirm you’re not sending the call return back into the call.

### 11.2 “I hear myself twice” (comb filtering)

- Disable hardware mic monitoring in Mix C.
- Monitor through Ardour only.

### 11.3 “Levels are wrong / mapping is weird”

- Use `alsa-scarlett-gui` **Levels** window to confirm which numbered ports correspond to Aux / headphones / monitors.
- Adjust the routing table accordingly.

### 11.4 “Speakers are active when they shouldn’t be”

- Remember Destination A is **monitors + Host headphones**.
- If you mirrored Master to Playback 1–2, either remove that mirror or keep the monitor knob at 0 during recording.

### 11.5 “Crackles / dropouts / monitoring feels laggy”

- Increase the Ardour buffer size (128 → 256 → 512).
- Close CPU-heavy apps and confirm your session isn’t overloading.
- If you must use hardware monitoring for comfort, mute Ardour monitoring for the mic to avoid double monitoring.

### 11.6 “Export is the wrong loudness”

- Confirm you are measuring **integrated LUFS** over the full program (not a short moment).
- Don’t peak-normalize exports; instead adjust the final gain/limiter threshold and re-export.
- Keep true peak ceiling at **-1.0 dBTP**.

---

## 12) Quick Reference

This section provides at-a-glance tables for daily operation and troubleshooting.

### 12.1 Plugin Quick Reference

**Host Mic Voice Chain (Track 1):**

| Plugin | Key Parameters | Values |
| --- | --- | --- |
| LSP EQ x8 (HPF) | Type: Hi-pass, Frequency, Slope | 80–100 Hz, 18 dB/oct |
| LSP Gate | Threshold, Attack, Hold, Release, Reduction | -40 to -35 dB, 0.5–1 ms, 150–200 ms, 200–400 ms, -20 to -30 dB |
| LSP EQ x8 (Curve) | Filters: Lo-shelf 200 Hz, Bell 300 Hz, Bell 3 kHz, Hi-shelf 10 kHz | -3 dB, -4 dB, +4 dB, +2 dB |
| Calf Deesser | Detection, Mode, Split, Threshold, Ratio, Peak Freq | Peak, Split, 5–7 kHz, -20 to -12 dB, 2:1 to 4:1, 5.5–6.5 kHz |
| LSP Compressor | Threshold, Ratio, Attack, Release, Knee, Makeup | -18 to -12 dB, 3:1 to 4:1, 10–20 ms, 100–200 ms, 6–9 dB, +3 to +8 dB |
| LSP Limiter | Mode, Threshold, Ceiling, Release, Lookahead, Oversampling | Modern, -6 to -3 dB, -1.0 dBTP, 100–200 ms, 5–10 ms, 4x or 8x |

**Remote Guest Chain (Track 7):**

| Plugin | Key Parameters | Values |
| --- | --- | --- |
| LSP EQ | HPF 150 Hz, Cut 300 Hz, Boost 2–3 kHz, Shelf 8 kHz | 18 dB/oct, -4 dB, +5 dB, -3 dB |
| LSP Gate | Threshold, Reduction | -35 to -30 dB, -30 to -40 dB |
| LSP Compressor | Threshold, Ratio, Attack, Makeup | -24 to -18 dB, 6:1 to 8:1, 5–10 ms, +6 to +12 dB |
| Calf Deesser | Mode, Split, Threshold, Ratio, Peak Freq | Split, 6–8 kHz, -18 to -10 dB, 3:1 to 6:1, 6.5–7.5 kHz |
| LSP Limiter | Ceiling, Oversampling | -1.0 dBTP, 4x |

**Music Ducking (Track 8):**

| Plugin | Key Parameters | Values |
| --- | --- | --- |
| Calf Sidechain Comp | Threshold, Ratio, Attack, Release, Sidechain Input | -30 to -24 dB, 4:1 to 6:1, 10–20 ms, 300–500 ms, Voice Bus send |

**Master Bus:**

| Plugin | Key Parameters | Values |
| --- | --- | --- |
| LSP Compressor | Threshold, Ratio, Attack, Knee | -10 to -6 dB, 2:1 to 3:1, 30–50 ms, 12 dB |
| LSP Limiter | Threshold (adjust for target), Ceiling, Lookahead, Oversampling | Varies, -1.0 dBTP, 10 ms, 8x |

---

### 12.2 TAP & ZAM Plugin Quick Reference (Optional/Alternative)

**TAP DeEsser (LADSPA - Legacy Mono De-essing):**

| Parameter | Range/Options | Recommended Values |
| --- | --- | --- |
| Frequency | 2000 Hz – 16000 Hz | Male "sss": 4500 Hz, Female "sss": 6800 Hz |
| Sidechain Filter | Highpass / Bandpass | Highpass (general), Bandpass (specific targeting) |
| Threshold Level | -50 dB to +10 dB | -20 to -10 dB |
| Monitor | Audio / Sidechain | Use Sidechain to verify detection |

**Notes:**
- Fixed attack/release (10 ms, non-adjustable)
- Fixed ratio (1:2 compression, non-adjustable)
- Mono only (use two instances for stereo)
- Simple, effective for quick de-essing on mono tracks
- Outdated interface, no visual metering

---

**TAP Dynamics Mono/Stereo (Preset-Based Dynamics):**

| Parameter | Range | Notes |
| --- | --- | --- |
| Function | 0–14 (15 presets) | Preset curves: compressors, limiters, expanders, gates |
| Attack | 4 ms to 500 ms | Adjustable per function |
| Release | 4 ms to 1000 ms | Adjustable per function |
| Offset Gain | -20 dB to +20 dB | Input gain adjustment |
| Makeup Gain | -20 dB to +20 dB | Output gain compensation |
| Stereo Mode (stereo only) | Independent / Average / Peak | Channel linking |

**Example Functions:**
- Function 0: Soft compressor (low ratio)
- Function 5: Medium compressor (broadcast-style)
- Function 10: Limiter
- Function 14: Gate

**Limitations:**
- Preset curves only (no continuous threshold/ratio adjustment)
- Less flexible than modern compressors
- Good for vintage-style dynamics or quick "character" compression

---

**ZamComp/ZamCompX2 (General Purpose Compressor):**

| Parameter | Range | Recommended for Broadcast |
| --- | --- | --- |
| Threshold | Variable | -20 to -12 dB |
| Ratio | 1:1 to 20:1 | 3:1 to 6:1 |
| Attack | Variable | 10–20 ms |
| Release | Variable | 100–300 ms |
| Knee | Variable | 3–6 dB (soft knee) |
| Makeup | Variable | Compensate for gain reduction |

**Notes:**
- ZamComp: Mono
- ZamCompX2: Stereo
- Modern alternative to LSP/Calf compressors
- Clean, transparent compression
- No sidechain capabilities (unlike LSP)

---

**ZamGate/ZamGateX2 (Noise Gate):**

| Parameter | Range | Recommended for Broadcast |
| --- | --- | --- |
| Threshold | Variable | -40 to -35 dB |
| Attack | Variable | 0.5–2 ms |
| Release | Variable | 150–300 ms |
| Hold | Variable | 100–200 ms |

**Notes:**
- ZamGate: Mono
- ZamGateX2: Stereo
- Alternative to LSP Gate
- Simpler interface than LSP

---

**ZamMultiComp/ZamMultiCompX2 (3-Band Multiband Compressor):**

| Parameter | Per-Band Control | Notes |
| --- | --- | --- |
| Bands | 3 (Low, Mid, High) | Fixed crossover points |
| Threshold | Independent per band | Target different frequency ranges |
| Ratio | Independent per band | Typical: 2:1 to 6:1 |
| Attack | Independent per band | Adjust per frequency characteristics |
| Release | Independent per band | Faster for high frequencies |
| Makeup | Global or per-band | Output level compensation |

**Notes:**
- Alternative to LSP Multiband Compressor
- Fewer bands than LSP (3 vs 4/8)
- Simpler interface, easier to use
- Good for basic multiband dynamics on music or master bus

---

**When to Use TAP/ZAM Plugins:**

| Use Case | Recommended Plugin | Reason |
| --- | --- | --- |
| Quick mono de-essing | TAP DeEsser | Simplest de-esser, low CPU |
| Vintage-style compression | TAP Dynamics | Preset curves, character |
| Alternative dynamics (non-LSP) | ZamComp/ZamMultiComp | Modern, clean, actively maintained |
| Simple gating | ZamGate | Straightforward, effective |
| Multiband on budget CPU | ZamMultiComp | Lighter than LSP Multiband |

**SG9 Studio Default Hierarchy:**
1. **Primary:** LSP plugins (modern, comprehensive, broadcast-ready)
2. **Specialized:** Calf plugins (Deesser, Sidechain Compressor, visual tools)
3. **MIDI Processing:** x42-plugins (MIDI filters, routing, transformation)
4. **Alternative/Legacy:** TAP plugins (LADSPA de-essing, vintage dynamics)
5. **Alternative/Modern:** ZAM plugins (clean dynamics, multiband)

---

### 12.2a x42 MIDI Plugins (FLOSS MIDI Processing)

**x42-plugins** by Robin Gareus (Ardour core developer) provides **32+ LV2 MIDI filter plugins** for professional MIDI processing.

**Website:** http://x42-plugins.com/x42/x42-midifilter  
**Format:** LV2  
**NixOS Package:** `x42-plugins`

#### MIDI Routing & Transformation

| Plugin | Purpose | SG9 Studio Use Case |
| --- | --- | --- |
| **MIDI Channel Map** | Reroute MIDI channels | Map Launchpad pads to different Ardour tracks |
| **MIDI Channel Filter** | Block specific channels | Isolate controller zones |
| **MIDI CC Map** | Convert CC numbers | Remap nanoKONTROL CCs to Ardour bindings |
| **MIDI Note Transpose** | Chromatic/scale transpose | Shift Launchpad note range |
| **MIDI Keysplit** | Route notes to channels | Split Launchpad grid into zones |

#### MIDI Effects

| Plugin | Purpose | Use Case |
| --- | --- | --- |
| **MIDI Delay** | Tempo-synced note delay | Timing adjustments |
| **MIDI Quantization** | Live event quantization | Tighten clip triggering |
| **MIDI Velocity Adjust** | Scale/offset velocity | Normalize controller response |
| **MIDI Duplicate Blocker** | Filter redundant messages | Prevent double-triggering |
| **MIDI Event Filter** | Block specific message types | Clean MIDI streams |

#### Launchpad Integration with x42 Plugins

**Use Case: Zone-Based Clip Triggering**

```
Launchpad Pro Mk2 → x42 MIDI Keysplit → Multiple Ardour Tracks

Configuration:
- Rows 1-4 (notes 11-48): Route to channel 1 → Track 11 (Jingles)
- Rows 5-8 (notes 51-88): Route to channel 2 → Track 14 (SFX)
```

**Use Case: Velocity Normalization**

```
Launchpad → x42 MIDI Velocity Adjust → Ardour

Settings:
- Scale: 1.2 (boost weak pad hits)
- Offset: +10 (ensure minimum velocity)
```

**Use Case: CC Remapping for nanoKONTROL**

```
nanoKONTROL → x42 MIDI CC Map → Ardour

Remapping:
- CC 0 (Fader 1) → CC 7 (Volume) for Track 1
- CC 1 (Fader 2) → CC 7 for Track 5
```

#### Advantages over Python Scripting

| Aspect | x42 MIDI Plugins | Python Scripting |
| --- | --- | --- |
| **Integration** | Native LV2 in Ardour | External process |
| **Latency** | Near-zero (audio thread) | Higher (IPC overhead) |
| **Persistence** | Saved with session | Requires manual startup |
| **Complexity** | GUI configuration | Code maintenance |
| **Reliability** | Tested, stable | Custom debugging |

**Limitation:** x42 MIDI plugins are **one-way** (MIDI in → MIDI out). They **cannot send SysEx for Launchpad RGB LED control**. For LED feedback, Python scripting is still required.

#### Recommended SG9 Studio MIDI Chain

```
┌─────────────────┐
│ Launchpad Pads  │
└────────┬────────┘
         │ MIDI Notes
         ▼
┌─────────────────────────┐
│ x42 MIDI Velocity Adjust│  ← Normalize pad velocities
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ x42 MIDI Keysplit       │  ← Route rows to tracks
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ Ardour Clip Triggering  │
└─────────────────────────┘

┌─────────────────┐
│ Python Script   │  ← Separate: OSC → SysEx for LED feedback
│ (LED Control)   │
└─────────────────┘
```

**This hybrid approach provides:**
- **Professional MIDI processing** (x42 plugins)
- **Visual feedback** (Python for LEDs)
- **Session persistence** (x42 saved with Ardour)
- **Low latency** (x42 in audio thread)

---

### 12.3 Gain Staging Targets

| Stage | Target Level | Notes |
| --- | --- | --- |
| Vocaster input (hardware meter) | -12 to -6 dB | Adjust Host/Guest Gain knob |
| Ardour track input (pre-plugin) | -18 to -12 dBFS | Verify on Track 1 meter |
| Track output (post-plugin chain) | -6 to -3 dBFS | After limiter, healthy signal |
| Bus outputs (Voice, Music, etc.) | -6 to -3 dBFS | Pre-Mixbus |
| Master input (pre-limiter) | -6 to -3 dBFS | Mixbus → Master |
| Master output (post-limiter) | -1.0 dBTP ceiling | Integrated loudness per target |

---

### 12.4 Loudness Targets

| Format | Integrated LUFS | True Peak Max | Master Limiter Threshold (Approx) |
| --- | ---: | --- | --- |
| **Podcast (stereo)** | -16 LUFS ± 1 LU | -1.0 dBTP | -10 to -6 dB |
| **Broadcast (EBU R128)** | -23 LUFS ± 0.5 LU | -1.0 dBTP | -17 to -13 dB |

**Loudness Range (LRA):**
- Podcast: 4–10 LU (moderate compression, engaging)
- Broadcast: 5–15 LU (more dynamic)

---

### 12.5 nanoKONTROL Studio MIDI Map

| Control | MIDI CC# | SG9 Assignment | Purpose |
| --- | ---: | --- | --- |
| Fader 1 | CC 0 | VCA 1 (All Voices) | Voice level control |
| Fader 2 | CC 1 | VCA 2 (All Music) | Music level control |
| Fader 3 | CC 2 | VCA 3 (All Content) | Content level control |
| Fader 4 | CC 3 | VCA 4 (Master Fader) | Master output level |
| Fader 5 | CC 4 | Voice Bus | Voice bus direct control |
| Fader 6 | CC 5 | Music Bus | Music bus direct control |
| Fader 7 | CC 6 | Production Bus | Production bus direct control |
| Fader 8 | CC 7 | Content Bus | Content bus direct control |
| Knob 1–4 | CC 16–19 | Aux sends | Track 1, 5, 7, Music Bus sends |
| Solo 1–8 | CC 32–39 | Solo tracks | Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Mute 1–8 | CC 48–55 | Mute tracks | Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Rec 1–8 | CC 64–71 | Arm tracks | Tracks 1, 5, 7, 9, 11, 13, 15, 17 |
| Play | Note 41 | Transport Play | Start playback |
| Stop | Note 42 | Transport Stop | Stop playback |
| Record | Note 45 | Transport Record | Start recording |
| Cycle | Note 46 | Loop Toggle | Enable/disable loop |

---

### 12.6 Launchpad Pro Mk2 Grid Layout

**8x8 Pad Grid (Row assignments):**

| Row | Track | Color | Content Examples |
| ---: | --- | --- | --- |
| 8 (top) | 11 (Intro Jingles) | Purple (53) | Intro A, Intro B, Intro C, etc. |
| 7 | 12 (Outro Jingles) | Purple (53) | Outro A, Outro B, etc. |
| 6 | 13 (Bumpers) | Purple (53) | Transition stingers |
| 5 | 14 (Sound FX) | Green (21) | Applause, laughter, ambiance |
| 4 | 15 (Stingers) | Orange (9) | Quick hits, punctuation |
| 3 | 16 (Sponsor Ads) | Yellow (13) | Pre-recorded spots |
| 2 | 17 (Station IDs) | Cyan (37) | Legal IDs, branding |
| 1 (bottom) | 18 (PSA / Promos) | Blue (45) | PSAs, promos |

**Top Function Buttons:**
- Button 1–4: Play, Stop, Record, Loop Toggle
- Button 5–7: Session Save, Undo, Redo

**Right Scene Buttons:** Launch entire row (all 8 clips in row simultaneously)

**LED States:**
- Off (0): Empty slot
- Dim (low velocity): Clip loaded, stopped
- Bright (full RGB): Clip playing
- Flashing: Clip queued

---

### 12.7 Track Color Coding Reference

| Track Type | Hex Code | Launchpad Velocity | RGB |
| --- | --- | ---: | --- |
| Voice/Mic (1–4) | `#FF4444` | 5 | 127, 0, 0 |
| External (5–7) | `#FF8800` | 9 | 127, 64, 0 |
| Music (8–10) | `#4488FF` | 45 | 0, 64, 127 |
| Jingles (11–13) | `#AA44FF` | 53 | 96, 0, 127 |
| SFX (14) | `#44FF88` | 21 | 0, 127, 64 |
| Stingers (15) | `#FF8800` | 9 | 127, 64, 0 |
| Ads (16) | `#FFFF44` | 13 | 127, 127, 0 |
| IDs (17) | `#00FFFF` | 37 | 0, 127, 127 |
| PSA (18) | `#4488FF` | 45 | 0, 64, 127 |
| Voice Bus | `#FFFF44` | 13 | 127, 127, 0 |
| Music Bus | `#4488FF` | 45 | 0, 64, 127 |
| Production Bus | `#AA44FF` | 53 | 96, 0, 127 |
| Content Bus | `#44FF88` | 21 | 0, 127, 64 |
| Master Bus | `#FF0000` | 5 | 127, 0, 0 |

---

### 12.8 Troubleshooting Decision Trees

**Problem: Voice sounds muddy/boxy**
1. Check LSP EQ low-mid cut (200–400 Hz): increase cut to -6 dB
2. Check HPF frequency: raise to 100–120 Hz if too much low-end
3. Verify proximity effect (mic too close): increase distance or boost HPF
4. Check for phase issues if multiple mics: flip phase on one channel

**Problem: Sibilance too harsh**
1. Check Calf Deesser threshold: lower to engage more often
2. Check Deesser ratio: increase to 4:1 or 6:1
3. Check Split frequency: adjust to 5–7 kHz to target sibilance range
4. Fine-tune Peak Freq/Level to target specific harsh frequencies
5. Check EQ high-shelf: reduce +10 kHz boost or cut instead
6. Verify de-esser is BEFORE compressor (compression amplifies sibilance)

**Alternative (LSP-only workflow):**
- Use LSP Compressor with sidechain HPF @ 5–7 kHz instead of Calf Deesser

**Problem: Compression sounds pumping/breathing**
1. Check LSP Compressor release: slow down to 200–300 ms
2. Check ratio: reduce from 6:1 to 3:1 or 4:1
3. Check threshold: raise to reduce gain reduction (aim for 3–6 dB max)
4. Check attack: slow down to 20–30 ms for more transparent compression

**Problem: Launchpad pads not triggering clips**
1. Verify Programmer mode is active (press Setup, tap top-right pad)
2. Check MIDI connection: Ardour Preferences → Control Surfaces → Generic MIDI → Launchpad Port 3
3. Verify clips are loaded in Ardour Clips view
4. Use MIDI Learn: right-click clip slot → MIDI Learn → press pad
5. Check MIDI monitor (aconnect -l) to verify pad is sending MIDI

**Problem: nanoKONTROL faders controlling wrong tracks**
1. Check binding XML file path is correct in Ardour preferences
2. Verify track/bus names in XML match Ardour exactly (case-sensitive)
3. Reload Generic MIDI control surface (disable/re-enable)
4. Check nanoKONTROL is in DAW mode (not CC mode)

**Problem: Remote guest hears themselves (echo)**
1. Verify Mix A (N-1) mutes all PCM/loopback returns in alsa-scarlett-gui
2. Check Zoom/Skype input is set to Mix A output, NOT Master
3. Verify Loopback 2 is NOT routed back into Mix A
4. Test: remote should only hear you, not themselves

**Problem: Integrated loudness off-target**
1. Measure with Ardour Loudness Analyzer over FULL program (don't pause)
2. Too quiet (e.g., -18 LUFS, target -16): Lower Master Limiter threshold by ~2 dB
3. Too loud (e.g., -14 LUFS, target -16): Raise Master Limiter threshold by ~2 dB
4. Re-export and re-measure until within ±0.5 LU of target
5. Verify limiter ceiling is -1.0 dBTP and oversampling is 8x

**Problem: True Peak violations (> -1.0 dBTP)**
1. Check Master Limiter oversampling is set to 4x or 8x
2. Verify ceiling is set to -1.0 dBTP (not -1.0 dBFS)
3. If still overs, reduce ceiling to -1.5 dBTP
4. Check for inter-sample peaks in stereo widening plugins

---

### 12.9 Daily Pre-Show Checklist (5 minutes)

| Step | Check | Expected Result |
| ---: | --- | --- |
| 1 | Power on Vocaster Two | Front panel LEDs light up |
| 2 | Open alsa-scarlett-gui | Saved routing loads automatically |
| 3 | Verify Aux/Loopback routing | Levels tab shows correct mapping |
| 4 | Connect nanoKONTROL Studio + Launchpad Pro Mk2 (USB) | aconnect -l shows both devices |
| 5 | Open Ardour, load SG9 session | Session loads without errors |
| 6 | Speak into Host mic | Track 1 meter peaks -12 to -6 dBFS |
| 7 | Verify gate opens cleanly | No chopping on speech onset |
| 8 | Check compressor gain reduction | 3–6 dB on normal speech |
| 9 | Verify Master output | ≤ -1.0 dBTP, no overs |
| 10 | Test nanoKONTROL faders | Fader 4 controls Master level |
| 11 | Test Launchpad pads | Tap pad → clip triggers, LED lights |
| 12 | If remote guest: verify N-1 | Remote hears you, not themselves |
| 13 | If music beds: test ducking | Music drops when you speak, recovers smoothly |
| 14 | Arm required tracks | Track 1 always, Track 7 if remote, Track 5 if Aux |
| 15 | Set Guest headphone level | Comfortable monitoring volume |

**Ready to record/broadcast!**

---

### 12.10 Calibration Targets Summary

| Parameter | Value | How to Verify |
| --- | --- | --- |
| Vocaster Host Gain | -12 to -6 dB | Hardware meter on Vocaster |
| Ardour Track 1 Input | -18 to -12 dBFS | Pre-plugin meter |
| Track 1 Output | -6 to -3 dBFS | Post-plugin meter |
| Compressor Gain Reduction | 3–6 dB | LSP Compressor GR meter |
| Master Output Ceiling | -1.0 dBTP | Ardour True Peak meter |
| Integrated Loudness (Podcast) | -16 LUFS ± 1 LU | Ardour Loudness Analyzer |
| Integrated Loudness (Broadcast) | -23 LUFS ± 0.5 LU | Ardour Loudness Analyzer |
| Phase Correlation | > +0.3 | Ardour Phase Meter |
| Loudness Range (LRA) | 4–10 LU (podcast), 5–15 LU (broadcast) | Ardour Loudness Analyzer |

---

## 13) Appendix: Studio Signal Flow (Conceptual)

- Inputs (mics/Aux/BT/loopbacks) → Ardour tracks → group buses → Mixbus → Master
- Master → Vocaster USB playback → Guest headphones (daily monitor)
- Talkback is routed to a dedicated output only and excluded from Master

Note: because monitors and Host headphones share the same destination, any “talkback-only” routing that targets Host headphones can also reach the monitor outputs. The recommended mitigation is operational: keep monitor volume at 0 / muted during talkback use.
