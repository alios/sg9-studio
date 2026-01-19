# SG9 Studio Clips Library

This directory contains reusable audio clips for Ardour's cue/trigger system.

## Directory Structure

```
clips/
├── Jingles/          - Show intros, outros, segment transitions
├── Music-Beds/       - Background music for interviews, Q&A segments
└── SFX/              - Sound effects (applause, laughter, ding, etc.)
```

## File Naming Convention

**Format:** `<category>-<name>-v<version>.<ext>`

**Examples:**
- `Intro-MainTheme-v1.wav`
- `Outro-Credits-v2.flac`
- `Bed-Interview-Ambient-v1.wav`
- `SFX-Applause-1.wav`

## Audio Specifications

- **Sample Rate:** 48 kHz (broadcast standard)
- **Bit Depth:** 24-bit
- **Format:** WAV (uncompressed) or FLAC (lossless)
- **Loudness Target:** -16 LUFS integrated (Apple Podcasts standard)
- **True Peak:** ≤ -1.0 dBTP

## Clip Preparation Workflow

1. **Edit in Ardour timeline:**
   - Trim to exact duration
   - Apply fade-in/fade-out
   - Add processing (EQ, compression, normalization)

2. **Bounce to clip:**
   - Select region → Right-click → Bounce (with processing)
   - Enable "Bounce to Trigger Slot"
   - Clip automatically added to cue grid + this library

3. **Manual addition:**
   - Export region to clips directory
   - Ardour will auto-detect on next Clips Browser refresh

## Ardour Configuration

Configure Ardour to use this library:

1. **Preferences → Triggering → Custom Clips Folder**
2. Set path to: `<repository-path>/clips/`
3. Restart Ardour or switch folders in Clips Browser to refresh

## Loudness Normalization

Use `loudness-scanner` or Ardour's built-in analyzer:

```fish
# Install loudness-scanner (if needed)
nix-shell -p loudness-scanner

# Check clip loudness
loudness-scanner clips/Jingles/Intro-MainTheme-v1.wav

# Target: -16.0 LUFS (±2 LU acceptable)
```

## Git LFS Consideration

Audio files are binary and can be large. Consider using Git LFS if clips exceed 50MB total:

```fish
git lfs track "clips/**/*.wav"
git lfs track "clips/**/*.flac"
```

Currently tracking audio files directly in git (manageable size).

## Related Documentation

- [CLIPS-INTEGRATION-RESEARCH.md](../CLIPS-INTEGRATION-RESEARCH.md) - Research on Ardour clips feature
- [.copilot-tracking/plans/clips-cue-integration.instructions.md](../.copilot-tracking/plans/clips-cue-integration.instructions.md) - Implementation plan
- [STUDIO.md](../STUDIO.md) - Main studio workflow reference
- [ARDOUR-SETUP.md](../ARDOUR-SETUP.md) - Ardour template setup guide
