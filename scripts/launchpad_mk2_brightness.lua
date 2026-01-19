ardour({
    ["type"] = "EditorAction",
    name = "Launchpad Mk2: Cycle Brightness",
    author = "SG9 Studio",
    license = "MIT",
    description = [[
		Cycle Launchpad Mk2 global brightness: Dim → Medium → Bright → Dim

		Brightness levels:
		- Dim: 32/127 (~25%)
		- Medium: 64/127 (~50%)
		- Bright: 127/127 (100%)

		Current brightness is stored in session metadata and persists
		across session saves/loads.
	]],
})

-- ============================================================================
-- CONFIGURATION
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

    -- Brightness levels
    brightness = {
        dim = 32, -- ~25%
        medium = 64, -- ~50%
        bright = 127, -- 100%
    },

    -- Brightness cycle order
    brightness_order = { "dim", "medium", "bright" },

    -- Session metadata key
    metadata_key = "launchpad_mk2_brightness",
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function log(level, msg)
    local prefix = string.format("[Launchpad Mk2 Brightness] [%s]", level)
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
-- SESSION METADATA FUNCTIONS
-- ============================================================================

local function get_stored_brightness()
    local session_data = Session:metadata()
    if not session_data then
        return "medium" -- Default if no metadata available
    end

    local stored = session_data:get_value(CONFIG.metadata_key)
    if stored and (stored == "dim" or stored == "medium" or stored == "bright") then
        return stored
    end

    return "medium" -- Default
end

local function store_brightness(level)
    local session_data = Session:metadata()
    if not session_data then
        log("WARN", "Cannot store brightness: session metadata unavailable")
        return
    end

    session_data:set_value(CONFIG.metadata_key, level)
    log("INFO", "Stored brightness level: " .. level)
end

-- ============================================================================
-- BRIGHTNESS CYCLE LOGIC
-- ============================================================================

local function get_next_brightness(current)
    for i, level in ipairs(CONFIG.brightness_order) do
        if level == current then
            local next_idx = (i % #CONFIG.brightness_order) + 1
            return CONFIG.brightness_order[next_idx]
        end
    end
    return "medium" -- Fallback
end

-- ============================================================================
-- SYSEX BUILDER
-- ============================================================================

local function build_brightness_sysex(value)
    local syx = {}
    for _, byte in ipairs(CONFIG.sysex_header) do
        table.insert(syx, byte)
    end
    table.insert(syx, 0x08) -- Brightness command
    table.insert(syx, value)
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
-- MAIN FUNCTION
-- ============================================================================

function factory()
    return function()
        log("INFO", "Cycling brightness...")

        -- Find Launchpad port
        local port, name = find_launchpad_port()
        if not port then
            log("ERROR", "Launchpad Mk2 not found. Please connect the device and try again.")
            return
        end

        log("INFO", "Using port: " .. name)

        -- Get current brightness from session metadata
        local current = get_stored_brightness()
        log("INFO", "Current brightness: " .. current .. " (" .. CONFIG.brightness[current] .. "/127)")

        -- Calculate next brightness
        local next_level = get_next_brightness(current)
        local next_value = CONFIG.brightness[next_level]

        -- Build and send SysEx
        local sysex = build_brightness_sysex(next_value)
        local bytes = table_to_bytes(sysex)

        local success, err = pcall(function()
            port:write(bytes, #bytes, 0)
        end)

        if not success then
            log("ERROR", "Failed to send brightness SysEx: " .. tostring(err))
            return
        end

        -- Store new brightness in session metadata
        store_brightness(next_level)

        log("INFO", string.format("Brightness changed: %s → %s (%d/127)", current, next_level, next_value))

        -- Optionally show visual feedback
        local display_name = next_level:sub(1, 1):upper() .. next_level:sub(2)
        local percentage = math.floor((next_value / 127) * 100)
        log("INFO", string.format("Launchpad Mk2: %s brightness (%d%%)", display_name, percentage))
    end
end
