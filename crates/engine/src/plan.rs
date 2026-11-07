//! Mixed-layer-height toolpath planning.
//!
//! Model: a fine base grid (`base`, e.g. 0.1 mm). Every region ("class") has
//!   wm = wall/skin layer height  (multiple of base)
//!   im = sparse-infill layer height (multiple of wm)
//! The default class applies everywhere not covered by a zone; zones override it
//! (later zones win). Each class is planned independently into "ops" (one layer
//! of one feature type, already clipped to the class's region). Ops from all
//! classes are then sorted by top-Z, so the nozzle never has to travel at a Z
//! lower than anything already printed beside it.
use crate::geom::*;
use crate::infill::{self, Pattern};
use crate::mesh::Mesh;
use crate::support;
use std::cell::RefCell;
use std::collections::HashMap;

#[derive(Clone, Copy, Debug)]
pub struct Class {
    pub wm: u32,
    pub im: u32,
}

#[derive(Clone, Debug)]
pub enum Shape {
    Circle { cx: f64, cy: f64, r: f64 },
    /// annulus between radii r0 and r1
    Ring { cx: f64, cy: f64, r0: f64, r1: f64 },
    Rect { x0: f64, y0: f64, x1: f64, y1: f64 },
}

#[derive(Clone, Debug)]
pub struct Zone {
    pub shape: Shape,
    pub class: Class,
    pub zmin: Option<f64>,
    pub zmax: Option<f64>,
    /// fill the zone completely solid (no sparse infill)
    pub solid: bool,
    /// infill pattern for this zone (None = the global pattern)
    pub pattern: Option<Pattern>,
    /// sparse infill density 0..1 for this zone (None = the global density)
    pub density: Option<f64>,
    /// filament slot this zone prints in (None = the object's filament)
    pub filament: Option<u8>,
}

impl Zone {
    pub fn polys(&self) -> Polys {
        match self.shape {
            Shape::Circle { cx, cy, r } => vec![circle(cx, cy, r, 96)],
            Shape::Ring { cx, cy, r0, r1 } => {
                // outer loop counter-clockwise, inner loop reversed (a hole)
                let mut inner = circle(cx, cy, r0, 96);
                inner.reverse();
                vec![circle(cx, cy, r1, 96), inner]
            }
            Shape::Rect { x0, y0, x1, y1 } => vec![vec![(x0, y0), (x1, y0), (x1, y1), (x0, y1)]],
        }
    }
    fn active(&self, z: f64) -> bool {
        self.zmin.map_or(true, |m| z >= m) && self.zmax.map_or(true, |m| z < m)
    }
    pub fn translate(&mut self, dx: f64, dy: f64) {
        match &mut self.shape {
            Shape::Circle { cx, cy, .. } | Shape::Ring { cx, cy, .. } => {
                *cx += dx;
                *cy += dy;
            }
            Shape::Rect { x0, y0, x1, y1 } => {
                *x0 += dx;
                *x1 += dx;
                *y0 += dy;
                *y1 += dy;
            }
        }
    }
}

#[derive(Clone, Debug)]
pub struct SupportCfg {
    pub enable: bool,
    /// overhangs shallower than this angle from horizontal get support
    pub angle_deg: f64,
    pub on_plate_only: bool,
    pub xy_gap: f64,
    pub z_gap: f64,
    pub interface_layers: u32,
    pub spacing: f64,
    pub width: f64,
}

impl Default for SupportCfg {
    fn default() -> Self {
        SupportCfg { enable: false, angle_deg: 30.0, on_plate_only: false, xy_gap: 0.35, z_gap: 0.2, interface_layers: 2, spacing: 2.5, width: 0.42 }
    }
}

#[derive(Clone, Debug)]
pub struct AdhesionCfg {
    /// outer brim width in mm (0 = none)
    pub brim_width: f64,
    pub brim_gap: f64,
    pub skirt_loops: u32,
    pub skirt_distance: f64,
}

impl Default for AdhesionCfg {
    fn default() -> Self {
        AdhesionCfg { brim_width: 0.0, brim_gap: 0.1, skirt_loops: 0, skirt_distance: 2.0 }
    }
}

#[derive(Clone, Debug)]
pub struct Config {
    pub base: f64,
    pub first_layer: f64,
    pub nozzle: f64,
    pub w_outer: f64,
    pub w_inner: f64,
    pub w_sparse: f64,
    pub w_solid: f64,
    pub w_first: f64,
    pub walls: u32,
    pub skin_thickness: f64,
    pub density: f64,
    pub default: Class,
    pub pattern: Pattern,
    pub support: SupportCfg,
    pub adhesion: AdhesionCfg,
    /// slow down / fan on walls that hang over empty space
    pub detect_overhangs: bool,
    /// print solid areas over empty space as bridges (ignored when supports are on)
    pub bridges: bool,
    /// wall loops printed along each zone's own boundary (inside the part), so regions with
    /// different layer heights are separated by a perimeter instead of butting together
    pub zone_walls: u32,
    /// filament slot the object (and supports) print in
    pub filament: u8,
}

impl Config {
    /// Sensible defaults for a 0.4 mm nozzle (used by the CLI when no profile is loaded).
    pub fn basic(base: f64, wall_h: f64, infill_h: f64) -> Config {
        let mult = |h: f64| ((h / base).round() as u32).max(1);
        let wm = mult(wall_h);
        Config {
            base,
            first_layer: 0.2,
            nozzle: 0.4,
            w_outer: 0.42,
            w_inner: 0.45,
            w_sparse: 0.45,
            w_solid: 0.42,
            w_first: 0.5,
            walls: 2,
            skin_thickness: 1.0,
            density: 0.15,
            default: Class { wm, im: (mult(infill_h) / wm).max(1) * wm },
            pattern: Pattern::Grid,
            support: SupportCfg::default(),
            adhesion: AdhesionCfg::default(),
            detect_overhangs: true,
            bridges: true,
            zone_walls: 1,
            filament: 0,
        }
    }

    /// Line width of wall loop `i` (0 = outer).
    pub fn wall_w(&self, i: u32, first: bool) -> f64 {
        if first { self.w_first } else if i == 0 { self.w_outer } else { self.w_inner }
    }
    /// Distance from the outline to the centre-line of wall loop `i`.
    pub fn wall_center(&self, i: u32, first: bool) -> f64 {
        (0..i).map(|j| self.wall_w(j, first)).sum::<f64>() + self.wall_w(i, first) * 0.5
    }
    /// Total thickness of all wall loops.
    pub fn wall_total(&self, first: bool) -> f64 {
        (0..self.walls).map(|j| self.wall_w(j, first)).sum()
    }
}

/// Feature types. The derive order is the print order within one layer.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug, Hash)]
pub enum Kind {
    Skirt,
    Brim,
    Support,
    SupportInterface,
    InnerWall,
    OuterWall,
    OverhangWall,
    Bridge,
    Solid,
    Top,
    Sparse,
    /// prime-tower extrusion (written by the G-code writer, never planned)
    Prime,
}

impl Kind {
    pub fn label(self) -> &'static str {
        match self {
            Kind::Skirt => "Skirt",
            Kind::Brim => "Brim",
            Kind::Support => "Support",
            Kind::SupportInterface => "Support interface",
            Kind::InnerWall => "Inner wall",
            Kind::OuterWall => "Outer wall",
            Kind::OverhangWall => "Overhang wall",
            Kind::Bridge => "Bridge",
            Kind::Solid => "Internal solid infill",
            Kind::Top => "Top surface",
            Kind::Sparse => "Sparse infill",
            Kind::Prime => "Prime tower",
        }
    }
}

pub struct Op {
    /// filament slot that prints this op
    pub filament: u8,
    /// part of a concentric-infill region: its wall loops and infill rings print as one sweep
    pub sweep: bool,
    pub z_top: f64,
    pub height: f64,
    pub kind: Kind,
    pub first: bool,
    pub width: f64,
    pub paths: Vec<(Poly, bool)>,
    /// For wall ops: the contour each path belongs to (same length as `paths`; empty = not a wall)
    pub chain: Vec<u32>,
    /// For wall ops: loop number, 0 = outermost
    pub wall_idx: u32,
}

pub(crate) struct Slicer<'a> {
    pub mesh: &'a Mesh,
    cache: RefCell<HashMap<i64, Polys>>,
}
impl<'a> Slicer<'a> {
    pub fn new(mesh: &'a Mesh) -> Self {
        Slicer { mesh, cache: RefCell::new(HashMap::new()) }
    }
    pub fn at(&self, z: f64) -> Polys {
        let k = (z * 10000.0).round() as i64;
        if let Some(p) = self.cache.borrow().get(&k) {
            return p.clone();
        }
        let p = if z < 0.0 { vec![] } else { self.mesh.slice(z) };
        self.cache.borrow_mut().insert(k, p.clone());
        p
    }
}

fn gcd(a: u32, b: u32) -> u32 {
    if b == 0 { a } else { gcd(b, a % b) }
}

pub fn validate(cfg: &Config, zones: &[Zone]) -> anyhow::Result<()> {
    let mut all = vec![cfg.default];
    all.extend(zones.iter().map(|z| z.class));
    for c in all {
        if c.wm == 0 || c.im == 0 || c.im % c.wm != 0 {
            anyhow::bail!("layer heights must satisfy: infill height is a whole multiple of wall height (got wall x{} infill x{})", c.wm, c.im);
        }
        let h = c.im as f64 * cfg.base;
        if h > cfg.nozzle * 0.8 + 1e-9 {
            eprintln!("warning: infill layer height {:.2} exceeds 80% of nozzle diameter {:.2}", h, cfg.nozzle);
        }
    }
    Ok(())
}

/// Flow-correct cross-section area of an extruded bead (Slic3r rounded-rectangle model).
pub fn bead_area(width: f64, height: f64) -> f64 {
    height * (width - height) + std::f64::consts::PI * (height / 2.0).powi(2)
}

fn dist_pt_poly(p: Pt, poly: &Poly) -> f64 {
    let n = poly.len();
    let mut best = f64::MAX;
    for i in 0..n {
        let (a, b) = (poly[i], poly[(i + 1) % n]);
        let (dx, dy) = (b.0 - a.0, b.1 - a.1);
        let l2 = dx * dx + dy * dy;
        let t = if l2 < 1e-12 { 0.0 } else { (((p.0 - a.0) * dx + (p.1 - a.1) * dy) / l2).clamp(0.0, 1.0) };
        let q = (a.0 + t * dx, a.1 + t * dy);
        best = best.min(((p.0 - q.0).powi(2) + (p.1 - q.1).powi(2)).sqrt());
    }
    best
}

/// Tie each wall loop to its contour: loop 0 starts a contour, a deeper loop joins the closest
/// loop one step further out. Lets the writer print a contour's loops together, inside out.
fn chain_loops(by_idx: &[Polys], next: &mut u32) -> Vec<Vec<u32>> {
    let mut out: Vec<Vec<u32>> = vec![];
    for (i, loops) in by_idx.iter().enumerate() {
        let mut ids = vec![];
        for l in loops {
            let parent = if i == 0 || l.is_empty() {
                None
            } else {
                by_idx[i - 1].iter().enumerate().map(|(j, pl)| (dist_pt_poly(l[0], pl), j)).min_by(|a, b| a.0.partial_cmp(&b.0).unwrap()).map(|(_, j)| out[i - 1][j])
            };
            ids.push(parent.unwrap_or_else(|| {
                *next += 1;
                *next - 1
            }));
        }
        out.push(ids);
    }
    out
}

/// Morphological opening: removes slivers thinner than 2*r.
pub(crate) fn open(p: &Polys, r: f64) -> Polys {
    if p.is_empty() {
        return vec![];
    }
    offset(&offset(p, -r), r)
}

pub(crate) fn drop_small(p: Polys, min_area: f64) -> Polys {
    p.into_iter().filter(|l| area(l).abs() >= min_area).collect()
}

fn clip_lines(lines: impl IntoIterator<Item = Poly>, region: &Region) -> Vec<(Poly, bool)> {
    let mut out = vec![];
    for l in lines {
        out.extend(clip_path(&l, false, region));
    }
    out
}

/// Best strand direction (radians) for a bridge: strands must be anchored at both ends on
/// material below (`supported`), so score each direction by the share of anchored line ends;
/// ties go to the shortest strands.
fn bridge_angle(area: &Polys, supported: &Polys) -> f64 {
    let mut best = (-1.0f64, f64::MAX, 0.0f64);
    for k in 0..12 {
        let a = (k as f64 * 15.0).to_radians();
        let lines = fill_lines(area, 1.5, a);
        if lines.is_empty() {
            continue;
        }
        let mut anchored = 0usize;
        let mut longest = 0.0f64;
        for l in &lines {
            longest = longest.max(((l[0].0 - l[1].0).powi(2) + (l[0].1 - l[1].1).powi(2)).sqrt());
            anchored += pip_evenodd(supported, l[0]) as usize + pip_evenodd(supported, l[1]) as usize;
        }
        let score = anchored as f64 / (2 * lines.len()) as f64;
        if score > best.0 + 0.02 || ((score - best.0).abs() <= 0.02 && longest < best.1) {
            best = (score, longest, a);
        }
    }
    best.2
}

/// Outer contours only (no holes), merged.
fn outer_union(c: &Polys) -> Polys {
    let outers: Polys = c.iter().filter(|p| area(p) > 0.0).cloned().collect();
    if outers.is_empty() {
        return vec![];
    }
    union_evenodd(&outers)
}

pub fn plan(mesh: &Mesh, cfg: &Config, zones: &[Zone]) -> anyhow::Result<Vec<Op>> {
    validate(cfg, zones)?;
    let (_, hi) = mesh.bounds();
    let zmax = hi[2];
    let s = Slicer::new(mesh);
    let ov = 0.1;
    let mut ops: Vec<Op> = vec![];
    let mut next_chain = 0u32;

    // ---- first layer: one thick solid layer for everyone, no regions ----
    let zf = cfg.first_layer;
    let first_slice = s.at(zf * 0.5);
    {
        let c = &first_slice;
        let first_loops: Vec<Polys> = (0..cfg.walls).map(|i| offset(c, -cfg.wall_center(i, true))).collect();
        let first_chains = chain_loops(&first_loops, &mut next_chain);
        for i in (0..cfg.walls).rev() {
            let loops = &first_loops[i as usize];
            ops.push(Op {
                sweep: false,
                filament: cfg.filament,
                chain: first_chains[i as usize].clone(),
                wall_idx: i,
                z_top: zf,
                height: zf,
                kind: if i == 0 { Kind::OuterWall } else { Kind::InnerWall },
                first: true,
                width: cfg.wall_w(i, true),
                paths: loops.iter().map(|l| (l.clone(), true)).collect(),
            });
        }
        let inner = offset(&offset(c, -cfg.wall_total(true)), ov);
        let lines = fill_lines(&inner, cfg.w_first, 45f64.to_radians());
        ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top: zf, height: zf, kind: Kind::Solid, first: true, width: cfg.w_first, paths: lines.into_iter().map(|l| (l.to_vec(), false)).collect() });

        // brim: loops growing outward from the outer contour
        let outline = outer_union(c);
        let ad = &cfg.adhesion;
        if ad.brim_width > 0.0 && !outline.is_empty() {
            let n = ((ad.brim_width / cfg.w_first).round() as u32).max(1);
            let mut paths = vec![];
            for i in (0..n).rev() {
                for l in offset(&outline, ad.brim_gap + cfg.w_first * (i as f64 + 0.5)) {
                    paths.push((l, true));
                }
            }
            ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top: zf, height: zf, kind: Kind::Brim, first: true, width: cfg.w_first, paths });
        }
        if ad.skirt_loops > 0 && !outline.is_empty() {
            let start = if ad.brim_width > 0.0 { ad.brim_width + ad.brim_gap } else { 0.0 } + ad.skirt_distance;
            let mut paths = vec![];
            for i in (0..ad.skirt_loops).rev() {
                for l in offset(&outline, start + cfg.w_first * (i as f64 + 0.5)) {
                    paths.push((l, true));
                }
            }
            ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top: zf, height: zf, kind: Kind::Skirt, first: true, width: cfg.w_first, paths });
        }
    }

    // ---- supports (planned on the default layer grid) ----
    if cfg.support.enable {
        support::plan(&s, cfg, zf, zmax, &first_slice, &mut ops);
    }

    // z-range snapping grid for zones: the lcm of all infill blocks
    let mut lcm = cfg.default.im;
    for z in zones {
        lcm = lcm / gcd(lcm, z.class.im) * z.class.im;
    }
    let grid = lcm as f64 * cfg.base;
    let snap = |v: f64| zf + ((v - zf) / grid).round() * grid;
    let zones: Vec<Zone> = zones
        .iter()
        .map(|z| {
            let mut z = z.clone();
            z.zmin = z.zmin.map(snap);
            z.zmax = z.zmax.map(snap);
            z
        })
        .collect();

    // class 0 = default region, class i+1 = zone i
    let n_classes = zones.len() + 1;
    for ci in 0..n_classes {
        let class = if ci == 0 { cfg.default } else { zones[ci - 1].class };
        let wh = class.wm as f64 * cfg.base;
        let ih = class.im as f64 * cfg.base;
        let n_skin = (cfg.skin_thickness / wh).ceil() as i64;
        let wall_blocks = (class.im / class.wm) as usize;
        let ops_start = ops.len();
        let class_fil = if ci > 0 { zones[ci - 1].filament } else { None }.unwrap_or(cfg.filament);
        let class_concentric = if ci > 0 { zones[ci - 1].pattern } else { None }.unwrap_or(cfg.pattern) == Pattern::Concentric;

        let mut ib = 0usize;
        loop {
            let zb0 = zf + ib as f64 * ih;
            if zb0 >= zmax {
                break;
            }
            let zb1 = zb0 + ih;
            let zmid_block = (zb0 + zb1) * 0.5;
            ib += 1;

            // Region for this block at its mid-height.
            let active: Vec<usize> = (0..zones.len()).filter(|&k| zones[k].active(zmid_block)).collect();
            if ci > 0 && !active.contains(&(ci - 1)) {
                continue;
            }
            let region = if ci == 0 {
                Region { include: None, exclude: active.iter().map(|&k| zones[k].polys()).collect() }
            } else {
                Region { include: Some(zones[ci - 1].polys()), exclude: active.iter().filter(|&&k| k > ci - 1).map(|&k| zones[k].polys()).collect() }
            };

            // Infill / skin are pulled in from the zone edge to leave room for its boundary walls.
            let fill_region = if ci > 0 && cfg.zone_walls > 0 {
                let t = cfg.zone_walls as f64 * cfg.w_inner;
                Region { include: Some(offset(&zones[ci - 1].polys(), -t + ov)), exclude: region.exclude.clone() }
            } else {
                region.clone()
            };

            // Wall-block cross-sections inside this infill block.
            // This zone's own infill pattern, if it has one
            let zone_pattern: Option<Pattern> = if ci > 0 { zones[ci - 1].pattern } else { None };
            let pattern = zone_pattern.unwrap_or(cfg.pattern);
            let density = if ci > 0 { zones[ci - 1].density } else { None }.unwrap_or(cfg.density).clamp(0.02, 1.0);

            let mids: Vec<f64> = (0..wall_blocks).map(|k| zb0 + (k as f64 + 0.5) * wh).filter(|&m| m < zmax).collect();
            if mids.is_empty() {
                continue;
            }

            // Sparse region = part of every wall-block section that has full
            // skin-thickness of material above and below.
            let mut sparse_raw: Option<Polys> = None;
            'outer: for &m in &mids {
                for j in -n_skin..=n_skin {
                    let c = s.at(m + j as f64 * wh);
                    let next = match &sparse_raw {
                        None => c,
                        Some(prev) => intersect(prev, &c),
                    };
                    if next.is_empty() {
                        sparse_raw = Some(vec![]);
                        break 'outer;
                    }
                    sparse_raw = Some(next);
                }
            }
            let sparse_area = sparse_raw.map(|r| offset(&offset(&r, -cfg.wall_total(false)), ov)).unwrap_or_default();
            let sparse_area: Polys = if total_area(&sparse_area) < 4.0 { vec![] } else { sparse_area };
            // a solid zone has no sparse region: everything inside the walls is solid fill
            let sparse_area: Polys = if ci > 0 && zones[ci - 1].solid { vec![] } else { sparse_area };

            // Wall blocks: walls + skins.
            for (k, &m) in mids.iter().enumerate() {
                let c = s.at(m);
                if c.is_empty() {
                    continue;
                }
                let z_top = zb0 + (k as f64 + 1.0) * wh;
                // previous / next layer sections, for overhang, bridge and top-surface detection
                let cprev = if m - wh < zf { first_slice.clone() } else { s.at(m - wh) };
                let cnext = if m + wh > zmax { vec![] } else { s.at(m + wh) };

                // overhang-aware wall splitting
                let supported = if cfg.detect_overhangs { offset(&cprev, cfg.w_outer * 0.25) } else { vec![] };
                let sup_region = Region { include: Some(supported.clone()), exclude: vec![] };
                let unsup_region = Region { include: None, exclude: vec![supported.clone()] };
                let all_loops: Vec<Polys> = (0..cfg.walls).map(|i| offset(&c, -cfg.wall_center(i, false))).collect();
                let chains = chain_loops(&all_loops, &mut next_chain);
                for i in (0..cfg.walls).rev() {
                    let (mut normal, mut hang, mut nch, mut hch) = (vec![], vec![], vec![], vec![]);
                    for (li, l) in all_loops[i as usize].iter().enumerate() {
                        let ch = chains[i as usize][li];
                        for (piece, closed) in clip_path(l, true, &region) {
                            if cfg.detect_overhangs && !supported.is_empty() {
                                let a = clip_path(&piece, closed, &sup_region);
                                nch.extend(std::iter::repeat(ch).take(a.len()));
                                normal.extend(a);
                                let b = clip_path(&piece, closed, &unsup_region);
                                hch.extend(std::iter::repeat(ch).take(b.len()));
                                hang.extend(b);
                            } else {
                                normal.push((piece, closed));
                                nch.push(ch);
                            }
                        }
                    }
                    let kind = if i == 0 { Kind::OuterWall } else { Kind::InnerWall };
                    let width = cfg.wall_w(i, false);
                    if !normal.is_empty() {
                        ops.push(Op { sweep: false, filament: cfg.filament, chain: nch, wall_idx: i, z_top, height: wh, kind, first: false, width, paths: normal });
                    }
                    if !hang.is_empty() {
                        ops.push(Op { sweep: false, filament: cfg.filament, chain: hch, wall_idx: i, z_top, height: wh, kind: Kind::OverhangWall, first: false, width, paths: hang });
                    }
                }

                // zone boundary walls: a perimeter along this zone's edge, only through solid interior
                if ci > 0 && cfg.zone_walls > 0 {
                    let zp = zones[ci - 1].polys();
                    let in_part = Region { include: Some(offset(&c, -cfg.wall_total(false))), exclude: vec![] };
                    let zb_loops: Vec<Polys> = (0..cfg.zone_walls).map(|i| offset(&zp, -(cfg.w_inner * 0.5 + i as f64 * cfg.w_inner))).collect();
                    let zb_chains = chain_loops(&zb_loops, &mut next_chain);
                    for i in (0..cfg.zone_walls).rev() {
                        let (mut paths, mut chs) = (vec![], vec![]);
                        for (li, l) in zb_loops[i as usize].iter().enumerate() {
                            for (piece, closed) in clip_path(l, true, &region) {
                                let got = clip_path(&piece, closed, &in_part);
                                chs.extend(std::iter::repeat(zb_chains[i as usize][li]).take(got.len()));
                                paths.extend(got);
                            }
                        }
                        if !paths.is_empty() {
                            ops.push(Op { sweep: false, filament: cfg.filament, chain: chs, wall_idx: i, z_top, height: wh, kind: Kind::InnerWall, first: false, width: cfg.w_inner, paths });
                        }
                    }
                }

                // skins
                let inner = offset(&offset(&c, -cfg.wall_total(false)), ov);
                let solid = difference(&inner, &sparse_area);
                if !solid.is_empty() {
                    let top_area = open(&difference(&solid, &cnext), 0.15);
                    let rest = difference(&solid, &top_area);
                    let bridge_area = if cfg.bridges && !cfg.support.enable && !cprev.is_empty() {
                        drop_small(open(&difference(&rest, &offset(&cprev, 0.2)), 0.4), 3.0)
                    } else {
                        vec![]
                    };
                    let internal = difference(&rest, &bridge_area);

                    if !bridge_area.is_empty() {
                        let lines = fill_lines(&bridge_area, cfg.w_solid, bridge_angle(&bridge_area, &offset(&cprev, 0.6)));
                        let paths = clip_lines(lines.into_iter().map(|l| l.to_vec()), &fill_region);
                        if !paths.is_empty() {
                            ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top, height: wh, kind: Kind::Bridge, first: false, width: cfg.w_solid, paths });
                        }
                    }
                    if !internal.is_empty() {
                        // a zone set to concentric fills its solid areas in rings too
                        let polylines: Vec<Poly> = if zone_pattern == Some(Pattern::Concentric) {
                            infill::concentric(&internal, cfg.w_solid)
                        } else {
                            fill_lines(&internal, cfg.w_solid, (45.0 + 90.0 * ((ib + k) % 2) as f64).to_radians()).into_iter().map(|l| l.to_vec()).collect()
                        };
                        let paths = clip_lines(polylines, &fill_region);
                        if !paths.is_empty() {
                            ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top, height: wh, kind: Kind::Solid, first: false, width: cfg.w_solid, paths });
                        }
                    }
                    if !top_area.is_empty() {
                        let lines = fill_lines(&top_area, cfg.w_solid, 45f64.to_radians());
                        let paths = clip_lines(lines.into_iter().map(|l| l.to_vec()), &fill_region);
                        if !paths.is_empty() {
                            ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top, height: wh, kind: Kind::Top, first: false, width: cfg.w_solid, paths });
                        }
                    }
                }
            }

            // Sparse infill: one thick layer for the whole infill block.
            if !sparse_area.is_empty() && mids.len() == wall_blocks {
                let polylines = infill::sparse(&sparse_area, cfg.w_sparse / density, pattern, ib, zmid_block);
                let paths = clip_lines(polylines, &fill_region);
                if !paths.is_empty() {
                    ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top: zb1, height: ih, kind: Kind::Sparse, first: false, width: cfg.w_sparse, paths });
                }
            }
        }
        for o in ops[ops_start..].iter_mut() {
            o.filament = class_fil;
            o.sweep = class_concentric;
        }
    }

    ops.sort_by(|a, b| {
        let r = |x: f64| (x * 1e4).round() as i64;
        r(a.z_top).cmp(&r(b.z_top)).then(a.filament.cmp(&b.filament)).then(r(a.height).cmp(&r(b.height))).then(a.kind.cmp(&b.kind))
    });
    Ok(order_filaments(ops))
}

/// Within each layer, print the filament that was already loaded first, so a layer that uses two
/// filaments costs one change instead of two. Ops are already sorted by (z, filament).
fn order_filaments(ops: Vec<Op>) -> Vec<Op> {
    let mut out: Vec<Op> = Vec::with_capacity(ops.len());
    let mut loaded: Option<u8> = None;
    let mut it = ops.into_iter().peekable();
    while let Some(first) = it.next() {
        let z = first.z_top;
        let mut group = vec![first];
        while it.peek().map_or(false, |o| (o.z_top - z).abs() < 1e-6) {
            group.push(it.next().unwrap());
        }
        // stable split by filament, in ascending order
        let mut by: Vec<(u8, Vec<Op>)> = vec![];
        for o in group {
            match by.last_mut() {
                Some((f, v)) if *f == o.filament => v.push(o),
                _ => by.push((o.filament, vec![o])),
            }
        }
        if let Some(l) = loaded {
            if let Some(p) = by.iter().position(|(f, _)| *f == l) {
                by.rotate_left(p);
            }
        }
        loaded = by.last().map(|(f, _)| *f);
        for (_, v) in by {
            out.extend(v);
        }
    }
    out
}
