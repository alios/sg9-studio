# LV2 Plugin Presets & State Storage Research

**Date:** 2025-01-21  
**Status:** Complete  
**Confidence:** High (based on official LV2 specification + real-world examples)

---

## Executive Summary

LV2 plugin presets and state are stored in **Turtle (.ttl) files**, not XML. Ardour session XML contains only a *reference* (`state-dir="stateN"`) to external `state.ttl` files. This research documents the exact format, structure, and RDF relationships used for LV2 preset/state storage.

---

## Research Questions Answered

### 1. The LV2 Preset Format - `.ttl` or XML?

**Answer: Turtle (.ttl) files using RDF**

LV2 presets are stored in Turtle (Terse RDF Triple Language) format. This is a text-based RDF serialization using the `.ttl` extension.

**Key characteristics:**
- Human-readable text format
- Uses RDF namespace prefixes for extensibility
- Can store both simple port values AND complex plugin state
- Organized as "preset bundles" in `.lv2` directories

---

### 2. How Ardour Stores LV2 Plugin State in Session XML

**Answer: Ardour session XML stores references to external `state.ttl` files**

Ardour's session file (`.ardour`) contains inline XML for basic plugin parameters, but **LV2-specific state** is stored externally:

```xml
<Processor id="1234" type="lv2" name="LSP Compressor">
  <lv2 state-dir="state3"/>
  <!-- Basic parameters stored inline -->
</Processor>
```

**Filesystem structure within Ardour session:**
```
MySession/
├── MySession.ardour          # Session XML (references state dirs)
└── plugins/
    ├── 14245/                # Plugin instance ID
    │   ├── state0/state.ttl  # Initial state
    │   ├── state1/state.ttl  # After first save
    │   └── state3/state.ttl  # Current state (versioned)
    └── 608195/
        └── state2/state.ttl
```

**Versioning:** Ardour increments state directories (`state0`, `state1`, `state2`...) on each save, using the `state-dir` attribute to reference the current version.

**Source:** Ardour `lv2_plugin.cc` - `set_state()` loads via `lilv_state_new_from_file()`, `add_state()` saves via `lilv_state_save()`.

---

### 3. Structure of `state.ttl` Files

**Minimal state.ttl structure:**

```turtle
@prefix atom:  <http://lv2plug.in/ns/ext/atom#> .
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix state: <http://lv2plug.in/ns/ext/state#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .

<>
    a pset:Preset ;
    lv2:appliesTo <http://plugin.uri/here> ;
    state:state [
        <http://plugin.uri#custom-key> "custom value"^^xsd:string
    ] .
```

**Real-world example (Yoshimi synth in Ardour):**

```turtle
@prefix state: <http://lv2plug.in/ns/ext/state#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .

<>
    a pset:Preset ;
    lv2:appliesTo <http://yoshimi.sourceforge.net/lv2_plugin> ;
    state:state [
        <http://yoshimi.sourceforge.net/lv2_plugin#state> """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Yoshimi-data>
<Yoshimi-data>
  <MASTER>
    <par name="volume" value="90"/>
    <!-- Plugin-specific XML embedded as string -->
  </MASTER>
</Yoshimi-data>
"""
    ] .
```

**Key observation:** Complex plugins (like synths) often embed their own serialization format (XML, JSON, binary base64) as a string literal within the RDF `state:state` property.

---

### 4. Creating Preset `.ttl` Files for Common Plugins

#### **Pattern 1: Port-Only Presets (Simple DSP Plugins)**

For plugins that store all state in control ports (LSP compressors, EQs, etc.):

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .

<http://example.org/presets/MyCompressorPreset>
    a pset:Preset ;
    rdfs:label "Broadcast Voice" ;
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/compressor_stereo> ;
    lv2:port [
        lv2:symbol "attack" ;
        pset:value 10.0     # Attack time in ms
    ] , [
        lv2:symbol "release" ;
        pset:value 100.0    # Release time in ms
    ] , [
        lv2:symbol "ratio" ;
        pset:value 4.0      # Compression ratio
    ] , [
        lv2:symbol "threshold" ;
        pset:value -18.0    # Threshold in dBFS
    ] , [
        lv2:symbol "makeup" ;
        pset:value 6.0      # Makeup gain in dB
    ] .
```

#### **Pattern 2: State + Ports (Plugins with Internal State)**

For plugins with both control ports and internal state:

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix state: <http://lv2plug.in/ns/ext/state#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .

<http://example.org/presets/MidiMapPreset>
    a pset:Preset ;
    rdfs:label "LaunchPad Row Tuned by Third" ;
    lv2:appliesTo <http://gareus.org/oss/lv2/midimap> ;
    state:state [
        <http://gareus.org/oss/lv2/midimap#state> """midimap v1
match-all
forward-unmatched

NOTE 11 ANY | CHN1 36 SAME
NOTE 12 ANY | CHN1 37 SAME
"""
    ] .
```

#### **Pattern 3: BChoppr Example (Complete Preset with Many Ports)**

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix state: <http://lv2plug.in/ns/ext/state#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .

<https://www.jahnichen.de/plugins/lv2/BChoppr#Jittery_Jim>
    a pset:Preset ;
    lv2:appliesTo <https://www.jahnichen.de/plugins/lv2/BChoppr> ;
    rdfs:label "Jittery Jim" ;
    lv2:port [
        lv2:symbol "amp_swing" ;
        pset:value 1.0
    ] , [
        lv2:symbol "attack" ;
        pset:value 0.2
    ] , [
        lv2:symbol "blend" ;
        pset:value 1.0
    ] , [
        lv2:symbol "bypass" ;
        pset:value 0.0
    ] , [
        lv2:symbol "dry_wet" ;
        pset:value 1.0
    ] , [
        lv2:symbol "level_01" ;
        pset:value 0.86000001
    ] , [
        lv2:symbol "level_02" ;
        pset:value 0.05
    ] ;
    state:state [
        <https://www.jahnichen.de/plugins/lv2/BChoppr#BSchafflSharedDataNr> "0"^^xsd:int
    ] .
```

#### **Pattern 4: Minimal Preset (MOD Distortion)**

Simplest possible valid preset:

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .

<default-preset>
    a pset:Preset ;
    lv2:appliesTo <http://moddevices.com/plugins/mod-devel/DS1> ;
    lv2:port [
        lv2:symbol "Dist" ;
        pset:value 0.5
    ] , [
        lv2:symbol "Level" ;
        pset:value 0.5
    ] , [
        lv2:symbol "Tone" ;
        pset:value 0.5
    ] .
```

---

### 5. Relationship Between `lv2:Preset`, `state:state`, and `pset:preset`

**Namespace relationships:**

| Prefix | Namespace URI | Purpose |
|--------|--------------|---------|
| `pset:` | `http://lv2plug.in/ns/ext/presets#` | Preset definition (`pset:Preset`, `pset:value`, `pset:bank`) |
| `state:` | `http://lv2plug.in/ns/ext/state#` | Plugin state extension (`state:state`, `state:State`) |
| `lv2:` | `http://lv2plug.in/ns/lv2core#` | Core LV2 (`lv2:appliesTo`, `lv2:port`, `lv2:symbol`) |

**How they relate:**

```turtle
# A preset IS A pset:Preset
<my-preset> a pset:Preset .

# It APPLIES TO a specific plugin
<my-preset> lv2:appliesTo <plugin-uri> .

# It can store PORT VALUES using lv2:port + pset:value
<my-preset> lv2:port [
    lv2:symbol "gain" ;
    pset:value 0.75
] .

# It can ALSO store PLUGIN STATE using state:state
<my-preset> state:state [
    <plugin-uri#custom-property> "value"
] .
```

**Key distinctions:**

1. **`pset:Preset`** - RDF class for presets (always used for `a` type assertion)
2. **`pset:value`** - Property linking port symbol to its value
3. **`pset:bank`** - Optional property for grouping presets
4. **`state:state`** - Property for plugin-specific state (arbitrary key-value pairs)
5. **`lv2:appliesTo`** - Mandatory link to the plugin URI
6. **`lv2:port`** - Container for port/value pairs
7. **`lv2:symbol`** - The port's symbol name (defined in plugin manifest)

---

## Preset Bundle Structure

User presets are typically stored as:

```
~/.lv2/
└── LSP_Compressor_Broadcast_Voice.preset.lv2/
    ├── manifest.ttl     # Bundle manifest
    └── preset.ttl       # Actual preset data
```

**manifest.ttl:**
```turtle
@prefix lv2:  <http://lv2plug.in/ns/lv2core#> .
@prefix pset: <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

<preset.ttl>
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/compressor_stereo> ;
    a pset:Preset ;
    rdfs:seeAlso <preset.ttl> .
```

---

## Key Findings for Nix DSL Integration

1. **Presets are declarative Turtle/RDF** - Maps naturally to Nix attribute sets
2. **Port symbols are strings** - Need plugin manifest to get valid symbols
3. **Values are typed** - Floats, ints, strings with XSD datatypes
4. **State can embed arbitrary formats** - Including XML, JSON, or binary (base64)
5. **Versioned storage** - Ardour uses `stateN/` directories for history

---

## Sources

- LV2 Presets Extension: http://lv2plug.in/ns/ext/presets
- LV2 State Extension: http://lv2plug.in/ns/ext/state  
- Ardour source: `libs/ardour/lv2_plugin.cc`
- Real presets: x42/midimap.lv2, sjaehn/BChoppr, mod-audio/mod-distortion
- Ardour session: lorenzosmusic/I-can-only-miss-you (state.ttl examples)
