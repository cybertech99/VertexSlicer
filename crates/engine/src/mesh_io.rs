//! Model import (STL, OBJ, 3MF) and geometric transforms.
use crate::mesh::Mesh;
use anyhow::{anyhow, bail, Context, Result};
use std::collections::HashMap;
use std::io::Read;

pub type Mat3 = [[f64; 3]; 3];
pub const IDENT: Mat3 = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];

pub fn mat_mul(a: &Mat3, b: &Mat3) -> Mat3 {
    let mut r = [[0.0; 3]; 3];
    for i in 0..3 {
        for j in 0..3 {
            r[i][j] = (0..3).map(|k| a[i][k] * b[k][j]).sum();
        }
    }
    r
}

pub fn rot_x(deg: f64) -> Mat3 {
    let (s, c) = deg.to_radians().sin_cos();
    [[1.0, 0.0, 0.0], [0.0, c, -s], [0.0, s, c]]
}
pub fn rot_y(deg: f64) -> Mat3 {
    let (s, c) = deg.to_radians().sin_cos();
    [[c, 0.0, s], [0.0, 1.0, 0.0], [-s, 0.0, c]]
}
pub fn rot_z(deg: f64) -> Mat3 {
    let (s, c) = deg.to_radians().sin_cos();
    [[c, -s, 0.0], [s, c, 0.0], [0.0, 0.0, 1.0]]
}

/// Rotation that carries unit vector `from` onto `to` (Rodrigues).
pub fn rotation_aligning(from: [f64; 3], to: [f64; 3]) -> Mat3 {
    let n = |v: [f64; 3]| {
        let l = (v[0] * v[0] + v[1] * v[1] + v[2] * v[2]).sqrt();
        [v[0] / l, v[1] / l, v[2] / l]
    };
    let (f, t) = (n(from), n(to));
    let v = [f[1] * t[2] - f[2] * t[1], f[2] * t[0] - f[0] * t[2], f[0] * t[1] - f[1] * t[0]];
    let c = f[0] * t[0] + f[1] * t[1] + f[2] * t[2];
    if c > 1.0 - 1e-12 {
        return IDENT;
    }
    if c < -1.0 + 1e-12 {
        // opposite: half-turn about any axis perpendicular to `from`
        let axis = if f[0].abs() < 0.9 { [1.0, 0.0, 0.0] } else { [0.0, 1.0, 0.0] };
        let p = n([f[1] * axis[2] - f[2] * axis[1], f[2] * axis[0] - f[0] * axis[2], f[0] * axis[1] - f[1] * axis[0]]);
        return [
            [2.0 * p[0] * p[0] - 1.0, 2.0 * p[0] * p[1], 2.0 * p[0] * p[2]],
            [2.0 * p[1] * p[0], 2.0 * p[1] * p[1] - 1.0, 2.0 * p[1] * p[2]],
            [2.0 * p[2] * p[0], 2.0 * p[2] * p[1], 2.0 * p[2] * p[2] - 1.0],
        ];
    }
    let k = 1.0 / (1.0 + c);
    let vx = [[0.0, -v[2], v[1]], [v[2], 0.0, -v[0]], [-v[1], v[0], 0.0]];
    let vx2 = mat_mul(&vx, &vx);
    let mut r = IDENT;
    for i in 0..3 {
        for j in 0..3 {
            r[i][j] += vx[i][j] + vx2[i][j] * k;
        }
    }
    r
}

pub fn apply(m: &Mat3, v: [f64; 3]) -> [f64; 3] {
    [
        m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
        m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
        m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
    ]
}

fn det(m: &Mat3) -> f64 {
    m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
}

impl Mesh {
    /// New mesh with every vertex transformed by `m` (a mirroring matrix flips the winding back).
    pub fn transformed(&self, m: &Mat3) -> Mesh {
        let verts: Vec<[f64; 3]> = self.verts.iter().map(|&v| apply(m, v)).collect();
        let mut tris = self.tris.clone();
        if det(m) < 0.0 {
            for t in &mut tris {
                t.swap(1, 2);
            }
        }
        Mesh::new(verts, tris)
    }
}

// ---------------- importers ----------------

pub fn load_any(path: &str) -> Result<Mesh> {
    let lower = path.to_lowercase();
    if lower.ends_with(".stl") {
        Mesh::load_stl(path)
    } else if lower.ends_with(".obj") {
        load_obj(path)
    } else if lower.ends_with(".3mf") {
        load_3mf(path)
    } else {
        bail!("unsupported file type (use .stl, .obj or .3mf)")
    }
}

fn load_obj(path: &str) -> Result<Mesh> {
    let txt = std::fs::read_to_string(path).with_context(|| format!("reading {path}"))?;
    let mut verts: Vec<[f64; 3]> = vec![];
    let mut tris: Vec<[u32; 3]> = vec![];
    for line in txt.lines() {
        let mut it = line.split_whitespace();
        match it.next() {
            Some("v") => {
                let c: Vec<f64> = it.take(3).filter_map(|x| x.parse().ok()).collect();
                if c.len() == 3 {
                    verts.push([c[0], c[1], c[2]]);
                }
            }
            Some("f") => {
                let idx: Vec<u32> = it
                    .filter_map(|tok| tok.split('/').next()?.parse::<i64>().ok())
                    .map(|i| if i < 0 { (verts.len() as i64 + i) as u32 } else { (i - 1) as u32 })
                    .collect();
                for k in 1..idx.len().saturating_sub(1) {
                    tris.push([idx[0], idx[k], idx[k + 1]]);
                }
            }
            _ => {}
        }
    }
    if tris.is_empty() {
        bail!("OBJ file has no faces");
    }
    if tris.iter().flatten().any(|&i| i as usize >= verts.len()) {
        bail!("OBJ face refers to a missing vertex");
    }
    Ok(Mesh::new(verts, tris))
}

struct Tag {
    name: String,
    attrs: HashMap<String, String>,
    closing: bool,
}

/// Minimal XML tag scanner (enough for the 3MF model part).
fn tags(xml: &str) -> Vec<Tag> {
    let b = xml.as_bytes();
    let mut out = vec![];
    let mut i = 0;
    while i < b.len() {
        if b[i] != b'<' {
            i += 1;
            continue;
        }
        let Some(end) = xml[i..].find('>') else { break };
        let body = &xml[i + 1..i + end];
        i += end + 1;
        if body.starts_with('?') || body.starts_with('!') {
            continue;
        }
        let closing = body.starts_with('/');
        let body = body.trim_start_matches('/').trim_end_matches('/');
        let mut parts = body.splitn(2, char::is_whitespace);
        let name = parts.next().unwrap_or("").to_string();
        let mut attrs = HashMap::new();
        let mut rest = parts.next().unwrap_or("");
        while let Some(eq) = rest.find('=') {
            let key = rest[..eq].trim().to_string();
            let after = rest[eq + 1..].trim_start();
            let q = after.chars().next().unwrap_or('"');
            let Some(close) = after[1..].find(q) else { break };
            attrs.insert(key, after[1..1 + close].to_string());
            rest = &after[close + 2..];
        }
        out.push(Tag { name, attrs, closing });
    }
    out
}

fn load_3mf(path: &str) -> Result<Mesh> {
    let mut zip = zip::ZipArchive::new(std::fs::File::open(path)?)?;
    // the model part is normally 3D/3dmodel.model; follow the rels file if it says otherwise
    let mut model_name = "3D/3dmodel.model".to_string();
    if zip.by_name(&model_name).is_err() {
        let found = (0..zip.len()).filter_map(|i| zip.by_index(i).ok().map(|f| f.name().to_string())).find(|n| n.to_lowercase().ends_with(".model"));
        model_name = found.ok_or_else(|| anyhow!("3MF has no model part"))?;
    }
    let mut xml = String::new();
    zip.by_name(&model_name)?.read_to_string(&mut xml)?;

    // objects: id -> (verts, tris); components reference other objects
    struct Obj {
        verts: Vec<[f64; 3]>,
        tris: Vec<[u32; 3]>,
        comps: Vec<(String, Mat12)>,
    }
    type Mat12 = [f64; 12];
    let parse12 = |s: &str| -> Mat12 {
        let v: Vec<f64> = s.split_whitespace().filter_map(|x| x.parse().ok()).collect();
        if v.len() == 12 { std::array::from_fn(|i| v[i]) } else { [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] }
    };
    let mut objects: HashMap<String, Obj> = HashMap::new();
    let mut cur: Option<(String, Obj)> = None;
    let mut build: Vec<(String, Mat12)> = vec![];
    for t in tags(&xml) {
        match (t.name.as_str(), t.closing) {
            ("object", false) => cur = Some((t.attrs.get("id").cloned().unwrap_or_default(), Obj { verts: vec![], tris: vec![], comps: vec![] })),
            ("object", true) => {
                if let Some((id, o)) = cur.take() {
                    objects.insert(id, o);
                }
            }
            ("vertex", false) => {
                if let Some((_, o)) = cur.as_mut() {
                    let g = |k: &str| t.attrs.get(k).and_then(|v| v.parse::<f64>().ok()).unwrap_or(0.0);
                    o.verts.push([g("x"), g("y"), g("z")]);
                }
            }
            ("triangle", false) => {
                if let Some((_, o)) = cur.as_mut() {
                    let g = |k: &str| t.attrs.get(k).and_then(|v| v.parse::<u32>().ok()).unwrap_or(0);
                    o.tris.push([g("v1"), g("v2"), g("v3")]);
                }
            }
            ("component", false) => {
                if let Some((_, o)) = cur.as_mut() {
                    if let Some(id) = t.attrs.get("objectid") {
                        o.comps.push((id.clone(), t.attrs.get("transform").map(|s| parse12(s)).unwrap_or(parse12(""))));
                    }
                }
            }
            ("item", false) => {
                if let Some(id) = t.attrs.get("objectid") {
                    build.push((id.clone(), t.attrs.get("transform").map(|s| parse12(s)).unwrap_or(parse12(""))));
                }
            }
            _ => {}
        }
    }
    if build.is_empty() {
        build = objects.keys().map(|k| (k.clone(), parse12(""))).collect();
    }
    // 3MF transform = row-vector convention: p' = [x y z 1] * M (m00 m01 m02 / m10 .. / tx ty tz)
    let xf = |m: &Mat12, p: [f64; 3]| -> [f64; 3] {
        [
            p[0] * m[0] + p[1] * m[3] + p[2] * m[6] + m[9],
            p[0] * m[1] + p[1] * m[4] + p[2] * m[7] + m[10],
            p[0] * m[2] + p[1] * m[5] + p[2] * m[8] + m[11],
        ]
    };
    fn emit(objects: &HashMap<String, Obj>, id: &str, chain: &[Mat12], depth: usize, verts: &mut Vec<[f64; 3]>, tris: &mut Vec<[u32; 3]>, xf: &dyn Fn(&Mat12, [f64; 3]) -> [f64; 3]) {
        if depth > 8 {
            return;
        }
        let Some(o) = objects.get(id) else { return };
        let base = verts.len() as u32;
        for &v in &o.verts {
            let mut p = v;
            for m in chain.iter().rev() {
                p = xf(m, p);
            }
            verts.push(p);
        }
        for t in &o.tris {
            tris.push([base + t[0], base + t[1], base + t[2]]);
        }
        for (cid, cm) in &o.comps {
            let mut c = chain.to_vec();
            c.push(*cm);
            emit(objects, cid, &c, depth + 1, verts, tris, xf);
        }
    }
    let (mut verts, mut tris) = (vec![], vec![]);
    for (id, m) in &build {
        emit(&objects, id, &[*m], 0, &mut verts, &mut tris, &xf);
    }
    if tris.is_empty() {
        bail!("3MF contains no mesh");
    }
    if tris.iter().flatten().any(|&i| i as usize >= verts.len()) {
        bail!("3MF triangle refers to a missing vertex");
    }
    Ok(Mesh::new(verts, tris))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rotation_aligns_vectors() {
        let r = rotation_aligning([1.0, 0.0, 0.0], [0.0, 0.0, -1.0]);
        let v = apply(&r, [1.0, 0.0, 0.0]);
        assert!((v[2] + 1.0).abs() < 1e-9 && v[0].abs() < 1e-9, "{v:?}");
        let r = rotation_aligning([0.0, 0.0, 1.0], [0.0, 0.0, -1.0]);
        assert!((apply(&r, [0.0, 0.0, 1.0])[2] + 1.0).abs() < 1e-9);
    }

    #[test]
    fn obj_and_3mf_round_trip() {
        let dir = std::env::temp_dir().join("slicer_io_test");
        std::fs::create_dir_all(&dir).unwrap();
        // OBJ cube made of quads
        let obj = dir.join("cube.obj");
        std::fs::write(&obj, "v 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nv 0 0 1\nv 1 0 1\nv 1 1 1\nv 0 1 1\nf 1 4 3 2\nf 5 6 7 8\nf 1 2 6 5\nf 2 3 7 6\nf 3 4 8 7\nf 4 1 5 8\n").unwrap();
        let m = load_any(obj.to_str().unwrap()).unwrap();
        assert_eq!(m.tris.len(), 12);
        // 3MF with a translated build item
        let p = dir.join("cube.3mf");
        let mut z = zip::ZipWriter::new(std::fs::File::create(&p).unwrap());
        z.start_file("3D/3dmodel.model", zip::write::SimpleFileOptions::default()).unwrap();
        use std::io::Write;
        z.write_all(br#"<?xml version="1.0"?><model><resources><object id="1" type="model"><mesh><vertices><vertex x="0" y="0" z="0"/><vertex x="10" y="0" z="0"/><vertex x="0" y="10" z="0"/><vertex x="0" y="0" z="10"/></vertices><triangles><triangle v1="0" v2="2" v3="1"/><triangle v1="0" v2="1" v3="3"/><triangle v1="1" v2="2" v3="3"/><triangle v1="2" v2="0" v3="3"/></triangles></mesh></object></resources><build><item objectid="1" transform="1 0 0 0 1 0 0 0 1 100 50 0"/></build></model>"#).unwrap();
        z.finish().unwrap();
        let m = load_any(p.to_str().unwrap()).unwrap();
        let (lo, hi) = m.bounds();
        assert_eq!((lo[0], hi[0], lo[1], hi[1]), (100.0, 110.0, 50.0, 60.0));
    }
}
