use engine::{gcode, mesh, plan};

use clap::{Parser, Subcommand};
use engine::plan::{Class, Config, Shape, Zone};

#[derive(Parser)]
#[command(name = "vertexslicer-cli", about = "VertexSlicer: a mixed-layer slicer for the Bambu Lab H2D")]
struct Cli {
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    /// Slice an STL to G-code
    Slice {
        input: String,
        #[arg(short, long, default_value = "out.gcode")]
        output: String,
        /// Finest layer height step (all heights are multiples of this)
        #[arg(long, default_value_t = 0.1)]
        base: f64,
        /// Default wall/skin layer height
        #[arg(long, default_value_t = 0.1)]
        wall_height: f64,
        /// Default sparse-infill layer height
        #[arg(long, default_value_t = 0.3)]
        infill_height: f64,
        #[arg(long)]
        walls: Option<u32>,
        /// Sparse infill density 0..1
        #[arg(long)]
        density: Option<f64>,
        /// Use a real Bambu Studio preset triple (machine defaults to the H2D 0.4 nozzle)
        #[arg(long, default_value = "Bambu Lab H2D 0.4 nozzle")]
        machine: String,
        #[arg(long)]
        filament: Option<String>,
        #[arg(long)]
        process: Option<String>,
        /// Generate supports
        #[arg(long)]
        support: bool,
        /// Brim width in mm
        #[arg(long)]
        brim: Option<f64>,
        /// Skirt loops
        #[arg(long)]
        skirt: Option<u32>,
        /// grid | rectilinear | triangles | gyroid
        #[arg(long)]
        pattern: Option<String>,
        /// Fine/coarse zone, repeatable. Coordinates are in the STL's own frame.
        ///   cyl:cx,cy,r,wall_h,infill_h[,zmin,zmax]
        ///   box:x0,y0,x1,y1,wall_h,infill_h[,zmin,zmax]
        /// append ",solid", ",concentric", ",infill=NN" (percent) and/or ",fil=N" (filament slot) to either form to fill that zone solid / in rings
        #[arg(long = "zone")]
        zones: Vec<String>,
        /// Filament slot (AMS tray) preset, repeatable, in slot order; append #2 to put it on the right hotend
        ///   e.g. --slot "Generic ASA @BBL H2D" --slot "Generic PLA @BBL H2D#2"
        #[arg(long = "slot")]
        slots: Vec<String>,
        /// Slot the object prints in (0-based; default 0)
        #[arg(long, default_value_t = 0)]
        object_filament: u8,
        /// Prime tower position and purge: x,y,width,depth,purge_mm3
        #[arg(long)]
        tower: Option<String>,
        /// No prime tower: the printer purges into its waste chute at every change
        #[arg(long)]
        no_tower: bool,
        /// Purge into the part's sparse infill first after each filament change
        #[arg(long)]
        purge_infill: bool,
        /// File with Bambu Studio start G-code (replaces the generic default)
        #[arg(long)]
        start_gcode: Option<String>,
        #[arg(long)]
        end_gcode: Option<String>,
        /// Fill the start G-code (defaults match the ASA sample the profile was extracted from)
        #[arg(long)]
        nozzle_temp: Option<u32>,
        #[arg(long)]
        bed_temp: Option<u32>,
        #[arg(long)]
        chamber_temp: Option<u32>,
        #[arg(long)]
        filament_type: Option<String>,
        /// Also write <output>.3mf, a Bambu .gcode.3mf for Bambu Studio / Handy / the printer
        #[arg(long)]
        pack_3mf: bool,
    },
    /// List Bambu Studio presets for a machine, or show what a preset triple imports
    Profiles {
        /// Machine preset name (default: Bambu Lab H2D 0.4 nozzle)
        #[arg(long, default_value = "Bambu Lab H2D 0.4 nozzle")]
        machine: String,
        #[arg(long)]
        filament: Option<String>,
        #[arg(long)]
        process: Option<String>,
    },
    /// Print bounds, detected holes and cross-section loops of an STL at given heights
    Inspect {
        input: String,
        /// heights above the model bottom (mm), comma separated
        #[arg(long, default_value = "0.1,0.3,0.5,0.56,0.7,1.0,2.0")]
        z: String,
    },
    /// Render a machine G-code template against a settings file (for checking the evaluator)
    EvalTemplate {
        /// Bambu project_settings.config (JSON) providing every setting
        #[arg(long)]
        config: String,
        /// machine preset whose template to render (looked up in your Bambu Studio library)
        #[arg(long, default_value = "Bambu Lab H2D 0.4 nozzle")]
        machine: String,
        /// start | end
        #[arg(long, default_value = "start")]
        which: String,
        #[arg(long, default_value_t = 6.0)]
        max_z: f64,
        /// extra variable, name=json (repeatable), e.g. --set next_filament_id=3
        #[arg(long = "set")]
        sets: Vec<String>,
        /// first layer bbox: minx,miny,w,h
        #[arg(long, default_value = "0,0,100,100")]
        bbox: String,
        #[arg(short, long)]
        output: String,
    },
    /// Write a named test part (tee | bridge | steps) as STL
    TestShape { name: String, output: String },
    /// Write a washer test STL (outer R, hole R, height)
    TestWasher { output: String, #[arg(default_value_t = 30.0)] r_out: f64, #[arg(default_value_t = 8.0)] r_in: f64, #[arg(default_value_t = 6.0)] height: f64 },
}

fn parse_zone(s: &str, base: f64) -> anyhow::Result<Zone> {
    let (kind, rest) = s.split_once(':').ok_or_else(|| anyhow::anyhow!("zone must look like cyl:... or box:..."))?;
    // optional trailing ",solid" makes the zone fully solid
    let mut rest = rest.trim();
    let (mut solid, mut pattern, mut density, mut filament) = (false, None, None, None);
    loop {
        if let Some((r, d)) = rest.rsplit_once(",fil=") {
            if let Ok(v) = d.parse::<u8>() {
                filament = Some(v);
                rest = r;
                continue;
            }
        }
        if let Some((r, d)) = rest.rsplit_once(",infill=") {
            if let Ok(v) = d.trim_end_matches('%').parse::<f64>() {
                density = Some((v / 100.0).clamp(0.02, 1.0));
                rest = r;
                continue;
            }
        }
        if let Some(r) = rest.strip_suffix(",solid") {
            solid = true;
            rest = r;
        } else if let Some(r) = rest.strip_suffix(",concentric") {
            pattern = Some(engine::infill::Pattern::Concentric);
            rest = r;
        } else {
            break;
        }
    }
    let v: Vec<f64> = rest.split(',').map(|x| x.trim().parse::<f64>()).collect::<Result<_, _>>()?;
    let mult = |h: f64| (h / base).round() as u32;
    let (shape, rest) = match kind {
        "cyl" if v.len() >= 5 => (Shape::Circle { cx: v[0], cy: v[1], r: v[2] }, &v[3..]),
        "box" if v.len() >= 6 => (Shape::Rect { x0: v[0], y0: v[1], x1: v[2], y1: v[3] }, &v[4..]),
        _ => anyhow::bail!("bad zone spec: {s}"),
    };
    Ok(Zone { shape, class: Class { wm: mult(rest[0]), im: mult(rest[1]) }, zmin: rest.get(2).copied(), zmax: rest.get(3).copied(), solid, pattern, density, filament })
}

fn main() -> anyhow::Result<()> {
    match Cli::parse().cmd {
        Cmd::Profiles { machine, filament, process } => {
            use engine::bbl::{self, BedType, Kind, Library};
            let lib = Library::discover()?;
            println!("library: {}", lib.root.display());
            match (filament, process) {
                (Some(f), Some(p)) => {
                    let i = bbl::import(&lib, &machine, &f, &p, BedType::TexturedPei)?;
                    println!("{i:#?}");
                }
                _ => {
                    println!("machines (H2D): {:?}", lib.machines().iter().filter(|e| e.name.contains("H2D")).map(|e| &e.name).collect::<Vec<_>>());
                    let fl = lib.compatible(Kind::Filament, &machine);
                    let pr = lib.compatible(Kind::Process, &machine);
                    println!("{} filaments compatible with '{}':", fl.len(), machine);
                    for e in fl.iter().take(12) { println!("  {}{}", e.name, if e.user { "  [user]" } else { "" }); }
                    println!("{} processes:", pr.len());
                    for e in &pr { println!("  {}{}", e.name, if e.user { "  [user]" } else { "" }); }
                }
            }
        }
        Cmd::Inspect { input, z } => {
            let m = mesh::Mesh::load_stl(&input)?;
            let (lo, hi) = m.bounds();
            println!("{} triangles, bounds X {:.2}..{:.2}  Y {:.2}..{:.2}  Z {:.2}..{:.2}", m.tris.len(), lo[0], hi[0], lo[1], hi[1], lo[2], hi[2]);
            for h in m.detect_holes() {
                println!("hole: centre ({:.2}, {:.2}) r {:.2}  z {:.2}..{:.2}", h.cx, h.cy, h.r, h.z0 - lo[2], h.z1 - lo[2]);
            }
            for zs in z.split(',') {
                let zz: f64 = zs.trim().parse()?;
                let polys = m.slice(lo[2] + zz);
                let mut outers = 0;
                let mut holes = 0;
                let mut net = 0.0;
                for p in &polys {
                    let a = engine::geom::area(p);
                    net += a;
                    if a >= 0.0 { outers += 1 } else { holes += 1 }
                }
                println!("z={zz:>5}: {} loops ({outers} outer, {holes} hole), net area {:.2} mm2", polys.len(), net.abs());
                for p in polys.iter().filter(|p| engine::geom::area(p) < 0.0) {
                    let (mut x0, mut x1, mut y0, mut y1) = (f64::MAX, f64::MIN, f64::MAX, f64::MIN);
                    for q in p { x0 = x0.min(q.0); x1 = x1.max(q.0); y0 = y0.min(q.1); y1 = y1.max(q.1); }
                    println!("    hole loop: {} pts, bbox x {:.2}..{:.2} y {:.2}..{:.2}, area {:.2}", p.len(), x0, x1, y0, y1, engine::geom::area(p).abs());
                }
            }
        }
        Cmd::EvalTemplate { config, machine, which, max_z, bbox, output, sets } => {
            use engine::{bbl, gcode_template as gt};
            let lib = bbl::Library::discover()?;
            let m = lib.resolve(bbl::Kind::Machine, &machine)?;
            let key = match which.as_str() {
                "end" => "machine_end_gcode",
                "change" => "change_filament_gcode",
                _ => "machine_start_gcode",
            };
            let tpl = bbl::get_s(&m, key).ok_or_else(|| anyhow::anyhow!("machine preset has no {key}"))?;
            let all: bbl::Settings = serde_json::from_str(&std::fs::read_to_string(&config)?)?;
            let b: Vec<f64> = bbox.split(',').map(|x| x.trim().parse()).collect::<Result<_, _>>()?;
            let rt = gt::Runtime {
                max_print_z: max_z,
                first_layer_min: (b[0], b[1]),
                first_layer_size: (b[2], b[3]),
                bed_type: bbl::get_s(&all, "curr_bed_type").unwrap_or_else(|| "Textured PEI Plate".into()),
                total_layers: 30,
                ..Default::default()
            };
            let mut extra = bbl::Settings::new();
            for kv in &sets {
                let (k, v) = kv.split_once('=').ok_or_else(|| anyhow::anyhow!("--set needs name=value"))?;
                extra.insert(k.to_string(), serde_json::from_str(v).unwrap_or_else(|_| serde_json::Value::String(v.to_string())));
            }
            let out = gt::render_with(&tpl, &all, &rt, &extra).map_err(|e| anyhow::anyhow!(e))?;
            std::fs::write(&output, &out)?;
            println!("rendered {} bytes -> {output}", out.len());
        }
        Cmd::TestShape { name, output } => {
            let m = mesh::test_shape(&name).ok_or_else(|| anyhow::anyhow!("unknown shape '{name}' (tee | bridge | steps)"))?;
            mesh::write_ascii_stl(&m, &output)?;
            println!("wrote {output}");
        }
        Cmd::TestWasher { output, r_out, r_in, height } => {
            mesh::write_ascii_stl(&mesh::washer(r_out, r_in, height, 96), &output)?;
            println!("wrote {output}");
        }
        Cmd::Slice { input, output, base, wall_height, infill_height, walls, density, zones, machine, filament, process, support, brim, skirt, pattern, slots, object_filament, tower, no_tower, purge_infill, start_gcode, end_gcode, nozzle_temp, bed_temp, chamber_temp, filament_type, pack_3mf } => {
            let (mut cfg, mut printer) = match (&filament, &process) {
                (Some(f), Some(p)) => {
                    let lib = engine::bbl::Library::discover()?;
                    let imp = engine::bbl::import(&lib, &machine, f, p, engine::bbl::BedType::TexturedPei)?;
                    for n in &imp.notes {
                        eprintln!("note: {n}");
                    }
                    (imp.to_config(base, wall_height, infill_height), imp.to_printer())
                }
                _ => (Config::basic(base, wall_height, infill_height), gcode::Printer::h2d()),
            };
            if let Some(w) = walls {
                cfg.walls = w;
            }
            if let Some(d) = density {
                cfg.density = d;
            }
            if support {
                cfg.support.enable = true;
            }
            if let Some(b) = brim {
                cfg.adhesion.brim_width = b;
            }
            if let Some(n) = skirt {
                cfg.adhesion.skirt_loops = n;
            }
            if let Some(name) = &pattern {
                let (pt, exact) = engine::infill::Pattern::from_name(name);
                anyhow::ensure!(exact, "unknown infill pattern '{name}'");
                cfg.pattern = pt;
            }
            cfg.filament = object_filament;
            if !slots.is_empty() {
                let lib = engine::bbl::Library::discover()?;
                for sname in &slots {
                    let (name, hotend) = match sname.rsplit_once('#') {
                        Some((n, h)) => (n, h.trim().parse::<u8>().unwrap_or(1).clamp(1, 2) - 1),
                        None => (sname.as_str(), 0),
                    };
                    printer.slots.push(engine::bbl_import::slot(&lib, name, hotend)?);
                    if std::env::var("SLICER_DEBUG").is_ok() {
                        eprintln!("slot {:?}", printer.slots.last());
                    }
                }
            }
            if let Some(t) = &tower {
                let v: Vec<f64> = t.split(',').map(|x| x.trim().parse()).collect::<Result<_, _>>()?;
                anyhow::ensure!(v.len() == 5, "--tower needs x,y,width,depth,purge_mm3");
                printer.tower = gcode::TowerCfg { enable: true, x: v[0], y: v[1], w: v[2], d: v[3], purge_mm3: v[4], purge_into_infill: false };
            }
            printer.tower.enable = !no_tower;
            printer.tower.purge_into_infill = purge_infill;
            let mut m = mesh::Mesh::load_stl(&input)?;
            let (lo, hi) = m.bounds();
            // centre on bed, sit on Z=0
            let (dx, dy) = (printer.bed_x / 2.0 - (lo[0] + hi[0]) / 2.0, printer.bed_y / 2.0 - (lo[1] + hi[1]) / 2.0);
            m.translate([dx, dy, -lo[2]]);
            let mut zs: Vec<Zone> = zones.iter().map(|z| parse_zone(z, base)).collect::<Result<_, _>>()?;
            for z in &mut zs {
                z.translate(dx, dy);
            }
            printer.start_gcode = start_gcode.map(std::fs::read_to_string).transpose()?;
            printer.end_gcode = end_gcode.map(std::fs::read_to_string).transpose()?;
            if let Some(v) = nozzle_temp {
                printer.nozzle_temp = v;
                printer.nozzle_temp_first = v;
            }
            if let Some(v) = bed_temp {
                printer.bed_temp = v;
                printer.bed_temp_first = v;
            }
            if let Some(v) = chamber_temp {
                printer.chamber_temp = v;
            }
            if let Some(v) = filament_type {
                printer.filament_type = v;
            }
            let t = std::time::Instant::now();
            let ops = plan::plan(&m, &cfg, &zs)?;
            let (g, st) = gcode::write(&ops, &cfg, &printer, (dx, dy));
            std::fs::write(&output, &g)?;
            if pack_3mf {
                let p3 = if output.ends_with(".gcode") { format!("{}.3mf", output) } else { format!("{}.gcode.3mf", output) };
                anyhow::ensure!(!std::path::Path::new(&p3).exists() || p3 != input, "refusing to overwrite the input file {p3}");
                gcode::write_3mf(&g, &p3)?;
                println!("wrote {p3}");
            }
            println!("wrote {output} in {:.1?}", t.elapsed());
            println!("layers (distinct z/height steps): {}", st.layers);
            for (h, n) in &st.by_height {
                println!("  height {:.2} mm: {} feature-layers", *h as f64 / 1000.0, n);
            }
            println!("filament: {:.1} m ({:.1} g)", st.filament_mm / 1000.0, st.weight_g);
            if st.tool_changes > 0 {
                println!("filament changes: {}", st.tool_changes);
            }
            for w in &st.warnings { eprintln!("WARNING: {w}"); }
            println!("estimated print time: {}h {:02}m ({} layers slowed for cooling)", (st.seconds / 3600.0) as u64, ((st.seconds % 3600.0) / 60.0) as u64, st.slowed_layers);
        }
    }
    Ok(())
}
