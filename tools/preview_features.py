"""Render G-code layers coloured by FEATURE type (or by filament with --by-filament).
usage: preview_features.py in.gcode out.png [--by-filament] z1 z2 ...   (z = layer top Z; nearest layer is used)"""
import re, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

args = sys.argv[1:]
by_fil = "--by-filament" in args
args = [a for a in args if a != "--by-filament"]
src, out, *zs = args
zs = [float(z) for z in zs]
COL = {
    "Outer wall": "#1f77b4", "Inner wall": "#7fb3e0", "Overhang wall": "#d62728", "Bridge": "#ff7f0e",
    "Internal solid infill": "#9467bd", "Top surface": "#2ca02c", "Sparse infill": "#bbbbbb",
    "Support": "#8c564b", "Support interface": "#e377c2", "Brim": "#17becf", "Skirt": "#bcbd22",
    "Prime tower": "#444444",
}
FIL = ["#1f77b4", "#d62728", "#2ca02c", "#ff7f0e", "#9467bd", "#8c564b", "#e377c2", "#17becf"]
x = y = z = 0.0
feat = None
tool = 0
layers = {}
started = False
for line in open(src, errors="ignore"):
    if line.startswith("; MACHINE_START_GCODE_END"):
        started = True
    if line.startswith("; FEATURE:"):
        feat = line.split(":", 1)[1].strip()
        continue
    t = re.match(r"T(\d+)\b", line)
    if t and started and int(t.group(1)) < 64:
        tool = int(t.group(1))
        continue
    m = re.match(r"G[0-3] (.*)", line)
    if not m:
        continue
    a = {}
    for tok in m.group(1).split():
        if tok[0] in "XYZE":
            try:
                a[tok[0]] = float(tok[1:])
            except ValueError:
                pass
    if "Z" in a:
        z = a["Z"]
    if "X" in a or "Y" in a:
        nx, ny = a.get("X", x), a.get("Y", y)
        if a.get("E", 0) > 0 and feat and started:
            label = f"filament {tool + 1}" if by_fil else feat
            color = FIL[tool % len(FIL)] if by_fil else COL.get(feat, "k")
            layers.setdefault(round(z, 3), []).append(((x, y), (nx, ny), label, color))
        x, y = nx, ny
avail = sorted(layers)
fig, axs = plt.subplots(1, len(zs), figsize=(6 * len(zs), 6), squeeze=False)
for ax, want in zip(axs[0], zs):
    zz = min(avail, key=lambda v: abs(v - want))
    seen = set()
    for p, q, f, c in layers[zz]:
        ax.plot([p[0], q[0]], [p[1], q[1]], "-", color=c, lw=0.8, label=None if f in seen else f)
        seen.add(f)
    ax.set_aspect("equal")
    ax.set_title(f"z={zz}")
    ax.legend(fontsize=7, loc="upper right")
plt.tight_layout()
plt.savefig(out, dpi=90)
print("saved", out)
