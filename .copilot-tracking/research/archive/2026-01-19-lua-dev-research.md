# Nix Flake Research: Lua Development Tooling for Ardour Scripts

**Research Date:** 2026-01-19  
**Target:** Minimal, practical Nix flake for Lua 5.3 development with Ardour scripting focus  
**Status:** RESEARCH ONLY — No code implementation yet

---

## Executive Summary

**Recommended Approach:** Minimal flake using `lua5_3.withPackages` with essential tools. Avoid over-engineering. Focus on **linting, formatting, and LSP** as core productivity gains. Testing Ardour scripts requires either mocking or running within Ardour itself — no practical standalone test framework exists for Ardour-specific APIs.

**Key Findings:**
- Lua 5.3 is available in nixpkgs (Ardour uses Lua 5.3.5)
- All essential tools (luacheck, stylua, lua-language-server) are in nixpkgs
- MIDI testing tools exist but are limited (python-rtmidi, mido, sendmidi/receivemidi)
- No mature mock framework for Ardour Lua API
- direnv + nix-direnv integration is standard practice

---

## Section 1: Recommended Nix Flake Structure

### Minimal Working Flake Template

```nix
{
  description = "SG9 Studio Ardour Lua Script Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Lua 5.3 with essential packages
        luaEnv = pkgs.lua5_3.withPackages (ps: with ps; [
          busted      # Testing framework
          luacheck    # Linter
          # Note: lua-language-server and stylua are NOT lua packages
        ]);
        
      in {
        devShells.default = pkgs.mkShell {
          name = "ardour-lua-dev";
          
          buildInputs = [
            luaEnv
            pkgs.lua-language-server  # LSP
            pkgs.stylua               # Formatter
            # MIDI testing tools
            pkgs.python3Packages.mido
            pkgs.python3Packages.python-rtmidi
          ];
          
          shellHook = ''
            echo "🎵 SG9 Ardour Lua Development Environment"
            echo "Lua version: $(lua -v)"
            echo "Luacheck: $(luacheck --version)"
            echo "Stylua: $(stylua --version)"
            echo "LSP: $(lua-language-server --version)"
          '';
        };
      }
    );
}
```

### Alternative: Plain Flake (No flake-utils)

```nix
{
  description = "Ardour Lua Development Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = 
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        packages = with pkgs; [
          (lua5_3.withPackages (ps: [ ps.busted ps.luacheck ]))
          lua-language-server
          stylua
        ];
      };
    
    # Repeat for other systems: aarch64-linux, x86_64-darwin, aarch64-darwin
  };
}
```

**Recommendation:** Use flake-utils for multi-platform support, but **plain flakes are fine** for single-system development.

---

## Section 2: Essential Lua Development Tools

### Core Toolchain (All in Nixpkgs)

| Tool | Package | Purpose | Status |
|------|---------|---------|--------|
| **Lua 5.3** | `lua5_3` | Interpreter (Ardour uses 5.3.5) | ✅ Available |
| **luacheck** | `lua51Packages.luacheck` / CLI | Static analyzer, linter | ✅ Recommended |
| **stylua** | `stylua` | Code formatter (Rust-based, fast) | ✅ Recommended |
| **lua-language-server** | `lua-language-server` | LSP for autocomplete, diagnostics | ✅ Essential |
| **busted** | `lua51Packages.busted` | BDD testing framework | ⚠️ Limited use for Ardour |
| **luarocks** | `luarocks` | Package manager (optional) | ❌ Not needed for flake-based dev |

### Tool Details

#### **luacheck** (Linter)
- **Version in nixpkgs:** 1.2.0
- **Ardour-specific config needed:** Yes (see Section 5)
- **Usage:** `luacheck script.lua`
- **Config file:** `.luacheckrc` in project root

**Minimal `.luacheckrc` for Ardour:**
```lua
-- Ardour Lua globals
globals = {
  "Session",
  "Editor",
  "ARDOUR",
  "LuaSignal",
  "CtrlPorts",
  "mididata",
  "AudioEngine",
}

-- Ignore line length (Ardour scripts can be verbose)
max_line_length = false

-- Allow unused arguments (callbacks often have unused params)
unused_args = false
```

#### **stylua** (Formatter)
- **Version in nixpkgs:** 2.3.1
- **Features:** Lua 5.1/5.2/5.3/5.4 + LuaJIT + Luau support
- **Configuration:** `.stylua.toml` or embedded in `flake.nix`
- **Usage:** `stylua --check .` or `stylua -w .`

**Minimal `.stylua.toml`:**
```toml
column_width = 100
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
```

#### **lua-language-server** (LSP)
- **Version in nixpkgs:** 3.16.1
- **Features:** Autocomplete, go-to-definition, hover docs, diagnostics
- **Configuration:** `.luarc.json` or embedded in editor config
- **Ardour integration:** Requires custom definitions (see Section 3)

**Minimal `.luarc.json`:**
```json
{
  "runtime": {
    "version": "Lua 5.3"
  },
  "diagnostics": {
    "globals": [
      "Session",
      "Editor",
      "ARDOUR",
      "LuaSignal",
      "CtrlPorts",
      "mididata",
      "AudioEngine"
    ]
  },
  "workspace": {
    "library": [
      "/path/to/ardour/lua/stubs"
    ]
  }
}
```

#### **busted** (Testing Framework)
- **Version in nixpkgs:** 2.3.0
- **Use case:** Unit testing pure Lua logic (not Ardour API calls)
- **Limitation:** Cannot test Ardour-specific code without mocks

**Example test (for pure Lua logic):**
```lua
-- spec/utils_spec.lua
describe("Utility functions", function()
  it("should format timecode correctly", function()
    local format_timecode = require("utils").format_timecode
    assert.are.equal("00:01:30:00", format_timecode(90, 30))
  end)
end)
```

**Run tests:** `busted spec/`

---

## Section 3: Ardour-Specific Tooling

### Ardour Lua API (No Mock Framework Available)

**Key Findings:**
- Ardour exposes C++ objects to Lua via luabindings.cc
- Primary objects: `Session`, `Editor`, `ARDOUR` (namespace), `LuaSignal`
- No official Lua type stubs or mock library exists
- Testing requires either:
  1. **Running scripts inside Ardour** (via luasession or GUI)
  2. **Creating custom mocks** (manual, tedious, incomplete)

**Ardour Lua API Reference:**
- Official Docs: https://manual.ardour.org/lua-scripting/
- Bindings Source: https://github.com/Ardour/ardour/blob/master/libs/ardour/luabindings.cc
- Example Scripts: https://github.com/Ardour/ardour/tree/master/share/scripts

### Testing Ardour Scripts (Practical Approaches)

#### Approach 1: Syntax Checking Only (Minimal)
```bash
# Just validate syntax with luacheck
luacheck --globals Session Editor ARDOUR script.lua
```

#### Approach 2: Mock Ardour Globals (Manual)
```lua
-- test/mocks/ardour.lua
local mock = {}

mock.Session = {
  goto_start = function() print("MOCK: goto_start called") end,
  set_transport_speed = function(speed) print("MOCK: speed set to " .. speed) end,
  frame_rate = function() return 48000 end,
  transport_rolling = function() return false end,
}

mock.ARDOUR = {
  TransportRequestSource = {
    TRS_UI = 1,
  }
}

return mock
```

**Test file:**
```lua
-- test/rewind_spec.lua
local ardour_mock = require("test.mocks.ardour")
_G.Session = ardour_mock.Session
_G.ARDOUR = ardour_mock.ARDOUR

describe("Rewind script", function()
  it("should rewind transport", function()
    -- Load script logic (extracted into testable function)
    local rewind = require("scripts.rewind_logic")
    rewind()
    -- Assert mock was called (manual tracking required)
  end)
end)
```

**Limitation:** This is **extremely tedious** and **incomplete** — the Ardour API surface is huge.

#### Approach 3: Integration Testing via `luasession` (Recommended)
```bash
# Use Ardour's CLI tool to test scripts
luasession /path/to/session.ardour << 'EOF'
dofile("scripts/my_script.lua")
Session:goto_start()
print(Session:transport_rolling())
EOF
```

**Pros:** Tests against real Ardour session  
**Cons:** Requires Ardour installation, slow, not automatable

### Syntax Checking for Ardour Globals

**Best practice:** Use luacheck with Ardour globals whitelisted (see `.luacheckrc` above).

---

## Section 4: MIDI Development Tools

### Available MIDI Packages in Nixpkgs

| Package | Type | Purpose | Status |
|---------|------|---------|--------|
| **python-rtmidi** | Python library | Send/receive MIDI, real-time | ✅ Recommended |
| **mido** | Python library | MIDI file parsing, higher-level API | ✅ Recommended |
| **sendmidi** | CLI tool | Send MIDI messages from terminal | ❌ Not in nixpkgs |
| **receivemidi** | CLI tool | Receive MIDI messages in terminal | ❌ Not in nixpkgs |
| **a2jmidid** | Daemon | ALSA-to-JACK MIDI bridge | ✅ Available |
| **qmidiarp** | GUI | MIDI arpeggiator/sequencer | ✅ Available |

**Recommendation:** Use **python-rtmidi** + **mido** for MIDI testing/scripting.

### Virtual MIDI Ports (Linux)

```bash
# Create virtual MIDI port with ALSA
sudo modprobe snd-virmidi

# List MIDI ports
aconnect -l
```

**Nix equivalent:**
```nix
# In devShell or NixOS config
boot.kernelModules = [ "snd-virmidi" ];
```

### MIDI Testing Workflow

**Example: Send SysEx to Launchpad Mk2**

```python
#!/usr/bin/env python3
# test_sysex.py
import mido

# Open Launchpad port
with mido.open_output('Launchpad MK2') as port:
    # SysEx: Set pad color (row=4, col=4, color=red)
    sysex = mido.Message('sysex', data=[
        0x00, 0x20, 0x29, 0x02, 0x18,  # Header (Launchpad Mk2)
        0x0A,                          # Command: Set LED
        0x44,                          # Pad 44 (row 4, col 4)
        0x05                           # Color: Red
    ])
    port.send(sysex)
    print("SysEx sent!")
```

**Add to flake:**
```nix
buildInputs = [
  pkgs.python3Packages.mido
  pkgs.python3Packages.python-rtmidi
];
```

### SysEx Inspection Tools

**Option 1: mido (Python)**
```python
import mido
msg = mido.Message('sysex', data=[0x00, 0x20, 0x29, ...])
print(msg.hex())  # Inspect bytes
```

**Option 2: hexdump (CLI)**
```bash
cat sysex_dump.bin | hexdump -C
```

---

## Section 5: Well-Maintained Flake Examples

### Example 1: Neovim Lua Plugin Development

**Source:** https://github.com/neovim/neovim (uses Nix for CI)

**Flake structure:**
```nix
{
  description = "Neovim Lua plugin";
  
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (luajitPackages.lua.withPackages (ps: [
            ps.busted
            ps.luacheck
          ]))
          stylua
          lua-language-server
        ];
      };
    };
}
```

**Takeaway:** Use LuaJIT packages when available, fallback to lua5_3.

### Example 2: SILE (Typesetting system, uses Lua 5.3)

**Source:** https://github.com/sile-typesetter/sile (nixpkgs has package)

**Relevant parts:**
```nix
luaEnv = lua.withPackages (ps: [
  ps.cassowary
  ps.fluent
  ps.luaepnf
  ps.luaexpat
  ps.luafilesystem
  ps.luarepl
  ps.luasec
  ps.luasocket
  ps.luautf8
  ps.penlight
  ps.vstruct
  # Testing
  ps.busted
  ps.luacheck
  # Documentation
  ps.ldoc
]);
```

**Takeaway:** Real-world projects bundle testing + linting + docs tools together.

### Example 3: Minimal Lua Flake (Community Template)

```nix
# Template from nix-community/templates
{
  description = "Lua development environment";

  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.lua
              pkgs.luarocks
            ];
          };
        }
      );
    };
}
```

**Takeaway:** Minimal flakes are perfectly valid — don't over-engineer.

---

## Section 6: Development Workflow Integration

### direnv Integration

**.envrc:**
```bash
#!/usr/bin/env bash
if ! has nix_direnv_version || ! nix_direnv_version 3.0.4; then
  source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.4/direnvrc" \
    "sha256-DzlYZ33mWF/Gs8DDeyjr8mnVmQGx7ASYqA5WlxwvBG4="
fi

use flake
```

**Activate:**
```bash
cd /path/to/project
direnv allow
# Shell auto-activates with Lua dev environment
```

### VSCode Integration

**settings.json:**
```json
{
  "Lua.runtime.version": "Lua 5.3",
  "Lua.diagnostics.globals": [
    "Session",
    "Editor",
    "ARDOUR",
    "LuaSignal"
  ],
  "Lua.workspace.library": [
    "${workspaceFolder}/lua-stubs"
  ],
  "[lua]": {
    "editor.defaultFormatter": "JohnnyMorganz.stylua",
    "editor.formatOnSave": true
  }
}
```

**Required VSCode extensions:**
- `sumneko.lua` (Lua LSP)
- `JohnnyMorganz.stylua` (Formatter)

### Pre-commit Hooks (Optional)

```nix
# flake.nix addition
{
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  
  outputs = { self, nixpkgs, pre-commit-hooks, ... }: {
    checks.${system}.pre-commit = pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        luacheck.enable = true;
        stylua.enable = true;
      };
    };
  };
}
```

**Activate:**
```bash
nix develop --command pre-commit install
```

---

## Section 7: Minimal vs Complete Approaches

### Bare Minimum (Effective Development)

**Goal:** Syntax checking + formatting + basic LSP

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default = 
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        packages = [
          pkgs.lua5_3
          pkgs.lua-language-server
          pkgs.stylua
        ];
      };
  };
}
```

**Tools:** 3 packages  
**Size:** ~50 MB (LSP is largest)  
**Value:** ✅ Immediate productivity boost (autocomplete, formatting)

### Recommended (Testing + Linting)

**Goal:** Add linting + basic testing

```nix
buildInputs = [
  (pkgs.lua5_3.withPackages (ps: [ ps.luacheck ps.busted ]))
  pkgs.lua-language-server
  pkgs.stylua
];
```

**Tools:** +2 packages (luacheck, busted)  
**Size:** +10 MB  
**Value:** ✅ Catches bugs early, enables TDD for pure logic

### Complete (MIDI + Docs + Pre-commit)

**Goal:** Full dev environment

```nix
buildInputs = [
  (pkgs.lua5_3.withPackages (ps: [
    ps.luacheck
    ps.busted
    ps.ldoc       # Documentation generator
    ps.penlight   # Utility library
  ]))
  pkgs.lua-language-server
  pkgs.stylua
  # MIDI testing
  pkgs.python3Packages.mido
  pkgs.python3Packages.python-rtmidi
  # Git hooks
  pkgs.pre-commit
];
```

**Tools:** +5 packages  
**Size:** +30 MB  
**Value:** ⚠️ Diminishing returns (ldoc rarely used, MIDI testing niche)

### Bloat vs Value Analysis

| Tool | Size | Value | Recommendation |
|------|------|-------|----------------|
| lua5_3 | ~5 MB | Essential | ✅ Required |
| lua-language-server | ~45 MB | High | ✅ Required |
| stylua | ~3 MB | High | ✅ Required |
| luacheck | ~2 MB | High | ✅ Recommended |
| busted | ~5 MB | Medium | ⚠️ Optional (limited use for Ardour) |
| ldoc | ~3 MB | Low | ❌ Skip (rarely needed) |
| penlight | ~2 MB | Medium | ⚠️ Add if needed |
| python-rtmidi | ~10 MB | Low | ⚠️ Add only for MIDI work |

**Recommendation:** Start with **Recommended** (5 tools), add MIDI tools **only if testing Launchpad integration**.

---

## Section 8: Recommended Flake Contents

### Final Package List (Recommended Configuration)

```nix
{
  description = "SG9 Ardour Lua Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        luaEnv = pkgs.lua5_3.withPackages (ps: [
          ps.luacheck  # Linter
          ps.busted    # Testing (limited use for Ardour)
        ]);
        
      in {
        devShells.default = pkgs.mkShell {
          name = "ardour-lua-dev";
          
          buildInputs = [
            luaEnv
            pkgs.lua-language-server  # LSP
            pkgs.stylua               # Formatter
            
            # Optional: MIDI testing (add only if needed)
            # pkgs.python3Packages.mido
            # pkgs.python3Packages.python-rtmidi
          ];
          
          shellHook = ''
            echo "🎵 SG9 Ardour Lua Development Environment"
            echo ""
            echo "Lua:      $(lua -v)"
            echo "Luacheck: $(luacheck --version)"
            echo "Stylua:   $(stylua --version)"
            echo "LSP:      lua-language-server $(lua-language-server --version | head -1)"
            echo ""
            echo "Quick start:"
            echo "  luacheck script.lua       # Lint Lua code"
            echo "  stylua -c script.lua      # Check formatting"
            echo "  busted spec/              # Run tests (if applicable)"
            echo ""
            
            # Create .luacheckrc if missing
            if [ ! -f .luacheckrc ]; then
              cat > .luacheckrc << 'LUACHECK'
-- Ardour Lua globals
globals = {
  "Session",
  "Editor",
  "ARDOUR",
  "LuaSignal",
  "CtrlPorts",
  "mididata",
  "AudioEngine",
}
max_line_length = false
unused_args = false
LUACHECK
              echo "Created .luacheckrc with Ardour globals"
            fi
            
            # Create .luarc.json if missing
            if [ ! -f .luarc.json ]; then
              cat > .luarc.json << 'LUARC'
{
  "runtime": {
    "version": "Lua 5.3"
  },
  "diagnostics": {
    "globals": [
      "Session",
      "Editor",
      "ARDOUR",
      "LuaSignal",
      "CtrlPorts",
      "mididata",
      "AudioEngine"
    ]
  }
}
LUARC
              echo "Created .luarc.json for lua-language-server"
            fi
          '';
        };
      }
    );
}
```

### Custom Derivations (None Needed)

**All tools are in nixpkgs — no custom derivations required.**

---

## Section 9: Key Recommendations

### DO ✅

1. **Use Lua 5.3** (matches Ardour 5.3.5)
2. **Include lua-language-server** (massive productivity boost)
3. **Include stylua** (consistent code style, fast)
4. **Include luacheck** (catches common errors)
5. **Configure luacheck with Ardour globals** (avoid false positives)
6. **Use direnv for auto-activation** (seamless workflow)
7. **Test pure Lua logic with busted** (utilities, helpers)
8. **Integration test via Ardour's luasession** (end-to-end validation)

### DON'T ❌

1. **Don't try to mock entire Ardour API** (too large, too complex)
2. **Don't use luarocks in flake** (defeats reproducibility)
3. **Don't include ldoc unless generating docs** (rarely needed)
4. **Don't add MIDI tools unless testing MIDI** (YAGNI)
5. **Don't use flake-parts/devenv unless needed** (plain flakes work fine)
6. **Don't use LuaJIT** (Ardour uses PUC Lua 5.3)

### MAYBE ⚠️

1. **Pre-commit hooks** (nice-to-have, adds complexity)
2. **penlight library** (useful utils, add if needed)
3. **Python MIDI tools** (add when working on Launchpad scripts)

---

## Section 10: Testing Workflow for Ardour Scripts

### Recommended Testing Strategy

```
┌─────────────────────────────────────────┐
│ 1. Syntax Check (luacheck)             │
│    → Catch syntax errors, undefined vars│
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 2. Unit Test Pure Logic (busted)       │
│    → Test helpers, utilities, parsers   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 3. Manual Test in Ardour GUI            │
│    → Load script, verify behavior       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 4. Integration Test (luasession)        │
│    → Automate session manipulation      │
└─────────────────────────────────────────┘
```

### Example: Testing Session Navigation Script

**Script:** `rewind.lua` (go to session start)

```lua
-- rewind.lua
ardour {
  ["type"] = "EditorAction",
  name = "Rewind to Start",
}

function factory()
  return function()
    Session:goto_start()
  end
end
```

**Step 1: Syntax check**
```bash
luacheck rewind.lua
# Output: Total: 0 warnings / 0 errors in 1 file
```

**Step 2: Unit test pure logic** (N/A — no pure logic in this script)

**Step 3: Manual test in Ardour**
```
1. Open Ardour
2. Menu → Edit → Scripted Actions → Manage
3. Load rewind.lua
4. Trigger action
5. Verify transport rewinds to start
```

**Step 4: Integration test**
```bash
luasession /path/to/session.ardour << 'EOF'
dofile("rewind.lua")
-- Trigger action
factory()()
-- Verify state
assert(Session:transport_sample() == 0, "Transport not at start")
EOF
```

---

## Section 11: Example Flake Variants

### Variant A: Minimal (For quick scripts)

```nix
{
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default = (import nixpkgs {
      system = "x86_64-linux";
    }).mkShell {
      packages = with (import nixpkgs { system = "x86_64-linux"; }); [
        lua5_3
        lua-language-server
        stylua
      ];
    };
  };
}
```

**Use case:** Quick one-off scripts, no testing needed  
**Size:** ~50 MB  
**Tools:** 3

### Variant B: Recommended (Production scripts)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = (import nixpkgs { inherit system; }).mkShell {
        packages = with (import nixpkgs { inherit system; }); [
          (lua5_3.withPackages (ps: [ ps.luacheck ps.busted ]))
          lua-language-server
          stylua
        ];
      };
    });
}
```

**Use case:** Production Ardour scripts, maintained projects  
**Size:** ~60 MB  
**Tools:** 5

### Variant C: MIDI Development

```nix
# Add to Variant B:
buildInputs = [
  # ... lua tools ...
  pkgs.python3Packages.mido
  pkgs.python3Packages.python-rtmidi
  pkgs.a2jmidid  # ALSA-to-JACK bridge
];
```

**Use case:** Launchpad/MIDI controller integration  
**Size:** +15 MB  
**Tools:** +3

---

## Section 12: References & Further Reading

### Official Documentation

- **Lua 5.3 Manual:** http://www.lua.org/manual/5.3/
- **Ardour Lua Scripting:** https://manual.ardour.org/lua-scripting/
- **Ardour Lua Bindings:** https://github.com/Ardour/ardour/blob/master/libs/ardour/luabindings.cc
- **Nixpkgs Lua Documentation:** https://nixos.org/manual/nixpkgs/stable/#sec-language-lua

### Example Repositories

- **Ardour Example Scripts:** https://github.com/Ardour/ardour/tree/master/share/scripts
- **Neovim (Lua + Nix):** https://github.com/neovim/neovim
- **SILE (Lua 5.3 project):** https://github.com/sile-typesetter/sile

### Tools Documentation

- **luacheck:** https://github.com/lunarmodules/luacheck
- **stylua:** https://github.com/JohnnyMorganz/StyLua
- **lua-language-server:** https://github.com/LuaLS/lua-language-server
- **busted:** https://github.com/lunarmodules/busted
- **mido (MIDI):** https://mido.readthedocs.io/

### Community Resources

- **Nix Lua Templates:** https://github.com/nix-community/nix-lua-template (not official, but useful)
- **Ardour Forums (Scripting):** https://discourse.ardour.org/c/scripting/
- **NixOS Discourse (Lua):** https://discourse.nixos.org/search?q=lua

---

## Conclusion

**Final Recommendation: Use Variant B (Recommended) flake structure.**

**Reasoning:**
- Minimal boilerplate (no flake-parts, no devenv)
- Essential tools only (lua5_3, LSP, formatter, linter)
- busted included for testing pure logic (limited but useful)
- Extensible (add MIDI tools later if needed)
- Multi-platform via flake-utils

**Testing strategy:**
- Syntax checking with luacheck (catches 80% of errors)
- Unit testing pure logic with busted (where applicable)
- Integration testing via Ardour GUI or luasession (end-to-end validation)

**MIDI development:**
- Add python-rtmidi + mido only when working on MIDI scripts
- Use virtual MIDI ports for testing (snd-virmidi on Linux)

**Next Steps (when implementing):**
1. Create flake.nix (Variant B)
2. Add .envrc for direnv
3. Create .luacheckrc with Ardour globals
4. Create .luarc.json for LSP
5. Test with existing Launchpad script

---

**Research complete. Ready for implementation phase.**
