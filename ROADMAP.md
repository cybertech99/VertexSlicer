# Future features

**Status: parked.** Do not start these until the major edits to the current feature set are complete.

## Requested

### 1. Infill percentage per zone
*(DONE: per-zone **Solid infill** and per-zone **Infill %** (GUI field, `.mlsproj`, CLI `,infill=NN`). Verified on a washer: a 50% zone has ~4.8x the sparse line length of 10% with the outside unchanged.)*

Zones currently override only layer heights (wall/skin height and infill height). Add an optional infill
density to each zone, so a zone can be denser (e.g. a threaded hole at 60%) or lighter than the rest of the part.

- Engine: add `density: Option<f64>` to `Zone`/`Class` in `plan.rs`; the per-class block loop in `plan()` should use it
  in place of `cfg.density` when computing the sparse-infill line spacing.
- Watch the skin logic: a denser zone beside a sparse region should not change which areas count as solid.
- GUI: a "Infill %" field in each zone card, with "inherit" as the default. Save it in `.mlsproj`.
- CLI: extend the `--zone` syntax with an optional density.
- Test: a washer with a 50% hole zone and 10% outside; confirm line spacing differs only inside the zone.

### 2. AMS support
*(First version DONE 2026-11-05: slot list (GUI + CLI `--slot`), left/right hotend per slot, per-layer filament grouping (one change per layer), Studio's `change_filament_gcode` rendered per change (verified line-for-line against a Studio H2D two-nozzle export), multi-filament start G-code, rectangular prime tower with a fixed purge volume, colour-by-filament preview. Still open: flush-volume matrix, idle-nozzle pre-cooling (`M104 ... ;Multi extruder pre cooling`), slice_info filament list in the .3mf, purge into infill/support, verification on a real print.)*

Print from AMS slots instead of the single external filament.

- Filament slots: let the user map up to 4 filaments (per AMS unit) to the print; show them in the UI.
- Templates: feed the Bambu start/end/change-filament templates the real filament map, per-filament temperatures,
  flush volumes and `first_filaments` / `first_non_support_filaments` (currently single-filament defaults in
  `gcode_template.rs`).
- Filament change: emit `change_filament_gcode` at the right layers (`M620`/`M621` sequences come from the machine preset).
- Purge: flush volumes matrix, prime tower generation (currently "not generated"), and flush-into-infill options.
- Needs the real H2D multi-filament export from Bambu Studio to verify against, as was done for the single-filament start code.

### 3. A zone can use a different filament
*(Basic version DONE: each zone has a filament slot; ops are tagged and grouped per Z. Open: bonding/overlap at the boundary between two materials, per-zone temperature.)*

A zoned region prints in another filament (colour or material), e.g. a PETG thread in a PLA body.

- Depends on #2 (AMS / filament changes and purging).
- Planner: each zone gets a filament id; ops are tagged with it; within a layer, order ops so each filament prints once
  (minimise changes), and a change happens at most once per layer. Mixed layer heights make this harder because zones
  have different layer grids, so changes should be grouped per Z.
- Interfaces: wall overlap and bonding at the zone boundary between two filaments; optional purge into the infill.
- Per-zone temperature and cooling overrides follow from the filament.
- GUI: filament picker per zone; colour the preview by filament.

## Carried over from the current work

### Print quality
- Gap fill and thin walls (Arachne-style variable width), so features thinner than two lines still print.
- Avoid crossing walls on travel moves; reduce stringing and surface marks.
- Tree supports (profiles that ask for them currently get normal grid supports).
- Ironing for top surfaces; scarf or other seam options.
- Arc fitting (`G2`/`G3`) to shrink files and smooth curves.
- Per-region wall and infill *line* settings (not just layer heights).
- Outer-wall layer height as a separate setting from skin height.

### Printer support
- Dual-nozzle printing on the H2D (left and right hotends).
- Other Bambu printers and machine profiles beyond the H2D.
- Multi-object plates and auto-arrange; copies.

### Zones and editing
- Zones that follow a picked face's real outline instead of its bounding box.
- Freehand / painted zones, and zones from a slope or a set of faces.
- Z-range handles in the 3D view; drag to resize zones.
- Undo / redo.

### Export and workflow
- The exported `.gcode.3mf` still carries the old washer's thumbnail and metadata; generate a correct thumbnail,
  plate JSON and slice info.
- Calibrate the time estimate against real prints and Studio's numbers.
- Send to printer (LAN / cloud) from the app.
- Save custom presets back into Bambu Studio's user folder.
