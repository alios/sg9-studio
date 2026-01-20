# AI Support Infrastructure Audit

**Version:** 1.0  
**Date:** 2026-01-20  
**Researcher:** AI Assistant  
**Status:** Complete

---

## Context

**Objective:**  
Perform an intensive audit of SG9 Studio’s AI support infrastructure (agents, MCP servers, Serena config, and tracking workflows) and fix obvious drift.

**Scope:**
- MCP configuration (`.vscode/mcp.json`)
- Serena configuration (`.serena/project.yml`)
- Agent definitions (`.github/agents/*.md`) and activation rules
- Documentation consistency across `.github/copilot-instructions.md`, `AGENTS.md`, `README.md`
- Tracking templates and structure in `.copilot-tracking/`

**Out of scope:**
- Deep security review of all dependencies
- Rewriting large agent docs for length (flagged as follow-up)

---

## Findings

### Finding 1: MCP configuration is sane (no hardcoded secrets)

**Source:** `.vscode/mcp.json`

**Summary:**
- MCP servers are configured with standard commands.
- GitHub MCP auth uses an environment variable (`${GITHUB_TOKEN}`) rather than a committed token.

**Confidence Level:** High

**Notes / follow-up:**
- The filesystem MCP uses an absolute path (`/Users/alios/src/sg9-studio`). This is fine for a single-machine studio repo but will break for other checkouts unless documented or parameterized.

---

### Finding 2: Serena project config was missing Markdown

**Source:** `.serena/project.yml`

**Summary:**
- Serena languages did not include `markdown`, which reduces the usefulness of semantic navigation for this repo (lots of docs).

**Fix applied:**
- Added `markdown` and removed unused `python` (no `.py` files found).

**Confidence Level:** High

---

### Finding 3: Tracking docs referenced a missing template + missing changes folder

**Source:** `.github/copilot-instructions.md`

**Summary:**
- The repo docs referenced `.copilot-tracking/templates/mcp-integration-testing.instructions.md`, but it didn’t exist.
- The tracking tree also referenced `.copilot-tracking/changes/`, but it was missing.

**Fix applied:**
- Created `.copilot-tracking/templates/mcp-integration-testing.instructions.md`.
- Created `.copilot-tracking/changes/` and added a short README for change records.

**Confidence Level:** High

---

### Finding 4: Cross-doc drift (agent + MCP lists)

**Sources:** `.github/copilot-instructions.md`, `AGENTS.md`, `README.md`

**Summary:**
- `README.md` did not list the AI Engineer agent.
- `README.md` MCP list was incomplete (missing Serena + Markitdown).
- `AGENTS.md` referenced a non-existent `.github/instructions/` directory.
- `.github/copilot-instructions.md` activation model was missing `clips/**` and some audio file extensions.

**Fix applied:**
- Synced these docs to match the repo’s current reality.

**Confidence Level:** High

---

## Risks / Gaps (Follow-ups)

1. **Agent doc size:** Agent definitions in `.github/agents/*.md` exceed the repo’s “keep under 500 lines” guideline. Recommend splitting each agent into:
   - a short “front page” (`audio-engineer.md`, etc.)
   - an “examples/playbook” companion (`audio-engineer-playbook.md`, etc.)

2. **Filesystem MCP portability:** consider parameterizing the path if VS Code MCP supports `${workspaceFolder}` for server args, or document that this repo assumes a fixed local path.

3. **Consistency checks:** add a lightweight script to validate:
   - all MCP servers in `.vscode/mcp.json` appear in `.github/copilot-instructions.md`, `AGENTS.md`, `README.md`
   - all referenced agent files exist

---

## Recommendations

**Primary recommendation:**
- Keep the docs self-healing by enforcing consistency checks and keeping templates complete.

**Next best improvements:**
- Split oversized agent docs.
- Add `.env.example` documenting `GITHUB_TOKEN` and any other env vars.

---

## Changelog

- **v1.0 (2026-01-20):** Initial audit completed, obvious drift fixed
