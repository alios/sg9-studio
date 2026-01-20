# Implementation Plan: Nix DSL for Ardour Session Generation

**Status:** Draft → **Research Complete**  
**Created:** 2026-01-20  
**Updated:** 2026-01-20  
**Agent:** Systems Engineer / AI Engineer

---

## Executive Summary

Build a Nix DSL for declaratively generating Ardour 8.x session files. Python handles XML serialization (xsdata + rdflib); Nix provides the configuration surface. Flake-exportable for external consumers.

**Key Research Findings:**
- ✅ `xsdata` v25.7+ generates dataclasses from raw XML (no schema required)
- ⚠️ `python3Packages.lilv` does NOT exist in nixpkgs — use `rdflib` instead
- ✅ Flowblade's `exportardour.py` (1800+ lines) provides complete reference implementation
- ✅ Ardour 8.x XML uses version `8000+`, monotonic IDs starting at 500

---

## Research Findings

### Ardour Session XML Structure

**No formal DTD/XSD schema** — XML structure defined by code in `libs/ardour/session_state.cc`.

**Root Element:**
```xml
<Session version="8000" uuid="..." name="session_name" sample-rate="48000" id-counter="1234">
```

**Major Child Elements (order matters):**
| Element | Description |
|---------|-------------|
| `<ProgramVersion>` | `created-with` and `modified-with` attributes |
| `<MIDIPorts>` | MIDI port configuration |
| `<Config>` | Session configuration settings |
| `<Metadata>` | Artist, album, copyright |
| `<Sources>` | Audio file references with unique IDs |
| `<Regions>` | Region definitions referencing sources |
| `<Locations>` | Markers, ranges, session bounds |
| `<Bundles>` | I/O bundles |
| `<Routes>` | **All tracks, buses, VCAs with processors** |
| `<Playlists>` | Clip arrangements per track |
| `<RouteGroups>` | Route groupings |
| `<Click>` | Metronome configuration |
| `<LTC-In/Out>` | Timecode I/O |
| `<Speakers>` | Speaker positioning |
| `<TempoMap>` | Tempo and meter data |
| `<VCAManager>` | VCA assignments |
| `<TriggerBindings>` | Cue/clip trigger bindings |

**Route/Track XML Structure:**
```xml
<Route id="123" name="Audio 1" version="8000" default-type="audio" 
       strict-io="1" active="1" meter-point="MeterPostFader">
    <PresentationInfo order="0" flags="AudioTrack,OrderSet"/>
    <IO name="Audio 1" direction="Input" default-type="audio">
        <Port name="Audio 1/audio_in 1" type="audio">
            <Connection other="system:capture_1"/>
        </Port>
    </IO>
    <IO name="Audio 1" direction="Output">...</IO>
    <Processor id="..." name="Amp" type="trim">...</Processor>
    <Processor id="..." name="Amp" type="amp">...</Processor>
    <Processor id="..." type="meter"/>
    <Processor id="..." type="lv2" unique-id="http://plugin.uri">
        <lv2>
            <Port symbol="gain" value="-6.0"/>
        </lv2>
    </Processor>
    <Processor id="..." type="main-outs" role="Main">...</Processor>
    <Diskstream ... playlist="Audio 1.1"/>
</Route>
```

**Processor Types:**
| `type` value | Description |
|--------------|-------------|
| `amp` | Gain/Amp processor |
| `trim` | Trim control |
| `meter` | Metering point |
| `lv2` | LV2 plugin (`unique-id` = plugin URI) |
| `ladspa` | LADSPA plugin |
| `luaproc` | Lua DSP script |
| `send` / `intsend` | Send processor |
| `main-outs` | Main outputs (last in chain) |

### LV2 Plugin State Storage

**Inline (simple plugins):**
```xml
<Processor type="lv2" unique-id="http://lsp-plug.in/plugins/lv2/compressor_stereo">
    <lv2>
        <Port symbol="attack" value="10.0"/>
        <Port symbol="release" value="100.0"/>
        <Port symbol="threshold" value="-18.0"/>
    </lv2>
</Processor>
```

**External state (complex plugins with `state:interface`):**
```xml
<lv2 state-dir="plugins/123/state0">
    <Port symbol="..." value="..."/>
</lv2>
```
State file location: `<session>/plugins/<insert_id>/state<N>/state.ttl`

**LV2 Preset .ttl Format:**
```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix state: <http://lv2plug.in/ns/ext/state#> .

<http://sg9.studio/presets/lsp-compressor-broadcast>
    a pset:Preset ;
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/compressor_stereo> ;
    rdfs:label "SG9 Broadcast Compressor" ;
    lv2:port [
        lv2:symbol "attack" ;
        pset:value 10.0
    ], [
        lv2:symbol "release" ;
        pset:value 100.0
    ], [
        lv2:symbol "threshold" ;
        pset:value -18.0
    ] .
```

### NixOS Package Availability

| Package | nixpkgs Attribute | Version | Status |
|---------|-------------------|---------|--------|
| **xsdata** | `python313Packages.xsdata` | 25.7+ | ✅ Available |
| **lxml** | `python313Packages.lxml` | 6.0.2 | ✅ Available |
| **rdflib** | `python313Packages.rdflib` | 7.5.0 | ✅ Alternative to lilv |
| **lilv** | `pkgs.lilv` | 0.24.26 | ⚠️ **C library only** |
| **libxml2** | `pkgs.libxml2` | — | ✅ For xmllint validation |

**Critical:** `python3Packages.lilv` does NOT exist. Use `rdflib` to parse LV2 `.ttl` presets instead.

### Reference Implementation: Flowblade

**Location:** [jliljebl/flowblade/exportardour.py](https://github.com/jliljebl/flowblade/blob/main/flowblade-trunk/Flowblade/src/tools/exportardour.py)

**Key Patterns:**

1. **Monotonic ID Sequence:**
```python
class Sequence:
    def __init__(self, start=500):
        self.value = start
    def next(self):
        self.value += 1
        return self.value
```

2. **Session Structure Generation:**
```python
def _create_ardour_project_file(basedir, project):
    seq = Sequence(500)  # IDs start at 500
    
    s = []
    s.append(_get_ardour_program_version())
    s.append(_get_ardour_midi_ports())
    s.append(_get_ardour_config(project))
    s.append(_get_ardour_sources(project, seq))
    s.append(_get_ardour_regions(project, seq))
    s.append(_get_ardour_routes(project, seq))
    s.append(_get_ardour_playlists(project, seq))
    # ... remaining sections
    
    # Session open tag includes final id-counter
    f.write(_get_ardour_session_open(name, project, seq.next()))
    f.write(''.join(s))
    f.write('</Session>')
```

3. **Directory Structure:**
```
MySession/
├── MySession.ardour          # Main XML file
├── analysis/
├── dead/
├── export/
├── externals/
├── interchange/
│   └── MySession/
│       ├── audiofiles/       # WAV/FLAC sources
│       └── midifiles/
└── plugins/                  # LV2 state directories
    └── <insert_id>/
        └── state<N>/
            └── state.ttl
```

---

## Prerequisites

- [x] ~~Export existing SG9 session as XML baseline~~ → Use Flowblade patterns instead
- [x] ~~Verify `python3Packages.lilv`~~ → **NOT available**, use `rdflib`
- [x] Review Ardour 8.x session XML structure → **Documented above**
- [ ] Export existing SG9 session to capture track names, routing, plugin chains
- [ ] Document LSP plugin port symbols for presets (use `lv2info`)

## Directory Structure

```
nix/ardour/
├── lib.nix                    # mkSession, mkTrack, mkBus, mkVCA, mkPlugin
├── version.nix                # Semantic version for API stability (0.1.0)
├── presets/                   # LV2 preset .ttl files (Nix-managed)
│   ├── lsp-compressor-broadcast.ttl
│   ├── lsp-gate-voice.ttl
│   ├── lsp-deesser-sc.ttl
│   └── README.md              # Port symbol documentation
├── generator/
│   ├── default.nix            # Python package derivation
│   ├── pyproject.toml
│   └── ardour_session/
│       ├── __init__.py
│       ├── models.py          # xsdata-generated dataclasses (optional)
│       ├── builder.py         # SessionBuilder (Flowblade-style string builder)
│       ├── presets.py         # rdflib-based .ttl preset parser
│       ├── id_sequence.py     # Monotonic ID generator
│       └── cli.py             # JSON stdin → .ardour stdout
└── tests/
    ├── validate.nix           # XML well-formedness + Ardour load test
    └── fixtures/              # Sample JSON configs for testing
nix/sessions/
├── sg9-broadcast.nix          # SG9 session definition using DSL
└── minimal.nix                # Minimal test session
```

## Implementation Steps

### Step 1: Create Nix DSL Library

**File:** `nix/ardour/lib.nix`

```nix
{ lib }:

rec {
  # Plugin with optional preset (.ttl path) or inline parameters
  mkPlugin = { 
    uri,                          # LV2 URI (e.g., "http://lsp-plug.in/plugins/lv2/compressor_stereo")
    preset ? null,                # Path to .ttl preset file
    parameters ? {},              # Inline parameters: { attack = 10.0; release = 100.0; }
    active ? true,                # Processor active state
  }: {
    inherit uri preset parameters active;
    _type = "ardour-plugin";
  };

  # Audio or MIDI track with processor chain
  mkTrack = { 
    name,                         # Display name
    type ? "audio",               # "audio" or "midi"
    input ? null,                 # Input connection (e.g., "system:capture_1")
    output ? "Master",            # Output destination (Route name or "Master")
    plugins ? [],                 # List of mkPlugin
    group ? null,                 # RouteGroup name
    color ? null,                 # RGBA color (e.g., "3030641919")
    recordEnabled ? false,        # Auto-arm on session load
  }: {
    inherit name type input output plugins group color recordEnabled;
    _type = "ardour-track";
  };

  # Bus (summing point) with optional sends
  mkBus = { 
    name,
    inputs ? [],                  # List of Route names to sum
    plugins ? [],
    sends ? [],                   # List of { destination; level; }
  }: {
    inherit name inputs plugins sends;
    _type = "ardour-bus";
  };

  # VCA for grouped fader control
  mkVCA = { 
    name,
    controls ? [],                # List of Route/Track names to control
    color ? null,
  }: {
    inherit name controls color;
    _type = "ardour-vca";
  };

  # Top-level session definition
  mkSession = { 
    name, 
    sampleRate ? 48000,           # Sample rate (default: broadcast standard)
    tracks ? [], 
    buses ? [], 
    vcas ? [],
    routeGroups ? [],             # List of { name; routes; }
    tempo ? 120,
    meterNumerator ? 4,
    meterDenominator ? 4,
    metadata ? {},                # { artist; album; description; }
    monitorSection ? true,        # Include monitor bus
  }: {
    inherit name sampleRate tracks buses vcas routeGroups 
            tempo meterNumerator meterDenominator metadata monitorSection;
    _type = "ardour-session";
  };

  # Serialize session config to JSON for Python generator
  toGeneratorInput = session: builtins.toJSON session;
  
  # Version for API stability
  version = "0.1.0";
}
```

### Step 2: Bootstrap xsdata Models (Optional)

xsdata can generate dataclasses from raw XML, but for Ardour's complex structure, a **string-builder approach** (like Flowblade) is more practical.

**If using xsdata for partial modeling:**
```bash
# From exported Ardour session (provides type hints)
xsdata generate ./SG9-Broadcast.ardour \
  --package ardour_session.models \
  --structure-style single-package \
  --unnest-classes \
  --slots
```

**Recommended approach:** Use xsdata models for validation/parsing only, generate XML via string builder.

### Step 3: Implement Python Generator

**File:** `nix/ardour/generator/ardour_session/id_sequence.py`

```python
"""Monotonic ID generator for Ardour XML elements."""

class IdSequence:
    """Generate unique IDs starting from 500 (IDs < 500 reserved for singletons)."""
    
    def __init__(self, start: int = 500):
        self._value = start
    
    def next(self) -> int:
        self._value += 1
        return self._value
    
    @property
    def current(self) -> int:
        return self._value
```

**File:** `nix/ardour/generator/ardour_session/presets.py`

```python
"""Parse LV2 preset .ttl files using rdflib."""

from pathlib import Path
from typing import Dict, Any
from rdflib import Graph, Namespace, URIRef, Literal

LV2 = Namespace("http://lv2plug.in/ns/lv2core#")
PSET = Namespace("http://lv2plug.in/ns/ext/presets#")

def parse_preset(preset_path: Path) -> Dict[str, Any]:
    """Parse LV2 preset .ttl file, return {symbol: value} dict."""
    g = Graph()
    g.parse(preset_path, format="turtle")
    
    parameters = {}
    
    # Query for port values
    for port in g.subjects(LV2.symbol, None):
        symbol = str(g.value(port, LV2.symbol))
        value = g.value(port, PSET.value)
        if value is not None:
            # Convert RDF literal to Python type
            if isinstance(value, Literal):
                parameters[symbol] = value.toPython()
            else:
                parameters[symbol] = str(value)
    
    return parameters
```

**File:** `nix/ardour/generator/ardour_session/builder.py`

```python
"""Generate Ardour session XML using Flowblade-style string builder."""

import json
from pathlib import Path
from typing import Dict, List, Any, Optional
from xml.sax.saxutils import escape as xml_escape

from .id_sequence import IdSequence
from .presets import parse_preset

class SessionBuilder:
    """Build Ardour session XML from JSON configuration."""
    
    ARDOUR_VERSION = 8000  # Ardour 8.x format
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.seq = IdSequence(500)
        self._route_ids: Dict[str, int] = {}  # name -> id mapping
    
    @classmethod
    def from_json(cls, json_str: str) -> "SessionBuilder":
        return cls(json.loads(json_str))
    
    def build(self) -> str:
        """Generate complete .ardour XML file."""
        parts = []
        
        # Generate body first (to get final id-counter)
        body_parts = [
            self._program_version(),
            self._midi_ports(),
            self._config(),
            self._metadata(),
            self._sources(),  # Empty for template
            self._regions(),  # Empty for template
            self._locations(),
            self._bundles(),
            self._routes(),
            self._playlists(),
            self._route_groups(),
            self._click(),
            self._ltc(),
            self._speakers(),
            self._tempo_map(),
            self._vca_manager(),
            self._extra(),
        ]
        body = "".join(body_parts)
        
        # XML header + session open (with final id-counter)
        parts.append('<?xml version="1.0" encoding="UTF-8"?>\n')
        parts.append(self._session_open())
        parts.append(body)
        parts.append('</Session>\n')
        
        return "".join(parts)
    
    def _session_open(self) -> str:
        name = xml_escape(self.config["name"])
        rate = self.config.get("sampleRate", 48000)
        return (
            f'<Session version="{self.ARDOUR_VERSION}" '
            f'name="{name}" sample-rate="{rate}" '
            f'end-is-free="1" id-counter="{self.seq.current}" '
            f'name-counter="1" event-counter="1" vca-counter="1">\n'
        )
    
    def _program_version(self) -> str:
        return (
            '  <ProgramVersion created-with="SG9 Nix DSL 0.1.0" '
            'modified-with="SG9 Nix DSL 0.1.0"/>\n'
        )
    
    def _routes(self) -> str:
        """Generate Routes section with Master, Monitor, and tracks."""
        parts = ['  <Routes>\n']
        
        # Master bus (always present)
        parts.append(self._master_bus())
        
        # Monitor bus (optional)
        if self.config.get("monitorSection", True):
            parts.append(self._monitor_bus())
        
        # User tracks
        for i, track in enumerate(self.config.get("tracks", [])):
            parts.append(self._track(track, i))
        
        # User buses
        for bus in self.config.get("buses", []):
            parts.append(self._bus(bus))
        
        parts.append('  </Routes>\n')
        return "".join(parts)
    
    def _track(self, track: Dict[str, Any], order: int) -> str:
        """Generate Route XML for audio/midi track."""
        route_id = self.seq.next()
        name = xml_escape(track["name"])
        self._route_ids[track["name"]] = route_id
        
        track_type = track.get("type", "audio")
        flags = "AudioTrack,OrderSet" if track_type == "audio" else "MidiTrack,OrderSet"
        
        parts = [
            f'    <Route id="{route_id}" name="{name}" '
            f'version="{self.ARDOUR_VERSION}" default-type="{track_type}" '
            f'strict-io="1" active="1" meter-point="MeterPostFader">\n',
            f'      <PresentationInfo order="{order}" flags="{flags}"/>\n',
        ]
        
        # Input IO
        parts.append(self._track_input_io(track))
        
        # Output IO
        parts.append(self._track_output_io(track))
        
        # Mute/Solo controllables
        parts.append(self._route_controllables())
        
        # Processors: trim -> amp -> [plugins] -> meter -> main-outs
        parts.append(self._processor_trim())
        parts.append(self._processor_amp())
        
        for plugin in track.get("plugins", []):
            parts.append(self._processor_plugin(plugin))
        
        parts.append(self._processor_meter(name))
        parts.append(self._processor_main_outs(name))
        
        # Diskstream for recording
        playlist_name = f"{name}.1"
        parts.append(
            f'      <Diskstream flags="Recordable" playlist="{xml_escape(playlist_name)}" '
            f'name="{name}" id="{self.seq.next()}" speed="1" channels="2"/>\n'
        )
        
        parts.append('    </Route>\n')
        return "".join(parts)
    
    def _processor_plugin(self, plugin: Dict[str, Any]) -> str:
        """Generate LV2 plugin processor XML."""
        proc_id = self.seq.next()
        uri = xml_escape(plugin["uri"])
        active = "1" if plugin.get("active", True) else "0"
        
        parts = [
            f'      <Processor id="{proc_id}" name="LV2" active="{active}" '
            f'type="lv2" unique-id="{uri}" count="1">\n',
        ]
        
        # Get parameters from preset file or inline
        parameters = {}
        if plugin.get("preset"):
            preset_path = Path(plugin["preset"])
            if preset_path.exists():
                parameters = parse_preset(preset_path)
        parameters.update(plugin.get("parameters", {}))
        
        if parameters:
            parts.append('        <lv2>\n')
            for symbol, value in parameters.items():
                parts.append(f'          <Port symbol="{xml_escape(symbol)}" value="{value}"/>\n')
            parts.append('        </lv2>\n')
        
        parts.append('      </Processor>\n')
        return "".join(parts)
    
    # ... additional helper methods for IO, controllables, master bus, etc.
    # (Full implementation follows Flowblade patterns)
```

**File:** `nix/ardour/generator/ardour_session/cli.py`

```python
#!/usr/bin/env python3
"""CLI: Read JSON config from stdin, write .ardour XML to stdout."""

import sys
import json
from .builder import SessionBuilder

def main():
    try:
        config = json.load(sys.stdin)
        builder = SessionBuilder(config)
        print(builder.build())
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### Step 4: Create Python Package Derivation

**File:** `nix/ardour/generator/pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "ardour-session-generator"
version = "0.1.0"
description = "Generate Ardour session XML from declarative Nix config"
requires-python = ">=3.10"
dependencies = [
    "rdflib>=7.0",
    "lxml>=4.9",
]

[project.scripts]
ardour-session-generator = "ardour_session.cli:main"

[project.optional-dependencies]
dev = ["xsdata[cli]", "pytest", "mypy"]
```

**File:** `nix/ardour/generator/default.nix`

```nix
{ lib
, python3Packages
, lv2  # For plugin URI validation (optional runtime check)
}:

python3Packages.buildPythonApplication {
  pname = "ardour-session-generator";
  version = "0.1.0";
  src = ./.;
  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [
    rdflib     # Parse LV2 .ttl presets
    lxml       # XML generation fallback
    setuptools # Build backend
  ];
  
  nativeCheckInputs = with python3Packages; [
    pytest
  ];
  
  checkPhase = ''
    pytest tests/
  '';

  meta = with lib; {
    description = "Generate Ardour session XML from declarative Nix config";
    homepage = "https://github.com/alios/sg9-studio";
    license = licenses.mit;
    maintainers = [ ];
  };
}
```

### Step 5: Wire Flake Outputs

**File:** `flake.nix` additions

```nix
{
  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      pkgsFor = system: import nixpkgs { inherit system; };
    in {
      # DSL library (pure Nix, system-independent)
      lib.ardour = import ./nix/ardour/lib.nix { inherit (nixpkgs) lib; };

      # Per-system outputs
      packages = forAllSystems (system: let
        pkgs = pkgsFor system;
      in {
        ardour-session-generator = pkgs.callPackage ./nix/ardour/generator {};
        
        # SG9 broadcast template (prebuilt .ardour file)
        sg9-broadcast-template = pkgs.runCommand "SG9-Broadcast.ardour" {
          nativeBuildInputs = [ self.packages.${system}.ardour-session-generator ];
          passAsFile = [ "config" ];
          config = self.lib.ardour.toGeneratorInput (import ./nix/sessions/sg9-broadcast.nix {
            ardour = self.lib.ardour;
            presets = ./nix/ardour/presets;
          });
        } ''
          ardour-session-generator < "$configPath" > $out
        '';
        
        # Full session directory with structure
        sg9-broadcast-session = pkgs.runCommand "SG9-Broadcast" {
          template = self.packages.${system}.sg9-broadcast-template;
        } ''
          mkdir -p $out/SG9-Broadcast/{analysis,dead,export,externals}
          mkdir -p $out/SG9-Broadcast/interchange/SG9-Broadcast/{audiofiles,midifiles}
          mkdir -p $out/SG9-Broadcast/plugins
          cp $template $out/SG9-Broadcast/SG9-Broadcast.ardour
        '';
      });

      # Validation checks
      checks = forAllSystems (system: let
        pkgs = pkgsFor system;
      in {
        # XML well-formedness
        ardour-session-xml-valid = pkgs.runCommand "validate-xml" {
          session = self.packages.${system}.sg9-broadcast-template;
          nativeBuildInputs = [ pkgs.libxml2 ];
        } ''
          xmllint --noout $session
          echo "XML validation passed" > $out
        '';
        
        # Python package tests
        ardour-generator-tests = self.packages.${system}.ardour-session-generator.overrideAttrs (old: {
          doCheck = true;
        });
      });
      
      # Development shell
      devShells = forAllSystems (system: let
        pkgs = pkgsFor system;
      in {
        ardour-dsl = pkgs.mkShell {
          packages = [
            self.packages.${system}.ardour-session-generator
            pkgs.python3Packages.xsdata  # For model generation
            pkgs.libxml2                 # xmllint
            (pkgs.python3.withPackages (ps: [ ps.rdflib ps.lxml ps.pytest ]))
          ];
        };
      });
    };
}
```

### Step 6: Define SG9 Broadcast Session

**File:** `nix/sessions/sg9-broadcast.nix`

```nix
{ ardour, presets }:

ardour.mkSession {
  name = "SG9-Broadcast";
  sampleRate = 48000;
  tempo = 120;
  meterNumerator = 4;
  meterDenominator = 4;
  monitorSection = true;  # Include Monitor bus

  tracks = [
    # === Voice Processing Chain ===
    (ardour.mkTrack {
      name = "Host Mic (DSP)";
      input = "system:capture_1";
      output = "Voice";  # Routes to Voice bus
      color = "3030641919";  # Blue
      plugins = [
        # HPF @ 80Hz (remove rumble)
        (ardour.mkPlugin { 
          uri = "http://lsp-plug.in/plugins/lv2/para_equalizer_x16_stereo";
          parameters = {
            fsel_0 = 0;       # HPF mode
            freq_0 = 80.0;
            gain_0 = 0.0;
          };
        })
        # Gate (reduce background noise)
        (ardour.mkPlugin { 
          uri = "http://lsp-plug.in/plugins/lv2/gate_stereo";
          preset = "${presets}/lsp-gate-voice.ttl";
        })
        # De-esser (sidechain compressor)
        (ardour.mkPlugin { 
          uri = "http://lsp-plug.in/plugins/lv2/sc_compressor_stereo";
          preset = "${presets}/lsp-deesser-sc.ttl";
        })
        # Compressor (broadcast leveling)
        (ardour.mkPlugin { 
          uri = "http://lsp-plug.in/plugins/lv2/compressor_stereo";
          preset = "${presets}/lsp-compressor-broadcast.ttl";
        })
        # Limiter (peak protection)
        (ardour.mkPlugin { 
          uri = "http://lsp-plug.in/plugins/lv2/limiter_stereo";
          parameters = {
            thresh = -1.0;    # -1 dBTP ceiling
            release = 50.0;
          };
        })
      ];
      group = "voice";
    })
    
    # Raw safety track (no processing)
    (ardour.mkTrack {
      name = "Host Mic (Raw)";
      input = "system:capture_1";
      output = "Master";
      plugins = [];  # No processing - emergency recovery
      group = "voice";
    })
    
    # Guest mic (same chain as host)
    (ardour.mkTrack {
      name = "Guest Mic (DSP)";
      input = "system:capture_2";
      output = "Voice";
      color = "3030641919";
      plugins = [
        (ardour.mkPlugin { uri = "http://lsp-plug.in/plugins/lv2/para_equalizer_x16_stereo"; })
        (ardour.mkPlugin { uri = "http://lsp-plug.in/plugins/lv2/gate_stereo"; preset = "${presets}/lsp-gate-voice.ttl"; })
        (ardour.mkPlugin { uri = "http://lsp-plug.in/plugins/lv2/sc_compressor_stereo"; preset = "${presets}/lsp-deesser-sc.ttl"; })
        (ardour.mkPlugin { uri = "http://lsp-plug.in/plugins/lv2/compressor_stereo"; preset = "${presets}/lsp-compressor-broadcast.ttl"; })
        (ardour.mkPlugin { uri = "http://lsp-plug.in/plugins/lv2/limiter_stereo"; parameters = { thresh = -1.0; }; })
      ];
      group = "voice";
    })
    
    (ardour.mkTrack {
      name = "Guest Mic (Raw)";
      input = "system:capture_2";
      output = "Master";
      plugins = [];
      group = "voice";
    })
    
    # Aux input (phone/tablet)
    (ardour.mkTrack {
      name = "Aux Input";
      input = "system:capture_3";
      output = "Master";
      color = "2565912831";  # Orange
      plugins = [];
    })
    
    # Remote guest (VoIP return)
    (ardour.mkTrack {
      name = "Remote Guest";
      type = "audio";
      input = null;  # JACK/PipeWire routing
      output = "Master";
      color = "1927666431";  # Green
      plugins = [];
    })
  ];

  buses = [
    # Voice summing bus
    (ardour.mkBus {
      name = "Voice";
      inputs = [ "Host Mic (DSP)" "Guest Mic (DSP)" ];
      plugins = [];
    })
    
    # VoIP send (mix-minus for remote guests)
    (ardour.mkBus {
      name = "VoIP Send";
      inputs = [ "Voice" "Aux Input" ];  # Excludes Remote Guest (mix-minus)
      sends = [];
      plugins = [];
    })
  ];

  vcas = [
    (ardour.mkVCA {
      name = "All Mics";
      controls = [ "Host Mic (DSP)" "Guest Mic (DSP)" ];
      color = "3030641919";
    })
  ];

  routeGroups = [
    { name = "voice"; routes = [ "Host Mic (DSP)" "Host Mic (Raw)" "Guest Mic (DSP)" "Guest Mic (Raw)" ]; }
  ];

  metadata = {
    artist = "SG9 Studio";
    album = "Broadcast Template";
    description = "Podcast/radio production template with -16 LUFS target";
  };
}
```

### Step 7: Create LV2 Preset Files

**File:** `nix/ardour/presets/lsp-compressor-broadcast.ttl`

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .

<http://sg9.studio/presets/lsp-compressor-broadcast>
    a pset:Preset ;
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/compressor_stereo> ;
    rdfs:label "SG9 Broadcast Compressor" ;
    lv2:port [
        lv2:symbol "at" ;        # Attack time (ms)
        pset:value 10.0
    ], [
        lv2:symbol "rt" ;        # Release time (ms)
        pset:value 100.0
    ], [
        lv2:symbol "th" ;        # Threshold (dB)
        pset:value -18.0
    ], [
        lv2:symbol "cr" ;        # Ratio
        pset:value 4.0
    ], [
        lv2:symbol "kn" ;        # Knee (dB)
        pset:value 6.0
    ], [
        lv2:symbol "mk" ;        # Makeup gain (dB)
        pset:value 6.0
    ] .
```

**File:** `nix/ardour/presets/lsp-gate-voice.ttl`

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .

<http://sg9.studio/presets/lsp-gate-voice>
    a pset:Preset ;
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/gate_stereo> ;
    rdfs:label "SG9 Voice Gate" ;
    lv2:port [
        lv2:symbol "th" ;        # Threshold (dB)
        pset:value -40.0
    ], [
        lv2:symbol "at" ;        # Attack (ms)
        pset:value 5.0
    ], [
        lv2:symbol "rt" ;        # Release (ms)
        pset:value 200.0
    ], [
        lv2:symbol "rng" ;       # Range/reduction (dB)
        pset:value -20.0
    ] .
```

**File:** `nix/ardour/presets/lsp-deesser-sc.ttl`

```turtle
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .

<http://sg9.studio/presets/lsp-deesser-sc>
    a pset:Preset ;
    lv2:appliesTo <http://lsp-plug.in/plugins/lv2/sc_compressor_stereo> ;
    rdfs:label "SG9 De-esser (Sidechain Compressor)" ;
    lv2:port [
        lv2:symbol "th" ;        # Threshold (dB)
        pset:value -30.0
    ], [
        lv2:symbol "cr" ;        # Ratio (high for de-essing)
        pset:value 10.0
    ], [
        lv2:symbol "at" ;        # Attack (fast for sibilance)
        pset:value 0.5
    ], [
        lv2:symbol "rt" ;        # Release
        pset:value 50.0
    ], [
        lv2:symbol "sf" ;        # Sidechain HPF frequency (target sibilance)
        pset:value 5000.0
    ], [
        lv2:symbol "shpf" ;      # Sidechain HPF enable
        pset:value 1.0
    ] .
```

> **Note:** Port symbols must match the actual LSP plugin parameters. Use `lv2info <plugin-uri>` to discover correct symbols.

## Testing Criteria

### Unit Tests (pytest)

```python
# nix/ardour/generator/tests/test_builder.py

import pytest
from ardour_session.builder import SessionBuilder
from ardour_session.presets import parse_preset
from pathlib import Path

class TestSessionBuilder:
    def test_basic_session_generation(self, basic_config):
        """Verify minimal session produces valid XML structure."""
        builder = SessionBuilder(basic_config)
        xml = builder.build()
        
        assert '<?xml version="1.0"' in xml
        assert '<Session version="8000"' in xml
        assert '</Session>' in xml
    
    def test_id_sequence_monotonic(self, basic_config):
        """Verify IDs are monotonically increasing from 500+."""
        builder = SessionBuilder(basic_config)
        xml = builder.build()
        
        # Extract all id= values
        import re
        ids = [int(m) for m in re.findall(r'id="(\d+)"', xml)]
        
        assert all(i >= 500 for i in ids), "IDs must be >= 500"
        assert ids == sorted(ids), "IDs must be monotonically increasing"
    
    def test_track_with_plugins(self, track_with_plugins_config):
        """Verify plugin chain renders correctly."""
        builder = SessionBuilder(track_with_plugins_config)
        xml = builder.build()
        
        assert 'type="lv2"' in xml
        assert 'http://lsp-plug.in/plugins/lv2/compressor_stereo' in xml


class TestPresetParser:
    def test_parse_ttl_preset(self, tmp_path):
        """Verify rdflib can parse LV2 preset .ttl files."""
        preset = tmp_path / "test-preset.ttl"
        preset.write_text('''
@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .
@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .

<test:preset>
    a pset:Preset ;
    lv2:port [ lv2:symbol "th" ; pset:value -18.0 ] .
        ''')
        
        params = parse_preset(preset)
        assert params.get("th") == -18.0


@pytest.fixture
def basic_config():
    return {
        "name": "TestSession",
        "sampleRate": 48000,
        "tracks": [],
        "buses": [],
    }

@pytest.fixture
def track_with_plugins_config():
    return {
        "name": "TestSession",
        "sampleRate": 48000,
        "tracks": [{
            "name": "Test Track",
            "plugins": [{
                "uri": "http://lsp-plug.in/plugins/lv2/compressor_stereo",
                "parameters": {"th": -18.0, "cr": 4.0}
            }]
        }],
        "buses": [],
    }
```

### Integration Tests (Nix)

```bash
# Run as part of `nix flake check`

# Test 1: XML validity
xmllint --noout $out/SG9-Broadcast/SG9-Broadcast.ardour

# Test 2: Schema structure (basic assertions)
grep -q '<Session version="8' $out/SG9-Broadcast/SG9-Broadcast.ardour
grep -q '<Routes>' $out/SG9-Broadcast/SG9-Broadcast.ardour
grep -q '<Config>' $out/SG9-Broadcast/SG9-Broadcast.ardour

# Test 3: Track count matches config
TRACK_COUNT=$(grep -c '<Route.*default-type="audio"' $out/SG9-Broadcast/SG9-Broadcast.ardour)
[ "$TRACK_COUNT" -eq 6 ] || exit 1  # Expected: 6 tracks in SG9 session
```

### Manual Acceptance Tests

- [ ] `nix build .#sg9-broadcast-template` produces valid XML output
- [ ] `nix flake check` passes all automated tests
- [ ] Generated session loads in Ardour 8.12 without errors or warnings
- [ ] All plugin chains appear correctly in mixer (HPF → Gate → De-esser → Compressor → Limiter)
- [ ] Track routing matches STUDIO.md signal flow (Voice bus, VoIP Send bus)
- [ ] VCA "All Mics" controls expected tracks
- [ ] Route groups work correctly (voice group contains all mic tracks)
- [ ] Session plays back at correct sample rate (48 kHz)
- [ ] Preset parameters loaded correctly (verify compressor threshold = -18 dB)

## Rollback Procedure

1. Revert to manual Ardour template workflow
2. Remove `nix/ardour/` and `nix/sessions/` directories
3. Remove flake output additions
4. Restore previous `.ardour` template file from Git history

## Dependencies

| Package | NixOS Attribute | Version | Purpose |
|---------|-----------------|---------|---------|
| **rdflib** | `python313Packages.rdflib` | 7.5.0 | Parse LV2 preset .ttl files (Turtle/RDF format) |
| **lxml** | `python313Packages.lxml` | 6.0.2 | XML manipulation fallback |
| **xsdata** | `python313Packages.xsdata` | 25.7+ | Generate dataclasses from XML samples (optional) |
| **libxml2** | `pkgs.libxml2` | 2.13+ | XML validation via `xmllint` |
| **lilv** | `pkgs.lilv` | 0.24.26 | **C library only** - for `lv2info` CLI validation |
| **pytest** | `python313Packages.pytest` | 8.x | Unit testing |

> **Important:** `python3Packages.lilv` does NOT exist in nixpkgs. Use `rdflib` for .ttl parsing instead.

## Future Phases

### Phase 2: Enhanced Features
- Clip/cue grid generation (integrate with `clips/` library)
- MIDI routing configuration (Generic MIDI bindings)
- Automation curves and tempo maps
- Monitor section configuration

### Phase 3: Extraction as Standalone Library
- `git subtree split -P nix/ardour -b ardour-nix`
- Create standalone `ardour-nix` flake with full documentation
- SG9 imports via `inputs.ardour-nix`
- Publish to FlakeHub for community use

### Phase 4: Validation & Tooling
- Ardour session linter (validate routing, check for orphaned buses)
- Session diffing tool (compare two .ardour files semantically)
- Plugin preset generator (extract presets from existing sessions)

## References

### Primary Sources

- [Ardour session_state.cc](https://github.com/Ardour/ardour/blob/main/libs/ardour/session_state.cc) — Canonical XML structure implementation
- [Flowblade exportardour.py](https://github.com/jliljebl/flowblade/blob/master/flowblade-trunk/Flowblade/exportardour.py) — Complete reference implementation (~1800 lines)
- [xsdata samples modeling](https://xsdata.readthedocs.io/en/latest/codegen/samples-modeling.html) — Generate dataclasses from raw XML files

### LV2 & Plugin Standards

- [LV2 Presets Specification](http://lv2plug.in/ns/ext/presets) — Official preset format documentation
- [rdflib Documentation](https://rdflib.readthedocs.io/) — Python RDF/Turtle parsing library
- [LSP Plugins LV2](https://lsp-plug.in/) — Plugin URIs and parameter symbols

### SG9 Studio Documentation

- [docs/STUDIO.md](../docs/STUDIO.md) — Signal flow, track hierarchy, routing
- [docs/ARDOUR-SETUP.md](../docs/ARDOUR-SETUP.md) — Plugin chains, session configuration
- [docs/MIDI-CONTROLLERS.md](../docs/MIDI-CONTROLLERS.md) — Future MIDI routing integration
