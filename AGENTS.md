# SG9 Studio - AI Agent Instructions

> **Quick Start**: AI assistants should read [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for comprehensive project context.

## Overview

This repository manages SG9 Studio.

## Core Principles

## Essential Commands

## Available Agents

| Agent | Activation | Scope | Key Capabilities |
|-------|-----------|-------|------------------|
| **[Audio Engineer](.github/agents/brief/audio-engineer.md)** | `audio/**`, `clips/**`, `*.md` with keywords (`loudness`, `broadcast`, `ardour`) | Ardour sessions, loudness analysis, plugin chains, cue/clip workflows | Session template validation (48kHz, track hierarchy), plugin chain verification (HPF→Gate→De-esser→EQ→Compressor→Limiter), EBU R128 compliance checking (-16 LUFS for Apple Podcasts), cue/clip library management, mix-minus troubleshooting, emergency procedures |
| **[Systems Engineer](.github/agents/brief/systems-engineer.md)** | `scripts/**`, `midi_maps/**`, `*.lua`, `*.nix`, `*.map` | Lua scripting, MIDI controllers, NixOS packages, PipeWire/ALSA routing | Ardour Lua API scripting (adaptive polling, error recovery, session metadata), Generic MIDI bindings (Launchpad RGB LEDs, nanoKONTROL layers), NixOS package management (LSP/Calf/x42/ZAM plugins), ALSA Vocaster routing, hardware debugging |
| **[AI Engineer](.github/agents/brief/ai-engineer.md)** | `.github/**`, `.vscode/**`, `.copilot-tracking/**`, `.serena/**`, `mcp.json`, `*.instructions.md` | AI/LLM/MCP infrastructure management, agent lifecycle, documentation sync, code reviews | MCP server discovery & integration (awesome-mcp-servers ecosystem), agent definition management (create/maintain/optimize), Copilot instructions synchronization, tracking infrastructure optimization, AI code reviews, Serena MCP specialist (semantic code navigation), quarterly audits |

## MCP Servers (`.vscode/mcp.json`)

| Server | Capability | When to Use |
|--------|-----------|-------------|
| **mcp-nixos** | NixOS packages (130k+), options (23k+), Home Manager, FlakeHub | Plugin installation (`lsp-plugins`, `calf`, `x42-plugins`), system configuration, package search |
| **oraios/serena** | Semantic code navigation for Nix/Lua/Markdown | Symbol search, code refactoring, dependency analysis in scripts |
| **microsoft/markitdown** | Document-to-markdown conversion | Convert PDFs, DOCX to markdown documentation |
| **github** | Repository operations, issue/PR creation, code search | Search Ardour/ardour repository for Lua API examples, retrieve file content, issue tracking |
| **filesystem** | Workspace file operations (create/read/delete) | Session file management in `audio/sessions/`, template operations, clip library validation |
| **sequential-thinking** | Multi-step reasoning for complex problems | Audio processing troubleshooting (loudness, plugin chains), debugging MIDI routing issues |

## Key Documentation

- **Copilot instructions**: `.github/copilot-instructions.md` - Repository context, agent activation rules, MCP server list
- **Agent definitions**: `.github/agents/*.md` - Detailed per-agent capabilities and workflows
- [STUDIO.md](docs/STUDIO.md)
  - A Complete Setup Guide to Setup the Studio from Scratch (Hardware Setup and Ardour Template(s))
  - A Fine Tuning Guide for all important Filter Parameters
  - Serves as a Reference Guide for the studio
  - Appendices include monitoring and plugin technical references
