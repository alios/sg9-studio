# Change Records

This folder contains short, durable change records for AI infrastructure and studio workflow updates.

## When to add a change record

Add a file here when you:

- Add/remove/rename an MCP server in `.vscode/mcp.json`
- Add or modify an agent definition in `.github/agents/`
- Change activation rules in `.github/copilot-instructions.md` or `AGENTS.md`
- Add/modify tracking templates in `.copilot-tracking/templates/`

## File naming

Use: `YYYY-MM-DD_short-title.md`

Examples:

- `2026-01-20-ai-infrastructure-audit.md`
- `2026-01-20-mcp-template-added.md`

## Suggested structure

- **Summary:** What changed and why
- **Files:** List of touched files
- **Testing:** How it was validated (even if manual)
- **Rollback:** How to undo the change safely
