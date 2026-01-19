-- Luacheck configuration for Ardour Lua scripts
-- Defines globals provided by Ardour's Lua environment

std = "lua53"

-- Ardour-provided globals
globals = {
    -- Ardour core API
    "ARDOUR",
    "Session",
    "Editor",

    -- LuaSignal for EditorHook scripts
    "LuaSignal",

    -- MIDI I/O for DSP scripts
    "midiout",
    "midiin",

    -- Common Lua bindings
    "PBD",
    "Evoral",
    "Temporal",
    "ArdourUI",

    -- Control types
    "AutomationControl",
    "MuteControl",
    "SoloControl",

    -- Route/Track types
    "Route",
    "Track",
    "MidiTrack",
    "AudioTrack",

    -- Location/Marker API
    "Location",
    "Locations",
}

-- Read-only globals (shouldn't be modified)
read_globals = {
    "ardour",  -- Script metadata table
}

-- Allow setting these globals (required by Ardour)
globals = {
    "signals",  -- EditorHook signal subscription function
    "factory",  -- Script factory function
    "sess_params",  -- Session script parameters function
    "dsp_ioconfig", -- DSP script I/O configuration
    "dsp_init",  -- DSP script initialization
    "dsp_run",  -- DSP script run function
}

-- Ignore specific warnings
ignore = {
    "212",  -- Unused argument (common in callback signatures)
    "631",  -- Line contains only whitespace (stylistic preference)
}

-- Maximum line length
max_line_length = 120

-- Code complexity limits
max_cyclomatic_complexity = 15
