//! Look and feel: a dark, low-glare palette with one warm accent, cards with soft borders,
//! pill and segmented controls, and switch toggles.
use eframe::egui::{self, Color32, CornerRadius, FontFamily, FontId, Margin, RichText, Stroke, StrokeKind, Vec2};

pub const BG: Color32 = Color32::from_rgb(0x0B, 0x0E, 0x13);
pub const PANEL: Color32 = Color32::from_rgb(0x10, 0x14, 0x1B);
pub const CARD: Color32 = Color32::from_rgb(0x16, 0x1B, 0x23);
pub const RAISED: Color32 = Color32::from_rgb(0x1E, 0x25, 0x30);
pub const BORDER: Color32 = Color32::from_rgb(0x22, 0x2A, 0x35);
pub const BORDER_STRONG: Color32 = Color32::from_rgb(0x2E, 0x37, 0x46);
pub const TEXT: Color32 = Color32::from_rgb(0xE6, 0xEA, 0xF0);
pub const TEXT_SOFT: Color32 = Color32::from_rgb(0xB8, 0xC1, 0xCD);
pub const MUTED: Color32 = Color32::from_rgb(0x9A, 0xA4, 0xB2);
pub const ACCENT: Color32 = Color32::from_rgb(0xFF, 0x7A, 0x1A);
pub const ON_ACCENT: Color32 = Color32::from_rgb(0x1A, 0x0E, 0x05);
pub const ACCENT_SOFT: Color32 = Color32::from_rgb(0x2A, 0x1B, 0x10);
pub const ACCENT_TEXT: Color32 = Color32::from_rgb(0xFF, 0xD3, 0xB0);
pub const DANGER: Color32 = Color32::from_rgb(0xFF, 0x8A, 0x80);
pub const WARN: Color32 = Color32::from_rgb(0xE9, 0xC4, 0x6A);
/// translucent fill for floating viewport panels
pub const GLASS: Color32 = Color32::from_rgba_premultiplied(0x0E, 0x12, 0x18, 0xE6);

pub fn mono(size: f32) -> FontId {
    FontId::new(size, FontFamily::Monospace)
}
pub fn semibold(size: f32) -> FontId {
    FontId::new(size, FontFamily::Name("semibold".into()))
}

/// Windows ships Segoe UI and Cascadia Mono; use them when present, egui's built-in fonts otherwise.
fn load_fonts(ctx: &egui::Context) {
    let mut fonts = egui::FontDefinitions::default();
    let dir = std::path::Path::new("C:\\Windows\\Fonts");
    let read = |names: &[&str]| names.iter().find_map(|n| std::fs::read(dir.join(n)).ok());
    let mut add = |key: &str, bytes: Option<Vec<u8>>| -> bool {
        match bytes {
            Some(b) => {
                fonts.font_data.insert(key.to_string(), std::sync::Arc::new(egui::FontData::from_owned(b)));
                true
            }
            None => false,
        }
    };
    let has_ui = add("ui", read(&["segoeui.ttf"]));
    let has_semi = add("ui_semibold", read(&["seguisb.ttf", "segoeuib.ttf"]));
    let has_mono = add("mono", read(&["CascadiaMono.ttf", "consola.ttf"]));
    let prop = fonts.families.entry(FontFamily::Proportional).or_default();
    if has_ui {
        prop.insert(0, "ui".into());
    }
    let prop_list = prop.clone();
    let mono_fam = fonts.families.entry(FontFamily::Monospace).or_default();
    if has_mono {
        mono_fam.insert(0, "mono".into());
    }
    let mut semi = prop_list;
    if has_semi {
        semi.insert(0, "ui_semibold".into());
    }
    fonts.families.insert(FontFamily::Name("semibold".into()), semi);
    ctx.set_fonts(fonts);
}

pub fn apply(ctx: &egui::Context) {
    load_fonts(ctx);
    let mut v = egui::Visuals::dark();
    v.panel_fill = PANEL;
    v.window_fill = PANEL;
    v.window_stroke = Stroke::new(1.0, BORDER_STRONG);
    v.window_corner_radius = CornerRadius::same(12);
    v.menu_corner_radius = CornerRadius::same(10);
    v.extreme_bg_color = BG;
    v.faint_bg_color = CARD;
    v.code_bg_color = CARD;
    v.hyperlink_color = ACCENT;
    v.warn_fg_color = WARN;
    v.error_fg_color = DANGER;
    // also the slider trailing fill
    v.selection.bg_fill = Color32::from_rgb(0xD9, 0x62, 0x10);
    v.selection.stroke = Stroke::new(1.0, Color32::WHITE);
    v.slider_trailing_fill = true;
    let r = CornerRadius::same(8);
    let w = &mut v.widgets;
    w.noninteractive.bg_fill = PANEL;
    w.noninteractive.weak_bg_fill = PANEL;
    w.noninteractive.bg_stroke = Stroke::new(1.0, BORDER);
    w.noninteractive.fg_stroke = Stroke::new(1.0, TEXT);
    w.noninteractive.corner_radius = r;
    w.inactive.bg_fill = CARD;
    w.inactive.weak_bg_fill = CARD;
    w.inactive.bg_stroke = Stroke::new(1.0, BORDER_STRONG);
    w.inactive.fg_stroke = Stroke::new(1.0, TEXT_SOFT);
    w.inactive.corner_radius = r;
    w.hovered.bg_fill = RAISED;
    w.hovered.weak_bg_fill = RAISED;
    w.hovered.bg_stroke = Stroke::new(1.0, Color32::from_rgb(0x46, 0x52, 0x66));
    w.hovered.fg_stroke = Stroke::new(1.5, TEXT);
    w.hovered.corner_radius = r;
    w.hovered.expansion = 0.0;
    w.active.bg_fill = RAISED;
    w.active.weak_bg_fill = RAISED;
    w.active.bg_stroke = Stroke::new(1.0, ACCENT);
    w.active.fg_stroke = Stroke::new(1.5, Color32::WHITE);
    w.active.corner_radius = r;
    w.active.expansion = 0.0;
    w.open.bg_fill = RAISED;
    w.open.weak_bg_fill = RAISED;
    w.open.bg_stroke = Stroke::new(1.0, ACCENT);
    w.open.fg_stroke = Stroke::new(1.0, TEXT);
    w.open.corner_radius = r;
    ctx.set_visuals(v);
    ctx.global_style_mut(|s| {
        s.spacing.item_spacing = Vec2::new(8.0, 8.0);
        s.spacing.button_padding = Vec2::new(12.0, 6.0);
        s.spacing.interact_size = Vec2::new(40.0, 30.0);
        s.spacing.slider_rail_height = 6.0;
        s.spacing.menu_margin = Margin::same(8);
        use egui::TextStyle::*;
        s.text_styles.insert(Body, FontId::proportional(14.0));
        s.text_styles.insert(Button, FontId::proportional(14.0));
        s.text_styles.insert(Small, FontId::proportional(12.0));
        s.text_styles.insert(Heading, semibold(17.0));
        s.text_styles.insert(Monospace, mono(13.0));
    });
}

/// Small uppercase heading over a group of settings.
pub fn caption(text: &str) -> RichText {
    RichText::new(text.to_uppercase()).font(semibold(11.0)).color(MUTED).extra_letter_spacing(1.2)
}

/// A collapsible settings section with an uppercase caption and a divider above it.
pub fn section(ui: &mut egui::Ui, id: &str, title: &str, default_open: bool, add: impl FnOnce(&mut egui::Ui)) {
    let id = ui.make_persistent_id(id);
    let mut state = egui::collapsing_header::CollapsingState::load_with_default_open(ui.ctx(), id, default_open);
    let (rect, resp) = ui.allocate_exact_size(Vec2::new(ui.available_width(), 26.0), egui::Sense::click());
    if resp.clicked() {
        state.toggle(ui);
    }
    let p = ui.painter();
    let galley = p.layout_no_wrap(caption(title).text().to_string(), semibold(11.0), if resp.hovered() { TEXT } else { MUTED });
    p.galley(egui::pos2(rect.left(), rect.center().y - galley.size().y / 2.0), galley, MUTED);
    // chevron
    let c = egui::pos2(rect.right() - 8.0, rect.center().y);
    let s = 4.0;
    let pts = if state.is_open() { [c + Vec2::new(-s, -s / 2.0), c + Vec2::new(0.0, s / 2.0), c + Vec2::new(s, -s / 2.0)] } else { [c + Vec2::new(-s / 2.0, -s), c + Vec2::new(s / 2.0, 0.0), c + Vec2::new(-s / 2.0, s)] };
    p.line_segment([pts[0], pts[1]], Stroke::new(1.5, MUTED));
    p.line_segment([pts[1], pts[2]], Stroke::new(1.5, MUTED));
    state.show_body_unindented(ui, |ui| {
        add(ui);
        ui.add_space(4.0);
    });
    state.store(ui.ctx());
    ui.add_space(2.0);
    let y = ui.cursor().top();
    ui.painter().hline(ui.max_rect().x_range(), y, Stroke::new(1.0, Color32::from_rgb(0x1E, 0x25, 0x30)));
    ui.add_space(8.0);
}

/// Bordered surface for a group of controls.
pub fn card<R>(ui: &mut egui::Ui, add: impl FnOnce(&mut egui::Ui) -> R) -> R {
    egui::Frame::new()
        .fill(CARD)
        .stroke(Stroke::new(1.0, BORDER))
        .corner_radius(10)
        .inner_margin(Margin::symmetric(12, 10))
        .show(ui, |ui| {
            ui.set_width(ui.available_width());
            add(ui)
        })
        .inner
}

/// Floating panel over the 3D view.
pub fn glass() -> egui::Frame {
    egui::Frame::new().fill(GLASS).stroke(Stroke::new(1.0, BORDER)).corner_radius(12).inner_margin(Margin::symmetric(12, 10))
}

/// Filled accent button (the main action).
pub fn primary(ui: &mut egui::Ui, enabled: bool, text: &str) -> egui::Response {
    let b = egui::Button::new(RichText::new(text).font(semibold(14.0)).color(if enabled { ON_ACCENT } else { MUTED }))
        .fill(if enabled { ACCENT } else { RAISED })
        .stroke(Stroke::NONE)
        .corner_radius(10)
        .min_size(Vec2::new(0.0, 40.0));
    ui.add_enabled(enabled, b)
}

/// Outlined button.
pub fn secondary(ui: &mut egui::Ui, enabled: bool, text: &str) -> egui::Response {
    let b = egui::Button::new(RichText::new(text).font(semibold(14.0)).color(if enabled { TEXT } else { MUTED }))
        .fill(CARD)
        .stroke(Stroke::new(1.0, BORDER_STRONG))
        .corner_radius(10)
        .min_size(Vec2::new(0.0, 40.0));
    ui.add_enabled(enabled, b)
}

/// Outlined accent button (e.g. re-slice).
pub fn accent_outline(ui: &mut egui::Ui, enabled: bool, text: &str, width: f32) -> egui::Response {
    let b = egui::Button::new((egui::Atom::grow(), RichText::new(text).font(semibold(14.0)).color(if enabled { ACCENT_TEXT } else { MUTED }), egui::Atom::grow()))
        .fill(Color32::TRANSPARENT)
        .stroke(Stroke::new(1.0, if enabled { ACCENT } else { BORDER_STRONG }))
        .corner_radius(10)
        .min_size(Vec2::new(width, 44.0));
    ui.add_enabled(enabled, b)
}

/// Quiet text button for the top bar.
pub fn ghost(ui: &mut egui::Ui, enabled: bool, text: &str) -> egui::Response {
    let b = egui::Button::new(RichText::new(text).color(if enabled { TEXT_SOFT } else { MUTED })).fill(Color32::TRANSPARENT).stroke(Stroke::NONE).corner_radius(8).min_size(Vec2::new(0.0, 34.0));
    ui.add_enabled(enabled, b)
}

/// Exclusive choice drawn as a segmented track. Returns true when the value changed.
pub fn segmented<T: PartialEq + Clone>(ui: &mut egui::Ui, value: &mut T, options: &[(T, String)], fill_width: bool, mono_text: bool) -> bool {
    let mut changed = false;
    egui::Frame::new().fill(BG).stroke(Stroke::new(1.0, BORDER)).corner_radius(10).inner_margin(Margin::same(4)).show(ui, |ui| {
        ui.spacing_mut().item_spacing.x = 4.0;
        let n = options.len().max(1) as f32;
        let w = if fill_width { ((ui.available_width() - 4.0 * (n - 1.0)) / n).max(30.0) } else { 0.0 };
        ui.horizontal(|ui| {
            for (v, label) in options {
                let on = *value == *v;
                let font = if mono_text { mono(13.0) } else if on { semibold(14.0) } else { FontId::proportional(14.0) };
                let color = if on && fill_width { ON_ACCENT } else if on { Color32::WHITE } else { MUTED };
                let fill = if on && fill_width { ACCENT } else if on { RAISED } else { Color32::TRANSPARENT };
                let b = egui::Button::new((egui::Atom::grow(), RichText::new(label).font(font).color(color), egui::Atom::grow())).fill(fill).stroke(Stroke::NONE).corner_radius(7).min_size(Vec2::new(w, 30.0));
                if ui.add(b).clicked() && !on {
                    *value = v.clone();
                    changed = true;
                }
            }
        });
    });
    changed
}

/// Pill-shaped choice chip.
pub fn chip(ui: &mut egui::Ui, on: bool, text: &str) -> egui::Response {
    let b = egui::Button::new(RichText::new(text).color(if on { ACCENT_TEXT } else { TEXT_SOFT }).font(if on { semibold(13.0) } else { FontId::proportional(13.0) }))
        .fill(if on { ACCENT_SOFT } else { CARD })
        .stroke(Stroke::new(1.0, if on { ACCENT } else { BORDER_STRONG }))
        .corner_radius(16)
        .min_size(Vec2::new(0.0, 32.0));
    ui.add(b)
}

/// iOS-style switch.
pub fn toggle(ui: &mut egui::Ui, on: &mut bool) -> egui::Response {
    let size = Vec2::new(44.0, 24.0);
    let (rect, mut resp) = ui.allocate_exact_size(size, egui::Sense::click());
    if resp.clicked() {
        *on = !*on;
        resp.mark_changed();
    }
    let t = ui.ctx().animate_bool_responsive(resp.id, *on);
    let bg = lerp_color(Color32::from_rgb(0x2A, 0x33, 0x41), ACCENT, t);
    let p = ui.painter();
    p.rect_filled(rect, 12.0, bg);
    let knob_x = egui::lerp(rect.left() + 12.0..=rect.right() - 12.0, t);
    p.circle_filled(egui::pos2(knob_x, rect.center().y), 9.0, lerp_color(Color32::from_rgb(0x8B, 0x95, 0xA3), Color32::WHITE, t));
    resp
}

/// A labelled row with a switch on the right and an optional hint under the label.
pub fn toggle_row(ui: &mut egui::Ui, label: &str, hint: &str, on: &mut bool) -> bool {
    let mut changed = false;
    ui.horizontal(|ui| {
        ui.vertical(|ui| {
            ui.spacing_mut().item_spacing.y = 1.0;
            ui.label(RichText::new(label).color(TEXT));
            if !hint.is_empty() {
                ui.label(RichText::new(hint).small().color(MUTED));
            }
        });
        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
            changed = toggle(ui, on).changed();
        });
    });
    changed
}

/// Label on the left, monospace value on the right.
pub fn value_row(ui: &mut egui::Ui, label: &str, value: &str) {
    ui.horizontal(|ui| {
        ui.label(RichText::new(label).color(TEXT));
        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
            ui.label(RichText::new(value).font(mono(13.0)).color(MUTED));
        });
    });
}

pub fn lerp_color(a: Color32, b: Color32, t: f32) -> Color32 {
    let l = |x: u8, y: u8| (x as f32 + (y as f32 - x as f32) * t).round() as u8;
    Color32::from_rgb(l(a.r(), b.r()), l(a.g(), b.g()), l(a.b(), b.b()))
}

/// Radial background glow behind the 3D view.
pub fn paint_backdrop(painter: &egui::Painter, rect: egui::Rect) {
    painter.rect_filled(rect, 0.0, BG);
    let mut mesh = egui::Mesh::default();
    let c = egui::pos2(rect.center().x, rect.top() + rect.height() * 0.45);
    let (rx, ry) = (rect.width() * 0.62, rect.height() * 0.75);
    mesh.colored_vertex(c, Color32::from_rgb(0x1A, 0x21, 0x2C));
    let n = 64;
    for i in 0..=n {
        let a = std::f32::consts::TAU * i as f32 / n as f32;
        mesh.colored_vertex(c + Vec2::new(a.cos() * rx, a.sin() * ry), BG);
    }
    for i in 1..=n as u32 {
        mesh.add_triangle(0, i, i + 1);
    }
    painter.add(egui::Shape::mesh(mesh));
}

/// Square icon button for the floating toolbars; `draw` paints the glyph inside `rect`.
pub fn icon_button(ui: &mut egui::Ui, tip: &str, selected: bool, draw: impl FnOnce(&egui::Painter, egui::Rect, Color32)) -> egui::Response {
    let (rect, resp) = ui.allocate_exact_size(Vec2::splat(40.0), egui::Sense::click());
    let p = ui.painter();
    let fill = if resp.hovered() { RAISED } else { GLASS };
    p.rect_filled(rect, 10.0, fill);
    p.rect_stroke(rect, 10.0, Stroke::new(1.0, if selected { ACCENT } else { BORDER_STRONG }), StrokeKind::Inside);
    let col = if resp.hovered() || selected { TEXT } else { MUTED };
    draw(p, rect.shrink(11.0), col);
    resp.on_hover_text(tip)
}

/// Brand mark: four stacked lines that narrow toward the top, like printed layers.
pub fn logo(painter: &egui::Painter, rect: egui::Rect) {
    let st = Stroke::new(2.2, ACCENT);
    let w = rect.width();
    for (i, f) in [1.0f32, 0.78, 0.56, 0.34].iter().enumerate() {
        let y = rect.bottom() - 3.0 - i as f32 * (rect.height() - 6.0) / 3.0;
        let half = w * f / 2.0;
        painter.line_segment([egui::pos2(rect.center().x - half, y), egui::pos2(rect.center().x + half, y)], st);
    }
}
