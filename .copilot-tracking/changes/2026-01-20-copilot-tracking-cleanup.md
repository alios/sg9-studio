# 2026-01-20 — .copilot-tracking Cleanup (Dedup + Archive + Portability)

## Summary

Cleaned up legacy content under `.copilot-tracking/` to reduce drift and keep public-facing documentation out of the tracking area.

Key themes:
- Move “real docs” to their natural homes (`docs/` or repo root).
- Keep `.copilot-tracking/` focused on templates, plans, research artifacts, and durable change records.
- Archive superseded research (keep a stub at the old path to avoid broken links).

## Files

**Moved / Renamed**
- `docs/COLOR-SCHEMA-STANDARD.md` (from `.copilot-tracking/plans/`)
- `TESTING-CUE-INTEGRATION.md` (from `.copilot-tracking/plans/`)
- `.copilot-tracking/plans/2026-01-19-*.instructions.md` (renamed for date + convention)
- `.copilot-tracking/changes/2026-01-19-*.md` (promoted “summaries” into change records)
- `.copilot-tracking/research/2026-01-19-ardour-cue-action-names.md` (moved out of plans)
- `.copilot-tracking/research/archive/*` (stored full snapshots of superseded research)

**Added**
- `CLIPS-INTEGRATION-RESEARCH.md` (root stub pointing to canonical research in `.copilot-tracking/research/`)
- `CUE-INTEGRATION-STATUS.md` (restored status file referenced by `STUDIO.md`)
- `.copilot-tracking/research/archive/` (archive location)

**Updated**
- `README.md` (color schema link now points to `docs/`)
- `clips/README.md` and `.copilot-tracking/changes/2026-01-19-cue-integration.md` (fixed plan links and broken relative paths)

## Knowledge Integration

- Updated `midi_maps/sg9-launchpad-mk2.map` and `midi_maps/README.md` to use verified Ardour cue action IDs:
  - `trigger-slot-{col}-{row}` and `trigger-cue-{row}`

## Testing

- Ran `bash scripts/check-ai-infra.sh` (passed).

## Rollback

- Use `git restore` / `git checkout -- <path>` to revert the file moves/edits.
- If you want the old research snapshots back at their original paths, move them back from `.copilot-tracking/research/archive/` and remove the stub files.
