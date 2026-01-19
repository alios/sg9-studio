# SG9 Studio - Verified Plugin Research Document
**Last Updated:** January 18, 2026  
**Status:** Verified against official documentation

---

## ⚠️ CRITICAL CORRECTION

**Previous documentation contained hallucinated plugins that do NOT exist:**
- ~~LSP DeEsser Mono~~ - **DOES NOT EXIST**
- LSP does not include a standalone de-esser plugin

**Verified de-essing solutions:**
1. **Calf Deesser** (recommended - dedicated de-esser plugin)
2. **LSP Compressor** with sidechain filtering (alternative method)
3. **TAP DeEsser** (LADSPA legacy, simple but functional)

---

## Table of Contents

1. [Verified Plugin Suites](#verified-plugin-suites)
2. [LSP Plugins Reference](#lsp-plugins-reference)
3. [Calf Studio Gear Reference](#calf-studio-gear-reference)
4. [TAP Plugins Reference](#tap-plugins-reference)
5. [ZAM Plugins Reference](#zam-plugins-reference)
6. [De-essing Methods Compared](#de-essing-methods-compared)
7. [Broadcast Voice Processing Chain](#broadcast-voice-processing-chain)
8. [Source Links](#source-links)

---

## 1. Verified Plugin Suites

### Installed on SG9 Studio

| Suite | Version (Jan 2026) | Format | Status | Website |
| --- | --- | --- | --- | --- |
| **LSP Plugins** | 1.2.26+ | LV2, VST2/3, CLAP | Active | https://lsp-plug.in/ |
| **Calf Studio Gear** | 0.90.9+ | LV2, LADSPA | Active | https://calf-studio-gear.org/ |
| **TAP Plugins** | 0.7.3 | LADSPA only | Inactive (~2014) | https://tomscii.sig7.se/tap-plugins/ |
| **ZAM Plugins** | 4.4+ | LV2, VST2/3, LADSPA | Active (2024) | http://www.zamaudio.com/ |

### Installation Commands

```bash
# NixOS (declarative - add to configuration.nix)
environment.systemPackages = with pkgs; [
  lsp-plugins
  calf
  tap-plugins
  zam-plugins
  x42-plugins  # MIDI utilities for professional workflows
];

# NixOS (imperative)
nix-env -iA nixos.lsp-plugins nixos.calf nixos.tap-plugins nixos.zam-plugins nixos.x42-plugins

# Arch/Manjaro
sudo pacman -S lsp-plugins calf tap-plugins zam-plugins x42-plugins

# Ubuntu/Debian
sudo apt install lsp-plugins-lv2 calf-plugins tap-plugins zam-plugins x42-plugins

# Verify
ls /nix/store/*lsp-plugins*/lib/lv2/  # NixOS
ls /usr/lib/lv2/ | grep -E '(lsp|calf|zam|x42)'  # Traditional distros
ls /usr/lib/ladspa/ | grep -i tap
```

---

## 2. LSP Plugins Reference

**Official Sources:**
- Website: https://lsp-plug.in/
- GitHub: https://github.com/lsp-plugins/lsp-plugins
- Documentation: https://lsp-plug.in/?page=manuals

### 2.1 Broadcast-Relevant LSP Plugins (Verified)

#### ✅ LSP Parametric Equalizer (x8, x16, x32 variants)

**Variants:** Mono, Stereo, LeftRight, MidSide  
**Available:** x8 (8 bands), x16 (16 bands), x32 (32 bands)

**SG9 Studio Recommendation:** Use **x8 variant** (SG9 voice chain uses 6-7 bands maximum)

**Filter Types:**
- Off, Bell, Hi-pass, Lo-pass, Hi-shelf, Lo-shelf, Notch, Resonance, Allpass, Bandpass

**Parameters (Per Band):**
- Frequency: 10 Hz to 20 kHz
- Gain: -24 dB to +24 dB (for gain-adjustable filters)
- Q: 0.1 to 10.0
- Slope: 6/12/18/24 dB/oct (for filters)

**Processing Modes:**
- IIR (Infinite Impulse Response - minimal latency)
- FIR (Finite Impulse Response - linear phase, adds latency)
- FFT (Fast Fourier Transform - linear phase)
- SPM (Spectral Processor Mode)

---

#### ✅ LSP Compressor (Mono/Stereo/LeftRight/MidSide)

**Compression Modes:**
- Downward (traditional - reduces loud signals)
- Upward (amplifies quiet signals)
- Boosting (upward with precise boost control)

**Parameters:**
- **Threshold:** -60 dB to 0 dB
- **Ratio:** 1:1 to 100:1
- **Attack:** 0.0 ms to 2000 ms
- **Release:** 0.0 ms to 5000 ms
- **Knee:** 0.0 dB to 30.0 dB
- **Makeup Gain:** 0 dB to +60 dB

**Sidechain Controls:**
- Position: Feed-forward / Feed-back / Link
- Preamp: -60 dB to +60 dB
- Reactivity: 0 to 250 ms
- Lookahead: 0 ms to 20 ms
- Type: Peak / RMS / LPF / SMA
- HPF/LPF: 10 Hz to 20 kHz (with slope control)

**De-essing with LSP Compressor (Professional Broadcast Technique):**

Since LSP does not have a standalone de-esser, use sidechain compression—the **industry standard in professional broadcast studios**:

1. **Sidechain → Internal** (process its own signal)
2. **Enable SC High-Pass Filter**
3. **SC HPF Frequency: 5–7 kHz**
4. **SC HPF Slope: 12 dB/oct (x2)**
5. **Threshold: -20 to -12 dB**
6. **Ratio: 3:1 to 6:1**
7. **Attack: 1–5 ms**
8. **Release: 50–100 ms**

This creates frequency-selective compression targeting sibilants.

**Why sidechain is professional standard:**
- Used in broadcast radio/TV studios worldwide
- More precise frequency targeting than fixed-algorithm de-essers
- Same technique applies to ducking, multiband processing
- Greater control over detection and reduction characteristics

---

#### ✅ LSP Gate (Mono/Stereo/LeftRight/MidSide)

**Parameters:**
- **Threshold:** -96 dB to 0 dB
- **Attack:** 0.0 ms to 250 ms
- **Release:** 0.0 ms to 5000 ms
- **Hold:** 0.0 ms to 2000 ms
- **Reduction:** -96 dB to 0 dB
- **Hysteresis:** Enable/disable with separate threshold and zone controls

**Sidechain:** Same controls as LSP Compressor

---

#### ✅ LSP Limiter (Mono/Stereo/LeftRight/MidSide)

**Modes:**
- Classic (traditional brick-wall)
- Modern (enhanced lookahead)
- Gentle (soft-knee)
- Mixed

**Parameters:**
- **Threshold:** -24 dB to 0 dB
- **Knee:** 0.0 dB to 10.0 dB
- **Lookahead:** 0 ms to 20 ms
- **Release:** 1 ms to 1000 ms
- **Oversampling:** 1x, 2x, 4x, 8x
- **True Peak limiting support**

**Broadcast Settings:**
- Mode: Modern
- Threshold: -6 to -3 dB (adjust for loudness target)
- Ceiling: -1.0 dBTP (True Peak)
- Lookahead: 5–10 ms
- Oversampling: 4x or 8x

---

#### ✅ LSP Multiband Compressor (x4, x8 variants)

**Variants:** Mono, Stereo, LeftRight, MidSide  
**Bands:** x4 (4-band), x8 (8-band)

**Features:**
- Independent threshold/ratio/attack/release per band
- Crossover slopes: 12/24/36/48 dB/oct
- Can be used for de-essing (use top band for sibilance)

---

### 2.2 LSP Plugins NOT Included

❌ **LSP DeEsser** - Does not exist  
❌ Dedicated de-esser of any kind

---

## 3. Calf Studio Gear Reference

**Official Sources:**
- Website: https://calf-studio-gear.org/
- GitHub: https://github.com/calf-studio-gear/calf
- Documentation: https://calf-studio-gear.org/doc/

### 3.1 Broadcast-Critical Calf Plugins (Verified)

#### ✅ Calf Deesser

**Purpose:** Specialized sidechain compressor for high-frequency sibilance reduction

**Parameters:**

| Parameter | Range | Typical Values | Description |
| --- | --- | --- | --- |
| **Detection** | Peak / RMS | Peak | Sidechain detection mode |
| **Mode** | Wideband / Split | Split | Split = only high frequencies affected |
| **Threshold** | -60 dB to 0 dB | -20 to -12 dB | Level that triggers de-essing |
| **Ratio** | 1:1 to 20:1 | 2:1 to 4:1 | Compression ratio |
| **Laxity** | 1 ms to 100 ms | 15–30 ms | Reaction time (higher = ignores short peaks) |
| **Split** | 1 kHz to 16 kHz | 5–7 kHz | Crossover frequency (split mode) |
| **Gain** | -15 dB to +15 dB | 0 dB | High-band boost/cut (split mode) |
| **Makeup** | 0 dB to +24 dB | 0 dB | High-band makeup gain (split mode) |
| **Peak Freq** | 1 kHz to 16 kHz | 5.5–6.5 kHz | Bell filter frequency for precision |
| **Peak Level** | -15 dB to +15 dB | +3 to +6 dB | Bell filter boost/cut |
| **Peak Q** | 0.1 to 10.0 | 2.0–4.0 | Bell filter width |

**Visual Feedback:**
- **Detected:** Level meter (shows sidechain detection)
- **Gain Reduction:** Active reduction meter
- **S/C Listen:** Monitor sidechain (filtered) signal

**Typical Sibilance Frequencies (from official docs):**
- Male "shhhh": 3500–4000 Hz
- Female "shhhh": 4000–4500 Hz
- Male "ssss": 4500–5000 Hz
- Female "ssss": 5000–5500 Hz

**Broadcast Setup:**
1. Mode: **Split**
2. Detection: **Peak**
3. Split: **5–7 kHz** (male: 5 kHz, female: 7 kHz)
4. Threshold: **-20 to -12 dB**
5. Ratio: **2:1** (increase to 4:1 if needed)
6. Laxity: **15–30 ms**
7. Peak Freq/Level/Q: Fine-tune to target specific harsh frequency

---

#### ✅ Calf Sidechain Compressor

**Purpose:** Full sidechain compression with two independent filters (perfect for music ducking)

**Parameters:**

| Parameter | Range | Typical for Ducking |
| --- | --- | --- |
| **Threshold** | -60 dB to 0 dB | -30 to -24 dB |
| **Ratio** | 1:1 to 20:1 | 4:1 to 6:1 |
| **Attack** | 0.01 ms to 2000 ms | 10–20 ms |
| **Release** | 0.01 ms to 5000 ms | 300–500 ms |
| **Knee** | 1.0 to 8.0 | 4–6 |
| **Makeup** | 0 dB to +24 dB | Compensate for reduction |
| **Stereo Link** | Average / Louder channel | Average |
| **Detection** | Peak / RMS | RMS |

**Sidechain Filters:**
- **F1 Freq/Level:** First filter (frequency/boost-cut)
- **F1 Type:** Bell, Shelving, Highpass, Lowpass, Bandpass
- **F2 Freq/Level:** Second filter (frequency/boost-cut)
- **F2 Type:** Bell, Shelving, Highpass, Lowpass, Bandpass

**Split Mode:**
- Only frequencies above/below split point are compressed
- Rest of spectrum untouched
- Perfect for frequency-specific dynamics

**Music Ducking Setup:**
1. Insert on Music Bus
2. Sidechain Input: Voice Bus send
3. Threshold: **-30 to -24 dB**
4. Ratio: **4:1 to 6:1**
5. Attack: **10–20 ms** (fast enough to respond to speech)
6. Release: **300–500 ms** (music recovers smoothly)
7. Use **S/C Listen** to verify voice is triggering compression

---

#### ✅ Other Calf Dynamics Plugins

**Calf Compressor:** Standard wideband compressor  
**Calf Multiband Compressor:** 4-band frequency-specific dynamics  
**Calf Limiter:** Brick-wall limiting with ASC mode  
**Calf Gate:** Standard noise gate  
**Calf Transient Designer:** Attack/sustain shaping

**Calf EQ Plugins:**
- 5-Band Equalizer
- 8-Band Equalizer
- 12-Band Equalizer
- 30-Band Equalizer (graphic)

**Calf Utility:**
- **Stereo Tools:** Width, balance, phase
- **Analyzer:** Spectrum/goniometer/stereo analyzer

---

## 4. TAP Plugins Reference

**Official Source:**
- Website: https://tomscii.sig7.se/tap-plugins/
- Format: LADSPA only
- Status: **Inactive** (last update ~2014)

### 4.1 Broadcast-Relevant TAP Plugins (Verified)

#### ✅ TAP DeEsser

**Format:** LADSPA only (mono)  
**CPU Usage:** 5.9% @ 44.1 kHz, 12.8% @ 96 kHz

**Parameters:**

| Parameter | Range | Values | Description |
| --- | --- | --- | --- |
| **Threshold Level** | -50 dB to +10 dB | -20 to -10 dB | Signal level for attenuation |
| **Frequency** | 2000 Hz to 16000 Hz | See table below | Sidechain filter frequency |
| **Sidechain Filter** | Highpass / Bandpass | Highpass (general) / Bandpass (specific) | Detection filter type |
| **Monitor** | Audio / Sidechain | Sidechain for setup | Listen to detection signal |

**Fixed Parameters (Non-Adjustable):**
- Attack/Release: **10 ms** (instant operation)
- Ratio: **1:2** compression (fixed)

**Recommended Frequencies (from official docs):**
- Male "ess": **4500 Hz**
- Male "ssh": **3400 Hz**
- Female "ess": **6800 Hz**
- Female "ssh": **5100 Hz**

**Operation:**
- **Highpass mode:** Attenuates multiple 'ess' sounds
- **Bandpass mode:** Targets specific frequency

**Limitations:**
- LADSPA format only (no LV2)
- Fixed attack/release (no user control)
- Fixed ratio (no adjustment)
- Mono only (stereo requires two instances)
- No visual feedback (no meters)
- Simple compared to modern de-essers

**When to Use:**
- Quick, simple de-essing on mono tracks
- Legacy workflows
- Low CPU usage priority
- "Set and forget" operation

---

#### ✅ TAP Dynamics (Mono/Stereo)

**Format:** LADSPA only

**Parameters:**

| Parameter | Range | Description |
| --- | --- | --- |
| **Function** | 0–14 (15 presets) | Preset dynamics curves |
| **Attack** | 4 ms to 500 ms | Envelope attack time |
| **Release** | 4 ms to 1000 ms | Envelope release time |
| **Offset Gain** | -20 dB to +20 dB | Input gain adjustment |
| **Makeup Gain** | -20 dB to +20 dB | Output gain compensation |
| **Stereo Mode** | Independent / Average / Peak | Channel linking (stereo only) |

**Preset Functions:**
- Functions 0–4: Soft to moderate compressors
- Functions 5–9: Broadcast-style compressors (higher ratios)
- Functions 10–12: Limiters
- Function 13–14: Expanders/gates

**Limitations:**
- **Preset curves only** (no continuous threshold/ratio adjustment)
- Less flexible than modern compressors
- Good for vintage-style dynamics or quick "character" compression

---

#### ✅ TAP Equalizer / TAP Equalizer BW

**Format:** LADSPA only

- 8-band graphic EQ
- BW version: Bandwidth control per band

---

## 5. ZAM Plugins Reference

**Official Sources:**
- Website: http://www.zamaudio.com/
- GitHub: https://github.com/zamaudio/zam-plugins
- Format: LV2, LADSPA, VST2, VST3, JACK
- Status: **Active** (June 2024 releases)

### 5.1 Broadcast-Relevant ZAM Plugins (Verified)

#### ✅ ZamComp / ZamCompX2

**Purpose:** General-purpose compressor

- **ZamComp:** Mono
- **ZamCompX2:** Stereo

**Parameters:**
- Threshold, Ratio, Attack, Release, Knee, Makeup
- Similar to LSP/Calf compressors
- Clean, transparent compression
- **No sidechain capabilities** (unlike LSP)

**When to Use:**
- Alternative to LSP/Calf compressors
- Modern, actively maintained
- Clean, neutral sound

---

#### ✅ ZamGate / ZamGateX2

**Purpose:** Noise gate

- **ZamGate:** Mono
- **ZamGateX2:** Stereo

**Parameters:**
- Threshold, Attack, Release, Hold

**When to Use:**
- Alternative to LSP Gate
- Simpler interface

---

#### ✅ ZamMultiComp / ZamMultiCompX2

**Purpose:** 3-band multiband compressor

- **ZamMultiComp:** Mono
- **ZamMultiCompX2:** Stereo

**Features:**
- 3 bands (Low, Mid, High)
- Independent threshold/ratio/attack/release per band
- Fixed crossover points
- Simpler than LSP Multiband (3 bands vs 4/8)

**When to Use:**
- Basic multiband dynamics
- Alternative to LSP Multiband Compressor
- Music bus or master bus processing
- Lighter CPU load than LSP

---

#### ✅ ZamDynamicEQ

**Purpose:** Dynamic equalization (frequency-selective compression)

**Could be used for de-essing:**
- Target specific frequency bands dynamically
- More complex than dedicated de-esser
- **Experimental/untested** for SG9 Studio use

---

#### ✅ Other ZAM Plugins

- **ZaMaximX2:** Stereo maximizer/limiter
- **ZamEQ2:** 2-band parametric EQ
- **ZamGEQ31:** 31-band graphic EQ
- **ZamChild670:** Fairchild 670 emulation (vintage compressor)
- **ZamTube:** Tube saturation/distortion
- **ZamAutoSat:** Automatic saturation

---

## 6. De-essing Methods Compared

### Method Summary

| Method | Plugin | Difficulty | Quality | CPU | Format | Best For |
| --- | --- | --- | --- | --- | --- | --- |
| **1. Calf Deesser** | Calf Deesser | Easy | Excellent | Low | LV2 | **SG9 Default** |
| **2. LSP Sidechain** | LSP Compressor | Medium | Excellent | Low | LV2 | LSP-only workflows |
| **3. TAP DeEsser** | TAP DeEsser | Easy | Good | Very Low | LADSPA | Quick/simple mono |
| **4. LSP Multiband** | LSP Multiband Comp | Hard | Excellent | Medium | LV2 | Advanced multiband |

### Detailed Comparison

#### **Method 1: Calf Deesser (RECOMMENDED for SG9 Studio)**

**Pros:**
- Dedicated de-esser plugin
- Split mode (only affects high frequencies)
- Precision Peak Freq/Level/Q controls
- Visual feedback (Gain Reduction meter, S/C Listen)
- Familiar broadcast-style interface

**Cons:**
- Requires Calf plugin suite

**Setup:**
1. Insert **Calf Deesser** after EQ, before compression
2. Mode: **Split**
3. Detection: **Peak**
4. Split: **5–7 kHz**
5. Enable **S/C Listen**, adjust **Peak Freq** to target sibilance
6. Threshold: **-20 to -12 dB**
7. Ratio: **2:1** (increase to 4:1 if needed)
8. Watch **Gain Reduction** meter: 3–6 dB on "S" sounds

---

#### **Method 2: LSP Compressor with Sidechain (Professional Broadcast Standard)**

**Pros:**
- **Industry-standard technique** used in professional broadcast studios worldwide
- Uses LSP suite only (consistent workflow)
- **Highly precise frequency targeting** via sidechain filters
- CPU-efficient
- **More control than fixed-algorithm de-essers**
- Transferable skill (applies to ducking, multiband compression)

**Cons:**
- Requires understanding of sidechain concepts
- No visual sibilance detection (use spectrum analyzer instead)
- Must configure from scratch (no presets)

**Setup:**
1. Insert **LSP Compressor Mono**
2. Sidechain: **Internal**
3. Enable **SC High-Pass Filter: 5–7 kHz, 12 dB/oct**
4. Threshold: **-20 to -12 dB**
5. Ratio: **3:1 to 6:1**
6. Attack: **1–5 ms**, Release: **50–100 ms**

**Why this is professional standard:**
- Used in broadcast radio/TV studios globally
- More precise than fixed-frequency de-essers
- Same technique for music ducking, multiband processing
- Greater control over detection and reduction

---

#### **Method 3: TAP DeEsser**

**Pros:**
- Simple, single-purpose
- Low CPU usage
- Predictable results

**Cons:**
- LADSPA only (no LV2)
- Fixed attack/release (10 ms)
- Fixed ratio (1:2)
- Mono only
- No visual feedback

**Setup:**
1. Insert **TAP DeEsser** on mono track
2. Frequency: **4500 Hz** (male) or **6800 Hz** (female)
3. Sidechain Filter: **Highpass** (general) or **Bandpass** (specific)
4. Threshold: **-20 to -10 dB**

---

## 7. Broadcast Voice Processing Chain

### Recommended SG9 Studio Chain

**Order of Processing:**

1. **Gate** → LSP Gate Mono
2. **High-Pass Filter** → LSP Parametric EQ x8 Mono (Band 1, Hi-pass @ 80–100 Hz)
3. **De-Esser** → **Calf Deesser** (recommended) OR LSP Compressor with sidechain (professional)
4. **Parametric EQ** → LSP Parametric EQ x8 Mono (voice curve, 6-7 bands)
5. **Compressor** → LSP Compressor Mono (main dynamics)
6. **Limiter** → LSP Limiter Mono (safety/True Peak)

### Detailed Settings

#### 1. LSP Gate Mono

- Threshold: **-40 to -35 dB**
- Attack: **0.5–2 ms**
- Release: **200–400 ms**
- Hold: **150–200 ms**
- Reduction: **-20 to -30 dB**
- Hysteresis: **On** (prevents gate chattering)
- SC HPF: **100 Hz, x2 slope** (prevent bass triggering)

#### 2. LSP Parametric EQ (HPF)

- Band 1: **Hi-pass, 80–100 Hz, 18 dB/oct (x3)**
- Purpose: Remove rumble, handling noise, proximity effect

#### 3. Calf Deesser (De-essing)

- Detection: **Peak**
- Mode: **Split**
- Split: **5–7 kHz** (male: 5 kHz, female: 7 kHz)
- Threshold: **-20 to -12 dB**
- Ratio: **2:1 to 4:1**
- Laxity: **15–30 ms**
- Peak Freq: **5.5–6.5 kHz** (fine-tune)
- Peak Level: **+3 to +6 dB**
- Peak Q: **2.0–4.0**

**Alternative:** LSP Compressor with SC HPF @ 5–7 kHz

#### 4. LSP Parametric EQ (Voice Curve)

| Band | Type | Frequency | Gain | Q | Purpose |
| ---: | --- | ---: | ---: | ---: | --- |
| 2 | Bell | 200–250 Hz | -3 to -6 dB | 1.0–1.5 | Reduce muddiness |
| 3 | Lo-shelf | 100–150 Hz | +2 to +4 dB | 0.7 | Add warmth |
| 4 | Bell | 2.5–4 kHz | +3 to +6 dB | 1.5–2.5 | Presence boost |
| 5 | Hi-shelf | 10–12 kHz | +2 to +4 dB | 0.5–0.7 | Air/brilliance |
| 6 | Lo-pass | 15–18 kHz | — | — | Optional noise reduction |

#### 5. LSP Compressor Mono (Main Dynamics)

- Mode: **Downward**
- Threshold: **-18 to -12 dB**
- Ratio: **3:1 to 4:1**
- Attack: **10–20 ms**
- Release: **100–200 ms** (or Auto)
- Knee: **6–9 dB** (soft knee)
- Makeup Gain: **+3 to +8 dB**
- SC HPF: **100 Hz, x2** (prevent bass triggering)

#### 6. LSP Limiter Mono (Safety)

- Mode: **Modern**
- Threshold: **-6 to -3 dB**
- Ceiling: **-1.0 dBTP** (True Peak - non-negotiable)
- Release: **100–200 ms**
- Lookahead: **5–10 ms**
- Oversampling: **4x or 8x**

---

## 8. Source Links

### Official Documentation

**LSP Plugins:**
- Website: https://lsp-plug.in/
- GitHub: https://github.com/lsp-plugins/lsp-plugins
- Manuals: https://lsp-plug.in/?page=manuals

**Calf Studio Gear:**
- Website: https://calf-studio-gear.org/
- GitHub: https://github.com/calf-studio-gear/calf
- Deesser docs: https://calf-studio-gear.org/doc/Deesser.html
- Sidechain Compressor docs: https://calf-studio-gear.org/doc/Sidechain%20Compressor.html

**TAP Plugins:**
- Website: https://tomscii.sig7.se/tap-plugins/
- DeEsser docs: https://tomscii.sig7.se/tap-plugins/ladspa/deesser.html
- Dynamics docs: https://tomscii.sig7.se/tap-plugins/ladspa/dynamics.html

**ZAM Plugins:**
- Website: http://www.zamaudio.com/
- GitHub: https://github.com/zamaudio/zam-plugins

### Community Resources

- Linux Musicians: https://linuxmusicians.com/
- Libre Music Production: http://libremusicproduction.com/
- Ardour Forums: https://discourse.ardour.org/
- KVR Audio (LSP): https://www.kvraudio.com/plugins/lsp

---

## Verification Statement

This document has been verified against official documentation from:
- LSP Plugins GitHub repository (tag 1.2.26)
- Calf Studio Gear official documentation (version 0.90.9)
- TAP Plugins official website (version 0.7.3)
- ZAM Plugins GitHub repository (release 4.4)

All plugin names, parameters, and capabilities have been cross-referenced with authoritative sources as of January 18, 2026.

**No hallucinated plugins or features are included in this document.**

---

## Change Log

**Version 2.0 - January 18, 2026:**
- Complete rewrite with verified plugin information
- Removed all references to non-existent "LSP DeEsser"
- Added Calf Deesser as primary de-essing solution
- Added LSP Compressor sidechain method for de-essing
- Added TAP and ZAM plugin documentation
- Verified all parameters against official sources
- Added comprehensive de-essing methods comparison

**Version 1.0 - [Previous Date]:**
- Initial document (contained hallucinated plugins - deprecated)

---

**END OF VERIFIED RESEARCH DOCUMENT**
