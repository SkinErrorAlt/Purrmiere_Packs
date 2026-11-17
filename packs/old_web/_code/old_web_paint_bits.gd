extends RefCounted

const Px := preload("old_web_px.gd")
const Kit := preload("old_web_kit.gd")
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const GREY := Color8(192, 192, 192)
const BUBBLE_MAX_TEXT := 132


static func paint(id: String, p: Dictionary, f: int, n: int, size: Vector2i, fps: float) -> Px:
	if id.begins_with("stamp_"):
		return stamp(id.substr(6), p, f, maxi(n, 1), size)
	if id.begins_with("btn_"):
		return button(id, p, f, maxi(n, 1), size)
	if id == "counter":
		return counter(p, f, size, fps)
	if id == "email":
		return email(f, n, size)
	if id == "mailbox":
		return mailbox(f, n, size)
	if id == "new_blink":
		return new_blink(p, f, n, size)
	if id == "globe":
		return globe(f, n, size)
	if id == "arrows":
		return arrows(p, f, n)
	if id == "webring":
		return webring(p, f, n, size)
	if id == "marquee":
		return marquee(p, f, size)
	if id == "guestbook":
		return guestbook(p, f, n, size)
	if id == "cursor_trail":
		return cursor_trail(f, n, size)
	if id == "bubble":
		return bubble(p, size)
	return Px.new(size.x, size.y)


static func button(id: String, p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var t1: String = Kit.text_of(p, "text", "")
	var t2: String = Kit.text_of(p, "text2", "")
	if id == "btn_html":
		Kit.button_base(px, Color8(221, 221, 221), Color8(170, 170, 170), BLACK)
		px.rect(3, 3, 25, 25, WHITE)
		px.box(3, 3, 25, 25, Color8(102, 102, 102))
		px.thick_line(8.0, 16.0, 13.0, 22.0, 2.0, Color8(0, 153, 0))
		px.thick_line(13.0, 22.0, 23.0, 8.0, 2.0, Color8(0, 153, 0))
		px.line(8, 15, 13, 20, Color8(102, 255, 102))
		Kit.fit_text(px, 30, size.x - 3, 5, t1, Color8(0, 0, 102), true)
		Kit.fit_text(px, 30, size.x - 3, 17, t2, Color8(153, 0, 0))
	elif id == "btn_browser":
		Kit.button_base(px, Color8(0, 0, 0), Color8(17, 17, 34), Color8(0, 153, 0))
		var mon: Px = Px.new(22, 22)
		mon.rect(0, 0, 22, 17, Color8(221, 204, 170))
		mon.rect(2, 2, 18, 12, Color8(0, 0, 102))
		for sy: int in range(2, 14):
			if (sy + f) % 3 == 0:
				mon.hline(2, 19, sy, Color8(0, 51, 204))
		mon.text(4, 4, "www", Color8(102, 255, 102), true)
		mon.rect(7, 17, 8, 2, Color8(187, 170, 136))
		mon.rect(4, 19, 14, 2, Color8(221, 204, 170))
		mon.put_px(18, 15, Color8(0, 255, 0) if f % 2 == 0 else Color8(0, 102, 0))
		mon.outlined(Color8(68, 68, 68), false)
		px.blit(mon, 3, 4)
		Kit.fit_text(px, 27, size.x - 3, 6, t1, Color8(0, 255, 0))
		Kit.fit_text(px, 27, size.x - 3, 17, t2, Color8(255, 255, 0), true)
	elif id == "btn_guestbook":
		Kit.button_base(px, Color8(204, 0, 51), Color8(102, 0, 0), BLACK)
		var book: Px = Px.new(26, 22)
		book.poly(PackedVector2Array([Vector2(1.0, 6.0), Vector2(12.0, 4.0), Vector2(13.0, 19.0), Vector2(1.0, 20.0)]), Color8(255, 255, 238))
		book.poly(PackedVector2Array([Vector2(13.0, 4.0), Vector2(24.0, 6.0), Vector2(24.0, 20.0), Vector2(13.0, 19.0)]), Color8(255, 255, 238))
		for ly: int in [9, 12, 15]:
			book.hline(3, 10, ly, Color8(153, 153, 204))
			book.hline(15, 22 - (4 if ly == 15 else 0), ly, Color8(153, 153, 204))
		book.vline(12, 4, 19, Color8(153, 102, 51))
		book.outlined(Color8(102, 51, 0), false)
		var q: int = [0, 1, 2, 1, 0, -1, -2, -1][f * 8 / n]
		book.thick_line(17.0 + float(q), 15.0, 24.0 + float(q), 2.0, 0.9, WHITE)
		book.line(17 + q, 15, 16 + q, 17, BLACK)
		px.blit(book, 3, 5)
		Kit.fit_text(px, 31, size.x - 3, 5, t1, Color8(255, 255, 204))
		Kit.fit_text(px, 31, size.x - 3, 17, t2, Color8(255, 255, 0), true)
	elif id == "btn_y2k":
		Kit.button_base(px, Color8(0, 51, 153), Color8(0, 0, 51), Color8(153, 153, 204))
		var big: Px = Kit.fancy_text(t1 if not t1.is_empty() else "Y2K", 2, func(xx: int, yy: int, fy: float) -> Color: return Px.websafe(Color8(204, 238, 255).lerp(Color8(102, 102, 153), fy), xx, yy), BLACK, WHITE, Color8(51, 51, 102))
		px.blit(big, 3, (size.y - big.h) / 2 + 2)
		var on: bool = f < n / 2 + 1
		var tx0: int = mini(big.w + 2, 48)
		if on:
			Kit.fit_text(px, tx0, size.x - 3, 8, t2, Color8(255, 255, 0), true)
		else:
			Kit.fit_text(px, tx0, size.x - 3, 8, t2, Color8(255, 102, 0), true)
		Kit.fit_text(px, tx0, size.x - 3, 19, "OK", Color8(102, 255, 102))
	elif id == "btn_handmade":
		Kit.button_base(px, Color8(255, 255, 221), Color8(255, 221, 170), Color8(153, 51, 51))
		var beat: bool = f % 4 < 2
		var r: float = 6.0 if beat else 5.0
		var heart: Px = Px.new(24, 22)
		heart.disc(12.0 - r * 0.55, 9.0, r * 0.62, Color8(221, 0, 51))
		heart.disc(12.0 + r * 0.55, 9.0, r * 0.62, Color8(221, 0, 51))
		heart.poly(PackedVector2Array([Vector2(12.0 - r * 1.15, 10.0), Vector2(12.0 + r * 1.15, 10.0), Vector2(12.0, 10.0 + r * 1.4)]), Color8(221, 0, 51))
		heart.put_px(9, 7, Color8(255, 153, 153))
		heart.put_px(8, 8, Color8(255, 153, 153))
		heart.outlined(Color8(102, 0, 0), false)
		px.blit(heart, 3, 5)
		Kit.fit_text(px, 28, size.x - 3, 5, t1, Color8(102, 0, 0), true)
		Kit.fit_text(px, 28, size.x - 3, 17, t2, Color8(204, 0, 102))
	return px


static func counter(p: Dictionary, f: int, size: Vector2i, fps: float) -> Px:
	var px: Px = Px.new(size.x, size.y, Color8(64, 64, 64))
	px.bevel(0, 0, size.x, size.y, Color8(160, 160, 160), Color8(16, 16, 16), true, 1)
	var digits: int = clampi(int(p.get("digits", 6)), 1, 12)
	var number: int = maxi(int(p.get("number", 0)), 0)
	var rate: float = maxf(float(p.get("rate", 1.0)), 0.0)
	var counting: bool = bool(p.get("counting", false)) and rate > 0.0
	var t: float = float(f) / maxf(fps, 1.0)
	var steps: float = t * rate if counting else 0.0
	var value: int = number + int(floor(steps))
	var frac: float = steps - floor(steps)
	var roll: float = clampf((frac - 0.6) / 0.4, 0.0, 1.0) if counting else 0.0
	var now: String = str(value)
	var after: String = str(value + 1)
	while now.length() < digits:
		now = "0" + now
	while after.length() < digits:
		after = "0" + after
	now = now.substr(now.length() - digits)
	after = after.substr(after.length() - digits)
	for i: int in digits:
		var cx: int = 3 + i * 10
		var last: bool = i == digits - 1
		var cell: Px = Px.new(9, 13)
		for y: int in 13:
			var c: Color = Color8(26, 26, 26) if y < 6 else Color8(0, 0, 0)
			if last:
				c = Color8(119, 0, 0) if y < 6 else Color8(85, 0, 0)
			cell.hline(0, 8, y, c)
		var a: String = now.substr(i, 1)
		var b: String = after.substr(i, 1)
		var off: int = int(round(roll * 11.0)) if a != b else 0
		var ink: Color = Color8(238, 238, 221)
		cell.text(2, 3 - off, a, ink)
		if off > 0:
			cell.text(2, 3 - off + 11, b, ink)
		cell.hline(0, 8, 6, Color8(0, 0, 0, 120))
		px.blit(cell, cx, 2)
	return px


static func email(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var theta: float = TAU * float(f) / float(n)
	var c: float = cos(theta)
	var full: int = 26
	var wd: int = maxi(int(round(float(full) * absf(c))), 1)
	var hgt: int = 18
	var x0: int = size.x / 2 - wd / 2
	var y0: int = (size.y - hgt) / 2
	if wd <= 2:
		px.rect(x0, y0, wd, hgt, Color8(153, 153, 153))
		px.vline(x0, y0, y0 + hgt - 1, Color8(102, 102, 102))
		return px
	var env: Px = Px.new(size.x, size.y)
	var paper: Color = WHITE.darkened(0.25 * (1.0 - absf(c)))
	env.rect(x0, y0, wd, hgt, paper)
	var front: bool = c >= 0.0
	for k: int in (wd + hgt) * 2:
		var stripe: Color = Color8(221, 0, 0) if (k / 3) % 2 == 0 else Color8(0, 51, 204)
		if k < wd:
			env.put_px(x0 + k, y0 + 1, stripe)
		elif k < wd + hgt:
			env.put_px(x0 + wd - 2, y0 + k - wd, stripe)
		elif k < wd * 2 + hgt:
			env.put_px(x0 + wd - 1 - (k - wd - hgt), y0 + hgt - 2, stripe)
		else:
			env.put_px(x0 + 1, y0 + hgt - 1 - (k - wd * 2 - hgt), stripe)
	if front:
		if wd > 12:
			env.rect(x0 + wd - 8, y0 + 3, 5, 6, Color8(255, 204, 0))
			env.box(x0 + wd - 8, y0 + 3, 5, 6, Color8(204, 102, 0))
			for ly: int in [10, 12, 14]:
				env.hline(x0 + wd / 3, x0 + wd - 5, y0 + ly, Color8(102, 102, 153))
	else:
		var mid: int = x0 + wd / 2
		env.line(x0 + 2, y0 + 2, mid, y0 + 10, Color8(102, 102, 102))
		env.line(x0 + wd - 3, y0 + 2, mid, y0 + 10, Color8(102, 102, 102))
		env.disc(float(mid) + 0.5, float(y0) + 10.5, 2.2, Color8(204, 0, 0))
	env.outlined(BLACK, false)
	px.blit(env, 0, 0)
	return px


static func mailbox(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	px.rect(18, 25, 4, 15, Color8(119, 68, 17))
	px.vline(18, 25, 39, Color8(170, 119, 51))
	var box: Px = Px.new(size.x, size.y)
	var body: Color = Color8(51, 102, 204)
	box.ellipse(20.0, 14.0, 13.0, 6.0, body)
	box.rect(7, 14, 27, 12, body)
	for y: int in size.y:
		for x: int in size.x:
			if box.alpha_at(x, y) == 0:
				continue
			if y < 12:
				box.put_px(x, y, Px.websafe(body.lightened(0.35), x, y))
			elif y > 22:
				box.put_px(x, y, body.darkened(0.3))
	box.ellipse(7.5, 19.0, 2.5, 6.5, body.darkened(0.45))
	box.outlined(BLACK, false)
	px.blit(box, 0, 0)
	var up: bool = f < n / 2
	if up:
		px.rect(31, 6, 2, 14, Color8(80, 80, 80))
		px.rect(33, 6, 6, 5, Color8(221, 0, 0))
		px.hline(33, 38, 6, Color8(255, 102, 102))
		px.box(32, 5, 8, 7, BLACK)
		px.rect(3, 15, 6, 4, WHITE)
		px.box(2, 14, 7, 6, BLACK)
		px.put_px(4, 16, Color8(204, 0, 0))
	else:
		px.rect(31, 18, 8, 2, Color8(80, 80, 80))
		px.rect(35, 18, 5, 5, Color8(221, 0, 0))
		px.box(34, 17, 6, 7, BLACK)
	return px


static func new_blink(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var phase_a: bool = f < n / 2
	var bg: Color = Color8(255, 255, 0) if phase_a else Color8(255, 0, 0)
	var ink: Color = Color8(255, 0, 0) if phase_a else Color8(255, 255, 0)
	var px: Px = Px.new(size.x, size.y, bg)
	px.box(0, 0, size.x, size.y, BLACK)
	var s: String = Kit.text_of(p, "text", "NEW")
	var tw: int = Px.text_width(s)
	px.text((size.x - tw) / 2 + 1, 4, s, ink.darkened(0.55))
	px.text((size.x - tw) / 2, 3, s, ink)
	return px


static func globe(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var r: float = float(mini(size.x, size.y)) * 0.5 - 1.5
	var cx: float = float(size.x) * 0.5
	var cy: float = float(size.y) * 0.5
	var rot: float = TAU * float(f) / float(n)
	var light: Vector3 = Vector3(-0.55, -0.6, 0.6).normalized()
	for y: int in size.y:
		for x: int in size.x:
			var nx: float = (float(x) + 0.5 - cx) / r
			var ny: float = (float(y) + 0.5 - cy) / r
			var d2: float = nx * nx + ny * ny
			if d2 > 1.0:
				continue
			var nz: float = sqrt(1.0 - d2)
			var lat: float = asin(clampf(-ny, -1.0, 1.0))
			var lon: float = atan2(nx, nz) + rot
			var u: float = fposmod(lon / TAU, 1.0) * 64.0
			var v: float = (lat / PI + 0.5) * 32.0
			var land: float = Px.tile_fbm(u, v, 64, 32, 4, 3, 7)
			var l: float = clampf(Vector3(nx, ny, nz).dot(light) * 0.8 + 0.25, 0.0, 1.0)
			var c: Color
			if absf(lat) > 1.22:
				c = Px.pick([Color8(153, 170, 204), Color8(221, 238, 255), WHITE], l, x, y)
			elif land > 0.53:
				c = Px.pick([Color8(0, 68, 0), Color8(34, 136, 34), Color8(102, 187, 51), Color8(204, 204, 102)], l * (0.8 + (land - 0.53) * 2.0), x, y)
			else:
				c = Px.pick([Color8(0, 0, 68), Color8(0, 51, 153), Color8(0, 102, 204), Color8(102, 170, 255)], l, x, y)
			px.put_px(x, y, c)
	px.outlined(Color8(0, 0, 34), false)
	return px


static func arrows(p: Dictionary, f: int, n: int) -> Px:
	var base_w: int = 40
	var base_h: int = 24
	var px: Px = Px.new(base_w, base_h)
	var col: Color = Kit.colour(p, "colour_a", Color(1.0, 0.8, 0.0))
	var bounce: Array = [0, 1, 3, 5, 6, 5, 3, 1]
	var dx: float = float(bounce[f * 8 / maxi(n, 1)])
	var shape: Px = Px.new(base_w, base_h)
	shape.poly(PackedVector2Array([Vector2(2.0 + dx, 8.0), Vector2(18.0 + dx, 8.0), Vector2(18.0 + dx, 2.0), Vector2(31.0 + dx, 12.0), Vector2(18.0 + dx, 22.0), Vector2(18.0 + dx, 16.0), Vector2(2.0 + dx, 16.0)]), col)
	for y: int in base_h:
		for x: int in base_w:
			if shape.alpha_at(x, y) == 0:
				continue
			if y <= 9 and shape.alpha_at(x, y - 1) == 0:
				shape.put_px(x, y, col.lerp(WHITE, 0.6))
			elif y > 13:
				shape.put_px(x, y, Px.websafe(col.darkened(0.25), x, y))
	shape.outlined(BLACK, false)
	px.blit(shape, 0, 0)
	var dir: String = String(p.get("direction", "right"))
	if dir == "left":
		return Kit.mirrored(px, true, false)
	if dir == "down":
		return Kit.turned(px)
	if dir == "up":
		return Kit.mirrored(Kit.turned(px), false, true)
	return px


static func webring(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, GREY)
	px.button3d(0, 0, size.x, size.y, GREY)
	for y: int in range(3, 16):
		for x: int in range(3, size.x - 3):
			px.put_px(x, y, Px.websafe(Color8(0, 0, 102).lerp(Color8(102, 0, 153), float(x) / float(size.x)), x, y))
	var name: String = "~ " + Kit.text_of(p, "text", "Webring") + " ~"
	Kit.fit_text(px, 20, size.x - 20, 5, name, WHITE)
	for k: int in 8:
		var a: float = TAU * float(k) / 8.0
		var lit: bool = k == posmod(f, 8)
		var c: Color = Color8(255, 255, 0) if lit else Color8(153, 153, 204)
		px.put_px(10 + int(round(cos(a) * 4.0)), 9 + int(round(sin(a) * 4.0)), c)
		px.put_px(size.x - 11 + int(round(cos(-a) * 4.0)), 9 + int(round(sin(-a) * 4.0)), Color8(255, 255, 0) if k == posmod(-f, 8) else Color8(153, 153, 204))
	var labels: PackedStringArray = ["<< Prev", "Random", "List", "Next >>"]
	var bw: int = (size.x - 10 - 3 * 4) / 4
	for i: int in labels.size():
		var bx: int = 5 + i * (bw + 4)
		px.button3d(bx, 20, bw, 17, GREY)
		px.text_centred(bx + bw / 2, 25, labels[i], Color8(0, 0, 0))
	return px


static func marquee_text(p: Dictionary) -> String:
	return Kit.text_of(p, "text", "Welcome!")


static func marquee_frames(p: Dictionary, width: int = 300) -> int:
	var step: int = clampi(int(p.get("step", 1)), 1, 16)
	var tw: int = Px.text_width(marquee_text(p))
	return maxi(int(ceil(float(tw + width) / float(step))), 1)


static func flows_right(p: Dictionary) -> bool:
	return String(p.get("flow", "left")) == "right"


static func marquee(p: Dictionary, f: int, size: Vector2i) -> Px:
	var bg: Color = Kit.colour(p, "colour_b", Color(0.0, 0.0, 0.2))
	var ink: Color = Kit.colour(p, "colour_a", Color(1.0, 1.0, 0.0))
	var px: Px = Px.new(size.x, size.y, bg)
	px.bevel(0, 0, size.x, size.y, Color8(128, 128, 128), WHITE, false, 1)
	var s: String = marquee_text(p)
	var step: int = clampi(int(p.get("step", 1)), 1, 16)
	var tw: int = Px.text_width(s)
	var span: int = tw + size.x
	var x: int = size.x - posmod(f * step + size.x - 6, span)
	if flows_right(p):
		x = posmod(f * step + size.x - 6, span) - tw
	var line: Px = Px.new(size.x - 2, size.y - 2)
	line.text(x - 1, 2, s, ink)
	px.blit(line, 1, 1)
	return px


static func guestbook(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var cx: int = size.x / 2
	var book: Px = Px.new(size.x, size.y)
	book.poly(PackedVector2Array([Vector2(float(cx) - 40.0, 10.0), Vector2(float(cx), 6.0), Vector2(float(cx), 44.0), Vector2(float(cx) - 40.0, 46.0)]), Color8(119, 51, 17))
	book.poly(PackedVector2Array([Vector2(float(cx), 6.0), Vector2(float(cx) + 40.0, 10.0), Vector2(float(cx) + 40.0, 46.0), Vector2(float(cx), 44.0)]), Color8(119, 51, 17))
	book.poly(PackedVector2Array([Vector2(float(cx) - 37.0, 9.0), Vector2(float(cx), 5.0), Vector2(float(cx), 42.0), Vector2(float(cx) - 37.0, 43.0)]), Color8(255, 255, 238))
	book.poly(PackedVector2Array([Vector2(float(cx), 5.0), Vector2(float(cx) + 37.0, 9.0), Vector2(float(cx) + 37.0, 43.0), Vector2(float(cx), 42.0)]), Color8(255, 255, 238))
	for ly: int in range(15, 40, 5):
		book.hline(cx - 33, cx - 4, ly, Color8(204, 204, 238))
		book.hline(cx + 4, cx + 33, ly, Color8(204, 204, 238))
	for ly2: int in range(14, 34, 5):
		for x: int in range(cx - 32, cx - 6):
			if Px.hash01(x / 2, ly2, 3) > 0.35:
				book.put_px(x, ly2 + (1 if Px.hash01(x, ly2, 4) > 0.7 else 0), Color8(51, 51, 153))
	var t: float = float(f) / float(n)
	var pen_x: int = cx + 6 + int(t * 26.0)
	for x2: int in range(cx + 5, pen_x):
		if Px.hash01(x2 / 2, 29, 9) > 0.3:
			book.put_px(x2, 29 + (1 if (x2 / 2) % 2 == 0 else 0), Color8(51, 51, 153))
	book.vline(cx, 5, 43, Color8(170, 136, 102))
	book.outlined(Color8(51, 17, 0), false)
	px.blit(book, 0, 0)
	var bob: int = 1 if f % 2 == 0 else 0
	var quill: Px = Px.new(size.x, size.y)
	quill.thick_line(float(pen_x), 28.0 - float(bob), float(pen_x) + 10.0, 6.0 - float(bob), 1.3, WHITE)
	quill.thick_line(float(pen_x) + 4.0, 18.0 - float(bob), float(pen_x) + 12.0, 4.0 - float(bob), 2.2, Color8(238, 238, 255))
	quill.outlined(Color8(68, 68, 102), false)
	px.blit(quill, 0, 0)
	px.put_px(pen_x, 29, BLACK)
	var ribbon: Px = Px.new(size.x, size.y)
	var ry: int = 52
	ribbon.poly(PackedVector2Array([Vector2(2.0, float(ry)), Vector2(14.0, float(ry)), Vector2(14.0, float(ry) + 14.0), Vector2(2.0, float(ry) + 14.0), Vector2(7.0, float(ry) + 7.0)]), Color8(204, 51, 51))
	ribbon.poly(PackedVector2Array([Vector2(float(size.x) - 2.0, float(ry)), Vector2(float(size.x) - 14.0, float(ry)), Vector2(float(size.x) - 14.0, float(ry) + 14.0), Vector2(float(size.x) - 2.0, float(ry) + 14.0), Vector2(float(size.x) - 7.0, float(ry) + 7.0)]), Color8(204, 51, 51))
	ribbon.rect(8, ry - 3, size.x - 16, 15, Color8(255, 102, 102))
	ribbon.hline(8, size.x - 9, ry - 3, Color8(255, 170, 170))
	ribbon.hline(8, size.x - 9, ry + 11, Color8(204, 51, 51))
	ribbon.outlined(Color8(102, 0, 0), false)
	px.blit(ribbon, 0, 0)
	Kit.fit_text(px, 10, size.x - 10, ry + 1, Kit.text_of(p, "text", "Sign my Guestbook!"), WHITE, true)
	return px


static func trail_point(t: float, size: Vector2i) -> Vector2:
	var a: float = TAU * t
	return Vector2(float(size.x) * 0.5 + sin(a) * float(size.x) * 0.36, float(size.y) * 0.5 + sin(a * 2.0) * float(size.y) * 0.3)


static func cursor_trail(f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var t: float = float(f) / float(n)
	for k: int in range(14, 0, -1):
		var at: Vector2 = trail_point(t - float(k) * 0.011, size)
		var hue: float = fposmod(float(k) * 0.07 + t * 2.0, 1.0)
		var c: Color = Color.from_hsv(hue, 0.7, 1.0)
		c = Color(round(c.r * 5.0) / 5.0, round(c.g * 5.0) / 5.0, round(c.b * 5.0) / 5.0)
		var arm: int = clampi(4 - k / 3, 0, 4)
		var tw: int = posmod(f + k, 3)
		var jx: int = int(round((Px.hash01(k, f, 3) - 0.5) * 6.0))
		var jy: int = int(round((Px.hash01(k, f, 4) - 0.5) * 6.0))
		if arm > 0:
			Kit.sparkle(px, int(at.x) + jx, int(at.y) + jy + 8, arm - (1 if tw == 0 else 0), WHITE, c)
		else:
			px.put_px(int(at.x) + jx, int(at.y) + jy + 8, c)
	var head: Vector2 = trail_point(t, size)
	Kit.cursor(px, int(head.x), int(head.y))
	return px


static func bubble_lines(p: Dictionary) -> PackedStringArray:
	return Px.wrap(Kit.text_of(p, "text", "Hello!"), BUBBLE_MAX_TEXT)


static func bubble_size(p: Dictionary) -> Vector2i:
	var lines: PackedStringArray = bubble_lines(p)
	var tw: int = 8
	for l: String in lines:
		tw = maxi(tw, Px.text_width(l))
	return Vector2i(tw + 14, lines.size() * Px.LINE_H + 10 + 9)


static func tail_tip(p: Dictionary, w: int) -> int:
	return clampi(int(p.get("tail_x", 7)), 3, maxi(w - 4, 3))


static func bubble(p: Dictionary, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var ink: Color = Kit.colour(p, "colour_a", BLACK)
	var paper: Color = Kit.colour(p, "colour_b", WHITE)
	var body_h: int = size.y - 9
	var shape: Px = Px.new(size.x, size.y)
	shape.rect(1, 4, size.x - 2, body_h - 7, paper)
	shape.rect(4, 1, size.x - 8, body_h - 1, paper)
	shape.rect(2, 2, size.x - 4, body_h - 3, paper)
	var tip: float = float(tail_tip(p, size.x))
	var near: float = 5.0 if tip < float(size.x) * 0.5 else -5.0
	var far: float = 17.0 if tip < float(size.x) * 0.5 else -17.0
	shape.poly(PackedVector2Array([Vector2(tip + near, float(body_h) - 2.0), Vector2(tip + far, float(body_h) - 2.0), Vector2(tip, float(size.y) - 1.0)]), paper)
	for y: int in size.y:
		for x: int in size.x:
			if shape.alpha_at(x, y) == 0:
				continue
			var edge: bool = shape.alpha_at(x - 1, y) == 0 or shape.alpha_at(x + 1, y) == 0 or shape.alpha_at(x, y - 1) == 0 or shape.alpha_at(x, y + 1) == 0
			if edge:
				px.put_px(x, y, ink)
			else:
				px.put_px(x, y, paper)
	var lines: PackedStringArray = bubble_lines(p)
	for i: int in lines.size():
		px.text_centred(size.x / 2, 5 + i * Px.LINE_H, lines[i], ink)
	return px


static func stamp(kind: String, p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	if bool(p.get("framed", true)):
		px.fill(Color8(51, 34, 119))
		px.bevel(0, 0, size.x, size.y, Color8(170, 153, 255), Color8(17, 0, 51), true, 2)
		px.box(0, 0, size.x, size.y, BLACK)
	var art: Px = Px.new(size.x, size.y)
	var cx: int = size.x / 2
	var cy: int = size.y / 2
	if kind == "star":
		art.poly(Kit.star_points(float(cx), float(cy) + 1.0, 12.0, 5.0, 5), Color8(255, 204, 0))
		for y: int in size.y:
			for x: int in size.x:
				if art.alpha_at(x, y) > 0:
					art.put_px(x, y, Px.pick([Color8(255, 255, 153), Color8(255, 204, 0), Color8(255, 136, 0)], float(y - cy + 11) / 22.0, x, y))
		art.outlined(Color8(102, 51, 0), false)
		art.put_px(cx - 1, cy - 5, WHITE)
		art.put_px(cx - 1, cy - 4, WHITE)
	elif kind == "eye":
		var lid: float = 0.0
		var phase: int = f * 8 / n
		if phase == 6:
			lid = 1.0
		elif phase == 5 or phase == 7:
			lid = 0.5
		art.ellipse(float(cx), float(cy), 12.0, 7.5, WHITE)
		for y2: int in size.y:
			for x2: int in size.x:
				if art.alpha_at(x2, y2) > 0 and y2 > cy + 3:
					art.put_px(x2, y2, Color8(221, 221, 238))
		art.disc(float(cx), float(cy), 5.2, Color8(204, 0, 0))
		art.ring(float(cx), float(cy), 5.2, 1.0, Color8(119, 0, 0))
		art.disc(float(cx), float(cy), 2.3, BLACK)
		art.rect(cx - 3, cy - 3, 2, 2, WHITE)
		if lid > 0.0:
			var cover: int = int(round(float(cy) - 8.0 + 16.0 * lid * 0.95))
			for y4: int in range(cy - 8, cover):
				for x4: int in size.x:
					if art.alpha_at(x4, y4) > 0:
						art.put_px(x4, y4, Color8(238, 187, 153))
			art.hline(cx - 10, cx + 10, cover, Color8(102, 51, 51))
		art.outlined(BLACK, false)
	elif kind == "check":
		art.thick_line(7.0, 16.0, 13.0, 23.0, 3.0, Color8(0, 204, 0))
		art.thick_line(13.0, 23.0, 25.0, 8.0, 3.0, Color8(0, 204, 0))
		art.thick_line(7.0, 15.0, 13.0, 21.0, 0.8, Color8(153, 255, 102))
		art.thick_line(13.0, 21.0, 24.0, 7.0, 0.8, Color8(153, 255, 102))
		art.outlined(Color8(0, 68, 0), false)
	elif kind == "coin":
		var th: float = TAU * float(f) / float(n)
		var k: float = absf(cos(th))
		var rx: float = maxf(11.0 * k, 1.5)
		art.ellipse(float(cx), float(cy), rx, 11.0, Color8(204, 153, 0))
		if rx > 3.0:
			art.ellipse(float(cx), float(cy), rx - 2.0, 9.0, Color8(255, 204, 0))
			for y5: int in size.y:
				for x5: int in size.x:
					var cc: Color = art.get_px(x5, y5)
					if cc == Color8(255, 204, 0) and float(x5) < float(cx) - rx * 0.3 and y5 < cy:
						art.put_px(x5, y5, Color8(255, 255, 153))
			if k > 0.55:
				art.poly(Kit.star_points(float(cx), float(cy) + 0.5, 5.5 * k, 2.4 * k, 5, 0.0, 1.0 / maxf(k, 0.3)), Color8(204, 136, 0))
		art.outlined(Color8(102, 51, 0), false)
		if f % 4 == 0 and rx > 6.0:
			Kit.sparkle(art, cx - int(rx * 0.5), cy - 6, 2, WHITE, Color8(255, 255, 204))
	elif kind == "house":
		art.rect(cx - 7, cy - 10, 3, 6, Color8(136, 68, 34))
		art.poly(PackedVector2Array([Vector2(float(cx) - 12.0, float(cy)), Vector2(float(cx), float(cy) - 11.0), Vector2(float(cx) + 12.0, float(cy))]), Color8(204, 34, 34))
		art.rect(cx - 9, cy, 18, 11, Color8(238, 204, 136))
		art.rect(cx - 3, cy + 4, 5, 7, Color8(136, 68, 17))
		art.put_px(cx + 1, cy + 7, Color8(255, 204, 0))
		art.rect(cx + 4, cy + 2, 4, 4, Color8(153, 221, 255))
		art.put_px(cx + 5, cy + 3, WHITE)
		art.hline(cx - 11, cx + 11, cy, Color8(136, 17, 17))
		art.outlined(BLACK, false)
	elif kind == "skull":
		art.ellipse(float(cx), float(cy) - 2.0, 10.5, 9.5, Color8(238, 238, 221))
		art.rect(cx - 6, cy + 5, 13, 7, Color8(238, 238, 221))
		for y6: int in size.y:
			for x6: int in size.x:
				if art.alpha_at(x6, y6) > 0 and (x6 > cx + 4 or y6 > cy + 7):
					art.put_px(x6, y6, Color8(187, 187, 170))
		art.ellipse(float(cx) - 4.5, float(cy) - 1.0, 3.2, 3.6, BLACK)
		art.ellipse(float(cx) + 5.0, float(cy) - 1.0, 3.2, 3.6, BLACK)
		art.put_px(cx - 5, cy - 2, Color8(204, 0, 0))
		art.put_px(cx + 4, cy - 2, Color8(204, 0, 0))
		art.poly(PackedVector2Array([Vector2(float(cx), float(cy) + 3.0), Vector2(float(cx) + 2.0, float(cy) + 6.0), Vector2(float(cx) - 1.0, float(cy) + 6.0)]), BLACK)
		for tx: int in range(cx - 5, cx + 7, 2):
			art.vline(tx, cy + 8, cy + 11, Color8(102, 102, 85))
		art.outlined(BLACK, false)
	elif kind == "no":
		art.disc(float(cx), float(cy), 12.0, WHITE)
		art.ring(float(cx), float(cy), 12.0, 3.4, Color8(221, 0, 0))
		art.thick_line(float(cx) - 7.5, float(cy) - 7.5, float(cx) + 7.5, float(cy) + 7.5, 1.8, Color8(221, 0, 0))
		art.outlined(Color8(102, 0, 0), false)
	elif kind == "arrow":
		art.rect(cx - 4, 4, 9, 13, Color8(51, 204, 51))
		art.poly(PackedVector2Array([Vector2(float(cx) - 11.0, 16.0), Vector2(float(cx) + 12.0, 16.0), Vector2(float(cx) + 0.5, 28.0)]), Color8(51, 204, 51))
		for y7: int in size.y:
			for x7: int in size.x:
				if art.alpha_at(x7, y7) > 0:
					art.put_px(x7, y7, Px.pick([Color8(153, 255, 102), Color8(51, 204, 51), Color8(0, 119, 0)], float(x7 - cx + 10) / 20.0, x7, y7))
		art.outlined(Color8(0, 51, 0), false)
	else:
		Kit.smiley(art, cx, cy, kind)
	px.blit(art, 0, 0)
	return px
