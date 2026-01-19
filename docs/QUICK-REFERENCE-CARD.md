# SG9 Studio — Quick Reference Card

**For printing and laminating — place on desk next to controllers**

---

## 🎛️ nanoKONTROL Studio Fader Map

| Fader | Track | Color | Function |
|-------|-------|-------|----------|
| **1** | Host Mic (DSP) | 🔴 Red | Your voice (processed) |
| **2** | Host Mic (Raw) | 🔴 Dark Red | Safety recording |
| **3** | Guest Mic | 🔵 Blue | Local guest |
| **4** | Aux Input | 🔵 Blue | Phone/tablet audio |
| **5** | Bluetooth | 🔵 Cyan | Wireless audio |
| **6** | Remote Guest | 🔵 Blue | VoIP/phone patch |
| **7** | Music 1 | 🟢 Green | Intro/outro music |
| **8** | Music 2 | 🟢 Green | Music beds |

**Encoders (Knobs):** Track panning, plugin parameters (HPF, Compressor, EQ)  
**Buttons:** Solo (row 1), Mute (row 2), Arm (row 3)  
**Transport:** Play, Stop, Record, Loop

---

## 🟥 Launchpad Mk2 Grid Layout

```
┌────────────────────────────────────────┬──────┐
│ TOP ROW: TRANSPORT                     │ 89   │
│ 104  105  106  107  108  109  110  111 │Scene │
│ Play Stop Rec  Loop Rew  FFwd Home End │      │
├────────────────────────────────────────┼──────┤
│ ROW 1: TRACK ARM (Track-Type Colors)  │ 79   │
│  81   82   83   84   85   86   87   88 │      │
│  B1   B2   B3   B4   B5   B6   B7   B8 │      │
├────────────────────────────────────────┼──────┤
│ ROW 2: MUTE (Orange when muted)        │ 69   │
│  71   72   73   74   75   76   77   78 │      │
├────────────────────────────────────────┼──────┤
│ ROW 3: SOLO (Yellow when soloed)       │ 59   │
│  61   62   63   64   65   66   67   68 │      │
├────────────────────────────────────────┼──────┤
│ ROW 4: CUE A (Jingles)                 │ 49   │
│  51   52   53   54   55   56   57   58 │      │
├────────────────────────────────────────┼──────┤
│ ROW 5: CUE B (Music Beds)              │ 39   │
│  41   42   43   44   45   46   47   48 │      │
├────────────────────────────────────────┼──────┤
│ ROW 6: CUE C (SFX)                     │ 29   │
│  31   32   33   34   35   36   37   38 │      │
└────────────────────────────────────────┴──────┘
```

---

## 🎨 Color Schema

### Track Types (Row 1 Armed State)
- 🔴 **Red** — Voice tracks (Host Mic)
- 🔵 **Blue** — Guest/Aux inputs (Guest, Remote, Aux, Bluetooth)
- 🟢 **Green** — Music tracks (Music 1/2, Jingles)
- 🟡 **Yellow** — SFX tracks
- 🔴 **Red Pulse** — RECORDING IN PROGRESS

### Track States (Rows 2-3)
- 🟠 **Orange** — Muted (Row 2)
- 🟡 **Yellow** — Soloed (Row 3)
- **Off** — Normal/inactive

### Cue Slots (Rows 4-6)
- 🟢 **Green** — Clip loaded, ready
- 🟢 **Green Pulse** — Clip playing
- 🟡 **Yellow** — Clip queued
- **Off** — Empty slot

---

## ⌨️ Emergency Keyboard Shortcuts

| Key | Action | When to Use |
|-----|--------|-------------|
| **F1** | 🚨 PANIC: Cut to Music | Profanity, feedback, emergency |
| **Spacebar** | Play/Stop | Transport control |
| **Ctrl+R** | Toggle Recording | Start/stop recording |
| **Ctrl+S** | Save Session | After important changes |
| **M** | Mute Selected Track | Quick mute |
| **S** | Solo Selected Track | Isolate track |
| **1-8** | Select Track B1-B8 | Quick track selection |

---

## 🎙️ Pre-Show Checklist (60 seconds)

- [ ] **Vocaster:** Power on, verify ALSA routing (`alsa-scarlett-gui`)
- [ ] **Ardour:** Load session/template
- [ ] **Controllers:** LEDs lit (nanoKONTROL + Launchpad)
- [ ] **Arm tracks:** B1 (Host DSP), B2 (Host Raw), [+B6 Remote if interview]
- [ ] **Headphones:** Guest headphones = primary monitor
- [ ] **Mic check:** Speak, verify meters moving (-18 to -12 dBFS)
- [ ] **Remote echo test:** Guest does NOT hear themselves
- [ ] **Loudness check:** 30s test → -16 LUFS ±2 LU

---

## 🆘 Emergency Procedures

### PANIC Button (F1 or Launchpad Pad 89)
**Instant cut to music:** Mutes all voice tracks, unmutes Music Bus, starts playback

### Ardour Crashes
1. Restart Ardour (90s recovery target)
2. Load last session (auto-saved every 60s)
3. Recordings saved in `interchange/` folder

### MIDI Controller Disconnects
1. **Immediate:** Use keyboard (Spacebar, M, S, 1-8)
2. **During music:** Unplug/replug USB
3. **Reconnection:** Launchpad auto-recovers, nanoKONTROL may need Generic MIDI restart

### No Audio Output
1. Check Vocaster hardware knobs (not muted)
2. Check Ardour Master bus (fader at 0 dB, not muted)
3. Check PipeWire routing: `pw-link -l | grep Ardour`

### Remote Guest Loses Connection
1. **Immediate:** Play music (fader 7), announce "technical difficulties"
2. **Backup:** Call guest on phone → route to Aux Input (fader 4)
3. **Continue:** Solo show content or reschedule interview

---

## 📊 Target Levels

| Parameter | Target | Check Method |
|-----------|--------|--------------|
| **Input Peaks** | -18 to -12 dBFS | Ardour track meters (pre-plugins) |
| **Integrated Loudness** | -16 LUFS ±2 LU | LSP Loudness Meter on Master |
| **Loudness Range (LRA)** | 4-10 LU | LSP Loudness Meter |
| **True Peak** | ≤ -1.0 dBTP | x42 True Peak Meter on Master |

---

## 📖 Documentation

- **[STUDIO.md](../STUDIO.md)** — Complete setup & operational manual
- **[ARDOUR-SETUP.md](../ARDOUR-SETUP.md)** — Template configuration
- **[COLOR-SCHEMA-STANDARD.md](COLOR-SCHEMA-STANDARD.md)** — Color meanings
- **[EMERGENCY-PROCEDURES.md](EMERGENCY-PROCEDURES.md)** — Detailed recovery protocols

---

**Version:** 1.0 | **Date:** 2026-01-19  
**Print:** A4 landscape, laminated, place on desk between controllers
