extends RefCounted

const Px := preload("old_web_px.gd")
const Kit := preload("old_web_kit.gd")
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const CRAYON_BANDS: Array[Color] = [Color8(255, 102, 187), Color8(153, 102, 238), Color8(51, 204, 170), Color8(255, 255, 255), Color8(102, 136, 255), Color8(221, 68, 204), Color8(119, 221, 170), Color8(187, 153, 255)]
const STRIPES: Array[Color] = [Color8(255, 0, 0), Color8(255, 153, 0), Color8(255, 255, 0), Color8(0, 204, 0), Color8(0, 102, 255), Color8(153, 0, 204)]


static func paint(id: String, p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	if id == "bg_crayon":
		return crayon(size)
	if id == "bg_stars":
		return stars(p, f, n, size)
	if id == "bg_nebula":
		return nebula(size)
	if id == "bg_marble":
		return marble(p, size)
	if id == "bg_parchment":
		return parchment(p, size)
	if id == "bg_purple":
		return purple(p, size)
	if id == "bg_stripes":
		return rainbow_stripes(f, n, size)
	if id == "bg_clouds":
		return clouds(p, size)
	return Px.new(size.x, size.y)


static func crayon(size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, WHITE)
	var band_h: float = float(size.y) / float(CRAYON_BANDS.size())
	for y: int in size.y:
		for x: int in size.x:
			var u: float = TAU * float(x) / float(size.x)
			var wob: float = 2.5 * sin(u * 2.0) + 1.5 * sin(u * 3.0 + 1.1) + 0.8 * sin(u * 5.0 + 0.3)
			var pos: float = fposmod(float(y) + wob, float(size.y))
			var band: int = int(pos / band_h) % CRAYON_BANDS.size()
			var inner: float = fposmod(pos, band_h) / band_h
			var c: Color = CRAYON_BANDS[band]
			if c == WHITE:
				if Px.hash01(x, y, 3) > 0.92:
					px.put_px(x, y, Color8(238, 238, 255))
				continue
			var edge: float = minf(inner, 1.0 - inner) * 2.0
			var streak: float = Px.hash01(posmod(x + y * 2, size.x), y / 2, 11) * 0.6 + Px.hash01(x, y, 12) * 0.4
			if streak < 0.35 + (1.0 - edge) * 0.45:
				if Px.hash01(x, y, 13) > 0.6:
					px.put_px(x, y, c.lerp(WHITE, 0.6))
				continue
			if Px.hash01(x, y, 14) > 0.85:
				c = c.darkened(0.2)
			elif Px.hash01(x, y, 15) > 0.8:
				c = c.lerp(WHITE, 0.3)
			px.put_px(x, y, c)
	return px


static func stars(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var bg: Color = Kit.colour(p, "colour_b", BLACK)
	var px: Px = Px.new(size.x, size.y, bg)
	var phase: float = float(f) / float(n)
	for i: int in 16:
		var sx: int = int(Px.hash01(i, 1, 21) * float(size.x))
		var sy: int = int(Px.hash01(i, 2, 21) * float(size.y))
		var tier: float = Px.hash01(i, 3, 21)
		var b: float = 0.5 + 0.5 * sin(TAU * (phase + Px.hash01(i, 4, 21)))
		if tier > 0.82:
			var arm: int = 2 if b > 0.5 else 1
			for k: int in range(1, arm + 1):
				for d: Vector2i in [Vector2i(k, 0), Vector2i(-k, 0), Vector2i(0, k), Vector2i(0, -k)]:
					px.put_px(posmod(sx + d.x, size.x), posmod(sy + d.y, size.y), Color8(102, 153, 255) if k > 1 else Color8(204, 221, 255))
			px.put_px(sx, sy, WHITE)
		elif tier > 0.45:
			px.put_px(sx, sy, WHITE if b > 0.4 else Color8(153, 153, 204))
		else:
			px.put_px(sx, sy, Color8(102, 102, 153) if b > 0.5 else Color8(51, 51, 102))
	return px


static func nebula(size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var pal: Array = [Color8(0, 0, 20), Color8(26, 0, 60), Color8(80, 0, 110), Color8(160, 30, 160), Color8(255, 120, 200)]
	for y: int in size.y:
		for x: int in size.x:
			var a: float = Px.tile_fbm(float(x), float(y), size.x, size.y, 3, 4, 61)
			var b: float = Px.tile_fbm(float(x), float(y), size.x, size.y, 2, 3, 97)
			var t: float = clampf(pow(a, 1.7) * 1.9 - 0.15, 0.0, 1.0)
			var c: Color = Px.ramp(pal, t)
			c = c.lerp(Color8(0, 60, 160), clampf((b - 0.55) * 2.0, 0.0, 0.6))
			px.put_px(x, y, Px.websafe(c, x, y))
			var h: float = Px.hash01(x, y, 5)
			if h > 0.992:
				px.put_px(x, y, WHITE)
			elif h > 0.984:
				px.put_px(x, y, Color8(153, 204, 255))
	return px


static func marble(p: Dictionary, size: Vector2i) -> Px:
	var vein: Color = Kit.colour(p, "colour_a", Color(0.4, 0.45, 0.6))
	var px: Px = Px.new(size.x, size.y)
	for y: int in size.y:
		for x: int in size.x:
			var turb: float = Px.tile_fbm(float(x), float(y), size.x, size.y, 3, 4, 33)
			var v: float = sin(TAU * (float(x) / float(size.x) * 2.0 + float(y) / float(size.y)) + turb * 9.0)
			var t: float = pow(1.0 - absf(v), 6.0)
			var base: Color = Color8(238, 238, 238).lerp(Color8(204, 204, 214), Px.tile_fbm(float(x), float(y), size.x, size.y, 4, 2, 71))
			px.put_px(x, y, Px.websafe(base.lerp(vein, t * 0.9), x, y))
	return px


static func parchment(p: Dictionary, size: Vector2i) -> Px:
	var paper: Color = Kit.colour(p, "colour_a", Color(0.95, 0.85, 0.62))
	var stain: Color = paper.darkened(0.3).lerp(Color(0.55, 0.35, 0.15), 0.3)
	var px: Px = Px.new(size.x, size.y)
	for y: int in size.y:
		for x: int in size.x:
			var n1: float = Px.tile_fbm(float(x), float(y), size.x, size.y, 3, 4, 41)
			var c: Color = paper.lerp(stain, clampf((n1 - 0.4) * 1.6, 0.0, 1.0))
			if Px.hash01(x, y, 2) > 0.975:
				c = c.darkened(0.35)
			elif Px.hash01(x / 3, y, 4) > 0.97:
				c = c.darkened(0.15)
			px.put_px(x, y, Px.websafe(c, x, y))
	return px


static func purple(p: Dictionary, size: Vector2i) -> Px:
	var base: Color = Kit.colour(p, "colour_a", Color(0.2, 0.0, 0.25))
	var px: Px = Px.new(size.x, size.y, base)
	var dot: Color = base.lerp(Color(0.6, 0.1, 0.6), 0.45)
	var faint: Color = base.lerp(Color(0.6, 0.1, 0.6), 0.2)
	for y: int in size.y:
		for x: int in size.x:
			if (x % 4 == 0 and y % 4 == 0) or (x % 4 == 2 and y % 4 == 2):
				px.put_px(x, y, dot)
			elif (x + y) % 2 == 1 and (y % 4 == 1 or y % 4 == 3) and x % 4 != 0:
				px.put_px(x, y, faint)
	return px


static func rainbow_stripes(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var period: int = size.x
	var band_w: int = period / STRIPES.size()
	var shift: int = f * period / n
	for y: int in size.y:
		for x: int in size.x:
			var d: int = posmod(x + y - shift, period)
			var band: int = mini(d / band_w, STRIPES.size() - 1)
			var c: Color = STRIPES[band]
			var inner: int = d % band_w
			if inner == 0:
				c = c.lightened(0.4)
			elif inner == band_w - 1:
				c = c.darkened(0.3)
			px.put_px(x, y, c)
	return px


static func clouds(p: Dictionary, size: Vector2i) -> Px:
	var sky: Color = Kit.colour(p, "colour_b", Color(0.4, 0.6, 1.0))
	var px: Px = Px.new(size.x, size.y)
	var field: PackedFloat32Array = PackedFloat32Array()
	field.resize(size.x * size.y)
	for y: int in size.y:
		for x: int in size.x:
			field[y * size.x + x] = Px.tile_fbm(float(x), float(y), size.x, size.y, 3, 4, 17)
	for y2: int in size.y:
		for x2: int in size.x:
			var v: float = field[y2 * size.x + x2]
			var c: Color = sky.lerp(sky.lightened(0.25), clampf(v - 0.3, 0.0, 1.0))
			if v > 0.55:
				var up: float = field[posmod(y2 - 2, size.y) * size.x + posmod(x2 - 1, size.x)]
				var lit: float = clampf((v - up) * 6.0 + 0.6, 0.0, 1.0)
				c = Px.pick([Color8(170, 187, 221), Color8(221, 230, 255), WHITE], lit, x2, y2)
				if v < 0.58:
					c = c.lerp(sky, 0.35)
			px.put_px(x2, y2, Px.websafe(c, x2, y2) if v <= 0.55 else c)
	return px
