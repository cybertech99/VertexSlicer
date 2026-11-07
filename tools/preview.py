"""Render G-code layers to PNG for checking. usage: preview.py in.gcode out.png z1 z2 ...
Colours extrusion by layer HEIGHT so mixed-height regions are obvious."""
import re, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

src, out, *zs = sys.argv[1:]
zs = [float(z) for z in zs]
cur = {"x": 0.0, "y": 0.0, "z": 0.0, "h": 0.0}
segs = {z: [] for z in zs}
for line in open(src):
    if line.startswith(";HEIGHT:"):
        cur["h"] = float(line.split(":")[1])
        continue
    m = re.match(r"G1 (.*)", line)
    if not m:
        continue
    a = dict((t[0], float(t[1:])) for t in m.group(1).split() if t[0] in "XYZE")
    if "Z" in a and "X" not in a:
        cur["z"] = a["Z"]
        continue
    if "X" in a:
        nx, ny = a["X"], a["Y"]
        if a.get("E", 0) > 0:
            for z in zs:
                if abs(cur["z"] - z) < 1e-3:
                    segs[z].append(((cur["x"], cur["y"]), (nx, ny), cur["h"]))
        cur["x"], cur["y"] = nx, ny
colors = {0.1: "tab:red", 0.2: "tab:green", 0.3: "tab:blue"}
fig, axs = plt.subplots(1, len(zs), figsize=(6 * len(zs), 6), squeeze=False)
for ax, z in zip(axs[0], zs):
    for (a, b, h) in segs[z]:
        ax.plot([a[0], b[0]], [a[1], b[1]], color=colors.get(round(h, 1), "k"), lw=0.6)
    ax.set_aspect("equal")
    ax.set_title(f"z={z}  segs={len(segs[z])}")
plt.savefig(out, dpi=110)
print("saved", out)
