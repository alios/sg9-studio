# SG9 Studio — Context-Aware Control Enhancement

**Proposal:** Add visual parameter feedback for nanoKONTROL encoders

## Problem Statement

Professional broadcast consoles (Lawo diamond, DHD Audio SX2) use **touch-sensitive encoders** that display parameter values and context *before* the control is moved. This enables operators to:

1. Verify current parameter value without changing it
2. See what function the encoder currently controls
3. Reduce accidental parameter changes

The Korg nanoKONTROL Studio lacks touch sensors, preventing this workflow.

## Solution: Visual Feedback Layer

### Option 1: Ardour OSC + Tablet Display (Recommended)

**Architecture:**
```
nanoKONTROL encoder movement
    ↓
Ardour Generic MIDI receives CC
    ↓
Ardour OSC broadcasts parameter state
    ↓
Tablet app displays current values
```

**Implementation:**

1. **Enable Ardour OSC:**
   - `Edit → Preferences → Control Surfaces → OSC`
   - Port: 3819 (default)
   - Enable: ☑

2. **Install OSC client on iPad/Android tablet:**
   - **TouchOSC** (commercial, $15): https://hexler.net/touchosc
   - **Control** (free, iOS): https://apps.apple.com/app/control-osc-midi/id1351854084
   - **oscHook** (free, Android): https://play.google.com/store/apps/details?id=com.hollyhook.oscHook

3. **Create custom layout:**
   ```
   ┌─────────────────────────────────────┐
   │ Encoder 1: HPF Freq    90 Hz        │
   │ Encoder 2: Gate Thresh -38 dB       │
   │ Encoder 3: Comp Thresh -18 dB       │
   │ Encoder 4: Comp Ratio  3.5:1        │
   │ Encoder 5: EQ 4kHz     +4 dB        │
   │ Encoder 6: Music Vol   -6 dB        │
   │ Encoder 7: (unused)                 │
   │ Encoder 8: (unused)                 │
   └─────────────────────────────────────┘
   ```

4. **Position tablet:**
   - Mount above nanoKONTROL with tablet arm
   - Within peripheral vision (no head turn needed)
   - Touch-sensitive display allows direct parameter adjustment

**Benefits:**
- Glanceable parameter state
- No hardware modification needed
- Tablet also displays loudness meters, waveforms, etc.

**Limitations:**
- Requires WiFi/Ethernet network
- Adds ~20ms latency for OSC feedback (acceptable for monitoring)
- Additional hardware cost (tablet + mount)

### Option 2: On-Screen Parameter Display (No Additional Hardware)

**Implementation:**

Create Lua EditorAction script: `show_encoder_params.lua`

```lua
-- Triggered by MIDI CC from nanoKONTROL
-- Displays floating window with current encoder values
-- Auto-hides after 3 seconds of no encoder activity

ardour({
    ["type"] = "EditorHook",
    name = "nanoKONTROL Parameter Display",
    description = "Show encoder values in floating window",
})

function factory()
    local encoder_values = {}
    local last_update = 0
    local display_timeout = 3000  -- ms
    
    return function(n_samples)
        local now = ARDOUR.LuaAPI.monotonic_time()
        
        -- Check if encoders moved recently
        if (now - last_update) < display_timeout then
            -- Show floating window with encoder values
            -- (Use Ardour LuaDialog API)
        end
    end
end
```

**Activation:**
- Assign keyboard shortcut: `F10` → Show Encoder Params
- Press when adjusting encoder to see current values

**Benefits:**
- No additional hardware
- Native Ardour integration

**Limitations:**
- Requires keyboard press (not automatic on touch)
- Blocks part of editor window

### Option 3: Hardware Upgrade (Future)

**Replace nanoKONTROL Studio with touch-sensitive controller:**

| Controller | Touch Encoders | Motorized Faders | Cost (approx.) |
|------------|----------------|------------------|----------------|
| **Behringer X-Touch Compact** | ✅ (9 encoders) | ❌ | $300 |
| **Icon QCon Pro X** | ✅ (8 encoders) | ✅ (9 faders) | $800 |
| **Presonus FaderPort 8** | ⚠️ (1 encoder, scribble strip) | ✅ (8 faders) | $500 |

**Recommendation:** Wait until nanoKONTROL Studio fails, then upgrade to **Behringer X-Touch Compact** (best value for touch-sensitive encoders).

## Current Action Plan

**Phase 1 (Immediate, No Cost):**
- Implement Option 2 (Lua script for parameter display)
- Create visual reference card showing encoder→parameter mapping
- Position reference card above nanoKONTROL

**Phase 2 (Low Cost, $50-200):**
- Repurpose old tablet as OSC display
- Mount with flexible arm (e.g., Yellowtec m!ka clone from Amazon)
- Implement Option 1

**Phase 3 (Future, $300+):**
- Replace nanoKONTROL when budget allows
- Upgrade to touch-sensitive controller with scribble strips
