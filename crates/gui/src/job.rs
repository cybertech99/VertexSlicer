//! Background slicing job: model + settings in, G-code and preview geometry out.
use engine::bbl::Imported;
use engine::mesh::Mesh;
use engine::infill::Pattern;
use engine::plan::{self, Class, Kind, Shape, Zone};
use std::collections::BTreeMap;
use std::sync::Arc;

#[derive(Clone)]
pub enum ZoneShape {
    Circle { cx: f64, cy: f64, r: f64 },
    Ring { cx: f64, cy: f64, r0: f64, r1: f64 },
    Rect { x0: f64, y0: f64, x1: f64, y1: f64 },
}

#[derive(Clone)]
pub struct ZoneSpec {
    pub shape: ZoneShape,
    pub wall_mult: u32,
    pub infill_mult: u32,
    pub solid: bool,
    pub pattern: Option<Pattern>,
    pub density: Option<f64>,
    pub filament: Option<u8>,
    pub z0: Option<f64>,
    pub z1: Option<f64>,
}

pub struct SliceInput {
    pub mesh: Arc<Mesh>,
    /// translation from model coordinates to bed coordinates
    pub place: (f64, f64, f64),
    pub imported: Imported,
    pub base: f64,
    pub wall_h: f64,
    pub infill_h: f64,
    pub walls: u32,
    pub density: f64,
    pub pattern: Pattern,
    pub support: bool,
    pub support_plate_only: bool,
    pub brim: f64,
    pub skirt: u32,
    pub zone_walls: u32,
    pub zones: Vec<ZoneSpec>,
    /// AMS slots (empty = single filament)
    pub slots: Vec<engine::gcode_template::SlotInfo>,
    /// preview colour of each slot
    pub slot_colours: Vec<[f32; 3]>,
    pub object_filament: u8,
    pub tower: engine::gcode::TowerCfg,
}

pub struct SliceOut {
    pub gcode: String,
    pub seconds: f64,
    pub filament_m: f64,
    pub notes: Vec<String>,
    /// interleaved pos+colour line vertices (6 floats each), layer by layer
    pub verts: Vec<f32>,
    /// cumulative vertex count at the end of each layer
    pub layer_end: Vec<usize>,
    pub layer_z: Vec<f32>,
    pub layer_h: Vec<f32>,
    pub legend: Vec<(f32, [f32; 3])>,
    /// same line geometry coloured by feature type
    pub verts_feature: Vec<f32>,
    pub legend_feature: Vec<(&'static str, [f32; 3])>,
    pub print_seconds: f64,
    pub weight_g: f64,
    pub cost: f64,
    pub warnings: Vec<String>,
    /// same line geometry coloured by filament slot
    pub verts_filament: Vec<f32>,
    pub legend_filament: Vec<(String, [f32; 3])>,
    pub tool_changes: usize,
}

fn feature_color(k: Kind) -> [f32; 3] {
    match k {
        Kind::OuterWall => [0.12, 0.47, 0.71],
        Kind::InnerWall => [0.50, 0.70, 0.88],
        Kind::OverhangWall => [0.84, 0.15, 0.16],
        Kind::Bridge => [1.0, 0.50, 0.05],
        Kind::Solid => [0.58, 0.40, 0.74],
        Kind::Top => [0.17, 0.63, 0.17],
        Kind::Sparse => [0.75, 0.75, 0.75],
        Kind::Support => [0.55, 0.34, 0.29],
        Kind::SupportInterface => [0.89, 0.47, 0.76],
        Kind::Brim => [0.09, 0.75, 0.81],
        Kind::Skirt => [0.74, 0.74, 0.13],
        Kind::Prime => [0.35, 0.35, 0.35],
    }
}

const PALETTE: [[f32; 3]; 6] = [
    [0.95, 0.35, 0.30], // thinnest
    [0.98, 0.75, 0.25],
    [0.45, 0.80, 0.40],
    [0.30, 0.65, 0.95],
    [0.65, 0.45, 0.95],
    [0.90, 0.50, 0.80],
];

pub fn run(inp: SliceInput) -> anyhow::Result<SliceOut> {
    let t = std::time::Instant::now();
    let mut mesh = (*inp.mesh).clone();
    mesh.translate([inp.place.0, inp.place.1, inp.place.2]);

    let mut cfg = inp.imported.to_config(inp.base, inp.wall_h, inp.infill_h);
    cfg.walls = inp.walls.max(1);
    cfg.density = inp.density.clamp(0.02, 1.0);
    cfg.pattern = inp.pattern;
    cfg.support.enable = inp.support;
    cfg.support.on_plate_only = inp.support_plate_only;
    cfg.adhesion.brim_width = inp.brim;
    cfg.adhesion.skirt_loops = inp.skirt;
    cfg.zone_walls = inp.zone_walls;
    cfg.filament = if inp.slots.is_empty() { 0 } else { inp.object_filament.min(inp.slots.len() as u8 - 1) };
    let zones: Vec<Zone> = inp
        .zones
        .iter()
        .map(|z| Zone {
            shape: match z.shape {
                ZoneShape::Circle { cx, cy, r } => Shape::Circle { cx: cx + inp.place.0, cy: cy + inp.place.1, r },
                ZoneShape::Ring { cx, cy, r0, r1 } => Shape::Ring { cx: cx + inp.place.0, cy: cy + inp.place.1, r0, r1 },
                ZoneShape::Rect { x0, y0, x1, y1 } => Shape::Rect { x0: x0 + inp.place.0, y0: y0 + inp.place.1, x1: x1 + inp.place.0, y1: y1 + inp.place.1 },
            },
            class: Class { wm: z.wall_mult, im: z.infill_mult.max(z.wall_mult) / z.wall_mult * z.wall_mult },
            zmin: z.z0,
            zmax: z.z1,
            solid: z.solid,
            pattern: z.pattern,
            density: z.density,
            filament: z.filament.filter(|f| (*f as usize) < inp.slots.len()),
        })
        .collect();

    let ops = plan::plan(&mesh, &cfg, &zones)?;
    let mut printer = inp.imported.to_printer();
    printer.slots = inp.slots.clone();
    printer.tower = inp.tower.clone();
    let (gcode, stats) = engine::gcode::write(&ops, &cfg, &printer, (inp.place.0, inp.place.1));

    // colour by layer height
    let mut heights: BTreeMap<i64, f32> = BTreeMap::new();
    for o in &ops {
        heights.insert((o.height * 1000.0).round() as i64, o.height as f32);
    }
    let legend: Vec<(f32, [f32; 3])> = heights.values().enumerate().map(|(i, h)| (*h, PALETTE[i.min(PALETTE.len() - 1)])).collect();
    let color_of = |h: f64| {
        let k = (h * 1000.0).round() as i64;
        let idx = heights.keys().position(|x| *x == k).unwrap_or(0);
        PALETTE[idx.min(PALETTE.len() - 1)]
    };

    let mut verts: Vec<f32> = vec![];
    let mut verts_feature: Vec<f32> = vec![];
    let mut verts_filament: Vec<f32> = vec![];
    let slot_col = |f: u8| inp.slot_colours.get(f as usize).copied().unwrap_or([0.8, 0.8, 0.8]);
    // the writer adds a prime tower on every layer up to the last filament change; show it too
    let multi = !inp.slots.is_empty() && ops.iter().any(|o| o.filament != ops[0].filament);
    let last_change_z = {
        let (mut cur, mut last) = (ops.first().map(|o| o.filament).unwrap_or(0), f64::NEG_INFINITY);
        for o in &ops {
            if o.filament != cur {
                cur = o.filament;
                last = o.z_top;
            }
        }
        last
    };
    let tw = &stats.tower.clone().unwrap_or(inp.tower.clone());
    let tower_loop: Vec<(f32, f32)> = vec![(tw.x, tw.y), (tw.x + tw.w, tw.y), (tw.x + tw.w, tw.y + tw.d), (tw.x, tw.y + tw.d)].into_iter().map(|(a, b)| (a as f32, b as f32)).collect();
    let tower_col = [0.35f32, 0.35, 0.35];
    let mut kinds_seen: std::collections::BTreeSet<Kind> = Default::default();
    let mut layer_end = vec![];
    let mut layer_z = vec![];
    let mut layer_h: Vec<f32> = vec![];
    let mut cur_z = f64::NAN;
    for o in &ops {
        if cur_z.is_nan() || (o.z_top - cur_z).abs() > 1e-6 {
            if !cur_z.is_nan() {
                layer_end.push(verts.len() / 6);
            }
            cur_z = o.z_top;
            if multi && tw.enable && o.z_top <= last_change_z + 1e-6 {
                let z = o.z_top as f32;
                for i in 0..4 {
                    let (a, b) = (tower_loop[i], tower_loop[(i + 1) % 4]);
                    for v in [&mut verts, &mut verts_feature, &mut verts_filament] {
                        v.extend_from_slice(&[a.0, a.1, z, tower_col[0], tower_col[1], tower_col[2]]);
                        v.extend_from_slice(&[b.0, b.1, z, tower_col[0], tower_col[1], tower_col[2]]);
                    }
                }
            }
            layer_z.push(o.z_top as f32);
            layer_h.push(o.height as f32);
        }
        if let Some(l) = layer_h.last_mut() {
            *l = l.min(o.height as f32);
        }
        let c = color_of(o.height);
        let fc = feature_color(o.kind);
        let mc = slot_col(o.filament);
        kinds_seen.insert(o.kind);
        let z = o.z_top as f32;
        for (p, closed) in &o.paths {
            let n = p.len();
            let segs = if *closed { n } else { n.saturating_sub(1) };
            for i in 0..segs {
                let (a, b) = (p[i], p[(i + 1) % n]);
                verts.extend_from_slice(&[a.0 as f32, a.1 as f32, z, c[0], c[1], c[2]]);
                verts.extend_from_slice(&[b.0 as f32, b.1 as f32, z, c[0], c[1], c[2]]);
                verts_feature.extend_from_slice(&[a.0 as f32, a.1 as f32, z, fc[0], fc[1], fc[2]]);
                verts_feature.extend_from_slice(&[b.0 as f32, b.1 as f32, z, fc[0], fc[1], fc[2]]);
                verts_filament.extend_from_slice(&[a.0 as f32, a.1 as f32, z, mc[0], mc[1], mc[2]]);
                verts_filament.extend_from_slice(&[b.0 as f32, b.1 as f32, z, mc[0], mc[1], mc[2]]);
            }
        }
    }
    layer_end.push(verts.len() / 6);

    let mut notes = inp.imported.notes.clone();
    notes.retain(|n| !n.contains("prime tower"));
    Ok(SliceOut {
        gcode,
        seconds: t.elapsed().as_secs_f64(),
        filament_m: stats.filament_mm / 1000.0,
        notes,
        verts,
        layer_end,
        layer_z,
        layer_h,
        legend,
        verts_feature,
        legend_feature: kinds_seen.iter().map(|k| (k.label(), feature_color(*k))).collect(),
        print_seconds: stats.seconds,
        weight_g: stats.weight_g,
        cost: stats.cost,
        warnings: stats.warnings.clone(),
        legend_filament: {
            let mut used: Vec<u8> = ops.iter().map(|o| o.filament).collect();
            used.sort();
            used.dedup();
            used.into_iter().map(|f| (inp.slots.get(f as usize).map_or_else(|| inp.imported.filament_name.clone(), |s| format!("{} · {}", f + 1, s.name)), slot_col(f))).collect()
        },
        verts_filament,
        tool_changes: stats.tool_changes,
    })
}
