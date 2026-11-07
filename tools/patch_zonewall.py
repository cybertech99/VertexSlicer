def sub(s, old, new, count=1):
    assert old in s, "missing anchor: " + old[:90]
    return s.replace(old, new, count)

# ---------------- plan.rs ----------------
p = "crates/engine/src/plan.rs"
s = open(p, encoding="utf-8").read()
s = sub(s, "    pub bridges: bool,\n}", "    pub bridges: bool,\n    /// wall loops printed along each zone's own boundary (inside the part), so regions with\n    /// different layer heights are separated by a perimeter instead of butting together\n    pub zone_walls: u32,\n}")
s = sub(s, "            bridges: true,\n        }\n    }", "            bridges: true,\n            zone_walls: 1,\n        }\n    }")

s = sub(s, """            // Wall-block cross-sections inside this infill block.
            let mids""", """            // Infill / skin are pulled in from the zone edge to leave room for its boundary walls.
            let fill_region = if ci > 0 && cfg.zone_walls > 0 {
                let t = cfg.zone_walls as f64 * cfg.w_inner;
                Region { include: Some(offset(&zones[ci - 1].polys(), -t + ov)), exclude: region.exclude.clone() }
            } else {
                region.clone()
            };

            // Wall-block cross-sections inside this infill block.
            let mids""")

s = sub(s, """                // skins
                let inner = offset(&offset(&c, -cfg.wall_total(false)), ov);""", """                // zone boundary walls: a perimeter along this zone's edge, only through solid interior
                if ci > 0 && cfg.zone_walls > 0 {
                    let zp = zones[ci - 1].polys();
                    let in_part = Region { include: Some(offset(&c, -cfg.wall_total(false))), exclude: vec![] };
                    for i in (0..cfg.zone_walls).rev() {
                        let mut paths = vec![];
                        for l in offset(&zp, -(cfg.w_inner * 0.5 + i as f64 * cfg.w_inner)) {
                            for (piece, closed) in clip_path(&l, true, &region) {
                                paths.extend(clip_path(&piece, closed, &in_part));
                            }
                        }
                        if !paths.is_empty() {
                            ops.push(Op { z_top, height: wh, kind: Kind::InnerWall, first: false, width: cfg.w_inner, paths });
                        }
                    }
                }

                // skins
                let inner = offset(&offset(&c, -cfg.wall_total(false)), ov);""")
n = s.count("clip_lines(lines.into_iter().map(|l| l.to_vec()), &region)")
assert n == 3, n
s = s.replace("clip_lines(lines.into_iter().map(|l| l.to_vec()), &region)", "clip_lines(lines.into_iter().map(|l| l.to_vec()), &fill_region)")
s = sub(s, "clip_lines(polylines, &region)", "clip_lines(polylines, &fill_region)")
open(p, "w", encoding="utf-8").write(s)

# ---------------- bbl_import.rs ----------------
p = "crates/engine/src/bbl_import.rs"
s = open(p, encoding="utf-8").read()
s = sub(s, "            detect_overhangs: true,\n            bridges: true,\n        }", "            detect_overhangs: true,\n            bridges: true,\n            zone_walls: 1,\n        }")
open(p, "w", encoding="utf-8").write(s)

# ---------------- gui job.rs ----------------
p = "crates/gui/src/job.rs"
s = open(p, encoding="utf-8").read()
s = sub(s, "    pub skirt: u32,\n    pub zones: Vec<ZoneSpec>,", "    pub skirt: u32,\n    pub zone_walls: u32,\n    pub zones: Vec<ZoneSpec>,")
s = sub(s, "    cfg.adhesion.skirt_loops = inp.skirt;\n", "    cfg.adhesion.skirt_loops = inp.skirt;\n    cfg.zone_walls = inp.zone_walls;\n")
open(p, "w", encoding="utf-8").write(s)

# ---------------- gui main.rs ----------------
p = "crates/gui/src/main.rs"
s = open(p, encoding="utf-8").read()
s = sub(s, "    brim: f64,\n    skirt: u32,\n\n    // model", "    brim: f64,\n    skirt: u32,\n    zone_walls: u32,\n\n    // model")
s = sub(s, "            brim: 0.0,\n            skirt: 0,\n            mesh: None,", "            brim: 0.0,\n            skirt: 0,\n            zone_walls: 1,\n            mesh: None,")
s = sub(s, "            skirt: self.skirt,\n            zones: self.zone_specs(),", "            skirt: self.skirt,\n            zone_walls: self.zone_walls,\n            zones: self.zone_specs(),")
# project file
s = sub(s, "    skirt: u32,\n    zones: Vec<ZoneUi>,\n}", "    skirt: u32,\n    #[serde(default = \"default_zone_walls\")]\n    zone_walls: u32,\n    zones: Vec<ZoneUi>,\n}\n\nfn default_zone_walls() -> u32 {\n    1\n}")
s = sub(s, "            skirt: self.skirt,\n            zones: self.zones.clone(),", "            skirt: self.skirt,\n            zone_walls: self.zone_walls,\n            zones: self.zones.clone(),")
s = sub(s, "        self.skirt = proj.skirt;\n", "        self.skirt = proj.skirt;\n        self.zone_walls = proj.zone_walls;\n")
# UI
s = sub(s, "        if let Some(i) = &self.imported {\n            ui.label(RichText::new(format!(\"Cooling:", "        ui.horizontal(|ui| {\n            ui.label(\"Zone boundary walls\").on_hover_text(\"Perimeter loops along each zone's edge, so regions with different layer heights are separated by a wall.\");\n            ui.add(egui::DragValue::new(&mut self.zone_walls).range(0..=4));\n        });\n        if let Some(i) = &self.imported {\n            ui.label(RichText::new(format!(\"Cooling:")
open(p, "w", encoding="utf-8").write(s)
print("ok")
