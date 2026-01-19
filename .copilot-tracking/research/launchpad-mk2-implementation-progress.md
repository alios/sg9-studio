# SG9 Studio - Launchpad Mk2 Implementation Progress

**Started:** 2026-01-19  
**Completed:** 2026-01-19  
**Status:** ✅ Complete (template creation optional)

## Implementation Checklist

### Phase 1: Development Environment Setup ✅

- [x] Create Nix flake with Lua 5.3, LSP, stylua, luacheck, busted
- [x] Add ardour package for luasession CLI testing
- [x] Add python3 with rtmidi/mido for MIDI testing
- [x] Support aarch64-linux and aarch64-darwin platforms
- [x] Create .luacheckrc with Ardour-specific globals
- [x] Create .luarc.json for lua-language-server
- [x] Create .envrc for direnv integration
- [x] Enable Serena MCP server (requires source files to exist)

### Phase 2: Lua Scripts ✅

- [x] scripts/launchpad_mk2_feedback.lua (main LED feedback) - **COMPLETED**
  - [x] EditorHook with adaptive polling (100ms/500ms)
  - [x] MIDI port auto-detection (regex patterns)
  - [x] SysEx builders (solid + pulse modes)
  - [x] Error recovery with 3-retry exponential backoff
  - [x] Hotplug detection and reconnection (every 5s)
  - [x] Error marker creation/deletion on timeline
  - [x] State cache for performance optimization
  - [x] Rate limiting (50 SysEx/sec max)
  - [x] Performance metrics logging (every 60s, optional)
  - [x] Validated with luacheck (0 errors, 22 expected Ardour globals warnings)
  - [x] Formatted with stylua
  
- [x] scripts/launchpad_mk2_refresh_leds.lua (manual refresh) - **COMPLETED**
  - [x] EditorAction script (user-triggered)
  - [x] Full 80-LED refresh logic (grid + top row + scene column)
  - [x] Transport LED state (play/stop/rec/loop)
  - [x] Track state refresh for 8 tracks
  - [x] 2ms delay between SysEx messages (USB MIDI rate limit)
  - [x] Validated with luacheck and formatted with stylua
  
- [x] scripts/launchpad_mk2_brightness.lua (brightness control) - **COMPLETED**
  - [x] EditorAction script (user ✅

- [x] ~/.config/ardour8/midi_maps/sg9-launchpad-mk2.map - **COMPLETED**
  - [x] Top row transport mappings (104-111: play/stop/rec/loop/rew/ffw/home/end)
  - [x] Grid row 1 (81-88: track arm B1-B8)
  - [x] Grid row 2 (71-78: track mute B1-B8)
  - [x] Grid row 3 (61-68: track solo B1-B8)
  - [x] Grid rows 4-6 (51-31: cue triggers A1-C8 for Ardour 8.0+)
  - [x] Grid row 7 (21-28: mixer navigation, bank/select/view controls)
  - [x] Grid row 8 (11-18: marker add/prev/next/delete, loop/punch)
  - [x] Scene column (89-9: save/undo/redo, view toggles)
  - [x] Comprehensive inline documentation with ASCII grid diagram
  - [x] Customization examples for plugin bypass/parameter control
### Phase 3: Ardour Configuration

- [ ] ~/.config/ardour8/mi ✅

- [x] Update MIDI-CONTROLLERS.md (v2.0) - **COMPLETED**
  - [x] Launchpad Mk2 overview section (specs, features, SG9 integration)
  - [x] Complete integration section (~600 lines)
  - [x] Architecture overview with Mermaid flowchart
  - [x] Grid layout ASCII diagram (8x8 + top row + scene column)
  - [x] MIDI protocol reference (SysEx commands, color palette)
  - [x] Color reference table (128-color palette subset)
  - [x] Lua architecture documentation (all 3 scripts)
  - [x] Error recovery documentation (auto-reconnection, retry logic, markers)
  - [x] Generic MIDI bindings reference
  - [x] Comprehensive testing  (Optional)

**Status:** Deferred - Requires Ardour 8 GUI on Linux  
**Reason:** Ardour not available on macOS via nixpkgs

Manual creation instructions provided below.

- [ ] Create "SG9 Broadcast + Launchpad Mk2.template"
  - [ ] Embedded Lua scripts (feedback + refresh + brightness)
  - [ ] Generic MIDI control surface configuration
  - [ ] x42 MIDI filter chain (velocity gamma + duplicate blocker)
  - [ ] 8-track SG9 broadcast layout (B1-B8)
  - [ ] Session metadata for brightness persistence workflow
  - [ ] Troubleshooting section
  - [ ] Snapshot workflow examples

### Phase 5: Template Creation

- [ ] Create "SG9 Broadcast + Launchpad Mk2.template"
  - [ ] Embedded Lua scripts
  - [ ] Generic MIDI bindings
  - [ ] x42 filter chain
  - [ ] 8-track SG9 layout

## Research Notes

### Serena MCP Server Setup
- Requires at least one source file (.lua or .nix) to activate
- Auto-detects language from file extensions
- No manual configuration needed for basic usage
- `.serena/` directory created automatically

### Virtual MIDI Testing (Future Enhancement)
- Linux: `snd-virmidi` kernel module for virtual MIDI ports
- macOS: IAC Driver (built-in via Audio MIDI Setup)
- Useful for development without physical Launchpad hardware
- Can be integrated into Nix flake shellHook later

### Luasession CLI Testing
- Ardour provides `luasession` command-line tool
- Can test Lua scripts outside GUI
- Syntax validation: `luasession --test script.lua`
- Available on both aarch64-linux and aarch64-darwin

## Technical Decisions Made

1. **Lua Version:** 5.3 (matches Ardour exactly)
2. **Polling Strategy:** Adaptive (100ms active, 500ms idle)
3. **Error Recovery:** 3-retry exponential backoff
4. **Rate Limiting:** 50 SysEx/sec max
5. **Port Detection:** Regex pattern matching (cross-platform)
6. **Error Notification:** Console logs + timeline markers
7. Implementation Complete! ✅

All core components finished and validated:

1. ✅ **3 Lua Scripts** (total ~900 lines):
   - launchpad_mk2_feedback.lua (EditorHook, real-time LED feedback)
   - launchpad_mk2_refresh_leds.lua (EditorAction, manual refresh)
   - launchpad_mk2_brightness.lua (EditorAction, brightness control)
   
2. ✅ **Generic MIDI Binding Map:**
   - sg9-launchpad-mk2.map (complete transport + track + cue control)
   
3. ✅ **Documentation:**
   - MIDI-CONTROLLERS.md updated with comprehensive Launchpad Mk2 section
   
4. ✅ **Development Environment:**
   - Nix flake with Lua 5.3, dev tools, platform-aware config
   - Luacheck + stylua configuration
   - Serena MCP enabled

## Optional Next Steps (Requires Linux + Ardour GUI)

1. Create Ardour template with embedded scripts
2. Hardware testing with physical Launchpad Mk2
3. Performance benchmarking on large sessions
4. Virtual MIDI loopback testing integration

## Manual Template Creation Instructions

**When on Linux system with Ardour 8 installed:**

1. **Install Scripts:**
   ```bash
   mkdir -p ~/.config/ardour8/scripts
   cp scripts/launchpad_mk2_*.lua ~/.config/ardour8/scripts/
   ```

2. **Install MIDI Map:**
   ```bash
   mkdir -p ~/.config/ardour8/midi_maps
   cp midi_maps/sg9-launchpad-mk2.map ~/.config/ardour8/midi_maps/
   ```

3. **Create Session:**
   - Open Ardour 8
   - `Session → New`
   - Name: "SG9 Broadcast Base"
   - Create 8 audio tracks named B1-B8

4. **Add Lua Scripts:**
   - `Edit → Preferences → Scripting → Manage Scripts`
   - Click "Add Script" → Select `launchpad_mk2_feedback.lua`
   - Check "Active" box
   - Add refresh and brightness scripts (EditorActions, not auto-run)

5. **Configure Generic MIDI:**
   - `Edit → Preferences → Control Surfaces`
   - Enable "Generic MIDI"
   - Click "Show Protocol Settings"
   - Set Incoming: `Launchpad Mk2:Launchpad Mk2 MIDI 1`
   - Set Outgoing: `Launchpad Mk2:Launchpad Mk2 MIDI 1`
   - Click "MIDI Binding File" → Browse to `sg9-launchpad-mk2.map`

6. **Add x42 MIDI Filters (Optional):**
   - Create MIDI track: "Launchpad Input Filter"
   - Add plugins:
     - x42 MIDI Velocity Gamma (gamma=2.0)
     - x42 MIDI Duplicate Blocker (200ms debounce)
   - Route: Launchpad → Filter Track → Generic MIDI → Ardour

7. **Save Template:**
   - `Session → Save Template`
   - Name: "SG9 Broadcast + Launchpad Mk2"
   - Description: "8-track broadcast template with Launchpad Mk2 RGB LED feedback"
   - Check "Include session state"

8. **Verify Template:**
   - `Session → New (from Template)`
   - Select "SG9 Broadcast + Launchpad Mk2"
   - Verify Lua scripts auto-load
   - Verify Generic MIDI active
   - Test: Arm track B1, pad 81 should light red
4. Create companion refresh and brightness scripts
5. Test with luasession CLI before manual Ardour testing

## Interruption Recovery

If interrupted, resume from:
- **Current task:** Creating scripts/launchpad_mk2_feedback.lua
- **Last completed:** Development environment config files
- **Environment ready:** `nix develop` should work
- **Serena ready:** Yes (flake.nix created, can activate project now)
