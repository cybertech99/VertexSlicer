//! Support generation: overhang detection per layer, downward propagation of the
//! support footprint, and base / interface toolpaths. Supports use the default
//! class layer height; they never depend on zones.
use crate::geom::*;
use crate::plan::{drop_small, Config, Kind, Op, Slicer};

pub(crate) fn plan(s: &Slicer, cfg: &Config, zf: f64, zmax: f64, first_slice: &Polys, ops: &mut Vec<Op>) {
    let sc = &cfg.support;
    let wh = cfg.default.wm as f64 * cfg.base;
    let n = (((zmax - zf) / wh).ceil() as usize).max(0);
    if n == 0 {
        return;
    }
    // model cross-section of every support layer (mid-height)
    let c: Vec<Polys> = (0..n)
        .map(|i| {
            let m = zf + (i as f64 + 0.5) * wh;
            if m > zmax { vec![] } else { s.at(m) }
        })
        .collect();

    // overhang of layer i = part of its section not carried by layer i-1 (grown by the allowed reach)
    let reach = (wh / sc.angle_deg.clamp(5.0, 89.0).to_radians().tan()).max(0.05);
    let over: Vec<Polys> = (0..n)
        .map(|i| {
            if c[i].is_empty() {
                return vec![];
            }
            let prev = if i == 0 { first_slice } else { &c[i - 1] };
            drop_small(difference(&c[i], &offset(prev, reach)), 2.0)
        })
        .collect();
    if over.iter().all(|o| o.is_empty()) {
        return;
    }

    // top-down: a support layer carries every overhang that lies (gap layers) above it
    let gap = (sc.z_gap / wh).ceil() as usize;
    let mut sup: Vec<Polys> = vec![vec![]; n];
    let mut prev: Polys = vec![];
    for i in (0..n).rev() {
        let mut cur = prev.clone();
        let j = i + 1 + gap;
        if j < n && !over[j].is_empty() {
            cur = union(&cur, &offset(&over[j], 0.3));
        }
        if !cur.is_empty() {
            cur = difference(&cur, &offset(&c[i], sc.xy_gap));
        }
        cur = drop_small(cur, 2.0);
        sup[i] = cur.clone();
        prev = cur;
    }

    // build-plate-only: drop any column that has model anywhere beneath it
    if sc.on_plate_only {
        let mut below = offset(first_slice, sc.xy_gap);
        for i in 0..n {
            if !sup[i].is_empty() {
                sup[i] = drop_small(difference(&sup[i], &below), 2.0);
            }
            if !c[i].is_empty() {
                below = union(&below, &offset(&c[i], sc.xy_gap));
            }
        }
    }

    // first (thick) layer of support where the column reaches the bed
    if !sup[0].is_empty() {
        let area0 = drop_small(difference(&sup[0], &offset(first_slice, sc.xy_gap)), 2.0);
        if !area0.is_empty() {
            emit(&area0, cfg, 0, zf, zf, true, false, ops);
        }
    }

    let nif = sc.interface_layers as usize;
    for i in 0..n {
        if sup[i].is_empty() {
            continue;
        }
        let up = if nif > 0 && i + nif < n { &sup[i + nif] } else { &Vec::new() };
        let iface = if nif > 0 { drop_small(difference(&sup[i], up), 2.0) } else { vec![] };
        let base = if iface.is_empty() { sup[i].clone() } else { drop_small(difference(&sup[i], &iface), 2.0) };
        let z_top = zf + (i as f64 + 1.0) * wh;
        if !base.is_empty() {
            emit(&base, cfg, i, z_top, wh, false, false, ops);
        }
        if !iface.is_empty() {
            emit(&iface, cfg, i, z_top, wh, false, true, ops);
        }
    }
}

fn emit(area: &Polys, cfg: &Config, layer: usize, z_top: f64, height: f64, first: bool, interface: bool, ops: &mut Vec<Op>) {
    let sc = &cfg.support;
    let w = sc.width;
    let kind = if interface { Kind::SupportInterface } else { Kind::Support };
    let mut paths: Vec<(Poly, bool)> = vec![];
    // outline keeps the column rigid
    for l in offset(area, -w * 0.5) {
        paths.push((l, true));
    }
    let fill = offset(area, -w);
    let spacing = if interface { w * 1.1 } else { sc.spacing };
    let angle = (if interface { 45.0 } else { 0.0 } + 90.0 * (layer % 2) as f64).to_radians();
    for l in fill_lines(&fill, spacing, angle) {
        paths.push((l.to_vec(), false));
    }
    if !paths.is_empty() {
        ops.push(Op { sweep: false, filament: cfg.filament, chain: vec![], wall_idx: 0, z_top, height, kind, first, width: w, paths });
    }
}
