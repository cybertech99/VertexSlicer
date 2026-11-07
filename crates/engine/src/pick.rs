//! Face picking: ray -> triangle, smooth patch growing, patch classification.
use crate::mesh::Mesh;
use std::collections::HashMap;

/// What a picked patch of the surface looks like, in model coordinates.
#[derive(Clone, Debug)]
pub enum PatchKind {
    /// Curved around a vertical axis (a hole, boss, round wall).
    /// `convex`: the material is inside the circle (an outside wall / boss). False for a hole.
    Cylinder { cx: f64, cy: f64, r: f64, convex: bool },
    /// Mostly horizontal (top or bottom surface). `z` is its mean height; `up` is true when it faces +Z.
    Horizontal { z: f64, up: bool },
    /// Anything else (vertical flat wall, slope, freeform).
    Other,
}

#[derive(Clone, Debug)]
pub struct Patch {
    pub tris: Vec<usize>,
    pub lo: [f64; 3],
    pub hi: [f64; 3],
    pub kind: PatchKind,
    /// area-weighted mean normal, oriented to face the picking ray (towards the viewer)
    pub normal: [f64; 3],
}

pub struct Adjacency(Vec<Vec<u32>>);

fn sub(a: [f64; 3], b: [f64; 3]) -> [f64; 3] {
    [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
}
fn cross(a: [f64; 3], b: [f64; 3]) -> [f64; 3] {
    [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
}
fn dot(a: [f64; 3], b: [f64; 3]) -> f64 {
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
}
fn unit(a: [f64; 3]) -> [f64; 3] {
    let l = dot(a, a).sqrt();
    if l < 1e-12 {
        [0.0; 3]
    } else {
        [a[0] / l, a[1] / l, a[2] / l]
    }
}

impl Mesh {
    pub fn tri_normal(&self, t: usize) -> [f64; 3] {
        let v = self.tris[t].map(|i| self.verts[i as usize]);
        unit(cross(sub(v[1], v[0]), sub(v[2], v[0])))
    }

    pub fn adjacency(&self) -> Adjacency {
        let mut edges: HashMap<(u32, u32), Vec<u32>> = HashMap::new();
        for (ti, t) in self.tris.iter().enumerate() {
            for k in 0..3 {
                let (a, b) = (t[k], t[(k + 1) % 3]);
                edges.entry((a.min(b), a.max(b))).or_default().push(ti as u32);
            }
        }
        let mut adj = vec![vec![]; self.tris.len()];
        for tris in edges.values() {
            for &a in tris {
                for &b in tris {
                    if a != b {
                        adj[a as usize].push(b);
                    }
                }
            }
        }
        Adjacency(adj)
    }

    /// Nearest triangle hit by the ray (Moller-Trumbore, double sided). Returns (triangle, distance).
    pub fn pick(&self, o: [f64; 3], d: [f64; 3]) -> Option<(usize, f64)> {
        let mut best: Option<(usize, f64)> = None;
        for (ti, t) in self.tris.iter().enumerate() {
            let v = t.map(|i| self.verts[i as usize]);
            let (e1, e2) = (sub(v[1], v[0]), sub(v[2], v[0]));
            let p = cross(d, e2);
            let det = dot(e1, p);
            if det.abs() < 1e-12 {
                continue;
            }
            let inv = 1.0 / det;
            let s = sub(o, v[0]);
            let u = dot(s, p) * inv;
            if !(0.0..=1.0).contains(&u) {
                continue;
            }
            let q = cross(s, e1);
            let w = dot(d, q) * inv;
            if w < 0.0 || u + w > 1.0 {
                continue;
            }
            let t_hit = dot(e2, q) * inv;
            if t_hit > 1e-9 && best.map_or(true, |b| t_hit < b.1) {
                best = Some((ti, t_hit));
            }
        }
        best
    }

    /// Grow a smooth patch from `seed`: neighbouring triangles join while the angle between
    /// adjacent faces stays under `max_edge_deg` (so a whole round hole is one patch, but a
    /// sharp edge stops it). `ray_dir` is the picking ray, used to tell top from bottom faces.
    pub fn face_patch(&self, adj: &Adjacency, seed: usize, max_edge_deg: f64, ray_dir: [f64; 3]) -> Patch {
        let cos_lim = max_edge_deg.to_radians().cos();
        let mut inpatch = vec![false; self.tris.len()];
        let mut stack = vec![seed];
        inpatch[seed] = true;
        let mut tris = vec![];
        while let Some(t) = stack.pop() {
            tris.push(t);
            let n = self.tri_normal(t);
            for &nb in &adj.0[t] {
                let nb = nb as usize;
                if !inpatch[nb] && dot(n, self.tri_normal(nb)) >= cos_lim {
                    inpatch[nb] = true;
                    stack.push(nb);
                }
            }
        }
        let mut lo = [f64::MAX; 3];
        let mut hi = [f64::MIN; 3];
        let mut area_sum = 0.0;
        let mut zsum = 0.0;
        let mut pts: Vec<(f64, f64)> = vec![];
        let mut horiz_area = 0.0;
        let mut nsum = [0.0f64; 3];
        for &t in &tris {
            let v = self.tris[t].map(|i| self.verts[i as usize]);
            let c = cross(sub(v[1], v[0]), sub(v[2], v[0]));
            let a = 0.5 * dot(c, c).sqrt();
            let n = unit(c);
            area_sum += a;
            for k in 0..3 {
                nsum[k] += n[k] * a;
            }
            zsum += (v[0][2] + v[1][2] + v[2][2]) / 3.0 * a;
            if n[2].abs() > 0.9 {
                horiz_area += a;
            }
            for p in &v {
                for k in 0..3 {
                    lo[k] = lo[k].min(p[k]);
                    hi[k] = hi[k].max(p[k]);
                }
                pts.push((p[0], p[1]));
            }
        }
        let kind = if area_sum > 0.0 && horiz_area / area_sum > 0.8 {
            PatchKind::Horizontal { z: zsum / area_sum, up: ray_dir[2] < 0.0 }
        } else if let Some((cx, cy, r, rms)) = fit_circle(&pts) {
            let span = (hi[0] - lo[0]).max(hi[1] - lo[1]);
            // a real round face wraps (nearly) all the way around; a corner fillet does not
            let coverage = angular_coverage(&pts, cx, cy);
            if rms / r < 0.02 && r < span * 3.0 + 1.0 && r > 0.2 && coverage > 0.75 * std::f64::consts::TAU {
                // Which side is the material on? The ray reaches the face from outside the material:
                // if it travels toward the axis, the face is the outside of a round part.
                let sv = self.tris[seed].map(|i| self.verts[i as usize]);
                let (px, py) = ((sv[0][0] + sv[1][0] + sv[2][0]) / 3.0, (sv[0][1] + sv[1][1] + sv[2][1]) / 3.0);
                let convex = (cx - px) * ray_dir[0] + (cy - py) * ray_dir[1] > 0.0;
                PatchKind::Cylinder { cx, cy, r, convex }
            } else {
                PatchKind::Other
            }
        } else {
            PatchKind::Other
        };
        let mut normal = unit(nsum);
        if dot(normal, ray_dir) > 0.0 {
            normal = [-normal[0], -normal[1], -normal[2]];
        }
        Patch { tris, lo, hi, kind, normal }
    }
}

/// Angle (radians) of arc around (cx, cy) that the points cover: 2*pi minus the largest empty gap.
fn angular_coverage(p: &[(f64, f64)], cx: f64, cy: f64) -> f64 {
    let mut a: Vec<f64> = p.iter().map(|q| (q.1 - cy).atan2(q.0 - cx)).collect();
    a.sort_by(|x, y| x.partial_cmp(y).unwrap());
    let mut gap = a[0] + std::f64::consts::TAU - a[a.len() - 1];
    for w in a.windows(2) {
        gap = gap.max(w[1] - w[0]);
    }
    std::f64::consts::TAU - gap
}

/// Algebraic (Kasa) circle fit. Returns (cx, cy, r, rms residual) or None if degenerate.
fn fit_circle(p: &[(f64, f64)]) -> Option<(f64, f64, f64, f64)> {
    let n = p.len() as f64;
    if p.len() < 6 {
        return None;
    }
    let (mx, my) = (p.iter().map(|q| q.0).sum::<f64>() / n, p.iter().map(|q| q.1).sum::<f64>() / n);
    let (mut suu, mut suv, mut svv, mut suuu, mut svvv, mut suvv, mut svuu) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    for q in p {
        let (u, v) = (q.0 - mx, q.1 - my);
        suu += u * u;
        suv += u * v;
        svv += v * v;
        suuu += u * u * u;
        svvv += v * v * v;
        suvv += u * v * v;
        svuu += v * u * u;
    }
    let det = suu * svv - suv * suv;
    if det.abs() < 1e-9 * (suu + svv).powi(2).max(1e-12) {
        return None; // collinear points: a flat wall, not a circle
    }
    let (b1, b2) = (0.5 * (suuu + suvv), 0.5 * (svvv + svuu));
    let (uc, vc) = ((b1 * svv - b2 * suv) / det, (b2 * suu - b1 * suv) / det);
    let r = (uc * uc + vc * vc + (suu + svv) / n).sqrt();
    let (cx, cy) = (uc + mx, vc + my);
    let rms = (p.iter().map(|q| (((q.0 - cx).powi(2) + (q.1 - cy).powi(2)).sqrt() - r).powi(2)).sum::<f64>() / n).sqrt();
    Some((cx, cy, r, rms))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mesh::washer;

    #[test]
    fn picks_hole_wall_outer_wall_and_top() {
        let m = washer(30.0, 8.0, 6.0, 96);
        let adj = m.adjacency();
        // from inside the hole, looking out at the hole wall
        let (t, _) = m.pick([0.0, 0.0, 3.0], [1.0, 0.0, 0.0]).unwrap();
        let p = m.face_patch(&adj, t, 12.0, [1.0, 0.0, 0.0]);
        match p.kind {
            PatchKind::Cylinder { cx, cy, r, convex } => assert!((r - 8.0).abs() < 0.1 && cx.abs() < 0.1 && cy.abs() < 0.1 && !convex, "a hole is concave: {:?}", p.kind),
            ref k => panic!("expected cylinder, got {k:?}"),
        }
        assert!(p.lo[2] < 0.01 && p.hi[2] > 5.99, "patch should span the full height");
        // outer wall from outside
        let (t, _) = m.pick([50.0, 0.0, 3.0], [-1.0, 0.0, 0.0]).unwrap();
        match m.face_patch(&adj, t, 12.0, [-1.0, 0.0, 0.0]).kind {
            PatchKind::Cylinder { r, convex, .. } => assert!((r - 30.0).abs() < 0.1 && convex, "an outside wall is convex"),
            k => panic!("expected cylinder, got {k:?}"),
        }
        // top face from above
        let (t, _) = m.pick([20.0, 0.0, 20.0], [0.0, 0.0, -1.0]).unwrap();
        match m.face_patch(&adj, t, 12.0, [0.0, 0.0, -1.0]).kind {
            PatchKind::Horizontal { z, up } => assert!((z - 6.0).abs() < 0.01 && up),
            k => panic!("expected horizontal, got {k:?}"),
        }
    }
}
