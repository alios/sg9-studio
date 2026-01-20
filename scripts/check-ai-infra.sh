#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

failures=0

say() {
  printf '%s\n' "$*"
}

fail() {
  failures=$((failures + 1))
  say "FAIL: $*"
}

pass() {
  say "OK:   $*"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "file exists: $path"
  else
    fail "missing file: $path"
  fi
}

require_contains() {
  local file="$1"
  local needle="$2"

  if grep -qF -- "$needle" "$file"; then
    pass "'$needle' referenced in $file"
  else
    fail "'$needle' NOT referenced in $file"
  fi
}

say "== SG9 AI Infra Consistency Check =="

require_file ".vscode/mcp.json"
require_file ".github/copilot-instructions.md"
require_file "AGENTS.md"
require_file "README.md"

require_file ".github/agents/brief/audio-engineer.md"
require_file ".github/agents/brief/systems-engineer.md"
require_file ".github/agents/brief/ai-engineer.md"

require_file ".copilot-tracking/templates/mcp-integration-testing.instructions.md"
require_file ".copilot-tracking/changes/README.md"

# Extract MCP server names from .vscode/mcp.json
mcp_servers_json="$repo_root/.vscode/mcp.json"

mcp_servers=$(
  python3 - <<'PY'
import json
from pathlib import Path

p = Path('.vscode/mcp.json')
with p.open('r', encoding='utf-8') as f:
  data = json.load(f)

servers = data.get('mcpServers', {})
for name in sorted(servers.keys()):
  print(name)
PY
) || {
  fail "unable to parse .vscode/mcp.json (invalid JSON?)"
  mcp_servers=""
}

if [[ -n "$mcp_servers" ]]; then
  pass "parsed MCP servers from .vscode/mcp.json"
else
  fail "no MCP servers detected in .vscode/mcp.json"
fi

# Ensure each MCP server is documented in the core docs.
for server in $mcp_servers; do
  require_contains ".github/copilot-instructions.md" "$server"
  require_contains "AGENTS.md" "$server"
  require_contains "README.md" "$server"
done

# Ensure the filesystem MCP root is portable.
if grep -qE -- '"@modelcontextprotocol/server-filesystem"[[:space:]]*,[[:space:]]*"/Users/' .vscode/mcp.json; then
  fail "filesystem MCP root is hardcoded to /Users/... (should use \"\${workspaceFolder}\")"
else
  pass "filesystem MCP root is not hardcoded to /Users/..."
fi

if grep -qF -- '"${workspaceFolder}"' .vscode/mcp.json; then
  pass "filesystem MCP uses \${workspaceFolder}"
else
  fail "filesystem MCP does not reference \${workspaceFolder}"
fi

# Ensure docs point to brief agent pages (not playbooks).
require_contains ".github/copilot-instructions.md" ".github/agents/brief/audio-engineer.md"
require_contains ".github/copilot-instructions.md" ".github/agents/brief/systems-engineer.md"
require_contains ".github/copilot-instructions.md" ".github/agents/brief/ai-engineer.md"

require_contains "AGENTS.md" ".github/agents/brief/audio-engineer.md"
require_contains "AGENTS.md" ".github/agents/brief/systems-engineer.md"
require_contains "AGENTS.md" ".github/agents/brief/ai-engineer.md"

require_contains "README.md" ".github/agents/brief/audio-engineer.md"
require_contains "README.md" ".github/agents/brief/systems-engineer.md"
require_contains "README.md" ".github/agents/brief/ai-engineer.md"

say ""
if [[ "$failures" -eq 0 ]]; then
  say "All checks passed."
  exit 0
fi

say "$failures check(s) failed."
exit 1
