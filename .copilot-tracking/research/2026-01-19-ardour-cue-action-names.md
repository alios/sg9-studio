# Cue Trigger Action Names - Verified from Ardour Source Code

**Source:** Ardour/ardour GitHub repository (2026-01-19)  
**Files Analyzed:**
- `gtk2_ardour/trigger_page.cc` (lines 970-1004)
- `gtk2_ardour/ardour_ui.cc` (lines 3127-3158)
- `gtk2_ardour/ardour_ui.h` (lines 313-336)

## Individual Cue Slot Triggers

**Action Pattern (Verified):**
```
trigger-slot-{COL}-{ROW}
```

**Implementation (trigger_page.cc:992-994):**
```cpp
const std::string action_name  = string_compose ("trigger-slot-%1-%2", c, n);
const std::string display_name = string_compose (_("Trigger Slot %1/%2"), c, cue_marker_name (n));
ActionManager::register_action (trigger_actions, action_name.c_str (), display_name.c_str (), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::trigger_slot), c, n));
```

**Parameters:**
- `COL` (c): Column number (0-15 for 16 tracks)
- `ROW` (n): Row number (0-15 for 16 slots, uses `cue_marker_name()` for display)

**Examples:**
```
trigger-slot-0-0   # Track 1, Slot A
trigger-slot-0-1   # Track 1, Slot B
trigger-slot-7-15  # Track 8, Slot P
trigger-slot-15-0  # Track 16, Slot A
```

**Handler (ardour_ui.cc:3127-3135):**
```cpp
void ARDOUR_UI::trigger_slot (int c, int r)
{
    if (!_basic_ui) {
        return;
    }
    _basic_ui->bang_trigger_at (c, r);
}
```

## Entire Cue Row (Scene) Triggers

**Action Pattern (Verified):**
```
trigger-cue-{ROW}
```

**Implementation (trigger_page.cc:987-990):**
```cpp
const std::string action_name  = string_compose ("trigger-cue-%1", n);
const std::string display_name = string_compose (_("Trigger Cue %1"), cue_marker_name (n));
ActionManager::register_action (trigger_actions, action_name.c_str (), display_name.c_str (), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::trigger_cue_row), n));
```

**Parameters:**
- `ROW` (n): Row number (0-15), triggers all slots in that row across all tracks

**Examples:**
```
trigger-cue-0   # Trigger all slots in row A (Cue A)
trigger-cue-1   # Trigger all slots in row B (Cue B)
trigger-cue-15  # Trigger all slots in row P (Cue P)
```

**Handler (ardour_ui.cc:3137-3145):**
```cpp
void ARDOUR_UI::trigger_cue_row (int r)
{
    if (!_basic_ui) {
        return;
    }
    _basic_ui->trigger_cue_row (r);
}
```

## Stop Actions

### Stop All Cues

**Actions:**
```
stop-all-cues-now    # Stop immediately
stop-all-cues-soon   # Stop quantized (at bar end)
```

**Implementation (trigger_page.cc:1003-1004):**
```cpp
ActionManager::register_action (trigger_actions, X_("stop-all-cues-now"), _("Stop all cues now"), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::stop_all_cues), true));
ActionManager::register_action (trigger_actions, X_("stop-all-cues-soon"), _("Stop all cues soon"), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::stop_all_cues), false));
```

**Handler (ardour_ui.cc:3147-3153):**
```cpp
void ARDOUR_UI::stop_all_cues (bool immediately)
{
    _basic_ui->trigger_stop_all (immediately);
}
```

### Stop Column-Specific Cues

**Action Pattern:**
```
stop-cues-{COL}-now    # Stop column immediately
stop-cues-{COL}-soon   # Stop column quantized
```

**Implementation (trigger_page.cc:998-999):**
```cpp
ActionManager::register_action (trigger_actions, string_compose ("stop-cues-%1-now", c).c_str(), 
    string_compose (_("Stop Cues %1"), c).c_str(), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::stop_cues), c, true));
ActionManager::register_action (trigger_actions, string_compose ("stop-cues-%1-soon", c).c_str(), 
    string_compose (_("Stop Cues %1"), c).c_str(), 
    sigc::bind (sigc::mem_fun (ARDOUR_UI::instance(), &ARDOUR_UI::stop_cues), c, false));
```

**Parameters:**
- `COL` (c): Column number (0-15)

**Examples:**
```
stop-cues-0-now     # Stop all cues in track 1 immediately
stop-cues-7-soon    # Stop all cues in track 8 quantized
```

**Handler (ardour_ui.cc:3155-3160):**
```cpp
void ARDOUR_UI::stop_cues (int col, bool immediately)
{
    _basic_ui->trigger_stop_col (col, immediately);
}
```

## Usage in MIDI Binding Map

**Correct XML Syntax:**
```xml
<!-- Individual slot triggers -->
<Binding channel="0" note="51" action="trigger-slot-0-0"/>
<Binding channel="0" note="52" action="trigger-slot-0-1"/>

<!-- Scene (entire row) triggers -->
<Binding channel="0" note="89" action="trigger-cue-0"/>
<Binding channel="0" note="79" action="trigger-cue-1"/>

<!-- Stop actions -->
<Binding channel="0" note="19" action="stop-all-cues-soon"/>
```

## Action Name Space

All cue-related actions are registered under the **"Cues"** action group:
```cpp
Glib::RefPtr<ActionGroup> trigger_actions = ActionManager::create_action_group (bindings, X_("Cues"));
```

## Implementation Status

✅ **VERIFIED** - All action names extracted directly from Ardour source code  
✅ **sg9-launchpad-mk2.map** uses correct syntax  
⏳ **REQUIRES TESTING** - MIDI Learn validation still recommended

## Next Steps

1. Load MIDI binding map in Ardour
2. Use MIDI Learn on one cue button to confirm exact syntax
3. If action names differ, update [midi_maps/sg9-launchpad-mk2.map](../../midi_maps/sg9-launchpad-mk2.map)
4. Proceed with [docs/TESTING-CUE-INTEGRATION.md](../../docs/TESTING-CUE-INTEGRATION.md) Test 1

## References

- Ardour source: https://github.com/Ardour/ardour
- Action registration: `gtk2_ardour/trigger_page.cc:970-1004`
- Handler methods: `gtk2_ardour/ardour_ui.cc:3127-3160`
- Public API: `gtk2_ardour/ardour_ui.h:313-336`
