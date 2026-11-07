//! Bambu Studio profile library: discovery, `inherits`/`include` resolution and
//! mapping of the resolved settings onto the engine's `Config` / `Printer`.
use anyhow::{anyhow, Context, Result};
use serde_json::{Map, Value};
use std::collections::HashMap;
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, PartialEq, Eq, Debug, Hash)]
pub enum Kind {
    Machine,
    Filament,
    Process,
}
impl Kind {
    fn dir(self) -> &'static str {
        match self {
            Kind::Machine => "machine",
            Kind::Filament => "filament",
            Kind::Process => "process",
        }
    }
}

#[derive(Clone, Debug)]
pub struct Entry {
    pub name: String,
    pub path: PathBuf,
    pub user: bool,
    /// `instantiation: true` presets are selectable; others are abstract bases.
    pub selectable: bool,
    pub compatible_printers: Vec<String>,
}

pub type Settings = Map<String, Value>;

pub struct Library {
    pub root: PathBuf,
    entries: HashMap<Kind, Vec<Entry>>,
    by_name: HashMap<(Kind, String), usize>,
}

impl Library {
    /// `%APPDATA%\BambuStudio` on Windows.
    pub fn default_root() -> Option<PathBuf> {
        let base = std::env::var_os("APPDATA")?;
        let p = PathBuf::from(base).join("BambuStudio");
        p.exists().then_some(p)
    }

    pub fn discover() -> Result<Library> {
        let root = Self::default_root().ok_or_else(|| anyhow!("Bambu Studio folder not found in %APPDATA%"))?;
        Self::load(&root)
    }

    pub fn load(root: &Path) -> Result<Library> {
        let mut lib = Library { root: root.to_path_buf(), entries: HashMap::new(), by_name: HashMap::new() };
        for kind in [Kind::Machine, Kind::Filament, Kind::Process] {
            let mut dirs: Vec<(PathBuf, bool)> = vec![];
            let sys = root.join("system");
            if let Ok(rd) = std::fs::read_dir(&sys) {
                for e in rd.flatten() {
                    if e.path().is_dir() {
                        dirs.push((e.path().join(kind.dir()), false));
                    }
                }
            }
            if let Ok(rd) = std::fs::read_dir(root.join("user")) {
                for e in rd.flatten() {
                    if e.path().is_dir() {
                        dirs.push((e.path().join(kind.dir()), true));
                    }
                }
            }
            let mut list = vec![];
            for (dir, user) in dirs {
                let Ok(rd) = std::fs::read_dir(&dir) else { continue };
                for f in rd.flatten() {
                    let p = f.path();
                    if p.extension().and_then(|e| e.to_str()) != Some("json") {
                        continue;
                    }
                    let Ok(txt) = std::fs::read_to_string(&p) else { continue };
                    let Ok(v) = serde_json::from_str::<Value>(&txt) else { continue };
                    let Some(name) = v.get("name").and_then(|n| n.as_str()) else { continue };
                    let selectable = match v.get("instantiation") {
                        Some(Value::String(s)) => s == "true",
                        Some(Value::Bool(b)) => *b,
                        _ => user, // user presets are always selectable
                    };
                    let compatible_printers = match v.get("compatible_printers") {
                        Some(Value::Array(a)) => a.iter().filter_map(|x| x.as_str().map(String::from)).collect(),
                        _ => vec![],
                    };
                    list.push(Entry { name: name.to_string(), path: p, user, selectable, compatible_printers });
                }
            }
            list.sort_by(|a, b| a.name.cmp(&b.name));
            for (i, e) in list.iter().enumerate() {
                // user presets shadow system presets of the same name
                if e.user || !lib.by_name.contains_key(&(kind, e.name.clone())) {
                    lib.by_name.insert((kind, e.name.clone()), i);
                }
            }
            lib.entries.insert(kind, list);
        }
        Ok(lib)
    }

    pub fn list(&self, kind: Kind) -> &[Entry] {
        self.entries.get(&kind).map(|v| v.as_slice()).unwrap_or(&[])
    }

    /// Selectable machine presets.
    pub fn machines(&self) -> Vec<&Entry> {
        self.list(Kind::Machine).iter().filter(|e| e.selectable).collect()
    }

    /// Selectable filament/process presets compatible with `machine` (by name).
    /// Presets with an empty compatibility list are compatible with everything.
    pub fn compatible(&self, kind: Kind, machine: &str) -> Vec<&Entry> {
        self.list(kind)
            .iter()
            .filter(|e| e.selectable && (e.compatible_printers.is_empty() || e.compatible_printers.iter().any(|p| p == machine)))
            .collect()
    }

    fn find(&self, kind: Kind, name: &str) -> Option<&Entry> {
        self.by_name.get(&(kind, name.to_string())).map(|&i| &self.list(kind)[i])
    }

    fn read(&self, kind: Kind, name: &str) -> Result<Settings> {
        let e = self.find(kind, name).ok_or_else(|| anyhow!("{:?} preset '{}' not found", kind, name))?;
        let txt = std::fs::read_to_string(&e.path).with_context(|| format!("reading {}", e.path.display()))?;
        match serde_json::from_str::<Value>(&txt)? {
            Value::Object(m) => Ok(m),
            _ => Err(anyhow!("{} is not a JSON object", e.path.display())),
        }
    }

    /// Fully resolved preset: base-most parent first, children override, then
    /// `include`d templates (e.g. machine start-G-code) fill in.
    pub fn resolve(&self, kind: Kind, name: &str) -> Result<Settings> {
        let mut chain = vec![];
        let mut cur = Some(name.to_string());
        while let Some(n) = cur {
            if chain.len() > 16 {
                return Err(anyhow!("inherits chain too deep at '{}'", n));
            }
            let s = self.read(kind, &n)?;
            cur = s.get("inherits").and_then(|v| v.as_str()).filter(|x| !x.is_empty()).map(String::from);
            chain.push(s);
        }
        let mut out = Settings::new();
        for s in chain.into_iter().rev() {
            // included templates fill in first; the preset's own keys then override them
            if let Some(Value::Array(a)) = s.get("include") {
                for inc in a.iter().filter_map(|x| x.as_str()) {
                    if let Ok(t) = self.read(kind, inc) {
                        for (tk, tv) in t {
                            if !matches!(tk.as_str(), "name" | "instantiation" | "inherits" | "type" | "from") {
                                out.insert(tk, tv);
                            }
                        }
                    }
                }
            }
            for (k, v) in s {
                if k != "include" {
                    out.insert(k, v);
                }
            }
        }
        Ok(out)
    }
}

// ---------- value helpers ----------

/// Scalar value: first element of per-extruder arrays.
pub fn scalar<'a>(s: &'a Settings, key: &str) -> Option<&'a Value> {
    match s.get(key)? {
        Value::Array(a) => a.first(),
        v => Some(v),
    }
}
pub fn get_f(s: &Settings, key: &str) -> Option<f64> {
    match scalar(s, key)? {
        Value::String(t) => t.trim().trim_end_matches('%').parse().ok(),
        Value::Number(n) => n.as_f64(),
        _ => None,
    }
}
pub fn get_s(s: &Settings, key: &str) -> Option<String> {
    match scalar(s, key)? {
        Value::String(t) => Some(t.clone()),
        Value::Number(n) => Some(n.to_string()),
        _ => None,
    }
}
pub(crate) fn get_f_idx(s: &Settings, key: &str, i: usize) -> Option<f64> {
    match s.get(key)? {
        Value::Array(a) => a.get(i).or(a.first()).and_then(|v| v.as_str()).and_then(|t| t.parse().ok()),
        _ => get_f(s, key),
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum BedType {
    Cool,
    Engineering,
    HighTemp,
    TexturedPei,
}
impl BedType {
    pub const ALL: [BedType; 4] = [BedType::TexturedPei, BedType::Cool, BedType::Engineering, BedType::HighTemp];
    pub fn label(self) -> &'static str {
        match self {
            BedType::Cool => "Cool Plate",
            BedType::Engineering => "Engineering Plate",
            BedType::HighTemp => "High Temp Plate",
            BedType::TexturedPei => "Textured PEI Plate",
        }
    }
    pub(crate) fn key(self) -> &'static str {
        match self {
            BedType::Cool => "cool_plate_temp",
            BedType::Engineering => "eng_plate_temp",
            BedType::HighTemp => "hot_plate_temp",
            BedType::TexturedPei => "textured_plate_temp",
        }
    }
}

pub use crate::bbl_import::*;
