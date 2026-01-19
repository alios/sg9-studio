ardour({
    ["type"] = "EditorAction",
    name = "PANIC: Cut to Music",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
        Emergency: Mute all voice tracks, unmute Music Bus, start playback.

        Use this when:
        - Profanity or inappropriate content occurs
        - Audio feedback emergency
        - Host/guest needs immediate privacy

        Effect:
        - Mutes: Host Mic (DSP), Host Mic (Raw), Guest Mic, Remote Guest, Aux Input, Bluetooth
        - Unmutes: Music Bus (sets to 0 dB)
        - Starts playback if transport stopped
        - Optional: Starts Music 1 track if not already playing

        Keyboard Shortcut: F1 (recommended)
        Launchpad: Scene button 89 (top-right)

        Recovery: Manually unmute tracks when crisis resolved
    ]],
})

function factory(params)
    return function()
        local session = Session

        -- Voice track names to mute (all possible voice inputs)
        local voice_tracks = {
            "Host Mic (DSP)",
            "Host Mic (Raw)",
            "Guest Mic",
            "Remote Guest",
            "Aux Input",
            "Bluetooth",
        }

        local muted_count = 0

        -- Mute all voice tracks
        for _, track_name in ipairs(voice_tracks) do
            local track = session:route_by_name(track_name)
            if track and not track:isnil() then
                -- Set mute control value to 1 (muted)
                track:mute_control():set_value(1, PBD.GroupControlDisposition.NoGroup)
                muted_count = muted_count + 1
            end
        end

        -- Unmute Music Bus and set to 0 dB
        local music_bus = session:route_by_name("Music Bus")
        if music_bus and not music_bus:isnil() then
            -- Unmute
            music_bus:mute_control():set_value(0, PBD.GroupControlDisposition.NoGroup)

            -- Set gain to 0 dB (unity gain = 1.0)
            music_bus:gain_control():set_value(1.0, PBD.GroupControlDisposition.NoGroup)
        end

        -- Start transport if not already rolling
        if not session:transport_rolling() then
            session:request_transport_speed(1.0, true, ARDOUR.TransportRequestSource.TRS_UI)
        end

        -- Optional: Start Music 1 track if it exists
        -- (This assumes Music 1 has audio ready to play)
        local music1 = session:route_by_name("Music 1")
        if music1 and not music1:isnil() then
            -- Unmute Music 1 track
            music1:mute_control():set_value(0, PBD.GroupControlDisposition.NoGroup)
            music1:gain_control():set_value(1.0, PBD.GroupControlDisposition.NoGroup)
        end

        -- Log action (visible in Ardour console: Window → Scripting)
        print(string.format("🚨 PANIC ACTIVATED: Muted %d voice tracks, switched to music", muted_count))

        -- Visual feedback: Flash message in GUI (if available)
        if Editor then
            -- Note: This may not work in all Ardour versions
            -- Editor:flash_message("PANIC: Switched to music mode")
        end
    end
end
