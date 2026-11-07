# VertexSlicer

A mixed-layer slicer for the Bambu Lab H2D.

VertexSlicer lets different parts of a print use different layer heights: fine walls with thick infill, or whole
regions (zones) printed finer or coarser than the rest. It writes a `.gcode.3mf` that Bambu Studio can preview and
send to the printer.

## Features

- Separate layer heights for walls/skin and infill, and per-zone heights, wall counts, infill density and pattern
- Zones from cylinders, boxes, picked faces or detected holes
- Bambu Studio printer, filament and process profiles, read straight from your Studio install
- Start, end and filament-change G-code rendered from the printer's own templates
- Multi-filament printing with AMS / AMS HT on either hotend, with a prime tower or purging into infill
- Concentric infill printed as one continuous sweep with its walls
- Supports, brim, skirt, cooling and volumetric speed limits
- Desktop app (egui) with layer preview, plus a command-line tool

## Building

Requires Rust (stable) and, on Windows, the MSVC build tools. Bambu Studio must be installed for its profiles.

```
cargo build --release
```

On the development machine the build goes through `build.ps1`, which loads the Visual Studio 2019 build environment
and closes a running copy of the app so its exe can be replaced:

```
.\build.ps1 build --release
```

This produces `target/release/vertexslicer` (the desktop app) and `target/release/vertexslicer-cli`.

## Status

Early and experimental. Check the G-code in Bambu Studio's preview before printing. See [ROADMAP.md](ROADMAP.md).

Not affiliated with or endorsed by Bambu Lab.

## License

[MIT](LICENSE)
