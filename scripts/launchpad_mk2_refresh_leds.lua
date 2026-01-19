ardour({
    ["type"] = "EditorAction",
    name = "Launchpad Mk2: Refresh All LEDs",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
		Manually trigger full LED refresh for Novation Launchpad Mk2.

		Use this when:
		- LEDs are out of sync with track state
		- After Launchpad hardware reset
		- After reconnecting the Launchpad

		This script will resend LED state for all 80 pads based on
		current Ardour session state.
	]],
})

-- ============================================================================
-- CONFIGURATION (matches main feedback script)
-- ============================================================================

local CONFIG = {
    -- MIDI port detection patterns
    port_patterns = {
        "Launchpad.*[Mm][Kk]2",
        "Launchpad MK2",
        "Launchpad Mk2",
    },

    -- Launchpad Mk2 SysEx header (Device ID: 0x18)
    sysex_header = { 0xF0, 0x00, 0x20, 0x29, 0x02, 0x18 },

    -- LED color codes
    colors = {
        off = 0,
        red = 5,
        orange = 9,
        yellow = 13,
        green = 21,
        blue = 45,
        purple = 53,
        white = 3,
    },

    -- Grid layout
    grid = {
        top_row = { 104, 105, 106, 107, 108, 109, 110, 111 },
        row1 = { 81, 82, 83, 84, 85, 86, 87, 88 }, -- Track arm
        row2 = { 71, 72, 73, 74, 75, 76, 77, 78 }, -- Mute
        row3 = { 61, 62, 63, 64, 65, 66, 67, 68 }, -- Solo
        scene = { 89, 79, 69, 59, 49, 39, 29, 19 },
    },
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function log(level, msg)
    local prefix = string.format("[Launchpad Mk2 Refresh] [%s]", level)
    print(prefix, msg)
end

local function find_launchpad_port()
    local engine = Session:engine()
    local success, port_table = engine:get_ports(ARDOUR.DataType("midi"), ARDOUR.PortList())

    if not success or not port_table or not port_table[2] then
        return nil
    end

    for port in port_table[2]:iter() do
        local amp = port:to_asyncmidiport()
        if not amp:isnil() and amp:sends_output() then
            local name = amp:name()

            for _, pattern in ipairs(CONFIG.port_patterns) do
                if string.find(name, pattern) then
                    log("INFO", "Found Launchpad Mk2 port: " .. name)
                    return amp, name
                end
            end
        end
    end

    return nil
end

-- ============================================================================
-- SYSEX BUILDERS
-- ============================================================================

local function build_led_sysex(note, color)
    local syx = {}
    for _, byte in ipairs(CONFIG.sysex_header) do
        table.insert(syx, byte)
    end
    table.insert(syx, 0x0a) -- Color code command
    table.insert(syx, note)
    table.insert(syx, color)
    table.insert(syx, 0xf7)
    return syx
end

local function build_pulse_sysex(note, color)
    local syx = {}
    for _, byte in ipairs(CONFIG.sysex_header) do
        table.insert(syx, byte)
    end
    table.insert(syx, 0x23) -- Pulse command
    table.insert(syx, note)
    table.insert(syx, color)
    table.insert(syx, 0xf7)
    return syx
end

local function table_to_bytes(tbl)
    local str = ""
    for _, byte in ipairs(tbl) do
        str = str .. string.char(byte)
    end
    return str
end

-- ============================================================================
-- LED UPDATE LOGIC
-- ============================================================================

local function get_track_led_color(rec_enabled, muted, soloed, is_recording)
    if is_recording then
        return CONFIG.colors.red, true -- Pulse for recording
    elseif rec_enabled then
        return CONFIG.colors.red, false -- Solid for armed
    elseif muted then
        return CONFIG.colors.orange, false
    elseif soloed then
        return CONFIG.colors.yellow, false
    else
        return CONFIG.colors.green, false -- Ready/idle
    end
end

local function update_led(port, note, color, pulse)
    local sysex
    if pulse then
        sysex = build_pulse_sysex(note, color)
    else
        sysex = build_led_sysex(note, color)
    end

    local bytes = table_to_bytes(sysex)
    local success, err = pcall(function()
        port:write(bytes, #bytes, 0)
    end)

    if not success then
        log("ERROR", "Failed to send SysEx: " .. tostring(err))
        return false
    end

    return true
end

local function refresh_all_leds(port)
    local led_count = 0
    local error_count = 0

    -- Refresh track arm LEDs (row 1)
    local tracks_list = Session:get_tracks()
    local track_idx = 1

    for track in tracks_list:iter() do
        if track_idx > 8 then
            break
        end

        local rec_ctrl = track:rec_enable_control()
        local mute_ctrl = track:mute_control()
        local solo_ctrl = track:solo_control()

        local rec_enabled = rec_ctrl:get_value() > 0
        local muted = mute_ctrl:muted()
        local soloed = solo_ctrl:soloed()
        local is_recording = rec_enabled and Session:transport_rolling() and Session:actively_recording()

        local color, pulse = get_track_led_color(rec_enabled, muted, soloed, is_recording)

        if update_led(port, CONFIG.grid.row1[track_idx], color, pulse) then
            led_count = led_count + 1
        else
            error_count = error_count + 1
        end

        -- Small delay to avoid overwhelming USB MIDI
        ARDOUR.LuaAPI.usleep(2000) -- 2ms between messages

        track_idx = track_idx + 1
    end

    -- Turn off unused track slots
    for i = track_idx, 8 do
        if update_led(port, CONFIG.grid.row1[i], CONFIG.colors.off, false) then
            led_count = led_count + 1
        else
            error_count = error_count + 1
        end
        ARDOUR.LuaAPI.usleep(2000)
    end

    -- Clear other rows (mute/solo rows - not yet implemented in main script)
    for _, row in ipairs({ CONFIG.grid.row2, CONFIG.grid.row3 }) do
        for _, note in ipairs(row) do
            if update_led(port, note, CONFIG.colors.off, false) then
                led_count = led_count + 1
            else
                error_count = error_count + 1
            end
            ARDOUR.LuaAPI.usleep(2000)
        end
    end

    -- Update top row transport LEDs
    local transport_playing = Session:transport_rolling()
    local transport_recording = Session:actively_recording()
    local loop_enabled = Session:get_play_loop()

    -- Play button (104)
    local play_color = transport_playing and CONFIG.colors.green or CONFIG.colors.off
    update_led(port, CONFIG.grid.top_row[1], play_color, false)
    ARDOUR.LuaAPI.usleep(2000)

    -- Stop button (105) - always off (button press stops)
    update_led(port, CONFIG.grid.top_row[2], CONFIG.colors.off, false)
    ARDOUR.LuaAPI.usleep(2000)

    -- Rec button (106)
    local rec_color = transport_recording and CONFIG.colors.red or CONFIG.colors.off
    update_led(port, CONFIG.grid.top_row[3], rec_color, false)
    ARDOUR.LuaAPI.usleep(2000)

    -- Loop button (107)
    local loop_color = loop_enabled and CONFIG.colors.yellow or CONFIG.colors.off
    update_led(port, CONFIG.grid.top_row[4], loop_color, false)
    ARDOUR.LuaAPI.usleep(2000)

    -- Clear remaining top row buttons
    for i = 5, 8 do
        update_led(port, CONFIG.grid.top_row[i], CONFIG.colors.off, false)
        ARDOUR.LuaAPI.usleep(2000)
        led_count = led_count + 1
    end

    -- Clear scene buttons
    for _, note in ipairs(CONFIG.grid.scene) do
        update_led(port, note, CONFIG.colors.off, false)
        ARDOUR.LuaAPI.usleep(2000)
        led_count = led_count + 1
    end

    return led_count, error_count
end

-- ============================================================================
-- MAIN FUNCTION
-- ============================================================================

function factory()
    return function()
        log("INFO", "Starting full LED refresh...")

        -- Find Launchpad port
        local port, name = find_launchpad_port()
        if not port then
            log("ERROR", "Launchpad Mk2 not found. Please connect the device and try again.")
            return
        end

        log("INFO", "Using port: " .. name)

        -- Refresh all LEDs
        local led_count, error_count = refresh_all_leds(port)

        if error_count > 0 then
            log(
                "WARN",
                string.format("Refresh completed with errors: %d LEDs updated, %d errors", led_count, error_count)
            )
        else
            log("INFO", string.format("Refresh completed successfully: %d LEDs updated", led_count))
        end
    end
end
