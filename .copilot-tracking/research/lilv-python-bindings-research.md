# Lilv Python Bindings Research

**Date:** 2026-01-20  
**Researcher:** AI Engineer Agent  
**Confidence:** High  
**Last Verified:** 2026-01-20

---

## NixOS Package Availability Summary

| Package | nixpkgs Attribute | Version | Python Bindings |
|---------|-------------------|---------|-----------------|
| **xsdata** | `python313Packages.xsdata` | 25.7 | ✅ Native Python |
| **lxml** | `python313Packages.lxml` | 6.0.2 | ✅ Native Python |
| **rdflib** | `python313Packages.rdflib` | 7.5.0 | ✅ Native Python (lilv alternative) |
| **lilv** | `lilv` | 0.24.26 | ⚠️ C library only, ctypes wrapper available |
| **sord** | `sord` | 0.16.20 | ❌ C library only |
| **serd** | `serd` | 0.32.4 | ❌ C library only |
| **suil** | `suil` | 0.10.20 | ❌ C library only (not needed for session gen) |
| **sratom** | `sratom` | 0.6.20 | ❌ C library only |
| **lv2** | `lv2` | 1.18.10 | ❌ C headers/specs only |

### Ready-to-Use Nix Expression

```nix
# For Ardour session generation
{ pkgs }:
pkgs.python313.withPackages (ps: [
  ps.xsdata           # XML dataclass generator (v25.7)
  ps.lxml             # XML parsing/writing (v6.0.2)
  ps.rdflib           # RDF/Turtle for LV2 plugin metadata (v7.5.0)
])
```

### Audio Production Flake

**musnix** - Real-time audio configuration for NixOS:
```nix
{
  inputs.musnix.url = "github:musnix/musnix";
  # Provides: nixosModules.musnix, packages.rtcqs
}
```

---

## Executive Summary

Lilv provides **official Python bindings** via ctypes that wrap the `liblilv` C library. These bindings are maintained upstream in the lilv repository but **are NOT packaged as a separate `python3Packages.lilv`** in nixpkgs. The Python bindings are a single-file ctypes wrapper (`lilv.py`) that can be used directly if the `liblilv` shared library is installed.

---

## 1. NixOS Package Availability

### Finding: No `python3Packages.lilv`

```bash
$ nix search nixpkgs "python.*lilv"
# No results
```

The `lilv` package in nixpkgs (`pkgs.lilv`) provides:
- The C library (`liblilv-0.dylib` / `liblilv-0.so`)
- Development headers
- Man pages
- Command-line tools (`lv2ls`, `lv2info`, `lv2bench`, `lv2apply`)

**Package outputs:**
- `out` - Library and tools
- `dev` - Headers
- `man` - Documentation

### Solution: Use the upstream Python bindings directly

The official Python bindings are a **single file** (`lilv.py`) that uses ctypes to load the system `liblilv` library. This file can be:

1. Downloaded from the official repository
2. Placed in your Python path or project directory
3. Used directly with `import lilv`

**Prerequisites:**
```nix
# In your NixOS/Home Manager configuration or shell.nix
environment.systemPackages = [ pkgs.lilv pkgs.lv2 ];
```

**Download the bindings:**
```bash
curl -o lilv.py https://gitlab.com/lv2/lilv/-/raw/main/bindings/python/lilv.py
```

---

## 2. Python API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `World` | Library context; loads plugins and provides namespaces |
| `Plugin` | LV2 plugin metadata and introspection |
| `Port` | Plugin port (audio, control, MIDI, etc.) |
| `Node` | RDF data node (URI, string, int, float, bool) |
| `Plugins` | Collection of plugins (iterable) |
| `PluginClass` | Plugin category (e.g., Filters, Compressors) |
| `PluginClasses` | Collection of plugin classes |
| `Nodes` | Collection of data nodes |
| `UI` | Plugin UI metadata |
| `UIs` | Collection of plugin UIs |
| `Instance` | Instantiated plugin (for running audio) |
| `State` | Plugin state (for presets) |
| `Namespace` | RDF namespace helper |
| `Namespaces` | Common LV2 namespaces (lv2, atom, midi, etc.) |

### World Class Methods

```python
world = lilv.World()

# Loading
world.load_all()                      # Load all installed LV2 bundles
world.load_bundle(bundle_uri)         # Load specific bundle
world.load_resource(uri)              # Load related resources (presets, etc.)
world.unload_bundle(bundle_uri)
world.unload_resource(uri)

# Querying
world.get_all_plugins()               # Returns Plugins collection
world.get_plugin_classes()            # Returns PluginClasses collection
world.get_plugin_class()              # Returns root lv2:Plugin class
world.find_nodes(subj, pred, obj)     # SPARQL-like query
world.get(subj, pred, obj)            # Get single node
world.ask(subj, pred, obj)            # Check if triple exists
world.get_symbol(subject)             # Get lv2:symbol

# Node creation
world.new_uri(uri)
world.new_file_uri(host, path)
world.new_string(string)
world.new_int(value)
world.new_float(value)
world.new_bool(value)

# Options
world.set_option(uri, value)
# Options: OPTION_DYN_MANIFEST, OPTION_FILTER_LANG, OPTION_LANG, OPTION_LV2_PATH

# Namespaces (via world.ns)
world.ns.lv2                          # http://lv2plug.in/ns/lv2core#
world.ns.lv2.Plugin                   # http://lv2plug.in/ns/lv2core#Plugin
world.ns.lv2.InputPort
world.ns.lv2.OutputPort
world.ns.lv2.AudioPort
world.ns.lv2.ControlPort
world.ns.atom, world.ns.midi, world.ns.rdfs, world.ns.doap, etc.
```

### Plugin Class Methods

```python
plugin = plugins[plugin_uri]

# Identity
plugin.get_uri()                      # Plugin URI (unique identifier)
plugin.get_name()                     # Human-readable name
plugin.get_class()                    # Plugin class (category)
plugin.verify()                       # Validate plugin data

# Metadata
plugin.get_author_name()
plugin.get_author_email()
plugin.get_author_homepage()
plugin.get_project()
plugin.get_bundle_uri()               # Bundle location
plugin.get_library_uri()              # Shared library path
plugin.get_data_uris()                # RDF data file URIs

# Features
plugin.has_feature(uri)
plugin.get_supported_features()
plugin.get_required_features()
plugin.get_optional_features()
plugin.has_extension_data(uri)
plugin.get_extension_data()

# Ports
plugin.get_num_ports()
plugin.get_num_ports_of_class(class1, class2, ...)
plugin.get_port(index_or_symbol)
plugin.get_port_by_index(index)
plugin.get_port_by_symbol(symbol)
plugin.get_port_by_designation(port_class, designation)
plugin.has_latency()
plugin.get_latency_port_index()

# Related resources (presets, etc.)
plugin.get_related(resource_type)     # Get presets, etc.
plugin.get_uis()                      # Get plugin UIs
plugin.get_value(predicate)           # Query RDF properties
plugin.is_replaced()                  # Check if deprecated
```

### Port Class Methods

```python
port = plugin.get_port(0)

# Identity
port.get_index()
port.get_symbol()                     # C identifier (e.g., "gain")
port.get_name()                       # Human name (e.g., "Gain")
port.get_node()                       # RDF node

# Classification
port.get_classes()                    # All port classes
port.is_a(port_class)                 # Check specific class
port.get_properties()
port.has_property(property_uri)
port.supports_event(event_type)

# Values
port.get_range()                      # Returns (default, min, max)
port.get_scale_points()               # Enumeration values
port.get_value(predicate)
port.get(predicate)
```

### URI Constants

```python
lilv.LILV_URI_INPUT_PORT              # http://lv2plug.in/ns/lv2core#InputPort
lilv.LILV_URI_OUTPUT_PORT             # http://lv2plug.in/ns/lv2core#OutputPort
lilv.LILV_URI_AUDIO_PORT              # http://lv2plug.in/ns/lv2core#AudioPort
lilv.LILV_URI_CONTROL_PORT            # http://lv2plug.in/ns/lv2core#ControlPort
lilv.LILV_URI_CV_PORT                 # http://lv2plug.in/ns/lv2core#CVPort
lilv.LILV_URI_ATOM_PORT               # http://lv2plug.in/ns/ext/atom#AtomPort
lilv.LILV_URI_EVENT_PORT              # http://lv2plug.in/ns/ext/event#EventPort
lilv.LILV_URI_MIDI_EVENT              # http://lv2plug.in/ns/ext/midi#MidiEvent
lilv.LILV_URI_PORT                    # http://lv2plug.in/ns/lv2core#Port

# Namespaces
lilv.LILV_NS_LV2                      # http://lv2plug.in/ns/lv2core#
lilv.LILV_NS_DOAP                     # http://usefulinc.com/ns/doap#
lilv.LILV_NS_FOAF                     # http://xmlns.com/foaf/0.1/
lilv.LILV_NS_RDFS                     # http://www.w3.org/2000/01/rdf-schema#
lilv.LILV_NS_LILV                     # http://drobilla.net/ns/lilv#
```

---

## 3. Code Examples

### Example 1: List All Installed LV2 Plugins

```python
#!/usr/bin/env python3
"""List all installed LV2 plugins with metadata."""

import lilv

def list_all_plugins():
    world = lilv.World()
    world.load_all()
    
    plugins = world.get_all_plugins()
    print(f"Found {len(plugins)} plugins:\n")
    
    for plugin in plugins:
        uri = plugin.get_uri()
        name = plugin.get_name()
        plugin_class = plugin.get_class()
        
        print(f"URI:   {uri}")
        print(f"Name:  {name}")
        print(f"Class: {plugin_class.get_label()}")
        
        # Author info
        author = plugin.get_author_name()
        if author:
            print(f"Author: {author}")
        
        # Port summary
        n_audio_in = plugin.get_num_ports_of_class(
            world.ns.lv2.InputPort, world.ns.lv2.AudioPort)
        n_audio_out = plugin.get_num_ports_of_class(
            world.ns.lv2.OutputPort, world.ns.lv2.AudioPort)
        n_control_in = plugin.get_num_ports_of_class(
            world.ns.lv2.InputPort, world.ns.lv2.ControlPort)
        
        print(f"Ports: {n_audio_in} audio in, {n_audio_out} audio out, {n_control_in} control in")
        print("-" * 60)

if __name__ == "__main__":
    list_all_plugins()
```

### Example 2: Get Detailed Port Information

```python
#!/usr/bin/env python3
"""Get detailed port metadata for a specific plugin."""

import lilv
import sys

def get_plugin_ports(plugin_uri: str):
    world = lilv.World()
    world.load_all()
    
    plugins = world.get_all_plugins()
    
    try:
        plugin = plugins[plugin_uri]
    except KeyError:
        print(f"Plugin not found: {plugin_uri}")
        sys.exit(1)
    
    print(f"Plugin: {plugin.get_name()}")
    print(f"URI: {plugin.get_uri()}")
    print(f"\nPorts ({plugin.get_num_ports()}):\n")
    
    for i in range(plugin.get_num_ports()):
        port = plugin.get_port_by_index(i)
        
        print(f"  [{i}] {port.get_symbol()} - {port.get_name()}")
        
        # Port type
        classes = port.get_classes()
        class_names = [str(c) for c in classes]
        
        is_input = port.is_a(lilv.LILV_URI_INPUT_PORT)
        is_output = port.is_a(lilv.LILV_URI_OUTPUT_PORT)
        is_audio = port.is_a(lilv.LILV_URI_AUDIO_PORT)
        is_control = port.is_a(lilv.LILV_URI_CONTROL_PORT)
        is_atom = port.is_a(lilv.LILV_URI_ATOM_PORT)
        
        direction = "Input" if is_input else "Output"
        port_type = "Audio" if is_audio else "Control" if is_control else "Atom" if is_atom else "Other"
        
        print(f"      Direction: {direction}")
        print(f"      Type: {port_type}")
        
        # Range for control ports
        if is_control:
            default, minimum, maximum = port.get_range()
            print(f"      Range: {minimum} to {maximum} (default: {default})")
        
        # Scale points (enumeration values)
        scale_points = port.get_scale_points()
        if scale_points:
            print("      Scale Points:")
            for sp in scale_points:
                print(f"        {sp.get_value()} = {sp.get_label()}")
        
        print()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: script.py <plugin-uri>")
        print("Example: script.py http://lsp-plug.in/plugins/lv2/compressor_stereo")
        sys.exit(1)
    
    get_plugin_ports(sys.argv[1])
```

### Example 3: List Plugin Presets

```python
#!/usr/bin/env python3
"""List all presets for a plugin."""

import lilv
import sys

NS_PRESETS = "http://lv2plug.in/ns/ext/presets#"

def list_presets(plugin_uri: str):
    world = lilv.World()
    world.load_all()
    
    # Create presets namespace
    world.ns.presets = lilv.Namespace(world, NS_PRESETS)
    
    plugins = world.get_all_plugins()
    
    try:
        plugin = plugins[plugin_uri]
    except KeyError:
        print(f"Plugin not found: {plugin_uri}")
        sys.exit(1)
    
    print(f"Presets for: {plugin.get_name()}\n")
    
    # Get related resources of type Preset
    presets = plugin.get_related(world.ns.presets.Preset)
    
    preset_list = []
    for preset in presets:
        # Load the preset resource to get its label
        world.load_resource(preset)
        label = world.get(preset, world.ns.rdfs.label, None)
        
        if label is None:
            label = "(no label)"
        
        preset_list.append((str(preset), str(label)))
    
    # Sort and print
    for uri, label in sorted(preset_list, key=lambda x: x[1]):
        print(f'  "{label}"')
        print(f'    URI: {uri}\n')
    
    print(f"Total: {len(preset_list)} presets")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: script.py <plugin-uri>")
        sys.exit(1)
    
    list_presets(sys.argv[1])
```

### Example 4: Query Specific Plugin Properties

```python
#!/usr/bin/env python3
"""Query specific properties from LV2 plugin RDF data."""

import lilv

def query_plugin_properties(plugin_uri: str):
    world = lilv.World()
    world.load_all()
    
    plugins = world.get_all_plugins()
    plugin = plugins[plugin_uri]
    
    # Query arbitrary RDF properties using get_value()
    # This returns all matching triples: plugin-uri predicate ?object
    
    # Example: Get all doap:license values
    licenses = plugin.get_value(world.ns.doap.license)
    for license in licenses:
        print(f"License: {license}")
    
    # Query if plugin has specific feature
    if plugin.has_feature("http://lv2plug.in/ns/lv2core#hardRTCapable"):
        print("Plugin is hard real-time capable")
    
    # Get required features
    required = plugin.get_required_features()
    if len(required) > 0:
        print("Required features:")
        for feat in required:
            print(f"  - {feat}")
    
    # Check for UI
    uis = plugin.get_uis()
    if len(uis) > 0:
        print(f"UIs available: {len(uis)}")
        for ui in uis:
            print(f"  - {ui.get_uri()}")
```

### Example 5: Search Plugins by Category

```python
#!/usr/bin/env python3
"""Find all plugins of a specific class (e.g., Compressors)."""

import lilv

def find_plugins_by_class(class_uri: str):
    world = lilv.World()
    world.load_all()
    
    # Get all plugin classes
    all_classes = world.get_plugin_classes()
    
    # Find matching class
    target_class = all_classes.get_by_uri(world.new_uri(class_uri))
    if target_class is None:
        print(f"Class not found: {class_uri}")
        # List available classes
        print("\nAvailable classes:")
        for pc in all_classes:
            print(f"  {pc.get_uri()} - {pc.get_label()}")
        return
    
    print(f"Plugins of class: {target_class.get_label()}\n")
    
    # Filter plugins by class
    plugins = world.get_all_plugins()
    for plugin in plugins:
        plugin_class = plugin.get_class()
        if str(plugin_class.get_uri()) == class_uri:
            print(f"  {plugin.get_name()} ({plugin.get_uri()})")

# Common LV2 plugin classes:
# http://lv2plug.in/ns/lv2core#CompressorPlugin
# http://lv2plug.in/ns/lv2core#LimiterPlugin
# http://lv2plug.in/ns/lv2core#GatePlugin
# http://lv2plug.in/ns/lv2core#ExpanderPlugin
# http://lv2plug.in/ns/lv2core#DelayPlugin
# http://lv2plug.in/ns/lv2core#ReverbPlugin
# http://lv2plug.in/ns/lv2core#EQPlugin
# http://lv2plug.in/ns/lv2core#FilterPlugin
# http://lv2plug.in/ns/lv2core#OscillatorPlugin
# http://lv2plug.in/ns/lv2core#InstrumentPlugin
# http://lv2plug.in/ns/lv2core#AnalyserPlugin

if __name__ == "__main__":
    find_plugins_by_class("http://lv2plug.in/ns/lv2core#CompressorPlugin")
```

---

## 4. State/Preset Handling (Advanced)

The lilv Python bindings expose state functions but the `State` class is marked as "TODO" in the implementation. For **read-only** preset listing (as shown above), use `plugin.get_related()` with the presets namespace.

For **full state save/restore**, the C API functions are bound:

```python
# C functions available (via ctypes):
c.state_new_from_world(world, urid_map, subject)
c.state_new_from_file(world, urid_map, subject, path)
c.state_new_from_string(world, urid_map, string)
c.state_new_from_instance(plugin, instance, urid_map, ...)
c.state_save(world, urid_map, urid_unmap, state, ...)
c.state_to_string(world, urid_map, urid_unmap, state, ...)
c.state_restore(state, instance, ...)
c.state_free(state)
c.state_get_label(state)
c.state_set_label(state, label)
c.state_get_plugin_uri(state)
c.state_equals(state1, state2)
```

**Note:** Full state handling requires implementing `LV2_URID_Map` and `LV2_URID_Unmap` features, which is complex. For SG9 Studio purposes, reading preset metadata via `get_related()` + `load_resource()` is sufficient.

---

## 5. Alternative Python Libraries

If lilv bindings are unavailable or unsuitable:

### Option A: Direct RDF Parsing with rdflib

```python
import rdflib
from pathlib import Path

def scan_lv2_bundles(lv2_path="/usr/lib/lv2"):
    """Parse LV2 bundle manifests directly with rdflib."""
    g = rdflib.Graph()
    
    for bundle in Path(lv2_path).glob("*.lv2"):
        manifest = bundle / "manifest.ttl"
        if manifest.exists():
            g.parse(manifest, format="turtle")
    
    # Query for plugins
    LV2 = rdflib.Namespace("http://lv2plug.in/ns/lv2core#")
    for plugin in g.subjects(rdflib.RDF.type, LV2.Plugin):
        print(plugin)
```

**Pros:** Pure Python, no system dependencies
**Cons:** Must implement LV2 discovery logic, slower, more complex

### Option B: lv2 Python Package (PyPI)

There's no official `lv2` package on PyPI that provides full introspection. The `lilv` ctypes wrapper remains the canonical solution.

### Option C: Subprocess Calls to lv2ls/lv2info

```python
import subprocess
import json

def list_plugins_cli():
    """Use lv2ls command-line tool."""
    result = subprocess.run(["lv2ls", "-n"], capture_output=True, text=True)
    return result.stdout.strip().split("\n")
```

**Pros:** Simple, uses system tools
**Cons:** Less metadata, parsing required, subprocess overhead

---

## 6. NixOS Integration Recommendation

For SG9 Studio, create a Python environment with lilv:

```nix
# shell.nix or flake.nix devShell
{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [
    # Add any other Python packages here
  ]);
  
  # Download lilv.py to a known location
  lilvPy = pkgs.fetchurl {
    url = "https://gitlab.com/lv2/lilv/-/raw/v0.24.26/bindings/python/lilv.py";
    sha256 = "..."; # Calculate with nix-prefetch-url
  };
in
pkgs.mkShell {
  packages = [
    pythonEnv
    pkgs.lilv     # Provides liblilv-0.so
    pkgs.lv2      # LV2 specifications
  ];
  
  shellHook = ''
    export PYTHONPATH="${lilvPy.outPath}:$PYTHONPATH"
  '';
}
```

Or simply copy `lilv.py` into your scripts directory and ensure `pkgs.lilv` is installed.

---

## 7. References

- **Official Repository:** https://gitlab.com/lv2/lilv
- **Python Bindings Source:** https://gitlab.com/lv2/lilv/-/blob/main/bindings/python/lilv.py
- **Example Scripts:** https://gitlab.com/lv2/lilv/-/tree/main/bindings/python
- **Lilv Documentation:** https://lv2plug.in/lilv/
- **LV2 Specifications:** https://lv2plug.in/

---

## Summary

| Question | Answer |
|----------|--------|
| Is there `python3Packages.lilv` in nixpkgs? | **No** |
| How to get Python bindings? | Download `lilv.py` from upstream, ensure `pkgs.lilv` installed |
| List plugins | `world.get_all_plugins()` iteration |
| Get plugin metadata | `plugin.get_uri()`, `get_name()`, `get_class()` |
| Get port info | `plugin.get_port(i)`, `port.get_range()`, `port.is_a()` |
| List presets | `plugin.get_related(presets.Preset)` + `world.load_resource()` |
| Save/restore state | Complex; use C-level `state_*` functions (not fully wrapped) |
| Alternative | `rdflib` for direct RDF parsing, or `lv2ls`/`lv2info` CLI |
