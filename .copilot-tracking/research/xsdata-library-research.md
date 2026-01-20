# xsdata Python Library Research

**Research Date:** 2026-01-20  
**Confidence Level:** High  
**Sources:** Official documentation, GitHub repository, PyPI

---

## Executive Summary

xsdata is a mature Python library for XML/JSON data binding that generates Python dataclasses from various schema sources including **raw XML files without formal schemas**. It's actively maintained (v26.1 released 2026-01-20), supports Python 3.10+, and is well-suited for complex nested XML like Ardour session files.

---

## 1. How xsdata Generates Dataclasses

### Supported Input Sources

| Source Type | Extension | Notes |
|-------------|-----------|-------|
| XML Schema | `.xsd` | Full XSD 1.0 & 1.1 support |
| WSDL | `.wsdl` | SOAP 1.1 bindings |
| DTD | `.dtd` | Requires lxml |
| **XML Documents** | `.xml` | Schema-less generation |
| JSON Documents | `.json` | Schema-less generation |

### Generation Process (Schema-less XML)

1. **Parses XML structure** into an internal class model
2. **Infers types** from element content (strings, numbers, booleans)
3. **Detects nested structures** and creates corresponding classes
4. **Handles attributes** separately from element content
5. **Merges duplicate classes** when processing multiple samples
6. **Flattens field types** across samples for Union types

---

## 2. Command Syntax for XML Files (No XSD)

### Basic Command

```bash
# Generate from a single XML file
xsdata generate session.xml --package ardour.models

# Generate from a directory of XML samples
xsdata generate ./samples/ --package ardour.models

# Recursive directory search
xsdata generate ./samples/ --package ardour.models --recursive
```

### Recommended Options for Complex XML

```bash
xsdata generate session.ardour \
  --package ardour.models \
  --structure-style single-package \
  --unnest-classes \
  --slots \
  --docstring-style Google
```

### Key CLI Options

| Option | Description | Recommended for Ardour |
|--------|-------------|------------------------|
| `-p, --package` | Target Python package | `ardour.models` |
| `-ss, --structure-style` | Output structure | `single-package` for unified output |
| `--unnest-classes` | Move inner classes to top level | Yes (cleaner code) |
| `--slots` | Enable `__slots__` | Yes (memory efficient) |
| `-ds, --docstring-style` | Docstring format | `Google` or `NumPy` |
| `--compound-fields` | Preserve element order in sequences | Yes if order matters |
| `--wrapper-fields` | Generate wrapper fields | Consider for lists |
| `-r, --recursive` | Search directories recursively | For multiple samples |

---

## 3. Handling Complex Nested XML (Ardour Sessions)

### Capabilities

xsdata **can handle complex nested XML** like Ardour session files:

✅ **Deeply nested elements** - Creates nested dataclass hierarchy  
✅ **Mixed content** - Text + child elements  
✅ **Namespaces** - Full namespace support  
✅ **Attributes** - Captured as dataclass fields with metadata  
✅ **Repeating elements** - Detected and typed as `list[ChildClass]`  
✅ **Union types** - Multiple samples merge varying types  

### Multi-Sample Strategy for Better Models

```bash
# Provide multiple Ardour session files for comprehensive type inference
mkdir -p ./ardour-samples/
cp session1.ardour session2.ardour session3.ardour ./ardour-samples/

xsdata generate ./ardour-samples/ \
  --package ardour.models \
  --structure-style single-package
```

When multiple samples are provided, xsdata:
- **Merges duplicate classes** across files
- **Unions field types** that differ between samples
- **Detects optional fields** (present in some, absent in others)

### Example: Complex Nested XML

**Input XML:**
```xml
<Session version="6000" name="podcast">
  <Config>
    <Option name="native-file-data-format" value="RF64"/>
  </Config>
  <Routes>
    <Route id="28" name="Host Mic" default-type="audio">
      <IO name="Host Mic" id="29" direction="Input">
        <Port type="audio" name="Host Mic/audio_in 1"/>
      </IO>
    </Route>
  </Routes>
</Session>
```

**Generated Dataclass (simplified):**
```python
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class Port:
    type: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    name: Optional[str] = field(default=None, metadata={"type": "Attribute"})

@dataclass
class Io:
    name: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    id: Optional[int] = field(default=None, metadata={"type": "Attribute"})
    direction: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    port: list[Port] = field(default_factory=list, metadata={"type": "Element"})

@dataclass
class Route:
    id: Optional[int] = field(default=None, metadata={"type": "Attribute"})
    name: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    default_type: Optional[str] = field(default=None, metadata={"type": "Attribute", "name": "default-type"})
    io: list[Io] = field(default_factory=list, metadata={"type": "Element", "name": "IO"})

@dataclass
class Routes:
    route: list[Route] = field(default_factory=list, metadata={"type": "Element", "name": "Route"})

@dataclass  
class Option:
    name: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    value: Optional[str] = field(default=None, metadata={"type": "Attribute"})

@dataclass
class Config:
    option: list[Option] = field(default_factory=list, metadata={"type": "Element", "name": "Option"})

@dataclass
class Session:
    version: Optional[int] = field(default=None, metadata={"type": "Attribute"})
    name: Optional[str] = field(default=None, metadata={"type": "Attribute"})
    config: Optional[Config] = field(default=None, metadata={"type": "Element", "name": "Config"})
    routes: Optional[Routes] = field(default=None, metadata={"type": "Element", "name": "Routes"})
```

---

## 4. Current Version & Key Features

### Version Information

| Property | Value |
|----------|-------|
| **Current Version** | 26.1 (2026-01-20) |
| **Python Support** | 3.10, 3.11, 3.12, 3.13, 3.14 |
| **Repository** | [github.com/tefra/xsdata](https://github.com/tefra/xsdata) |
| **Stars** | 421 |
| **License** | MIT |

### Key Features

**Code Generation:**
- XML Schemas 1.0 & 1.1
- WSDL 1.1 with SOAP 1.1 bindings
- DTD external definitions
- **Direct XML/JSON document processing (schema-less)**
- Extensive configuration options
- Plugin system for custom output formats

**Generated Code:**
- Pure Python dataclasses with metadata
- Full type hints with forward references and unions
- Enumerations and inner classes
- Namespace-qualified elements and attributes
- `kw_only=True` always enabled (Python 3.10+)

**Data Binding:**
- XML and JSON parser/serializer
- PyCode serializer (generate Python code from objects)
- lxml and native xml handlers
- Wildcard elements and attributes support
- XInclude statement support

### Recent Changes (v26.1)

- Added Python 3.14 support
- Switched to `Sequence` for generic containers
- Removed Python 3.9 support
- `union-type`, `kw-only`, `postponed-annotations` now always enabled
- Fixed choice elements with `minOccurs <= 1` not marked optional

---

## 5. Limitations & Gotchas (Schema-less XML)

### Type Inference Limitations

| Issue | Impact | Workaround |
|-------|--------|------------|
| **All values are strings by default** | Numbers/booleans may be typed as `str` | Manually annotate types or provide multiple samples |
| **Can't infer constraints** | No min/max, patterns, enums | Add manual validation |
| **Optional vs required ambiguous** | Single sample can't distinguish | Use multiple samples with varying content |
| **Union types from samples** | May be overly broad | Provide representative samples |

### Structural Limitations

| Issue | Impact | Workaround |
|-------|--------|------------|
| **Element order not guaranteed** | Serialization may differ | Use `--compound-fields` option |
| **Mixed content complexity** | Text + elements can be tricky | Review generated models |
| **Namespace prefix changes** | Native XML parser doesn't preserve prefixes | Use lxml handler |
| **Large files** | Memory usage for very large XML | Process smaller samples |

### Recommended Workflow for Schema-less XML

```python
# 1. Generate initial models
# xsdata generate session.ardour --package ardour.models

# 2. Parse and verify
from xsdata.formats.dataclass.parsers import XmlParser
from ardour.models import Session

parser = XmlParser()
session = parser.parse("session.ardour", Session)

# 3. Inspect and refine types manually
print(session)

# 4. Serialize back to XML
from xsdata.formats.dataclass.serializers import XmlSerializer
from xsdata.formats.dataclass.serializers.config import SerializerConfig

config = SerializerConfig(indent="  ")
serializer = XmlSerializer(config=config)
xml_output = serializer.render(session)
```

### Best Practices for Ardour Session Files

1. **Collect multiple session samples** with different configurations
2. **Use `--compound-fields`** to preserve element ordering
3. **Review generated types** and add manual type annotations where needed
4. **Test round-trip** (parse → serialize → compare) to verify fidelity
5. **Consider lxml handler** for better namespace handling:

```python
from xsdata.formats.dataclass.parsers import XmlParser
from xsdata.formats.dataclass.parsers.handlers import LxmlEventHandler

parser = XmlParser(handler=LxmlEventHandler)
```

---

## Installation

```bash
# Full installation with all features
pip install xsdata[cli,lxml,soap]

# Minimal for code generation only
pip install xsdata[cli]

# NixOS
nix-shell -p python3Packages.xsdata
```

---

## References

- [Official Documentation](https://xsdata.readthedocs.io/)
- [Samples Modeling Guide](https://xsdata.readthedocs.io/en/latest/codegen/samples_modeling/)
- [CLI Reference](https://xsdata.readthedocs.io/en/latest/codegen/intro/)
- [GitHub Repository](https://github.com/tefra/xsdata)
- [PyPI Package](https://pypi.org/project/xsdata/)
