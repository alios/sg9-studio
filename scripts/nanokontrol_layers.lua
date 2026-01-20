ardour({
    ["type"] = "EditorAction",
    name = "nanoKONTROL: Toggle Layer (Tracks ↔ VCAs)",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
        Switch nanoKONTROL fader assignments between tracks and VCAs.

        Layer A (Default): Faders 1-8 = Tracks B1-B8
        - Fader 1: Host Mic (DSP)
        - Fader 2: Host Mic (Raw)
        - Fader 3: Guest Mic
        - Fader 4: (unused)
        - Fader 5: Aux Input
        - Fader 6: Remote Guest
        - Fader 7: Music 1
        - Fader 8: Music 2

        Layer B (VCA Mode): Faders control busses/VCAs
        - Fader 1: (unused)
        - Fader 2: (unused)
        - Fader 3: Voice Bus
        - Fader 4: Music Bus
        - Fader 5: Master Out
        - Fader 6: Voice Master VCA
        - Fader 7: Music Master VCA
        - Fader 8: Master Control VCA

        Usage:
        1. Assign keyboard shortcut: Edit → Preferences → Keyboard
        2. Search "nanoKONTROL Toggle Layer"
        3. Assign key (e.g., F2)

        Current limitation:
        - Ardour Generic MIDI does not support dynamic MIDI binding updates
        - This script stores layer state but cannot remap faders automatically
        - Workaround: Use Editor → MIDI Learn manually for VCA layer

        Manual MIDI Learn for VCA Layer:
        1. Run this script to switch to VCA layer
        2. Right-click Voice Master VCA fader → MIDI Learn
        3. Move nanoKONTROL Fader 6
        4. Right-click Music Master VCA fader → MIDI Learn
        5. Move nanoKONTROL Fader 7
        6. Right-click Master Control VCA fader → MIDI Learn
        7. Move nanoKONTROL Fader 8

        To return to Track layer:
        1. Run this script again
        2. Reload Generic MIDI map: Edit → Preferences → Control Surfaces
        3. Generic MIDI → MIDI Binding File → Reload

        Future enhancement: OSC-based dynamic binding (requires additional setup)
    ]],
})

function factory(params)
    return function()
        local session = Session

        -- Store layer state in session metadata
        -- Metadata persists with session file
        local current_layer = session:metadata():get_value("nanokontrol_layer") or "tracks"

        if current_layer == "tracks" then
            -- Switch to VCA layer
            session:metadata():set_value("nanokontrol_layer", "vcas")
            print("\n═══════════════════════════════════════════════════")
            print("🎚️  nanoKONTROL Layer: VCAs/Busses")
            print("═══════════════════════════════════════════════════")
            print("   Fader 3: Voice Bus")
            print("   Fader 4: Music Bus")
            print("   Fader 5: Master Out")
            print("   Fader 6: Voice Master VCA")
            print("   Fader 7: Music Master VCA")
            print("   Fader 8: Master Control VCA")
            print("\n⚠️  Manual MIDI Learn Required:")
            print("   1. Right-click Voice Master VCA → MIDI Learn")
            print("   2. Move nanoKONTROL Fader 6")
            print("   3. Repeat for Music Master (F7), Master Control (F8)")
            print("═══════════════════════════════════════════════════\n")
        else
            -- Switch back to track layer
            session:metadata():set_value("nanokontrol_layer", "tracks")
            print("\n═══════════════════════════════════════════════════")
            print("🎚️  nanoKONTROL Layer: Tracks B1-B8")
            print("═══════════════════════════════════════════════════")
            print("   Fader 1: Host Mic (DSP)")
            print("   Fader 2: Host Mic (Raw)")
            print("   Fader 3: Guest Mic")
            print("   Fader 4: (unused)")
            print("   Fader 5: Aux Input")
            print("   Fader 6: Remote Guest")
            print("   Fader 7: Music 1")
            print("   Fader 8: Music 2")
            print("\n⚠️  Reload Generic MIDI map:")
            print("   Edit → Preferences → Control Surfaces")
            print("   Generic MIDI → Show Protocol Settings")
            print("   MIDI Binding File → Reload")
            print("═══════════════════════════════════════════════════\n")
        end
    end
end
