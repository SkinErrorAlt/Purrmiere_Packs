extends RefCounted

const Px := preload("old_web_px.gd")
const Kit := preload("old_web_kit.gd")
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const FACE := Color8(192, 192, 192)
const SHADE := Color8(128, 128, 128)
const LIGHT := Color8(223, 223, 223)
const BAND := 9
const SPACING := 8
const SPACING_MIN := 4
const SPACING_MAX := 32
const CELLS_MAX := 8
const CELL_GAP := 3
const CHROME_TOP := 83
const CHROME_BOTTOM := 18
const TITLE_H := 14


static func paint(id: String, p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	if id == "win_browser":
		return browser(p, f, n, size)
	if id == "win_dialog":
		return dialog(p, size)
	if id == "frame_pixel":
		return pixel_frame(p, f, n, size)
	if id == "table_cell":
		return table(p, size)
	return Px.new(size.x, size.y)


static func inner_rect(id: String, size: Vector2i) -> Rect2i:
	if id == "win_browser":
		return Rect2i(5, CHROME_TOP, size.x - 24, size.y - CHROME_TOP - CHROME_BOTTOM)
	if id == "win_dialog":
		return Rect2i(3, 3 + TITLE_H + 1, size.x - 6, size.y - TITLE_H - 7)
	if id == "frame_pixel":
		return Rect2i(BAND, BAND, size.x - BAND * 2, size.y - BAND * 2)
	if id == "table_cell":
		return Rect2i(3, 3, size.x - 6, size.y - 6)
	return Rect2i(Vector2i.ZERO, size)


static func see_through(id: String, p: Dictionary) -> bool:
	if id == "win_browser" or id == "frame_pixel":
		return true
	return id == "table_cell" and not bool(p.get("filled", true))


static func title_rect(id: String, size: Vector2i) -> Rect2i:
	if id == "win_browser" or id == "win_dialog":
		return Rect2i(3, 3, size.x - 6, TITLE_H)
	return Rect2i()


static func spacing_of(p: Dictionary) -> int:
	return clampi(int(p.get("spacing", SPACING)), SPACING_MIN, SPACING_MAX)


static func grid_of(p: Dictionary) -> Vector2i:
	return Vector2i(clampi(int(p.get("cols", 2)), 1, CELLS_MAX), clampi(int(p.get("rows", 2)), 1, CELLS_MAX))


static func cell_rect(p: Dictionary, size: Vector2i, col: int, row: int) -> Rect2i:
	var g: Vector2i = grid_of(p)
	var cw: int = maxi((size.x - 6 - CELL_GAP * (g.x + 1)) / g.x, 1)
	var ch: int = maxi((size.y - 6 - CELL_GAP * (g.y + 1)) / g.y, 1)
	return Rect2i(3 + CELL_GAP + col * (cw + CELL_GAP), 3 + CELL_GAP + row * (ch + CELL_GAP), cw, ch)


static func window_edge(px: Px, x: int, y: int, w: int, h: int) -> void:
	px.hline(x, x + w - 2, y, LIGHT)
	px.vline(x, y, y + h - 2, LIGHT)
	px.hline(x + 1, x + w - 3, y + 1, WHITE)
	px.vline(x + 1, y + 1, y + h - 3, WHITE)
	px.hline(x, x + w - 1, y + h - 1, BLACK)
	px.vline(x + w - 1, y, y + h - 1, BLACK)
	px.hline(x + 1, x + w - 2, y + h - 2, SHADE)
	px.vline(x + w - 2, y + 1, y + h - 2, SHADE)


static func sunken(px: Px, x: int, y: int, w: int, h: int) -> void:
	px.hline(x, x + w - 1, y, SHADE)
	px.vline(x, y, y + h - 1, SHADE)
	px.hline(x + 1, x + w - 2, y + 1, Color8(64, 64, 64))
	px.vline(x + 1, y + 1, y + h - 2, Color8(64, 64, 64))
	px.hline(x, x + w - 1, y + h - 1, WHITE)
	px.vline(x + w - 1, y, y + h - 1, WHITE)
	px.hline(x + 1, x + w - 2, y + h - 2, LIGHT)
	px.vline(x + w - 2, y + 1, y + h - 2, LIGHT)


static func title_bar(px: Px, x: int, y: int, w: int, h: int, tint: Color, title: String) -> void:
	var a: Color = tint.darkened(0.35)
	var b: Color = tint.lerp(Color(0.85, 0.55, 1.0), 0.55)
	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			px.put_px(xx, yy, Px.websafe(a.lerp(b, float(xx - x) / float(maxi(w - 1, 1))), xx, yy))
	var room: int = w - 44
	var shown: String = title
	while shown.length() > 1 and Px.text_width(shown) + 1 > room:
		shown = shown.substr(0, shown.length() - 1)
	px.text(x + 14, y + (h - 7) / 2, shown, WHITE)
	px.text(x + 15, y + (h - 7) / 2, shown, WHITE)
	px.rect(x + 3, y + 2, 8, h - 4, Color8(255, 255, 204))
	px.box(x + 3, y + 2, 8, h - 4, Color8(102, 102, 102))
	px.hline(x + 5, x + 8, y + 5, Color8(0, 0, 204))
	px.hline(x + 5, x + 7, y + 7, Color8(0, 0, 204))
	px.hline(x + 5, x + 8, y + 9, Color8(0, 0, 204))


static func control_button(px: Px, x: int, y: int, kind: String) -> void:
	px.button3d(x, y, 12, 11, FACE)
	if kind == "min":
		px.hline(x + 3, x + 7, y + 7, BLACK)
		px.hline(x + 3, x + 7, y + 8, BLACK)
	elif kind == "max":
		px.box(x + 2, y + 2, 8, 7, BLACK)
		px.hline(x + 2, x + 9, y + 3, BLACK)
	else:
		for k: int in 5:
			px.put_px(x + 3 + k, y + 3 + k, BLACK)
			px.put_px(x + 4 + k, y + 3 + k, BLACK)
			px.put_px(x + 7 - k, y + 3 + k, BLACK)
			px.put_px(x + 8 - k, y + 3 + k, BLACK)


static func tool_icon(px: Px, x: int, y: int, kind: String, f: int) -> void:
	px.button3d(x, y, 24, 22, FACE)
	var cx: float = 12.0
	var cy: float = 11.0
	var icon: Px = Px.new(24, 22)
	if kind == "back" or kind == "forward":
		var s: float = -1.0 if kind == "back" else 1.0
		icon.poly(PackedVector2Array([Vector2(cx - 7.0 * s, cy - 2.0), Vector2(cx, cy - 2.0), Vector2(cx, cy - 7.0), Vector2(cx + 7.0 * s, cy), Vector2(cx, cy + 7.0), Vector2(cx, cy + 2.0), Vector2(cx - 7.0 * s, cy + 2.0)]), Color8(0, 153, 102) if kind == "back" else Color8(0, 102, 204))
	elif kind == "stop":
		icon.poly(PackedVector2Array([Vector2(cx - 3.0, cy - 7.0), Vector2(cx + 3.0, cy - 7.0), Vector2(cx + 7.0, cy - 3.0), Vector2(cx + 7.0, cy + 3.0), Vector2(cx + 3.0, cy + 7.0), Vector2(cx - 3.0, cy + 7.0), Vector2(cx - 7.0, cy + 3.0), Vector2(cx - 7.0, cy - 3.0)]), Color8(204, 0, 0))
		icon.thick_line(cx - 3.0, cy - 3.0, cx + 3.0, cy + 3.0, 0.9, WHITE)
		icon.thick_line(cx + 3.0, cy - 3.0, cx - 3.0, cy + 3.0, 0.9, WHITE)
	elif kind == "reload":
		icon.ring(cx, cy, 7.0, 2.2, Color8(0, 153, 0))
		icon.clear_rect(int(cx), int(cy) - 8, 8, 6)
		icon.poly(PackedVector2Array([Vector2(cx, cy - 9.0), Vector2(cx + 5.0, cy - 5.5), Vector2(cx, cy - 2.0)]), Color8(0, 153, 0))
	elif kind == "home":
		icon.poly(PackedVector2Array([Vector2(cx - 8.0, cy), Vector2(cx, cy - 8.0), Vector2(cx + 8.0, cy)]), Color8(204, 51, 0))
		icon.rect(int(cx) - 6, int(cy), 12, 7, Color8(255, 238, 187))
		icon.rect(int(cx) - 1, int(cy) + 2, 3, 5, Color8(119, 68, 17))
	elif kind == "search":
		icon.ring(cx - 2.0, cy - 2.0, 5.0, 1.6, Color8(51, 51, 51))
		icon.disc(cx - 2.0, cy - 2.0, 3.4, Color8(153, 221, 255))
		icon.thick_line(cx + 2.0, cy + 2.0, cx + 6.0, cy + 6.0, 1.4, Color8(119, 68, 17))
	icon.outlined(Color8(34, 34, 34), false)
	px.blit(icon, x, y)


static func throbber(px: Px, x: int, y: int, w: int, h: int, f: int, n: int) -> void:
	px.rect(x, y, w, h, Color8(0, 0, 0))
	px.box(x, y, w, h, SHADE)
	var cx: float = float(x) + float(w) * 0.5
	var cy: float = float(y) + float(h) * 0.5
	for k: int in 8:
		var a: float = TAU * float(k) / 8.0
		var age: int = posmod(f * 8 / n - k, 8)
		var c: Color = [Color8(255, 255, 255), Color8(255, 153, 255), Color8(204, 51, 204), Color8(119, 0, 153), Color8(51, 0, 85), Color8(34, 0, 51), Color8(17, 0, 34), Color8(17, 0, 34)][age]
		px.rect(int(round(cx + cos(a) * 6.0)) - 1, int(round(cy + sin(a) * 6.0)) - 1, 2, 2, c)
	px.put_px(int(cx), int(cy), Color8(255, 255, 102))


static func browser(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, FACE)
	window_edge(px, 0, 0, size.x, size.y)
	var tint: Color = Kit.colour(p, "colour_a", Color(0.4, 0.0, 0.6))
	title_bar(px, 3, 3, size.x - 6, 14, tint, Kit.text_of(p, "text", "My Cool Homepage"))
	control_button(px, size.x - 45, 4, "min")
	control_button(px, size.x - 32, 4, "max")
	control_button(px, size.x - 17, 4, "close")
	var my: int = 20
	var mx: int = 7
	for word: String in ["File", "Edit", "View", "Go", "Help"]:
		var ww: int = px.text(mx, my + 1, word, BLACK)
		px.hline(mx, mx + Px.glyph_width(word.substr(0, 1), false) - 1, my + 9, BLACK)
		mx += ww + 9
	px.hline(3, size.x - 4, 31, SHADE)
	px.hline(3, size.x - 4, 32, WHITE)
	var tx: int = 6
	for kind: String in ["back", "forward", "stop", "reload", "home", "search"]:
		tool_icon(px, tx, 35, kind, f)
		tx += 26
		if kind == "forward" or kind == "home":
			px.vline(tx, 36, 56, SHADE)
			px.vline(tx + 1, 36, 56, WHITE)
			tx += 4
	throbber(px, size.x - 32, 34, 26, 24, f, n)
	px.hline(3, size.x - 4, 60, SHADE)
	px.hline(3, size.x - 4, 61, WHITE)
	px.text(6, 66, "Address", BLACK)
	var fx: int = 48
	var fw: int = size.x - fx - 34
	px.rect(fx, 63, fw, 14, WHITE)
	sunken(px, fx, 63, fw, 14)
	px.rect(fx + 3, 66, 8, 8, Color8(255, 255, 204))
	px.box(fx + 3, 66, 8, 8, Color8(0, 102, 204))
	var url: String = Kit.text_of(p, "text2", "http://www.example.com/~me/")
	var line: Px = Px.new(fw - 30, 10)
	line.text(0, 1, url, BLACK)
	px.blit(line, fx + 14, 65)
	px.button3d(fx + fw - 13, 65, 11, 10, FACE)
	px.poly(PackedVector2Array([Vector2(float(fx + fw) - 10.0, 68.0), Vector2(float(fx + fw) - 5.0, 68.0), Vector2(float(fx + fw) - 7.5, 71.0)]), BLACK)
	px.button3d(size.x - 31, 63, 26, 14, FACE)
	px.text(size.x - 25, 66, "Go", BLACK)
	var top: int = 81
	var bottom: int = size.y - 16
	sunken(px, 3, top, size.x - 6, bottom - top)
	px.clear_rect(5, top + 2, size.x - 10 - 14, bottom - top - 4)
	var sx: int = size.x - 5 - 14
	for yy: int in range(top + 2, bottom - 2):
		for xx: int in range(sx, sx + 14):
			px.put_px(xx, yy, WHITE if (xx + yy) % 2 == 0 else LIGHT)
	px.button3d(sx, top + 2, 14, 14, FACE)
	px.poly(PackedVector2Array([Vector2(float(sx) + 3.5, float(top) + 11.0), Vector2(float(sx) + 10.5, float(top) + 11.0), Vector2(float(sx) + 7.0, float(top) + 6.0)]), BLACK)
	px.button3d(sx, bottom - 16, 14, 14, FACE)
	px.poly(PackedVector2Array([Vector2(float(sx) + 3.5, float(bottom) - 11.0), Vector2(float(sx) + 10.5, float(bottom) - 11.0), Vector2(float(sx) + 7.0, float(bottom) - 6.0)]), BLACK)
	px.button3d(sx, top + 17, 14, 34, FACE)
	sunken(px, 4, size.y - 14, size.x - 90, 11)
	sunken(px, size.x - 84, size.y - 14, 80, 11)
	px.text(8, size.y - 12, "Done" if f >= n / 2 else "Opening page...", BLACK)
	px.disc(float(size.x) - 76.0, float(size.y) - 8.5, 3.5, Color8(0, 102, 204))
	px.put_px(size.x - 78, size.y - 10, Color8(0, 204, 0))
	px.put_px(size.x - 76, size.y - 8, Color8(0, 204, 0))
	px.text(size.x - 69, size.y - 12, "Online", BLACK)
	return px


static func dialog(p: Dictionary, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, FACE)
	window_edge(px, 0, 0, size.x, size.y)
	var tint: Color = Kit.colour(p, "colour_a", Color(0.4, 0.0, 0.6))
	title_bar(px, 3, 3, size.x - 6, 14, tint, Kit.text_of(p, "text", "Message"))
	control_button(px, size.x - 17, 4, "close")
	var icon: Px = Px.new(28, 26)
	icon.poly(PackedVector2Array([Vector2(13.0, 1.0), Vector2(15.0, 1.0), Vector2(27.0, 24.0), Vector2(1.0, 24.0)]), Color8(255, 204, 0))
	for y: int in 26:
		for x: int in 28:
			if icon.alpha_at(x, y) > 0 and x < 14 and y < 14:
				icon.put_px(x, y, Color8(255, 255, 102))
	icon.outlined(BLACK, false)
	icon.rect(13, 7, 3, 10, BLACK)
	icon.rect(13, 19, 3, 3, BLACK)
	px.blit(Kit.shadow_of(icon, SHADE), 12, 28)
	px.blit(icon, 10, 26)
	var lines: PackedStringArray = Px.wrap(Kit.text_of(p, "text2", "Are you sure?"), size.x - 52)
	var ty: int = 25
	for l: String in lines:
		if ty > size.y - 30:
			break
		px.text(44, ty, l, BLACK)
		ty += Px.LINE_H
	var bw: int = 54
	var by: int = size.y - 22
	var ok_x: int = size.x / 2 - bw - 4
	var cancel_x: int = size.x / 2 + 4
	px.box(ok_x - 1, by - 1, bw + 2, 18, BLACK)
	px.button3d(ok_x, by, bw, 16, FACE)
	px.text_centred(ok_x + bw / 2, by + 4, "OK", BLACK)
	for k: int in range(ok_x + 4, ok_x + bw - 4, 2):
		px.put_px(k, by + 3, BLACK)
		px.put_px(k, by + 12, BLACK)
	for k2: int in range(by + 3, by + 13, 2):
		px.put_px(ok_x + 4, k2, BLACK)
		px.put_px(ok_x + bw - 5, k2, BLACK)
	px.button3d(cancel_x, by, bw, 16, FACE)
	px.text_centred(cancel_x + bw / 2, by + 4, "Cancel", BLACK)
	return px


static func pixel_frame(p: Dictionary, f: int, n: int, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var band: Color = Kit.colour(p, "colour_a", Color(0.6, 0.0, 0.6))
	var gem: Color = Kit.colour(p, "colour_b", Color(1.0, 0.8, 0.0))
	var t: int = BAND
	for y: int in size.y:
		for x: int in size.x:
			var d: int = mini(mini(x, y), mini(size.x - 1 - x, size.y - 1 - y))
			if d >= t:
				continue
			var c: Color = band
			if d == 0 or d == t - 1:
				c = BLACK
			elif d == 1:
				c = band.lerp(WHITE, 0.55)
			elif d == t - 2:
				c = band.darkened(0.5)
			px.put_px(x, y, c)
	var perimeter: int = 2 * (size.x + size.y - 2 * t)
	var spacing: int = spacing_of(p)
	var count: int = perimeter / spacing
	for i: int in count:
		var s: int = i * spacing
		var pos: Vector2i
		var inset: int = t / 2
		var wlen: int = size.x - 2 * inset
		var hlen: int = size.y - 2 * inset
		if s < wlen:
			pos = Vector2i(inset + s, inset)
		elif s < wlen + hlen:
			pos = Vector2i(size.x - 1 - inset, inset + s - wlen)
		elif s < 2 * wlen + hlen:
			pos = Vector2i(size.x - 1 - inset - (s - wlen - hlen), size.y - 1 - inset)
		else:
			pos = Vector2i(inset, size.y - 1 - inset - (s - 2 * wlen - hlen))
		var lit: bool = posmod(i - f, 4) == 0
		var bulb: Color = Color8(255, 255, 204) if lit else band.darkened(0.25).lerp(gem, 0.25)
		px.rect(pos.x - 1, pos.y - 1, 3, 3, bulb)
		if lit:
			px.put_px(pos.x, pos.y, WHITE)
	for corner: Vector2i in [Vector2i(t / 2, t / 2), Vector2i(size.x - 1 - t / 2, t / 2), Vector2i(t / 2, size.y - 1 - t / 2), Vector2i(size.x - 1 - t / 2, size.y - 1 - t / 2)]:
		var diamond: PackedVector2Array = PackedVector2Array([Vector2(8.5, 2.0), Vector2(15.0, 8.5), Vector2(8.5, 15.0), Vector2(2.0, 8.5)])
		var dm: Px = Px.new(17, 17)
		dm.poly(diamond, gem)
		dm.put_px(7, 6, WHITE)
		dm.put_px(8, 5, gem.lerp(WHITE, 0.6))
		dm.outlined(BLACK, false)
		px.blit(dm, corner.x - 8, corner.y - 8)
	return px


static func table(p: Dictionary, size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y)
	var face: Color = Kit.colour(p, "colour_a", FACE)
	var hi: Color = face.lerp(WHITE, 0.7)
	var lo: Color = face.darkened(0.5)
	var filled: bool = bool(p.get("filled", true))
	px.bevel(0, 0, size.x, size.y, hi, lo, true, 3)
	if filled:
		px.rect(3, 3, size.x - 6, size.y - 6, face)
	var grid: Vector2i = grid_of(p)
	var cols: int = grid.x
	var rows: int = grid.y
	if not filled:
		for y: int in range(3, size.y - 3):
			for x: int in range(3, size.x - 3):
				px.put_px(x, y, face)
	for r: int in rows:
		for c: int in cols:
			var cell: Rect2i = cell_rect(p, size, c, r)
			var x0: int = cell.position.x
			var y0: int = cell.position.y
			var cw: int = cell.size.x
			var ch: int = cell.size.y
			if filled:
				px.rect(x0, y0, cw, ch, face.lerp(WHITE, 0.15))
			else:
				px.clear_rect(x0, y0, cw, ch)
			px.bevel(x0, y0, cw, ch, hi, lo, false, 1)
	return px


static func layout_card(size: Vector2i) -> Px:
	var px: Px = Px.new(size.x, size.y, WHITE)
	var w: int = px.w
	var h: int = px.h
	for y: int in h:
		for x: int in range(0, 22):
			px.put_px(x, y, [Color8(255, 102, 187), Color8(153, 102, 238), Color8(51, 204, 170), WHITE][posmod(y / 4 + int(2.0 * sin(float(x) * 0.4)), 4)])
			px.put_px(w - 1 - x, y, [Color8(255, 102, 187), Color8(153, 102, 238), Color8(51, 204, 170), WHITE][posmod(y / 4 + int(2.0 * sin(float(x) * 0.4)), 4)])
	px.rect(w / 2 - 50, 8, 100, 18, Color8(0, 0, 51))
	px.text_centred(w / 2, 13, "WELCOME", Color8(255, 204, 0))
	for k: int in 6:
		px.hline(36, w - 37, 40 + k * 9, Color8(0, 0, 204) if k % 3 != 2 else WHITE)
	px.rect(w / 2 - 44, h - 30, 26, 10, Color8(102, 0, 153))
	px.rect(w / 2 - 13, h - 30, 26, 10, Color8(204, 204, 204))
	px.rect(w / 2 + 18, h - 30, 26, 10, Color8(0, 0, 0))
	px.rect(w / 2 - 30, h - 16, 60, 8, Color8(0, 0, 0))
	px.text_centred(w / 2, h - 15, "004527", WHITE, true)
	return px
