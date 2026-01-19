ardour({
    ["type"] = "SessionStart",
    name = "Auto-Arm Recording Tracks",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
        Automatically arm specific tracks on session load.

        Tracks auto-armed:
        - Host Mic (DSP) — Primary processed voice
        - Host Mic (Raw) — Safety/backup recording
        - Master Bus Record — Final mix backup
        - Mix-Minus Record — Remote guest troubleshooting

        Benefits:
        - Eliminates pre-show checklist item
        - Prevents "forgot to arm track" errors
        - Matches professional automation (RCS Zetta, mAirList)

        Installation:
        1. Save to ~/.config/ardour8/scripts/auto_arm_tracks.lua
        2. Edit → Preferences → Scripting → Session Scripts
        3. Add "auto_arm_tracks.lua"
        4. Check "Auto-start"
        5. Restart Ardour or load session

        Disable: Uncheck "Auto-start" in Session Scripts preferences
    ]],
})

function factory(params)
    return function()
        local session = Session

        -- Wait for session to fully load (arbitrary delay)
        -- This ensures all tracks are available before arming
        ARDOUR.LuaAPI.usleep(500000) -- 500ms delay

        -- Tracks to automatically arm on session load
        local auto_arm_tracks = {
            "Host Mic (DSP)",      -- Primary voice track
            "Host Mic (Raw)",      -- Safety/backup recording
            "Master Bus Record",   -- Final mix backup
            "Mix-Minus Record",    -- Remote guest troubleshooting
        }

        local armed_count = 0
        local failed_tracks = {}

        for _, track_name in ipairs(auto_arm_tracks) do
            local track = session:route_by_name(track_name)

            if track and not track:isnil() then
                -- Check if this route is actually a track (not a bus)
                local as_track = track:to_track()

                if as_track and not as_track:isnil() then
                    -- Arm the track
                    as_track:rec_enable_control():set_value(1, PBD.GroupControlDisposition.NoGroup)
                    armed_count = armed_count + 1
                    print(string.format("✅ Auto-armed: %s", track_name))
                else
                    table.insert(failed_tracks, track_name .. " (not a track)")
                end
            else
                table.insert(failed_tracks, track_name .. " (not found)")
            end
        end

        -- Summary log
        print(string.format("🎙️ Auto-Arm Complete: %d tracks armed", armed_count))

        if #failed_tracks > 0 then
            print("⚠️ Failed to arm:")
            for _, name in ipairs(failed_tracks) do
                print("  - " .. name)
            end
        end

        -- Optional: Display notification in GUI (if available)
        -- Note: This may not work in all contexts
        if Editor then
            -- Editor:flash_message(string.format("Auto-armed %d tracks", armed_count))
        end
    end
end
