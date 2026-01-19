# SG9 Studio — Color Coding Standard

**Version:** 1.0 | **Date:** 2026-01-19

## Purpose

Establish consistent color vocabulary across all interfaces (Ardour tracks, Launchpad LEDs, future GUI elements) to reduce cognitive load and enable pre-attentive perception during live broadcasts.

Based on professional broadcast HMI research (DHD Audio, Lawo, Wheatstone standards).

## Color Palette

### Primary Function Colors

| Color | Hex Code | RGB LED Code | Use Case | Example |
|-------|----------|--------------|----------|---------|
| **Red** | #E74C3C | 5 | Voice tracks (primary content), Armed state, Danger/Error | Host Mic, Recording indicator |
| **Pink** | #EC7063 | 53 | Voice bus/processing, Vocal groups | Voice Bus |
| **Orange** | #E67E22 | 9 | Muted state, Standby/Warning | Muted tracks |
| **Yellow** | #F1C40F | 13 | Solo state, SFX tracks, Attention needed | Soloed tracks, SFX folder |
| **Green** | #27AE60 | 21 | Music tracks, Ready/Safe state, Playback | Music 1/2, Ready indicator |
| **Cyan** | #1ABC9C | 37 | Loopback/technical inputs, Monitoring | Music Loopback track |
| **Blue** | #3498DB | 45 | Guest/auxiliary inputs, Communication channels | Guest Mic, Aux Input, Remote Guest |
| **Purple** | #9B59B6 | 53 | Mix-minus buses, Special routing | Mix-Minus (Remote Guest) |
| **Gray** | #566573 | 3 (white) | VCA masters, System controls | Master Control VCA |

### State Indicators (LED Animation)

| State | LED Behavior | Applies To |
|-------|--------------|-----------|
| **Armed** | Solid color | Track ready to record |
| **Recording** | Pulsing color | Active recording in progress |
| **Playing** | Solid bright | Clip/cue playing |
| **Muted** | Orange solid | Track muted |
| **Soloed** | Yellow solid | Track soloed |
| **Idle/Ready** | Green solid | Track loaded, not active |
| **Error** | Red pulse | System error, attention required |
| **Off** | LED off | Inactive/empty slot |

## Application Guidelines

### Ardour Track Colors

**Voice Tracks (Red Family):**
- Host Mic (DSP): Red (#E74C3C)
- Host Mic (Raw): Dark Red (#C0392B)
- Guest Mic: Blue (#3498DB)
- Remote Guest: Blue (#3498DB)

**Input Tracks (Blue/Cyan Family):**
- Aux Input: Blue (#3498DB)
- Bluetooth: Cyan (#1ABC9C)
- Music Loopback: Cyan (#1ABC9C)

**Content Tracks (Green/Yellow Family):**
- Music 1: Green (#27AE60)
- Music 2: Dark Green (#229954)
- Jingles: Light Green (#58D68D)
- SFX: Yellow (#F1C40F)

**Buses (Secondary Colors):**
- Voice Bus: Pink (#EC7063)
- Music Bus: Dark Green (#1E8449)
- Mix-Minus: Purple (#9B59B6)
- Master: Gray (#95A5A6)

### Launchpad Mk2 LED Mapping

**Track Control Rows (1-3):**
- Row 1 (Arm): Track-specific color when armed, off when disarmed
- Row 2 (Mute): Orange when muted, off when active
- Row 3 (Solo): Yellow when soloed, off when inactive

**Cue Rows (4-8):**
- Row 4 (Cue A - Jingles): Yellow for loaded clips
- Row 5 (Cue B - Music Beds): Green for loaded clips
- Row 6 (Cue C - SFX): Yellow for loaded clips
- Row 7-8: Reserved (use default green)

**Transport Row:**
- Play: Green (playing), off (stopped)
- Stop: Red (armed), off (stopped)
- Record: Red (recording), orange (armed), off (idle)

### Visual Radio Camera Indicators

When visual radio is active:

- **On-Air Camera:** Red border/tally light
- **Preview Camera:** Green border
- **Inactive Camera:** Gray/dim

### Plugin GUI Standardization

**LSP Plugin Parameter Colors** (when customizable):

- **HPF/LPF:** Blue (filtering)
- **Gate:** Orange (dynamic control)
- **Compressor:** Red (gain reduction)
- **EQ:** Green (tonal shaping)
- **Limiter:** Red (safety/protection)

## Cognitive Benefits

### Pre-Attentive Perception

Human visual system processes color **before** shape or text:

- **Red = Voice** → Moderator instantly locates voice controls
- **Green = Music** → Quick identification of content tracks
- **Blue = Guest** → Clear separation of external inputs
- **Orange = Warning** → Immediate attention to muted state

### Glanceability

During live broadcast, moderator should identify track state **without reading labels**:

- LED color alone indicates track type and state
- No need to read track names on screen
- Reduces eye movement and cognitive load

### Consistency Across Interfaces

Same color means same function everywhere:

- Ardour track color = Launchpad LED color = Future GUI color
- Reduces training time for new operators
- Enables "blind" operation (muscle memory)

## Implementation Checklist

- [ ] Update Ardour session template with standardized track colors
- [ ] Update `launchpad_mk2_feedback.lua` to use color schema
- [ ] Update nanoKONTROL LED mappings (if firmware allows)
- [ ] Create visual reference card for studio desk
- [ ] Document color meanings in session README
- [ ] Apply to all future sessions via template

## References

- Lawo diamond color coding system (Blue=Pan, Red=Gain, Green=EQ)
- DHD Audio RGB LED feedback standards
- EBU R128 loudness metering color conventions
- Broadcast Bionics visual signaling best practices
