## Plan: Comprehensive SG9 Studio Documentation Overhaul

**TL;DR:** Complete documentation overhaul: resolve all inconsistencies (monitoring model, de-essing, TAP plugins, plugin chain order), remove manual section numbering, restructure for readability, add missing content (platform loudness, LRA, metering, redundancy), consolidate research documents, add visual signal flow diagram, implement version tracking, and ensure markdown lint/format compliance.

### Steps

01. **Remove manual section numbering from all documents**

    - Strip numeric prefixes from all headers (e.g., `## 5) Ardour Session Template` → `## Ardour Session Template`)
    - Use hierarchical heading levels (`#`, `##`, `###`, `####`) to convey structure
    - Let markdown renderers generate TOC numbering automatically
    - Affects: [STUDIO.md](STUDIO.md)
    - **Status:** ✅ Done (new STUDIO.md uses unnumbered headings)

02. **Standardize on Software Monitoring model across all documents**

    - Update [ardour-monitoring-io-research.md](ardour-monitoring-io-research.md): Change key recommendation to "Ardour does monitoring", revise configuration and troubleshooting sections
    - Update [STUDIO.md](STUDIO.md): Fix Track Configuration Notes, Quick Reference tables, clarify Vocaster as physical volume control only
    - Retain "Vocaster Volume Knob Behavior" as canonical software monitoring reference
    - **Status:** ✅ Done (STUDIO.md now standardizes on software monitoring)

03. **Fix de-essing hierarchy and remove TAP plugins from stack**

    - Update [broadcast-studio-research.md](broadcast-studio-research.md) comparison table: LSP Compressor sidechain = "**SG9 Primary**", Calf Deesser = "Quick setup / Legacy"
    - Remove TAP plugins from [README.md](README.md) and [STUDIO.md](STUDIO.md) entirely
    - Final stack: **LSP + Calf + ZAM + x42** (4 suites)
    - **Status:** ✅ Done (TAP removed from docs and install commands)

04. **Standardize plugin chain order with rationale**

    - Canonical order: `HPF → Gate → De-esser (LSP SC) → EQ → Compressor → Limiter`
    - Update [broadcast-studio-research.md](broadcast-studio-research.md) and [STUDIO.md](STUDIO.md) to match
    - Add rationale: "HPF removes rumble before gate detection; de-esser before EQ prevents presence boost amplifying sibilance"
    - **Status:** ✅ Done (canonical order and rationale in STUDIO.md)

05. **Consolidate research documents into STUDIO.md appendices**

    - Merge [ardour-monitoring-io-research.md](ardour-monitoring-io-research.md) content into STUDIO.md as "Appendix: Ardour Monitoring Technical Reference"
    - Merge [broadcast-studio-research.md](broadcast-studio-research.md) into STUDIO.md as "Appendix: Plugin Technical Reference"
    - Result: Single authoritative document ([STUDIO.md](STUDIO.md)) with optional deep-dive appendices
    - Delete or archive the separate research files after merge
    - **Status:** ✅ Done (appendices added to STUDIO.md; research files archived with pointers)

06. **Restructure [STUDIO.md](STUDIO.md) for improved readability**

    - Add "Quick Start" summary section near the top with links to detailed sections (1-page overview for returning users)
    - Reorganize main content into logical flow: Quick Start → Hardware Setup → Ardour Configuration → Processing Chains → Controllers → Operations → Troubleshooting → Appendices
    - Consolidate redundant content (plugin parameters currently duplicated across sections)
    - Implementor has full authority to restructure entire document
    - **Status:** ✅ Done (new structure with Quick Start → Hardware → Ardour → Chains → Ops → Troubleshooting → Appendices)

07. **Add visual signal flow diagram**

    - Create Mermaid diagram showing: `Mic → Vocaster ADC → ALSA → Ardour Input → Plugin Chain → Master Bus → ALSA → Vocaster DAC → Monitors/Headphones`
    - Include monitoring path annotation showing software monitoring model
    - Place in Hardware Overview or new "Signal Flow" section
    - **Status:** ✅ Done (Mermaid diagram added in STUDIO.md)

08. **Add platform-specific loudness targets and LRA guidance**

    - Add table: Apple Podcasts (-16 LUFS), Spotify (-14 LUFS normalized), YouTube (-14 LUFS), Amazon (-14 LUFS, -2 dBTP), EBU R128 (-23 LUFS ±0.5 LU)
    - Add recommendation: "Produce at -16 LUFS for broadest compatibility"
    - Add LRA section: measurement in Ardour, target ranges (4–10 LU podcast, 5–15 LU broadcast), adjustment workflow if out of range
    - **Status:** ✅ Done (platform targets + LRA guidance in STUDIO.md)

09. **Enhance operational workflows**

    - Add pre-show loudness verification: "Play 30s test, verify -16 LUFS ± 2 LU and TP ≤ -1.0 dBTP"
    - Add gate hysteresis setup: "Enable Hysteresis, threshold -6 to -10 dB below main"
    - Add redundancy recording section: why raw backup matters, disk space considerations, sync/alignment workflow for recovery
    - Add metering recommendations: x42-meter (True Peak), Ardour built-in (EBU R128), Calf Analyzer (spectrum/phase)
    - **Status:** ✅ Done (preflight loudness check, gate hysteresis, redundancy, metering added)

10. **Implement documentation versioning**

    - Add version header to STUDIO.md: `**Document Version:** 2.0 | **Last Updated:** YYYY-MM-DD`
    - Add changelog section at end of document tracking major updates

- Note this revision as "v2.0: Consolidated documentation, standardized on software monitoring model"
- **Status:** ✅ Done (version header + changelog in STUDIO.md)

11. **Ensure markdown format compliance**
    - Max line length: 120 characters (`.markdownlint.yaml` MD013)
    - Ordered lists: sequential numbering 1. 2. 3. (`MD029: ordered`, `mdformat number = true`)
    - Tables: aligned pipe style (MD060), not compacted
    - Line endings: LF (`.editorconfig`, `.mdformat.toml`)

- Run `mdformat` on all modified files before committing
- **Status:** ✅ Done (mdformat run via nix-shell)

12. **Update [README.md](README.md) to reflect consolidated structure**
    - Remove references to separate research documents
    - Update "What's Inside" section to reflect single STUDIO.md with appendices
    - Simplify installation commands (remove TAP plugins)

- Update documentation links
- **Status:** ✅ Done (README updated to single STUDIO.md structure)

## Further instructions

- Use full power of markdown features (links, images, tables, code blocks)
- Update this review.plan.md for everthing done to keep track of progress (ane beeing able to later continue if interrupted)
- Use web/sourcemode/manual research online or via MCP Servers to clearify or lookup missing information or best practices by professional audio engineers
