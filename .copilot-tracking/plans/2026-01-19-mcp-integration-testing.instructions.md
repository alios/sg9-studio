# MCP Server Integration Testing Protocol

**Version:** 1.0  
**Date:** 2026-01-19  
**Purpose:** Sequential validation of newly installed MCP servers

## Task Overview

Validate that each MCP server (GitHub, Filesystem, Sequential Thinking) is properly installed, activated, and functional before proceeding with agent development.

## Prerequisites

- [x] MCP servers configured in `.vscode/mcp.json`
- [ ] `GITHUB_TOKEN` environment variable set (for GitHub MCP server)
- [ ] VS Code restarted to activate MCP servers
- [ ] Workspace opened at your `sg9-studio` checkout (any path)

## Test Sequence

Execute tests in order. **Stop if any test fails** and troubleshoot before proceeding.

### Test 1: Filesystem MCP Server

**Objective:** Verify file creation, reading, and deletion in workspace

**Test Steps:**

1. **Create test directory:**
   - Use Filesystem MCP to create `audio/sessions/test/`
   - Expected: Directory created successfully

2. **Create test file:**
   - Create `audio/sessions/test/test-session.txt` with content:
     ```
     SG9 Studio Test Session
     Sample Rate: 48kHz
     Created: 2026-01-19
     ```
   - Expected: File created with exact content

3. **Read test file:**
   - Read `audio/sessions/test/test-session.txt`
   - Expected: Content matches exactly

4. **List directory:**
   - List contents of `audio/sessions/test/`
   - Expected: Shows `test-session.txt`

5. **Delete test artifacts:**
   - Delete `audio/sessions/test/test-session.txt`
   - Delete `audio/sessions/test/` directory
   - Expected: Clean removal

**Success Criteria:**
- ✅ All file operations complete without errors
- ✅ Content integrity verified
- ✅ No orphaned test files remain

---

### Test 2: Sequential Thinking MCP Server

**Objective:** Solve complex audio processing problem requiring multi-step reasoning

**Test Scenario:**

You have a podcast recording with the following issues:
- Integrated loudness: -12 LUFS (target: -16 LUFS for Apple Podcasts)
- True peak: -0.5 dBTP (exceeds -1.0 dBTP safe limit)
- LRA: 15 LU (exceeds 4-10 LU target range)

**Question:** What plugin processing chain adjustments would you recommend to achieve EBU R128 compliance?

**Test Steps:**

1. **Invoke Sequential Thinking MCP:**
   - Ask the server to analyze the problem
   - Expected: Multi-step reasoning process visible

2. **Validate reasoning quality:**
   - Check for consideration of: gain reduction (4 dB), true peak limiting, compression adjustment
   - Expected: Mentions loudness normalization, limiter ceiling adjustment, compression ratio increase

3. **Verify solution completeness:**
   - Solution should address all three issues
   - Expected: Specific dB values and plugin recommendations

**Success Criteria:**
- ✅ Sequential reasoning steps documented
- ✅ Solution addresses loudness, true peak, and LRA
- ✅ Recommendations align with SG9 Studio canonical chain (HPF→Gate→De-esser→EQ→Compressor→Limiter)

---

### Test 3: GitHub MCP Server

**Objective:** Search repositories, retrieve file content, create test issue

**Test Steps:**

1. **Search for Ardour Lua API examples:**
   - Query: `repo:Ardour/ardour "Lua API" language:lua`
   - Expected: Returns Lua script examples from Ardour repository

2. **Retrieve file content:**
   - Get content of `share/scripts/_rawmidi.lua` from Ardour repository
   - Expected: Returns Lua code with MIDI API examples

3. **Search SG9 Studio issues:**
   - Search for existing test issues in `alios/sg9-studio` (if repository exists)
   - Expected: Returns issue list or confirms no repository

4. **Create test issue (optional if repo exists):**
   - Title: "MCP Integration Test - DELETE ME"
   - Body: "Automated test issue created during MCP server validation. Safe to delete."
   - Expected: Issue created successfully

**Success Criteria:**
- ✅ Repository search returns relevant results
- ✅ File content retrieval works
- ✅ GitHub API authentication successful (via GITHUB_TOKEN)
- ✅ Optional: Issue creation/deletion works

---

## Environment Setup

**GitHub Token Configuration:**

```bash
# Add to ~/.zshrc or ~/.bashrc or ~/.config/fish/config.fish
export GITHUB_TOKEN="ghp_your_personal_access_token_here"
```

**Token Permissions Required:**
- `repo` (full control of private repositories)
- `read:org` (read organization data)
- `read:user` (read user profile data)

**Generate Token:**
1. Visit: https://github.com/settings/tokens
2. Generate new token (classic)
3. Select scopes: `repo`, `read:org`, `read:user`
4. Copy token and save to environment variable

---

## Rollback Procedure

**If tests fail:**

1. **Check VS Code Output:**
   - View → Output → Select "MCP Servers" from dropdown
   - Look for activation errors

2. **Verify configuration:**
   - Confirm `.vscode/mcp.json` syntax is valid JSON
   - Check filesystem MCP root uses `${workspaceFolder}` (portable; no hardcoded `/Users/...`)
   - Verify `GITHUB_TOKEN` is set: `echo $GITHUB_TOKEN`

3. **Restart VS Code:**
   - MCP servers only load on VS Code startup
   - Quit completely and reopen

4. **Test individual servers:**
   - Comment out all but one server in `.vscode/mcp.json`
   - Restart VS Code
   - Test single server
   - Repeat for each server

5. **Fallback:**
   - Remove failing server from `.vscode/mcp.json`
   - Document failure in `.copilot-tracking/research/mcp-troubleshooting.md`
   - Proceed with working servers only

---

## Testing Notes

**Filesystem MCP Server:**
- The filesystem MCP root should be configured via `${workspaceFolder}` (portable)
- Cannot access files outside workspace root (security constraint)
- Respects `.gitignore` patterns

**Sequential Thinking MCP Server:**
- Best for multi-step reasoning, not simple queries
- Useful for debugging complex audio processing chains
- Can analyze trade-offs (e.g., compression vs. dynamic range)

**GitHub MCP Server:**
- Requires valid GITHUB_TOKEN in environment
- Token should not be committed to version control
- Rate limits apply (60 requests/hour unauthenticated, 5000/hour authenticated)

---

## Completion Checklist

- [ ] Test 1 (Filesystem) passed
- [ ] Test 2 (Sequential Thinking) passed
- [ ] Test 3 (GitHub) passed
- [ ] Test artifacts cleaned up (`audio/sessions/test/` deleted)
- [ ] MCP servers visible in VS Code status bar
- [ ] Document any failures in `.copilot-tracking/research/mcp-troubleshooting.md`
- [ ] Ready to proceed with Step 2 (tracking templates)

---

## References

- [MCP Server Documentation](https://github.com/modelcontextprotocol)
- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Filesystem MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)
- [Sequential Thinking MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sequential-thinking)
