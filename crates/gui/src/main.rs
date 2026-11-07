mod gl;
mod job;
mod theme;

use eframe::egui::{self, Color32, RichText};
use engine::bbl::{self, BedType, Imported, Kind, Library};
use engine::infill::Pattern;
use engine::mesh::{self, Hole, Mesh};
use engine::mesh_io::{self, mat_mul, rot_x, rot_y, rot_z, Mat3, IDENT};
use serde::{Deserialize, Serialize};
use engine::pick::{Adjacency, Patch, PatchKind};
use glam::{Mat4, Vec3};
use job::{SliceInput, SliceOut, ZoneSpec, ZoneShape};
use std::sync::{mpsc, Arc, Mutex};

const ORANGE: [f32; 3] = [1.0, 0.55, 0.1];
const YELLOW: [f32; 3] = [1.0, 0.95, 0.3];

#[derive(Clone, Copy, PartialEq, Serialize, Deserialize)]
enum ZKind {
    Cylinder,
    Box,
}

#[derive(Clone, Serialize, Deserialize)]
struct ZoneUi {
    name: String,
    kind: ZKind,
    cx: f64,
    cy: f64,
    r: f64,
    w: f64,
    d: f64,
    use_z: bool,
    z0: f64,
    z1: f64,
    wall_h: f64,
    infill_h: f64,
    #[serde(default)]
    solid: bool,
    /// infill layer height follows the current default instead of its own value
    #[serde(default)]
    infill_inherit: bool,
    /// inner radius of a cylinder zone; 0 = a full disc, > 0 = a ring (zone going inward from an outside face)
    #[serde(default)]
    r_in: f64,
    /// infill pattern label for this zone; empty = use the global pattern
    #[serde(default)]
    pattern: String,
    /// sparse infill percent for this zone; 0 = use the print's value
    #[serde(default)]
    infill_pct: f64,
    /// AMS slot this zone prints in (None = the object's filament)
    #[serde(default)]
    filament: Option<u8>,
}

/// One AMS slot in the filament list.
#[derive(Clone, Serialize, Deserialize)]
struct SlotUi {
    filament: String,
    /// on the right hotend (otherwise the left)
    right: bool,
    colour: [u8; 3],
    /// AMS position, e.g. "A2" or "L ext"
    #[serde(default)]
    label: String,
}

const SLOT_COLOURS: [[u8; 3]; 8] = [[240, 240, 240], [30, 30, 30], [247, 35, 35], [255, 210, 40], [40, 120, 230], [60, 180, 80], [240, 130, 30], [160, 80, 200]];

#[derive(Clone, Copy, PartialEq, Default, Serialize, Deserialize)]
enum AmsKind {
    /// 4-tray AMS / AMS 2 Pro
    #[default]
    Ams,
    /// single-tray AMS HT
    AmsHt,
}

impl AmsKind {
    fn trays(self) -> usize {
        match self {
            AmsKind::Ams => 4,
            AmsKind::AmsHt => 1,
        }
    }
}

#[derive(Clone, Default, Serialize, Deserialize)]
struct Tray {
    /// filament preset; empty = nothing loaded
    filament: String,
    colour: [u8; 3],
}

#[derive(Clone, Serialize, Deserialize)]
struct AmsUnit {
    kind: AmsKind,
    trays: Vec<Tray>,
}

impl AmsUnit {
    fn new(kind: AmsKind) -> Self {
        AmsUnit { kind, trays: (0..kind.trays()).map(|t| Tray { filament: String::new(), colour: SLOT_COLOURS[t % SLOT_COLOURS.len()] }).collect() }
    }
}

/// Which AMS units hang off each H2D hotend, and what is loaded in every tray.
#[derive(Clone, Default, Serialize, Deserialize)]
struct AmsSetup {
    left: Vec<AmsUnit>,
    right: Vec<AmsUnit>,
    #[serde(default)]
    left_ext: Option<Tray>,
    #[serde(default)]
    right_ext: Option<Tray>,
}

impl AmsSetup {
    /// Every loaded position as (label, on the right hotend, tray), in slot order.
    /// Units are lettered A, B, C… across the left side first, then the right.
    fn positions(&self) -> Vec<(String, bool, Tray)> {
        let mut out = vec![];
        let mut letter = b'A';
        for (right, units, ext) in [(false, &self.left, &self.left_ext), (true, &self.right, &self.right_ext)] {
            for u in units {
                for (i, t) in u.trays.iter().enumerate() {
                    if !t.filament.is_empty() {
                        out.push((format!("{}{}", letter as char, i + 1), right, t.clone()));
                    }
                }
                letter += 1;
            }
            if let Some(t) = ext {
                if !t.filament.is_empty() {
                    out.push((format!("{} ext", if right { "R" } else { "L" }), right, t.clone()));
                }
            }
        }
        out
    }
}

/// Short name of a filament slot for pickers: "A2 · Bambu PLA Basic".
fn slot_name(i: usize, s: &SlotUi) -> String {
    let tag = if s.label.is_empty() { (i + 1).to_string() } else { s.label.clone() };
    format!("{tag} · {}", s.filament)
}

fn default_tower() -> [f64; 5] {
    [178.5, 195.1, 30.0, 28.0, 80.0]
}

struct Filter {
    text: String,
}

#[derive(Clone, Copy, PartialEq)]
enum PickKind {
    Zone,
    LayFlat,
}

#[derive(Clone, Copy, PartialEq)]
enum Tab {
    Prepare,
    Preview,
    Device,
}

#[derive(Clone, Copy, PartialEq)]
enum ColorBy {
    Height,
    Feature,
    Filament,
}

/// Remembered between runs (%APPDATA%\VertexSlicer\settings.json).
#[derive(Serialize, Deserialize, Default)]
struct Saved {
    machine: String,
    filament: String,
    process: String,
    bed: String,
    #[serde(default)]
    ams: AmsSetup,
}

/// Vertical mouse-wheel movement this frame, in points (a wheel notch is about 50).
fn wheel_delta(ui: &egui::Ui) -> f32 {
    ui.input(|i| {
        i.raw
            .events
            .iter()
            .filter_map(|e| match e {
                egui::Event::MouseWheel { unit, delta, .. } => Some(match unit {
                    egui::MouseWheelUnit::Line => delta.y * 50.0,
                    egui::MouseWheelUnit::Page => delta.y * 400.0,
                    egui::MouseWheelUnit::Point => delta.y,
                }),
                _ => None,
            })
            .sum()
    })
}

/// Turn mouse-wheel movement into whole steps: one wheel notch = one step, and small trackpad
/// movements add up until they are worth a step.
fn wheel_steps(accum: &mut f32, delta: f32) -> i64 {
    if delta == 0.0 {
        return 0;
    }
    *accum += delta;
    if accum.abs() >= 30.0 {
        let s = accum.signum() as i64;
        *accum = 0.0;
        s
    } else {
        0
    }
}

fn settings_path() -> Option<std::path::PathBuf> {
    let base = std::env::var_os("APPDATA")?;
    let base = std::path::PathBuf::from(base);
    let path = base.join("VertexSlicer").join("settings.json");
    // carry settings over from the app's earlier name
    let old = base.join("MixedLayerSlicer").join("settings.json");
    if !path.exists() && old.exists() {
        let _ = std::fs::create_dir_all(path.parent()?);
        let _ = std::fs::copy(&old, &path);
    }
    Some(path)
}

/// A saved project: model + transform + presets + settings + zones.
#[derive(Serialize, Deserialize)]
struct ProjectFile {
    version: u32,
    model_path: String,
    xf: [[f64; 3]; 3],
    scale_pct: f64,
    pos: (f64, f64),
    machine: String,
    filament: String,
    process: String,
    bed: String,
    base: f64,
    wall_h: f64,
    infill_h: f64,
    walls: u32,
    density_pct: f64,
    pattern: String,
    support: bool,
    support_plate_only: bool,
    brim: f64,
    skirt: u32,
    #[serde(default = "default_zone_walls")]
    zone_walls: u32,
    zones: Vec<ZoneUi>,
    #[serde(default)]
    ams: bool,
    #[serde(default)]
    slots: Vec<SlotUi>,
    #[serde(default)]
    object_slot: usize,
    #[serde(default)]
    ams_setup: Option<AmsSetup>,
    #[serde(default = "default_tower")]
    tower: [f64; 5],
    #[serde(default = "default_true")]
    tower_enabled: bool,
    #[serde(default)]
    purge_infill: bool,
}

fn default_true() -> bool {
    true
}

fn default_zone_walls() -> u32 {
    1
}

struct App {
    scene: Arc<Mutex<gl::Scene>>,
    cam: gl::Camera,

    // profiles
    lib: Option<Library>,
    lib_err: Option<String>,
    show_all_printers: bool,
    machine: String,
    filament: String,
    process: String,
    bed: BedType,
    f_machine: Filter,
    f_filament: Filter,
    f_process: Filter,
    imported: Option<Imported>,
    import_err: Option<String>,

    // layer-height controls
    base: f64,
    wall_h: f64,
    infill_h: f64,
    walls: u32,
    density_pct: f64,
    pattern: Pattern,
    support: bool,
    support_plate_only: bool,
    brim: f64,
    skirt: u32,
    zone_walls: u32,

    // AMS / multi-filament
    ams: bool,
    slots: Vec<SlotUi>,
    slot_filters: Vec<Filter>,
    object_slot: usize,
    ams_setup: AmsSetup,
    ams_filters: std::collections::HashMap<String, Filter>,
    /// prime tower x, y, width, depth, purge mm^3
    tower: [f64; 5],
    tower_enabled: bool,
    purge_infill: bool,

    // model
    mesh: Option<Arc<Mesh>>,
    model_name: String,
    lo: [f64; 3],
    hi: [f64; 3],
    pos: (f64, f64),
    holes: Vec<Hole>,
    mesh_base: Option<Arc<Mesh>>,
    xf: Mat3,
    scale_pct: f64,
    model_path: Option<String>,
    project_path: Option<String>,

    // zones
    zones: Vec<ZoneUi>,
    selected: Option<usize>,
    zone_margin: f64,
    face_depth: f64,
    dragging_zone: bool,
    adj: Option<Adjacency>,
    pick_mode: bool,
    pick_kind: PickKind,
    hover_seed: Option<usize>,
    hover_patch: Option<Patch>,

    // slicing
    rx: Option<mpsc::Receiver<Result<SliceOut, String>>>,
    result: Option<SliceOut>,
    layer: usize,
    only_layer: bool,
    show_model: bool,
    show_toolpath: bool,
    color_by: ColorBy,
    tab: Tab,
    status: String,
    scroll_accum: f32,
    frames: u64,
    shot_path: Option<String>,
    shot_requested: bool,

    // undo / redo: serialized snapshots of the editable state
    hist_undo: Vec<String>,
    hist_redo: Vec<String>,
    hist_cur: String,
    /// identity of the loaded model; loading another model starts a fresh history
    hist_model: usize,
}

/// Right-hand space kept free in the left panel for its floating scroll bar.
const SCROLL_GUTTER: f32 = 14.0;

fn main() -> eframe::Result {
    let opts = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_inner_size([1500.0, 900.0]).with_title("VertexSlicer — a mixed-layer slicer for the Bambu Lab H2D"),
        depth_buffer: 24,
        ..Default::default()
    };
    eframe::run_native("vertexslicer", opts, Box::new(|cc| Ok(Box::new(App::new(cc)))))
}

impl App {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        theme::apply(&cc.egui_ctx);
        let gl = cc.gl.as_ref().expect("OpenGL context required");
        let mut scene = gl::Scene::new(gl);
        scene.pending_bed = Some(gl::bed_lines(350.0, 320.0, 325.0));
        scene.pending_bed_fill = Some(gl::bed_fill(350.0, 320.0));
        let (lib, lib_err) = match Library::discover() {
            Ok(l) => (Some(l), None),
            Err(e) => (None, Some(e.to_string())),
        };
        let mut app = App {
            scene: Arc::new(Mutex::new(scene)),
            cam: gl::Camera::new(),
            lib,
            lib_err,
            show_all_printers: false,
            machine: "Bambu Lab H2D 0.4 nozzle".into(),
            filament: String::new(),
            process: String::new(),
            bed: BedType::TexturedPei,
            f_machine: Filter { text: String::new() },
            f_filament: Filter { text: String::new() },
            f_process: Filter { text: String::new() },
            imported: None,
            import_err: None,
            base: 0.1,
            wall_h: 0.2,
            infill_h: 0.2,
            walls: 2,
            density_pct: 15.0,
            pattern: Pattern::Grid,
            support: false,
            support_plate_only: false,
            brim: 0.0,
            skirt: 0,
            zone_walls: 1,
            ams: false,
            slots: vec![],
            slot_filters: vec![],
            object_slot: 0,
            ams_setup: AmsSetup::default(),
            ams_filters: Default::default(),
            tower: default_tower(),
            tower_enabled: true,
            purge_infill: false,
            mesh: None,
            model_name: String::new(),
            lo: [0.0; 3],
            hi: [0.0; 3],
            pos: (175.0, 160.0),
            holes: vec![],
            mesh_base: None,
            xf: IDENT,
            scale_pct: 100.0,
            model_path: None,
            project_path: None,
            zones: vec![],
            selected: None,
            zone_margin: 3.0,
            face_depth: 1.5,
            dragging_zone: false,
            adj: None,
            pick_mode: false,
            pick_kind: PickKind::Zone,
            hover_seed: None,
            hover_patch: None,
            rx: None,
            result: None,
            layer: 1,
            only_layer: false,
            show_model: true,
            show_toolpath: true,
            color_by: ColorBy::Height,
            tab: Tab::Prepare,
            status: "Open a model to begin.".into(),
            scroll_accum: 0.0,
            frames: 0,
            shot_path: std::env::var("SLICER_SHOT").ok(),
            shot_requested: false,
            hist_undo: vec![],
            hist_redo: vec![],
            hist_cur: String::new(),
            hist_model: 0,
        };
        if let Some(saved) = settings_path().and_then(|p| std::fs::read_to_string(p).ok()).and_then(|t| serde_json::from_str::<Saved>(&t).ok()) {
            let exists = |k: Kind, n: &str| app.lib.as_ref().map_or(false, |l| l.list(k).iter().any(|e| e.name == n));
            if exists(Kind::Machine, &saved.machine) {
                app.machine = saved.machine.clone();
                if exists(Kind::Filament, &saved.filament) {
                    app.filament = saved.filament.clone();
                }
                if exists(Kind::Process, &saved.process) {
                    app.process = saved.process.clone();
                }
                if let Some(b) = BedType::ALL.iter().find(|b| b.label() == saved.bed) {
                    app.bed = *b;
                }
            }
            app.ams_setup = saved.ams.clone();
        }
        app.pick_default_presets();
        app.reimport(true);
        app.apply_ams();
        if let Ok(path) = std::env::var("SLICER_STL") {
            app.load_path(&path);
            if let Ok(r) = std::env::var("SLICER_ROT") {
                // test hook: e.g. x90, y-90, z45
                let (axis, deg) = r.split_at(1);
                if let Ok(d) = deg.parse::<f64>() {
                    app.rotate(match axis { "x" => 0, "y" => 1, _ => 2 }, d);
                }
            }
            if std::env::var("SLICER_HOLEZONE").is_ok() {
                if let Some(h) = app.holes.first().cloned() {
                    app.add_zone_for_hole(&h);
                    app.zones[0].solid = std::env::var("SLICER_SOLID").is_ok();
                }
            }
            if std::env::var("SLICER_SUPPORT").is_ok() {
                app.support = true;
            }
            if std::env::var("SLICER_COLOR").as_deref() == Ok("feature") {
                app.color_by = ColorBy::Feature;
            }
            if std::env::var("SLICER_DEVICE").is_ok() {
                // test hook: open the Device page with one AMS on the left and an AMS HT on the right
                app.ams = true;
                let mut setup = app.default_ams();
                let mut ht = AmsUnit::new(AmsKind::AmsHt);
                ht.trays[0].filament = app.filament.clone();
                setup.right.push(ht);
                app.ams_setup = setup;
                app.apply_ams();
                app.tab = Tab::Device;
            }
            if std::env::var("SLICER_AMS").is_ok() {
                // test hook: two slots (left + right hotend), the first zone prints in slot 2
                app.ams = true;
                for (i, right) in [false, true].into_iter().enumerate() {
                    app.slots.push(SlotUi { filament: app.filament.clone(), right, colour: SLOT_COLOURS[i + 1], label: String::new() });
                    app.slot_filters.push(Filter { text: String::new() });
                }
                if let Some(z) = app.zones.first_mut() {
                    z.filament = Some(1);
                }
                app.color_by = ColorBy::Filament;
            }
            app.start_slice();
        }
        if std::env::var("SLICER_DEMO").is_ok() {
            app.set_mesh(mesh::washer(30.0, 8.0, 6.0, 96), "test_washer".into());
            if let Ok(face) = std::env::var("SLICER_FACE") {
                // test hook: pick a face with a fixed ray (hole | top | bottom | outer)
                let (o, d) = match face.as_str() {
                    "hole" => ([0.0, 0.0, 3.0], [1.0, 0.0, 0.0]),
                    "top" => ([20.0, 0.0, 20.0], [0.0, 0.0, -1.0]),
                    "bottom" => ([20.0, 0.0, -20.0], [0.0, 0.0, 1.0]),
                    _ => ([50.0, 0.0, 3.0], [-1.0, 0.0, 0.0]),
                };
                if let (Some(m), Some(adj)) = (app.mesh.clone(), app.adj.as_ref()) {
                    if let Some((t, _)) = m.pick(o, d) {
                        let patch = m.face_patch(adj, t, 12.0, d);
                        app.add_zone_for_patch(&patch);
                        if std::env::var("SLICER_SOLID").is_ok() {
                            if let Some(z) = app.zones.last_mut() {
                                z.solid = true;
                            }
                        }
                        app.hover_patch = Some(patch);
                    }
                }
            } else if let Some(h) = app.holes.first().cloned() {
                app.add_zone_for_hole(&h);
            }
            app.wall_h = 0.2;
            app.infill_h = 0.2;
            app.start_slice();
        }
        app
    }

    // ---------- profiles ----------

    fn pick_default_presets(&mut self) {
        let Some(lib) = &self.lib else { return };
        let fil = lib.compatible(Kind::Filament, &self.machine);
        let pro = lib.compatible(Kind::Process, &self.machine);
        if !fil.iter().any(|e| e.name == self.filament) {
            self.filament = fil
                .iter()
                .find(|e| e.name.contains("Generic PLA") || e.name.contains("Bambu PLA Basic"))
                .or(fil.first())
                .map(|e| e.name.clone())
                .unwrap_or_default();
        }
        if !pro.iter().any(|e| e.name == self.process) {
            self.process = pro
                .iter()
                .find(|e| e.name.starts_with("0.20mm Standard"))
                .or(pro.first())
                .map(|e| e.name.clone())
                .unwrap_or_default();
        }
    }

    /// Re-read the selected presets. `reset_params` also resets the editable layer settings.
    fn reimport(&mut self, reset_params: bool) {
        let Some(lib) = &self.lib else { return };
        match bbl::import(lib, &self.machine, &self.filament, &self.process, self.bed) {
            Ok(i) => {
                if reset_params {
                    self.base = ((i.layer_height / 2.0) * 1000.0).round() / 1000.0;
                    self.wall_h = i.layer_height;
                    self.infill_h = i.layer_height;
                    self.walls = i.walls;
                    self.density_pct = (i.density * 100.0).round();
                    self.pattern = i.pattern;
                    self.support = i.support_enable;
                    self.support_plate_only = i.support_on_plate_only;
                    self.brim = i.brim_width;
                    self.skirt = i.skirt_loops;
                }
                self.bed_to_scene(&i);
                self.imported = Some(i);
                self.import_err = None;
            }
            Err(e) => {
                self.import_err = Some(format!("{e:#}"));
                self.imported = None;
            }
        }
    }

    fn bed_to_scene(&mut self, i: &Imported) {
        let mut sc = self.scene.lock().unwrap();
        sc.pending_bed = Some(gl::bed_lines(i.bed_x as f32, i.bed_y as f32, i.max_z as f32));
        sc.pending_bed_fill = Some(gl::bed_fill(i.bed_x as f32, i.bed_y as f32));
    }

    fn bed_size(&self) -> (f64, f64) {
        self.imported.as_ref().map(|i| (i.bed_x, i.bed_y)).unwrap_or((350.0, 320.0))
    }

    // ---------- model ----------

    /// A newly loaded model: reset the transform and fit the camera.
    fn set_mesh(&mut self, m: Mesh, name: String) {
        self.mesh_base = Some(Arc::new(m));
        self.model_name = name;
        self.xf = IDENT;
        self.scale_pct = 100.0;
        self.rebuild_mesh(true);
    }

    fn total_xf(&self) -> Mat3 {
        let k = self.scale_pct / 100.0;
        let mut m = self.xf;
        for row in m.iter_mut() {
            for v in row.iter_mut() {
                *v *= k;
            }
        }
        m
    }

    /// Re-derive the working mesh from the loaded one and the current transform.
    /// Zones and any slice result belong to the old orientation, so they are cleared.
    fn rebuild_mesh(&mut self, fit: bool) {
        let Some(base) = self.mesh_base.clone() else { return };
        let m = base.transformed(&self.total_xf());
        let (lo, hi) = m.bounds();
        self.lo = lo;
        self.hi = hi;
        self.holes = m.detect_holes();
        self.adj = Some(m.adjacency());
        self.pick_mode = false;
        self.hover_patch = None;
        self.hover_seed = None;
        let tris = gl::mesh_tris(&m.verts, &m.tris);
        self.scene.lock().unwrap().pending_model = Some(tris);
        self.mesh = Some(Arc::new(m));
        let had_zones = !self.zones.is_empty();
        self.zones.clear();
        self.selected = None;
        self.result = None;
        self.scene.lock().unwrap().pending_toolpath = Some(vec![]);
        self.show_model = true;
        let (bx, by) = self.bed_size();
        if fit {
            self.pos = (bx / 2.0, by / 2.0);
        }
        self.cam.target = Vec3::new(self.pos.0 as f32, self.pos.1 as f32, ((hi[2] - lo[2]) / 2.0) as f32);
        if fit {
            self.cam.dist = (((hi[0] - lo[0]).powi(2) + (hi[1] - lo[1]).powi(2) + (hi[2] - lo[2]).powi(2)).sqrt() as f32 * 1.6).max(60.0);
        }
        self.status = format!(
            "{} — {:.1} × {:.1} × {:.1} mm, {} hole(s) detected.{}",
            if fit { format!("Loaded {}", self.model_name) } else { "Model transformed".to_string() },
            hi[0] - lo[0],
            hi[1] - lo[1],
            hi[2] - lo[2],
            self.holes.len(),
            if had_zones && !fit { " Zones were cleared because they no longer match the model." } else { "" }
        );
    }

    fn rotate(&mut self, axis: usize, deg: f64) {
        let r = match axis {
            0 => rot_x(deg),
            1 => rot_y(deg),
            _ => rot_z(deg),
        };
        self.xf = mat_mul(&r, &self.xf);
        self.rebuild_mesh(false);
    }

    fn mirror(&mut self, axis: usize) {
        let mut m = IDENT;
        m[axis][axis] = -1.0;
        self.xf = mat_mul(&m, &self.xf);
        self.rebuild_mesh(false);
    }

    fn load_path(&mut self, path: &str) {
        match mesh_io::load_any(path) {
            Ok(m) => {
                let name = std::path::Path::new(path).file_stem().map(|s| s.to_string_lossy().to_string()).unwrap_or_else(|| "model".into());
                self.model_path = Some(path.to_string());
                self.set_mesh(m, name);
            }
            Err(e) => self.status = format!("Could not load {path}: {e:#}"),
        }
    }

    fn open_model(&mut self) {
        if let Some(path) = rfd::FileDialog::new().add_filter("3D models", &["stl", "obj", "3mf"]).add_filter("Project", &["mlsproj"]).pick_file() {
            self.open_any(&path.to_string_lossy());
        }
    }

    fn open_any(&mut self, path: &str) {
        if path.to_lowercase().ends_with(".mlsproj") {
            self.load_project(path);
        } else {
            self.load_path(path);
        }
    }

    fn save_settings(&self) {
        let Some(p) = settings_path() else { return };
        let saved = Saved { machine: self.machine.clone(), filament: self.filament.clone(), process: self.process.clone(), bed: self.bed.label().to_string(), ams: self.ams_setup.clone() };
        if let Some(dir) = p.parent() {
            let _ = std::fs::create_dir_all(dir);
        }
        if let Ok(t) = serde_json::to_string_pretty(&saved) {
            let _ = std::fs::write(p, t);
        }
    }

    fn save_project(&mut self) {
        let Some(model_path) = self.model_path.clone() else {
            self.status = "Save project: open a model from a file first.".into();
            return;
        };
        let default = self.project_path.clone().map(|p| std::path::PathBuf::from(p).file_name().map(|n| n.to_string_lossy().to_string()).unwrap_or_default()).unwrap_or_else(|| format!("{}.mlsproj", self.model_name));
        let Some(path) = rfd::FileDialog::new().set_file_name(default).add_filter("Project", &["mlsproj"]).save_file() else { return };
        let mut proj = self.snapshot();
        proj.model_path = model_path;
        self.status = match serde_json::to_string_pretty(&proj).map_err(|e| e.to_string()).and_then(|t| std::fs::write(&path, t).map_err(|e| e.to_string())) {
            Ok(_) => {
                self.project_path = Some(path.to_string_lossy().to_string());
                format!("Saved project {}", path.display())
            }
            Err(e) => format!("Could not save project: {e}"),
        };
    }

    /// The editable state, as saved in a project (the model path is left empty).
    fn snapshot(&self) -> ProjectFile {
        ProjectFile {
            version: 1,
            model_path: String::new(),
            xf: self.xf,
            scale_pct: self.scale_pct,
            pos: self.pos,
            machine: self.machine.clone(),
            filament: self.filament.clone(),
            process: self.process.clone(),
            bed: self.bed.label().to_string(),
            base: self.base,
            wall_h: self.wall_h,
            infill_h: self.infill_h,
            walls: self.walls,
            density_pct: self.density_pct,
            pattern: self.pattern.label().to_string(),
            support: self.support,
            support_plate_only: self.support_plate_only,
            brim: self.brim,
            skirt: self.skirt,
            zone_walls: self.zone_walls,
            zones: self.zones.clone(),
            ams: self.ams,
            slots: self.slots.clone(),
            object_slot: self.object_slot,
            ams_setup: Some(self.ams_setup.clone()),
            tower: self.tower,
            tower_enabled: self.tower_enabled,
            purge_infill: self.purge_infill,
        }
    }

    /// Put back a snapshot taken by `snapshot()` (undo / redo) on the same model.
    fn restore(&mut self, p: ProjectFile) {
        let profiles_changed = p.machine != self.machine || p.filament != self.filament || p.process != self.process || p.bed != self.bed.label();
        if let Some(b) = BedType::ALL.iter().find(|b| b.label() == p.bed) {
            self.bed = *b;
        }
        self.machine = p.machine;
        self.filament = p.filament;
        self.process = p.process;
        if profiles_changed {
            self.reimport(false);
        }
        if p.xf != self.xf || p.scale_pct != self.scale_pct {
            self.xf = p.xf;
            self.scale_pct = p.scale_pct;
            self.rebuild_mesh(false);
        }
        self.pos = p.pos;
        self.base = p.base;
        self.wall_h = p.wall_h;
        self.infill_h = p.infill_h;
        self.walls = p.walls;
        self.density_pct = p.density_pct;
        if let Some(pt) = Pattern::ALL.iter().find(|x| x.label() == p.pattern) {
            self.pattern = *pt;
        }
        self.support = p.support;
        self.support_plate_only = p.support_plate_only;
        self.brim = p.brim;
        self.skirt = p.skirt;
        self.zone_walls = p.zone_walls;
        self.zones = p.zones;
        if self.selected.map_or(false, |i| i >= self.zones.len()) {
            self.selected = None;
        }
        self.slots = p.slots;
        self.ams = !self.slots.is_empty();
        self.slot_filters = self.slots.iter().map(|_| Filter { text: String::new() }).collect();
        self.object_slot = p.object_slot;
        if let Some(a) = p.ams_setup {
            self.ams_setup = a;
        }
        self.tower = p.tower;
        self.tower_enabled = p.tower_enabled;
        self.purge_infill = p.purge_infill;
        self.save_settings();
    }

    /// Record a history step when the state changed and the edit is finished
    /// (no mouse button held, no text field being typed in).
    fn track_history(&mut self, ctx: &egui::Context) {
        let model = self.mesh_base.as_ref().map_or(0, |m| Arc::as_ptr(m) as usize);
        let now = serde_json::to_string(&self.snapshot()).unwrap_or_default();
        if model != self.hist_model || self.hist_cur.is_empty() {
            // a different model: the old history no longer applies
            self.hist_model = model;
            self.hist_undo.clear();
            self.hist_redo.clear();
            self.hist_cur = now;
            return;
        }
        if now == self.hist_cur || ctx.input(|i| i.pointer.any_down()) || ctx.egui_wants_keyboard_input() {
            return;
        }
        self.hist_undo.push(std::mem::replace(&mut self.hist_cur, now));
        if self.hist_undo.len() > 200 {
            self.hist_undo.remove(0);
        }
        self.hist_redo.clear();
    }

    fn undo(&mut self) {
        self.step_history(true);
    }

    fn redo(&mut self) {
        self.step_history(false);
    }

    fn step_history(&mut self, back: bool) {
        let (from, to) = if back { (&mut self.hist_undo, &mut self.hist_redo) } else { (&mut self.hist_redo, &mut self.hist_undo) };
        let Some(target) = from.pop() else {
            self.status = if back { "Nothing to undo." } else { "Nothing to redo." }.into();
            return;
        };
        to.push(std::mem::replace(&mut self.hist_cur, target.clone()));
        if let Ok(p) = serde_json::from_str::<ProjectFile>(&target) {
            self.restore(p);
        }
        // restoring can normalise values; keep the stored step in sync so it is not seen as a new edit
        self.hist_cur = serde_json::to_string(&self.snapshot()).unwrap_or_default();
        self.status = if back { "Undone." } else { "Redone." }.into();
    }

    fn load_project(&mut self, path: &str) {
        let proj: ProjectFile = match std::fs::read_to_string(path).map_err(|e| e.to_string()).and_then(|t| serde_json::from_str(&t).map_err(|e| e.to_string())) {
            Ok(p) => p,
            Err(e) => {
                self.status = format!("Could not read project: {e}");
                return;
            }
        };
        self.load_path(&proj.model_path);
        if self.mesh.is_none() {
            return;
        }
        if let Some(b) = BedType::ALL.iter().find(|b| b.label() == proj.bed) {
            self.bed = *b;
        }
        self.machine = proj.machine;
        self.filament = proj.filament;
        self.process = proj.process;
        self.pick_default_presets();
        self.reimport(true);
        self.xf = proj.xf;
        self.scale_pct = proj.scale_pct;
        self.rebuild_mesh(true);
        self.pos = proj.pos;
        self.base = proj.base;
        self.wall_h = proj.wall_h;
        self.infill_h = proj.infill_h;
        self.walls = proj.walls;
        self.density_pct = proj.density_pct;
        if let Some(pt) = Pattern::ALL.iter().find(|p| p.label() == proj.pattern) {
            self.pattern = *pt;
        }
        self.support = proj.support;
        self.support_plate_only = proj.support_plate_only;
        self.brim = proj.brim;
        self.skirt = proj.skirt;
        self.zone_walls = proj.zone_walls;
        self.zones = proj.zones;
        self.slots = proj.slots;
        self.ams = !self.slots.is_empty();
        self.slot_filters = self.slots.iter().map(|_| Filter { text: String::new() }).collect();
        self.object_slot = proj.object_slot;
        if let Some(a) = proj.ams_setup {
            self.ams_setup = a;
        }
        self.tower = proj.tower;
        self.tower_enabled = proj.tower_enabled;
        self.purge_infill = proj.purge_infill;
        self.project_path = Some(path.to_string());
        self.status = format!("Opened project {path}");
    }

    /// Offset from the model's own coordinates to bed coordinates.
    fn place(&self) -> (f64, f64, f64) {
        (self.pos.0 - (self.lo[0] + self.hi[0]) / 2.0, self.pos.1 - (self.lo[1] + self.hi[1]) / 2.0, -self.lo[2])
    }

    // ---------- layer-height validation ----------

    fn mult(&self, h: f64) -> Option<u32> {
        let m = h / self.base;
        ((m - m.round()).abs() < 0.02 && m.round() >= 1.0).then(|| m.round() as u32)
    }

    /// Returns a list of problems that block slicing.
    fn problems(&self) -> Vec<String> {
        let mut p = vec![];
        if self.imported.is_none() {
            p.push("No valid printer/filament/process selected".into());
        }
        if self.mesh.is_none() {
            p.push("No model loaded".into());
        }
        let mut check = |label: &str, w: f64, i: f64| match (self.mult(w), self.mult(i)) {
            (Some(wm), Some(im)) => {
                if im % wm != 0 {
                    p.push(format!("{label}: infill height ×{im} must be a whole multiple of wall height ×{wm}"));
                }
            }
            _ => p.push(format!("{label}: heights must be multiples of the base step {:.3} mm", self.base)),
        };
        check("Default", self.wall_h, self.infill_h);
        for z in &self.zones {
            check(&z.name, z.wall_h, self.zone_infill_h(z));
        }
        p
    }

    // ---------- zones ----------

    /// A zone's infill layer height: the current default when it inherits, else its own value.
    fn zone_infill_h(&self, z: &ZoneUi) -> f64 {
        if z.infill_inherit { self.infill_h } else { z.infill_h }
    }

    fn zone_color(&self, i: usize) -> [f32; 3] {
        if Some(i) == self.selected { YELLOW } else { ORANGE }
    }

    fn add_zone_for_hole(&mut self, h: &Hole) {
        let n = self.zones.len() + 1;
        self.zones.push(ZoneUi {
            name: format!("Hole zone {n}"),
            kind: ZKind::Cylinder,
            cx: h.cx,
            cy: h.cy,
            r: h.r + self.zone_margin,
            w: 20.0,
            d: 20.0,
            // the zone only spans the heights where the hole really exists
            use_z: (h.z1 - h.z0) < (self.hi[2] - self.lo[2]) - 0.05,
            z0: (h.z0 - self.lo[2]).max(0.0),
            z1: (h.z1 - self.lo[2]).min(self.hi[2] - self.lo[2]),
            wall_h: self.base,
            infill_h: self.infill_h,
            solid: false,
            infill_inherit: true,
            r_in: 0.0,
            pattern: String::new(),
            infill_pct: 0.0,
            filament: None,
        });
        self.selected = Some(self.zones.len() - 1);
    }

    /// Build a zone from a picked surface patch (model coordinates).
    fn add_zone_for_patch(&mut self, p: &Patch) {
        let h = self.hi[2] - self.lo[2];
        let m = self.zone_margin;
        let zlo = (p.lo[2] - self.lo[2]).max(0.0);
        let zhi = (p.hi[2] - self.lo[2]).min(h);
        let n = self.zones.len() + 1;
        let mut z = ZoneUi {
            name: format!("Face zone {n}"),
            kind: ZKind::Box,
            cx: (p.lo[0] + p.hi[0]) / 2.0,
            cy: (p.lo[1] + p.hi[1]) / 2.0,
            r: 10.0,
            w: (p.hi[0] - p.lo[0]) + 2.0 * m,
            d: (p.hi[1] - p.lo[1]) + 2.0 * m,
            use_z: true,
            z0: zlo,
            z1: zhi,
            wall_h: self.base,
            infill_h: self.infill_h,
            solid: false,
            infill_inherit: true,
            r_in: 0.0,
            pattern: String::new(),
            infill_pct: 0.0,
            filament: None,
        };
        match p.kind {
            PatchKind::Cylinder { cx, cy, r, convex } => {
                z.kind = ZKind::Cylinder;
                z.cx = cx;
                z.cy = cy;
                if convex {
                    // outside of a round part: the zone is a band going INWARD from the face
                    z.name = format!("Outer face zone {n}");
                    z.r = r + 0.5;
                    z.r_in = (r - m).max(0.0);
                } else {
                    // a hole: the zone goes outward into the surrounding material
                    z.name = format!("Hole face zone {n}");
                    z.r = r + m;
                    z.r_in = 0.0;
                }
                // a face that runs the whole height needs no Z limit
                z.use_z = (zhi - zlo) < h - 0.5;
            }
            PatchKind::Horizontal { z: zf, up } => {
                let zr = (zf - self.lo[2]).clamp(0.0, h);
                z.name = format!("{} face zone {n}", if up { "Top" } else { "Bottom" });
                if up {
                    z.z0 = (zr - self.face_depth).max(0.0);
                    z.z1 = zr + 0.01;
                } else {
                    z.z0 = (zr - 0.01).max(0.0);
                    z.z1 = (zr + self.face_depth).min(h);
                }
            }
            PatchKind::Other => {
                z.z0 = (zlo - m).max(0.0);
                z.z1 = (zhi + m).min(h);
            }
        }
        self.zones.push(z);
        self.selected = Some(self.zones.len() - 1);
        self.status = "Zone added from face. Adjust it in the list, or keep picking (Esc or the button exits pick mode).".into();
    }

    fn describe_patch(&self, p: &Patch) -> String {
        if self.pick_kind == PickKind::LayFlat {
            return "Click to lay this face flat on the bed".into();
        }
        match p.kind {
            PatchKind::Cylinder { r, convex, .. } => {
                if convex {
                    format!("Outside round face, diameter {:.1} mm — click to add a zone going inward from it", r * 2.0)
                } else {
                    format!("Hole, diameter {:.1} mm — click to add a zone around it", r * 2.0)
                }
            }
            PatchKind::Horizontal { z, up } => format!("{} face at Z {:.2} mm — click to add a zone {:.1} mm deep", if up { "Top" } else { "Bottom" }, z - self.lo[2], self.face_depth),
            PatchKind::Other => format!("Face {:.1} × {:.1} × {:.1} mm — click to add a box zone", p.hi[0] - p.lo[0], p.hi[1] - p.lo[1], p.hi[2] - p.lo[2]),
        }
    }

    fn add_zone(&mut self, kind: ZKind) {
        let n = self.zones.len() + 1;
        let (cx, cy) = ((self.lo[0] + self.hi[0]) / 2.0, (self.lo[1] + self.hi[1]) / 2.0);
        self.zones.push(ZoneUi {
            name: format!("Zone {n}"),
            kind,
            cx,
            cy,
            r: 10.0,
            w: 20.0,
            d: 20.0,
            use_z: false,
            z0: 0.0,
            z1: self.hi[2] - self.lo[2],
            wall_h: self.base,
            infill_h: self.infill_h,
            solid: false,
            infill_inherit: true,
            r_in: 0.0,
            pattern: String::new(),
            infill_pct: 0.0,
            filament: None,
        });
        self.selected = Some(self.zones.len() - 1);
    }

    fn zone_specs(&self) -> Vec<ZoneSpec> {
        self.zones
            .iter()
            .map(|z| ZoneSpec {
                shape: match z.kind {
                    ZKind::Cylinder if z.r_in > 0.0 => ZoneShape::Ring { cx: z.cx, cy: z.cy, r0: z.r_in, r1: z.r },
                    ZKind::Cylinder => ZoneShape::Circle { cx: z.cx, cy: z.cy, r: z.r },
                    ZKind::Box => ZoneShape::Rect { x0: z.cx - z.w / 2.0, y0: z.cy - z.d / 2.0, x1: z.cx + z.w / 2.0, y1: z.cy + z.d / 2.0 },
                },
                wall_mult: self.mult(z.wall_h).unwrap_or(1),
                infill_mult: self.mult(self.zone_infill_h(z)).unwrap_or(1),
                solid: z.solid,
                pattern: Pattern::ALL.iter().find(|p| p.label() == z.pattern).copied(),
                density: (z.infill_pct > 0.0).then_some(z.infill_pct / 100.0),
                filament: if self.ams { z.filament } else { None },
                z0: z.use_z.then_some(z.z0),
                z1: z.use_z.then_some(z.z1),
            })
            .collect()
    }

    // ---------- slicing ----------

    fn start_slice(&mut self) {
        let (Some(mesh), Some(imp)) = (self.mesh.clone(), self.imported.clone()) else { return };
        let mut slots = vec![];
        if self.ams {
            let Some(lib) = &self.lib else { return };
            for (i, sl) in self.slots.iter().enumerate() {
                match engine::bbl_import::slot(lib, &sl.filament, sl.right as u8) {
                    Ok(mut s) => {
                        s.colour = format!("#{:02X}{:02X}{:02X}", sl.colour[0], sl.colour[1], sl.colour[2]);
                        slots.push(s)
                    }
                    Err(e) => {
                        self.status = format!("Slot {}: {e:#}", i + 1);
                        return;
                    }
                }
            }
        }
        let t = self.tower;
        let input = SliceInput {
            slot_colours: self.slots.iter().map(|s| [s.colour[0] as f32 / 255.0, s.colour[1] as f32 / 255.0, s.colour[2] as f32 / 255.0]).collect(),
            slots,
            object_filament: self.object_slot as u8,
            tower: engine::gcode::TowerCfg { enable: self.tower_enabled, x: t[0], y: t[1], w: t[2], d: t[3], purge_mm3: t[4], purge_into_infill: self.tower_enabled && self.purge_infill },
            mesh,
            place: self.place(),
            imported: imp,
            base: self.base,
            wall_h: self.wall_h,
            infill_h: self.infill_h,
            walls: self.walls,
            density: self.density_pct / 100.0,
            pattern: self.pattern,
            support: self.support,
            support_plate_only: self.support_plate_only,
            brim: self.brim,
            skirt: self.skirt,
            zone_walls: self.zone_walls,
            zones: self.zone_specs(),
        };
        let (tx, rx) = mpsc::channel();
        self.rx = Some(rx);
        self.status = "Slicing…".into();
        std::thread::spawn(move || {
            let _ = tx.send(job::run(input).map_err(|e| format!("{e:#}")));
        });
    }

    fn poll_slice(&mut self) {
        let Some(rx) = &self.rx else { return };
        match rx.try_recv() {
            Ok(Ok(out)) => {
                let t = out.print_seconds;
                self.status = format!(
                    "Sliced in {:.1}s — {} layers{} · est. {}h {:02}m · {:.1} g ({:.2} cost){}{}",
                    out.seconds,
                    out.layer_z.len(),
                    if out.tool_changes > 0 { format!(" · {} filament changes", out.tool_changes) } else { String::new() },
                    (t / 3600.0) as u64,
                    ((t % 3600.0) / 60.0) as u64,
                    out.weight_g,
                    out.cost,
                    if out.warnings.is_empty() { String::new() } else { format!("  ⚠ {}", out.warnings.join("; ")) },
                    if out.notes.is_empty() { String::new() } else { format!("  Notes: {}", out.notes.join("; ")) }
                );
                self.layer = out.layer_z.len();
                self.show_model = std::env::var("SLICER_FACE").is_ok() && std::env::var("SLICER_HIDE_MODEL").is_err();
                self.show_toolpath = true;
                if self.tab != Tab::Device {
                    self.tab = Tab::Preview;
                }
                if let Ok(l) = std::env::var("SLICER_LAYER") {
                    if let Ok(l) = l.parse::<usize>() {
                        self.layer = l.clamp(1, out.layer_z.len());
                        self.only_layer = std::env::var("SLICER_ONLY").is_ok();
                    }
                }
                self.result = Some(out);
                self.upload_toolpath();
                self.rx = None;
            }
            Ok(Err(e)) => {
                self.status = format!("Slice failed: {e}");
                self.rx = None;
            }
            Err(mpsc::TryRecvError::Empty) => {}
            Err(mpsc::TryRecvError::Disconnected) => {
                self.status = "Slice worker stopped unexpectedly".into();
                self.rx = None;
            }
        }
    }

    fn upload_toolpath(&mut self) {
        if let Some(r) = &self.result {
            let v = match self.color_by {
                ColorBy::Feature => r.verts_feature.clone(),
                ColorBy::Filament => r.verts_filament.clone(),
                ColorBy::Height => r.verts.clone(),
            };
            self.scene.lock().unwrap().pending_toolpath = Some(v);
        }
    }

    fn export(&mut self) {
        let Some(res) = &self.result else { return };
        let default = format!("{}.gcode.3mf", if self.model_name.is_empty() { "print" } else { &self.model_name });
        let Some(path) = rfd::FileDialog::new().set_file_name(default).add_filter("Bambu 3MF", &["3mf"]).save_file() else { return };
        let p3 = path.to_string_lossy().to_string();
        let plain = p3.trim_end_matches(".3mf").to_string();
        let r = engine::gcode::write_3mf(&res.gcode, &p3).and_then(|_| {
            if plain.ends_with(".gcode") {
                std::fs::write(&plain, &res.gcode)?;
            }
            Ok(())
        });
        self.status = match r {
            Ok(_) => format!("Exported {p3}"),
            Err(e) => format!("Export failed: {e:#}"),
        };
    }

    // ---------- UI ----------

    fn combo(ui: &mut egui::Ui, id: &str, label: &str, sel: &mut String, items: &[String], filter: &mut Filter) -> bool {
        let mut changed = false;
        if !label.is_empty() {
            ui.label(RichText::new(label).small().color(theme::MUTED));
        }
        let shown = if sel.is_empty() { "choose…".to_string() } else { sel.clone() };
        egui::ComboBox::from_id_salt(id)
            .width(ui.available_width())
            .height(360.0)
            .selected_text(RichText::new(shown).color(theme::TEXT))
            .close_behavior(egui::PopupCloseBehavior::CloseOnClickOutside)
            .show_ui(ui, |ui| {
                ui.add(egui::TextEdit::singleline(&mut filter.text).hint_text("search…"));
                egui::ScrollArea::vertical().max_height(320.0).show(ui, |ui| {
                    let f = filter.text.to_lowercase();
                    for it in items.iter().filter(|n| f.is_empty() || n.to_lowercase().contains(&f)) {
                        if ui.selectable_label(sel == it, it).clicked() {
                            *sel = it.clone();
                            changed = true;
                            ui.close();
                        }
                    }
                });
            });
        changed
    }

    /// Printer, build plate, filament and process presets from Bambu Studio.
    fn profiles_ui(&mut self, ui: &mut egui::Ui) {
        if let Some(e) = &self.lib_err {
            ui.colored_label(theme::DANGER, format!("Bambu Studio profiles not found: {e}"));
            return;
        }
        let Some(lib) = &self.lib else { return };
        let (machines, processes): (Vec<String>, Vec<String>) = (
            lib.machines().iter().filter(|e| self.show_all_printers || e.name.contains("H2D")).map(|e| e.name.clone()).collect(),
            lib.compatible(Kind::Process, &self.machine).iter().map(|e| e.name.clone()).collect(),
        );
        let machine_changed = false;
        let mut other_changed = false;
        let _ = &machines;
        ui.label(theme::caption("Printer"));
        theme::card(ui, |ui| {
            ui.label(RichText::new(&self.machine).color(theme::TEXT));
            ui.label(RichText::new(self.bed.label()).small().color(theme::MUTED));
            if theme::ghost(ui, true, "Change on the Device page").clicked() {
                self.tab = Tab::Device;
            }
        });
        ui.add_space(6.0);
        ui.label(theme::caption("Process"));
        theme::card(ui, |ui| {
            other_changed |= Self::combo(ui, "process", "", &mut self.process, &processes, &mut self.f_process);
        });
        if machine_changed {
            self.pick_default_presets();
        }
        if machine_changed || other_changed {
            self.reimport(machine_changed || other_changed);
            self.save_settings();
        }
        if let Some(e) = &self.import_err {
            ui.colored_label(theme::DANGER, e);
        }
        if let Some(i) = &self.imported {
            egui::CollapsingHeader::new(RichText::new("Imported values").small().color(theme::MUTED)).show(ui, |ui| {
                let t = |s: String| RichText::new(s).small().color(theme::TEXT_SOFT);
                ui.label(t(format!("Lines: outer {:.2} inner {:.2} infill {:.2} solid {:.2}", i.w_outer, i.w_inner, i.w_sparse, i.w_solid)));
                ui.label(t(format!("Speeds: outer {:.0} inner {:.0} infill {:.0} mm/s", i.speed_outer, i.speed_inner, i.speed_sparse)));
                ui.label(t(format!("Flow ratio {:.2}, retract {:.1} mm, z-hop {:.1} mm, chamber {:.0} °C", i.flow_ratio, i.retract, i.z_hop, i.chamber_temp)));
                for n in &i.notes {
                    ui.colored_label(theme::WARN, RichText::new(format!("• {n}")).small());
                }
            });
        }
    }

    /// Height choices that are whole multiples of `unit`, as segmented-control options.
    fn height_options(unit: f64, max: f64, count: usize) -> Vec<(i64, String)> {
        (1..=16)
            .map(|k| k as f64 * unit)
            .filter(|h| *h >= 0.039 && *h <= max + 1e-6)
            .take(count)
            .map(|h| ((h * 1e4).round() as i64, format!("{h:.2}")))
            .collect()
    }

    fn layers_ui(&mut self, ui: &mut egui::Ui) {
        // walls / skin height
        theme::value_row(ui, "Wall / skin height", &format!("{:.2} mm", self.wall_h));
        let mut key = (self.wall_h * 1e4).round() as i64;
        let opts = Self::height_options(self.base, 0.42, 5);
        if theme::segmented(ui, &mut key, &opts, true, true) {
            self.wall_h = key as f64 / 1e4;
            if self.mult(self.infill_h / self.wall_h * self.base).is_none() || self.infill_h < self.wall_h {
                self.infill_h = self.wall_h;
            }
        }
        if self.mult(self.wall_h).is_none() {
            ui.colored_label(theme::DANGER, RichText::new("Wall height is not a multiple of the base step").small());
        }
        ui.add_space(4.0);
        // sparse infill height
        theme::value_row(ui, "Infill height", &format!("{:.2} mm", self.infill_h));
        let mut ikey = (self.infill_h * 1e4).round() as i64;
        let iopts = Self::height_options(self.wall_h, 0.8, 4);
        if theme::segmented(ui, &mut ikey, &iopts, true, true) {
            self.infill_h = ikey as f64 / 1e4;
        }
        ui.add_space(4.0);
        ui.horizontal(|ui| {
            ui.label(RichText::new("Base step").color(theme::TEXT));
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                ui.add(egui::DragValue::new(&mut self.base).speed(0.005).range(0.01..=0.2).suffix(" mm").fixed_decimals(3));
            });
        });
        ui.label(RichText::new("Every height is a multiple of the base step; infill is a multiple of the wall height. Zones can use other multiples.").small().color(theme::MUTED));
    }

    fn zones_ui(&mut self, ui: &mut egui::Ui) {
        ui.horizontal(|ui| {
            if ui.add_enabled(self.mesh.is_some(), egui::Button::new("+ Cylinder")).clicked() {
                self.add_zone(ZKind::Cylinder);
            }
            if ui.add_enabled(self.mesh.is_some(), egui::Button::new("+ Box")).clicked() {
                self.add_zone(ZKind::Box);
            }
            let pick = ui.add_enabled(self.mesh.is_some(), egui::Button::new("Pick face").selected(self.pick_mode));
            if pick.clicked() {
                self.pick_kind = PickKind::Zone;
                self.pick_mode = !self.pick_mode;
                self.hover_patch = None;
                self.hover_seed = None;
            }
            pick.on_hover_text("Hover a surface of the model and click it to make a zone from that face.\nRound faces become cylinders; top/bottom faces become shallow boxes.");
        });
        if self.mesh.is_some() {
            ui.horizontal(|ui| {
                ui.label("Zone margin");
                ui.add(egui::DragValue::new(&mut self.zone_margin).speed(0.1).range(0.0..=50.0).suffix(" mm"));
                ui.label("Face depth");
                ui.add(egui::DragValue::new(&mut self.face_depth).speed(0.1).range(0.1..=50.0).suffix(" mm"));
            });
        }
        if !self.holes.is_empty() {
            ui.separator();
            ui.label(RichText::new("Detected holes").strong());
            let holes = self.holes.clone();
            for h in &holes {
                ui.horizontal(|ui| {
                    let full = (h.z1 - h.z0) >= (self.hi[2] - self.lo[2]) - 0.05;
                    ui.label(format!(
                        "Ø{:.1} at ({:.1}, {:.1}){}",
                        h.r * 2.0,
                        h.cx,
                        h.cy,
                        if full { String::new() } else { format!(", Z {:.1}–{:.1}", h.z0 - self.lo[2], h.z1 - self.lo[2]) }
                    ));
                    if ui.button("Zone around it").clicked() {
                        self.add_zone_for_hole(h);
                    }
                });
            }
        }
        ui.separator();
        let mut remove = None;
        let base = self.base;
        let hmax = (self.hi[2] - self.lo[2]).max(1.0);
        let ams = self.ams;
        let slot_names: Vec<String> = self.slots.iter().enumerate().map(|(i, s)| slot_name(i, s)).collect();
        for idx in 0..self.zones.len() {
            let selected = self.selected == Some(idx);
            let heights: [(Option<u32>, Option<u32>); 1] = [(self.mult(self.zones[idx].wall_h), self.mult(self.zone_infill_h(&self.zones[idx])))];
            let default_infill = self.infill_h;
            let z = &mut self.zones[idx];
            egui::Frame::group(ui.style()).stroke(egui::Stroke::new(if selected { 2.0 } else { 1.0 }, if selected { Color32::YELLOW } else { Color32::DARK_GRAY })).show(ui, |ui| {
                ui.horizontal(|ui| {
                    if ui.selectable_label(selected, RichText::new(&z.name).strong()).clicked() {
                        self.selected = Some(idx);
                    }
                    ui.label(RichText::new(if z.kind == ZKind::Cylinder { if z.r_in > 0.0 { "ring" } else { "cylinder" } } else { "box" }).weak());
                    if ui.small_button("Delete").clicked() {
                        remove = Some(idx);
                    }
                });
                ui.horizontal(|ui| {
                    ui.label("Centre");
                    ui.add(egui::DragValue::new(&mut z.cx).speed(0.2).prefix("X ").fixed_decimals(1));
                    ui.add(egui::DragValue::new(&mut z.cy).speed(0.2).prefix("Y ").fixed_decimals(1));
                });
                match z.kind {
                    ZKind::Cylinder => {
                        ui.horizontal(|ui| {
                            ui.label("Radius");
                            ui.add(egui::DragValue::new(&mut z.r).speed(0.1).range(0.5..=300.0).suffix(" mm").fixed_decimals(1));
                            ui.label("Inner");
                            let max_in = (z.r - 0.1).max(0.0);
                            ui.add(egui::DragValue::new(&mut z.r_in).speed(0.1).range(0.0..=max_in).suffix(" mm").fixed_decimals(1))
                                .on_hover_text("0 = a full disc. Above 0 the zone is a ring between the inner and outer radius, which is what you want for a band just inside an outside wall.");
                        });
                    }
                    ZKind::Box => {
                        ui.horizontal(|ui| {
                            ui.label("Size");
                            ui.add(egui::DragValue::new(&mut z.w).speed(0.2).range(1.0..=600.0).prefix("W ").fixed_decimals(1));
                            ui.add(egui::DragValue::new(&mut z.d).speed(0.2).range(1.0..=600.0).prefix("D ").fixed_decimals(1));
                        });
                    }
                }
                ui.horizontal(|ui| {
                    ui.checkbox(&mut z.use_z, "Limit height");
                    if z.use_z {
                        ui.add(egui::DragValue::new(&mut z.z0).speed(0.1).range(0.0..=hmax).suffix(" mm").fixed_decimals(1));
                        ui.label("to");
                        ui.add(egui::DragValue::new(&mut z.z1).speed(0.1).range(0.0..=hmax).suffix(" mm").fixed_decimals(1));
                    }
                });
                ui.horizontal(|ui| {
                    ui.label("Walls");
                    ui.add(egui::DragValue::new(&mut z.wall_h).speed(0.005).range(0.04..=1.0).suffix(" mm").fixed_decimals(3));
                    ui.label(match heights[0].0 { Some(m) => format!("×{m}"), None => "invalid".into() });
                    ui.label("Infill");
                    if z.infill_inherit {
                        ui.label(RichText::new(format!("{:.3} mm", default_infill)).weak());
                    } else {
                        ui.add(egui::DragValue::new(&mut z.infill_h).speed(0.005).range(0.04..=1.0).suffix(" mm").fixed_decimals(3));
                    }
                    ui.label(match heights[0].1 { Some(m) => format!("×{m}"), None => "invalid".into() });
                });
                if ui.checkbox(&mut z.infill_inherit, "Infill height follows the default").on_hover_text("On: this zone's infill layer height always equals the default sparse-infill height above. Off: set its own value.").changed() && !z.infill_inherit {
                    z.infill_h = default_infill;
                }
                ui.horizontal(|ui| {
                    ui.label("Infill pattern");
                    let shown = if z.pattern.is_empty() { "Inherit".to_string() } else { z.pattern.clone() };
                    egui::ComboBox::from_id_salt(("zone_pattern", idx)).selected_text(shown).show_ui(ui, |ui| {
                        ui.selectable_value(&mut z.pattern, String::new(), "Inherit");
                        for p in Pattern::ALL {
                            ui.selectable_value(&mut z.pattern, p.label().to_string(), p.label());
                        }
                    });
                });
                ui.horizontal(|ui| {
                    ui.label("Infill %");
                    ui.add_enabled(!z.solid, egui::DragValue::new(&mut z.infill_pct).range(0.0..=100.0).speed(0.5).custom_formatter(|v, _| if v <= 0.0 { "inherit".to_string() } else { format!("{v:.0}%") }).custom_parser(|t| t.trim().trim_end_matches('%').parse::<f64>().ok().or(Some(0.0))))
                        .on_hover_text("Sparse infill density inside this zone. 'inherit' (0) uses the print's value.");
                });
                if ams && !slot_names.is_empty() {
                    ui.horizontal(|ui| {
                        ui.label("Filament");
                        let shown = z.filament.and_then(|f| slot_names.get(f as usize).cloned()).unwrap_or_else(|| "Object's filament".to_string());
                        egui::ComboBox::from_id_salt(("zone_fil", idx)).selected_text(shown).show_ui(ui, |ui| {
                            ui.selectable_value(&mut z.filament, None, "Object's filament");
                            for (i, n) in slot_names.iter().enumerate() {
                                ui.selectable_value(&mut z.filament, Some(i as u8), n);
                            }
                        });
                    });
                }
                ui.checkbox(&mut z.solid, "Solid infill").on_hover_text("Fill this zone completely solid (100%), with no sparse infill. The zone's walls and boundary wall still print.");
                let _ = base;
            });
        }
        if let Some(i) = remove {
            self.zones.remove(i);
            self.selected = None;
        }
    }

    /// Default first setup: one AMS on the left with the current filament in tray A1.
    fn default_ams(&self) -> AmsSetup {
        let mut u = AmsUnit::new(AmsKind::Ams);
        u.trays[0].filament = self.filament.clone();
        AmsSetup { left: vec![u], ..Default::default() }
    }

    /// Rebuild the print's filament slots from the AMS setup, keeping zone and object
    /// assignments that point at a tray which is still loaded.
    fn apply_ams(&mut self) {
        let old: Vec<String> = self.slots.iter().map(|s| s.label.clone()).collect();
        let new: Vec<SlotUi> = self.ams_setup.positions().into_iter().map(|(label, right, t)| SlotUi { filament: t.filament, right, colour: t.colour, label }).collect();
        let remap = |i: usize| old.get(i).filter(|l| !l.is_empty()).and_then(|l| new.iter().position(|s| &s.label == l));
        for z in &mut self.zones {
            z.filament = z.filament.and_then(|f| remap(f as usize)).map(|p| p as u8);
        }
        self.object_slot = remap(self.object_slot).unwrap_or(0);
        self.slot_filters = new.iter().map(|_| Filter { text: String::new() }).collect();
        self.slots = new;
        // an AMS (or external spool) with trays means a multi-filament print
        self.ams = !self.slots.is_empty();
        self.save_settings();
    }

    /// Prime tower position overlaps the placed model (with a 3 mm margin).
    fn tower_overlaps(&self) -> bool {
        if !self.ams || !self.tower_enabled || self.mesh.is_none() {
            return false;
        }
        let (x0, y0, x1, y1) = (self.tower[0], self.tower[1], self.tower[0] + self.tower[2], self.tower[1] + self.tower[3]);
        let pl = self.place();
        let (mx0, my0, mx1, my1) = (self.lo[0] + pl.0, self.lo[1] + pl.1, self.hi[0] + pl.0, self.hi[1] + pl.1);
        x0 < mx1 + 3.0 && x1 > mx0 - 3.0 && y0 < my1 + 3.0 && y1 > my0 - 3.0
    }

    /// Device page: which filament the print uses, and how filament changes purge.
    fn print_filaments_ui(&mut self, ui: &mut egui::Ui, filaments: &[String]) {
        ui.add_space(16.0);
        ui.label(RichText::new("Filaments for this print").font(theme::semibold(20.0)).color(theme::TEXT));
        ui.add_space(6.0);
        if !self.ams {
            ui.label(theme::caption("Filament (no AMS)"));
            theme::card(ui, |ui| {
                let changed = Self::combo(ui, "filament", "", &mut self.filament, filaments, &mut self.f_filament);
                if let Some(i) = &self.imported {
                    ui.label(RichText::new(format!("{} · {:.0} °C · bed {:.0} °C", i.filament_type, i.nozzle_temp, i.bed_temp)).font(theme::mono(12.0)).color(theme::MUTED));
                }
                ui.label(RichText::new("The whole print uses this filament. Add an AMS above to print with several.").small().color(theme::MUTED));
                if changed {
                    self.reimport(false);
                    self.save_settings();
                }
            });
            return;
        }
        ui.columns(2, |cols| {
            let ui = &mut cols[0];
            ui.label(theme::caption("Object"));
            theme::card(ui, |ui| {
                ui.horizontal(|ui| {
                    ui.label("Object prints in");
                    let names: Vec<String> = self.slots.iter().enumerate().map(|(i, s)| slot_name(i, s)).collect();
                    egui::ComboBox::from_id_salt("object_slot").width(ui.available_width()).selected_text(names.get(self.object_slot).cloned().unwrap_or_default()).show_ui(ui, |ui| {
                        for (i, n) in names.iter().enumerate() {
                            ui.selectable_value(&mut self.object_slot, i, n);
                        }
                    });
                });
                ui.label(RichText::new("Zones can print in other slots; pick them per zone in Prepare.").small().color(theme::MUTED));
            });
            let ui = &mut cols[1];
            ui.label(theme::caption("Filament changes"));
            theme::card(ui, |ui| {
                theme::toggle_row(ui, "Prime tower", if self.tower_enabled { "purges and wipes the nozzle after each change" } else { "off: the printer purges into its waste chute" }, &mut self.tower_enabled);
                if !self.tower_enabled {
                    ui.horizontal(|ui| {
                        ui.label(RichText::new("Purge per change").small().color(theme::MUTED));
                        ui.add(egui::DragValue::new(&mut self.tower[4]).speed(1.0).range(10.0..=1000.0).suffix(" mm³").fixed_decimals(0));
                    });
                    return;
                }
                theme::toggle_row(ui, "Purge into infill", "new filament prints infill first, then walls, then the rest", &mut self.purge_infill);
                ui.horizontal(|ui| {
                    ui.add(egui::DragValue::new(&mut self.tower[0]).speed(0.5).prefix("X ").suffix(" mm").fixed_decimals(1));
                    ui.add(egui::DragValue::new(&mut self.tower[1]).speed(0.5).prefix("Y ").suffix(" mm").fixed_decimals(1));
                    ui.add(egui::DragValue::new(&mut self.tower[2]).speed(0.5).range(10.0..=80.0).prefix("W ").suffix(" mm").fixed_decimals(1));
                    ui.add(egui::DragValue::new(&mut self.tower[3]).speed(0.5).range(10.0..=80.0).prefix("D ").suffix(" mm").fixed_decimals(1));
                });
                ui.horizontal(|ui| {
                    ui.add(egui::DragValue::new(&mut self.tower[4]).speed(1.0).range(10.0..=1000.0).prefix("purge ").suffix(" mm³").fixed_decimals(0))
                        .on_hover_text("Plastic pushed through after every filament change. With purge into infill, the infill takes as much of it as it can and the tower the rest. Bambu Studio used about 80 mm³ for an ASA to ASA change.");
                });
            });
        });
        if self.tower_overlaps() {
            ui.colored_label(theme::WARN, "⚠ The prime tower overlaps the model; move it.");
        }
    }

    /// One hotend's column in the AMS dialog.
    fn ams_side(ui: &mut egui::Ui, draft: &mut AmsSetup, right: bool, filaments: &[String], filters: &mut std::collections::HashMap<String, Filter>) {
        let base = if right { draft.left.len() } else { 0 };
        let (units, ext) = if right { (&mut draft.right, &mut draft.right_ext) } else { (&mut draft.left, &mut draft.left_ext) };
        let side = if right { "R" } else { "L" };
        ui.label(theme::caption(if right { "Right hotend" } else { "Left hotend" }));
        let mut remove = None;
        for (u, unit) in units.iter_mut().enumerate() {
            let letter = (b'A' + (base + u) as u8) as char;
            theme::card(ui, |ui| {
                ui.horizontal(|ui| {
                    ui.label(RichText::new(format!("AMS {letter}")).font(theme::semibold(14.0)).color(theme::TEXT));
                    let mut kind = unit.kind;
                    if theme::segmented(ui, &mut kind, &[(AmsKind::Ams, "AMS · 4".to_string()), (AmsKind::AmsHt, "AMS HT · 1".to_string())], false, false) {
                        unit.kind = kind;
                        let n = kind.trays();
                        unit.trays.truncate(n);
                        while unit.trays.len() < n {
                            let t = unit.trays.len();
                            unit.trays.push(Tray { filament: String::new(), colour: SLOT_COLOURS[t % SLOT_COLOURS.len()] });
                        }
                    }
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        if theme::ghost(ui, true, "Remove").clicked() {
                            remove = Some(u);
                        }
                    });
                });
                for (t, tray) in unit.trays.iter_mut().enumerate() {
                    Self::tray_row(ui, &format!("{letter}{}", t + 1), &format!("ams_{side}_{u}_{t}"), tray, filaments, filters);
                }
            });
            ui.add_space(4.0);
        }
        if let Some(u) = remove {
            units.remove(u);
        }
        if units.len() < 4 {
            ui.horizontal(|ui| {
                if theme::ghost(ui, true, "+ AMS").on_hover_text("4-tray AMS or AMS 2 Pro").clicked() {
                    units.push(AmsUnit::new(AmsKind::Ams));
                }
                if theme::ghost(ui, true, "+ AMS HT").on_hover_text("single-tray AMS HT").clicked() {
                    units.push(AmsUnit::new(AmsKind::AmsHt));
                }
            });
        }
        let mut has_ext = ext.is_some();
        if theme::toggle_row(ui, "External spool", "spool holder feeding this hotend directly", &mut has_ext) {
            *ext = has_ext.then(|| Tray { filament: String::new(), colour: SLOT_COLOURS[0] });
        }
        if let Some(t) = ext {
            Self::tray_row(ui, "Ext", &format!("ams_{side}_ext"), t, filaments, filters);
        }
    }

    /// Colour, position label and filament picker for one tray.
    fn tray_row(ui: &mut egui::Ui, label: &str, id: &str, tray: &mut Tray, filaments: &[String], filters: &mut std::collections::HashMap<String, Filter>) {
        ui.horizontal(|ui| {
            let mut col = Color32::from_rgb(tray.colour[0], tray.colour[1], tray.colour[2]);
            if ui.color_edit_button_srgba(&mut col).on_hover_text("Filament colour (used in the preview)").changed() {
                tray.colour = [col.r(), col.g(), col.b()];
            }
            ui.label(RichText::new(label).font(theme::mono(13.0)).color(if tray.filament.is_empty() { theme::MUTED } else { theme::TEXT }));
            let clear = if tray.filament.is_empty() {
                ui.allocate_exact_size(egui::vec2(28.0, 28.0), egui::Sense::hover());
                false
            } else {
                ui.add_sized(egui::vec2(28.0, 28.0), egui::Button::new(RichText::new("×").color(theme::MUTED)).fill(Color32::TRANSPARENT).stroke(egui::Stroke::NONE)).on_hover_text("Empty this tray").clicked()
            };
            let filter = filters.entry(id.to_string()).or_insert_with(|| Filter { text: String::new() });
            if tray.filament.is_empty() {
                let mut pick = String::new();
                egui::ComboBox::from_id_salt(id)
                    .width(ui.available_width())
                    .height(360.0)
                    .selected_text(RichText::new("empty").color(theme::MUTED))
                    .close_behavior(egui::PopupCloseBehavior::CloseOnClickOutside)
                    .show_ui(ui, |ui| {
                        ui.add(egui::TextEdit::singleline(&mut filter.text).hint_text("search…"));
                        egui::ScrollArea::vertical().max_height(320.0).show(ui, |ui| {
                            let f = filter.text.to_lowercase();
                            for it in filaments.iter().filter(|n| f.is_empty() || n.to_lowercase().contains(&f)) {
                                if ui.selectable_label(false, it).clicked() {
                                    pick = it.clone();
                                    ui.close();
                                }
                            }
                        });
                    });
                if !pick.is_empty() {
                    tray.filament = pick;
                }
            } else {
                Self::combo(ui, id, "", &mut tray.filament, filaments, filter);
            }
            if clear {
                tray.filament.clear();
            }
        });
    }

    fn print_ui(&mut self, ui: &mut egui::Ui) {
        theme::value_row(ui, "Infill density", &format!("{:.0}%", self.density_pct));
        ui.spacing_mut().slider_width = ui.available_width();
        ui.add(egui::Slider::new(&mut self.density_pct, 2.0..=100.0).show_value(false).trailing_fill(true).step_by(1.0));
        ui.add_space(4.0);
        ui.label(RichText::new("Infill pattern").color(theme::TEXT));
        ui.horizontal_wrapped(|ui| {
            ui.spacing_mut().item_spacing = egui::vec2(6.0, 6.0);
            for p in Pattern::ALL {
                if theme::chip(ui, self.pattern == p, p.label()).clicked() {
                    self.pattern = p;
                }
            }
        });
        ui.add_space(4.0);
        ui.columns(2, |cols| {
            let stat = |ui: &mut egui::Ui, label: &str, hint: &str, add: &mut dyn FnMut(&mut egui::Ui)| {
                theme::card(ui, |ui| {
                    ui.spacing_mut().item_spacing.y = 2.0;
                    ui.label(RichText::new(label).small().color(theme::MUTED)).on_hover_text(hint);
                    add(ui);
                });
            };
            let walls = &mut self.walls;
            stat(&mut cols[0], "Walls", "Wall loops around every contour", &mut |ui| {
                ui.add(egui::DragValue::new(walls).range(1..=10).custom_formatter(|v, _| format!("{v:.0}")));
            });
            let zw = &mut self.zone_walls;
            stat(&mut cols[1], "Zone walls", "Perimeter loops along each zone's edge, so regions with different layer heights are separated by a wall", &mut |ui| {
                ui.add(egui::DragValue::new(zw).range(0..=4));
            });
        });
        ui.add_space(2.0);
        theme::toggle_row(ui, "Supports", if self.support_plate_only { "Grid · from the build plate only" } else { "Grid · everywhere" }, &mut self.support);
        if self.support {
            ui.indent("support_opts", |ui| {
                ui.checkbox(&mut self.support_plate_only, RichText::new("Only from the build plate").small());
            });
        }
        let mut brim = self.brim > 0.0;
        let hint = if brim { format!("{:.0} mm outer", self.brim) } else { "off".to_string() };
        if theme::toggle_row(ui, "Brim", &hint, &mut brim) {
            self.brim = if brim { 5.0 } else { 0.0 };
        }
        if brim {
            ui.indent("brim_w", |ui| {
                ui.horizontal(|ui| {
                    ui.label(RichText::new("Width").small().color(theme::MUTED));
                    ui.add(egui::DragValue::new(&mut self.brim).speed(0.1).range(0.5..=30.0).suffix(" mm"));
                });
            });
        }
        ui.horizontal(|ui| {
            ui.label(RichText::new("Skirt loops").color(theme::TEXT));
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                ui.add(egui::DragValue::new(&mut self.skirt).range(0..=10));
            });
        });
        if let Some(i) = &self.imported {
            ui.label(RichText::new(format!("Cooling: fan {:.0}–{:.0}% · slow layers under {:.0}s · max flow {:.0} mm³/s", i.fan_min, i.fan_max, i.slow_layer_time, i.max_volumetric)).small().color(theme::MUTED));
        }
    }

    fn model_ui(&mut self, ui: &mut egui::Ui) {
        ui.label(format!("{}  ({:.1} × {:.1} × {:.1} mm)", self.model_name, self.hi[0] - self.lo[0], self.hi[1] - self.lo[1], self.hi[2] - self.lo[2]));
        for (axis, name) in [(0usize, "X"), (1, "Y"), (2, "Z")] {
            ui.horizontal(|ui| {
                ui.label(format!("Rotate {name}"));
                if ui.button("−90°").clicked() {
                    self.rotate(axis, -90.0);
                }
                if ui.button("+90°").clicked() {
                    self.rotate(axis, 90.0);
                }
                if ui.button(format!("Mirror {name}")).clicked() {
                    self.mirror(axis);
                }
            });
        }
        ui.horizontal(|ui| {
            ui.label("Scale");
            let r = ui.add(egui::DragValue::new(&mut self.scale_pct).speed(0.5).range(5.0..=2000.0).suffix(" %"));
            if r.drag_stopped() || (r.changed() && !r.dragged()) {
                self.rebuild_mesh(false);
            }
        });
        ui.horizontal(|ui| {
            let lay = ui.add(egui::Button::new("Lay face flat").selected(self.pick_mode && self.pick_kind == PickKind::LayFlat));
            if lay.clicked() {
                self.pick_kind = PickKind::LayFlat;
                self.pick_mode = !(self.pick_mode && self.pick_kind == PickKind::LayFlat) || self.hover_patch.is_none() && !self.pick_mode;
                self.hover_patch = None;
                self.hover_seed = None;
            }
            lay.on_hover_text("Hover a surface and click it: the model turns so that face sits on the bed.");
            if ui.button("Reset transform").clicked() {
                self.xf = IDENT;
                self.scale_pct = 100.0;
                self.rebuild_mesh(false);
            }
        });
        ui.horizontal(|ui| {
            ui.label("Position on bed");
            ui.add(egui::DragValue::new(&mut self.pos.0).speed(0.5).prefix("X ").fixed_decimals(1));
            ui.add(egui::DragValue::new(&mut self.pos.1).speed(0.5).prefix("Y ").fixed_decimals(1));
        });
    }

    fn left_panel(&mut self, ui: &mut egui::Ui) {
        let problems = self.problems();
        let busy = self.rx.is_some();
        ui.with_layout(egui::Layout::bottom_up(egui::Align::Min), |ui| {
            ui.add_space(14.0);
            let label = if busy {
                "Slicing…"
            } else if self.result.is_some() {
                "Re-slice plate"
            } else {
                "Slice plate"
            };
            // leave the same right gutter as the scrolled content above (room for its scroll bar)
            let w = ui.available_width() - SCROLL_GUTTER;
            let r = theme::accent_outline(ui, problems.is_empty() && !busy, label, w);
            if r.clicked() {
                self.start_slice();
            }
            if !problems.is_empty() {
                r.on_disabled_hover_text(problems.join("\n"));
            }
            ui.add_space(6.0);
            ui.with_layout(egui::Layout::top_down(egui::Align::Min), |ui| {
                egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
                    // the scroll bar floats over the right edge: keep content out of its way
                    egui::Frame::new().inner_margin(egui::Margin { right: SCROLL_GUTTER as i8, ..Default::default() }).show(ui, |ui| {
                    ui.set_width(ui.available_width());
                    ui.add_space(14.0);
                    if self.mesh.is_some() {
                        for p in &problems {
                            ui.colored_label(theme::DANGER, RichText::new(p).small());
                        }
                    }
                    theme::section(ui, "sec_profiles", "Printer & profiles", true, |ui| self.profiles_ui(ui));
                    theme::section(ui, "sec_layers", "Layer heights", true, |ui| self.layers_ui(ui));
                    theme::section(ui, "sec_print", "Print settings", true, |ui| self.print_ui(ui));
                    theme::section(ui, "sec_zones", "Zones — height by region", true, |ui| self.zones_ui(ui));
                    if self.mesh.is_some() {
                        theme::section(ui, "sec_model", "Model", false, |ui| self.model_ui(ui));
                    }
                    });
                });
            });
        });
    }

    /// Device page: printer, build plate, hotends and the AMS units feeding each hotend.
    fn device_page(&mut self, ui: &mut egui::Ui) {
        theme::paint_backdrop(ui.painter(), ui.max_rect());
        egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
            let full = ui.available_width();
            let w = (full - 48.0).min(1180.0);
            ui.add_space(24.0);
            ui.horizontal(|ui| {
                ui.add_space(((full - w) / 2.0).max(24.0));
                ui.vertical(|ui| {
                    ui.set_width(w);
                    self.device_contents(ui);
                });
            });
            ui.add_space(32.0);
        });
    }

    fn device_contents(&mut self, ui: &mut egui::Ui) {
        ui.label(RichText::new("Device").font(theme::semibold(24.0)).color(theme::TEXT));
        ui.label(RichText::new("The printer, build plate and hotends, and which AMS units and filaments are loaded. Saved with your settings and used by every slice.").color(theme::MUTED));
        ui.add_space(14.0);
        let Some(lib) = &self.lib else {
            ui.colored_label(theme::DANGER, format!("Bambu Studio profiles not found: {}", self.lib_err.clone().unwrap_or_default()));
            return;
        };
        let machines: Vec<String> = lib.machines().iter().filter(|e| self.show_all_printers || e.name.contains("H2D")).map(|e| e.name.clone()).collect();
        let filaments: Vec<String> = lib.compatible(Kind::Filament, &self.machine).iter().map(|e| e.name.clone()).collect();
        let mut machine_changed = false;
        let mut bed_changed = false;
        ui.columns(2, |cols| {
            // printer
            cols[0].label(theme::caption("Printer"));
            theme::card(&mut cols[0], |ui| {
                machine_changed |= Self::combo(ui, "dev_machine", "Machine profile", &mut self.machine, &machines, &mut self.f_machine);
                ui.checkbox(&mut self.show_all_printers, RichText::new("Show all Bambu printers").small().color(theme::MUTED));
                ui.add_space(4.0);
                ui.label(RichText::new("Build plate").small().color(theme::MUTED));
                egui::ComboBox::from_id_salt("dev_bed").width(ui.available_width()).selected_text(self.bed.label()).show_ui(ui, |ui| {
                    for b in BedType::ALL {
                        if ui.selectable_value(&mut self.bed, b, b.label()).clicked() {
                            bed_changed = true;
                        }
                    }
                });
                if let Some(i) = &self.imported {
                    ui.add_space(6.0);
                    ui.columns(3, |c| {
                        for (k, (label, value)) in [("Build volume", format!("{:.0}×{:.0}×{:.0}", i.bed_x, i.bed_y, i.max_z)), ("Nozzle", format!("{:.1} mm", i.nozzle)), ("Plate temp", format!("{:.0} °C", i.bed_temp))].into_iter().enumerate() {
                            c[k].label(RichText::new(label).small().color(theme::MUTED));
                            c[k].label(RichText::new(value).font(theme::mono(14.0)).color(theme::TEXT));
                        }
                    });
                }
            });
            // hotends
            cols[1].label(theme::caption("Hotends"));
            let list = |key: &str| -> Vec<String> {
                match self.imported.as_ref().and_then(|i| i.all.get(key)) {
                    Some(serde_json::Value::Array(a)) => a.iter().map(|v| v.as_str().map(String::from).unwrap_or_else(|| v.to_string())).collect(),
                    Some(v) => vec![v.as_str().map(String::from).unwrap_or_else(|| v.to_string())],
                    None => vec![],
                }
            };
            let dia = list("nozzle_diameter");
            let vol = list("nozzle_volume_type");
            let ext = list("extruder_type");
            let feeds = |units: &Vec<AmsUnit>, ext_spool: &Option<Tray>, base: usize| -> String {
                let mut parts: Vec<String> = units.iter().enumerate().map(|(u, unit)| format!("AMS {}{}", (b'A' + (base + u) as u8) as char, if unit.kind == AmsKind::AmsHt { " HT" } else { "" })).collect();
                if ext_spool.is_some() {
                    parts.push("external spool".into());
                }
                if parts.is_empty() { "nothing attached".into() } else { parts.join(" · ") }
            };
            let (lf, rf) = (feeds(&self.ams_setup.left, &self.ams_setup.left_ext, 0), feeds(&self.ams_setup.right, &self.ams_setup.right_ext, self.ams_setup.left.len()));
            for (k, side, fed) in [(0usize, "Left hotend", lf), (1, "Right hotend", rf)] {
                theme::card(&mut cols[1], |ui| {
                    ui.horizontal(|ui| {
                        ui.label(RichText::new(side).font(theme::semibold(15.0)).color(theme::TEXT));
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            ui.label(RichText::new(format!("{} mm", dia.get(k).or(dia.first()).cloned().unwrap_or_else(|| "?".into()))).font(theme::mono(14.0)).color(theme::ACCENT_TEXT));
                        });
                    });
                    let mut facts = vec![];
                    if let Some(v) = vol.get(k).or(vol.first()) {
                        facts.push(format!("{v} flow"));
                    }
                    if let Some(v) = ext.get(k).or(ext.first()) {
                        facts.push(v.clone());
                    }
                    if !facts.is_empty() {
                        ui.label(RichText::new(facts.join(" · ")).small().color(theme::MUTED));
                    }
                    ui.label(RichText::new(format!("Fed by: {fed}")).small().color(theme::TEXT_SOFT));
                });
                cols[1].add_space(4.0);
            }
        });
        if machine_changed {
            self.pick_default_presets();
        }
        if machine_changed || bed_changed {
            self.reimport(true);
            self.save_settings();
        }

        // AMS
        ui.add_space(16.0);
        ui.horizontal(|ui| {
            ui.label(RichText::new("AMS").font(theme::semibold(20.0)).color(theme::TEXT));
            ui.add_space(12.0);
            ui.label(RichText::new(if self.ams { "Printing with several filaments" } else { "None set up: single filament (chosen below)" }).color(theme::TEXT_SOFT));
        });
        ui.label(RichText::new("Units are lettered A, B, C… down the left hotend first, then the right. Loaded trays become the print's filament slots.").small().color(theme::MUTED));
        ui.add_space(8.0);
        let before = serde_json::to_string(&self.ams_setup).unwrap_or_default();
        ui.columns(2, |cols| {
            Self::ams_side(&mut cols[0], &mut self.ams_setup, false, &filaments, &mut self.ams_filters);
            Self::ams_side(&mut cols[1], &mut self.ams_setup, true, &filaments, &mut self.ams_filters);
        });
        if serde_json::to_string(&self.ams_setup).unwrap_or_default() != before {
            self.apply_ams();
        }
        // what the print will use
        ui.add_space(12.0);
        ui.label(theme::caption("Filament slots for slicing"));
        theme::card(ui, |ui| {
            if self.slots.is_empty() {
                ui.label(RichText::new("No trays loaded yet.").small().color(theme::MUTED));
            }
            ui.horizontal_wrapped(|ui| {
                for s in &self.slots {
                    egui::Frame::new().fill(theme::BG).stroke(egui::Stroke::new(1.0, theme::BORDER)).corner_radius(16).inner_margin(egui::Margin::symmetric(10, 5)).show(ui, |ui| {
                        ui.horizontal(|ui| {
                            let (r, _) = ui.allocate_exact_size(egui::vec2(14.0, 14.0), egui::Sense::hover());
                            ui.painter().circle_filled(r.center(), 6.0, Color32::from_rgb(s.colour[0], s.colour[1], s.colour[2]));
                            ui.painter().circle_stroke(r.center(), 6.0, egui::Stroke::new(1.0, theme::BORDER_STRONG));
                            ui.label(RichText::new(&s.label).font(theme::mono(12.0)).color(theme::TEXT));
                            ui.label(RichText::new(&s.filament).small().color(theme::TEXT_SOFT));
                        });
                    });
                }
            });
        });
        self.print_filaments_ui(ui, &filaments);
    }

    fn set_tab(&mut self, tab: Tab) {
        match tab {
            Tab::Prepare => {
                self.tab = Tab::Prepare;
                self.show_model = true;
                self.show_toolpath = false;
            }
            Tab::Preview if self.result.is_some() => {
                self.tab = Tab::Preview;
                self.show_toolpath = true;
                self.show_model = false;
            }
            Tab::Preview => self.status = "Slice the plate first to see the preview.".into(),
            Tab::Device => self.tab = Tab::Device,
        }
    }

    fn top_bar(&mut self, ui: &mut egui::Ui) {
        ui.horizontal(|ui| {
            ui.set_min_height(46.0);
            let (r, _) = ui.allocate_exact_size(egui::vec2(24.0, 24.0), egui::Sense::hover());
            theme::logo(ui.painter(), r);
            ui.label(RichText::new("VertexSlicer").font(theme::semibold(17.0)).color(theme::TEXT));
            if self.mesh.is_some() {
                egui::Frame::new().stroke(egui::Stroke::new(1.0, theme::BORDER_STRONG)).corner_radius(6).inner_margin(egui::Margin::symmetric(8, 3)).show(ui, |ui| {
                    ui.label(RichText::new(&self.model_name).font(theme::mono(12.0)).color(theme::MUTED));
                });
            }
            ui.add_space(10.0);
            let mut tab = self.tab;
            if theme::segmented(ui, &mut tab, &[(Tab::Prepare, "Prepare".to_string()), (Tab::Preview, "Preview".to_string()), (Tab::Device, "Device".to_string())], false, false) {
                self.set_tab(tab);
            }
            ui.add_space(10.0);
            if theme::ghost(ui, true, "Open…").on_hover_text("STL, OBJ, 3MF model or a saved project (you can also drag a file onto the window)").clicked() {
                self.open_model();
            }
            if theme::ghost(ui, self.mesh.is_some(), "Save project…").clicked() {
                self.save_project();
            }
            ui.add_space(6.0);
            if theme::ghost(ui, !self.hist_undo.is_empty(), "Undo").on_hover_text("Undo the last change (Ctrl+Z)").clicked() {
                self.undo();
            }
            if theme::ghost(ui, !self.hist_redo.is_empty(), "Redo").on_hover_text("Redo (Ctrl+Y or Ctrl+Shift+Z)").clicked() {
                self.redo();
            }
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                let problems = self.problems();
                let busy = self.rx.is_some();
                let slice = theme::primary(ui, problems.is_empty() && !busy, if busy { "Slicing…" } else { "Slice" });
                if slice.clicked() {
                    self.start_slice();
                }
                if !problems.is_empty() {
                    slice.on_disabled_hover_text(problems.join("\n"));
                }
                if theme::secondary(ui, self.result.is_some(), "Export G-code").on_hover_text("Save a Bambu .gcode.3mf").clicked() {
                    self.export();
                }
                ui.add_space(8.0);
                let status = self.status.clone();
                ui.add(egui::Label::new(RichText::new(&status).small().color(theme::MUTED)).truncate()).on_hover_text(status);
            });
        });
    }

    /// Camera shortcuts: isometric, top, front, and zoom-to-fit.
    fn camera_preset(&mut self, which: &str) {
        match which {
            "iso" => {
                self.cam.yaw = -1.0;
                self.cam.pitch = 0.65;
            }
            "top" => {
                self.cam.yaw = -std::f32::consts::FRAC_PI_2;
                self.cam.pitch = 1.5;
            }
            "front" => {
                self.cam.yaw = -std::f32::consts::FRAC_PI_2;
                self.cam.pitch = 0.12;
            }
            _ => {
                if self.mesh.is_some() {
                    let pl = self.place();
                    let c = [(self.lo[0] + self.hi[0]) / 2.0 + pl.0, (self.lo[1] + self.hi[1]) / 2.0 + pl.1, (self.hi[2] - self.lo[2]) / 2.0];
                    let size = (self.hi[0] - self.lo[0]).max(self.hi[1] - self.lo[1]).max(self.hi[2] - self.lo[2]);
                    self.cam.target = Vec3::new(c[0] as f32, c[1] as f32, c[2] as f32);
                    self.cam.dist = (size as f32 * 2.6).max(60.0);
                } else {
                    let (bx, by) = self.bed_size();
                    self.cam.target = Vec3::new(bx as f32 / 2.0, by as f32 / 2.0, 0.0);
                    self.cam.dist = 520.0;
                }
            }
        }
    }

    /// Floating controls drawn over the 3D view.
    fn overlays(&mut self, ui: &mut egui::Ui, rect: egui::Rect) {
        let ctx = ui.ctx().clone();
        let area = |id: &str, pivot: egui::Align2, pos: egui::Pos2| egui::Area::new(egui::Id::unique(id)).pivot(pivot).fixed_pos(pos).order(egui::Order::Middle);

        // camera buttons (top right)
        area("cam_btns", egui::Align2::RIGHT_TOP, rect.right_top() + egui::vec2(-16.0, 16.0)).show(&ctx, |ui| {
            ui.horizontal(|ui| {
                ui.spacing_mut().item_spacing.x = 6.0;
                let st = |c: Color32| egui::Stroke::new(1.6, c);
                if theme::icon_button(ui, "Isometric view", false, |p, r, c| {
                    let (cx, t, b) = (r.center().x, r.top(), r.bottom());
                    let m = r.center().y;
                    let pts = [egui::pos2(cx, t), egui::pos2(r.right(), t + r.height() * 0.25), egui::pos2(r.right(), b - r.height() * 0.25), egui::pos2(cx, b), egui::pos2(r.left(), b - r.height() * 0.25), egui::pos2(r.left(), t + r.height() * 0.25)];
                    for i in 0..6 {
                        p.line_segment([pts[i], pts[(i + 1) % 6]], st(c));
                    }
                    p.line_segment([egui::pos2(cx, m), pts[1]], st(c));
                    p.line_segment([egui::pos2(cx, m), pts[5]], st(c));
                    p.line_segment([egui::pos2(cx, m), pts[3]], st(c));
                })
                .clicked()
                {
                    self.camera_preset("iso");
                }
                if theme::icon_button(ui, "Top view", false, |p, r, c| {
                    p.rect_stroke(r, 3.0, st(c), egui::StrokeKind::Inside);
                    p.circle_stroke(r.center(), 3.5, st(c));
                })
                .clicked()
                {
                    self.camera_preset("top");
                }
                if theme::icon_button(ui, "Front view", false, |p, r, c| {
                    let rr = egui::Rect::from_min_max(egui::pos2(r.left(), r.top() + 3.0), egui::pos2(r.right(), r.bottom() - 3.0));
                    p.rect_stroke(rr, 3.0, st(c), egui::StrokeKind::Inside);
                })
                .clicked()
                {
                    self.camera_preset("front");
                }
                if theme::icon_button(ui, "Zoom to fit", false, |p, r, c| {
                    let k = 5.0;
                    for (corner, dx, dy) in [(r.left_top(), 1.0, 1.0), (r.right_top(), -1.0, 1.0), (r.left_bottom(), 1.0, -1.0), (r.right_bottom(), -1.0, -1.0)] {
                        p.line_segment([corner, corner + egui::vec2(k * dx, 0.0)], st(c));
                        p.line_segment([corner, corner + egui::vec2(0.0, k * dy)], st(c));
                    }
                })
                .clicked()
                {
                    self.camera_preset("fit");
                }
            });
        });

        // axis gizmo (bottom right)
        {
            let aspect = rect.width() / rect.height().max(1.0);
            let vp = self.cam.view_proj(aspect);
            let o = vp.project_point3(self.cam.target);
            let origin = rect.right_bottom() + egui::vec2(-44.0, -40.0);
            let p = ui.painter();
            for (axis, col, name) in [(Vec3::X, Color32::from_rgb(0xFF, 0x6B, 0x6B), "X"), (Vec3::Y, Color32::from_rgb(0x5B, 0xE3, 0x7D), "Y"), (Vec3::Z, Color32::from_rgb(0x5A, 0xA9, 0xFF), "Z")] {
                let q = vp.project_point3(self.cam.target + axis * (self.cam.dist * 0.1));
                let d = egui::vec2((q.x - o.x) * rect.width(), -(q.y - o.y) * rect.height());
                let d = if d.length() > 1e-3 { d.normalized() * 26.0 } else { d };
                p.line_segment([origin, origin + d], egui::Stroke::new(2.5, col));
                p.text(origin + d * 1.25, egui::Align2::CENTER_CENTER, name, theme::mono(11.0), col);
            }
        }

        if self.mesh.is_none() {
            ui.painter().text(rect.center(), egui::Align2::CENTER_CENTER, "Open a model or drop an STL, OBJ or 3MF here", egui::FontId::proportional(18.0), theme::MUTED);
        }

        // filament key (top left, under the view-mode buttons once there is a slice)
        if self.mesh.is_some() {
            let y = if self.result.is_some() { 72.0 } else { 16.0 };
            area("filament_key", egui::Align2::LEFT_TOP, rect.left_top() + egui::vec2(16.0, y)).show(&ctx, |ui| {
                theme::glass().show(ui, |ui| {
                    ui.spacing_mut().item_spacing.y = 4.0;
                    ui.label(theme::caption(if self.ams { "Filaments" } else { "Filament" }));
                    let dot = |ui: &mut egui::Ui, c: [u8; 3]| {
                        let (r, _) = ui.allocate_exact_size(egui::vec2(14.0, 14.0), egui::Sense::hover());
                        ui.painter().circle_filled(r.center(), 6.0, Color32::from_rgb(c[0], c[1], c[2]));
                        ui.painter().circle_stroke(r.center(), 6.0, egui::Stroke::new(1.0, theme::BORDER_STRONG));
                    };
                    if self.ams {
                        let used: Vec<usize> = self.zones.iter().filter_map(|z| z.filament.map(|f| f as usize)).collect();
                        for (i, s) in self.slots.iter().enumerate() {
                            ui.horizontal(|ui| {
                                dot(ui, s.colour);
                                ui.label(RichText::new(&s.label).font(theme::mono(12.0)).color(theme::TEXT));
                                ui.label(RichText::new(&s.filament).small().color(theme::TEXT_SOFT));
                                if i == self.object_slot {
                                    ui.label(RichText::new("object").small().color(theme::ACCENT_TEXT));
                                } else if used.contains(&i) {
                                    ui.label(RichText::new("zone").small().color(theme::MUTED));
                                }
                            });
                        }
                    } else {
                        ui.horizontal(|ui| {
                            dot(ui, [0xE8, 0xE8, 0xE8]);
                            ui.label(RichText::new(&self.filament).small().color(theme::TEXT_SOFT));
                        });
                        if let Some(i) = &self.imported {
                            ui.label(RichText::new(format!("{} · {:.0} °C · bed {:.0} °C", i.filament_type, i.nozzle_temp, i.bed_temp)).font(theme::mono(11.0)).color(theme::MUTED));
                        }
                    }
                    if self.tower_overlaps() {
                        ui.colored_label(theme::WARN, RichText::new("⚠ Prime tower overlaps the model").small());
                    }
                    if ui.add(egui::Label::new(RichText::new("Edit on the Device page →").small().color(theme::ACCENT_TEXT)).sense(egui::Sense::click())).on_hover_cursor(egui::CursorIcon::PointingHand).clicked() {
                        self.tab = Tab::Device;
                    }
                });
            });
        }

        let Some(res) = &self.result else {
            ui.painter().text(rect.left_bottom() + egui::vec2(16.0, -16.0), egui::Align2::LEFT_BOTTOM, "Left-drag: orbit (or move the selected zone) · Right/middle-drag: pan · Wheel: zoom · Click a zone to select", egui::FontId::proportional(12.0), theme::MUTED);
            return;
        };
        let n = res.layer_z.len();
        self.layer = self.layer.clamp(1, n.max(1));
        let i = self.layer - 1;
        let (lz, lh) = (res.layer_z[i], res.layer_h[i]);
        let mut recolor = false;
        let mut scroll_steps = 0i64;

        // view mode (top left)
        area("view_mode", egui::Align2::LEFT_TOP, rect.left_top() + egui::vec2(16.0, 16.0)).show(&ctx, |ui| {
            let mut mode = match (self.show_toolpath, self.show_model) {
                (true, false) => 0,
                (false, true) => 1,
                _ => 2,
            };
            if theme::segmented(ui, &mut mode, &[(0, "Toolpaths".to_string()), (1, "Solid".to_string()), (2, "Both".to_string())], false, false) {
                self.show_toolpath = mode != 1;
                self.show_model = mode != 0;
            }
        });

        // vertical layer slider (right)
        let slider_resp = area("layer_slider", egui::Align2::RIGHT_CENTER, rect.right_center() + egui::vec2(-16.0, 0.0)).show(&ctx, |ui| {
            theme::glass().inner_margin(egui::Margin::symmetric(10, 12)).show(ui, |ui| {
                ui.vertical_centered(|ui| {
                    ui.label(RichText::new(n.to_string()).font(theme::mono(12.0)).color(theme::MUTED));
                    let h = (rect.height() * 0.42).clamp(160.0, 380.0);
                    ui.spacing_mut().slider_width = h;
                    ui.add(egui::Slider::new(&mut self.layer, 1..=n.max(1)).vertical().show_value(false).trailing_fill(true).smart_aim(false));
                    ui.label(RichText::new("1").font(theme::mono(12.0)).color(theme::MUTED));
                });
            });
        });
        if slider_resp.response.contains_pointer() {
            let (d, shift) = (wheel_delta(ui), ui.input(|i| i.modifiers.shift));
            scroll_steps = wheel_steps(&mut self.scroll_accum, d) * if shift { 10 } else { 1 };
        }
        let slider_w = slider_resp.response.rect.width();

        // layer readout (left of the slider)
        area("layer_readout", egui::Align2::RIGHT_CENTER, rect.right_center() + egui::vec2(-16.0 - slider_w - 10.0, 0.0)).show(&ctx, |ui| {
            theme::glass().show(ui, |ui| {
                ui.spacing_mut().item_spacing.y = 2.0;
                ui.label(theme::caption("Layer"));
                ui.horizontal(|ui| {
                    ui.spacing_mut().item_spacing.x = 2.0;
                    ui.label(RichText::new(self.layer.to_string()).font(theme::mono(20.0)).color(Color32::WHITE));
                    ui.label(RichText::new(format!(" / {n}")).font(theme::mono(13.0)).color(theme::MUTED));
                });
                ui.label(RichText::new(format!("Z {lz:.2} mm")).font(theme::mono(12.0)).color(theme::ACCENT_TEXT));
                ui.label(RichText::new(format!("h {lh:.2} mm")).font(theme::mono(12.0)).color(theme::MUTED));
                ui.add_space(4.0);
                ui.horizontal(|ui| {
                    theme::toggle(ui, &mut self.only_layer);
                    ui.label(RichText::new("Only this layer").small().color(theme::TEXT_SOFT));
                });
            });
        });

        // legend (bottom left)
        area("legend", egui::Align2::LEFT_BOTTOM, rect.left_bottom() + egui::vec2(16.0, -96.0)).show(&ctx, |ui| {
            theme::glass().show(ui, |ui| {
                ui.label(theme::caption("Color by"));
                let before = self.color_by;
                let mut c = self.color_by;
                theme::segmented(ui, &mut c, &[(ColorBy::Height, "Height".to_string()), (ColorBy::Feature, "Feature".to_string()), (ColorBy::Filament, "Filament".to_string())], false, false);
                self.color_by = c;
                if self.color_by != before {
                    recolor = true;
                }
                ui.add_space(2.0);
                let swatch = |ui: &mut egui::Ui, col: [f32; 3], text: String| {
                    ui.horizontal(|ui| {
                        let c = Color32::from_rgb((col[0] * 255.0) as u8, (col[1] * 255.0) as u8, (col[2] * 255.0) as u8);
                        let (r, _) = ui.allocate_exact_size(egui::vec2(18.0, 10.0), egui::Sense::hover());
                        ui.painter().rect_filled(egui::Rect::from_center_size(r.center(), egui::vec2(18.0, 4.0)), 2.0, c);
                        ui.label(RichText::new(text).small().color(theme::TEXT_SOFT));
                    });
                };
                ui.spacing_mut().item_spacing.y = 3.0;
                match self.color_by {
                    ColorBy::Height => {
                        for (h, c) in &res.legend {
                            swatch(ui, *c, format!("{h:.2} mm layers"));
                        }
                    }
                    ColorBy::Feature => {
                        for (name, c) in &res.legend_feature {
                            swatch(ui, *c, name.to_string());
                        }
                    }
                    ColorBy::Filament => {
                        for (name, c) in &res.legend_filament {
                            swatch(ui, *c, name.clone());
                        }
                    }
                }
            });
        });

        // stats bar (bottom centre)
        area("stats", egui::Align2::CENTER_BOTTOM, rect.center_bottom() + egui::vec2(0.0, -18.0)).show(&ctx, |ui| {
            theme::glass().inner_margin(egui::Margin::symmetric(4, 4)).show(ui, |ui| {
                ui.horizontal(|ui| {
                    let t = res.print_seconds;
                    let mut cells: Vec<(&str, String)> = vec![
                        ("Print time", format!("{}h {:02}m", (t / 3600.0) as u64, ((t % 3600.0) / 60.0) as u64)),
                        ("Filament", format!("{:.1} g · {:.2} m", res.weight_g, res.filament_m)),
                        ("Layers", format!("{n}")),
                        ("Cost", format!("{:.2}", res.cost)),
                    ];
                    if res.tool_changes > 0 {
                        cells.insert(2, ("Changes", res.tool_changes.to_string()));
                    }
                    for (k, (label, value)) in cells.iter().enumerate() {
                        if k > 0 {
                            let (r, _) = ui.allocate_exact_size(egui::vec2(1.0, 38.0), egui::Sense::hover());
                            ui.painter().rect_filled(r, 0.0, theme::BORDER);
                        }
                        egui::Frame::new().inner_margin(egui::Margin::symmetric(14, 6)).show(ui, |ui| {
                            ui.vertical(|ui| {
                                ui.spacing_mut().item_spacing.y = 1.0;
                                ui.label(theme::caption(label));
                                ui.label(RichText::new(value).font(theme::mono(16.0)).color(theme::TEXT));
                            });
                        });
                    }
                });
            });
        });

        if scroll_steps != 0 {
            self.layer = (self.layer as i64 + scroll_steps).clamp(1, n as i64) as usize;
        }
        if recolor {
            self.upload_toolpath();
        }
    }

    fn viewport(&mut self, ui: &mut egui::Ui) {
        let rect = ui.available_rect_before_wrap();
        let resp = ui.allocate_rect(rect, egui::Sense::click_and_drag());
        theme::paint_backdrop(ui.painter(), rect);
        let aspect = rect.width() / rect.height().max(1.0);

        let ndc = |p: egui::Pos2| ((p.x - rect.min.x) / rect.width() * 2.0 - 1.0, 1.0 - (p.y - rect.min.y) / rect.height() * 2.0);
        let ground = |cam: &gl::Camera, p: egui::Pos2| -> Option<(f64, f64)> {
            let (o, d) = cam.ray(ndc(p), aspect);
            (d.z.abs() > 1e-4).then(|| {
                let t = -o.z / d.z;
                ((o.x + d.x * t) as f64, (o.y + d.y * t) as f64)
            })
        };
        let place = self.place();
        let hit_zone = |z: &ZoneUi, g: (f64, f64)| {
            let (x, y) = (g.0 - place.0, g.1 - place.1);
            match z.kind {
                ZKind::Cylinder => {
                    let d = ((x - z.cx).powi(2) + (y - z.cy).powi(2)).sqrt();
                    d <= z.r && d >= z.r_in
                }
                ZKind::Box => (x - z.cx).abs() <= z.w / 2.0 && (y - z.cy).abs() <= z.d / 2.0,
            }
        };

        if resp.hovered() {
            let (ctrl, shift) = ui.input(|i| (i.modifiers.ctrl, i.modifiers.shift));
            if ctrl && self.result.is_some() {
                // Ctrl + wheel in the 3D view also steps layers
                let d = wheel_delta(ui);
                let steps = wheel_steps(&mut self.scroll_accum, d) * if shift { 10 } else { 1 };
                if steps != 0 {
                    let n = self.result.as_ref().map_or(1, |r| r.layer_z.len()) as i64;
                    self.layer = (self.layer as i64 + steps).clamp(1, n) as usize;
                }
            } else {
                let s = ui.input(|i| i.smooth_scroll_delta.y);
                if s != 0.0 {
                    self.cam.zoom(s);
                }
            }
        }
        if self.pick_mode && ui.input(|i| i.key_pressed(egui::Key::Escape)) {
            self.pick_mode = false;
            self.hover_patch = None;
            self.hover_seed = None;
        }
        let mut pick_text: Option<String> = None;
        if self.pick_mode {
            let hover = resp.hover_pos();
            if let (Some(mesh), Some(adj), Some(p)) = (self.mesh.clone(), self.adj.as_ref(), hover) {
                // world ray -> model coordinates
                let (o, d) = self.cam.ray(ndc(p), aspect);
                let o = [o.x as f64 - place.0, o.y as f64 - place.1, o.z as f64 - place.2];
                let d = [d.x as f64, d.y as f64, d.z as f64];
                match mesh.pick(o, d) {
                    Some((seed, _)) => {
                        if self.hover_seed != Some(seed) {
                            self.hover_seed = Some(seed);
                            self.hover_patch = Some(mesh.face_patch(adj, seed, 12.0, d));
                        }
                    }
                    None => {
                        self.hover_seed = None;
                        self.hover_patch = None;
                    }
                }
            } else {
                self.hover_patch = None;
            }
            if let Some(p) = &self.hover_patch {
                pick_text = Some(self.describe_patch(p));
            }
            if resp.clicked_by(egui::PointerButton::Primary) {
                if let Some(p) = self.hover_patch.clone() {
                    match self.pick_kind {
                        PickKind::Zone => self.add_zone_for_patch(&p),
                        PickKind::LayFlat => {
                            // rotate so the picked face's outward normal points straight down
                            let r = mesh_io::rotation_aligning(p.normal, [0.0, 0.0, -1.0]);
                            self.xf = mat_mul(&r, &self.xf);
                            self.pick_mode = false;
                            self.rebuild_mesh(false);
                        }
                    }
                }
            }
        } else if resp.clicked_by(egui::PointerButton::Primary) {
            if let Some(g) = resp.interact_pointer_pos().and_then(|p| ground(&self.cam, p)) {
                self.selected = (0..self.zones.len()).rev().find(|&i| hit_zone(&self.zones[i], g));
            }
        }
        if resp.drag_started_by(egui::PointerButton::Primary) {
            self.dragging_zone = match (self.selected, resp.interact_pointer_pos().and_then(|p| ground(&self.cam, p))) {
                (Some(i), Some(g)) => hit_zone(&self.zones[i], g),
                _ => false,
            };
        }
        let d = resp.drag_delta();
        if resp.dragged_by(egui::PointerButton::Primary) {
            if self.dragging_zone {
                if let (Some(i), Some(p)) = (self.selected, resp.interact_pointer_pos()) {
                    let prev = p - d;
                    if let (Some(a), Some(b)) = (ground(&self.cam, prev), ground(&self.cam, p)) {
                        self.zones[i].cx += b.0 - a.0;
                        self.zones[i].cy += b.1 - a.1;
                    }
                }
            } else {
                self.cam.orbit(d.x, d.y);
            }
        }
        if resp.dragged_by(egui::PointerButton::Secondary) || resp.dragged_by(egui::PointerButton::Middle) {
            self.cam.pan(d.x, d.y);
        }

        // geometry for this frame
        let highlight = match (&self.hover_patch, &self.mesh) {
            (Some(p), Some(m)) => {
                let tris: Vec<[u32; 3]> = p.tris.iter().map(|&t| m.tris[t]).collect();
                gl::mesh_tris(&m.verts, &tris)
            }
            _ => vec![],
        };
        let mut zt = vec![];
        let mut zl = vec![];
        let zh = (self.hi[2] - self.lo[2]) as f32 + 1.0;
        for (i, z) in self.zones.iter().enumerate() {
            let (z0, z1) = if z.use_z { (z.z0 as f32, z.z1 as f32) } else { (0.0, zh) };
            let (cx, cy) = ((z.cx + place.0) as f32, (z.cy + place.1) as f32);
            match z.kind {
                ZKind::Cylinder if z.r_in > 0.0 => gl::ring(cx, cy, z.r_in as f32, z.r as f32, z0, z1, self.zone_color(i), &mut zt, &mut zl),
                ZKind::Cylinder => gl::cylinder(cx, cy, z.r as f32, z0, z1, self.zone_color(i), &mut zt, &mut zl),
                ZKind::Box => gl::cuboid(cx - z.w as f32 / 2.0, cy - z.d as f32 / 2.0, cx + z.w as f32 / 2.0, cy + z.d as f32 / 2.0, z0, z1, self.zone_color(i), &mut zt, &mut zl),
            }
        }
        let (first, count) = match &self.result {
            Some(r) if self.show_toolpath => {
                let end = r.layer_end[self.layer - 1] as i32;
                let start = if self.only_layer && self.layer > 1 { r.layer_end[self.layer - 2] as i32 } else { 0 };
                (start, end)
            }
            _ => (0, 0),
        };
        let frame = gl::Frame {
            view_proj: self.cam.view_proj(aspect),
            model: Mat4::from_translation(Vec3::new(place.0 as f32, place.1 as f32, place.2 as f32)),
            model_color: [0.62, 0.68, 0.78, 1.0],
            show_model: self.show_model && self.mesh.is_some(),
            show_toolpath: self.show_toolpath && self.result.is_some(),
            toolpath_first: first,
            toolpath_count: count,
            highlight,
            zones_tri: zt,
            zones_line: zl,
            zone_color: [ORANGE[0], ORANGE[1], ORANGE[2], 0.16],
            clear_depth: true,
        };
        let scene = self.scene.clone();
        ui.painter().add(egui::PaintCallback {
            rect,
            callback: Arc::new(eframe::egui_glow::CallbackFn::new(move |info, painter| {
                let vp = info.viewport_in_pixels();
                let cp = info.clip_rect_in_pixels();
                scene.lock().unwrap().paint(
                    painter.gl(),
                    [vp.left_px, vp.from_bottom_px, vp.width_px, vp.height_px],
                    [cp.left_px, cp.from_bottom_px, cp.width_px, cp.height_px],
                    &frame,
                );
            })),
        });
        if self.pick_mode {
            let msg = pick_text.unwrap_or_else(|| "Pick face: hover a surface of the model (Esc to exit)".into());
            ui.painter().text(
                rect.center_top() + egui::vec2(0.0, 14.0),
                egui::Align2::CENTER_TOP,
                msg,
                egui::FontId::proportional(15.0),
                theme::ACCENT_TEXT,
            );
        }
        self.overlays(ui, rect);
    }
}

impl eframe::App for App {
    fn ui(&mut self, ui: &mut egui::Ui, _frame: &mut eframe::Frame) {
        self.frames += 1;
        // Self-screenshot for automated checks (SLICER_SHOT=path.png): captures only this window.
        if let Some(path) = self.shot_path.clone() {
            let ready = self.frames > 40 && self.rx.is_none() && (self.result.is_some() || (std::env::var("SLICER_DEMO").is_err() && std::env::var("SLICER_STL").is_err()));
            if ready && !self.shot_requested {
                self.shot_requested = true;
                ui.ctx().request_screenshot(move |img| {
                    let [w, h] = img.size;
                    let rgba: Vec<u8> = img.pixels.iter().flat_map(|c| { let a = c.to_array(); [a[0], a[1], a[2], 255] }).collect();
                    if let Some(buf) = image::RgbaImage::from_raw(w as u32, h as u32, rgba) {
                        let _ = buf.save(&path);
                    }
                    std::process::exit(0);
                });
            }
            ui.ctx().request_repaint();
        }
        let dropped: Vec<String> = ui.ctx().input(|i| i.raw.dropped_files.iter().map(|f| f.path().to_string_lossy().to_string()).collect());
        if let Some(p) = dropped.first() {
            self.open_any(p);
        }
        self.poll_slice();
        if self.rx.is_some() {
            ui.ctx().request_repaint();
        }
        // Ctrl+Z undo, Ctrl+Y / Ctrl+Shift+Z redo (text fields keep their own undo while typing)
        if !ui.ctx().egui_wants_keyboard_input() {
            use egui::{Key, KeyboardShortcut, Modifiers};
            let (redo, undo) = ui.ctx().input_mut(|i| {
                let redo = i.consume_shortcut(&KeyboardShortcut::new(Modifiers::COMMAND | Modifiers::SHIFT, Key::Z)) || i.consume_shortcut(&KeyboardShortcut::new(Modifiers::COMMAND, Key::Y));
                (redo, i.consume_shortcut(&KeyboardShortcut::new(Modifiers::COMMAND, Key::Z)))
            });
            if redo {
                self.redo();
            } else if undo {
                self.undo();
            }
        }
        egui::Panel::top("top")
            .frame(egui::Frame::new().fill(theme::PANEL).inner_margin(egui::Margin::symmetric(18, 6)).stroke(egui::Stroke::new(1.0, theme::BORDER)))
            .show(ui, |ui| self.top_bar(ui));
        if self.tab == Tab::Device {
            egui::CentralPanel::default().frame(egui::Frame::NONE.fill(theme::BG)).show(ui, |ui| self.device_page(ui));
        } else {
            egui::Panel::left("left")
                .default_size(350.0)
                .resizable(true)
                .frame(egui::Frame::new().fill(theme::PANEL).inner_margin(egui::Margin { left: 18, right: 6, top: 0, bottom: 0 }).stroke(egui::Stroke::new(1.0, theme::BORDER)))
                .show(ui, |ui| self.left_panel(ui));
            egui::CentralPanel::default().frame(egui::Frame::NONE).show(ui, |ui| self.viewport(ui));
        }
        self.track_history(ui.ctx());
        if ui.ctx().input(|i| i.pointer.any_released()) {
            // an edit may finish on release with nothing else asking for a repaint
            ui.ctx().request_repaint();
        }
    }
}
