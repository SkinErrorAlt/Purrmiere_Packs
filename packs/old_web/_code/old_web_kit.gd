extends RefCounted

const Px := preload("old_web_px.gd")
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const GREY := Color(0.75, 0.75, 0.75, 1.0)
const DARK_GREY := Color(0.5, 0.5, 0.5, 1.0)
const CURSOR: PackedStringArray = [
	"1000000000",
	"1100000000",
	"1210000000",
	"1221000000",
	"1222100000",
	"1222210000",
	"1222221000",
	"1222222100",
	"1222222210",
	"1222221111",
	"1221221000",
	"1210122100",
	"1100122100",
	"1000012210",
	"0000012210",
	"0000001100",
]

static var nudge: Vector2i = Vector2i.ZERO


static func colour(p: Dictionary, key: String, fallback: Color) -> Color:
	var v: Variant = p.get(key, null)
	if v is Color:
		return v
	if v is Array and (v as Array).size() >= 3:
		var a: Array = v
		return Color(float(a[0]), float(a[1]), float(a[2]), float(a[3]) if a.size() > 3 else 1.0)
	if v is String and Color.html_is_valid(String(v)):
		return Color.html(String(v))
	return fallback


static func text_of(p: Dictionary, key: String, fallback: String) -> String:
	var v: Variant = p.get(key, null)
	if v == null:
		return fallback
	return String(v)


static func letters(s: String, scale: int, spacing: int = 1, micro: bool = false, weight: int = 0) -> Px:
	var tw: int = Px.text_width(s, micro, scale, spacing, weight)
	var th: int = (Px.LINE_H if not micro else Px.MICRO_LINE_H) * scale + weight
	var m: Px = Px.new(maxi(tw, 1), maxi(th, 1))
	m.text(0, 0, s, WHITE, micro, scale, spacing, weight)
	return m


static func filled(mask: Px, fill: Callable, top: int, glyph_h: int) -> Px:
	var out: Px = Px.new(mask.w, mask.h)
	for y: int in mask.h:
		var fy: float = clampf(float(y - top) / float(maxi(glyph_h - 1, 1)), 0.0, 1.0)
		for x: int in mask.w:
			if mask.alpha_at(x, y) == 0:
				continue
			out.put_px(x, y, fill.call(x, y, fy))
	return out


static func edge_light(src: Px, mask: Px, light: Color, dark: Color) -> void:
	for y: int in mask.h:
		for x: int in mask.w:
			if mask.alpha_at(x, y) == 0:
				continue
			if mask.alpha_at(x, y - 1) == 0 or mask.alpha_at(x - 1, y) == 0:
				src.put_px(x, y, light)
			elif mask.alpha_at(x, y + 1) == 0 or mask.alpha_at(x + 1, y) == 0:
				src.put_px(x, y, dark)


static func padded(src: Px, pad: int) -> Px:
	var out: Px = Px.new(src.w + pad * 2, src.h + pad * 2)
	out.blit(src, pad, pad)
	return out


static func shadow_of(src: Px, c: Color) -> Px:
	var out: Px = Px.new(src.w, src.h)
	for y: int in src.h:
		for x: int in src.w:
			if src.alpha_at(x, y) > 0:
				out.put_px(x, y, c)
	return out


static func stamp_text(dst: Px, piece: Px, cx: int, y: int, shadow: Color = Color(0, 0, 0, 0), shadow_off: Vector2i = Vector2i(2, 2)) -> void:
	var x: int = cx - piece.w / 2 + nudge.x
	y += nudge.y
	if shadow.a > 0.0:
		dst.blit(shadow_of(piece, shadow), x + shadow_off.x, y + shadow_off.y)
	dst.blit(piece, x, y)


static func weight_for(scale: int) -> int:
	return 1 if scale >= 2 else 0


static func fancy_text(s: String, scale: int, fill: Callable, outline: Color, light: Color = Color(0, 0, 0, 0), dark: Color = Color(0, 0, 0, 0), outline2: Color = Color(0, 0, 0, 0)) -> Px:
	var wgt: int = weight_for(scale)
	var mask: Px = padded(letters(s, scale, 1, false, wgt), 2)
	var body: Px = filled(mask, fill, 2, Px.FONT_ROWS * scale + wgt)
	if light.a > 0.0:
		edge_light(body, mask, light, dark)
	if outline.a > 0.0:
		body.outlined(outline, false)
	if outline2.a > 0.0:
		body.outlined(outline2, true)
	return body


static func sparkle(p: Px, cx: int, cy: int, arm: int, core: Color, glow: Color) -> void:
	if arm <= 0:
		return
	for i: int in range(1, arm + 1):
		var c: Color = glow if i > 1 else core
		p.set_px(cx + i, cy, c)
		p.set_px(cx - i, cy, c)
		p.set_px(cx, cy + i, c)
		p.set_px(cx, cy - i, c)
	if arm >= 3:
		p.set_px(cx + 1, cy + 1, glow)
		p.set_px(cx - 1, cy - 1, glow)
		p.set_px(cx + 1, cy - 1, glow)
		p.set_px(cx - 1, cy + 1, glow)
	p.set_px(cx, cy, WHITE)


static func star_points(cx: float, cy: float, outer: float, inner: float, spikes: int, turn: float = 0.0, squash: float = 1.0) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in spikes * 2:
		var r: float = outer if i % 2 == 0 else inner
		var a: float = -PI * 0.5 + turn + PI * float(i) / float(spikes)
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r * squash))
	return pts


static func shaded_disc(p: Px, cx: float, cy: float, r: float, hi: Color, mid: Color, lo: Color) -> void:
	for y: int in range(int(floor(cy - r - 1.0)), int(ceil(cy + r + 1.0))):
		for x: int in range(int(floor(cx - r - 1.0)), int(ceil(cx + r + 1.0))):
			var dx: float = (float(x) + 0.5 - cx) / r
			var dy: float = (float(y) + 0.5 - cy) / r
			var d2: float = dx * dx + dy * dy
			if d2 > 1.0:
				continue
			var nz: float = sqrt(1.0 - d2)
			var l: float = clampf(-dx * 0.45 - dy * 0.55 + nz * 0.7, 0.0, 1.0)
			p.put_px(x, y, Px.pick([lo, mid, hi], l, x, y))


static func outline_shape(p: Px, c: Color) -> void:
	p.outlined(c, false)


static func fit_text(p: Px, x0: int, x1: int, y: int, s: String, c: Color, bold: bool = false) -> void:
	var room: int = x1 - x0
	var micro: bool = Px.text_width(s, false) > room
	var tw: int = Px.text_width(s, micro)
	var x: int = x0 + (room - tw) / 2 + nudge.x
	y += nudge.y
	var shade: Color = c.darkened(0.8)
	shade.a = 0.85
	if micro:
		if bold:
			p.text(x + 1, y + 2, s, shade, true)
		p.text(x, y + 1, s, c, true)
	else:
		if bold:
			p.text(x + 1, y + 1, s, shade)
		p.text(x, y, s, c)


static func button_base(p: Px, top: Color, bottom: Color, border: Color) -> void:
	for y: int in p.h:
		var t: float = float(y) / float(maxi(p.h - 1, 1))
		for x: int in p.w:
			p.put_px(x, y, Px.websafe(top.lerp(bottom, t), x, y))
	p.box(0, 0, p.w, p.h, border)
	var hi: Color = top.lerp(WHITE, 0.55)
	var lo: Color = bottom.darkened(0.45)
	p.hline(1, p.w - 2, 1, hi)
	p.vline(1, 1, p.h - 2, hi)
	p.hline(1, p.w - 2, p.h - 2, lo)
	p.vline(p.w - 2, 1, p.h - 2, lo)


static func cursor(p: Px, x: int, y: int) -> void:
	for ry: int in CURSOR.size():
		var row: String = CURSOR[ry]
		for rx: int in row.length():
			var ch: int = row.unicode_at(rx)
			if ch == 49:
				p.put_px(x + rx, y + ry, BLACK)
			elif ch == 50:
				p.put_px(x + rx, y + ry, WHITE)


static func mirrored(src: Px, flip_x: bool, flip_y: bool) -> Px:
	var out: Px = Px.new(src.w, src.h)
	for y: int in src.h:
		for x: int in src.w:
			out.put_px(x, y, src.get_px(src.w - 1 - x if flip_x else x, src.h - 1 - y if flip_y else y))
	return out


static func turned(src: Px) -> Px:
	var out: Px = Px.new(src.h, src.w)
	for y: int in src.h:
		for x: int in src.w:
			out.put_px(src.h - 1 - y, x, src.get_px(x, y))
	return out


static func smiley(p: Px, cx: int, cy: int, mood: String) -> void:
	var face_hi: Color = Color8(255, 255, 102)
	var face: Color = Color8(255, 204, 0)
	var face_lo: Color = Color8(204, 102, 0)
	if mood == "angry":
		face_hi = Color8(255, 153, 51)
		face = Color8(255, 102, 0)
		face_lo = Color8(204, 51, 0)
	var shape: Px = Px.new(p.w, p.h)
	shaded_disc(shape, float(cx), float(cy), 11.5, face_hi, face, face_lo)
	shape.outlined(Color8(51, 0, 0), false)
	p.blit(shape, 0, 0)
	var ink: Color = Color8(51, 0, 0)
	if mood == "happy" or mood == "sad" or mood == "angry":
		p.rect(cx - 5, cy - 5, 2, 4, ink)
		p.rect(cx + 3, cy - 5, 2, 4, ink)
		p.put_px(cx - 5, cy - 5, Color8(255, 255, 204))
		p.put_px(cx + 3, cy - 5, Color8(255, 255, 204))
	if mood == "happy":
		for x: int in range(-6, 7):
			var yy: int = 3 + int(round(sqrt(maxf(36.0 - float(x * x), 0.0)) * 0.55))
			p.set_px(cx + x, cy + yy, ink)
		p.set_px(cx - 7, cy + 2, ink)
		p.set_px(cx + 7, cy + 2, ink)
	elif mood == "sad":
		for x: int in range(-5, 6):
			var yy2: int = 8 - int(round(sqrt(maxf(25.0 - float(x * x), 0.0)) * 0.6))
			p.set_px(cx + x, cy + yy2, ink)
		p.put_px(cx - 7, cy - 1, Color8(102, 204, 255))
		p.put_px(cx - 7, cy, Color8(51, 153, 255))
	elif mood == "angry":
		p.line(cx - 7, cy - 8, cx - 3, cy - 6, ink)
		p.line(cx + 7, cy - 8, cx + 3, cy - 6, ink)
		p.line(cx - 7, cy - 7, cx - 3, cy - 5, ink)
		p.line(cx + 7, cy - 7, cx + 3, cy - 5, ink)
		p.hline(cx - 4, cx + 4, cy + 5, ink)
		p.set_px(cx - 5, cy + 6, ink)
		p.set_px(cx + 5, cy + 6, ink)
	elif mood == "shocked":
		p.disc(float(cx) - 4.0, float(cy) - 3.0, 3.0, WHITE)
		p.disc(float(cx) + 5.0, float(cy) - 3.0, 3.0, WHITE)
		p.ring(float(cx) - 4.0, float(cy) - 3.0, 3.0, 1.0, ink)
		p.ring(float(cx) + 5.0, float(cy) - 3.0, 3.0, 1.0, ink)
		p.rect(cx - 5, cy - 4, 2, 2, ink)
		p.rect(cx + 4, cy - 4, 2, 2, ink)
		p.ellipse(float(cx) + 0.5, float(cy) + 6.0, 3.0, 3.6, ink)
		p.ellipse(float(cx) + 0.5, float(cy) + 7.0, 1.6, 1.6, Color8(153, 0, 0))
	elif mood == "laughing":
		for d: int in 3:
			p.set_px(cx - 6 + d, cy - 3 - d, ink)
			p.set_px(cx - 2 - d, cy - 3 - d, ink)
			p.set_px(cx + 3 + d, cy - 3 - d, ink)
			p.set_px(cx + 7 - d, cy - 3 - d, ink)
		var mouth: PackedVector2Array = PackedVector2Array()
		for i: int in 13:
			var a: float = PI * float(i) / 12.0
			mouth.append(Vector2(float(cx) + 0.5 + cos(a) * 7.0, float(cy) + 1.0 + sin(a) * 7.0))
		p.poly(mouth, ink)
		p.ellipse(float(cx) + 0.5, float(cy) + 6.0, 3.5, 1.8, Color8(255, 102, 102))
		p.hline(cx - 5, cx + 6, cy + 2, WHITE)
	elif mood == "cool":
		p.rect(cx - 9, cy - 5, 19, 2, ink)
		p.rect(cx - 8, cy - 4, 7, 5, ink)
		p.rect(cx + 2, cy - 4, 7, 5, ink)
		p.put_px(cx - 7, cy - 3, Color8(153, 204, 255))
		p.put_px(cx + 3, cy - 3, Color8(153, 204, 255))
		p.put_px(cx - 6, cy - 3, Color8(102, 153, 204))
		p.line(cx - 3, cy + 6, cx + 3, cy + 5, ink)
		p.line(cx + 3, cy + 5, cx + 6, cy + 3, ink)
