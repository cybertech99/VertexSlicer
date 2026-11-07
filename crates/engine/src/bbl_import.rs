//! Maps a resolved Bambu (machine, filament, process) preset triple onto engine settings.
use crate::bbl::*;
use crate::gcode::{Accels, Fan, Printer, Speeds};
use crate::infill::Pattern;
use crate::plan::{AdhesionCfg, Class, Config, SupportCfg};
use anyhow::Result;
use serde_json::Value;

/// Values pulled out of a (machine, filament, process) triple.
#[derive(Clone, Debug)]
pub struct Imported {
    pub machine_name: String,
    pub filament_name: String,
    pub process_name: String,
    pub bed_x: f64,
    pub bed_y: f64,
    pub max_z: f64,
    pub nozzle: f64,
    pub filament_dia: f64,
    pub filament_type: String,
    pub filament_density: f64,
    pub filament_cost: f64,
    pub flow_ratio: f64,
    pub bridge_flow: f64,
    pub nozzle_temp: f64,
    pub nozzle_temp_first: f64,
    pub bed_temp: f64,
    pub bed_temp_first: f64,
    pub chamber_temp: f64,
    pub retract: f64,
    pub retract_speed: f64,
    pub deretract_speed: f64,
    pub retract_min_travel: f64,
    pub z_hop: f64,
    pub wipe: bool,
    pub wipe_distance: f64,
    pub layer_height: f64,
    pub first_layer_height: f64,
    pub walls: u32,
    pub density: f64,
    pub top_layers: u32,
    pub bottom_layers: u32,
    pub w_outer: f64,
    pub w_inner: f64,
    pub w_sparse: f64,
    pub w_solid: f64,
    pub w_first: f64,
    pub w_support: f64,
    pub pattern: Pattern,
    // speeds (mm/s)
    pub speed_outer: f64,
    pub speed_inner: f64,
    pub speed_overhang: f64,
    pub speed_bridge: f64,
    pub speed_sparse: f64,
    pub speed_solid: f64,
    pub speed_top: f64,
    pub speed_support: f64,
    pub speed_support_interface: f64,
    pub speed_first: f64,
    pub speed_first_infill: f64,
    pub speed_travel: f64,
    // accelerations (mm/s^2)
    pub accel_default: f64,
    pub accel_outer: f64,
    pub accel_inner: f64,
    pub accel_top: f64,
    pub accel_sparse: f64,
    pub accel_bridge: f64,
    pub accel_first: f64,
    pub accel_travel: f64,
    pub max_volumetric: f64,
    // cooling
    pub fan_min: f64,
    pub fan_max: f64,
    pub fan_aux: f64,
    pub fan_overhang: f64,
    pub fan_close_first: u32,
    pub fan_full_layer: u32,
    pub slow_layer_time: f64,
    pub slow_min_speed: f64,
    pub fan_cooling_layer_time: f64,
    pub slow_down: bool,
    // adhesion + support
    pub brim_width: f64,
    pub brim_gap: f64,
    pub skirt_loops: u32,
    pub skirt_distance: f64,
    pub support_enable: bool,
    pub support_angle: f64,
    pub support_on_plate_only: bool,
    pub support_xy_gap: f64,
    pub support_z_gap: f64,
    pub support_interface_layers: u32,
    pub support_spacing: f64,
    pub machine_start_gcode: Option<String>,
    pub machine_end_gcode: Option<String>,
    pub machine_change_gcode: Option<String>,
    /// merged machine + process + filament settings (for template rendering)
    pub all: Settings,
    pub bed_type: String,
    pub notes: Vec<String>,
}

/// Acceleration-style value: "100%" = same as `default`, 0 = unset (use default).
fn accel(p: &Settings, key: &str, default: f64) -> f64 {
    match scalar(p, key) {
        Some(Value::String(t)) => {
            let t = t.trim();
            if let Some(pct) = t.strip_suffix('%') {
                pct.parse::<f64>().map(|v| default * v / 100.0).unwrap_or(default)
            } else {
                match t.parse::<f64>() {
                    Ok(v) if v > 0.0 => v,
                    _ => default,
                }
            }
        }
        _ => default,
    }
}

pub fn import(lib: &Library, machine: &str, filament: &str, process: &str, bed: BedType) -> Result<Imported> {
    let m = lib.resolve(Kind::Machine, machine)?;
    let f = lib.resolve(Kind::Filament, filament)?;
    let p = lib.resolve(Kind::Process, process)?;
    let mut notes = vec![];

    // printable area: ["0x0","350x0","350x320","0x320"]
    let (mut bx, mut by) = (350.0, 320.0);
    if let Some(Value::Array(a)) = m.get("printable_area") {
        let pts: Vec<(f64, f64)> = a
            .iter()
            .filter_map(|v| v.as_str())
            .filter_map(|s| s.split_once('x'))
            .filter_map(|(x, y)| Some((x.parse().ok()?, y.parse().ok()?)))
            .collect();
        if !pts.is_empty() {
            bx = pts.iter().map(|p| p.0).fold(0.0, f64::max);
            by = pts.iter().map(|p| p.1).fold(0.0, f64::max);
        }
    }
    let width = |key: &str, fallback: f64| get_f(&p, key).filter(|w| *w > 0.0).unwrap_or(fallback);
    let default_w = width("line_width", 0.42);
    let top = get_f(&p, "top_shell_layers").unwrap_or(5.0) as u32;
    let bottom = get_f(&p, "bottom_shell_layers").unwrap_or(4.0) as u32;

    let bed_t = get_f_idx(&f, bed.key(), 0).unwrap_or(60.0);
    let bed_t1 = get_f_idx(&f, &format!("{}_initial_layer", bed.key()), 0).unwrap_or(bed_t);
    let nozzle_t = get_f_idx(&f, "nozzle_temperature", 0).unwrap_or(220.0);
    let nozzle_t1 = get_f_idx(&f, "nozzle_temperature_initial_layer", 0).unwrap_or(nozzle_t);
    let chamber = get_f_idx(&f, "chamber_temperatures", 0).unwrap_or(0.0);

    let pattern_name = get_s(&p, "sparse_infill_pattern").unwrap_or_default();
    let (pattern, exact) = Pattern::from_name(&pattern_name);
    if !pattern_name.is_empty() && !exact {
        notes.push(format!("infill pattern '{}' not available; using {}", pattern_name, pattern.label().to_lowercase()));
    }
    let support_enable = get_s(&p, "enable_support").as_deref() == Some("1");
    let support_type = get_s(&p, "support_type").unwrap_or_default();
    if support_enable && support_type.starts_with("tree") {
        notes.push("tree supports aren't implemented; normal grid supports are used instead".into());
    }
    let brim_type = get_s(&p, "brim_type").unwrap_or_default();
    let brim_width = match brim_type.as_str() {
        "outer_only" | "outer_and_inner" => get_f(&p, "brim_width").unwrap_or(5.0),
        "auto_brim" => get_f(&p, "brim_width").unwrap_or(5.0).min(5.0),
        _ => 0.0,
    };

    let accel_default = accel(&p, "default_acceleration", 8000.0);
    let sp = |key: &str, fallback: f64| get_f(&p, key).filter(|v| *v > 0.0).unwrap_or(fallback);
    let max_vol = get_f_idx(&f, "filament_max_volumetric_speed", 0).filter(|v| *v > 0.0).unwrap_or(15.0);
    let mw = get_f(&p, "support_line_width").filter(|w| *w > 0.0).unwrap_or(default_w);

    Ok(Imported {
        machine_name: machine.into(),
        filament_name: filament.into(),
        process_name: process.into(),
        bed_x: bx,
        bed_y: by,
        max_z: get_f(&m, "printable_height").unwrap_or(325.0),
        nozzle: get_f(&m, "nozzle_diameter").unwrap_or(0.4),
        filament_dia: get_f(&f, "filament_diameter").unwrap_or(1.75),
        filament_type: get_s(&f, "filament_type").unwrap_or_else(|| "PLA".into()),
        filament_density: get_f(&f, "filament_density").unwrap_or(1.24),
        filament_cost: get_f(&f, "filament_cost").unwrap_or(20.0),
        flow_ratio: get_f(&f, "filament_flow_ratio").unwrap_or(1.0),
        bridge_flow: get_f(&p, "bridge_flow").filter(|v| *v > 0.0).unwrap_or(1.0),
        nozzle_temp: nozzle_t,
        nozzle_temp_first: nozzle_t1,
        bed_temp: bed_t,
        bed_temp_first: bed_t1,
        chamber_temp: chamber,
        retract: get_f(&m, "retraction_length").unwrap_or(0.8),
        retract_speed: get_f(&m, "retraction_speed").filter(|v| *v > 0.0).unwrap_or(30.0),
        deretract_speed: get_f(&m, "deretraction_speed").filter(|v| *v > 0.0).or(get_f(&m, "retraction_speed")).unwrap_or(30.0),
        retract_min_travel: get_f(&m, "retraction_minimum_travel").unwrap_or(1.0),
        z_hop: get_f(&m, "z_hop").unwrap_or(0.4),
        wipe: get_s(&m, "wipe").as_deref() == Some("1"),
        wipe_distance: get_f(&m, "wipe_distance").unwrap_or(2.0),
        layer_height: get_f(&p, "layer_height").unwrap_or(0.2),
        first_layer_height: get_f(&p, "initial_layer_print_height").unwrap_or(0.2),
        walls: get_f(&p, "wall_loops").unwrap_or(2.0) as u32,
        density: get_f(&p, "sparse_infill_density").map(|d| d / 100.0).unwrap_or(0.15),
        top_layers: top,
        bottom_layers: bottom,
        w_outer: width("outer_wall_line_width", default_w),
        w_inner: width("inner_wall_line_width", default_w),
        w_sparse: width("sparse_infill_line_width", default_w),
        w_solid: width("internal_solid_infill_line_width", default_w),
        w_first: width("initial_layer_line_width", default_w),
        w_support: mw,
        pattern,
        speed_outer: sp("outer_wall_speed", 60.0),
        speed_inner: sp("inner_wall_speed", 120.0),
        speed_overhang: sp("overhang_2_4_speed", 50.0),
        speed_bridge: sp("bridge_speed", 50.0),
        speed_sparse: sp("sparse_infill_speed", 150.0),
        speed_solid: sp("internal_solid_infill_speed", 100.0),
        speed_top: sp("top_surface_speed", 100.0),
        speed_support: sp("support_speed", 100.0),
        speed_support_interface: sp("support_interface_speed", 60.0),
        speed_first: sp("initial_layer_speed", 40.0),
        speed_first_infill: sp("initial_layer_infill_speed", 60.0),
        speed_travel: sp("travel_speed", 300.0),
        accel_default,
        accel_outer: accel(&p, "outer_wall_acceleration", accel_default),
        accel_inner: accel(&p, "inner_wall_acceleration", accel_default),
        accel_top: accel(&p, "top_surface_acceleration", accel_default),
        accel_sparse: accel(&p, "sparse_infill_acceleration", accel_default),
        accel_bridge: accel(&p, "bridge_acceleration", accel_default),
        accel_first: accel(&p, "initial_layer_acceleration", 500.0),
        accel_travel: accel(&p, "travel_acceleration", 10000.0),
        max_volumetric: max_vol,
        fan_min: get_f_idx(&f, "fan_min_speed", 0).unwrap_or(60.0),
        fan_max: get_f_idx(&f, "fan_max_speed", 0).unwrap_or(100.0),
        fan_aux: get_f_idx(&f, "additional_cooling_fan_speed", 0).unwrap_or(0.0),
        fan_overhang: get_f_idx(&f, "overhang_fan_speed", 0).unwrap_or(100.0),
        fan_close_first: get_f_idx(&f, "close_fan_the_first_x_layers", 0).unwrap_or(1.0) as u32,
        fan_full_layer: get_f_idx(&f, "full_fan_speed_layer", 0).unwrap_or(0.0) as u32,
        slow_layer_time: get_f_idx(&f, "slow_down_layer_time", 0).unwrap_or(4.0),
        slow_min_speed: get_f_idx(&f, "slow_down_min_speed", 0).unwrap_or(20.0),
        fan_cooling_layer_time: get_f_idx(&f, "fan_cooling_layer_time", 0).unwrap_or(100.0),
        slow_down: get_s(&f, "slow_down_for_layer_cooling").as_deref() != Some("0"),
        brim_width,
        brim_gap: get_f(&p, "brim_object_gap").unwrap_or(0.1),
        skirt_loops: get_f(&p, "skirt_loops").unwrap_or(0.0) as u32,
        skirt_distance: get_f(&p, "skirt_distance").unwrap_or(2.0),
        support_enable,
        support_angle: get_f(&p, "support_threshold_angle").filter(|a| *a > 0.0).unwrap_or(30.0),
        support_on_plate_only: get_s(&p, "support_on_build_plate_only").as_deref() == Some("1"),
        support_xy_gap: get_f(&p, "support_object_xy_distance").unwrap_or(0.35),
        support_z_gap: get_f(&p, "support_top_z_distance").unwrap_or(0.2),
        support_interface_layers: get_f(&p, "support_interface_top_layers").unwrap_or(2.0) as u32,
        support_spacing: get_f(&p, "support_base_pattern_spacing").filter(|v| *v > 0.0).unwrap_or(2.5),
        machine_start_gcode: get_s(&m, "machine_start_gcode"),
        machine_end_gcode: get_s(&m, "machine_end_gcode"),
        machine_change_gcode: get_s(&m, "change_filament_gcode"),
        all: crate::gcode_template::merge(&m, &p, &f),
        bed_type: bed.label().to_string(),
        notes,
    })
}

impl Imported {
    /// Engine config. `base` is the finest layer step; heights are rounded to multiples of it.
    pub fn to_config(&self, base: f64, wall_height: f64, infill_height: f64) -> Config {
        let mult = |h: f64| ((h / base).round() as u32).max(1);
        let wm = mult(wall_height);
        // infill must be a whole multiple of the wall height
        let im = (mult(infill_height) / wm).max(1) * wm;
        let layer = wall_height.max(base);
        Config {
            base,
            first_layer: self.first_layer_height,
            nozzle: self.nozzle,
            w_outer: self.w_outer,
            w_inner: self.w_inner,
            w_sparse: self.w_sparse,
            w_solid: self.w_solid,
            w_first: self.w_first,
            walls: self.walls.max(1),
            skin_thickness: (self.top_layers.max(self.bottom_layers) as f64 * layer).max(0.6),
            density: self.density.clamp(0.02, 1.0),
            default: Class { wm, im },
            pattern: self.pattern,
            support: SupportCfg {
                enable: self.support_enable,
                angle_deg: self.support_angle,
                on_plate_only: self.support_on_plate_only,
                xy_gap: self.support_xy_gap,
                z_gap: self.support_z_gap,
                interface_layers: self.support_interface_layers,
                spacing: self.support_spacing,
                width: self.w_support,
            },
            adhesion: AdhesionCfg { brim_width: self.brim_width, brim_gap: self.brim_gap, skirt_loops: self.skirt_loops, skirt_distance: self.skirt_distance },
            detect_overhangs: true,
            bridges: true,
            zone_walls: 1,
            filament: 0,
        }
    }

    pub fn to_printer(&self) -> Printer {
        let mut p = Printer::h2d();
        p.bed_x = self.bed_x;
        p.bed_y = self.bed_y;
        p.max_z = self.max_z;
        p.filament_dia = self.filament_dia;
        p.filament_density = self.filament_density;
        p.filament_cost = self.filament_cost;
        p.flow_ratio = self.flow_ratio;
        p.bridge_flow = self.bridge_flow;
        p.nozzle_temp = self.nozzle_temp.round() as u32;
        p.nozzle_temp_first = self.nozzle_temp_first.round() as u32;
        p.bed_temp = self.bed_temp.round() as u32;
        p.bed_temp_first = self.bed_temp_first.round() as u32;
        p.chamber_temp = self.chamber_temp.round() as u32;
        p.filament_type = self.filament_type.clone();
        p.retract = self.retract;
        p.retract_speed = self.retract_speed;
        p.deretract_speed = self.deretract_speed;
        p.retract_min_travel = self.retract_min_travel;
        p.z_hop = self.z_hop;
        p.wipe = self.wipe;
        p.wipe_distance = self.wipe_distance;
        p.max_volumetric = self.max_volumetric;
        p.speed = Speeds {
            outer: self.speed_outer,
            inner: self.speed_inner,
            overhang: self.speed_overhang,
            bridge: self.speed_bridge,
            solid: self.speed_solid,
            top: self.speed_top,
            sparse: self.speed_sparse,
            support: self.speed_support,
            support_interface: self.speed_support_interface,
            first: self.speed_first,
            first_infill: self.speed_first_infill,
            travel: self.speed_travel,
        };
        p.accel = Accels {
            default: self.accel_default,
            outer: self.accel_outer,
            inner: self.accel_inner,
            top: self.accel_top,
            sparse: self.accel_sparse,
            bridge: self.accel_bridge,
            first: self.accel_first,
            travel: self.accel_travel,
        };
        if let (Some(start), Some(end)) = (&self.machine_start_gcode, &self.machine_end_gcode) {
            p.tpl = Some(crate::gcode::TemplateSrc { all: self.all.clone(), start: start.clone(), end: end.clone(), bed_type: self.bed_type.clone(), change: self.machine_change_gcode.clone().unwrap_or_default() });
        }
        p.fan = Fan {
            min: self.fan_min,
            max: self.fan_max,
            aux: self.fan_aux,
            overhang: self.fan_overhang,
            close_first: self.fan_close_first,
            full_layer: self.fan_full_layer,
            slow_layer_time: self.slow_layer_time,
            min_print_speed: self.slow_min_speed,
            cooling_layer_time: self.fan_cooling_layer_time,
            slow_down: self.slow_down,
        };
        p
    }
}

/// Describe one filament preset as an AMS slot on the given hotend (0 = left, 1 = right).
pub fn slot(lib: &Library, filament: &str, hotend: u8) -> Result<crate::gcode_template::SlotInfo> {
    let f = lib.resolve(Kind::Filament, filament)?;
    let temp = get_f_idx(&f, "nozzle_temperature", 0).unwrap_or(220.0);
    let temp_first = get_f_idx(&f, "nozzle_temperature_initial_layer", 0).unwrap_or(temp);
    let max_vol = get_f_idx(&f, "filament_max_volumetric_speed", 0).filter(|v| *v > 0.0).unwrap_or(12.0);
    Ok(crate::gcode_template::SlotInfo {
        name: filament.to_string(),
        ftype: get_s(&f, "filament_type").unwrap_or_else(|| "PLA".into()),
        colour: get_s(&f, "default_filament_colour").filter(|c| c.starts_with('#')).unwrap_or_else(|| "#FFFFFF".into()),
        temp,
        temp_first,
        max_vol,
        cooling_before_tower: get_f_idx(&f, "filament_cooling_before_tower", 0).unwrap_or(10.0),
        flush_temp: get_f_idx(&f, "filament_flush_temp", 0).unwrap_or(0.0),
        flush_speed: get_f_idx(&f, "filament_flush_volumetric_speed", 0).unwrap_or(0.0),
        retract_when_cut: 10.0,
        hotend,
        filament_id: get_s(&f, "filament_id").unwrap_or_default(),
        density: get_f(&f, "filament_density").unwrap_or(1.24),
    })
}
