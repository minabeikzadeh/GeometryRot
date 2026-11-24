#!/usr/bin/env python3
"""Regenerates the enemy path in scenes/level.tscn from a list of waypoints.

Edit WAYPOINTS below, run `python tools/make_path.py` from the project folder, then reload
the project in Godot. It rewrites the Path2D curve AND Grid.path_cells together, so they
can never get out of sync. It also prints checks and writes tools/path_preview.png if
Pillow is installed (pip install pillow).

Coordinates are pixels relative to the grid's top-left corner (the grid sits at 0,72 on
screen). The playfield is 1280 x 576. Tips:
  - Keep lane centers on multiples of 32 so the track is exactly 2 cells wide.
  - Leave at least 128 px between lane centers if you want a 2-cell build strip between lanes.
  - The last waypoint is the Core center, (640, 288).
  - The first waypoint should be off screen so zombies walk in.
"""
import math
import pathlib
import re

CELL = 32
COLS, ROWS = 40, 18
TRACK_HALF_WIDTH = 32      # path is ~2 cells wide
FILLET = 44                # corner rounding radius in px
SAMPLE = 12                # px between curve points
CORE = (640, 288)
CORE_CELLS = [(19, 8), (20, 8), (19, 9), (20, 9)]

WAYPOINTS = [
	(-40, 544),                      # entrance, off screen bottom-left
	(1184, 544),                     # bottom lane to the right
	(1184, 448),
	(1056, 448), (1008, 352), (848, 352), (800, 448),   # lane back left, with a bump up
	(96, 448),
	(96, 32),                        # long climb up the left side
	(1184, 32),                      # top lane to the right
	(1184, 128),
	(1056, 128), (1008, 224), (848, 224), (800, 128),   # lane back left, with a dip down
	(384, 128),
	(384, 288),                      # drop into the middle
	CORE,                            # straight into the Core
]


def fillet(points, r):
	out = [points[0]]
	for i in range(1, len(points) - 1):
		a, p, b = points[i - 1], points[i], points[i + 1]
		da = math.dist(a, p)
		db = math.dist(p, b)
		rr = min(r, da / 2.0, db / 2.0)
		p1 = (p[0] + (a[0] - p[0]) / da * rr, p[1] + (a[1] - p[1]) / da * rr)
		p2 = (p[0] + (b[0] - p[0]) / db * rr, p[1] + (b[1] - p[1]) / db * rr)
		steps = 8
		for s in range(steps + 1):
			t = s / steps
			x = (1 - t) ** 2 * p1[0] + 2 * (1 - t) * t * p[0] + t ** 2 * p2[0]
			y = (1 - t) ** 2 * p1[1] + 2 * (1 - t) * t * p[1] + t ** 2 * p2[1]
			out.append((x, y))
	out.append(points[-1])
	return out


def resample(points, step):
	out = [points[0]]
	carry = 0.0
	for a, b in zip(points, points[1:]):
		seg = math.dist(a, b)
		d = step - carry
		while d <= seg:
			t = d / seg
			out.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t))
			d += step
		carry = seg - (d - step)
	if out[-1] != points[-1]:
		out.append(points[-1])
	return out


def seg_dist(p, a, b):
	ax, ay = a
	bx, by = b
	dx, dy = bx - ax, by - ay
	l2 = dx * dx + dy * dy
	t = 0.0 if l2 == 0 else max(0.0, min(1.0, ((p[0] - ax) * dx + (p[1] - ay) * dy) / l2))
	return math.dist(p, (ax + t * dx, ay + t * dy))


def main():
	curve = resample(fillet(WAYPOINTS, FILLET), SAMPLE)
	length = sum(math.dist(a, b) for a, b in zip(curve, curve[1:]))

	cells = []
	for cx in range(COLS):
		for cy in range(ROWS):
			c = (cx * CELL + CELL / 2, cy * CELL + CELL / 2)
			if (cx, cy) in CORE_CELLS:
				continue
			if min(seg_dist(c, a, b) for a, b in zip(curve, curve[1:])) < TRACK_HALF_WIDTH:
				cells.append((cx, cy))

	# Check: how close do far-apart parts of the path get? (gap = distance - track width)
	acc = [0.0]
	for a, b in zip(curve, curve[1:]):
		acc.append(acc[-1] + math.dist(a, b))
	worst = 9999.0
	for i in range(0, len(curve), 2):
		for j in range(i + 1, len(curve), 2):
			if acc[j] - acc[i] > 300 and acc[j] < acc[-1] - 160:
				worst = min(worst, math.dist(curve[i], curve[j]))
	print(f"path length: {length:.0f} px | path cells: {len(cells)} | "
		f"build cells: {COLS * ROWS - len(cells) - len(CORE_CELLS)}")
	print(f"closest approach between separate lanes: {worst:.0f} px center to center "
		f"(build gap about {worst - 2 * TRACK_HALF_WIDTH:.0f} px)")
	print(f"seconds to cross: speed 50 -> {length / 50:.0f}s, 100 -> {length / 100:.0f}s, "
		f"150 -> {length / 150:.0f}s")

	pts = ", ".join(f"0, 0, 0, 0, {x:.1f}, {y:.1f}" for x, y in curve)
	cell_txt = ", ".join(f"Vector2i({x}, {y})" for x, y in cells)
	scene = pathlib.Path(__file__).resolve().parent.parent / "scenes" / "level.tscn"
	s = scene.read_text(encoding="utf-8")
	s = re.sub(r'"points": PackedVector2Array\([^)]*\)', f'"points": PackedVector2Array({pts})', s)
	s = re.sub(r"point_count = \d+", f"point_count = {len(curve)}", s)
	s = re.sub(r"path_cells = Array\[Vector2i\]\(\[[^\]]*\]\)",
		f"path_cells = Array[Vector2i]([{cell_txt}])", s)
	core_txt = ", ".join(f"Vector2i({x}, {y})" for x, y in CORE_CELLS)
	s = re.sub(r"core_cells = Array\[Vector2i\]\(\[[^\]]*\]\)",
		f"core_cells = Array[Vector2i]([{core_txt}])", s)
	scene.write_text(s, encoding="utf-8")
	print("updated scenes/level.tscn")

	try:
		from PIL import Image, ImageDraw
	except ImportError:
		print("(install pillow to also get a preview picture)")
		return
	im = Image.new("RGB", (COLS * CELL, ROWS * CELL), (10, 13, 23))
	d = ImageDraw.Draw(im)
	for x in range(COLS):
		for y in range(ROWS):
			d.rectangle([x * CELL, y * CELL, x * CELL + CELL, y * CELL + CELL], outline=(32, 38, 54))
	for x, y in cells:
		d.rectangle([x * CELL + 1, y * CELL + 1, x * CELL + CELL - 1, y * CELL + CELL - 1], fill=(95, 28, 42))
	d.line(curve, fill=(255, 120, 120), width=2)
	d.ellipse([CORE[0] - 32, CORE[1] - 32, CORE[0] + 32, CORE[1] + 32], outline=(125, 249, 255), width=3)
	d.text((CORE[0] - 14, CORE[1] - 5), "CORE", fill=(125, 249, 255))
	d.text((8, 40), "ENTRANCE >", fill=(255, 255, 255))
	out = pathlib.Path(__file__).resolve().parent / "path_preview.png"
	im.save(out)
	print(f"wrote {out.name}")


if __name__ == "__main__":
	main()
