# MCP Integration Testing — Instructions

**Version:** 1.0  
**Date:** YYYY-MM-DD  
**Owner:** [Your Name or "AI Assistant"]  
**Status:** Draft | In Review | Complete

---

## Purpose

Validate that a newly added or modified MCP server:
- Starts reliably in VS Code
- Provides the expected tools/capabilities
- Does not break existing agent workflows
- Has safe configuration (no hardcoded secrets)

---

## Scope

**In scope:**
- `.vscode/mcp.json` changes (server added/removed/updated)
- Basic functional testing of server tool availability
- Minimal smoke test of the server’s main workflows
- Documentation synchronization checks

**Out of scope:**
- Performance benchmarking beyond basic “usable/not usable”
- Deep security audits (note findings, open follow-up if needed)

---

## Prerequisites

- VS Code restarted after `.vscode/mcp.json` changes
- Any required credentials set via env vars (never hardcoded)
- If server is local-only, required local dependency installed (e.g., `npx`, Python, etc.)

---

## Test Matrix

Fill this table as you test.

| Check | Result | Notes |
|------|--------|-------|
| MCP server starts (no crash/restart loop) | ✅/❌ | |
| Tools show up in Copilot tool list | ✅/❌ | |
| Key workflow succeeds (define below) | ✅/❌ | |
| No secrets committed / hardcoded | ✅/❌ | |
| Docs updated (Copilot instructions / AGENTS / README) | ✅/❌ | |

---

## Step-by-step Tests

### 1) Configuration sanity

1. Open `.vscode/mcp.json` and verify:
   - Server name is correct and stable
   - `command` exists
   - `args` are correct
   - `env` only references environment variables (e.g. `${GITHUB_TOKEN}`)
   - No absolute paths unless explicitly intended

2. Confirm the JSON is valid.

**Pass criteria:** No obvious misconfig or secret exposure.

---

### 2) Startup + discovery

1. Restart VS Code.
2. Open Copilot Chat.
3. Confirm the MCP server appears and tools are available.

**Pass criteria:** Tools are discoverable and callable.

---

### 3) Functional smoke test

Define 1–3 “happy path” checks for this server.

**Workflow A:** [Describe]
- Steps:
  1. …
  2. …
- Expected result:
  - …
- Actual result:
  - …

**Workflow B:** [Describe]

**Pass criteria:** At least one representative workflow succeeds.

---

### 4) Regression check (existing critical workflows)

Run quick checks that should remain stable:
- Serena: symbol search works on `scripts/*.lua`
- filesystem: can list and read files under repo
- github: can authenticate and perform a basic query (if configured)

**Pass criteria:** No breakage in baseline workflows.

---

### 5) Documentation sync check

Update docs so repo stays self-healing:
- `.github/copilot-instructions.md` (MCP server table)
- `AGENTS.md` (MCP server table)
- `README.md` (AI assistance section)

**Pass criteria:** All docs agree on the MCP server list.

---

## Rollback Procedure

If the server causes errors or instability:
1. Remove or disable the server in `.vscode/mcp.json`
2. Restart VS Code
3. Re-run the baseline regression checks
4. Record rollback in `.copilot-tracking/changes/`

---

## Changelog

- **v1.0 (YYYY-MM-DD):** Initial template
