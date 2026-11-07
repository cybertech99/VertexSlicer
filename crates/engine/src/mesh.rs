use crate::geom::*;
use std::collections::HashMap;

#[derive(Clone)]
pub struct Mesh {
    pub verts: Vec<[f64; 3]>,
    pub tris: Vec<[u32; 3]>,
    tz: Vec<(f64, f64)>,
}

impl Mesh {
    pub fn load_stl(path: &str) -> anyhow::Result<Mesh> {
        let mut f = std::fs::File::open(path)?;
        let m = stl_io::read_stl(&mut f)?;
        let verts = m.vertices.iter().map(|v| [v[0] as f64, v[1] as f64, v[2] as f64]).collect();
        let tris = m.faces.iter().map(|f| [f.vertices[0] as u32, f.vertices[1] as u32, f.vertices[2] as u32]).collect();
        Ok(Mesh::new(verts, tris))
    }

    pub fn new(verts: Vec<[f64; 3]>, tris: Vec<[u32; 3]>) -> Mesh {
        let tz = tris
            .iter()
            .map(|t| {
                let z: Vec<f64> = t.iter().map(|&i| verts[i as usize][2]).collect();
                (z.iter().cloned().fold(f64::MAX, f64::min), z.iter().cloned().fold(f64::MIN, f64::max))
            })
            .collect();
        Mesh { verts, tris, tz }
    }

    pub fn bounds(&self) -> ([f64; 3], [f64; 3]) {
        let mut lo = [f64::MAX; 3];
        let mut hi = [f64::MIN; 3];
        for v in &self.verts {
            for i in 0..3 {
                lo[i] = lo[i].min(v[i]);
                hi[i] = hi[i].max(v[i]);
            }
        }
        (lo, hi)
    }

    pub fn translate(&mut self, d: [f64; 3]) {
        for v in &mut self.verts {
            for i in 0..3 {
                v[i] += d[i];
            }
        }
        for t in &mut self.tz {
            t.0 += d[2];
            t.1 += d[2];
        }
    }

    /// Cross-section at height z as a union (even-odd) of closed loops.
    pub fn slice(&self, z: f64) -> Polys {
        struct Seg {
            e: [(u32, u32); 2],
            p: [Pt; 2],
        }
        let mut segs: Vec<Seg> = vec![];
        for (ti, t) in self.tris.iter().enumerate() {
            let (lo, hi) = self.tz[ti];
            // Vertices exactly on the plane count as 'up' (>= z). A triangle whose top
            // touches the plane must NOT be skipped: its neighbours still expect its segment,
            // and dropping it breaks the outline chain (a whole loop vanishes).
            if z < lo || z > hi {
                continue;
            }
            let up: Vec<bool> = t.iter().map(|&i| self.verts[i as usize][2] >= z).collect();
            if up[0] == up[1] && up[1] == up[2] {
                continue;
            }
            let mut crossing = vec![];
            for k in 0..3 {
                let (a, b) = (t[k], t[(k + 1) % 3]);
                if up[k] != up[(k + 1) % 3] {
                    let (va, vb) = (self.verts[a as usize], self.verts[b as usize]);
                    let f = (z - va[2]) / (vb[2] - va[2]);
                    crossing.push(((a.min(b), a.max(b)), (va[0] + f * (vb[0] - va[0]), va[1] + f * (vb[1] - va[1]))));
                }
            }
            if crossing.len() == 2 {
                segs.push(Seg { e: [crossing[0].0, crossing[1].0], p: [crossing[0].1, crossing[1].1] });
            }
        }
        let mut map: HashMap<(u32, u32), Vec<usize>> = HashMap::new();
        for (i, s) in segs.iter().enumerate() {
            map.entry(s.e[0]).or_default().push(i);
            map.entry(s.e[1]).or_default().push(i);
        }
        let mut used = vec![false; segs.len()];
        let mut loops: Polys = vec![];
        for start in 0..segs.len() {
            if used[start] {
                continue;
            }
            used[start] = true;
            let mut poly = vec![segs[start].p[0], segs[start].p[1]];
            let first_edge = segs[start].e[0];
            let mut cur_edge = segs[start].e[1];
            loop {
                if cur_edge == first_edge {
                    break;
                }
                let next = map.get(&cur_edge).and_then(|v| v.iter().find(|&&i| !used[i]).copied());
                let Some(ni) = next else { break };
                used[ni] = true;
                let s = &segs[ni];
                let (pt, ne) = if s.e[0] == cur_edge { (s.p[1], s.e[1]) } else { (s.p[0], s.e[0]) };
                poly.push(pt);
                cur_edge = ne;
            }
            if poly.len() > 3 {
                poly.pop(); // closing point duplicates the first
                loops.push(poly);
            }
        }
        union_evenodd(&loops)
    }
}

/// Build a washer (disc with a hole) for testing.
pub fn washer(r_out: f64, r_in: f64, h: f64, segs: usize) -> Mesh {
    let mut v = vec![];
    for i in 0..segs {
        let a = std::f64::consts::TAU * i as f64 / segs as f64;
        let (c, s) = (a.cos(), a.sin());
        v.push([r_out * c, r_out * s, 0.0]);
        v.push([r_out * c, r_out * s, h]);
        v.push([r_in * c, r_in * s, 0.0]);
        v.push([r_in * c, r_in * s, h]);
    }
    let mut t = vec![];
    for i in 0..segs {
        let j = (i + 1) % segs;
        let (ob, ot, ib, it) = ((4 * i) as u32, (4 * i + 1) as u32, (4 * i + 2) as u32, (4 * i + 3) as u32);
        let (ob2, ot2, ib2, it2) = ((4 * j) as u32, (4 * j + 1) as u32, (4 * j + 2) as u32, (4 * j + 3) as u32);
        t.push([ob, ob2, ot2]);
        t.push([ob, ot2, ot]);
        t.push([ib, it2, ib2]);
        t.push([ib, it, it2]);
        t.push([ot, ot2, it2]);
        t.push([ot, it2, it]);
        t.push([ob, ib2, ob2]);
        t.push([ob, ib, ib2]);
    }
    Mesh::new(v, t)
}

pub fn write_ascii_stl(m: &Mesh, path: &str) -> anyhow::Result<()> {
    use std::fmt::Write;
    let mut s = String::from("solid test\n");
    for t in &m.tris {
        let v: Vec<[f64; 3]> = t.iter().map(|&i| m.verts[i as usize]).collect();
        writeln!(s, "facet normal 0 0 0\n outer loop")?;
        for p in &v {
            writeln!(s, "  vertex {} {} {}", p[0], p[1], p[2])?;
        }
        writeln!(s, " endloop\nendfacet")?;
    }
    s.push_str("endsolid test\n");
    std::fs::write(path, s)?;
    Ok(())
}

#[derive(Clone, Debug)]
pub struct Hole {
    pub cx: f64,
    pub cy: f64,
    pub r: f64,
    /// Z range over which the hole was seen (sampled, so approximate).
    pub z0: f64,
    pub z1: f64,
}

impl Mesh {
    /// Vertical circular holes: slice at several heights, keep inner loops that are
    /// circles, and merge ones that line up between slices.
    pub fn detect_holes(&self) -> Vec<Hole> {
        let (lo, hi) = self.bounds();
        let n = 12usize;
        let mut found: Vec<(Hole, usize)> = vec![];
        let mut samples = 0;
        for k in 0..n {
            let z = lo[2] + (hi[2] - lo[2]) * (k as f64 + 0.5) / n as f64;
            let polys = self.slice(z);
            samples += 1;
            for poly in &polys {
                let a = area(poly);
                // Clipper output: outer loops positive, holes negative
                if a >= 0.0 || poly.len() < 8 {
                    continue;
                }
                let c = (poly.iter().map(|p| p.0).sum::<f64>() / poly.len() as f64, poly.iter().map(|p| p.1).sum::<f64>() / poly.len() as f64);
                let rs: Vec<f64> = poly.iter().map(|p| ((p.0 - c.0).powi(2) + (p.1 - c.1).powi(2)).sqrt()).collect();
                let mean = rs.iter().sum::<f64>() / rs.len() as f64;
                let sd = (rs.iter().map(|r| (r - mean).powi(2)).sum::<f64>() / rs.len() as f64).sqrt();
                if mean < 0.4 || sd / mean > 0.03 {
                    continue;
                }
                match found.iter_mut().find(|(h, _)| (h.cx - c.0).abs() < 0.3 && (h.cy - c.1).abs() < 0.3 && (h.r - mean).abs() < 0.3) {
                    Some((h, cnt)) => {
                        h.z0 = h.z0.min(z);
                        h.z1 = h.z1.max(z);
                        *cnt += 1;
                    }
                    None => found.push((Hole { cx: c.0, cy: c.1, r: mean, z0: z, z1: z }, 1)),
                }
            }
        }
        let _ = samples;
        // must persist over at least 2 samples to count as a hole (not a small feature)
        let mut out: Vec<Hole> = found.into_iter().filter(|(_, c)| *c >= 2).map(|(h, _)| h).collect();
        // The samples only bracket the hole; find where it really starts and ends.
        let step = (hi[2] - lo[2]) / n as f64;
        for h in &mut out {
            let eps = 1e-3;
            let below = (h.z0 - step).max(lo[2] + eps);
            h.z0 = if below >= h.z0 {
                lo[2]
            } else if self.hole_present(below, h) {
                lo[2]
            } else {
                self.bisect_hole(h, below, h.z0)
            };
            let above = (h.z1 + step).min(hi[2] - eps);
            h.z1 = if above <= h.z1 {
                hi[2]
            } else if self.hole_present(above, h) {
                hi[2]
            } else {
                self.bisect_hole(h, above, h.z1)
            };
        }
        out
    }

    /// Is the circular hole `h` still open at height `z`?
    fn hole_present(&self, z: f64, h: &Hole) -> bool {
        self.slice(z).iter().any(|poly| {
            if area(poly) >= 0.0 || poly.len() < 8 {
                return false;
            }
            let n = poly.len() as f64;
            let c = (poly.iter().map(|p| p.0).sum::<f64>() / n, poly.iter().map(|p| p.1).sum::<f64>() / n);
            let mean = poly.iter().map(|p| ((p.0 - c.0).powi(2) + (p.1 - c.1).powi(2)).sqrt()).sum::<f64>() / n;
            (c.0 - h.cx).abs() < 0.3 && (c.1 - h.cy).abs() < 0.3 && (mean - h.r).abs() < 0.3
        })
    }

    /// Edge of the hole between `absent` (no hole) and `present` (hole), to ~0.01 mm.
    fn bisect_hole(&self, h: &Hole, mut absent: f64, mut present: f64) -> f64 {
        for _ in 0..12 {
            let mid = 0.5 * (absent + present);
            if self.hole_present(mid, h) {
                present = mid;
            } else {
                absent = mid;
            }
        }
        present
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn washer_has_one_round_hole() {
        let m = washer(30.0, 8.0, 6.0, 96);
        let h = m.detect_holes();
        assert_eq!(h.len(), 1, "{h:?}");
        assert!((h[0].r - 8.0).abs() < 0.1 && h[0].cx.abs() < 0.1 && h[0].cy.abs() < 0.1, "{h:?}");
        // a through hole spans the whole height
        assert!(h[0].z0 < 0.01 && h[0].z1 > 5.99, "{h:?}");
    }

    /// A counterbore: the 20 mm hole exists only in the top half, so its z range must say so.
    #[test]
    fn blind_hole_reports_its_real_height_range() {
        use crate::mesh::washer;
        // stack: solid disc 0..6 (no hole) + washer with 10 mm hole 6..12, same outer radius
        let mut base = boxes(&[[-30.0, -30.0, 0.0, 30.0, 30.0, 6.0]]);
        let top = washer(30.0, 10.0, 6.0, 96);
        let off = base.verts.len() as u32;
        for v in &top.verts {
            base.verts.push([v[0], v[1], v[2] + 6.0]);
        }
        for t in &top.tris {
            base.tris.push([t[0] + off, t[1] + off, t[2] + off]);
        }
        let m = Mesh::new(base.verts, base.tris);
        let h = m.detect_holes();
        assert_eq!(h.len(), 1, "{h:?}");
        assert!((h[0].z0 - 6.0).abs() < 0.05, "starts at the floor: {h:?}");
        assert!(h[0].z1 > 11.99, "open to the top: {h:?}");
    }
}

#[cfg(test)]
mod slice_tests {
    use super::*;

    /// Slicing exactly through vertex heights must not lose or break loops.
    #[test]
    fn slice_through_vertex_planes_keeps_loops() {
        let m = washer(30.0, 8.0, 6.0, 96);
        for z in [0.0001, 1.0, 3.0, 5.9999] {
            let p = m.slice(z);
            assert_eq!(p.len(), 2, "z={z}: expected outer + hole loop");
        }
        // exactly on the top and bottom vertex planes: must not panic or return garbage
        for z in [0.0, 6.0] {
            let p = m.slice(z);
            assert!(p.len() <= 2, "z={z}");
        }
    }
}

/// Mesh made of axis-aligned boxes (x0,y0,z0,x1,y1,z1). Boxes may touch but must not overlap.
pub fn boxes(list: &[[f64; 6]]) -> Mesh {
    let mut v: Vec<[f64; 3]> = vec![];
    let mut t: Vec<[u32; 3]> = vec![];
    for b in list {
        let o = v.len() as u32;
        for &z in &[b[2], b[5]] {
            for &(x, y) in &[(b[0], b[1]), (b[3], b[1]), (b[3], b[4]), (b[0], b[4])] {
                v.push([x, y, z]);
            }
        }
        // bottom (0..3), top (4..7), outward winding
        for q in [[0, 3, 2, 1], [4, 5, 6, 7], [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7]] {
            t.push([o + q[0], o + q[1], o + q[2]]);
            t.push([o + q[0], o + q[2], o + q[3]]);
        }
    }
    Mesh::new(v, t)
}

/// Named test parts for exercising supports, bridges and overhangs.
pub fn test_shape(name: &str) -> Option<Mesh> {
    match name {
        // stem with a wide cap: 15 mm ledges on two sides
        "tee" => Some(boxes(&[[-5.0, -5.0, 0.0, 5.0, 5.0, 15.0], [-20.0, -8.0, 15.0, 20.0, 8.0, 20.0]])),
        // two pillars joined by a beam: a 24 mm bridge
        "bridge" => Some(boxes(&[[-20.0, -5.0, 0.0, -12.0, 5.0, 15.0], [12.0, -5.0, 0.0, 20.0, 5.0, 15.0], [-20.0, -5.0, 15.0, 20.0, 5.0, 18.0]])),
        // stepped pyramid: every step overhangs 3 mm
        "steps" => Some(boxes(&[
            [-10.0, -10.0, 0.0, 10.0, 10.0, 6.0],
            [-13.0, -13.0, 6.0, 13.0, 13.0, 12.0],
            [-16.0, -16.0, 12.0, 16.0, 16.0, 18.0],
        ])),
        _ => None,
    }
}
