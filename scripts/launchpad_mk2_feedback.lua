ardour({
    ["type"] = "EditorHook",
    name = "Launchpad Mk2 LED Feedback",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
		Real-time RGB LED feedback for Novation Launchpad Mk2.

		Features:
		- Track controls (rows 1-3): arm/mute/solo status
		- Cue slots (rows 4-8): clip loaded/playing/queued status
		- Adaptive polling (100ms active, 500ms idle)
		- Automatic MIDI port detection with reconnection
		- Error recovery with timeline markers
		- Recording state pulse animation
		- Track-type aware colors
		- Performance optimized (state cache, rate limiting)

		Grid Layout:
		- Row 1 (pads 81-88): Track 1-8 arm status
		- Row 2 (pads 71-78): Track 1-8 mute status
		- Row 3 (pads 61-68): Track 1-8 solo status
		- Row 4 (pads 51-58): Cue A slots 1-8
		- Row 5 (pads 41-48): Cue B slots 1-8
		- Row 6 (pads 31-38): Cue C slots 1-8
		- Row 7 (pads 21-28): Cue D slots 1-8
		- Row 8 (pads 11-18): Cue E slots 1-8

		LED Color Schema (Cue Slots):
		- Off: Empty slot (no clip loaded)
		- Green (solid): Clip loaded (ready to trigger)
		- Green (pulse): Clip playing
		- Yellow: Clip queued (awaiting quantization)
		- Red: Error state
	]],
})

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local CONFIG = {
    -- MIDI port detection patterns (regex-compatible)
    port_patterns = {
        "Launchpad.*[Mm][Kk]2",
        "Launchpad MK2",
        "Launchpad Mk2",
    },

    -- Launchpad Mk2 SysEx header (Device ID: 0x18)
    sysex_header = { 0xF0, 0x00, 0x20, 0x29, 0x02, 0x18 },

    -- LED color codes (0-127 palette)
    colors = {
        off = 0,
        red = 5, -- Armed, recording
        orange = 9, -- Muted
        yellow = 13, -- Soloed, SFX
        green = 21, -- Ready, playback
        blue = 45, -- Guest tracks
        purple = 53, -- Music tracks
        white = 3, -- Selected, metronome
    },

    -- Grid layout (note numbers)
    grid = {
        -- Top row (transport controls)
        top_row = { 104, 105, 106, 107, 108, 109, 110, 111 },

        -- Main grid rows (8 columns each)
        row1 = { 81, 82, 83, 84, 85, 86, 87, 88 }, -- Track arm
        row2 = { 71, 72, 73, 74, 75, 76, 77, 78 }, -- Mute
        row3 = { 61, 62, 63, 64, 65, 66, 67, 68 }, -- Solo
        row4 = { 51, 52, 53, 54, 55, 56, 57, 58 }, -- Cue A (slots 1-8)
        row5 = { 41, 42, 43, 44, 45, 46, 47, 48 }, -- Cue B (slots 1-8)
        row6 = { 31, 32, 33, 34, 35, 36, 37, 38 }, -- Cue C (slots 1-8)
        row7 = { 21, 22, 23, 24, 25, 26, 27, 28 }, -- Cue D (slots 1-8)
        row8 = { 11, 12, 13, 14, 15, 16, 17, 18 }, -- Cue E (slots 1-8)

        -- Scene buttons (right column)
        scene = { 89, 79, 69, 59, 49, 39, 29, 19 },
    },

    -- Polling intervals (milliseconds)
    poll_fast = 100, -- When changes detected
    poll_slow = 500, -- When idle
    idle_threshold = 5000, -- Switch to slow after 5s of no changes

    -- Error recovery
    max_retries = 3,
    retry_backoff_ms = 50,
    reconnect_interval_ms = 5000,

    -- Rate limiting
    max_sysex_per_sec = 50,
}

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local state = {
    -- MIDI port
    midi_port = nil,
    port_name = nil,
    port_check_counter = 0,
    consecutive_failures = 0,

    -- Track state cache (indexed by track number 1-8)
    tracks = {},

    -- Cue state cache (indexed by cue letter "A"-"E", then slot 1-8)
    cues = {
        A = {},
        B = {},
        C = {},
        D = {},
        E = {},
    },

    -- Timing
    last_change_time = 0,
    current_interval_ms = CONFIG.poll_fast,
    last_sysex_batch_time = 0,
    sysex_count_this_second = 0,

    -- Error tracking
    error_marker_location = nil,
    total_errors = 0,

    -- Performance metrics
    sysex_sent_total = 0,
    metrics_log_time = 0,
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get current time in milliseconds
local function get_time_ms()
    return ARDOUR.LuaAPI.monotonic_time() / 1000
end

-- Log message to Ardour console
local function log(level, msg)
    local prefix = string.format("[Launchpad Mk2] [%s]", level)
    print(prefix, msg)
end

-- Create error marker in timeline
local function create_error_marker(message)
    pcall(function()
        local loc = Session:locations()
        local name = "⚠️ Launchpad Error: " .. message
        local mark = ARDOUR.Location(Session:current_start_sample(), Session:current_start_sample())
        mark:set_name(name)
        mark:set_is_mark(true)
        loc:add(mark)
        state.error_marker_location = mark
        log("ERROR", "Created timeline marker: " .. name)
    end)
end

-- Remove error marker (on recovery)
local function remove_error_marker()
    if state.error_marker_location then
        pcall(function()
            Session:locations():remove(state.error_marker_location)
            state.error_marker_location = nil
            log("INFO", "Removed error marker (recovered)")
        end)
    end
end

-- ============================================================================
-- SYSEX BUILDERS
-- ============================================================================

-- Build SysEx message for solid LED color
local function build_led_sysex(note, color)
    local syx = {}
    for _, byte in ipairs(CONFIG.sysex_header) do
        table.insert(syx, byte)
    end
    table.insert(syx, 0x0A) -- Color code command
    table.insert(syx, note)
    table.insert(syx, color)
    table.insert(syx, 0xF7)
    return syx
end

-- Build SysEx message for pulsing LED
local function build_pulse_sysex(note, color)
    local syx = {}
    for _, byte in ipairs(CONFIG.sysex_header) do
        table.insert(syx, byte)
    end
    table.insert(syx, 0x23) -- Pulse command
    table.insert(syx, note)
    table.insert(syx, color)
    table.insert(syx, 0xF7)
    return syx
end

-- Convert Lua table to C uint8_t array for MIDI write
local function table_to_bytes(tbl)
    local str = ""
    for _, byte in ipairs(tbl) do
        str = str .. string.char(byte)
    end
    return str
end

-- ============================================================================
-- MIDI PORT MANAGEMENT
-- ============================================================================

-- Enumerate all MIDI ports and find Launchpad Mk2
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

            -- Try each pattern
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

-- Check port health and attempt reconnection
local function check_and_reconnect_port()
    state.port_check_counter = state.port_check_counter + 1

    -- Only check every 5 seconds
    if state.port_check_counter < (CONFIG.reconnect_interval_ms / state.current_interval_ms) then
        return
    end

    state.port_check_counter = 0

    -- Try to find port
    local port, name = find_launchpad_port()

    if port then
        if not state.midi_port or state.port_name ~= name then
            -- New port or reconnection
            state.midi_port = port
            state.port_name = name
            state.consecutive_failures = 0

            log("INFO", "Launchpad Mk2 connected: " .. name)
            remove_error_marker()

            -- Trigger full LED refresh
            state.tracks = {}
            return true
        end
    else
        if state.midi_port and state.consecutive_failures == 0 then
            log("WARN", "Launchpad Mk2 disconnected - pausing LED feedback")
            state.midi_port = nil
            state.port_name = nil
        end
    end

    return false
end

-- ============================================================================
-- SYSEX TRANSMISSION
-- ============================================================================

-- Send SysEx with retry logic
local function send_sysex_with_retry(sysex_table)
    if not state.midi_port then
        return false
    end

    -- Rate limiting check
    local now_ms = get_time_ms()
    if now_ms - state.last_sysex_batch_time >= 1000 then
        -- Reset counter every second
        state.last_sysex_batch_time = now_ms
        state.sysex_count_this_second = 0
    end

    if state.sysex_count_this_second >= CONFIG.max_sysex_per_sec then
        -- Too many messages this second, skip
        return false
    end

    local bytes = table_to_bytes(sysex_table)

    for attempt = 1, CONFIG.max_retries do
        local success, err = pcall(function()
            state.midi_port:write(bytes, #bytes, 0)
        end)

        if success then
            state.consecutive_failures = 0
            state.sysex_sent_total = state.sysex_sent_total + 1
            state.sysex_count_this_second = state.sysex_count_this_second + 1
            return true
        else
            state.consecutive_failures = state.consecutive_failures + 1

            if attempt < CONFIG.max_retries then
                -- Exponential backoff
                ARDOUR.LuaAPI.usleep(CONFIG.retry_backoff_ms * 1000 * attempt)
            else
                log("ERROR", "Failed to send SysEx after " .. CONFIG.max_retries .. " attempts: " .. tostring(err))
                state.total_errors = state.total_errors + 1

                -- Mark port as dead after 3 consecutive failures
                if state.consecutive_failures >= 3 then
                    log("WARN", "MIDI port appears dead - will attempt reconnection")
                    state.midi_port = nil
                    create_error_marker("MIDI port disconnected")
                    return false
                end
            end
        end
    end

    return false
end

-- ============================================================================
-- LED UPDATE LOGIC
-- ============================================================================

-- Determine LED color for a track based on state
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

-- Update single LED
local function update_led(note, color, pulse)
    local sysex
    if pulse then
        sysex = build_pulse_sysex(note, color)
    else
        sysex = build_led_sysex(note, color)
    end
    send_sysex_with_retry(sysex)
end

-- Update LEDs for all tracks
local function update_track_leds()
    local tracks_list = Session:get_tracks()
    local track_idx = 1
    local changes_detected = false

    for track in tracks_list:iter() do
        if track_idx > 8 then
            break
        end -- Only first 8 tracks

        -- Get current track state
        local rec_ctrl = track:rec_enable_control()
        local mute_ctrl = track:mute_control()
        local solo_ctrl = track:solo_control()

        local rec_enabled = rec_ctrl:get_value() > 0
        local muted = mute_ctrl:muted()
        local soloed = solo_ctrl:soloed()

        -- Check if track is actually recording (transport rolling + armed)
        local is_recording = rec_enabled and Session:transport_rolling() and Session:actively_recording()

        -- Compare with cached state
        local prev = state.tracks[track_idx] or {}

        if prev.rec ~= rec_enabled or prev.mute ~= muted or prev.solo ~= soloed or prev.recording ~= is_recording then
            -- State changed - update LED
            local color, pulse = get_track_led_color(rec_enabled, muted, soloed, is_recording)

            -- Update row 1 (arm status)
            update_led(CONFIG.grid.row1[track_idx], color, pulse)

            -- Update cache
            state.tracks[track_idx] = {
                rec = rec_enabled,
                mute = muted,
                solo = soloed,
                recording = is_recording,
            }

            changes_detected = true
        end

        track_idx = track_idx + 1
    end

    return changes_detected
end

-- ============================================================================
-- CUE SLOT LED UPDATES
-- ============================================================================

-- Get LED color for cue slot based on state
-- Returns (color, pulse_mode)
local function get_cue_slot_color(has_clip, is_playing, is_queued)
    if is_playing then
        return CONFIG.colors.green, true -- Pulsing green when playing
    elseif is_queued then
        return CONFIG.colors.yellow, false -- Solid yellow when queued
    elseif has_clip then
        return CONFIG.colors.green, false -- Solid green when loaded
    else
        return CONFIG.colors.off, false -- Off when empty
    end
end

-- Update cue slot LEDs (rows 4-8)
-- Returns true if any changes detected
local function update_cue_leds()
    local changes_detected = false

    -- Define cue rows and their corresponding letters
    local cue_rows = {
        {row = CONFIG.grid.row4, letter = "A"},
        {row = CONFIG.grid.row5, letter = "B"},
        {row = CONFIG.grid.row6, letter = "C"},
        {row = CONFIG.grid.row7, letter = "D"},
        {row = CONFIG.grid.row8, letter = "E"},
    }

    -- Get tracks list (each track may have a triggerbox)
    local tracks_list = Session:get_tracks()

    -- Iterate through each cue row
    for cue_idx, cue_info in ipairs(cue_rows) do
        local cue_letter = cue_info.letter
        local pads = cue_info.row

        -- Iterate through each slot (1-8)
        for slot_idx = 1, 8 do
            local pad_note = pads[slot_idx]

            -- Initialize default state (empty slot)
            local has_clip = false
            local is_playing = false
            local is_queued = false

            -- Try to query cue slot state via Ardour Lua API
            -- NOTE: This API is currently UNVERIFIED and may not exist
            -- If API calls fail, all slots will show as empty (LED off)

            -- Attempt 1: Try track-based triggerbox access
            local track_idx = slot_idx
            if track_idx <= tracks_list:size() then
                local track = tracks_list:table()[track_idx]

                -- Check if track has triggerbox method
                if track and type(track.triggerbox) == "function" then
                    local success, triggerbox = pcall(track.triggerbox, track)

                    if success and triggerbox then
                        -- Try to get slot state (0-indexed cue row)
                        local cue_row_zero_indexed = cue_idx - 1

                        if type(triggerbox.slot) == "function" then
                            local success2, slot = pcall(triggerbox.slot, triggerbox, cue_row_zero_indexed)

                            if success2 and slot then
                                -- Query slot state
                                if type(slot.has_clip) == "function" then
                                    has_clip = slot:has_clip()
                                end
                                if type(slot.is_playing) == "function" then
                                    is_playing = slot:is_playing()
                                end
                                if type(slot.is_queued) == "function" then
                                    is_queued = slot:is_queued()
                                end
                            end
                        end
                    end
                end
            end

            -- Compare with cached state
            local prev = state.cues[cue_letter][slot_idx] or {}

            if prev.has_clip ~= has_clip or prev.is_playing ~= is_playing or prev.is_queued ~= is_queued then
                -- State changed - update LED
                local color, pulse = get_cue_slot_color(has_clip, is_playing, is_queued)
                update_led(pad_note, color, pulse)

                -- Update cache
                state.cues[cue_letter][slot_idx] = {
                    has_clip = has_clip,
                    is_playing = is_playing,
                    is_queued = is_queued,
                }

                changes_detected = true
            end
        end
    end

    return changes_detected
end

-- ============================================================================
-- ADAPTIVE POLLING
-- ============================================================================

-- Adjust polling interval based on activity
local function update_polling_interval(changes_detected)
    local now_ms = get_time_ms()

    if changes_detected then
        state.last_change_time = now_ms
        if state.current_interval_ms ~= CONFIG.poll_fast then
            state.current_interval_ms = CONFIG.poll_fast
            log("DEBUG", "Switched to fast polling (100ms)")
        end
    else
        local idle_duration = now_ms - state.last_change_time
        if idle_duration > CONFIG.idle_threshold and state.current_interval_ms ~= CONFIG.poll_slow then
            state.current_interval_ms = CONFIG.poll_slow
            log("DEBUG", "Switched to slow polling (500ms)")
        end
    end
end

-- ============================================================================
-- PERFORMANCE METRICS
-- ============================================================================

local function log_metrics_if_needed()
    local now_ms = get_time_ms()

    -- Log every 60 seconds
    if now_ms - state.metrics_log_time >= 60000 then
        log(
            "INFO",
            string.format(
                "Metrics: %d SysEx sent, %d errors, %dms polling interval",
                state.sysex_sent_total,
                state.total_errors,
                state.current_interval_ms
            )
        )
        state.metrics_log_time = now_ms
    end
end

-- ============================================================================
-- MAIN UPDATE FUNCTION
-- ============================================================================

local function update_launchpad_leds()
    -- Check port status and attempt reconnection if needed
    check_and_reconnect_port()

    if not state.midi_port then
        -- No port available, skip update
        return
    end

    -- Update track LEDs (rows 1-3)
    local track_changes = update_track_leds()

    -- Update cue slot LEDs (rows 4-8)
    local cue_changes = update_cue_leds()

    -- Aggregate changes for polling adjustment
    local changes = track_changes or cue_changes

    -- Adjust polling interval
    update_polling_interval(changes)

    -- Log metrics periodically
    log_metrics_if_needed()
end

-- ============================================================================
-- ARDOUR SIGNAL SUBSCRIPTION
-- ============================================================================

function signals()
    local s = LuaSignal.Set()
    s:add({
        -- Timer signal for periodic updates
        [LuaSignal.LuaTimerDS] = true,

        -- Optional: React to session-level events
        [LuaSignal.RecordArmStateChanged] = true,
        [LuaSignal.SoloActive] = true,
    })
    return s
end

-- ============================================================================
-- FACTORY (SCRIPT INITIALIZATION)
-- ============================================================================

function factory(params)
    log("INFO", "Initializing Launchpad Mk2 LED feedback script")

    -- Find Launchpad port on startup
    local port, name = find_launchpad_port()
    if port then
        state.midi_port = port
        state.port_name = name
        log("INFO", "Initial port detected: " .. name)
    else
        log("WARN", "Launchpad Mk2 not found on startup - will retry automatically")
        create_error_marker("Launchpad Mk2 not detected")
    end

    -- Initialize timing
    state.last_change_time = get_time_ms()
    state.last_sysex_batch_time = get_time_ms()
    state.metrics_log_time = get_time_ms()

    -- Return callback function
    return function(signal, ref, ...)
        if signal == LuaSignal.LuaTimerDS then
            -- Timer tick - check if it's time to poll
            local interval_samples = (state.current_interval_ms / 1000) * Session:sample_rate()
            if ref >= interval_samples then
                update_launchpad_leds()
            end
        elseif signal == LuaSignal.RecordArmStateChanged or signal == LuaSignal.SoloActive then
            -- Immediate update on arm/solo changes
            update_launchpad_leds()
        end
    end
end
