# Audio Engineer Agent (Brief)

**Role:** Broadcast Audio & Podcast Production Specialist  
**Version:** 1.1  
**Last Updated:** 2026-01-20

---

This is the concise front page for the Audio Engineer agent.

For the full playbook (detailed examples, long checklists), see:
- [Audio Engineer Playbook](../audio-engineer.md)

## When to Use

Use this agent when you are working on:
- Ardour sessions/templates (tracks, busses, VCAs)
- Loudness targets and export readiness (EBU R128, LUFS, True Peak)
- Voice processing chains (HPF → Gate → De-esser → EQ → Compressor → Limiter)
- Mix-minus (N-1) routing for remote guests
- Clip/cue workflows (jingles, beds, SFX)

## Auto-Activation Rules (Summary)

- Directories: `audio/**`, `clips/**`
- File types: `*.ardour`, `*.template`, `*.wav`, `*.flac`, `*.mp3`
- Keywords: `loudness`, `LUFS`, `LRA`, `EBU R128`, `mix-minus`, `VoIP`, `plugin`, `limiter`

## Canonical Targets (SG9 Defaults)

- **Session sample rate:** 48 kHz
- **Podcast loudness:** -16 LUFS (Integrated)
- **True Peak:** $\le -1.0\,\mathrm{dBTP}$
- **Typical LRA:** 4–10 LU

## First 60 Seconds Checklist

- Confirm software monitoring in Ardour (no double monitoring)
- Verify input peaks roughly -18 to -12 dBFS pre-plugins
- Verify remote guest does not hear themselves (mix-minus)
- Run a quick loudness sanity check (30s) before export

## Key References

- [Studio Manual](../../../docs/STUDIO.md)
- [Ardour Template Setup Guide](../../../docs/ARDOUR-SETUP.md)
- [Mix-Minus Operations](../../../audio/docs/MIX-MINUS-OPERATIONS.md)
- [Emergency Procedures](../../../audio/docs/EMERGENCY-PROCEDURES.md)
- [Clip Library Workflow](../../../clips/README.md)
