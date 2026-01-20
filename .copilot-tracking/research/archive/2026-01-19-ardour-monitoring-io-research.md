# Ardour 8 Monitoring & I/O Configuration - Comprehensive Technical Report

**Research Date:** January 19, 2026\
**For:** SG9 Studio (Podcast/Broadcast Workflow)\
**DAW:** Ardour 8.x\
**Hardware:** Focusrite Vocaster Two with ALSA hardware mixer

______________________________________________________________________

## Executive Summary

This report provides comprehensive technical documentation on Ardour 8's monitoring features and I/O configuration modes (Flexible vs Strict I/O). Based on official documentation, source code analysis, and broadcast engineering best practices, specific recommendations are provided for the SG9 Studio setup.

**Key Recommendations for SG9 Studio:**

- **Monitoring Mode:** Use **Auto Input** monitoring with **Hardware Monitoring** model
- **I/O Mode:** Enable **Strict I/O** for all voice tracks
- **Hardware Integration:** Leverage Vocaster's zero-latency hardware mixer for monitoring
- **Track Monitoring:** Set tracks to **MonitorAuto** (default) to work seamlessly with Auto Input

______________________________________________________________________

## Part 1: Ardour Monitoring Features

### 1.1 Monitoring Model (Global Setting)

Ardour supports three primary monitoring models, configured globally in Preferences:

#### **Hardware Monitoring**

- **What it is:** Audio interface performs monitoring with zero/near-zero latency
- **How it works:** ALSA/JACK driver controls hardware mixer to route inputs to outputs
- **Latency:** Near-zero (only A/D/A conversion ~1.5-2ms)
- **Ardour's role:** Can control interface's hardware monitoring if driver supports it
- **Best for:** Professional recording with interfaces like Vocaster Two

#### **Software Monitoring**

- **What it is:** Ardour routes input signals through its mixer for monitoring
- **How it works:** Input signal passes through Ardour's processor chain before output
- **Latency:** System buffer size dependent (typically 5-20ms+)
- **Advantage:** Monitor signal includes all plugins/processing
- **Best for:** Overdubbing with effects, when latency is acceptable

#### **External Monitoring**

- **What it is:** Monitoring handled entirely outside Ardour (analog mixer, standalone monitor mixer)
- **How it works:** Ardour plays no role in monitoring
- **Latency:** Zero (pure analog path)
- **Best for:** Studios with dedicated monitor consoles

**SG9 Studio Configuration:**

```
Edit > Preferences > Signal Flow
Monitoring Model: Hardware Monitoring (via Audio Driver)
```

### 1.2 Track Monitoring Modes (Per-Track Setting)

Each track has a monitoring control with three modes:

#### **MonitorAuto (Default)**

- **Behavior:** Automatically switches between input and disk based on transport state
- **When Stopped + Track Armed:** Monitors input
- **When Playing + Track Armed:** Monitors disk (unless Auto Input enabled)
- **When Playing + Track Unarmed:** Always monitors disk
- **Best for:** Most recording workflows

#### **MonitorInput (Force Input)**

- **Behavior:** Always monitors input signal, regardless of transport/arm state
- **When Stopped:** Input
- **When Playing:** Input (even during playback)
- **Use case:** Live broadcast where you always want to hear mic
- **Caution:** You won't hear playback of recorded material

#### **MonitorDisk (Force Disk)**

- **Behavior:** Always monitors disk/playback signal

# Archived Research (Consolidated)

This research document has been consolidated into the appendices of [docs/STUDIO.md](../../../docs/STUDIO.md).
Please refer to the monitoring technical reference in the main manual for up-to-date guidance.

#### **MonitorCue (Sound-on-Sound Mode)**
