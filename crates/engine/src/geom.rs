//! 2D geometry helpers. Polygons are plain Vec<(f64,f64)> in mm; Clipper2 is used
//! only for boolean ops / offsetting. Toolpath-vs-region clipping is done here
//! because the clipper2 crate discards open paths from boolean results.
use clipper2::*;

pub type Pt = (f64, f64);
pub type Poly = Vec<Pt>;
pub type Polys = Vec<Poly>;

fn to_paths(p: &Polys) -> Paths<Milli> {
    Paths::<Milli>::from(p.clone())
}
fn from_paths(p: Paths<Milli>) -> Polys {
    Vec::<Vec<(f64, f64)>>::from(p)
}

pub fn union_evenodd(a: &Polys) -> Polys {
    if a.is_empty() {
        return vec![];
    }
    Clipper::<NoSubjects, Milli>::new()
        .add_subject(to_paths(a))
        .add_clip(Paths::<Milli>::new(vec![]))
        .union(FillRule::EvenOdd)
        .map(from_paths)
        .unwrap_or_default()
}

pub fn union(a: &Polys, b: &Polys) -> Polys {
    if a.is_empty() {
        return b.clone();
    }
    if b.is_empty() {
        return a.clone();
    }
    Clipper::<NoSubjects, Milli>::new()
        .add_subject(to_paths(a))
        .add_clip(to_paths(b))
        .union(FillRule::NonZero)
        .map(from_paths)
        .unwrap_or_default()
}

pub fn intersect(a: &Polys, b: &Polys) -> Polys {
    if a.is_empty() || b.is_empty() {
        return vec![];
    }
    Clipper::<NoSubjects, Milli>::new()
        .add_subject(to_paths(a))
        .add_clip(to_paths(b))
        .intersect(FillRule::NonZero)
        .map(from_paths)
        .unwrap_or_default()
}

pub fn difference(a: &Polys, b: &Polys) -> Polys {
    if a.is_empty() {
        return vec![];
    }
    if b.is_empty() {
        return a.clone();
    }
    Clipper::<NoSubjects, Milli>::new()
        .add_subject(to_paths(a))
        .add_clip(to_paths(b))
        .difference(FillRule::NonZero)
        .map(from_paths)
        .unwrap_or_default()
}

/// Offset (positive = grow, negative = shrink). Input must be union output
/// (outer/hole orientation normalised).
pub fn offset(a: &Polys, delta: f64) -> Polys {
    if a.is_empty() {
        return vec![];
    }
    // Round joins only: Miter produced long spikes on slightly-noisy intersect() output.
    from_paths(to_paths(a).simplify(0.005, false).inflate(delta, JoinType::Round, EndType::Polygon, 2.0))
}

pub fn area(p: &Poly) -> f64 {
    let n = p.len();
    let mut s = 0.0;
    for i in 0..n {
        let (a, b) = (p[i], p[(i + 1) % n]);
        s += a.0 * b.1 - b.0 * a.1;
    }
    s * 0.5
}

pub fn total_area(p: &Polys) -> f64 {
    p.iter().map(area).sum::<f64>().abs()
}

pub fn pip_evenodd(polys: &Polys, p: Pt) -> bool {
    let mut inside = false;
    for poly in polys {
        let n = poly.len();
        if n < 3 {
            continue;
        }
        let mut j = n - 1;
        for i in 0..n {
            let (a, b) = (poly[i], poly[j]);
            if (a.1 > p.1) != (b.1 > p.1) && p.0 < (b.0 - a.0) * (p.1 - a.1) / (b.1 - a.1) + a.0 {
                inside = !inside;
            }
            j = i;
        }
    }
    inside
}

pub fn circle(cx: f64, cy: f64, r: f64, segs: usize) -> Poly {
    (0..segs)
        .map(|i| {
            let a = std::f64::consts::TAU * i as f64 / segs as f64;
            (cx + r * a.cos(), cy + r * a.sin())
        })
        .collect()
}

/// A region of the XY plane: inside `include` (or everywhere) and outside every `exclude`.
#[derive(Clone, Default)]
pub struct Region {
    pub include: Option<Polys>,
    pub exclude: Vec<Polys>,
}

impl Region {
    pub fn contains(&self, p: Pt) -> bool {
        if let Some(inc) = &self.include {
            if !pip_evenodd(inc, p) {
                return false;
            }
        }
        !self.exclude.iter().any(|e| pip_evenodd(e, p))
    }
    fn edges(&self) -> Vec<(Pt, Pt)> {
        let mut v = vec![];
        let mut add = |polys: &Polys| {
            for poly in polys {
                for i in 0..poly.len() {
                    v.push((poly[i], poly[(i + 1) % poly.len()]));
                }
            }
        };
        if let Some(i) = &self.include {
            add(i);
        }
        for e in &self.exclude {
            add(e);
        }
        v
    }
    pub fn is_everything(&self) -> bool {
        self.include.is_none() && self.exclude.is_empty()
    }
}

fn seg_t(a: Pt, b: Pt, c: Pt, d: Pt) -> Option<f64> {
    let (rx, ry) = (b.0 - a.0, b.1 - a.1);
    let (sx, sy) = (d.0 - c.0, d.1 - c.1);
    let den = rx * sy - ry * sx;
    if den.abs() < 1e-12 {
        return None;
    }
    let t = ((c.0 - a.0) * sy - (c.1 - a.1) * sx) / den;
    let u = ((c.0 - a.0) * ry - (c.1 - a.1) * rx) / den;
    if (0.0..1.0).contains(&t) && (0.0..=1.0).contains(&u) {
        Some(t)
    } else {
        None
    }
}

/// Clip a polyline/loop to a region. Returns (points, closed) pieces.
pub fn clip_path(pts: &[Pt], closed: bool, region: &Region) -> Vec<(Poly, bool)> {
    if pts.len() < 2 {
        return vec![];
    }
    if region.is_everything() {
        return vec![(pts.to_vec(), closed)];
    }
    let edges = region.edges();
    let n = pts.len();
    let nseg = if closed { n } else { n - 1 };
    let mut pieces: Vec<(Poly, bool)> = vec![];
    let mut cur: Poly = vec![];
    let mut all_inside = true;
    for i in 0..nseg {
        let (a, b) = (pts[i], pts[(i + 1) % n]);
        let (minx, maxx) = (a.0.min(b.0), a.0.max(b.0));
        let (miny, maxy) = (a.1.min(b.1), a.1.max(b.1));
        let mut ts = vec![0.0, 1.0];
        for &(c, d) in &edges {
            if c.0.max(d.0) < minx || c.0.min(d.0) > maxx || c.1.max(d.1) < miny || c.1.min(d.1) > maxy {
                continue;
            }
            if let Some(t) = seg_t(a, b, c, d) {
                ts.push(t);
            }
        }
        ts.sort_by(|x, y| x.partial_cmp(y).unwrap());
        for w in ts.windows(2) {
            if w[1] - w[0] < 1e-9 {
                continue;
            }
            let p0 = (a.0 + (b.0 - a.0) * w[0], a.1 + (b.1 - a.1) * w[0]);
            let p1 = (a.0 + (b.0 - a.0) * w[1], a.1 + (b.1 - a.1) * w[1]);
            let mid = ((p0.0 + p1.0) * 0.5, (p0.1 + p1.1) * 0.5);
            if region.contains(mid) {
                if cur.is_empty() {
                    cur.push(p0);
                }
                cur.push(p1);
            } else {
                all_inside = false;
                if cur.len() >= 2 {
                    pieces.push((std::mem::take(&mut cur), false));
                }
                cur.clear();
            }
        }
    }
    if all_inside && closed {
        return vec![(pts.to_vec(), true)];
    }
    if cur.len() >= 2 {
        pieces.push((cur, false));
    }
    pieces
}

/// Parallel scanlines through `area` (even-odd), at `angle` radians, spacing `s`.
/// Lines are phase-locked to world coordinates so layers line up.
pub fn fill_lines(area: &Polys, s: f64, angle: f64) -> Vec<[Pt; 2]> {
    let (ca, sa) = (angle.cos(), angle.sin());
    let rot = |p: Pt| (p.0 * ca + p.1 * sa, -p.0 * sa + p.1 * ca);
    let unrot = |p: Pt| (p.0 * ca - p.1 * sa, p.0 * sa + p.1 * ca);
    let polys: Vec<Vec<Pt>> = area.iter().map(|p| p.iter().map(|&q| rot(q)).collect()).collect();
    let (mut ymin, mut ymax) = (f64::MAX, f64::MIN);
    for p in &polys {
        for q in p {
            ymin = ymin.min(q.1);
            ymax = ymax.max(q.1);
        }
    }
    let mut out = vec![];
    if ymin > ymax {
        return out;
    }
    let k0 = (ymin / s).ceil() as i64;
    let k1 = (ymax / s).floor() as i64;
    for k in k0..=k1 {
        let y = k as f64 * s + 1e-7;
        let mut xs = vec![];
        for p in &polys {
            let n = p.len();
            for i in 0..n {
                let (a, b) = (p[i], p[(i + 1) % n]);
                if (a.1 <= y) != (b.1 <= y) {
                    xs.push(a.0 + (y - a.1) / (b.1 - a.1) * (b.0 - a.0));
                }
            }
        }
        xs.sort_by(|a, b| a.partial_cmp(b).unwrap());
        for c in xs.chunks(2) {
            if c.len() == 2 && c[1] - c[0] > 0.05 {
                out.push([unrot((c[0], y)), unrot((c[1], y))]);
            }
        }
    }
    out
}
