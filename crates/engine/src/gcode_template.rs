//! Builds the variable table for Bambu machine G-code templates (start / end / layer
//! change) and renders them with `placeholder`.
use crate::bbl::Settings;
use crate::placeholder::{self, Val, Vars};
use serde_json::Value;

pub fn to_val(v: &Value) -> Option<Val> {
    match v {
        Value::String(s) => {
            let t = s.trim();
            // numeric-looking strings become numbers; everything else (incl. "0x0", "nil") stays text
            match t.parse::<f64>() {
                Ok(n) if !t.is_empty() && !t.contains(['x', 'X']) => Some(Val::Num(n)),
                _ => Some(Val::Str(s.clone())),
            }
        }
        Value::Number(n) => n.as_f64().map(Val::Num),
        Value::Bool(b) => Some(Val::from_bool(*b)),
        Value::Array(a) => Some(Val::List(a.iter().filter_map(to_val).collect())),
        _ => None,
    }
}

/// One filament slot (AMS tray) taking part in the print.
#[derive(Clone, Debug, Default)]
pub struct SlotInfo {
    pub name: String,
    pub ftype: String,
    pub colour: String,
    pub temp: f64,
    pub temp_first: f64,
    pub max_vol: f64,
    pub cooling_before_tower: f64,
    /// 0 = nozzle temperature + 20
    pub flush_temp: f64,
    /// 0 = the filament's maximum volumetric speed
    pub flush_speed: f64,
    pub retract_when_cut: f64,
    /// 0 = left hotend, 1 = right hotend
    pub hotend: u8,
    /// Bambu filament id (tray_info_idx), e.g. GFB98
    pub filament_id: String,
    pub density: f64,
}

/// Facts about the sliced print that the templates ask for.
#[derive(Clone, Debug, Default)]
pub struct Runtime {
    pub max_print_z: f64,
    /// bounding box of the first layer (min x, min y) and size (w, h), in bed coordinates
    pub first_layer_min: (f64, f64),
    pub first_layer_size: (f64, f64),
    pub bed_type: String,
    pub total_layers: usize,
    /// filament slots of a multi-filament print (empty = single filament)
    pub slots: Vec<SlotInfo>,
    /// slots in order of first use
    pub used_slots: Vec<usize>,
}

fn list_at(vars: &Vars, key: &str, i: usize) -> Option<Val> {
    match vars.get(key)? {
        Val::List(l) => l.get(i).or(l.first()).cloned(),
        v => Some(v.clone()),
    }
}
fn num_at(vars: &Vars, key: &str, i: usize) -> Option<f64> {
    match list_at(vars, key, i)? {
        Val::Num(n) => Some(n),
        Val::Str(s) => s.parse().ok(),
        _ => None,
    }
}
fn str_at(vars: &Vars, key: &str, i: usize) -> Option<String> {
    list_at(vars, key, i).map(|v| v.text())
}

/// `all` is a flat settings map (machine + filament + process, filament arrays indexed by
/// filament id). For a single-filament print every filament array has the chosen filament first.
pub fn build_vars(all: &Settings, rt: &Runtime) -> Vars {
    let mut vars = Vars::new();
    for (k, v) in all {
        if let Some(val) = to_val(v) {
            vars.insert(k.clone(), val);
        }
    }
    // project-level settings that individual presets don't carry
    vars.entry("filament_map".into()).or_insert(Val::List(vec![Val::Num(1.0)]));
    let num = |vars: &Vars, k: &str, d: f64| num_at(vars, k, 0).unwrap_or(d);

    // nozzle / filament selection (single filament on filament slot 0)
    let nozzle_id = num_at(&vars, "filament_nozzle_map", 0).unwrap_or(0.0);
    let diameters = vars.get("nozzle_diameter").cloned().unwrap_or(Val::List(vec![Val::Num(0.4)]));
    vars.insert("nozzle_diameter_at_nozzle_id".into(), diameters);
    vars.insert("initial_nozzle_id".into(), Val::Num(nozzle_id));
    // -1 = "let the printer pick the hotend" (what Bambu Studio emits for a single-filament print)
    vars.insert("initial_no_support_hotend".into(), Val::Num(-1.0));
    vars.insert("initial_no_support_filament_id".into(), Val::Num(0.0));
    vars.insert("first_filaments".into(), Val::List(vec![Val::Num(0.0), Val::Num(-1.0)]));
    vars.insert("first_non_support_filaments".into(), Val::List(vec![Val::Num(0.0), Val::Num(-1.0)]));

    let ftype = str_at(&vars, "filament_type", 0).unwrap_or_default();
    vars.insert("has_tpu_in_first_layer".into(), Val::from_bool(ftype == "TPU"));
    vars.insert("overall_chamber_temperature".into(), Val::Num(num(&vars, "chamber_temperatures", 0.0)));
    vars.insert("min_vitrification_temperature".into(), Val::Num(num(&vars, "temperature_vitrification", 0.0)));
    let vendor = str_at(&vars, "filament_vendor", 0).unwrap_or_default();
    vars.insert("is_all_bbl_filament".into(), Val::from_bool(vendor == "Bambu Lab"));
    vars.insert("cooling_filter_enabled".into(), Val::from_bool(num(&vars, "activate_air_filtration", 0.0) != 0.0));
    vars.insert("long_retraction_when_ec".into(), Val::Num(num(&vars, "long_retractions_when_ec", 0.0)));
    vars.insert("retraction_distance_when_ec".into(), Val::Num(num(&vars, "retraction_distances_when_ec", 0.0)));

    // flush defaults when the profile leaves them at 0: nozzle + 20 C, and the filament's max flow
    let nozzle_t = num(&vars, "nozzle_temperature_initial_layer", 260.0);
    let flush_t = num(&vars, "filament_flush_temp", 0.0);
    vars.insert("flush_temperatures".into(), Val::List(vec![Val::Num(if flush_t > 0.0 { flush_t } else { nozzle_t + 20.0 })]));
    let flush_v = num(&vars, "filament_flush_volumetric_speed", 0.0);
    let maxv = num(&vars, "filament_max_volumetric_speed", 12.0);
    vars.insert("flush_volumetric_speeds".into(), Val::List(vec![Val::Num(if flush_v > 0.0 { flush_v } else { maxv })]));

    // plate temperature for the chosen build plate
    let bed_key = match rt.bed_type.as_str() {
        "Cool Plate" => "cool_plate_temp_initial_layer",
        "Engineering Plate" => "eng_plate_temp_initial_layer",
        "High Temp Plate" => "hot_plate_temp_initial_layer",
        _ => "textured_plate_temp_initial_layer",
    };
    vars.insert("bed_temperature_initial_layer_single".into(), Val::Num(num(&vars, bed_key, 60.0)));
    vars.insert("curr_bed_type".into(), Val::Str(rt.bed_type.clone()));

    if !rt.slots.is_empty() {
        let list = |f: &dyn Fn(&SlotInfo) -> Val| Val::List(rt.slots.iter().map(f).collect());
        vars.insert("filament_type".into(), list(&|s| Val::Str(s.ftype.clone())));
        vars.insert("nozzle_temperature_initial_layer".into(), list(&|s| Val::Num(s.temp_first)));
        vars.insert("nozzle_temperature".into(), list(&|s| Val::Num(s.temp)));
        vars.insert("flush_temperatures".into(), list(&|s| Val::Num(if s.flush_temp > 0.0 { s.flush_temp } else { s.temp_first + 20.0 })));
        vars.insert("flush_volumetric_speeds".into(), list(&|s| Val::Num(if s.flush_speed > 0.0 { s.flush_speed } else { s.max_vol })));
        vars.insert("filament_map".into(), list(&|s| Val::Num(s.hotend as f64 + 1.0)));
        vars.insert("filament_max_volumetric_speed".into(), list(&|s| Val::Num(s.max_vol)));
        vars.insert("retraction_distances_when_cut".into(), list(&|s| Val::Num(s.retract_when_cut)));
        vars.insert("filament_cooling_before_tower".into(), list(&|s| Val::Num(s.cooling_before_tower)));
        vars.insert("filament_tower_interface_purge_volume".into(), list(&|_| Val::Num(0.0)));
        vars.insert("filament_tower_interface_print_temp".into(), list(&|_| Val::Num(-1.0)));
        let first = rt.used_slots.first().copied().unwrap_or(0).min(rt.slots.len() - 1);
        vars.insert("initial_no_support_filament_id".into(), Val::Num(first as f64));
        vars.insert("initial_nozzle_id".into(), Val::Num(rt.slots[first].hotend as f64));
        // first filament used on each extruder (-1 = none); extruder 0 is the right hotend, 1 the left
        let per_hotend: Vec<Val> = (0..2u8)
            .map(|h| Val::Num(rt.used_slots.iter().copied().find(|&i| rt.slots.get(i).map_or(false, |s| s.hotend == 1 - h)).map_or(-1.0, |i| i as f64)))
            .collect();
        vars.insert("first_filaments".into(), Val::List(per_hotend.clone()));
        vars.insert("first_non_support_filaments".into(), Val::List(per_hotend));
        vars.insert("has_tpu_in_first_layer".into(), Val::from_bool(rt.slots[first].ftype == "TPU"));
    }
    vars.insert("max_print_z".into(), Val::Num(rt.max_print_z));
    vars.insert("max_layer_z".into(), Val::Num(rt.max_print_z));
    vars.insert("total_layer_count".into(), Val::Num(rt.total_layers as f64));
    vars.insert("first_layer_print_min".into(), Val::List(vec![Val::Num(rt.first_layer_min.0), Val::Num(rt.first_layer_min.1)]));
    vars.insert("first_layer_print_size".into(), Val::List(vec![Val::Num(rt.first_layer_size.0), Val::Num(rt.first_layer_size.1)]));
    vars
}

pub fn render(template: &str, all: &Settings, rt: &Runtime) -> Result<String, String> {
    placeholder::render(template, &build_vars(all, rt))
}

/// Like `render`, with extra / overriding variables (filament-change values and the like).
pub fn render_with(template: &str, all: &Settings, rt: &Runtime, extra: &Settings) -> Result<String, String> {
    let mut vars = build_vars(all, rt);
    for (k, v) in extra {
        if let Some(val) = to_val(v) {
            vars.insert(k.clone(), val);
        }
    }
    placeholder::render(template, &vars)
}

/// Merge machine, process and filament settings into one flat map for `build_vars`.
/// Filament arrays are already per-variant; slot 0 is the chosen filament.
pub fn merge(machine: &Settings, process: &Settings, filament: &Settings) -> Settings {
    let mut all = Settings::new();
    for m in [machine, process, filament] {
        for (k, v) in m {
            all.insert(k.clone(), v.clone());
        }
    }
    all
}

/// Variables that only exist while changing filament.
/// `first_use`: the target hotend has not printed yet (it is hot and full, so no pre-cooling and nothing to un-retract).
/// `flush_mm`: filament the printer purges by itself (into its waste chute), in mm of filament; 0 when the
/// prime tower or the infill takes the purge.
pub fn change_extra(rt: &Runtime, from: usize, to: usize, count: u32, layer_z: f64, tower_right_x: f64, first_use: bool, flush_mm: f64, all: &Settings) -> Settings {
    use serde_json::json;
    let sl = |i: usize| rt.slots.get(i).cloned().unwrap_or_default();
    let (a, b) = (sl(from), sl(to));
    let speed = |s: &SlotInfo| if s.flush_speed > 0.0 { s.flush_speed } else { s.max_vol };
    let first_val = |k: &str, d: f64| -> serde_json::Value {
        match all.get(k) {
            Some(Value::Array(l)) => l.first().cloned().unwrap_or(json!(d)),
            Some(v) => v.clone(),
            None => json!(d),
        }
    };
    let mut m = Settings::new();
    let mut put = |k: &str, v: serde_json::Value| {
        m.insert(k.to_string(), v);
    };
    put("current_filament_id", json!(from));
    put("next_filament_id", json!(to));
    put("current_hotend", json!(-1));
    put("next_hotend", json!(-1));
    put("current_nozzle_id", json!(a.hotend));
    put("next_nozzle_id", json!(b.hotend));
    put("toolchange_count", json!(count));
    put("flush_length", json!((flush_mm * 10.0).round() / 10.0));
    put("old_filament_temp", json!(a.temp));
    put("new_filament_temp", json!(b.temp));
    put("layer_z", json!(layer_z));
    put("max_layer_z", json!(layer_z));
    let retract_tc = match all.get("retract_length_toolchange") {
        Some(Value::Array(l)) => l.first().and_then(|v| v.as_str()).and_then(|t| t.parse::<f64>().ok()).unwrap_or(2.0),
        _ => 2.0,
    };
    put("new_extruder_retracted_length", json!(if first_use { 0.0 } else { retract_tc }));
    // Studio stores these as whole numbers
    put("old_filament_e_feedrate", json!((speed(&a) / 2.4053 * 60.0).floor() as i64));
    put("new_filament_e_feedrate", json!((speed(&b) / 2.4053 * 60.0).floor() as i64));
    let cooling: Vec<f64> = rt.slots.iter().enumerate().map(|(i, s)| if i == to && first_use { 0.0 } else { s.cooling_before_tower }).collect();
    put("filament_cooling_before_tower", json!(cooling));
    // change-path waypoints Studio fills in for the H2D
    put("travel_point_1_x", json!(54));
    put("travel_point_1_y", json!(0));
    put("travel_point_2_x", json!(54));
    put("travel_point_2_y", json!(0));
    put("travel_point_3_x", json!(54));
    put("travel_point_3_y", json!(245));
    put("is_prime_tower_interface", json!(0));
    put("wipe_avoid_perimeter", json!(1));
    put("wipe_avoid_pos_x", json!(tower_right_x));
    put("long_retraction_when_cut", json!(0));
    put("retraction_distance_when_cut", json!(a.retract_when_cut));
    put("nozzle_volume_types", json!(["Standard", "Standard"]));
    // per-extruder vectors that the template reads as a single number
    put("initial_layer_acceleration", first_val("initial_layer_acceleration", 500.0));
    put("default_acceleration", first_val("default_acceleration", 8000.0));
    m
}
