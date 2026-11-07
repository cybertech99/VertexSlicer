//! G-code generation: turns planned ops into per-layer moves, applies flow / cooling
//! limits, estimates time and filament, and writes Bambu-flavoured G-code.
use crate::geom::*;
use crate::plan::*;
use std::fmt::Write;

/// Everything needed to render the printer's own start/end G-code templates.
#[derive(Clone, Debug)]
pub struct TemplateSrc {
    /// merged machine + process + filament settings
    pub all: crate::bbl::Settings,
    pub start: String,
    pub end: String,
    pub bed_type: String,
    /// the printer's change_filament_gcode template
    pub change: String,
}

/// Prime (wipe) tower used to purge the nozzle after a filament change.
#[derive(Clone, Debug)]
pub struct TowerCfg {
    pub enable: bool,
    pub x: f64,
    pub y: f64,
    pub w: f64,
    pub d: f64,
    /// plastic purged per change, mm^3 (half before the change, half after)
    pub purge_mm3: f64,
    /// purge into the part's sparse infill first; the tower only takes what infill can't
    pub purge_into_infill: bool,
}

impl Default for TowerCfg {
    fn default() -> Self {
        // position and size of the tower Bambu Studio picked for the H2D reference print
        TowerCfg { enable: true, x: 178.5, y: 195.1, w: 30.0, d: 28.0, purge_mm3: 80.0, purge_into_infill: false }
    }
}

#[derive(Clone, Debug)]
pub struct Speeds {
    pub outer: f64,
    pub inner: f64,
    pub overhang: f64,
    pub bridge: f64,
    pub solid: f64,
    pub top: f64,
    pub sparse: f64,
    pub support: f64,
    pub support_interface: f64,
    pub first: f64,
    pub first_infill: f64,
    pub travel: f64,
}

#[derive(Clone, Debug)]
pub struct Accels {
    pub default: f64,
    pub outer: f64,
    pub inner: f64,
    pub top: f64,
    pub sparse: f64,
    pub bridge: f64,
    pub first: f64,
    pub travel: f64,
}

#[derive(Clone, Debug)]
pub struct Fan {
    /// percentages 0..100
    pub min: f64,
    pub max: f64,
    pub aux: f64,
    pub overhang: f64,
    pub close_first: u32,
    pub full_layer: u32,
    /// layers estimated shorter than this are slowed down (s)
    pub slow_layer_time: f64,
    pub min_print_speed: f64,
    /// layers shorter than this get fan between min and max (s)
    pub cooling_layer_time: f64,
    pub slow_down: bool,
}

#[derive(Clone, Debug)]
pub struct Printer {
    pub bed_x: f64,
    pub bed_y: f64,
    pub max_z: f64,
    pub filament_dia: f64,
    pub filament_density: f64,
    pub filament_cost: f64,
    pub nozzle_temp: u32,
    pub nozzle_temp_first: u32,
    pub bed_temp: u32,
    pub bed_temp_first: u32,
    pub chamber_temp: u32,
    pub filament_type: String,
    pub flow_ratio: f64,
    pub bridge_flow: f64,
    pub retract: f64,
    pub retract_speed: f64,
    pub deretract_speed: f64,
    pub retract_min_travel: f64,
    pub z_hop: f64,
    pub wipe: bool,
    pub wipe_distance: f64,
    pub speed: Speeds,
    pub accel: Accels,
    /// mm^3/s
    pub max_volumetric: f64,
    pub fan: Fan,
    /// explicit override files (take priority over the template)
    pub start_gcode: Option<String>,
    pub end_gcode: Option<String>,
    /// printer-supplied templates, rendered per print
    pub tpl: Option<TemplateSrc>,
    /// filament slots of a multi-filament print; empty = single filament
    pub slots: Vec<crate::gcode_template::SlotInfo>,
    pub tower: TowerCfg,
}

impl Printer {
    /// Bambu Lab H2D defaults (used when no profile is imported).
    pub fn h2d() -> Printer {
        Printer {
            bed_x: 350.0,
            bed_y: 320.0,
            max_z: 325.0,
            filament_dia: 1.75,
            filament_density: 1.24,
            filament_cost: 20.0,
            nozzle_temp: 260,
            nozzle_temp_first: 260,
            bed_temp: 100,
            bed_temp_first: 100,
            chamber_temp: 60,
            filament_type: "ASA".into(),
            flow_ratio: 1.0,
            bridge_flow: 1.0,
            retract: 0.8,
            retract_speed: 30.0,
            deretract_speed: 30.0,
            retract_min_travel: 1.0,
            z_hop: 0.4,
            wipe: true,
            wipe_distance: 2.0,
            speed: Speeds {
                outer: 80.0,
                inner: 120.0,
                overhang: 50.0,
                bridge: 50.0,
                solid: 100.0,
                top: 100.0,
                sparse: 150.0,
                support: 100.0,
                support_interface: 60.0,
                first: 40.0,
                first_infill: 60.0,
                travel: 300.0,
            },
            accel: Accels { default: 8000.0, outer: 5000.0, inner: 8000.0, top: 2000.0, sparse: 8000.0, bridge: 5000.0, first: 500.0, travel: 10000.0 },
            max_volumetric: 20.0,
            fan: Fan { min: 60.0, max: 100.0, aux: 0.0, overhang: 100.0, close_first: 1, full_layer: 0, slow_layer_time: 4.0, min_print_speed: 20.0, cooling_layer_time: 100.0, slow_down: true },
            start_gcode: None,
            end_gcode: None,
            tpl: None,
            slots: vec![],
            tower: TowerCfg::default(),
        }
    }
}

#[derive(Default, Debug, Clone)]
pub struct Stats {
    pub layers: usize,
    /// (layer height mm x1000) -> number of ops
    pub by_height: std::collections::BTreeMap<i64, usize>,
    pub filament_mm: f64,
    /// estimated print time, seconds
    pub seconds: f64,
    pub weight_g: f64,
    pub cost: f64,
    pub layer_seconds: Vec<f64>,
    /// number of layers that were slowed for cooling
    pub slowed_layers: usize,
    pub warnings: Vec<String>,
    pub tool_changes: usize,
    /// the prime tower actually printed (after any automatic move); None = no tower
    pub tower: Option<TowerCfg>,
    /// filament used per slot, mm (indexed by slot)
    pub slot_mm: Vec<f64>,
}

fn dist(a: Pt, b: Pt) -> f64 {
    ((a.0 - b.0).powi(2) + (a.1 - b.1).powi(2)).sqrt()
}

/// Seam vertex of a closed loop: the point furthest toward the back-left, so every layer's seam
/// stacks into one clean line instead of scattering blobs over the wall.
fn seam_vertex(p: &Poly) -> usize {
    (0..p.len()).max_by(|&a, &b| (p[a].1 - p[a].0).partial_cmp(&(p[b].1 - p[b].0)).unwrap()).unwrap_or(0)
}

/// Greedy nearest-neighbour ordering; closed loops are rotated to start at the nearest vertex
/// (or at the aligned seam vertex for walls).
fn order(paths: &[(Poly, bool)], mut pos: Pt, aligned_seam: bool) -> Vec<(Poly, bool)> {
    let mut left: Vec<(Poly, bool)> = paths.to_vec();
    let mut out = vec![];
    while !left.is_empty() {
        let mut best = (f64::MAX, 0usize, 0usize, false);
        for (i, (p, closed)) in left.iter().enumerate() {
            if p.is_empty() {
                continue;
            }
            if *closed {
                if aligned_seam {
                    let j = seam_vertex(p);
                    let d = dist(pos, p[j]);
                    if d < best.0 {
                        best = (d, i, j, false);
                    }
                    continue;
                }
                for (j, &q) in p.iter().enumerate() {
                    let d = dist(pos, q);
                    if d < best.0 {
                        best = (d, i, j, false);
                    }
                }
            } else {
                let d0 = dist(pos, p[0]);
                let d1 = dist(pos, *p.last().unwrap());
                if d0 < best.0 {
                    best = (d0, i, 0, false);
                }
                if d1 < best.0 {
                    best = (d1, i, 0, true);
                }
            }
        }
        let (_, i, j, rev) = best;
        let (mut p, closed) = left.swap_remove(i);
        if p.is_empty() {
            continue;
        }
        if closed {
            p.rotate_left(j);
            p.push(p[0]);
        } else if rev {
            p.reverse();
        }
        pos = *p.last().unwrap();
        out.push((p, closed));
    }
    out
}

enum Item {
    Travel { to: Pt, len: f64, retract: bool, hop: bool, first_of_layer: bool, short_infill: bool },
    /// `flush_mm3`: what the printer must purge itself (no tower / not enough infill)
    Tool { from: usize, to: usize, count: u32, flush_mm3: f64 },
    Path { kind: Kind, pts: Poly, len: f64, e_per_mm: f64, speed: f64, accel: f64, width: f64, height: f64, new_feature: bool, fan_override: bool },
}

struct Layer {
    z: f64,
    height: f64,
    items: Vec<Item>,
    seconds: f64,
    fan_pct: f64,
}

fn move_time(len: f64, v: f64, a: f64) -> f64 {
    if len <= 0.0 || v <= 0.0 {
        return 0.0;
    }
    let ramp = v * v / a.max(100.0);
    if len >= ramp { len / v + v / a.max(100.0) } else { 2.0 * (len / a.max(100.0)).sqrt() }
}

fn accel_for(kind: Kind, first: bool, a: &Accels) -> f64 {
    if first {
        return a.first;
    }
    match kind {
        Kind::OuterWall | Kind::OverhangWall => a.outer,
        Kind::InnerWall => a.inner,
        Kind::Top => a.top,
        Kind::Sparse | Kind::Support | Kind::SupportInterface => a.sparse,
        Kind::Bridge => a.bridge,
        _ => a.default,
    }
}

fn speed_for(kind: Kind, first: bool, s: &Speeds) -> f64 {
    if first {
        return match kind {
            Kind::Solid | Kind::Sparse | Kind::Top | Kind::Bridge => s.first_infill,
            _ => s.first,
        };
    }
    match kind {
        Kind::OuterWall => s.outer,
        Kind::InnerWall => s.inner,
        Kind::OverhangWall => s.overhang,
        Kind::Bridge => s.bridge,
        Kind::Solid => s.solid,
        Kind::Top => s.top,
        Kind::Sparse => s.sparse,
        Kind::Support => s.support,
        Kind::SupportInterface => s.support_interface,
        Kind::Skirt | Kind::Brim => s.first,
        Kind::Prime => s.sparse.min(60.0),
    }
}

/// Zigzag purge rows inside the tower; `vol` mm^3 of plastic at layer height `h`.
fn tower_zigzag(t: &TowerCfg, vol: f64, h: f64, from_top: bool) -> Vec<(Poly, bool)> {
    let (sp, line_w) = (1.2, 1.0);
    let usable = (t.w - 2.0).max(1.0);
    let rows_max = (((t.d - 2.0) / sp).floor() as usize).max(1);
    let rows = ((vol / (line_w * h.max(0.05)) / usable).ceil() as usize).clamp(1, rows_max);
    let (x0, x1) = (t.x + 1.0, t.x + t.w - 1.0);
    let mut pts = vec![];
    for r in 0..rows {
        let y = if from_top { t.y + t.d - 1.0 - r as f64 * sp } else { t.y + 1.0 + r as f64 * sp };
        if r % 2 == 0 {
            pts.push((x0, y));
            pts.push((x1, y));
        } else {
            pts.push((x1, y));
            pts.push((x0, y));
        }
    }
    vec![(pts, false)]
}

fn tower_outline(t: &TowerCfg) -> Vec<(Poly, bool)> {
    let i = 0.25;
    vec![(vec![(t.x + i, t.y + i), (t.x + t.w - i, t.y + i), (t.x + t.w - i, t.y + t.d - i), (t.x + i, t.y + t.d - i)], true)]
}

/// Sparse diagonal fill for tower layers that have no filament change.
/// The first layer is filled solid so the tower sticks to the plate.
fn tower_fill(t: &TowerCfg, layer: usize) -> Vec<(Poly, bool)> {
    let rect: Polys = vec![vec![(t.x + 0.8, t.y + 0.8), (t.x + t.w - 0.8, t.y + 0.8), (t.x + t.w - 0.8, t.y + t.d - 0.8), (t.x + 0.8, t.y + t.d - 0.8)]];
    let a = (45.0 + 90.0 * (layer % 2) as f64).to_radians();
    let spacing = if layer == 0 { 0.5 } else { 5.0 };
    fill_lines(&rect, spacing, a).into_iter().map(|l| (l.to_vec(), false)).collect()
}

/// Start and end G-code. Priority: explicit override files, then the printer template
/// rendered with this print's facts, then the static sample extracted from Bambu Studio.
/// Filament slots in order of first use.
fn used_slots(ops: &[Op]) -> Vec<usize> {
    let mut v: Vec<usize> = vec![];
    for o in ops {
        if !v.contains(&(o.filament as usize)) {
            v.push(o.filament as usize);
        }
    }
    v
}

fn machine_gcode(ops: &[Op], pr: &Printer, total_layers: usize, seconds: f64, warnings: &mut Vec<String>) -> (String, String) {
    let sample = |pr: &Printer| {
        let start = include_str!("../../../profiles/h2d_start.gcode")
            .replace("{nozzle}", &pr.nozzle_temp_first.to_string())
            .replace("{bed}", &pr.bed_temp_first.to_string())
            .replace("{chamber}", &pr.chamber_temp.to_string())
            .replace("{ftype}", &pr.filament_type);
        (start, include_str!("../../../profiles/h2d_end.gcode").to_string())
    };
    let (mut start, mut end) = match &pr.tpl {
        Some(t) => {
            // first-layer footprint (used by the printer's bed-leveling / flush logic)
            let (mut x0, mut y0, mut x1, mut y1) = (f64::MAX, f64::MAX, f64::MIN, f64::MIN);
            for o in ops.iter().filter(|o| o.first) {
                for (p, _) in &o.paths {
                    for q in p {
                        x0 = x0.min(q.0);
                        y0 = y0.min(q.1);
                        x1 = x1.max(q.0);
                        y1 = y1.max(q.1);
                    }
                }
            }
            if x0 > x1 {
                (x0, y0, x1, y1) = (0.0, 0.0, 0.0, 0.0);
            }
            let rt = crate::gcode_template::Runtime {
                max_print_z: ops.iter().map(|o| o.z_top).fold(0.0, f64::max),
                first_layer_min: (x0, y0),
                first_layer_size: (x1 - x0, y1 - y0),
                bed_type: t.bed_type.clone(),
                total_layers,
                slots: pr.slots.clone(),
                used_slots: used_slots(ops),
            };
            let get = |k: &str, i: usize| crate::bbl::get_f_idx(&t.all, k, i).unwrap_or(0.0);
            let limits = format!(
                "M201 X{} Y{} Z{} E{}\nM203 X{} Y{} Z{} E{}\nM204 P{} R{} T{}\nM205 X{:.2} Y{:.2} Z{:.2} E{:.2}\n",
                get("machine_max_acceleration_x", 0), get("machine_max_acceleration_y", 0), get("machine_max_acceleration_z", 0), get("machine_max_acceleration_e", 0),
                get("machine_max_speed_x", 0), get("machine_max_speed_y", 0), get("machine_max_speed_z", 0), get("machine_max_speed_e", 0),
                get("machine_max_acceleration_extruding", 0), get("machine_max_acceleration_retracting", 0), get("machine_max_acceleration_extruding", 0),
                get("machine_max_jerk_x", 0), get("machine_max_jerk_y", 0), get("machine_max_jerk_z", 0), get("machine_max_jerk_e", 0),
            );
            let remaining = (seconds / 60.0).ceil();
            match (crate::gcode_template::render(&t.start, &t.all, &rt), crate::gcode_template::render(&t.end, &t.all, &rt)) {
                (Ok(a), Ok(b)) => (
                    format!("M73 P0 R{:.0}\n{}M106 S0\nM106 P2 S0\n; FEATURE: Custom\n{}\n; MACHINE_START_GCODE_END\n", remaining, limits, a),
                    format!("; MACHINE_END_GCODE_START\n; filament end gcode \n{}\nM141 S0;set chamber_temperature\nM73 P100 R0\n; EXECUTABLE_BLOCK_END\n", b),
                ),
                (a, b) => {
                    for e in [a.err(), b.err()].into_iter().flatten() {
                        warnings.push(format!("start/end template failed ({e}); used the static Bambu sample instead"));
                    }
                    sample(pr)
                }
            }
        }
        None => sample(pr),
    };
    if let Some(s) = &pr.start_gcode {
        start = s.clone();
    }
    if let Some(e) = &pr.end_gcode {
        end = e.clone();
    }
    (start, end)
}

pub fn write(ops: &[Op], _cfg: &Config, pr: &Printer, _center: Pt) -> (String, Stats) {
    let mut st = Stats::default();
    let fil_area = std::f64::consts::PI * (pr.filament_dia / 2.0).powi(2);

    // ---------- pass 1: moves per layer ----------
    /// Builds the move list for one layer, tracking where the nozzle is.
    struct Emit {
        items: Vec<Item>,
        pos: Pt,
        have_pos: bool,
        first_of_layer: bool,
        prev_kind: Option<Kind>,
    }
    impl Emit {
        fn op(&mut self, kind: Kind, first: bool, width: f64, height: f64, paths: &[(Poly, bool)], pr: &Printer, fil_area: f64) {
            let wall = matches!(kind, Kind::OuterWall | Kind::InnerWall | Kind::OverhangWall);
            let mut speed = speed_for(kind, first, &pr.speed);
            // volumetric flow limit
            let area = bead_area(width, height);
            if pr.max_volumetric > 0.0 {
                speed = speed.min(pr.max_volumetric / area);
            }
            let flow = if kind == Kind::Bridge { pr.bridge_flow } else { 1.0 };
            let e_per_mm = area * pr.flow_ratio * flow / fil_area;
            let accel = accel_for(kind, first, &pr.accel);
            let fan_override = matches!(kind, Kind::OverhangWall | Kind::Bridge | Kind::SupportInterface);
            let mut new_feature = true;
            for (p, _closed) in order(paths, if self.have_pos { self.pos } else { (0.0, 0.0) }, wall) {
                let start = p[0];
                let d = if self.have_pos { dist(self.pos, start) } else { f64::MAX };
                if d > 0.01 || self.first_of_layer {
                    // Short hops between lines of the same infill never cross a wall and are hidden
                    // inside the part: no retraction, no z-hop, no acceleration switch.
                    let infill_kind = matches!(kind, Kind::Sparse | Kind::Solid | Kind::Top | Kind::Bridge | Kind::Support | Kind::SupportInterface);
                    let short_infill = infill_kind && self.prev_kind == Some(kind) && d < 8.0 && !self.first_of_layer;
                    let long = !short_infill && (d > pr.retract_min_travel || self.first_of_layer);
                    self.items.push(Item::Travel { to: start, len: if self.have_pos { d } else { 0.0 }, retract: long, hop: long && pr.z_hop > 0.0, first_of_layer: self.first_of_layer, short_infill });
                }
                self.prev_kind = Some(kind);
                self.first_of_layer = false;
                // drop near-zero segments (they crash Bambu Studio's preview mesher); keep the closing point
                let mut pts = vec![start];
                let mut last = start;
                let n_pts = p.len();
                let mut len = 0.0;
                for (qi, q) in p.iter().enumerate().skip(1) {
                    let l = dist(last, *q);
                    if l < 0.05 && !(qi == n_pts - 1 && l > 0.005) {
                        continue;
                    }
                    len += l;
                    pts.push(*q);
                    last = *q;
                }
                if pts.len() >= 2 {
                    self.items.push(Item::Path { kind, pts, len, e_per_mm, speed, accel, width, height, new_feature, fan_override });
                    new_feature = false;
                }
                self.pos = last;
                self.have_pos = true;
            }
        }
    }

    /// A wall path together with where it sits in its contour.
    struct WallPath<'a> {
        path: &'a (Poly, bool),
        idx: u32,
        kind: Kind,
        first: bool,
        width: f64,
        height: f64,
    }
    /// How far the nozzle must travel to start the innermost loop of a contour.
    fn entry_dist(v: &[WallPath], pos: Pt) -> f64 {
        let inner = v.iter().map(|w| w.idx).max().unwrap_or(0);
        v.iter()
            .filter(|w| w.idx == inner)
            .map(|w| {
                let (p, closed) = w.path;
                if p.is_empty() {
                    f64::MAX
                } else if *closed {
                    dist(pos, p[seam_vertex(p)])
                } else {
                    dist(pos, p[0]).min(dist(pos, *p.last().unwrap()))
                }
            })
            .fold(f64::MAX, f64::min)
    }

    let mut layers: Vec<Layer> = vec![];
    let mut pos: Pt = (0.0, 0.0);
    let mut have_pos = false;
    // group ops into layers (same top Z)
    let mut ranges: Vec<(usize, usize)> = vec![];
    {
        let mut i = 0;
        while i < ops.len() {
            let z = ops[i].z_top;
            let mut j = i;
            while j < ops.len() && (ops[j].z_top - z).abs() < 1e-6 {
                j += 1;
            }
            ranges.push((i, j));
            i = j;
        }
    }
    let first_fil = ops.first().map(|o| o.filament).unwrap_or(0);
    let multi = !pr.slots.is_empty() && ops.iter().any(|o| o.filament != first_fil);
    // the tower is printed on every layer up to the last one that has a filament change
    let mut last_change: Option<usize> = None;
    {
        let mut cur = first_fil;
        for (gi, &(a, b)) in ranges.iter().enumerate() {
            for o in &ops[a..b] {
                if o.filament != cur {
                    last_change = Some(gi);
                    cur = o.filament;
                }
            }
        }
    }
    let tower_to = if multi && pr.tower.enable { last_change } else { None };
    // keep the prime tower off the part: if it overlaps the model, move it to the first free spot
    let mut tower = pr.tower.clone();
    if tower_to.is_some() {
        let (mut x0, mut y0, mut x1, mut y1) = (f64::MAX, f64::MAX, f64::MIN, f64::MIN);
        for o in ops {
            for (p, _) in &o.paths {
                for q in p {
                    x0 = x0.min(q.0);
                    y0 = y0.min(q.1);
                    x1 = x1.max(q.0);
                    y1 = y1.max(q.1);
                }
            }
        }
        let gap = 6.0;
        let hits = |t: &TowerCfg| t.x < x1 + gap && t.x + t.w > x0 - gap && t.y < y1 + gap && t.y + t.d > y0 - gap;
        let fits = |t: &TowerCfg| t.x >= 5.0 && t.y >= 5.0 && t.x + t.w <= pr.bed_x - 5.0 && t.y + t.d <= pr.bed_y - 5.0;
        if x0 <= x1 && hits(&tower) {
            let (w, d) = (tower.w, tower.d);
            let cy = ((y0 + y1) / 2.0 - d / 2.0).clamp(5.0, (pr.bed_y - 5.0 - d).max(5.0));
            let cx = ((x0 + x1) / 2.0 - w / 2.0).clamp(5.0, (pr.bed_x - 5.0 - w).max(5.0));
            let candidates = [(x1 + gap + 2.0, cy), (x0 - gap - 2.0 - w, cy), (cx, y1 + gap + 2.0), (cx, y0 - gap - 2.0 - d), (pr.bed_x - 5.0 - w, pr.bed_y - 5.0 - d), (5.0, pr.bed_y - 5.0 - d), (pr.bed_x - 5.0 - w, 5.0), (5.0, 5.0)];
            match candidates.iter().map(|&(x, y)| TowerCfg { x, y, ..tower.clone() }).find(|t| fits(t) && !hits(t)) {
                Some(t) => {
                    st.warnings.push(format!("prime tower moved to X{:.0} Y{:.0} because it overlapped the model", t.x, t.y));
                    tower = t;
                }
                None => st.warnings.push("the prime tower overlaps the model and there is no free spot on the plate for it".into()),
            }
        }
        st.tower = Some(tower.clone());
    }
    let mut cur_fil = first_fil;
    let mut toolchanges = 0u32;
    let mut prev_z = 0.0f64;
    for (gi, &(ra, rb)) in ranges.iter().enumerate() {
        let layer_ops = &ops[ra..rb];
        let z = layer_ops[0].z_top;
        let height = layer_ops.iter().map(|o| o.height).fold(f64::MAX, f64::min);
        let tower_h = z - prev_z;
        let mut em = Emit { items: vec![], pos, have_pos, first_of_layer: true, prev_kind: None };
        for op in layer_ops {
            *st.by_height.entry((op.height * 1000.0).round() as i64).or_default() += 1;
        }
        let mut changed = false;
        // one run of consecutive ops per filament
        let mut rs = 0;
        while rs < layer_ops.len() {
            let mut re = rs + 1;
            while re < layer_ops.len() && layer_ops[re].filament == layer_ops[rs].filament {
                re += 1;
            }
            let group = &layer_ops[rs..re];
            rs = re;
            // sparse-infill paths already printed as purge right after a change: (op index, path index)
            let mut purged: std::collections::HashSet<(usize, usize)> = std::collections::HashSet::new();
            if multi && group[0].filament != cur_fil {
                toolchanges += 1;
                changed = true;
                let tw = &tower;
                let want = tw.purge_mm3;
                // Purge into infill: pick sparse-infill lines nearest the middle of this filament's
                // infill until the purge volume is used up.
                let mut infill_vol = 0.0;
                if tw.purge_into_infill {
                    let mut cand: Vec<(usize, usize, f64, (f64, f64))> = vec![];
                    let (mut sx, mut sy, mut sn) = (0.0, 0.0, 0.0);
                    for (oi, op) in group.iter().enumerate().filter(|(_, o)| o.kind == Kind::Sparse && !o.sweep) {
                        let area = bead_area(op.width, op.height);
                        for (pi, (p, _)) in op.paths.iter().enumerate() {
                            if p.len() < 2 {
                                continue;
                            }
                            let len: f64 = p.windows(2).map(|w| dist(w[0], w[1])).sum();
                            let mid = p[p.len() / 2];
                            sx += mid.0;
                            sy += mid.1;
                            sn += 1.0;
                            cand.push((oi, pi, len * area, mid));
                        }
                    }
                    if sn > 0.0 {
                        let c = (sx / sn, sy / sn);
                        cand.sort_by(|a, b| dist(a.3, c).partial_cmp(&dist(b.3, c)).unwrap());
                        for (oi, pi, vol, _) in cand {
                            if infill_vol >= want {
                                break;
                            }
                            purged.insert((oi, pi));
                            infill_vol += vol;
                        }
                    }
                }
                let rest = (want - infill_vol).max(0.0);
                let use_tower = tower_to.is_some();
                if use_tower && !tw.purge_into_infill {
                    em.op(Kind::Prime, gi == 0, 1.0, tower_h, &tower_zigzag(tw, want * 0.5, tower_h, gi % 2 == 1), pr, fil_area);
                }
                // without a tower the printer flushes whatever the infill could not take
                let flush_mm3 = if use_tower { 0.0 } else { rest };
                em.items.push(Item::Tool { from: cur_fil as usize, to: group[0].filament as usize, count: toolchanges, flush_mm3 });
                em.prev_kind = None;
                cur_fil = group[0].filament;
                // the purge itself: infill first (new filament pushes the old one out into hidden infill)
                for (oi, op) in group.iter().enumerate().filter(|(_, o)| o.kind == Kind::Sparse) {
                    let paths: Vec<(Poly, bool)> = op.paths.iter().enumerate().filter(|(pi, _)| purged.contains(&(oi, *pi))).map(|(_, p)| p.clone()).collect();
                    if !paths.is_empty() {
                        em.op(op.kind, op.first, op.width, op.height, &paths, pr, fil_area);
                    }
                }
                if use_tower {
                    let tower_rest = if tw.purge_into_infill { rest } else { want * 0.5 };
                    if tower_rest > 1.0 {
                        em.op(Kind::Prime, gi == 0, 1.0, tower_h, &tower_zigzag(tw, tower_rest, tower_h, gi % 2 == 0), pr, fil_area);
                    }
                    em.op(Kind::Prime, gi == 0, 0.5, tower_h, &tower_outline(tw), pr, fil_area);
                    if tw.purge_into_infill && tower_rest <= 1.0 {
                        // nothing left to purge: keep the tower layer as a light frame
                        em.op(Kind::Prime, gi == 0, 0.5, tower_h, &tower_fill(tw, gi), pr, fil_area);
                    }
                }
            }
            // a closed loop: wall loops, or concentric rings (open polylines that end where they start)
            let is_loop = |p: &Poly, closed: bool| closed || (p.len() > 3 && dist(p[0], *p.last().unwrap()) < 0.05);
            // 1. skirt / brim / supports
            for op in group.iter().filter(|o| o.kind < Kind::InnerWall) {
                em.op(op.kind, op.first, op.width, op.height, &op.paths, pr, fil_area);
            }
            // 2. walls: one contour at a time, its loops printed together from the inside out
            let mut chains: std::collections::BTreeMap<u32, Vec<WallPath>> = std::collections::BTreeMap::new();
            let mut loose: Vec<&Op> = vec![];
            for op in group.iter().filter(|o| !o.sweep && matches!(o.kind, Kind::InnerWall | Kind::OuterWall | Kind::OverhangWall)) {
                if !op.chain.is_empty() && op.chain.len() == op.paths.len() {
                    for (k, path) in op.paths.iter().enumerate() {
                        chains.entry(op.chain[k]).or_default().push(WallPath { path, idx: op.wall_idx, kind: op.kind, first: op.first, width: op.width, height: op.height });
                    }
                } else {
                    loose.push(op);
                }
            }
            while !chains.is_empty() {
                // continue with the contour that is closest to where the nozzle is
                let key = *chains.iter().map(|(k, v)| (k, entry_dist(v, em.pos))).min_by(|a, b| a.1.partial_cmp(&b.1).unwrap()).unwrap().0;
                let mut v = chains.remove(&key).unwrap();
                v.sort_by(|a, b| b.idx.cmp(&a.idx).then(a.kind.cmp(&b.kind)));
                let mut s0 = 0;
                while s0 < v.len() {
                    let mut e0 = s0 + 1;
                    while e0 < v.len() && v[e0].idx == v[s0].idx && v[e0].kind == v[s0].kind {
                        e0 += 1;
                    }
                    let paths: Vec<(Poly, bool)> = v[s0..e0].iter().map(|w| w.path.clone()).collect();
                    em.op(v[s0].kind, v[s0].first, v[s0].width, v[s0].height, &paths, pr, fil_area);
                    s0 = e0;
                }
            }
            for op in loose {
                em.op(op.kind, op.first, op.width, op.height, &op.paths, pr, fil_area);
            }
            // 2b. concentric regions: walls, zone walls and infill rings are all loops, so print them as
            // one sweep from the innermost loop outward, always moving on to the nearest next loop
            {
                let mut loops: Vec<(&Op, &(Poly, bool))> = vec![];
                for op in group.iter().filter(|o| o.sweep) {
                    for pc in op.paths.iter().filter(|pc| !pc.0.is_empty() && is_loop(&pc.0, pc.1)) {
                        loops.push((op, pc));
                    }
                }
                if !loops.is_empty() {
                    let near = |p: &Poly, q: Pt| p.iter().map(|v| dist(*v, q)).fold(f64::MAX, f64::min);
                    let mut left: Vec<usize> = (0..loops.len()).collect();
                    let mut k = (0..left.len()).min_by(|&a, &b| area(&loops[a].1 .0).abs().partial_cmp(&area(&loops[b].1 .0).abs()).unwrap()).unwrap();
                    loop {
                        let (op, pc) = loops[left.swap_remove(k)];
                        em.op(op.kind, op.first, op.width, op.height, std::slice::from_ref(pc), pr, fil_area);
                        if left.is_empty() {
                            break;
                        }
                        let pos = em.pos;
                        k = (0..left.len()).min_by(|&a, &b| near(&loops[left[a]].1 .0, pos).partial_cmp(&near(&loops[left[b]].1 .0, pos)).unwrap()).unwrap();
                    }
                }
            }
            // 3. bridges, solid, top, sparse infill (minus infill already printed as purge, and minus
            // rings already printed in a concentric sweep)
            for (oi, op) in group.iter().enumerate().filter(|(_, o)| o.kind > Kind::OverhangWall || o.sweep) {
                if op.sweep {
                    let paths: Vec<(Poly, bool)> = op.paths.iter().filter(|pc| !pc.0.is_empty() && !is_loop(&pc.0, pc.1)).cloned().collect();
                    if !paths.is_empty() {
                        em.op(op.kind, op.first, op.width, op.height, &paths, pr, fil_area);
                    }
                } else if purged.is_empty() || op.kind != Kind::Sparse {
                    em.op(op.kind, op.first, op.width, op.height, &op.paths, pr, fil_area);
                } else {
                    let paths: Vec<(Poly, bool)> = op.paths.iter().enumerate().filter(|(pi, _)| !purged.contains(&(oi, *pi))).map(|(_, p)| p.clone()).collect();
                    if !paths.is_empty() {
                        em.op(op.kind, op.first, op.width, op.height, &paths, pr, fil_area);
                    }
                }
            }
        }
        // layers without a change still print the tower so it stays a solid column
        if let Some(t) = tower_to {
            if gi <= t && !changed {
                let tw = &tower;
                em.op(Kind::Prime, gi == 0, 0.5, tower_h, &tower_outline(tw), pr, fil_area);
                em.op(Kind::Prime, gi == 0, 0.5, tower_h, &tower_fill(tw, gi), pr, fil_area);
            }
        }
        prev_z = z;
        pos = em.pos;
        have_pos = em.have_pos;
        layers.push(Layer { z, height, items: em.items, seconds: 0.0, fan_pct: 0.0 });
    }
    st.tool_changes = toolchanges as usize;
    let total_layers = layers.len();

    // ---------- pass 2: layer times, cooling slowdown, fan ----------
    let travel_time = |len: f64, retract: bool, hop: bool| -> f64 {
        let mut t = move_time(len, pr.speed.travel, pr.accel.travel);
        if retract {
            t += 2.0 * pr.retract / pr.retract_speed.max(1.0);
        }
        if hop {
            t += 2.0 * pr.z_hop / 20.0;
        }
        t
    };
    for (li, layer) in layers.iter_mut().enumerate() {
        let calc = |layer: &Layer| -> (f64, f64) {
            let (mut tt, mut tp) = (0.0, 0.0);
            for it in &layer.items {
                match it {
                    Item::Travel { len, retract, hop, .. } => tt += travel_time(*len, *retract, *hop),
                    Item::Path { len, speed, accel, .. } => tp += move_time(*len, *speed, *accel),
                    // retract, cut, swap and re-load take the printer a while
                    Item::Tool { .. } => tt += 40.0,
                }
            }
            (tt, tp)
        };
        let (tt, tp) = calc(layer);
        let mut total = tt + tp;
        if pr.fan.slow_down && li > 0 && total < pr.fan.slow_layer_time && tp > 0.0 {
            let want_tp = (pr.fan.slow_layer_time - tt).max(tp);
            let f = tp / want_tp; // < 1
            for it in layer.items.iter_mut() {
                if let Item::Path { speed, .. } = it {
                    *speed = (*speed * f).max(pr.fan.min_print_speed.min(*speed));
                }
            }
            let (tt2, tp2) = calc(layer);
            total = tt2 + tp2;
            st.slowed_layers += 1;
        }
        layer.seconds = total;
        // fan
        let n = li + 1;
        let f = &pr.fan;
        let mut pct = if total >= f.cooling_layer_time {
            f.min
        } else if total <= f.slow_layer_time {
            f.max
        } else {
            let t = (f.cooling_layer_time - total) / (f.cooling_layer_time - f.slow_layer_time).max(1e-6);
            f.min + (f.max - f.min) * t
        };
        if n as u32 <= f.close_first {
            pct = 0.0;
        } else if f.full_layer > 0 && (n as u32) < f.full_layer {
            let ramp = (n as u32 - f.close_first) as f64 / (f.full_layer - f.close_first).max(1) as f64;
            pct *= ramp.clamp(0.0, 1.0);
        }
        layer.fan_pct = pct;
    }
    st.seconds = layers.iter().map(|l| l.seconds).sum();
    st.layer_seconds = layers.iter().map(|l| l.seconds).collect();
    st.layers = total_layers;

    // ---------- pass 3: emit ----------
    let mut g = String::new();
    let (start, end_gcode) = machine_gcode(ops, pr, total_layers, st.seconds, &mut st.warnings);
    g.push_str(&start);
    // Same block Bambu emits right after the machine start G-code: ;VT0 selects the
    // virtual tool (extruder/filament) that the preview assigns the following moves to.
    let first_vt = first_fil;
    let _ = write!(g, "\n; filament start gcode\n;VT{first_vt} H-1\nG90\nG21\nM83 ; use relative distances for extrusion\nM981 S1 P20000 ;open spaghetti detector\n");
    let _ = writeln!(g, "G1 E-{:.2} F{:.0}", pr.retract, pr.retract_speed * 60.0);

    let mut z = 0.0f64;
    let mut retracted = true;
    let mut elapsed = 0.0f64;
    let mut cur_accel = -1.0f64;
    let mut cur_fan = -1.0f64;
    let mut last_path: Option<Poly> = None;
    let mut last_wall_kind = false;
    let mut tool_warned = false;
    let mut nozzle_used = [false; 2];
    let mut cur_slot = first_fil as usize;
    st.slot_mm = vec![0.0; pr.slots.len().max(cur_slot + 1)];
    nozzle_used[pr.slots.get(first_fil as usize).map_or(0, |s| s.hotend as usize).min(1)] = true;
    let e_to_mm3 = fil_area;

    for (li, layer) in layers.iter().enumerate() {
        let n = li + 1;
        let remaining = ((st.seconds - elapsed) / 60.0).ceil().max(0.0);
        let pct = (elapsed / st.seconds.max(1e-9) * 100.0).floor();
        let _ = writeln!(
            g,
            "; CHANGE_LAYER\n; Z_HEIGHT: {:.3}\n; LAYER_HEIGHT: {:.3}\n; layer num/total_layer_count: {}/{}\nM73 L{}\nM73 P{:.0} R{:.0}\nM991 S0 P{} ;notify layer change\n; OBJECT_ID: 378",
            layer.z, layer.height, n, total_layers, n, pct, remaining, n - 1
        );
        if n == 1 {
            g.push_str("M106 S0\nM106 P2 S0\n");
            cur_fan = 0.0;
        } else {
            if n == 2 {
                if pr.nozzle_temp != pr.nozzle_temp_first {
                    let _ = writeln!(g, "M104 S{}", pr.nozzle_temp);
                }
                if pr.bed_temp != pr.bed_temp_first {
                    let _ = writeln!(g, "M140 S{}", pr.bed_temp);
                }
                if pr.fan.aux > 0.0 {
                    let _ = writeln!(g, "M106 P2 S{:.0}", pr.fan.aux * 2.55);
                }
            }
            if (layer.fan_pct - cur_fan).abs() > 0.5 {
                let _ = writeln!(g, "M106 S{:.1}", layer.fan_pct * 2.55);
                cur_fan = layer.fan_pct;
            }
        }
        let layer_fan = cur_fan;
        elapsed += layer.seconds;

        for it in &layer.items {
            match it {
                Item::Travel { to, retract, hop, first_of_layer, short_infill, .. } => {
                    if *retract && !retracted {
                        // wipe: retract while retracing the end of the previous wall loop
                        if pr.wipe && last_wall_kind {
                            if let Some(lp) = &last_path {
                                let mut remaining = pr.wipe_distance;
                                let mut cur = *lp.last().unwrap();
                                let mut pending: Vec<(Pt, f64)> = vec![];
                                for k in (0..lp.len().saturating_sub(1)).rev() {
                                    if remaining <= 1e-6 {
                                        break;
                                    }
                                    let d = dist(cur, lp[k]);
                                    if d < 1e-6 {
                                        continue;
                                    }
                                    let take = d.min(remaining);
                                    let f = take / d;
                                    let np = (cur.0 + (lp[k].0 - cur.0) * f, cur.1 + (lp[k].1 - cur.1) * f);
                                    pending.push((np, take));
                                    cur = np;
                                    remaining -= take;
                                }
                                let total: f64 = pending.iter().map(|p| p.1).sum();
                                if total > 0.1 {
                                    g.push_str("; WIPE_START\n");
                                    for (np, take) in &pending {
                                        let e = pr.retract * (take / total);
                                        let _ = writeln!(g, "G1 X{:.3} Y{:.3} E-{:.5} F{:.0}", np.0, np.1, e, pr.speed.outer.min(60.0) * 60.0);
                                    }
                                    g.push_str("; WIPE_END\n");
                                } else {
                                    let _ = writeln!(g, "G1 E-{:.2} F{:.0}", pr.retract, pr.retract_speed * 60.0);
                                }
                            } else {
                                let _ = writeln!(g, "G1 E-{:.2} F{:.0}", pr.retract, pr.retract_speed * 60.0);
                            }
                        } else {
                            let _ = writeln!(g, "G1 E-{:.2} F{:.0}", pr.retract, pr.retract_speed * 60.0);
                        }
                        retracted = true;
                    }
                    let _ = first_of_layer;
                    let travel_z = if *hop { layer.z.max(z) + pr.z_hop } else { layer.z.max(z) };
                    if (z - travel_z).abs() > 1e-6 {
                        let _ = writeln!(g, "G1 Z{:.3} F1200", travel_z);
                        z = travel_z;
                    }
                    if !*short_infill && cur_accel != pr.accel.travel {
                        let _ = writeln!(g, "M204 S{:.0}", pr.accel.travel);
                        cur_accel = pr.accel.travel;
                    }
                    let _ = writeln!(g, "G1 X{:.3} Y{:.3} F{:.0}", to.0, to.1, pr.speed.travel * 60.0);
                    if (z - layer.z).abs() > 1e-6 {
                        let _ = writeln!(g, "G1 Z{:.3} F1200", layer.z);
                        z = layer.z;
                    }
                    if retracted {
                        let _ = writeln!(g, "G1 E{:.2} F{:.0}", pr.retract, pr.deretract_speed * 60.0);
                        retracted = false;
                    }
                }
                Item::Tool { from, to, count, flush_mm3 } => {
                    cur_slot = *to;
                    if st.slot_mm.len() <= cur_slot {
                        st.slot_mm.resize(cur_slot + 1, 0.0);
                    }
                    let hot = |i: usize| pr.slots.get(i).map_or(0, |s| s.hotend as usize).min(1);
                    let first_use = !nozzle_used[hot(*to)];
                    nozzle_used[hot(*to)] = true;
                    if !retracted {
                        let _ = writeln!(g, "G1 E-{:.2} F{:.0}", pr.retract, pr.retract_speed * 60.0);
                        retracted = true;
                    }
                    g.push_str("; filament end gcode \n; FilamentChangeGCodeStart\n");
                    let rendered = match &pr.tpl {
                        Some(t) if !t.change.trim().is_empty() => {
                            let rt = crate::gcode_template::Runtime {
                                max_print_z: layer.z,
                                bed_type: t.bed_type.clone(),
                                total_layers,
                                slots: pr.slots.clone(),
                                used_slots: used_slots(ops),
                                ..Default::default()
                            };
                            let extra = crate::gcode_template::change_extra(&rt, *from, *to, *count, layer.z, tower.x + tower.w + 4.0, first_use, *flush_mm3 / fil_area, &t.all);
                            crate::gcode_template::render_with(&t.change, &t.all, &rt, &extra)
                        }
                        _ => Err("no change_filament_gcode in the machine profile".to_string()),
                    };
                    match rendered {
                        Ok(txt) => g.push_str(&txt),
                        Err(e) => {
                            if !tool_warned {
                                st.warnings.push(format!("filament change template failed ({e}); used a minimal change sequence"));
                                tool_warned = true;
                            }
                            let _ = writeln!(g, "M620 S{to}A H-1\nT{to} H-1\nM621 S{to}A");
                        }
                    }
                    g.push_str("\n; FilamentChangeGCodeEnd\nM106 S0\nM106 P2 S0\n; filament start gcode\n");
                    z = layer.z + 3.0;
                    cur_accel = -1.0;
                    cur_fan = 0.0;
                    last_path = None;
                    last_wall_kind = false;
                }
                Item::Path { kind, pts, e_per_mm, speed, accel, width, height, new_feature, fan_override, .. } => {
                    if *new_feature {
                        let _ = writeln!(g, "; FEATURE: {}\n; LINE_WIDTH: {:.2}\n;HEIGHT:{:.3}", kind.label(), width, height);
                        // part-cooling override for overhangs / bridges / interfaces
                        let want = if *fan_override { pr.fan.overhang.max(layer_fan) } else { layer_fan };
                        if (want - cur_fan).abs() > 0.5 && layer.z > 0.0 && li > 0 {
                            let _ = writeln!(g, "M106 S{:.1}", want * 2.55);
                            cur_fan = want;
                        }
                    }
                    if (accel - cur_accel).abs() > 0.5 {
                        let _ = writeln!(g, "M204 S{:.0}", accel);
                        cur_accel = *accel;
                    }
                    let mut prev = pts[0];
                    for q in pts.iter().skip(1) {
                        let len = dist(prev, *q);
                        let e = len * e_per_mm;
                        st.filament_mm += e;
                        st.slot_mm[cur_slot] += e;
                        let _ = writeln!(g, "G1 X{:.3} Y{:.3} E{:.5} F{:.0}", q.0, q.1, e, speed * 60.0);
                        prev = *q;
                    }
                    last_wall_kind = matches!(kind, Kind::OuterWall);
                    last_path = Some(pts.clone());
                }
            }
        }
    }
    g.push_str("\n; ---- end print ----\nM106 S0\n");
    g.push_str(&end_gcode);

    let vol_cm3 = st.filament_mm * e_to_mm3 / 1000.0;
    st.weight_g = vol_cm3 * pr.filament_density;
    st.cost = st.weight_g / 1000.0 * pr.filament_cost;

    // Header + config blocks (extruder/filament/printer setup the preview reads),
    // from the Bambu Studio sample, with the slice-dependent fields updated.
    let max_z = layers.last().map(|l| l.z).unwrap_or(0.0);
    let fmt_time = |s: f64| {
        let s = s.round() as u64;
        let (h, m, sec) = (s / 3600, (s % 3600) / 60, s % 60);
        if h > 0 { format!("{h}h {m}m {sec}s") } else { format!("{m}m {sec}s") }
    };
    // Multi-filament: describe the real filament list, so Bambu Studio's preview knows every tool.
    let multi_meta = !pr.slots.is_empty() && st.slot_mm.iter().filter(|m| **m > 0.0).count() > 1;
    let used: Vec<usize> = (0..st.slot_mm.len()).filter(|&i| st.slot_mm[i] > 0.0).collect();
    let dens = |i: usize| pr.slots.get(i).map_or(pr.filament_density, |s| s.density);
    let per_used = |f: &dyn Fn(usize) -> f64| used.iter().map(|&i| format!("{:.2}", f(i))).collect::<Vec<_>>().join(",");
    let tpl_n = include_str!("../../../profiles/h2d_header.gcode").lines().find(|l| l.starts_with("; filament_colour = ")).map_or(0, |l| l.split(';').count() - 1);
    let fil_list = |key: &str, val: &str| -> Option<String> {
        if !multi_meta {
            return None;
        }
        let n = pr.slots.len();
        let sl = &pr.slots;
        let own = match key {
            "filament_colour" => Some(sl.iter().map(|s| s.colour.clone()).collect::<Vec<_>>().join(";")),
            "filament_type" => Some(sl.iter().map(|s| s.ftype.clone()).collect::<Vec<_>>().join(";")),
            "filament_settings_id" => Some(sl.iter().map(|s| format!("\"{}\"", s.name)).collect::<Vec<_>>().join(";")),
            "filament_ids" => Some(sl.iter().map(|s| s.filament_id.clone()).collect::<Vec<_>>().join(";")),
            "filament_map" => Some(sl.iter().map(|s| (s.hotend + 1).to_string()).collect::<Vec<_>>().join(",")),
            "filament_density" => Some(sl.iter().map(|s| format!("{}", s.density)).collect::<Vec<_>>().join(",")),
            "nozzle_temperature" => Some(sl.iter().map(|s| format!("{}", s.temp)).collect::<Vec<_>>().join(",")),
            "nozzle_temperature_initial_layer" => Some(sl.iter().map(|s| format!("{}", s.temp_first)).collect::<Vec<_>>().join(",")),
            _ => None,
        };
        if own.is_some() {
            return own;
        }
        // other per-filament arrays: resize the template's list to the slot count
        let sep = if val.contains(';') { ';' } else { ',' };
        let items: Vec<&str> = val.split(sep).collect();
        if tpl_n > 1 && items.len() == tpl_n && n != tpl_n {
            let last = *items.last().unwrap();
            let v: Vec<&str> = (0..n).map(|i| *items.get(i).unwrap_or(&last)).collect();
            return Some(v.join(&sep.to_string()));
        }
        None
    };
    let mut out = String::new();
    for line in include_str!("../../../profiles/h2d_header.gcode").lines() {
        if let Some((k, v)) = line.strip_prefix("; ").and_then(|r| r.split_once(" = ")) {
            if let Some(nv) = fil_list(k, v) {
                out.push_str(&format!("; {k} = {nv}\n"));
                continue;
            }
        }
        let l = if multi_meta && line.starts_with("; filament: ") {
            format!("; filament: {}", used.iter().map(|i| (i + 1).to_string()).collect::<Vec<_>>().join(","))
        } else if multi_meta && line.starts_with("; total filament length [mm] :") {
            format!("; total filament length [mm] : {}", per_used(&|i| st.slot_mm[i]))
        } else if multi_meta && line.starts_with("; total filament volume [cm^3] :") {
            format!("; total filament volume [cm^3] : {}", per_used(&|i| st.slot_mm[i] * e_to_mm3))
        } else if multi_meta && line.starts_with("; total filament weight [g] :") {
            format!("; total filament weight [g] : {}", per_used(&|i| st.slot_mm[i] * e_to_mm3 / 1000.0 * dens(i)))
        } else if multi_meta && line.starts_with("; filament_density:") {
            format!("; filament_density: {}", pr.slots.iter().map(|s| format!("{}", s.density)).collect::<Vec<_>>().join(","))
        } else if multi_meta && line.starts_with("; filament_diameter:") {
            format!("; filament_diameter: {}", pr.slots.iter().map(|_| format!("{}", pr.filament_dia)).collect::<Vec<_>>().join(","))
        } else if line.starts_with("; model printing time:") {
            format!("; model printing time: {}; total estimated time: {}", fmt_time(st.seconds), fmt_time(st.seconds + 480.0))
        } else if line.starts_with("; total layer number:") {
            format!("; total layer number: {}", total_layers)
        } else if line.starts_with("; total filament length [mm] :") {
            format!("; total filament length [mm] : {:.2}", st.filament_mm)
        } else if line.starts_with("; total filament volume [cm^3] :") {
            format!("; total filament volume [cm^3] : {:.2}", vol_cm3)
        } else if line.starts_with("; total filament weight [g] :") {
            format!("; total filament weight [g] : {:.2}", st.weight_g)
        } else if line.starts_with("; max_z_height:") {
            format!("; max_z_height: {:.2}", max_z)
        } else if line.starts_with("; BambuStudio ") {
            format!("{}\n; VertexSlicer {} (mixed layer height slicer)", line, env!("CARGO_PKG_VERSION"))
        } else {
            line.to_string()
        };
        out.push_str(&l);
        out.push('\n');
    }
    out.push_str(&g);
    (out, st)
}

/// Filament facts read back from the G-code header / config block (multi-filament prints only).
struct FilMeta {
    colours: Vec<String>,
    types: Vec<String>,
    names: Vec<String>,
    ids: Vec<String>,
    map: Vec<String>,
    /// 0-based slots used, with metres and grams
    used: Vec<(usize, f64, f64)>,
    layers: usize,
}

fn fil_meta(gcode: &str) -> Option<FilMeta> {
    let head = &gcode[..gcode.find("; CONFIG_BLOCK_END").unwrap_or(gcode.len().min(400_000))];
    let get = |k: &str| head.lines().find_map(|l| l.strip_prefix(&format!("; {k} = "))).map(|v| v.to_string());
    let hdr = |k: &str| head.lines().find_map(|l| l.strip_prefix(&format!("; {k}"))).map(|v| v.trim_start_matches(':').trim().to_string());
    let used: Vec<usize> = hdr("filament:")?.split(',').filter_map(|x| x.trim().parse::<usize>().ok()).map(|x| x - 1).collect();
    if used.len() < 2 {
        return None;
    }
    let nums = |k: &str| hdr(k).map(|v| v.split(',').filter_map(|x| x.trim().parse::<f64>().ok()).collect::<Vec<_>>()).unwrap_or_default();
    let len = nums("total filament length [mm] :");
    let g = nums("total filament weight [g] :");
    let split = |v: Option<String>, sep: char| v.map(|v| v.split(sep).map(|x| x.trim().trim_matches('"').to_string()).collect::<Vec<_>>()).unwrap_or_default();
    Some(FilMeta {
        colours: split(get("filament_colour"), ';'),
        types: split(get("filament_type"), ';'),
        names: split(get("filament_settings_id"), ';'),
        ids: split(get("filament_ids"), ';'),
        map: split(get("filament_map"), ','),
        layers: hdr("total layer number:").and_then(|v| v.parse().ok()).unwrap_or(1),
        used: used.iter().enumerate().map(|(k, &i)| (i, len.get(k).copied().unwrap_or(0.0) / 1000.0, g.get(k).copied().unwrap_or(0.0))).collect(),
    })
}

fn patch_slice_info(xml: &str, m: &FilMeta) -> String {
    let mut out = String::new();
    let n = m.colours.len();
    for line in xml.lines() {
        let t = line.trim_start();
        if t.starts_with("<filament id=") {
            for &(i, metres, grams) in &m.used {
                let at = |v: &Vec<String>, d: &str| v.get(i).cloned().unwrap_or_else(|| d.to_string());
                let group = if at(&m.map, "1") == "2" { 1 } else { 0 };
                out.push_str(&format!(
                    "    <filament id=\"{}\" tray_info_idx=\"{}\" type=\"{}\" color=\"{}\" used_m=\"{:.2}\" used_g=\"{:.2}\" group_id=\"{}\" nozzle_diameter=\"0.40\" volume_type=\"Standard\" used_for_object=\"true\" used_for_support=\"false\" total_load_time=\"26.00\" total_unload_time=\"0.00\"/>\n",
                    i + 1, at(&m.ids, ""), at(&m.types, "PLA"), at(&m.colours, "#FFFFFF"), metres, grams, group
                ));
            }
            continue;
        }
        if t.starts_with("<nozzle id=") {
            if t.contains("id=\"0\"") {
                out.push_str("    <nozzle id=\"0\" extruder_id=\"1\" nozzle_diameter=\"0.4\" volume_type=\"Standard\"/>\n    <nozzle id=\"1\" extruder_id=\"2\" nozzle_diameter=\"0.4\" volume_type=\"Standard\"/>\n");
            }
            continue;
        }
        if t.starts_with("<metadata key=\"filament_maps\"") {
            out.push_str(&format!("    <metadata key=\"filament_maps\" value=\"{}\"/>\n", m.map.join(" ")));
            continue;
        }
        if t.starts_with("<metadata key=\"limit_filament_maps\"") {
            out.push_str(&format!("    <metadata key=\"limit_filament_maps\" value=\"{}\"/>\n", vec!["0"; n].join(" ")));
            continue;
        }
        if t.starts_with("<metadata key=\"weight\"") {
            out.push_str(&format!("    <metadata key=\"weight\" value=\"{:.2}\"/>\n", m.used.iter().map(|u| u.2).sum::<f64>()));
            continue;
        }
        if t.starts_with("<layer_filament_list ") {
            let list = m.used.iter().map(|u| u.0.to_string()).collect::<Vec<_>>().join(" ");
            out.push_str(&format!("      <layer_filament_list filament_list=\"{list}\" layer_ranges=\"0 {}\" />\n", m.layers.saturating_sub(1)));
            continue;
        }
        out.push_str(line);
        out.push('\n');
    }
    out
}

fn patch_project_settings(json: &[u8], m: &FilMeta) -> Option<Vec<u8>> {
    let mut v: serde_json::Value = serde_json::from_slice(json).ok()?;
    let obj = v.as_object_mut()?;
    let tpl_n = obj.get("filament_colour")?.as_array()?.len();
    let n = m.colours.len();
    let strs = |x: &Vec<String>| serde_json::Value::Array(x.iter().map(|s| serde_json::Value::String(s.clone())).collect());
    for (_, val) in obj.iter_mut() {
        if let Some(a) = val.as_array_mut() {
            if a.len() == tpl_n && n != tpl_n && tpl_n > 0 {
                let last = a[tpl_n - 1].clone();
                a.resize(n, last);
            }
        }
    }
    obj.insert("filament_colour".into(), strs(&m.colours));
    obj.insert("filament_type".into(), strs(&m.types));
    obj.insert("filament_settings_id".into(), strs(&m.names));
    obj.insert("filament_ids".into(), strs(&m.ids));
    obj.insert("filament_map".into(), strs(&m.map));
    serde_json::to_vec_pretty(&v).ok()
}

/// Package G-code as a Bambu `.gcode.3mf` by swapping the plate gcode + md5 in a
/// template exported from Bambu Studio (profiles/h2d_template.3mf). For multi-filament
/// prints the plate metadata is rewritten to list every filament, so Studio previews them.
pub fn write_3mf(gcode: &str, path: &str) -> anyhow::Result<()> {
    use std::io::{Read, Write as _};
    let tpl = include_bytes!("../../../profiles/h2d_template.3mf");
    let meta = fil_meta(gcode);
    let mut zin = zip::ZipArchive::new(std::io::Cursor::new(&tpl[..]))?;
    let mut zout = zip::ZipWriter::new(std::fs::File::create(path)?);
    let opts = zip::write::SimpleFileOptions::default().compression_method(zip::CompressionMethod::Deflated);
    for i in 0..zin.len() {
        let mut f = zin.by_index(i)?;
        let name = f.name().to_string();
        let mut buf = vec![];
        f.read_to_end(&mut buf)?;
        zout.start_file(&name, opts)?;
        match (name.as_str(), &meta) {
            ("Metadata/plate_1.gcode", _) => zout.write_all(gcode.as_bytes())?,
            ("Metadata/plate_1.gcode.md5", _) => zout.write_all(format!("{:X}", md5::compute(gcode.as_bytes())).as_bytes())?,
            ("Metadata/slice_info.config", Some(m)) => zout.write_all(patch_slice_info(&String::from_utf8_lossy(&buf), m).as_bytes())?,
            ("Metadata/project_settings.config", Some(m)) => zout.write_all(&patch_project_settings(&buf, m).unwrap_or(buf))?,
            ("Metadata/plate_1.json", Some(m)) => {
                let mut v: serde_json::Value = serde_json::from_slice(&buf).unwrap_or(serde_json::Value::Null);
                if let Some(o) = v.as_object_mut() {
                    o.insert("filament_colors".into(), serde_json::json!(m.used.iter().map(|u| m.colours.get(u.0).cloned().unwrap_or_default()).collect::<Vec<_>>()));
                    o.insert("filament_ids".into(), serde_json::json!(m.used.iter().map(|u| u.0).collect::<Vec<_>>()));
                    o.insert("first_extruder".into(), serde_json::json!(m.used[0].0));
                }
                zout.write_all(&serde_json::to_vec(&v).unwrap_or(buf))?
            }
            ("Metadata/filament_sequence.json", Some(m)) => {
                let seq: Vec<usize> = m.used.iter().map(|u| u.0 + 1).collect();
                let assign: Vec<u8> = m.map.iter().map(|x| if x == "2" { 1 } else { 0 }).collect();
                zout.write_all(serde_json::json!({"plate_1": {"nozzle_sequence": [], "optimal_assignment": assign, "sequence": seq}}).to_string().as_bytes())?
            }
            _ => zout.write_all(&buf)?,
        }
    }
    zout.finish()?;
    Ok(())
}
