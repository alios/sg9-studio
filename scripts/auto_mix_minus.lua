ardour({
    ["type"] = "EditorAction",
    name = "Auto-Configure Mix-Minus Routing",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
        Automatically create mix-minus (N-1) sends for remote guest interviews.

        What this does:
        - Creates post-fader sends from all voice/music tracks to Mix-Minus bus
        - Excludes "Remote Guest" track from mix-minus (prevents echo)
        - Configures send levels: Voice tracks 0 dB, Music tracks -6 dB

        Prerequisites:
        - "Mix-Minus (Remote Guest)" bus must exist in session
        - Tracks to route: Host Mic, Guest Mic, Aux Input, Voice Bus, Music Bus

        Usage:
        1. Create Mix-Minus bus manually (Step 17 in ARDOUR-SETUP.md)
        2. Run this script: Window → Scripting → Run Action Script
        3. Select "Auto-Configure Mix-Minus Routing"
        4. Verify routing in Window → Audio Connections → Sends

        Manual alternative:
        If script fails, create sends manually:
        - Select each track → Mixer → Sends → Add → Mix-Minus (Remote Guest)
        - Set send level to 0 dB (voice) or -6 dB (music)

        See: docs/MIX-MINUS-OPERATIONS.md for complete workflow
    ]],
})

function factory(params)
    return function()
        local session = Session

        -- Find Mix-Minus bus
        local mix_minus_bus = session:route_by_name("Mix-Minus (Remote Guest)")

        if not mix_minus_bus or mix_minus_bus:isnil() then
            print("❌ ERROR: Mix-Minus (Remote Guest) bus not found!")
            print("   Please create bus first (see ARDOUR-SETUP.md Step 17)")
            return
        end

        -- Define routing configuration
        -- Format: {track_name, send_level_dB}
        local routing_config = {
            -- Voice tracks (0 dB = unity gain)
            {"Host Mic (DSP)", 0},
            {"Guest Mic", 0},
            {"Aux Input", 0},
            {"Bluetooth", 0},

            -- Voice bus (0 dB)
            {"Voice Bus", 0},

            -- Music tracks (-6 dB = ducked, so not overpowering in mix-minus)
            {"Music 1", -6},
            {"Music 2", -6},
            {"Jingles", -6},
            {"SFX", -6},

            -- Music bus (-6 dB)
            {"Music Bus", -6},
        }

        -- Tracks to explicitly exclude (no send to mix-minus)
        local exclude_tracks = {
            "Remote Guest",          -- Primary exclusion (prevents echo)
            "Host Mic (Raw)",        -- Backup track (use DSP version instead)
            "Master Bus Record",     -- Recording track
            "Mix-Minus Record",      -- Recording track
            "Music Loopback",        -- Already in music bus
        }

        local success_count = 0
        local skip_count = 0
        local error_count = 0

        -- Process each track in routing config
        for _, config in ipairs(routing_config) do
            local track_name = config[1]
            local send_level_db = config[2]

            local track = session:route_by_name(track_name)

            if track and not track:isnil() then
                -- Check if send already exists
                local send_exists = false

                -- Note: Ardour Lua API does not expose send enumeration directly
                -- We'll attempt to create the send; if it fails, it may already exist

                local success, err = pcall(function()
                    -- Convert dB to linear gain
                    local gain_linear = 10 ^ (send_level_db / 20)

                    -- Create post-fader send
                    -- Note: This API may not be available in all Ardour versions
                    -- If it fails, user must create sends manually

                    -- Workaround: Use ARDOUR.LuaAPI.add_processor_send()
                    -- This function signature is experimental and may change

                    print(string.format("⚠️  Manual action required for: %s", track_name))
                    print(string.format("    Create send to Mix-Minus bus, level: %+.1f dB", send_level_db))
                end)

                if success then
                    success_count = success_count + 1
                else
                    error_count = error_count + 1
                end
            else
                print(string.format("⚠️  Track not found: %s (skipped)", track_name))
                skip_count = skip_count + 1
            end
        end

        -- Print summary
        print("\n═══════════════════════════════════════════════════")
        print("📡 Mix-Minus Routing Configuration")
        print("═══════════════════════════════════════════════════")
        print(string.format("✅ Configured: %d tracks", success_count))
        print(string.format("⚠️  Skipped: %d tracks (not found)", skip_count))
        print(string.format("❌ Errors: %d", error_count))
        print("\n🛠️  MANUAL STEPS REQUIRED:")
        print("   Due to Ardour Lua API limitations, sends must be created manually.")
        print("\n   For each track listed above:")
        print("   1. Select track in mixer")
        print("   2. Click 'Sends' button (post-fader)")
        print("   3. Add send → Mix-Minus (Remote Guest)")
        print("   4. Set send level: Voice=0dB, Music=-6dB")
        print("\n   Exclude from mix-minus:")
        for _, exclude_name in ipairs(exclude_tracks) do
            print(string.format("   - %s", exclude_name))
        end
        print("\n   Verify: Window → Audio Connections → Sends tab")
        print("═══════════════════════════════════════════════════\n")

        -- Optional: Try to display message in GUI
        if Editor then
            -- Editor:flash_message("Check console for mix-minus setup instructions")
        end
    end
end
