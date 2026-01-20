# SG9 Studio — Emergency Procedures

**Critical Workflows for Live Broadcast Failures**

## Philosophy

**Murphy's Law applies to live radio:** If it can fail, it will fail at the worst possible moment.

Professional broadcast studios (EBU standards, BBC guidelines) require:
- **Redundancy:** Backup for every critical path
- **Hot-switchable:** No dead air during failover
- **Documented procedures:** Muscle memory, not improvisation
- **90-second recovery:** Return to air within 90 seconds of failure

## Critical Failure Scenarios

### 1. Ardour Crashes During Live Recording

**Symptoms:**
- Ardour window disappears
- Audio stops flowing
- MIDI controllers unresponsive

**Immediate Actions (0-30 seconds):**

1. **Switch to backup recording:**
   - If recording via Audacity/Reaper as backup → continue with backup
   - If no backup running → proceed to step 2

2. **Restart Ardour (fast launch):**
   ```bash
   # Kill zombie processes
   killall -9 ardour8
   
   # Restart with last session
   ardour8 --session-path ~/SG9-Studio/2026-01-19-Episode-Name &
   ```

3. **Recover last recording:**
   - Ardour auto-saves to `~/SG9-Studio/.../interchange/`
   - Latest WAV files are recoverable even if session crashed
   - Import into new session after show

**Prevention:**
- Always run secondary recorder (Audacity on separate laptop)
- Record Host Mic (Raw) track as unprocessed safety
- Enable Ardour auto-backup: `Edit → Preferences → Misc → Periodic Backups: 60s`

---

### 2. MIDI Controller Failure (nanoKONTROL / Launchpad)

**Symptoms:**
- Faders/pads don't respond
- LEDs don't light up
- USB disconnected during show

**Immediate Actions (0-10 seconds):**

1. **Switch to keyboard control:**
   - Spacebar: Play/Stop
   - `Ctrl+R`: Toggle recording
   - `1-8`: Select tracks B1-B8
   - `M`: Mute selected track
   - `S`: Solo selected track

2. **Use mouse for faders:**
   - Mixer window: Drag faders directly
   - Faster than keyboard for level adjustments

3. **Reconnect USB (if time permits):**
   - Unplug/replug MIDI controller
   - Launchpad Mk2 feedback script auto-detects reconnection
   - nanoKONTROL may require Generic MIDI restart:
     ```
     Edit → Preferences → Control Surfaces → Generic MIDI
     Uncheck → Check (restarts connection)
     ```

**During Music/Ad Break (60 seconds):**

4. **Full MIDI reset:**
   ```bash
   # Reload ALSA/PipeWire MIDI routing
   systemctl --user restart pipewire pipewire-pulse
   
   # Reconnect in Ardour
   Edit → Preferences → Control Surfaces → Reload All
   ```

**Prevention:**
- Keep keyboard within reach (primary input device)
- Test MIDI controllers 5 minutes before show
- Have spare USB cable taped under desk

---

### 3. Vocaster Two Failure (No Audio I/O)

**Symptoms:**
- No input meters in Ardour
- No output to headphones/monitors
- USB disconnected or driver crash

**Immediate Actions (0-60 seconds):**

1. **Switch to built-in audio (emergency only):**
   ```bash
   # macOS: Use built-in headphone jack
   Edit → Preferences → Audio → Device: Built-in Audio
   
   # Connect:
   - Input: Built-in microphone (degraded quality)
   - Output: Headphones
   ```

2. **If USB audio still dead, use phone/tablet:**
   - Continue show via phone call to co-host
   - Record on phone voice recorder app
   - Transfer audio file after show for editing

**During Music Break (2-5 minutes):**

3. **Reconnect Vocaster:**
   - Unplug USB from Vocaster
   - Wait 10 seconds
   - Reconnect USB
   - Select Vocaster in Ardour Audio preferences
   - Verify input meters respond to voice

4. **If Vocaster still dead:**
   - Continue show with built-in audio
   - After show: Test Vocaster on different computer (diagnose hardware vs. driver)

**Prevention:**
- Keep USB-C to USB-A adapter (Vocaster uses USB-C)
- Test Vocaster routing in `alsa-scarlett-gui` before every show
- Monthly firmware check: https://focusrite.com/vocaster-firmware

---

### 4. No Output Audio (Master Bus Dead)

**Symptoms:**
- Ardour tracks show meters moving
- No sound in headphones/monitors
- Master bus meter shows activity

**Diagnosis (10 seconds):**

Check in order:

1. **Hardware volume:**
   - Vocaster: Turn up headphone/monitor knobs
   - Check if "Mute" button pressed on Vocaster

2. **Ardour Master bus:**
   - Master fader at 0 dB? (not -inf)
   - Master bus not muted? (M button not lit)

3. **PipeWire routing:**
   ```bash
   pw-link -l | grep Ardour
   # Verify: Ardour:out → Vocaster:playback_1/2
   ```

**Fix (30 seconds):**

If Master bus issue:
- Unmute Master bus
- Reset Master fader to 0 dB

If PipeWire routing issue:
- `qpwgraph` (GUI) → Reconnect Ardour output to Vocaster
- Or restart PipeWire: `systemctl --user restart pipewire`

**Prevention:**
- Never touch Master bus during show (use VCAs instead)
- Test full signal path 5 minutes before show
- Enable Ardour "Solo Isolate" on Master bus (prevents accidental mute)

---

### 5. Remote Guest Loses Connection (VoIP Failure)

**Symptoms:**
- Guest audio cuts out
- VoIP software shows "Reconnecting..."
- Network latency spike

**Immediate Actions (0-20 seconds):**

1. **Announce to audience:**
   - "We're experiencing technical difficulties with [Guest Name]'s connection. We'll reconnect shortly."

2. **Fill dead air:**
   - Play Music 1 track (nanoKONTROL fader 7)
   - Or trigger Jingle (Launchpad pad 51-58)

3. **Attempt VoIP reconnect:**
   - VoIP software: Click "Reconnect" or "Call"
   - If fails after 10 seconds → proceed to backup

**Backup Communication (30-60 seconds):**

4. **Switch to phone call:**
   - Call guest on phone (have number pre-saved)
   - Route phone to Aux Input track (3.5mm cable or Bluetooth)
   - Unmute Aux Input track (nanoKONTROL button 74)

5. **Adjust for phone audio quality:**
   - Phone has narrower frequency range (300-3400 Hz)
   - Lower HPF to 300 Hz on Aux Input processing
   - Increase de-esser threshold (phone already band-limited)

**If Phone Also Fails:**

6. **Continue show without guest:**
   - Announce: "We'll have [Guest Name] back on the show soon."
   - Pivot to solo content (music, monologue, pre-recorded segment)
   - Reschedule interview for next episode

**Prevention:**
- Exchange phone numbers with guest before show
- Test VoIP connection 10 minutes early
- Have backup VoIP platform (Zoom fails → try Jitsi, Skype)
- Ask guest to use wired ethernet (not WiFi)

---

### 6. Computer Freeze / Kernel Panic

**Symptoms:**
- Entire computer unresponsive
- Mouse/keyboard frozen
- Fans spinning loudly (thermal throttle)

**Immediate Actions (0-10 seconds):**

1. **Assess if show is recordable:**
   - If co-host has backup recorder → continue
   - If solo show → announce technical difficulties

2. **Hard reset (last resort):**
   ```bash
   # Hold power button 10 seconds → force shutdown
   # Boot computer (30-60 seconds)
   # Launch Ardour with backup session
   ```

**During Reboot (1-3 minutes):**

3. **Use phone to continue show:**
   - Record voice memo on phone
   - Announce on social media: "Technical difficulties, back in 5 minutes"

**After Reboot:**

4. **Resume show:**
   - Open last auto-saved session
   - Verify MIDI controllers reconnected
   - Continue recording from current timecode

**Prevention:**
- Monitor CPU temperature: `sensors` (Linux) or iStat Menus (macOS)
- Close unnecessary applications before show
- Keep computer on UPS (uninterruptible power supply)
- Monthly system updates (kernel, drivers)

---

## Backup Equipment Checklist

**Always Have On Hand:**

- [ ] **Backup laptop** with Audacity/Reaper installed
- [ ] **USB microphone** (Blue Yeti, Rode NT-USB) for emergency input
- [ ] **Smartphone** with voice recorder app
- [ ] **3.5mm to 1/4" TRS cable** (phone → Vocaster Aux input)
- [ ] **Spare USB cables** (USB-C, USB-A, Micro-USB)
- [ ] **Bluetooth adapter** (if Vocaster's Bluetooth fails)
- [ ] **Printed contact list** (guest phone numbers, tech support)

**Software Backups:**

- [ ] Ardour session backed up to cloud (Dropbox, Google Drive)
- [ ] Auto-save enabled: `Edit → Preferences → Misc → Backups: 60s`
- [ ] Secondary recorder running during show (Audacity on laptop)

---

## Communication Protocols

### During Live Show

**Problem Severity Levels:**

| Level | Description | Action | Example |
|-------|-------------|--------|---------|
| **L1 - Minor** | Non-critical, fix after segment | Note for later | Launchpad LED desync |
| **L2 - Moderate** | Affects quality, fix during music | Fix in 60s | MIDI controller disconnect |
| **L3 - Critical** | Show-stopping, immediate action | Emergency procedure | Ardour crash, no audio |

**Hand Signals (for co-host/guest in studio):**

- **Fist raised:** Mute your mic now (audio issue)
- **Finger to lips:** Reduce volume (too loud)
- **Pointing to headphones:** Check your monitoring
- **Waving hand:** Stop talking, I'll take over

### Post-Show Debriefing

**After any L2 or L3 failure:**

1. **Document the failure:**
   - Time of occurrence
   - Symptoms observed
   - Actions taken
   - Recovery time
   - Root cause (if known)

2. **Update this document:**
   - Add new failure scenario if not listed
   - Refine existing procedures based on lessons learned

3. **Test fix:**
   - Reproduce failure in test session (if possible)
   - Verify emergency procedure works as documented

---

## Recovery Time Objectives (RTO)

**Target recovery times (industry standard):**

| Failure | Target RTO | SG9 Current RTO |
|---------|------------|-----------------|
| MIDI controller disconnect | 10 seconds | 10 seconds ✅ |
| Ardour crash | 90 seconds | 120 seconds ⚠️ |
| Vocaster failure | 5 minutes | 3 minutes ✅ |
| VoIP guest disconnect | 30 seconds | 45 seconds ⚠️ |
| Computer freeze | 5 minutes | 5 minutes ✅ |

**Improvement Targets:**

- Reduce Ardour crash RTO to 60 seconds (practice fast restart)
- Reduce VoIP disconnect RTO to 20 seconds (pre-dial phone backup)

---

## Testing Procedures

**Monthly Emergency Drill (Last Friday of Month):**

1. **Simulate MIDI failure:**
   - Unplug nanoKONTROL mid-test recording
   - Practice keyboard-only workflow
   - Verify Launchpad auto-reconnects

2. **Simulate Ardour crash:**
   - `killall -9 ardour8` during recording
   - Time how long to relaunch and recover session
   - Verify auto-saved files are intact

3. **Simulate audio interface failure:**
   - Unplug Vocaster USB
   - Switch to built-in audio within 60 seconds
   - Test backup microphone input

**Document drill results:**
- Actual recovery time vs. target
- Issues discovered
- Procedures to update

---

## References

- EBU Tech 3344: Quality of Service for Broadcast Contribution Links
- BBC Radio Production Standards (Emergency Procedures)
- NAB Engineering Handbook: Backup Systems & Redundancy
- IEC 62682: Continuity of Service for Mission-Critical Systems
