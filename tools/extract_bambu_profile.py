"""Extract evaluated machine start/end G-code from a Bambu Studio *.gcode.3mf and
turn temperatures into placeholders the slicer fills in.

usage: python -I extract_bambu_profile.py sample.gcode.3mf profiles_dir
Placeholders: {nozzle} {bed} {chamber} {ftype}
"""
import re, sys, zipfile, os, shutil

src, outdir = sys.argv[1:3]
z = zipfile.ZipFile(src)
g = z.read("Metadata/plate_1.gcode").decode("utf-8", "replace").splitlines()

def find(pred, start=0):
    for i in range(start, len(g)):
        if pred(g[i]):
            return i
    raise SystemExit("marker not found")

s0 = find(lambda l: l.startswith("; EXECUTABLE_BLOCK_START")) + 1
s1 = find(lambda l: l.startswith("; MACHINE_START_GCODE_END"), s0) + 1
e0 = find(lambda l: l.startswith("; MACHINE_END_GCODE_START"), s1)
e1 = find(lambda l: l.startswith("; EXECUTABLE_BLOCK_END"), e0) + 1
start, end = g[s0:s1], g[e0:e1]

# detect the temperatures this sample was sliced with
txt = "\n".join(start)
nozzle = re.search(r"M109 S(\d+)\s*;? ?wait tmpr", txt) or re.search(r"M104 S(\d+) ; rise to print", txt)
nozzle = nozzle.group(1)
bed = re.search(r"M190 S(\d+); ensure bed", txt).group(1)
chamber = (re.search(r"M141 S(\d+)", txt) or [None, "0"])[1] if re.search(r"M141 S([1-9]\d*)", txt) else "0"
chamber = re.search(r"M141 S([1-9]\d*)", txt).group(1) if re.search(r"M141 S([1-9]\d*)", txt) else "0"
ftype = re.search(r"set_filament_type:(?!UNKNOWN)(\w+)", txt).group(1)
print("sample temps: nozzle", nozzle, "bed", bed, "chamber", chamber, "filament", ftype)

def sub(line):
    line = re.sub(r"\b(M104|M109) S%s\b" % nozzle, r"\1 S{nozzle}", line)
    line = re.sub(r"\bG150 T%s\b" % nozzle, "G150 T{nozzle}", line)
    line = re.sub(r"(M620\.10 .* P)%s\b" % nozzle, r"\1{nozzle}", line)
    line = re.sub(r"(M620\.17 T\d S)%s\b" % nozzle, r"\1{nozzle}", line)
    line = re.sub(r"\b(M140|M190) S%s\b" % bed, r"\1 S{bed}", line)
    if chamber != "0":
        line = re.sub(r"\b(M141|M191) S%s\b" % chamber, r"\1 S{chamber}", line)
    line = line.replace("set_filament_type:%s" % ftype, "set_filament_type:{ftype}")
    return line

os.makedirs(outdir, exist_ok=True)
open(os.path.join(outdir, "h2d_start.gcode"), "w", newline="\n").write("\n".join(map(sub, start)) + "\n")
open(os.path.join(outdir, "h2d_header.gcode"), "w", newline="\n").write("\n".join(g[:s0]) + "\n")
open(os.path.join(outdir, "h2d_end.gcode"), "w", newline="\n").write("\n".join(end) + "\n")
shutil.copy(src, os.path.join(outdir, "h2d_template.3mf"))
print("start lines", len(start), "end lines", len(end))
