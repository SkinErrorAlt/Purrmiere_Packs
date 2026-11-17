extends RefCounted

const CLEAR := Color(0.0, 0.0, 0.0, 0.0)
const BAYER: PackedInt32Array = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
const FONT_ROWS := 7
const LINE_H := 10
const MICRO_ROWS := 5
const MICRO_LINE_H := 7
const SPACE_W := 3
const MICRO_SPACE_W := 2
const GLYPHS: Dictionary = {
	"A": "01110 10001 10001 11111 10001 10001 10001",
	"B": "11110 10001 10001 11110 10001 10001 11110",
	"C": "01110 10001 10000 10000 10000 10001 01110",
	"D": "11110 10001 10001 10001 10001 10001 11110",
	"E": "11111 10000 10000 11110 10000 10000 11111",
	"F": "11111 10000 10000 11110 10000 10000 10000",
	"G": "01110 10001 10000 10111 10001 10001 01111",
	"H": "10001 10001 10001 11111 10001 10001 10001",
	"I": "111 010 010 010 010 010 111",
	"J": "00111 00010 00010 00010 00010 10010 01100",
	"K": "10001 10010 10100 11000 10100 10010 10001",
	"L": "10000 10000 10000 10000 10000 10000 11111",
	"M": "10001 11011 10101 10101 10001 10001 10001",
	"N": "10001 10001 11001 10101 10011 10001 10001",
	"O": "01110 10001 10001 10001 10001 10001 01110",
	"P": "11110 10001 10001 11110 10000 10000 10000",
	"Q": "01110 10001 10001 10001 10101 10010 01101",
	"R": "11110 10001 10001 11110 10100 10010 10001",
	"S": "01111 10000 10000 01110 00001 00001 11110",
	"T": "11111 00100 00100 00100 00100 00100 00100",
	"U": "10001 10001 10001 10001 10001 10001 01110",
	"V": "10001 10001 10001 10001 10001 01010 00100",
	"W": "10001 10001 10001 10101 10101 10101 01010",
	"X": "10001 10001 01010 00100 01010 10001 10001",
	"Y": "10001 10001 01010 00100 00100 00100 00100",
	"Z": "11111 00001 00010 00100 01000 10000 11111",
	"0": "01110 10001 10011 10101 11001 10001 01110",
	"1": "00100 01100 00100 00100 00100 00100 01110",
	"2": "01110 10001 00001 00010 00100 01000 11111",
	"3": "11111 00010 00100 00010 00001 10001 01110",
	"4": "00010 00110 01010 10010 11111 00010 00010",
	"5": "11111 10000 11110 00001 00001 10001 01110",
	"6": "00110 01000 10000 11110 10001 10001 01110",
	"7": "11111 00001 00010 00100 01000 01000 01000",
	"8": "01110 10001 10001 01110 10001 10001 01110",
	"9": "01110 10001 10001 01111 00001 00010 01100",
	"a": "00000 00000 01110 00001 01111 10001 01111",
	"b": "10000 10000 10110 11001 10001 10001 11110",
	"c": "0000 0000 0111 1000 1000 1000 0111",
	"d": "00001 00001 01101 10011 10001 10001 01111",
	"e": "00000 00000 01110 10001 11111 10000 01110",
	"f": "0011 0100 0100 1110 0100 0100 0100",
	"g": "00000 00000 01111 10001 10001 01111 00001 10001 01110",
	"h": "10000 10000 10110 11001 10001 10001 10001",
	"i": "1 0 1 1 1 1 1",
	"j": "001 000 011 001 001 001 001 101 010",
	"k": "1000 1000 1001 1010 1100 1010 1001",
	"l": "11 01 01 01 01 01 01",
	"m": "00000 00000 11010 10101 10101 10101 10001",
	"n": "00000 00000 10110 11001 10001 10001 10001",
	"o": "00000 00000 01110 10001 10001 10001 01110",
	"p": "00000 00000 11110 10001 10001 11110 10000 10000 10000",
	"q": "00000 00000 01111 10001 10001 01111 00001 00001 00001",
	"r": "0000 0000 1011 1100 1000 1000 1000",
	"s": "0000 0000 0111 1000 0110 0001 1110",
	"t": "010 010 111 010 010 010 001",
	"u": "00000 00000 10001 10001 10001 10011 01101",
	"v": "00000 00000 10001 10001 10001 01010 00100",
	"w": "00000 00000 10001 10001 10101 10101 01010",
	"x": "00000 00000 10001 01010 00100 01010 10001",
	"y": "00000 00000 10001 10001 10001 01111 00001 10001 01110",
	"z": "00000 00000 11111 00010 00100 01000 11111",
	"!": "1 1 1 1 1 0 1",
	"\"": "101 101 000 000 000 000 000",
	"#": "01010 01010 11111 01010 11111 01010 01010",
	"$": "00100 01111 10100 01110 00101 11110 00100",
	"%": "11000 11001 00010 00100 01000 10011 00011",
	"&": "01100 10010 10100 01000 10101 10010 01101",
	"'": "1 1 0 0 0 0 0",
	"(": "001 010 100 100 100 010 001",
	")": "100 010 001 001 001 010 100",
	"*": "00000 00100 10101 01110 10101 00100 00000",
	"+": "00000 00100 00100 11111 00100 00100 00000",
	",": "00 00 00 00 00 01 01 10",
	"-": "0000 0000 0000 1111 0000 0000 0000",
	".": "0 0 0 0 0 0 1",
	"/": "00001 00001 00010 00100 01000 10000 10000",
	":": "0 0 1 0 0 1 0",
	";": "00 00 01 00 00 01 01 10",
	"<": "0001 0010 0100 1000 0100 0010 0001",
	"=": "0000 0000 1111 0000 1111 0000 0000",
	">": "1000 0100 0010 0001 0010 0100 1000",
	"?": "01110 10001 00001 00010 00100 00000 00100",
	"@": "01110 10001 00001 01101 10101 10101 01110",
	"[": "111 100 100 100 100 100 111",
	"\\": "10000 10000 01000 00100 00010 00001 00001",
	"]": "111 001 001 001 001 001 111",
	"^": "00100 01010 10001 00000 00000 00000 00000",
	"_": "00000 00000 00000 00000 00000 00000 11111",
	"`": "10 01 00 00 00 00 00",
	"{": "001 010 010 100 010 010 001",
	"|": "1 1 1 1 1 1 1",
	"}": "100 010 010 001 010 010 100",
	"~": "00000 00000 01000 10101 00010 00000 00000",
}
const MICRO: Dictionary = {
	"A": "010 101 111 101 101",
	"B": "110 101 110 101 110",
	"C": "011 100 100 100 011",
	"D": "110 101 101 101 110",
	"E": "111 100 110 100 111",
	"F": "111 100 110 100 100",
	"G": "011 100 101 101 011",
	"H": "101 101 111 101 101",
	"I": "111 010 010 010 111",
	"J": "001 001 001 101 010",
	"K": "101 101 110 101 101",
	"L": "100 100 100 100 111",
	"M": "10001 11011 10101 10001 10001",
	"N": "1001 1101 1011 1001 1001",
	"O": "010 101 101 101 010",
	"P": "110 101 110 100 100",
	"Q": "010 101 101 110 011",
	"R": "110 101 110 101 101",
	"S": "011 100 010 001 110",
	"T": "111 010 010 010 010",
	"U": "101 101 101 101 111",
	"V": "101 101 101 101 010",
	"W": "10001 10001 10101 11011 10001",
	"X": "101 101 010 101 101",
	"Y": "101 101 010 010 010",
	"Z": "111 001 010 100 111",
	"0": "111 101 101 101 111",
	"1": "010 110 010 010 111",
	"2": "110 001 010 100 111",
	"3": "110 001 010 001 110",
	"4": "101 101 111 001 001",
	"5": "111 100 110 001 110",
	"6": "011 100 111 101 111",
	"7": "111 001 010 010 010",
	"8": "111 101 111 101 111",
	"9": "111 101 111 001 110",
	".": "0 0 0 0 1",
	"!": "1 1 1 0 1",
	"-": "000 000 111 000 000",
	":": "0 1 0 1 0",
	"/": "001 001 010 100 100",
	"'": "1 1 0 0 0",
	"?": "110 001 010 000 010",
	"+": "000 010 111 010 000",
	"&": "010 101 010 101 011",
	",": "00 00 00 01 10",
	"(": "01 10 10 10 01",
	")": "10 01 01 01 10",
	"%": "101 001 010 100 101",
	"#": "01010 11111 01010 11111 01010",
	"<": "001 010 100 010 001",
	">": "100 010 001 010 100",
	"=": "000 111 000 111 000",
	"@": "0110 1001 1011 1000 0111",
	"*": "000 101 010 101 000",
	"_": "000 000 000 000 111",
	"~": "0000 0000 0101 1010 0000",
}

static var _parsed: Dictionary = {}

var w: int = 1
var h: int = 1
var data: PackedByteArray = PackedByteArray()


func _init(width: int = 1, height: int = 1, fill_colour: Color = CLEAR) -> void:
	w = maxi(width, 1)
	h = maxi(height, 1)
	data.resize(w * h * 4)
	if fill_colour.a > 0.0:
		fill(fill_colour)


func fill(c: Color) -> void:
	var r: int = c.r8
	var g: int = c.g8
	var b: int = c.b8
	var a: int = c.a8
	for i: int in w * h:
		var k: int = i * 4
		data[k] = r
		data[k + 1] = g
		data[k + 2] = b
		data[k + 3] = a


func inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h


func set_px(x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= w or y >= h:
		return
	var k: int = (y * w + x) * 4
	if c.a >= 0.999:
		data[k] = c.r8
		data[k + 1] = c.g8
		data[k + 2] = c.b8
		data[k + 3] = 255
		return
	if c.a <= 0.001:
		return
	var under: Color = get_px(x, y)
	var out: Color = under.blend(c)
	data[k] = out.r8
	data[k + 1] = out.g8
	data[k + 2] = out.b8
	data[k + 3] = out.a8


func put_px(x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= w or y >= h:
		return
	var k: int = (y * w + x) * 4
	data[k] = c.r8
	data[k + 1] = c.g8
	data[k + 2] = c.b8
	data[k + 3] = c.a8


func get_px(x: int, y: int) -> Color:
	if x < 0 or y < 0 or x >= w or y >= h:
		return CLEAR
	var k: int = (y * w + x) * 4
	return Color8(data[k], data[k + 1], data[k + 2], data[k + 3])


func alpha_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= w or y >= h:
		return 0
	return data[(y * w + x) * 4 + 3]


func rect(x: int, y: int, rw: int, rh: int, c: Color) -> void:
	for yy: int in range(maxi(y, 0), mini(y + rh, h)):
		for xx: int in range(maxi(x, 0), mini(x + rw, w)):
			set_px(xx, yy, c)


func clear_rect(x: int, y: int, rw: int, rh: int) -> void:
	for yy: int in range(maxi(y, 0), mini(y + rh, h)):
		for xx: int in range(maxi(x, 0), mini(x + rw, w)):
			put_px(xx, yy, CLEAR)


func box(x: int, y: int, rw: int, rh: int, c: Color) -> void:
	hline(x, x + rw - 1, y, c)
	hline(x, x + rw - 1, y + rh - 1, c)
	vline(x, y, y + rh - 1, c)
	vline(x + rw - 1, y, y + rh - 1, c)


func hline(x0: int, x1: int, y: int, c: Color) -> void:
	for x: int in range(mini(x0, x1), maxi(x0, x1) + 1):
		set_px(x, y, c)


func vline(x: int, y0: int, y1: int, c: Color) -> void:
	for y: int in range(mini(y0, y1), maxi(y0, y1) + 1):
		set_px(x, y, c)


func line(x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var dx: int = absi(x1 - x0)
	var dy: int = -absi(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx + dy
	var x: int = x0
	var y: int = y0
	var guard: int = 0
	while guard < 100000:
		guard += 1
		set_px(x, y, c)
		if x == x1 and y == y1:
			break
		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy


func thick_line(x0: float, y0: float, x1: float, y1: float, radius: float, c: Color) -> void:
	var lo_x: int = int(floor(minf(x0, x1) - radius - 1.0))
	var hi_x: int = int(ceil(maxf(x0, x1) + radius + 1.0))
	var lo_y: int = int(floor(minf(y0, y1) - radius - 1.0))
	var hi_y: int = int(ceil(maxf(y0, y1) + radius + 1.0))
	var a: Vector2 = Vector2(x0, y0)
	var b: Vector2 = Vector2(x1, y1)
	for y: int in range(lo_y, hi_y + 1):
		for x: int in range(lo_x, hi_x + 1):
			var p: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5)
			if seg_dist(p, a, b) <= radius:
				set_px(x, y, c)


static func seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var l2: float = ab.length_squared()
	if l2 <= 0.00001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / l2, 0.0, 1.0)
	return p.distance_to(a + ab * t)


func disc(cx: float, cy: float, r: float, c: Color) -> void:
	for y: int in range(int(floor(cy - r - 1.0)), int(ceil(cy + r + 1.0))):
		for x: int in range(int(floor(cx - r - 1.0)), int(ceil(cx + r + 1.0))):
			var dx: float = float(x) + 0.5 - cx
			var dy: float = float(y) + 0.5 - cy
			if dx * dx + dy * dy <= r * r:
				set_px(x, y, c)


func ring(cx: float, cy: float, r: float, thick: float, c: Color) -> void:
	for y: int in range(int(floor(cy - r - 1.0)), int(ceil(cy + r + 1.0))):
		for x: int in range(int(floor(cx - r - 1.0)), int(ceil(cx + r + 1.0))):
			var d: float = Vector2(float(x) + 0.5 - cx, float(y) + 0.5 - cy).length()
			if d <= r and d > r - thick:
				set_px(x, y, c)


func ellipse(cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for y: int in range(int(floor(cy - ry - 1.0)), int(ceil(cy + ry + 1.0))):
		for x: int in range(int(floor(cx - rx - 1.0)), int(ceil(cx + rx + 1.0))):
			var dx: float = (float(x) + 0.5 - cx) / maxf(rx, 0.01)
			var dy: float = (float(y) + 0.5 - cy) / maxf(ry, 0.01)
			if dx * dx + dy * dy <= 1.0:
				set_px(x, y, c)


func poly(pts: PackedVector2Array, c: Color) -> void:
	if pts.size() < 3:
		return
	var lo: float = INF
	var hi: float = -INF
	for p: Vector2 in pts:
		lo = minf(lo, p.y)
		hi = maxf(hi, p.y)
	for y: int in range(int(floor(lo)), int(ceil(hi)) + 1):
		var sy: float = float(y) + 0.5
		var xs: Array[float] = []
		for i: int in pts.size():
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[(i + 1) % pts.size()]
			if (a.y <= sy and b.y > sy) or (b.y <= sy and a.y > sy):
				xs.append(a.x + (sy - a.y) / (b.y - a.y) * (b.x - a.x))
		xs.sort()
		var i2: int = 0
		while i2 + 1 < xs.size():
			for x: int in range(int(ceil(xs[i2] - 0.5)), int(ceil(xs[i2 + 1] - 0.5))):
				set_px(x, y, c)
			i2 += 2


func bevel(x: int, y: int, rw: int, rh: int, light: Color, dark: Color, raised: bool = true, thick: int = 1) -> void:
	var top: Color = light if raised else dark
	var bottom: Color = dark if raised else light
	for t: int in thick:
		hline(x + t, x + rw - 1 - t, y + t, top)
		vline(x + t, y + t, y + rh - 1 - t, top)
		hline(x + t, x + rw - 1 - t, y + rh - 1 - t, bottom)
		vline(x + rw - 1 - t, y + t, y + rh - 1 - t, bottom)


func button3d(x: int, y: int, rw: int, rh: int, face: Color, pressed: bool = false) -> void:
	rect(x, y, rw, rh, face)
	var hi: Color = face.lerp(Color.WHITE, 0.75)
	var mid: Color = face.darkened(0.33)
	var lo: Color = Color(0.0, 0.0, 0.0, 1.0)
	if pressed:
		box(x, y, rw, rh, lo)
		bevel(x + 1, y + 1, rw - 2, rh - 2, hi, mid, false)
		return
	hline(x, x + rw - 2, y, hi)
	vline(x, y, y + rh - 2, hi)
	hline(x, x + rw - 1, y + rh - 1, lo)
	vline(x + rw - 1, y, y + rh - 1, lo)
	hline(x + 1, x + rw - 2, y + rh - 2, mid)
	vline(x + rw - 2, y + 1, y + rh - 2, mid)


func blit(src: RefCounted, x: int, y: int, tint: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	var sw: int = int(src.get("w"))
	var sh: int = int(src.get("h"))
	var sd: PackedByteArray = src.get("data")
	for yy: int in sh:
		var ty: int = y + yy
		if ty < 0 or ty >= h:
			continue
		for xx: int in sw:
			var tx: int = x + xx
			if tx < 0 or tx >= w:
				continue
			var k: int = (yy * sw + xx) * 4
			if sd[k + 3] == 0:
				continue
			var c: Color = Color8(sd[k], sd[k + 1], sd[k + 2], sd[k + 3])
			if tint != Color(1.0, 1.0, 1.0, 1.0):
				c = Color(c.r * tint.r, c.g * tint.g, c.b * tint.b, c.a * tint.a)
			set_px(tx, ty, c)


func outlined(c: Color, diagonal: bool = false) -> void:
	var src: PackedByteArray = data.duplicate()
	for y: int in h:
		for x: int in w:
			if src[(y * w + x) * 4 + 3] != 0:
				continue
			var hit: bool = false
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
				if not diagonal and d.x != 0 and d.y != 0:
					continue
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and src[(ny * w + nx) * 4 + 3] != 0:
					hit = true
					break
			if hit:
				put_px(x, y, c)


func mask_has(x: int, y: int) -> bool:
	return alpha_at(x, y) > 0


func to_image() -> Image:
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)


func copy() -> RefCounted:
	var out: RefCounted = (get_script() as GDScript).new(w, h)
	out.set("data", data.duplicate())
	return out


func shifted_x(dx: int) -> RefCounted:
	var out: RefCounted = (get_script() as GDScript).new(w, h)
	var od: PackedByteArray = out.get("data")
	for y: int in h:
		for x: int in w:
			var sx: int = posmod(x - dx, w)
			var a: int = (y * w + sx) * 4
			var b: int = (y * w + x) * 4
			od[b] = data[a]
			od[b + 1] = data[a + 1]
			od[b + 2] = data[a + 2]
			od[b + 3] = data[a + 3]
	out.set("data", od)
	return out


static func bayer(x: int, y: int) -> float:
	return (float(BAYER[(y & 3) * 4 + (x & 3)]) + 0.5) / 16.0


static func safe_level(v: float, x: int, y: int) -> float:
	var s: float = clampf(v, 0.0, 1.0) * 5.0
	var base: float = floor(s)
	if s - base > bayer(x, y):
		base += 1.0
	return minf(base, 5.0) / 5.0


static func websafe(c: Color, x: int, y: int) -> Color:
	return Color(safe_level(c.r, x, y), safe_level(c.g, x, y), safe_level(c.b, x, y), c.a)


static func pick(colours: Array, t: float, x: int, y: int) -> Color:
	if colours.is_empty():
		return Color.BLACK
	if colours.size() == 1:
		return colours[0]
	var s: float = clampf(t, 0.0, 1.0) * float(colours.size() - 1)
	var i: int = int(floor(s))
	var f: float = s - float(i)
	if i >= colours.size() - 1:
		return colours[colours.size() - 1]
	return colours[i + 1] if f > bayer(x, y) else colours[i]


static func ramp(colours: Array, t: float) -> Color:
	if colours.is_empty():
		return Color.BLACK
	var s: float = clampf(t, 0.0, 1.0) * float(colours.size() - 1)
	var i: int = mini(int(floor(s)), colours.size() - 2)
	if colours.size() == 1:
		return colours[0]
	return (colours[i] as Color).lerp(colours[i + 1], s - float(i))


static func hash01(a: int, b: int, s: int) -> float:
	var n: int = a * 374761393 + b * 668265263 + s * 982451653
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)
	return float(n & 0xFFFF) / 65535.0


static func smooth(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)


static func tile_noise(x: float, y: float, cells_x: int, cells_y: int, seed_v: int) -> float:
	var ix: int = int(floor(x))
	var iy: int = int(floor(y))
	var fx: float = smooth(x - float(ix))
	var fy: float = smooth(y - float(iy))
	var x0: int = posmod(ix, cells_x)
	var x1: int = posmod(ix + 1, cells_x)
	var y0: int = posmod(iy, cells_y)
	var y1: int = posmod(iy + 1, cells_y)
	var a: float = hash01(x0, y0, seed_v)
	var b: float = hash01(x1, y0, seed_v)
	var c: float = hash01(x0, y1, seed_v)
	var d: float = hash01(x1, y1, seed_v)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy)


static func tile_fbm(px: float, py: float, size_x: int, size_y: int, base_cells: int, octaves: int, seed_v: int) -> float:
	var total: float = 0.0
	var amp: float = 0.5
	var norm: float = 0.0
	var cells: int = base_cells
	for o: int in octaves:
		var cx: int = cells
		var cy: int = maxi(int(round(float(cells) * float(size_y) / float(maxi(size_x, 1)))), 1)
		total += amp * tile_noise(px / float(size_x) * float(cx), py / float(size_y) * float(cy), cx, cy, seed_v + o * 101)
		norm += amp
		amp *= 0.5
		cells *= 2
	return total / maxf(norm, 0.0001)


static func glyph_rows(ch: String, micro: bool) -> Array:
	var key: String = ("m" if micro else "f") + ch
	if _parsed.has(key):
		return _parsed[key]
	var table: Dictionary = MICRO if micro else GLYPHS
	var src: String = ""
	if table.has(ch):
		src = String(table[ch])
	elif micro and table.has(ch.to_upper()):
		src = String(table[ch.to_upper()])
	elif table.has("?"):
		src = String(table["?"])
	var rows: Array = []
	for part: String in src.split(" ", false):
		rows.append(part)
	_parsed[key] = rows
	return rows


static func glyph_width(ch: String, micro: bool) -> int:
	if ch == " ":
		return MICRO_SPACE_W if micro else SPACE_W
	var rows: Array = glyph_rows(ch, micro)
	return String(rows[0]).length() if not rows.is_empty() else 0


static func text_width(text: String, micro: bool = false, scale: int = 1, spacing: int = 1, weight: int = 0) -> int:
	var total: int = 0
	var n: int = 0
	for i: int in text.length():
		var ch: String = text.substr(i, 1)
		total += glyph_width(ch, micro) * scale + weight
		n += 1
	if n > 1:
		total += (n - 1) * spacing * scale
	return total


static func text_height(micro: bool = false, scale: int = 1) -> int:
	return (MICRO_ROWS if micro else FONT_ROWS) * scale


func text(x: int, y: int, s: String, c: Color, micro: bool = false, scale: int = 1, spacing: int = 1, weight: int = 0) -> int:
	var cx: int = x
	for i: int in s.length():
		var ch: String = s.substr(i, 1)
		if ch != " ":
			var rows: Array = glyph_rows(ch, micro)
			for ry: int in rows.size():
				var row: String = rows[ry]
				for rx: int in row.length():
					if row.unicode_at(rx) == 49:
						if scale == 1 and weight == 0:
							set_px(cx + rx, y + ry, c)
						else:
							rect(cx + rx * scale, y + ry * scale, scale + weight, scale + weight, c)
		cx += (glyph_width(ch, micro) + spacing) * scale + weight
	return cx - x


func text_centred(cx: int, y: int, s: String, c: Color, micro: bool = false, scale: int = 1, spacing: int = 1) -> void:
	text(cx - text_width(s, micro, scale, spacing) / 2, y, s, c, micro, scale, spacing)


static func wrap(s: String, max_w: int, micro: bool = false) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for para: String in s.replace("|", "\n").split("\n"):
		var line_now: String = ""
		for word: String in para.split(" ", false):
			var trial: String = word if line_now.is_empty() else line_now + " " + word
			if text_width(trial, micro) <= max_w or line_now.is_empty():
				line_now = trial
			else:
				out.append(line_now)
				line_now = word
		out.append(line_now)
	return out
