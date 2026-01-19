ardour {
    ["type"]    = "EditorAction",
    name        = "Test Cue API Availability",
    description = "Explores Ardour Lua API for cue/trigger grid access. Run from Window → Scripting → Action Scripts."
}

function factory()
    return function()
        print("\n=== ARDOUR CUE API EXPLORATION ===\n")
        
        -- Test 1: Session-level cue accessors
        print("--- Test 1: Session Methods ---")
        local session_methods = {
            "cue_grid",
            "get_cue",
            "trigger_grid",
            "triggerbox_count",
            "get_triggerbox",
            "cue_count"
        }
        
        for _, method in ipairs(session_methods) do
            local func = Session[method]
            if func then
                print(string.format("✓ Session:%s exists (type: %s)", method, type(func)))
            else
                print(string.format("✗ Session:%s NOT FOUND", method))
            end
        end
        
        -- Test 2: RouteList for triggerbox access
        print("\n--- Test 2: Track-Level Triggerbox ---")
        local routes = Session:get_routes()
        if routes:size() > 0 then
            local track = routes:front()
            print(string.format("Testing with track: %s", track:name()))
            
            local track_methods = {
                "triggerbox",
                "get_triggerbox",
                "cue_slot"
            }
            
            for _, method in ipairs(track_methods) do
                local func = track[method]
                if func then
                    print(string.format("  ✓ Route:%s exists (type: %s)", method, type(func)))
                    
                    -- Try calling if function
                    if type(func) == "function" then
                        local success, result = pcall(func, track)
                        if success and result then
                            print(string.format("    → Returns: %s", type(result)))
                        end
                    end
                else
                    print(string.format("  ✗ Route:%s NOT FOUND", method))
                end
            end
        else
            print("  ✗ No tracks in session")
        end
        
        -- Test 3: Search metatable for "cue" or "trigger" keywords
        print("\n--- Test 3: Keyword Search in Session Metatable ---")
        local session_meta = getmetatable(Session)
        if session_meta and session_meta.__index then
            local found = {}
            for key, value in pairs(session_meta.__index) do
                if string.match(string.lower(key), "cue") or 
                   string.match(string.lower(key), "trigger") then
                    table.insert(found, {key = key, type = type(value)})
                end
            end
            
            if #found > 0 then
                table.sort(found, function(a, b) return a.key < b.key end)
                for _, item in ipairs(found) do
                    print(string.format("  %s: %s", item.key, item.type))
                end
            else
                print("  No matches found")
            end
        else
            print("  Could not access Session metatable")
        end
        
        -- Test 4: Try calling suspected API
        print("\n--- Test 4: Attempting API Calls ---")
        
        -- Try triggerbox access
        if routes and routes:size() > 0 then
            local track = routes:front()
            if track.triggerbox then
                local success, tb = pcall(track.triggerbox, track)
                if success and tb then
                    print(string.format("  ✓ Got TriggerBox from %s", track:name()))
                    print(string.format("    Type: %s", type(tb)))
                    
                    -- Try to get slot count
                    if tb.slot_count then
                        local success2, count = pcall(tb.slot_count, tb)
                        if success2 then
                            print(string.format("    Slot count: %d", count or 0))
                        end
                    end
                else
                    print("  ✗ triggerbox() call failed")
                end
            else
                print("  ✗ No triggerbox method on Route")
            end
        end
        
        -- Test 5: Check for TriggerBox class in global scope
        print("\n--- Test 5: Global Classes ---")
        local classes = {"TriggerBox", "Trigger", "CueGrid", "CueSlot"}
        for _, class in ipairs(classes) do
            if _G[class] then
                print(string.format("  ✓ %s class exists", class))
            else
                print(string.format("  ✗ %s class NOT FOUND", class))
            end
        end
        
        print("\n=== END CUE API EXPLORATION ===\n")
        print("Check Ardour log (Window → Log) for additional debug output")
    end
end
