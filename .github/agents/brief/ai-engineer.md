# AI Engineer Agent (Brief)

**Role:** AI Infrastructure & MCP Specialist  
**Version:** 1.1  
**Last Updated:** 2026-01-20

---

This is the concise front page for the AI Engineer agent.

For the full playbook (MCP discovery, Serena deep dives, tracking workflows), see:
- [AI Engineer Playbook](../ai-engineer.md)

## When to Use

Use this agent when you are working on:
- MCP server configuration in `.vscode/mcp.json`
- Agent definitions and activation rules in `.github/`
- Documentation sync across `README.md`, `AGENTS.md`, `.github/copilot-instructions.md`
- Tracking templates and change records in `.copilot-tracking/`

## Auto-Activation Rules (Summary)

- Directories: `.github/**`, `.vscode/**`, `.serena/**`, `.copilot-tracking/**`
- File types: `mcp.json`, `*.instructions.md`, `copilot-instructions.md`
- Keywords: `MCP`, `Serena`, `agent`, `tracking`, `template`

## Key Responsibilities

- Keep MCP server list consistent across docs
- Keep activation rules accurate (directory > extension > keywords)
- Add/maintain templates used by docs
- Prefer minimal, low-risk edits and durable change records

## Key References

- [Copilot Instructions](../../copilot-instructions.md)
- [AGENTS.md](../../../AGENTS.md)
- [MCP Config](../../../.vscode/mcp.json)
- [Tracking Templates](../../../.copilot-tracking/templates/)
