extends RefCounted

const Px := preload("old_web_px.gd")
const Kit := preload("old_web_kit.gd")
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const CRAYONS: Array[Color] = [Color8(0, 102, 255), Color8(0, 204, 170), Color8(255, 51, 153), Color8(221, 0, 0), Color8(40, 40, 40), Color8(136, 51, 187), Color8(255, 136, 0), Color8(17, 170, 51)]


static func paint(id: String, p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	if id == "banner_night":
		return night(p, f, n, size)
	if id == "banner_rainbow":
		return rainbow_banner(p, f, n, size)
	if id == "banner_glitter":
		return glitter(p, f, n, size)
	if id == "banner_chrome":
		return chrome(p, f, n, size)
	if id == "construct_digger":
		return digger(p, f, n, size)
	if id == "construct_cone":
		return cone(p, f, n, size)
	if id == "new_burst":
		return burst(p, f, n, size)
	if id == "award":
		return award(p, f, n, size)
	if id == "div_crayon":
		return crayon_line(size)
	if id == "div_rainbow":
		return rainbow_rule(f, n, size)
	if id == "div_flame":
		return flame(f, n, size)
	if id == "div_sparkle":
		return sparkle_line(p, f, n, size)
	if id == "div_chain":
		return chain(f, n, size)
	if id == "div_bevel":
		return bevel_rule(size)
	return Px.new(size.x, size.y)


static func night(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var sky: Color = Kit.colour(p, "colour_b", Color(0.0, 0.0, 0.2))
	var low: Color = sky.lerp(Color(0.45, 0.1, 0.55), 0.75)
	for y: int in size.y:
		var t: float = float(y) / float(size.y - 1)
		for x: int in size.x:
			px.put_px(x, y, Px.websafe(sky.lerp(low, t * t), x, y))
	var phase: float = float(f) / float(n)
	for i: int in 46:
		var sx: int = int(Px.hash01(i, 1, 77) * float(size.x))
		var sy: int = int(Px.hash01(i, 2, 77) * float(size.y) * 0.62)
		var b: float = 0.5 + 0.5 * sin(TAU * (phase + Px.hash01(i, 3, 77)))
		var big: bool = Px.hash01(i, 4, 77) > 0.82
		if big and b > 0.55:
			Kit.sparkle(px, sx, sy, 2 if b < 0.85 else 3, WHITE, Color8(153, 204, 255))
		elif b > 0.66:
			px.put_px(sx, sy, WHITE)
		elif b > 0.3:
			px.put_px(sx, sy, Color8(153, 153, 204))
		else:
			px.put_px(sx, sy, Color8(102, 102, 153))
	var mx: float = float(size.x) - 26.0
	var my: float = 15.0
	for y2: int in range(int(my) - 11, int(my) + 12):
		for x2: int in range(int(mx) - 11, int(mx) + 12):
			var a: Vector2 = Vector2(float(x2) + 0.5 - mx, float(y2) + 0.5 - my)
			var b2: Vector2 = a - Vector2(4.5, -3.0)
			if a.length() <= 9.5 and b2.length() > 8.0:
				var shade: float = clampf(0.5 - a.x / 18.0, 0.0, 1.0)
				px.put_px(x2, y2, Px.pick([Color8(255, 204, 51), Color8(255, 255, 153), WHITE], shade, x2, y2))
	var ink: Color = Color8(10, 10, 30)
	var x: int = 0
	var bi: int = 0
	while x < size.x:
		var bw: int = 8 + int(Px.hash01(bi, 5, 31) * 14.0)
		var bh: int = 9 + int(Px.hash01(bi, 6, 31) * 15.0)
		var top: int = size.y - bh
		px.rect(x, top, bw, bh, ink)
		if Px.hash01(bi, 7, 31) > 0.7:
			px.vline(x + bw / 2, top - 5, top - 1, ink)
			if (f / 2) % 2 == 0:
				px.put_px(x + bw / 2, top - 6, Color8(255, 51, 51))
		elif Px.hash01(bi, 8, 31) > 0.6:
			px.rect(x + 2, top - 3, bw - 4, 3, ink)
		for wy: int in range(top + 2, size.y - 2, 3):
			for wx: int in range(x + 2, x + bw - 2, 3):
				var lit: float = Px.hash01(wx, wy, 13)
				var flick: bool = Px.hash01(wx, wy, 14) > 0.9 and ((f + wx) / 3) % 2 == 0
				if lit > 0.55 and not flick:
					px.put_px(wx, wy, Color8(255, 255, 102) if lit > 0.8 else Color8(255, 204, 51))
		x += bw + (1 if Px.hash01(bi, 9, 31) > 0.6 else 0)
		bi += 1
	var gold: Color = Kit.colour(p, "colour_a", Color(1.0, 0.8, 0.0))
	var deep: Color = gold.lerp(Color(1.0, 0.35, 0.0), 0.75)
	var text: Px = Kit.fancy_text(Kit.text_of(p, "text", "WELCOME"), 3, func(xx: int, yy: int, fy: float) -> Color: return Px.websafe(gold.lerp(Color.WHITE, 0.4).lerp(deep, fy), xx, yy), Color8(0, 0, 51), gold.lerp(Color.WHITE, 0.7), deep.darkened(0.3))
	Kit.stamp_text(px, text, size.x / 2 - 8, 4, Color8(0, 0, 0), Vector2i(2, 2))
	return px


static func rainbow_banner(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var bg: Color = Kit.colour(p, "colour_b", WHITE)
	var px: Px = Px.new(size.x, size.y, bg)
	var s: String = Kit.text_of(p, "text", "WELCOME")
	var scale: int = 3
	var total: int = Px.text_width(s, false, scale, 1, Kit.weight_for(scale))
	var x: int = (size.x - total) / 2
	var count: int = maxi(s.length(), 1)
	for i: int in s.length():
		var ch: String = s.substr(i, 1)
		var hue: float = fposmod(float(i) / float(count) - float(f) / float(n), 1.0)
		var c: Color = Color.from_hsv(hue, 1.0, 1.0)
		c = Color(round(c.r * 5.0) / 5.0, round(c.g * 5.0) / 5.0, round(c.b * 5.0) / 5.0)
		var bob: int = int(round(3.0 * sin(TAU * (float(f) / float(n) + float(i) / float(count)))))
		if ch != " ":
			var piece: Px = Kit.fancy_text(ch, scale, func(xx: int, yy: int, fy: float) -> Color: return c.lerp(Color.WHITE, 0.45) if fy < 0.15 else (c.darkened(0.25) if fy > 0.8 else c), BLACK)
			px.blit(Kit.shadow_of(piece, Color8(153, 153, 153)), x - 2 + 3, (size.y - piece.h) / 2 + bob + 3)
			px.blit(piece, x - 2, (size.y - piece.h) / 2 + bob)
		x += (Px.glyph_width(ch, false) + 1) * scale + Kit.weight_for(scale)
	return px


static func glitter(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var bg: Color = Kit.colour(p, "colour_b", Color(0.15, 0.0, 0.25))
	var px: Px = Px.new(size.x, size.y)
	for y: int in size.y:
		for x: int in size.x:
			px.put_px(x, y, Px.websafe(bg.lerp(BLACK, float(y) / float(size.y) * 0.6), x, y))
	var g: Color = Kit.colour(p, "colour_a", Color(1.0, 0.4, 0.8))
	var shades: Array[Color] = [g.darkened(0.55), g.darkened(0.2), g, g.lerp(WHITE, 0.45), WHITE]
	var fill: Callable = func(xx: int, yy: int, _fy: float) -> Color:
		var r: float = Px.hash01(xx, yy, 400 + f)
		if r > 0.93:
			return shades[4]
		if r > 0.62:
			return shades[3]
		if r > 0.28:
			return shades[2]
		if r > 0.1:
			return shades[1]
		return shades[0]
	var text: Px = Kit.fancy_text(Kit.text_of(p, "text", "WELCOME"), 3, fill, WHITE, Color(0, 0, 0, 0), Color(0, 0, 0, 0), g.darkened(0.5))
	Kit.stamp_text(px, text, size.x / 2, (size.y - text.h) / 2 + 1)
	for i: int in 7:
		var life: int = posmod(f + i * 3, n)
		var arm: int = [0, 1, 2, 3, 2, 1, 0, 0][life * 8 / n]
		var sx: int = int(Px.hash01(i, f / n + 9, 5) * float(size.x - 16)) + 8
		var sy: int = int(Px.hash01(i, 3, 5) * float(size.y - 10)) + 5
		Kit.sparkle(px, sx, sy, arm, WHITE, g.lerp(WHITE, 0.6))
	return px


static func chrome(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var bg: Color = Kit.colour(p, "colour_b", Color(0.0, 0.0, 0.3))
	var px: Px = Px.new(size.x, size.y)
	var horizon: int = size.y * 2 / 3
	for y: int in size.y:
		for x: int in size.x:
			if y < horizon:
				px.put_px(x, y, Px.websafe(BLACK.lerp(bg, float(y) / float(horizon)), x, y))
			else:
				px.put_px(x, y, Px.websafe(bg.darkened(0.4), x, y))
	for gx: int in range(-size.x, size.x * 2, 24):
		px.line(size.x / 2 + (gx - size.x / 2) / 6, horizon, gx, size.y - 1, Color8(204, 0, 204))
	for k: int in 5:
		var gy: int = horizon + int(pow(float(k) / 4.0, 1.8) * float(size.y - horizon - 1))
		px.hline(0, size.x - 1, gy, Color8(204, 0, 204))
	for i: int in 20:
		px.put_px(int(Px.hash01(i, 1, 9) * float(size.x)), int(Px.hash01(i, 2, 9) * float(horizon - 4)), WHITE if i % 3 == 0 else Color8(153, 153, 204))
	var sky_a: Color = Color8(51, 102, 204)
	var sky_b: Color = Color8(204, 238, 255)
	var earth_a: Color = Color8(102, 51, 0)
	var earth_b: Color = Color8(255, 221, 153)
	var fill: Callable = func(xx: int, yy: int, fy: float) -> Color:
		if fy < 0.5:
			return Px.websafe(sky_a.lerp(sky_b, fy / 0.5), xx, yy)
		if fy < 0.58:
			return Color8(51, 25, 0)
		return Px.websafe(earth_a.lerp(earth_b, (fy - 0.58) / 0.42).lerp(WHITE, maxf(fy - 0.85, 0.0) * 3.0), xx, yy)
	var text: Px = Kit.fancy_text(Kit.text_of(p, "text", "WELCOME"), 3, fill, BLACK, WHITE, Color8(51, 51, 102))
	var shine_at: float = float(f) / float(n) * 1.8 - 0.4
	for y3: int in text.h:
		for x3: int in text.w:
			var c: Color = text.get_px(x3, y3)
			if c.a <= 0.0 or c == BLACK:
				continue
			var u: float = (float(x3) + float(y3) * 0.6) / float(text.w)
			if absf(u - shine_at) < 0.035:
				text.put_px(x3, y3, WHITE)
	Kit.stamp_text(px, text, size.x / 2, (size.y - text.h) / 2 - 2, Color8(0, 0, 0), Vector2i(3, 3))
	var glint: int = posmod(f - n / 2, n)
	if glint < 4:
		Kit.sparkle(px, size.x / 2 + text.w / 2 - 10, (size.y - text.h) / 2 + 3, [2, 4, 3, 1][glint], WHITE, Color8(204, 238, 255))
	return px


static func stripes(px: Px, y0: int, hgt: int, shift: int) -> void:
	for y: int in range(y0, y0 + hgt):
		for x: int in px.w:
			var band: int = posmod(x + y - shift, 16)
			px.put_px(x, y, Color8(20, 20, 20) if band < 8 else Color8(255, 204, 0))


static func digger(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, Color8(255, 204, 0))
	var shift: int = f * 16 / n
	stripes(px, 0, 8, shift)
	stripes(px, size.y - 8, 8, -shift)
	px.hline(0, size.x - 1, 8, BLACK)
	px.hline(0, size.x - 1, size.y - 9, BLACK)
	var base_y: int = size.y - 12
	var sprite: Px = Px.new(64, 44)
	sprite.rect(4, 36, 40, 6, Color8(60, 60, 60))
	for wx: int in [8, 16, 24, 32, 40]:
		sprite.disc(float(wx), 39.0, 2.6, Color8(30, 30, 30))
		sprite.put_px(wx - 1, 38, Color8(150, 150, 150))
	sprite.rect(6, 24, 34, 12, Color8(255, 136, 0))
	sprite.hline(6, 39, 24, Color8(255, 187, 68))
	sprite.rect(10, 12, 16, 13, Color8(255, 136, 0))
	sprite.rect(12, 14, 11, 7, Color8(153, 221, 255))
	sprite.put_px(13, 15, WHITE)
	sprite.put_px(14, 15, WHITE)
	sprite.rect(28, 18, 3, 6, Color8(80, 80, 80))
	var swing: float = sin(TAU * float(f) / float(n))
	var pivot: Vector2 = Vector2(38.0, 26.0)
	var elbow: Vector2 = pivot + Vector2(12.0, -14.0 + 4.0 * swing)
	var tip: Vector2 = elbow + Vector2(10.0, 14.0 - 5.0 * swing)
	sprite.thick_line(pivot.x, pivot.y, elbow.x, elbow.y, 2.0, Color8(255, 136, 0))
	sprite.thick_line(elbow.x, elbow.y, tip.x, tip.y, 1.6, Color8(255, 136, 0))
	var bucket: PackedVector2Array = PackedVector2Array([tip + Vector2(-4.0, -1.0), tip + Vector2(4.0, -2.0), tip + Vector2(3.0, 5.0), tip + Vector2(-3.0, 4.0)])
	sprite.poly(bucket, Color8(90, 90, 90))
	if swing < -0.3:
		sprite.disc(tip.x, tip.y - 2.0, 2.0, Color8(153, 102, 51))
	sprite.outlined(BLACK, false)
	px.blit(sprite, 4, base_y - 40)
	var t1: String = Kit.text_of(p, "text", "UNDER")
	var t2: String = Kit.text_of(p, "text2", "CONSTRUCTION")
	var area_x: int = 70
	var area_w: int = size.x - area_x - 4
	var scale: int = 2 if Px.text_width(t2, false, 2, 1, 1) <= area_w and Px.text_width(t1, false, 2, 1, 1) <= area_w else 1
	var lh: int = Px.FONT_ROWS * scale
	var top: int = 8 + (size.y - 16 - lh * 2 - 4) / 2
	for row: int in 2:
		var s: String = t1 if row == 0 else t2
		var piece: Px = Kit.fancy_text(s, scale, func(_xx: int, _yy: int, _fy: float) -> Color: return Color8(20, 20, 20), Color(0, 0, 0, 0))
		px.blit(Kit.shadow_of(piece, Color8(204, 136, 0)), area_x + (area_w - piece.w) / 2 + 1, top + row * (lh + 4) - 2 + 1)
		px.blit(piece, area_x + (area_w - piece.w) / 2, top + row * (lh + 4) - 2)
	return px


static func cone(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var plate: Px = Px.new(size.x - 8, 26, Color8(255, 204, 0))
	plate.box(0, 0, plate.w, plate.h, BLACK)
	plate.box(2, 2, plate.w - 4, plate.h - 4, BLACK)
	var t1: String = Kit.text_of(p, "text", "UNDER")
	var t2: String = Kit.text_of(p, "text2", "CONSTRUCTION")
	Kit.fit_text(plate, 3, plate.w - 3, 4, t1, BLACK, true)
	Kit.fit_text(plate, 3, plate.w - 3, 14, t2, BLACK, true)
	px.rect(size.x / 2 - 1, 26, 3, 8, Color8(80, 80, 80))
	px.blit(plate, 4, 0)
	var y0: int = 46
	var board: Px = Px.new(76, 11)
	for y: int in board.h:
		for x: int in board.w:
			board.put_px(x, y, Color8(255, 102, 0) if posmod(x - y, 12) < 6 else WHITE)
	board.box(0, 0, board.w, board.h, BLACK)
	var bx: int = size.x - board.w - 4
	px.thick_line(float(bx) + 8.0, float(y0) + 6.0, float(bx) + 2.0, float(size.y) - 2.0, 1.2, Color8(110, 70, 30))
	px.thick_line(float(bx) + 8.0, float(y0) + 6.0, float(bx) + 16.0, float(size.y) - 2.0, 1.2, Color8(110, 70, 30))
	px.thick_line(float(bx + board.w) - 8.0, float(y0) + 6.0, float(bx + board.w) - 2.0, float(size.y) - 2.0, 1.2, Color8(110, 70, 30))
	px.thick_line(float(bx + board.w) - 8.0, float(y0) + 6.0, float(bx + board.w) - 16.0, float(size.y) - 2.0, 1.2, Color8(110, 70, 30))
	px.blit(board, bx, y0)
	var lamp_x: int = bx + board.w - 10
	var on: bool = f < n / 2
	px.rect(lamp_x - 1, y0 - 4, 3, 4, Color8(60, 60, 60))
	px.disc(float(lamp_x) + 0.5, float(y0) - 7.0, 4.0, Color8(255, 204, 0) if on else Color8(153, 102, 0))
	px.disc(float(lamp_x) - 0.5, float(y0) - 8.0, 1.5, WHITE if on else Color8(204, 153, 51))
	if on:
		for k: int in 8:
			var a: float = TAU * float(k) / 8.0
			px.set_px(lamp_x + int(round(cos(a) * 7.0)), y0 - 7 + int(round(sin(a) * 7.0)), Color8(255, 255, 102))
	var c: Px = Px.new(30, 40)
	var tri: PackedVector2Array = PackedVector2Array([Vector2(13.0, 2.0), Vector2(17.0, 2.0), Vector2(26.0, 34.0), Vector2(4.0, 34.0)])
	c.poly(tri, Color8(255, 102, 0))
	for y2: int in range(2, 34):
		for x2: int in 30:
			if c.alpha_at(x2, y2) == 0:
				continue
			if (y2 >= 12 and y2 <= 15) or (y2 >= 22 and y2 <= 25):
				c.put_px(x2, y2, WHITE)
			var mid: float = 15.0 + float(y2 - 2) * 0.0
			if float(x2) < mid - float(y2) * 0.15:
				c.put_px(x2, y2, c.get_px(x2, y2).lightened(0.25))
			elif float(x2) > mid + float(y2) * 0.12:
				c.put_px(x2, y2, c.get_px(x2, y2).darkened(0.25))
	c.rect(1, 34, 28, 5, Color8(40, 40, 40))
	c.hline(1, 28, 34, Color8(90, 90, 90))
	c.outlined(BLACK, false)
	px.blit(c, 2, size.y - 41)
	return px


static func burst(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var a: Color = Kit.colour(p, "colour_a", Color(1.0, 0.0, 0.0))
	var b: Color = Kit.colour(p, "colour_b", Color(1.0, 1.0, 0.0))
	var swap: bool = (f * 2 / n) % 2 == 1
	var turn: float = PI / 14.0 if f % 2 == 1 else 0.0
	var cx: float = float(size.x) * 0.5
	var cy: float = float(size.y) * 0.5
	var shape: Px = Px.new(size.x, size.y)
	shape.poly(Kit.star_points(cx, cy, cx - 2.0, cx * 0.68, 14, turn, (cy - 2.0) / (cx - 2.0)), b if swap else a)
	shape.poly(Kit.star_points(cx, cy, cx * 0.72, cx * 0.52, 14, turn + PI / 14.0, (cy - 2.0) / (cx - 2.0)), a if swap else b)
	shape.outlined(BLACK, false)
	px.blit(shape, 0, 0)
	var s: String = Kit.text_of(p, "text", "NEW!")
	var scale: int = 2 if Px.text_width(s, false, 2) <= size.x - 14 else 1
	var tc: Color = WHITE if not swap else Color8(255, 255, 204)
	var text: Px = Kit.fancy_text(s, scale, func(_xx: int, _yy: int, fy: float) -> Color: return tc if fy < 0.7 else Color8(204, 204, 204), BLACK)
	var lift: int = 1 if f % 3 == 0 else 0
	Kit.stamp_text(px, text, size.x / 2 + 1, (size.y - Px.FONT_ROWS * scale) / 2 - 2 - lift, Color8(102, 0, 0), Vector2i(1, 1))
	return px


static func award(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var ribbon: Color = Kit.colour(p, "colour_a", Color(0.0, 0.2, 0.8))
	var cx: float = float(size.x) * 0.5
	var cy: float = 46.0
	var tails: Px = Px.new(size.x, size.y)
	for side: int in 2:
		var x0: float = cx - 24.0 if side == 0 else cx + 4.0
		var lean: float = -6.0 if side == 0 else 6.0
		var pts: PackedVector2Array = PackedVector2Array([Vector2(x0, cy + 10.0), Vector2(x0 + 20.0, cy + 10.0), Vector2(x0 + 20.0 + lean, float(size.y) - 3.0), Vector2(x0 + 10.0 + lean, float(size.y) - 11.0), Vector2(x0 + lean, float(size.y) - 3.0)])
		tails.poly(pts, ribbon)
		for y: int in range(int(cy) + 10, size.y):
			for x: int in size.x:
				if tails.alpha_at(x, y) == 0:
					continue
				var c: Color = tails.get_px(x, y)
				if c == ribbon and (x + y) % 7 == 0:
					tails.put_px(x, y, ribbon.lightened(0.35))
	tails.outlined(BLACK, false)
	px.blit(tails, 0, 0)
	var rose: Px = Px.new(size.x, size.y)
	for y2: int in size.y:
		for x2: int in size.x:
			var d: Vector2 = Vector2(float(x2) + 0.5 - cx, float(y2) + 0.5 - cy)
			var ang: float = atan2(d.y, d.x)
			var ridge: float = cos(ang * 24.0)
			var r: float = 40.0 + 2.6 * ridge
			var dist: float = d.length()
			if dist > r:
				continue
			var light: float = clampf(0.55 - d.x / 90.0 - d.y / 70.0, 0.0, 1.0)
			if dist > 30.0:
				light = clampf(light * 0.6 + (ridge * 0.5 + 0.5) * 0.5, 0.0, 1.0)
			elif dist > 27.0:
				light = 0.15
			rose.put_px(x2, y2, Px.pick([Color8(153, 102, 0), Color8(204, 153, 0), Color8(255, 204, 51), Color8(255, 255, 153)], light, x2, y2))
	rose.outlined(BLACK, false)
	px.blit(rose, 0, 0)
	var ink: Color = Color8(102, 51, 0)
	px.poly(Kit.star_points(cx, cy - 12.0, 5.5, 2.4, 5), Color8(255, 255, 204))
	Kit.fit_text(px, int(cx) - 25, int(cx) + 25, int(cy) - 4, Kit.text_of(p, "text", "NEAT PAGE"), ink)
	Kit.fit_text(px, int(cx) - 25, int(cx) + 25, int(cy) + 5, Kit.text_of(p, "text2", "OF THE DAY"), ink)
	var ga: float = TAU * float(f) / float(n) - PI * 0.75
	Kit.sparkle(px, int(cx + cos(ga) * 37.0), int(cy + sin(ga) * 37.0), 3 if f % 2 == 0 else 2, WHITE, Color8(255, 255, 204))
	return px


static func crayon_line(size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var dir: Vector2 = Vector2(cos(-0.42), sin(-0.42))
	var across: Vector2 = Vector2(-dir.y, dir.x)
	var count: int = (size.x - 34) / 24
	for i: int in count:
		var col: Color = CRAYONS[i % CRAYONS.size()]
		var centre: Vector2 = Vector2(14.0 + float(i) * 24.0, float(size.y) * 0.5)
		var piece: Px = Px.new(size.x, size.y)
		for y: int in size.y:
			for x: int in range(maxi(int(centre.x) - 16, 0), mini(int(centre.x) + 16, size.x)):
				var d: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5) - centre
				var u: float = d.dot(dir)
				var v: float = d.dot(across)
				var radius: float = 2.6
				if u > 7.0:
					radius = lerpf(2.6, 0.5, (u - 7.0) / 5.0)
				if u < -12.0 or u > 12.0 or absf(v) > radius:
					continue
				var c: Color = col
				if (u > -10.0 and u < -7.5) or (u > 3.0 and u < 5.5):
					c = col.darkened(0.35)
				elif u >= 7.0:
					c = col.lightened(0.15)
				if v < -1.2:
					c = c.lightened(0.35)
				elif v > 1.3:
					c = c.darkened(0.3)
				piece.put_px(x, y, c)
		piece.outlined(col.darkened(0.6), false)
		px.blit(piece, 0, 0)
	var last: Color = CRAYONS[count % CRAYONS.size()]
	var sx: int = 14 + count * 24 - 8
	var prev: Vector2 = Vector2(float(sx), float(size.y) * 0.5)
	for k: int in range(1, 60):
		var t: float = float(k) / 59.0
		var pt: Vector2 = Vector2(float(sx) + t * float(size.x - sx - 4), float(size.y) * 0.5 + sin(t * TAU * 3.5) * 4.0 * (1.0 - t * 0.4))
		px.thick_line(prev.x, prev.y, pt.x, pt.y, 0.8, last)
		prev = pt
	return px


static func rainbow_rule(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	for y: int in size.y:
		for x: int in size.x:
			var hue: float = fposmod(float(x) / float(size.x) - float(f) / float(n), 1.0)
			var c: Color = Color.from_hsv(hue, 1.0, 1.0)
			if y == 0:
				c = c.lerp(WHITE, 0.55)
			elif y == size.y - 1:
				c = c.darkened(0.5)
			elif y == size.y - 2:
				c = c.darkened(0.2)
			px.put_px(x, y, Px.websafe(c, x, y))
	return px


static func flame_height(x: int, f: int, n: int, w: int) -> float:
	var t: float = TAU * float(f) / float(n)
	var u: float = TAU * float(x) / float(w)
	var hgt: float = 0.55
	hgt += 0.16 * sin(u * 23.0 + t)
	hgt += 0.12 * sin(u * 41.0 - t * 2.0 + 1.3)
	hgt += 0.08 * sin(u * 67.0 + t * 3.0 + 2.1)
	hgt += 0.06 * sin(u * 11.0 - t + 0.4)
	return clampf(hgt, 0.15, 1.0)


static func flame(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var pal: Array = [Color8(255, 255, 204), Color8(255, 255, 0), Color8(255, 204, 0), Color8(255, 102, 0), Color8(204, 0, 0), Color8(102, 0, 0)]
	for x: int in size.x:
		var hgt: float = flame_height(x, f, n, size.x) * float(size.y)
		for y: int in size.y:
			var up: float = float(size.y - 1 - y)
			var jitter: float = 0.85 + 0.3 * Px.hash01(x / 2, y, 50 + f)
			var q: float = up / maxf(hgt * jitter, 1.0)
			if q > 1.0:
				continue
			px.put_px(x, y, Px.pick(pal, q, x, y))
	return px


static func sparkle_line(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var c: Color = Kit.colour(p, "colour_a", Color(1.0, 0.4, 1.0))
	var mid: int = size.y / 2
	for x: int in range(2, size.x - 2):
		if x % 4 == 0:
			px.put_px(x, mid, WHITE)
		elif x % 2 == 0:
			px.put_px(x, mid, c)
	var steps: int = (size.x - 8) / 20
	for i: int in steps + 1:
		var life: int = posmod(f - i, n)
		var arm: int = [1, 2, 3, 4, 3, 2, 1, 0][life * 8 / n]
		var sx: int = 4 + i * 20
		Kit.sparkle(px, sx, mid, mini(arm, mid - 1), WHITE, c.lerp(WHITE, 0.3))
	return px


static func chain(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var cy: float = float(size.y) * 0.5
	var links: int = size.x / 10
	var glint_at: int = posmod(f, n)
	for i: int in links:
		var cx: float = float(i) * 10.0 + 5.0
		for y: int in size.y:
			for x: int in range(maxi(int(cx) - 7, 0), mini(int(cx) + 7, size.x)):
				var dx: float = (float(x) + 0.5 - cx) / 5.2
				var dy: float = (float(y) + 0.5 - cy) / 4.2
				var r: float = sqrt(dx * dx + dy * dy)
				if r <= 1.0 and r >= 0.55:
					var c: Color = Color8(221, 221, 221) if dy < -0.2 else (Color8(170, 170, 170) if dy < 0.35 else Color8(102, 102, 102))
					px.put_px(x, y, c)
		px.rect(int(cx) + 4, int(cy) - 1, 4, 2, Color8(136, 136, 136))
		px.hline(int(cx) + 4, int(cx) + 7, int(cy) - 1, Color8(204, 204, 204))
		if i % n == glint_at:
			px.put_px(int(cx) - 2, int(cy) - 3, WHITE)
			px.put_px(int(cx) - 1, int(cy) - 3, WHITE)
			px.put_px(int(cx) - 2, int(cy) - 4, WHITE)
	px.outlined(Color8(34, 34, 34), false)
	return px


static func bevel_rule(size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var rows: Array[Color] = [Color8(128, 128, 128), Color8(64, 64, 64), Color8(255, 255, 255), Color8(192, 192, 192)]
	for y: int in size.y:
		px.hline(0, size.x - 1, y, rows[mini(y, rows.size() - 1)])
	px.vline(0, 0, size.y - 1, Color8(128, 128, 128))
	px.vline(size.x - 1, 0, size.y - 1, WHITE)
	return px
