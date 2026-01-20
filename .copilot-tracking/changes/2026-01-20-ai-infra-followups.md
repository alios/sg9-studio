# AI Infrastructure Follow-ups (Portability + Consistency)

**Date:** 2026-01-20

## Summary

Implemented the post-audit follow-ups to reduce drift and improve portability:

- Made the filesystem MCP root portable by using `${workspaceFolder}`.
- Split agent documentation into concise front pages (briefs) and existing detailed playbooks.
- Added an automated consistency check script for MCP/docs/agent links.

## Files Changed

- `.vscode/mcp.json`
  - `filesystem` MCP server now uses `${workspaceFolder}` instead of an absolute path.

- `.github/agents/brief/`
  - Added brief agent front pages:
    - `audio-engineer.md`
    - `systems-engineer.md`
    - `ai-engineer.md`

- `.github/agents/*.md`
  - Added a short banner at the top of each long agent doc clarifying it is the playbook and linking to its brief.

- `.github/copilot-instructions.md`, `AGENTS.md`, `README.md`
  - Updated links to point to the brief agent pages.
  - Updated README MCP server list to use actual MCP server IDs.

- `scripts/check-ai-infra.sh`
  - Added a repo-local check that validates:
    - core files exist
    - MCP server IDs from `.vscode/mcp.json` are referenced in docs
    - agent docs links point to the brief pages
    - filesystem MCP path is not hardcoded to `/Users/...`

## Testing

- Ran: `bash scripts/check-ai-infra.sh`
  - Result: all checks passed.

## Rollback

- MCP portability:
  - Revert `.vscode/mcp.json` `filesystem` args back to a fixed path (not recommended).

- Agent docs:
  - Revert doc links in `.github/copilot-instructions.md`, `AGENTS.md`, and `README.md` back to `.github/agents/*.md`.

- Consistency script:
  - Remove `scripts/check-ai-infra.sh` if you do not want automated enforcement.
