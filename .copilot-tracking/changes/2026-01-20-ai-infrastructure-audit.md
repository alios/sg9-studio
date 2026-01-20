# 2026-01-20 — AI Infrastructure Audit + Drift Fixes

## Summary

Performed an audit of AI support infrastructure (MCP config, Serena, agents, and tracking) and fixed obvious documentation/config drift so the repo remains self-consistent.

## Files

- `.serena/project.yml`
  - Added `markdown` to Serena languages; removed unused `python`
  - Made `initial_prompt` role-neutral

- `.copilot-tracking/templates/mcp-integration-testing.instructions.md`
  - Added missing MCP integration testing template

- `.copilot-tracking/changes/README.md`
  - Added guidance for durable change records

- `.github/copilot-instructions.md`
  - Synced activation rules (`clips/**`, audio file extensions)
  - Updated Serena scope to include Markdown

- `AGENTS.md`
  - Removed reference to non-existent `.github/instructions/`

- `README.md`
  - Added AI Engineer agent
  - Completed MCP server list (Serena + Markitdown)
  - Documented `GITHUB_TOKEN`
  - Fixed broken doc links (color schema + mix-minus)

## Testing

- Manual verification:
  - Confirmed files/directories exist and referenced links resolve locally
  - Confirmed `.vscode/mcp.json` continues to reference `GITHUB_TOKEN` (no secrets committed)

## Rollback

Revert the above files to undo the changes. No code paths or runtime components were modified.