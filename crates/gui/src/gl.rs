//! Minimal OpenGL scene renderer used inside an egui paint callback.
//! All geometry uses one vertex layout: position (3 floats) + attribute (3 floats),
//! where the attribute is a normal (lit mesh) or a colour (coloured lines).
use eframe::glow::{self, HasContext};
use glam::{Mat4, Vec3, Vec4};

#[derive(Clone)]
pub struct Camera {
    pub yaw: f32,
    pub pitch: f32,
    pub dist: f32,
    pub target: Vec3,
}

impl Camera {
    pub fn new() -> Self {
        Camera { yaw: -1.0, pitch: 0.65, dist: 520.0, target: Vec3::new(175.0, 160.0, 0.0) }
    }
    pub fn eye(&self) -> Vec3 {
        let (sy, cy) = self.yaw.sin_cos();
        let (sp, cp) = self.pitch.sin_cos();
        self.target + Vec3::new(cy * cp, sy * cp, sp) * self.dist
    }
    pub fn view_proj(&self, aspect: f32) -> Mat4 {
        perspective_gl(40f32.to_radians(), aspect.max(0.01), 2.0, 6000.0) * look_at(self.eye(), self.target, Vec3::Z)
    }
    /// World-space ray through a point in normalised device coords (x right, y up, -1..1).
    pub fn ray(&self, ndc: (f32, f32), aspect: f32) -> (Vec3, Vec3) {
        let inv = self.view_proj(aspect).inverse();
        let p0 = inv * Vec4::new(ndc.0, ndc.1, -1.0, 1.0);
        let p1 = inv * Vec4::new(ndc.0, ndc.1, 1.0, 1.0);
        let (a, b) = (p0.truncate() / p0.w, p1.truncate() / p1.w);
        (a, (b - a).normalize())
    }
    pub fn orbit(&mut self, dx: f32, dy: f32) {
        self.yaw -= dx * 0.008;
        self.pitch = (self.pitch + dy * 0.008).clamp(-1.5, 1.5);
    }
    pub fn pan(&mut self, dx: f32, dy: f32) {
        let (sy, cy) = self.yaw.sin_cos();
        let right = Vec3::new(-sy, cy, 0.0);
        let fwd = Vec3::new(-cy, -sy, 0.0);
        let k = self.dist * 0.0012;
        // screen-down drag moves the scene down: keep it simple on the ground plane
        self.target += right * (-dx * k) + fwd * (dy * k) * self.pitch.sin().abs().max(0.3);
    }
    pub fn zoom(&mut self, scroll: f32) {
        self.dist = (self.dist * (1.0 - scroll * 0.0015)).clamp(20.0, 3000.0);
    }
}

/// Right-handed perspective projection with OpenGL clip space (z in -1..1).
fn perspective_gl(fov_y: f32, aspect: f32, near: f32, far: f32) -> Mat4 {
    let f = 1.0 / (fov_y * 0.5).tan();
    Mat4::from_cols_array(&[
        f / aspect, 0.0, 0.0, 0.0,
        0.0, f, 0.0, 0.0,
        0.0, 0.0, (far + near) / (near - far), -1.0,
        0.0, 0.0, 2.0 * far * near / (near - far), 0.0,
    ])
}

/// Right-handed view matrix.
fn look_at(eye: Vec3, target: Vec3, up: Vec3) -> Mat4 {
    let z = (eye - target).normalize();
    let x = up.cross(z).normalize();
    let y = z.cross(x);
    Mat4::from_cols_array(&[
        x.x, y.x, z.x, 0.0,
        x.y, y.y, z.y, 0.0,
        x.z, y.z, z.z, 0.0,
        -x.dot(eye), -y.dot(eye), -z.dot(eye), 1.0,
    ])
}

pub struct Geo {
    vao: glow::VertexArray,
    vbo: glow::Buffer,
    pub n: i32,
}

impl Geo {
    unsafe fn new(gl: &glow::Context) -> Geo {
        let vao = gl.create_vertex_array().unwrap();
        let vbo = gl.create_buffer().unwrap();
        gl.bind_vertex_array(Some(vao));
        gl.bind_buffer(glow::ARRAY_BUFFER, Some(vbo));
        gl.enable_vertex_attrib_array(0);
        gl.vertex_attrib_pointer_f32(0, 3, glow::FLOAT, false, 24, 0);
        gl.enable_vertex_attrib_array(1);
        gl.vertex_attrib_pointer_f32(1, 3, glow::FLOAT, false, 24, 12);
        Geo { vao, vbo, n: 0 }
    }
    unsafe fn upload(&mut self, gl: &glow::Context, data: &[f32]) {
        gl.bind_vertex_array(Some(self.vao));
        gl.bind_buffer(glow::ARRAY_BUFFER, Some(self.vbo));
        let bytes = std::slice::from_raw_parts(data.as_ptr() as *const u8, std::mem::size_of_val(data));
        gl.buffer_data_u8_slice(glow::ARRAY_BUFFER, bytes, glow::DYNAMIC_DRAW);
        self.n = (data.len() / 6) as i32;
    }
}

struct Prog {
    p: glow::Program,
    mvp: Option<glow::UniformLocation>,
    model: Option<glow::UniformLocation>,
    color: Option<glow::UniformLocation>,
}

const VS: &str = "#version 330 core
layout(location=0) in vec3 p;
layout(location=1) in vec3 a;
uniform mat4 mvp;
uniform mat4 model;
out vec3 v_a;
out vec3 v_n;
void main(){ gl_Position = mvp*vec4(p,1.0); v_a = a; v_n = mat3(model)*a; }";
const FS_LIT: &str = "#version 330 core
in vec3 v_a; in vec3 v_n; uniform vec4 color; out vec4 o;
void main(){ float l = 0.30 + 0.70*abs(dot(normalize(v_n), normalize(vec3(0.4,-0.5,0.8)))); o = vec4(color.rgb*l, color.a); }";
const FS_VCOL: &str = "#version 330 core
in vec3 v_a; in vec3 v_n; uniform vec4 color; out vec4 o;
void main(){ o = vec4(v_a, 1.0); }";
const FS_FLAT: &str = "#version 330 core
in vec3 v_a; in vec3 v_n; uniform vec4 color; out vec4 o;
void main(){ o = color; }";

unsafe fn compile(gl: &glow::Context, fs: &str) -> Prog {
    let p = gl.create_program().unwrap();
    let mut shaders = vec![];
    for (ty, src) in [(glow::VERTEX_SHADER, VS), (glow::FRAGMENT_SHADER, fs)] {
        let s = gl.create_shader(ty).unwrap();
        gl.shader_source(s, src);
        gl.compile_shader(s);
        if !gl.get_shader_compile_status(s) {
            panic!("shader compile error: {}", gl.get_shader_info_log(s));
        }
        gl.attach_shader(p, s);
        shaders.push(s);
    }
    gl.link_program(p);
    if !gl.get_program_link_status(p) {
        panic!("program link error: {}", gl.get_program_info_log(p));
    }
    for s in shaders {
        gl.detach_shader(p, s);
        gl.delete_shader(s);
    }
    Prog {
        mvp: gl.get_uniform_location(p, "mvp"),
        model: gl.get_uniform_location(p, "model"),
        color: gl.get_uniform_location(p, "color"),
        p,
    }
}

/// What to draw this frame.
#[derive(Clone)]
pub struct Frame {
    pub view_proj: Mat4,
    pub model: Mat4,
    pub model_color: [f32; 4],
    pub show_model: bool,
    pub show_toolpath: bool,
    /// number of toolpath vertices to draw (layer scrubber)
    pub toolpath_first: i32,
    pub toolpath_count: i32,
    pub highlight: Vec<f32>,
    pub zones_tri: Vec<f32>,
    pub zones_line: Vec<f32>,
    pub zone_color: [f32; 4],
    pub clear_depth: bool,
}

pub struct Scene {
    lit: Prog,
    vcol: Prog,
    flat: Prog,
    model: Geo,
    bed: Geo,
    bed_fill: Geo,
    zt: Geo,
    zl: Geo,
    ht: Geo,
    toolpath: Geo,
    pub pending_model: Option<Vec<f32>>,
    pub pending_bed: Option<Vec<f32>>,
    pub pending_bed_fill: Option<Vec<f32>>,
    pub pending_toolpath: Option<Vec<f32>>,
}

impl Scene {
    pub fn new(gl: &glow::Context) -> Scene {
        unsafe {
            Scene {
                lit: compile(gl, FS_LIT),
                vcol: compile(gl, FS_VCOL),
                flat: compile(gl, FS_FLAT),
                model: Geo::new(gl),
                bed: Geo::new(gl),
                bed_fill: Geo::new(gl),
                zt: Geo::new(gl),
                zl: Geo::new(gl),
                ht: Geo::new(gl),
                toolpath: Geo::new(gl),
                pending_model: None,
                pending_bed: None,
                pending_bed_fill: None,
                pending_toolpath: None,
            }
        }
    }

    pub fn paint(&mut self, gl: &glow::Context, vp: [i32; 4], clip: [i32; 4], f: &Frame) {
        unsafe {
            if let Some(d) = self.pending_model.take() {
                self.model.upload(gl, &d);
            }
            if let Some(d) = self.pending_bed.take() {
                self.bed.upload(gl, &d);
            }
            if let Some(d) = self.pending_bed_fill.take() {
                self.bed_fill.upload(gl, &d);
            }
            if let Some(d) = self.pending_toolpath.take() {
                self.toolpath.upload(gl, &d);
            }
            self.zt.upload(gl, &f.zones_tri);
            self.zl.upload(gl, &f.zones_line);
            self.ht.upload(gl, &f.highlight);

            gl.viewport(vp[0], vp[1], vp[2], vp[3]);
            gl.enable(glow::SCISSOR_TEST);
            gl.scissor(clip[0], clip[1], clip[2], clip[3]);
            gl.enable(glow::DEPTH_TEST);
            gl.depth_func(glow::LEQUAL);
            gl.depth_mask(true);
            gl.disable(glow::CULL_FACE);
            if f.clear_depth {
                gl.clear(glow::DEPTH_BUFFER_BIT);
            }
            let mvp = (f.view_proj * f.model).to_cols_array();
            let mvp_world = f.view_proj.to_cols_array();
            let model = f.model.to_cols_array();
            let ident = Mat4::IDENTITY.to_cols_array();

            let draw = |gl: &glow::Context, pr: &Prog, geo: &Geo, mode: u32, m: &[f32; 16], mm: &[f32; 16], color: [f32; 4]| {
                if geo.n == 0 {
                    return;
                }
                gl.use_program(Some(pr.p));
                gl.uniform_matrix_4_f32_slice(pr.mvp.as_ref(), false, m);
                gl.uniform_matrix_4_f32_slice(pr.model.as_ref(), false, mm);
                gl.uniform_4_f32(pr.color.as_ref(), color[0], color[1], color[2], color[3]);
                gl.bind_vertex_array(Some(geo.vao));
                gl.draw_arrays(mode, 0, geo.n);
            };

            // build plate surface, pushed back so the grid lines on it stay visible
            gl.enable(glow::POLYGON_OFFSET_FILL);
            gl.polygon_offset(2.0, 2.0);
            draw(gl, &self.flat, &self.bed_fill, glow::TRIANGLES, &mvp_world, &ident, [0x18 as f32 / 255.0, 0x20 as f32 / 255.0, 0x2A as f32 / 255.0, 1.0]);
            gl.disable(glow::POLYGON_OFFSET_FILL);
            // bed grid (world space)
            draw(gl, &self.vcol, &self.bed, glow::LINES, &mvp_world, &ident, [1.0; 4]);
            if f.show_model {
                draw(gl, &self.lit, &self.model, glow::TRIANGLES, &mvp, &model, f.model_color);
            }
            if f.show_toolpath && self.toolpath.n > 0 {
                let first = f.toolpath_first.clamp(0, self.toolpath.n);
                let n = f.toolpath_count.clamp(first, self.toolpath.n) - first;
                if n > 0 {
                    gl.use_program(Some(self.vcol.p));
                    gl.uniform_matrix_4_f32_slice(self.vcol.mvp.as_ref(), false, &mvp_world);
                    gl.uniform_matrix_4_f32_slice(self.vcol.model.as_ref(), false, &ident);
                    gl.bind_vertex_array(Some(self.toolpath.vao));
                    gl.draw_arrays(glow::LINES, first, n);
                }
            }
            // picked-face highlight, drawn over the model surface
            if self.ht.n > 0 {
                gl.enable(glow::BLEND);
                gl.blend_func_separate(glow::SRC_ALPHA, glow::ONE_MINUS_SRC_ALPHA, glow::ZERO, glow::ONE);
                gl.depth_mask(false);
                gl.enable(glow::POLYGON_OFFSET_FILL);
                gl.polygon_offset(-2.0, -2.0);
                draw(gl, &self.flat, &self.ht, glow::TRIANGLES, &mvp, &model, [0.15, 0.6, 1.0, 0.65]);
                gl.disable(glow::POLYGON_OFFSET_FILL);
                gl.depth_mask(true);
            }
            // translucent zone volumes: no depth writes
            gl.enable(glow::BLEND);
            gl.blend_func_separate(glow::SRC_ALPHA, glow::ONE_MINUS_SRC_ALPHA, glow::ZERO, glow::ONE);
            gl.depth_mask(false);
            draw(gl, &self.flat, &self.zt, glow::TRIANGLES, &mvp_world, &ident, f.zone_color);
            gl.depth_mask(true);
            gl.depth_func(glow::ALWAYS);
            draw(gl, &self.vcol, &self.zl, glow::LINES, &mvp_world, &ident, [1.0; 4]);
            gl.depth_func(glow::LEQUAL);

            // restore the state egui expects
            gl.disable(glow::DEPTH_TEST);
            gl.depth_mask(true);
            gl.enable(glow::BLEND);
            gl.blend_func_separate(glow::ONE, glow::ONE_MINUS_SRC_ALPHA, glow::ONE_MINUS_DST_ALPHA, glow::ONE);
            gl.bind_vertex_array(None);
            gl.use_program(None);
        }
    }
}

// ---------- geometry builders (return interleaved pos+attr floats) ----------

pub fn bed_lines(bx: f32, by: f32, max_z: f32) -> Vec<f32> {
    let mut v = vec![];
    let mut line = |a: [f32; 3], b: [f32; 3], c: [f32; 3]| {
        v.extend_from_slice(&[a[0], a[1], a[2], c[0], c[1], c[2]]);
        v.extend_from_slice(&[b[0], b[1], b[2], c[0], c[1], c[2]]);
    };
    let hex = |r: u8, g: u8, b: u8| [r as f32 / 255.0, g as f32 / 255.0, b as f32 / 255.0];
    let minor = hex(0x2C, 0x35, 0x42);
    let major = hex(0x3A, 0x45, 0x56);
    let mut x = 0.0;
    while x <= bx + 0.1 {
        line([x, 0.0, 0.0], [x, by, 0.0], if (x as i32) % 50 == 0 { major } else { minor });
        x += 10.0;
    }
    let mut y = 0.0;
    while y <= by + 0.1 {
        line([0.0, y, 0.0], [bx, y, 0.0], if (y as i32) % 50 == 0 { major } else { minor });
        y += 10.0;
    }
    let e = hex(0x47, 0x53, 0x66);
    line([0.0, 0.0, 0.0], [bx, 0.0, 0.0], e);
    line([bx, 0.0, 0.0], [bx, by, 0.0], e);
    line([bx, by, 0.0], [0.0, by, 0.0], e);
    line([0.0, by, 0.0], [0.0, 0.0, 0.0], e);
    // faint build-volume height posts
    let h = hex(0x1E, 0x25, 0x30);
    for (x, y) in [(0.0, 0.0), (bx, 0.0), (bx, by), (0.0, by)] {
        line([x, y, 0.0], [x, y, max_z.min(400.0)], h);
    }
    v
}

/// Solid build-plate rectangle (two triangles).
pub fn bed_fill(bx: f32, by: f32) -> Vec<f32> {
    let mut v = vec![];
    let (a, b, c, d) = (Vec3::new(0.0, 0.0, 0.0), Vec3::new(bx, 0.0, 0.0), Vec3::new(bx, by, 0.0), Vec3::new(0.0, by, 0.0));
    tri(&mut v, a, b, c);
    tri(&mut v, a, c, d);
    v
}

/// Triangle soup with flat normals.
pub fn mesh_tris(verts: &[[f64; 3]], tris: &[[u32; 3]]) -> Vec<f32> {
    let mut out = Vec::with_capacity(tris.len() * 18);
    for t in tris {
        let p: Vec<Vec3> = t.iter().map(|&i| Vec3::new(verts[i as usize][0] as f32, verts[i as usize][1] as f32, verts[i as usize][2] as f32)).collect();
        let n = (p[1] - p[0]).cross(p[2] - p[0]).normalize_or_zero();
        for q in &p {
            out.extend_from_slice(&[q.x, q.y, q.z, n.x, n.y, n.z]);
        }
    }
    out
}

fn tri(v: &mut Vec<f32>, a: Vec3, b: Vec3, c: Vec3) {
    for p in [a, b, c] {
        v.extend_from_slice(&[p.x, p.y, p.z, 0.0, 0.0, 0.0]);
    }
}
fn seg(v: &mut Vec<f32>, a: Vec3, b: Vec3, c: [f32; 3]) {
    for p in [a, b] {
        v.extend_from_slice(&[p.x, p.y, p.z, c[0], c[1], c[2]]);
    }
}

/// (triangles, lines) for a vertical cylinder.
pub fn cylinder(cx: f32, cy: f32, r: f32, z0: f32, z1: f32, col: [f32; 3], tris: &mut Vec<f32>, lines: &mut Vec<f32>) {
    let n = 48;
    let pt = |i: usize, z: f32| {
        let a = std::f32::consts::TAU * i as f32 / n as f32;
        Vec3::new(cx + r * a.cos(), cy + r * a.sin(), z)
    };
    for i in 0..n {
        let j = (i + 1) % n;
        let (a0, a1, b0, b1) = (pt(i, z0), pt(j, z0), pt(i, z1), pt(j, z1));
        tri(tris, a0, a1, b1);
        tri(tris, a0, b1, b0);
        tri(tris, Vec3::new(cx, cy, z1), b0, b1);
        seg(lines, b0, b1, col);
        seg(lines, a0, a1, col);
        if i % 6 == 0 {
            seg(lines, a0, b0, col);
        }
    }
}

/// (triangles, lines) for a vertical ring (annulus extruded in z).
pub fn ring(cx: f32, cy: f32, r0: f32, r1: f32, z0: f32, z1: f32, col: [f32; 3], tris: &mut Vec<f32>, lines: &mut Vec<f32>) {
    let n = 48;
    let pt = |i: usize, r: f32, z: f32| {
        let a = std::f32::consts::TAU * i as f32 / n as f32;
        Vec3::new(cx + r * a.cos(), cy + r * a.sin(), z)
    };
    for i in 0..n {
        let j = (i + 1) % n;
        for r in [r0, r1] {
            let (a0, a1, b0, b1) = (pt(i, r, z0), pt(j, r, z0), pt(i, r, z1), pt(j, r, z1));
            tri(tris, a0, a1, b1);
            tri(tris, a0, b1, b0);
            seg(lines, b0, b1, col);
            seg(lines, a0, a1, col);
            if i % 6 == 0 {
                seg(lines, a0, b0, col);
            }
        }
        // top cap: annulus quad
        let (i0, i1, o0, o1) = (pt(i, r0, z1), pt(j, r0, z1), pt(i, r1, z1), pt(j, r1, z1));
        tri(tris, i0, o0, o1);
        tri(tris, i0, o1, i1);
    }
}

pub fn cuboid(x0: f32, y0: f32, x1: f32, y1: f32, z0: f32, z1: f32, col: [f32; 3], tris: &mut Vec<f32>, lines: &mut Vec<f32>) {
    let c = |x, y, z| Vec3::new(x, y, z);
    let p = [
        c(x0, y0, z0), c(x1, y0, z0), c(x1, y1, z0), c(x0, y1, z0),
        c(x0, y0, z1), c(x1, y0, z1), c(x1, y1, z1), c(x0, y1, z1),
    ];
    for f in [[0, 1, 2, 3], [4, 5, 6, 7], [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7]] {
        tri(tris, p[f[0]], p[f[1]], p[f[2]]);
        tri(tris, p[f[0]], p[f[2]], p[f[3]]);
    }
    for (a, b) in [(0, 1), (1, 2), (2, 3), (3, 0), (4, 5), (5, 6), (6, 7), (7, 4), (0, 4), (1, 5), (2, 6), (3, 7)] {
        seg(lines, p[a], p[b], col);
    }
}
