//! Sparse-infill patterns. Every function returns open polylines covering `area`;
//! callers clip them to the region they belong to.
use crate::geom::*;
use std::collections::HashMap;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Pattern {
    Rectilinear,
    Grid,
    Triangles,
    Gyroid,
    /// rings that follow the outline of the area, inward
    Concentric,
}

impl Pattern {
    pub const ALL: [Pattern; 5] = [Pattern::Grid, Pattern::Rectilinear, Pattern::Triangles, Pattern::Gyroid, Pattern::Concentric];

    pub fn label(self) -> &'static str {
        match self {
            Pattern::Rectilinear => "Rectilinear",
            Pattern::Grid => "Grid",
            Pattern::Triangles => "Triangles",
            Pattern::Gyroid => "Gyroid",
            Pattern::Concentric => "Concentric",
        }
    }

    /// Map a Bambu/Orca/Prusa pattern name; unknown names fall back to rectilinear.
    pub fn from_name(s: &str) -> (Pattern, bool) {
        match s {
            "grid" => (Pattern::Grid, true),
            "rectilinear" | "zig-zag" | "line" => (Pattern::Rectilinear, true),
            "triangles" | "tri-hexagon" | "cubic" | "adaptivecubic" | "supportcubic" => (Pattern::Triangles, s == "triangles"),
            "gyroid" => (Pattern::Gyroid, true),
            "concentric" => (Pattern::Concentric, true),
            _ => (Pattern::Rectilinear, false),
        }
    }
}

/// `spacing` is the distance between lines that would give the target density with
/// a single set of parallel lines; multi-direction patterns widen it internally.
pub fn sparse(area: &Polys, spacing: f64, pattern: Pattern, layer_idx: usize, z: f64) -> Vec<Poly> {
    let lines = |angle_deg: f64, sp: f64| fill_lines(area, sp, angle_deg.to_radians()).into_iter().map(|l| l.to_vec());
    match pattern {
        Pattern::Rectilinear => lines(45.0 + 90.0 * (layer_idx % 2) as f64, spacing).collect(),
        Pattern::Grid => lines(45.0, spacing * 2.0).chain(lines(135.0, spacing * 2.0)).collect(),
        Pattern::Triangles => lines(0.0, spacing * 3.0).chain(lines(60.0, spacing * 3.0)).chain(lines(120.0, spacing * 3.0)).collect(),
        Pattern::Gyroid => gyroid(area, spacing, z),
        Pattern::Concentric => concentric(area, spacing),
    }
}

/// Closed loops stepping inward from the outline of `area`, `spacing` apart. They follow the shape
/// of the area (round holes give round rings). Each loop is returned as an open polyline that ends
/// where it began.
pub fn concentric(area: &Polys, spacing: f64) -> Vec<Poly> {
    let mut out = vec![];
    let mut cur = offset(area, -spacing * 0.5);
    let mut guard = 0;
    while !cur.is_empty() && guard < 4000 {
        for l in &cur {
            if l.len() >= 3 {
                let mut p = l.clone();
                p.push(p[0]);
                out.push(p);
            }
        }
        cur = offset(&cur, -spacing);
        guard += 1;
    }
    out
}

fn bbox(area: &Polys) -> Option<(f64, f64, f64, f64)> {
    let mut b = (f64::MAX, f64::MIN, f64::MAX, f64::MIN);
    for p in area {
        for q in p {
            b = (b.0.min(q.0), b.1.max(q.0), b.2.min(q.1), b.3.max(q.1));
        }
    }
    (b.0 <= b.1).then_some(b)
}

fn gyro_f(x: f64, y: f64, z: f64) -> f64 {
    x.sin() * y.cos() + y.sin() * z.cos() + z.sin() * x.cos()
}

/// Gyroid slice at height `z`. The spatial period is calibrated so the printed line
/// length per area matches a rectilinear pattern of the same `spacing`.
fn gyroid(area: &Polys, spacing: f64, z: f64) -> Vec<Poly> {
    let Some(bb) = bbox(area) else { return vec![] };
    let a = total_area(area).max(1.0);
    let target_len = a / spacing;
    let mut period = spacing * 2.2;
    let mut out = trace_gyroid(bb, period, z);
    for _ in 0..2 {
        let len: f64 = out.iter().map(|p| p.windows(2).map(|w| ((w[0].0 - w[1].0).powi(2) + (w[0].1 - w[1].1).powi(2)).sqrt()).sum::<f64>()).sum();
        // length inside the bbox scales with bbox area, compare against bbox-area target
        let bb_area = (bb.1 - bb.0) * (bb.3 - bb.2);
        let want = bb_area / spacing;
        let _ = target_len;
        if len < 1e-6 {
            break;
        }
        let ratio = len / want; // >1 means too dense
        if (ratio - 1.0).abs() < 0.05 {
            break;
        }
        period *= ratio;
        out = trace_gyroid(bb, period, z);
    }
    // clip to the area
    let region = Region { include: Some(area.clone()), exclude: vec![] };
    let mut clipped = vec![];
    for p in out {
        for (piece, _) in clip_path(&p, false, &region) {
            if piece.len() >= 2 {
                clipped.push(piece);
            }
        }
    }
    clipped
}

fn trace_gyroid(bb: (f64, f64, f64, f64), period: f64, z: f64) -> Vec<Poly> {
    let k = std::f64::consts::TAU / period;
    let cell = (period / 10.0).max(((bb.1 - bb.0).max(bb.3 - bb.2)) / 900.0);
    let (x0, y0) = (bb.0 - cell, bb.2 - cell);
    let nx = (((bb.1 - x0) / cell).ceil() as usize + 2).max(2);
    let ny = (((bb.3 - y0) / cell).ceil() as usize + 2).max(2);
    let zz = z * k;
    let val: Vec<f64> = (0..ny).flat_map(|j| (0..nx).map(move |i| (i, j))).map(|(i, j)| gyro_f((x0 + i as f64 * cell) * k, (y0 + j as f64 * cell) * k, zz)).collect();
    let v = |i: usize, j: usize| val[j * nx + i];

    // edge keys: (i, j, dir) with dir 0 = horizontal edge (i,j)-(i+1,j), 1 = vertical (i,j)-(i,j+1)
    type Key = (usize, usize, u8);
    let point = |key: Key| -> Pt {
        let (i, j, d) = key;
        let (a, b) = if d == 0 { (v(i, j), v(i + 1, j)) } else { (v(i, j), v(i, j + 1)) };
        let t = if (a - b).abs() < 1e-12 { 0.5 } else { a / (a - b) };
        let (px, py) = (x0 + i as f64 * cell, y0 + j as f64 * cell);
        if d == 0 { (px + t * cell, py) } else { (px, py + t * cell) }
    };
    let mut segs: Vec<(Key, Key)> = vec![];
    for j in 0..ny - 1 {
        for i in 0..nx - 1 {
            let c = [v(i, j) > 0.0, v(i + 1, j) > 0.0, v(i + 1, j + 1) > 0.0, v(i, j + 1) > 0.0];
            let idx = (c[0] as u8) | (c[1] as u8) << 1 | (c[2] as u8) << 2 | (c[3] as u8) << 3;
            let bottom: Key = (i, j, 0);
            let top: Key = (i, j + 1, 0);
            let left: Key = (i, j, 1);
            let right: Key = (i + 1, j, 1);
            match idx {
                0 | 15 => {}
                1 | 14 => segs.push((bottom, left)),
                2 | 13 => segs.push((bottom, right)),
                3 | 12 => segs.push((left, right)),
                4 | 11 => segs.push((right, top)),
                6 | 9 => segs.push((bottom, top)),
                7 | 8 => segs.push((left, top)),
                5 => {
                    segs.push((bottom, left));
                    segs.push((right, top));
                }
                10 => {
                    segs.push((bottom, right));
                    segs.push((left, top));
                }
                _ => {}
            }
        }
    }
    // chain segments into polylines
    let mut adj: HashMap<Key, Vec<usize>> = HashMap::new();
    for (i, s) in segs.iter().enumerate() {
        adj.entry(s.0).or_default().push(i);
        adj.entry(s.1).or_default().push(i);
    }
    let mut used = vec![false; segs.len()];
    let mut out = vec![];
    for start in 0..segs.len() {
        if used[start] {
            continue;
        }
        used[start] = true;
        let mut chain: std::collections::VecDeque<Key> = std::collections::VecDeque::new();
        chain.push_back(segs[start].0);
        chain.push_back(segs[start].1);
        for forward in [true, false] {
            loop {
                let end = if forward { *chain.back().unwrap() } else { *chain.front().unwrap() };
                let next = adj.get(&end).and_then(|l| l.iter().find(|&&s| !used[s]).copied());
                let Some(n) = next else { break };
                used[n] = true;
                let other = if segs[n].0 == end { segs[n].1 } else { segs[n].0 };
                if forward { chain.push_back(other) } else { chain.push_front(other) }
            }
        }
        out.push(chain.into_iter().map(point).collect());
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn square(s: f64) -> Polys {
        vec![vec![(0.0, 0.0), (s, 0.0), (s, s), (0.0, s)]]
    }
    fn total_len(p: &[Poly]) -> f64 {
        p.iter().map(|l| l.windows(2).map(|w| ((w[0].0 - w[1].0).powi(2) + (w[0].1 - w[1].1).powi(2)).sqrt()).sum::<f64>()).sum()
    }

    #[test]
    fn all_patterns_have_similar_line_density() {
        let area = square(60.0);
        let spacing = 3.0;
        let target = 60.0 * 60.0 / spacing;
        for p in Pattern::ALL {
            let len = total_len(&sparse(&area, spacing, p, 0, 5.0));
            let r = len / target;
            assert!((0.8..1.25).contains(&r), "{:?}: length ratio {r:.2}", p);
        }
    }
}
