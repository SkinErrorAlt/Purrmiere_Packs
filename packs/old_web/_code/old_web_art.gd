extends RefCounted

const Px := preload("old_web_px.gd")
const Kit := preload("old_web_kit.gd")
const Catalogue := preload("old_web_catalogue.gd")
const Banners := preload("old_web_paint_banners.gd")
const Tiles := preload("old_web_paint_tiles.gd")
const Bits := preload("old_web_paint_bits.gd")
const Frames := preload("old_web_paint_frames.gd")
const CACHE_CAP := 384
const MIN_FPS := 1.0
const MAX_FPS := 30.0
const BUBBLE_MAX_W := 132
const STAMP_KEYS: PackedStringArray = ["oldweb", "text", "text2", "colour_a", "colour_b", "number", "digits", "counting", "rate", "direction", "step", "framed", "filled", "box_w", "box_h", "cols", "rows", "spacing", "tail_x", "flow", "text_dx", "text_dy"]

static var _images: Dictionary = {}
static var _textures: Dictionary = {}
static var paints: int = 0
static var _previews: Dictionary = {}


static func id_of(p: Dictionary) -> String:
	return String(p.get(Catalogue.ID_PROP, ""))


static func stamp(p: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for k: String in STAMP_KEYS:
		parts.append(k + "=" + var_to_str(p.get(k, null)))
	return "|".join(parts).md5_text()


static func anim_fps(p: Dictionary) -> float:
	var d: Dictionary = Catalogue.entry(id_of(p))
	return clampf(float(p.get(Catalogue.FPS_PROP, d.get("fps", 8.0))), MIN_FPS, MAX_FPS)


static func art_size(p: Dictionary) -> Vector2i:
	var id: String = id_of(p)
	var d: Dictionary = Catalogue.entry(id)
	if d.is_empty():
		return Vector2i(16, 16)
	var base: Vector2i = Vector2i(int(d["size"][0]), int(d["size"][1]))
	if Catalogue.can_resize(id):
		return boxed(id, p, base)
	if bool(d.get("layout", false)):
		return base / 4
	if id == "bubble":
		return Bits.bubble_size(p)
	if id == "new_blink":
		return Vector2i(Px.text_width(Kit.text_of(p, "text", "NEW")) + 10, 13)
	if id == "counter":
		return Vector2i(clampi(int(p.get("digits", 6)), 1, 12) * 10 + 5, 17)
	if id == "arrows":
		var dir: String = String(p.get("direction", "right"))
		if dir == "up" or dir == "down":
			return Vector2i(base.y, base.x)
	return base


static func boxed(id: String, p: Dictionary, base: Vector2i) -> Vector2i:
	var r: Dictionary = Catalogue.resize_of(id)
	var lo: Array = r.get("min", [1, 1])
	var hi: Array = r.get("max", [4096, 4096])
	var axes: String = String(r.get("axes", "xy"))
	var w: int = base.x
	var h: int = base.y
	if p.has(Catalogue.BOX_W) and axes.contains("x"):
		w = clampi(int(p[Catalogue.BOX_W]), int(lo[0]), int(hi[0]))
	if p.has(Catalogue.BOX_H) and axes.contains("y"):
		h = clampi(int(p[Catalogue.BOX_H]), int(lo[1]), int(hi[1]))
	return Vector2i(w, h)


static func nudge_of(p: Dictionary) -> Vector2i:
	if not Catalogue.moves_words(id_of(p)):
		return Vector2i.ZERO
	return Vector2i(int(p.get("text_dx", 0)), int(p.get("text_dy", 0)))


static func frame_count(p: Dictionary) -> int:
	var id: String = id_of(p)
	var d: Dictionary = Catalogue.entry(id)
	if d.is_empty():
		return 1
	if id == "marquee":
		return Bits.marquee_frames(p, art_size(p).x)
	if id == "counter":
		return 0 if bool(p.get("counting", false)) else 1
	return maxi(int(d["frames"]), 1)


static func frame_at(p: Dictionary, clock: float) -> int:
	var n: int = frame_count(p)
	var f: int = int(floor(maxf(clock, 0.0) * anim_fps(p) + 0.0001))
	if n == 0:
		return f
	return posmod(f, n)


static func paint(p: Dictionary, frame: int) -> Px:
	var id: String = id_of(p)
	var d: Dictionary = Catalogue.entry(id)
	if d.is_empty():
		return Px.new(16, 16)
	paints += 1
	var n: int = frame_count(p)
	var group: String = String(d["group"])
	var out: Px = null
	Kit.nudge = nudge_of(p)
	if group == "Banners" or group == "Dividers":
		out = Banners.paint(id, p, frame, maxi(n, 1), art_size(p))
	elif group == "Backgrounds":
		out = Tiles.paint(id, p, frame, maxi(n, 1), art_size(p))
	elif group == "Frames":
		out = Frames.paint(id, p, frame, maxi(n, 1), art_size(p))
	elif group == "Layouts":
		out = Frames.layout_card(art_size(p))
	else:
		out = Bits.paint(id, p, frame, n, art_size(p), anim_fps(p))
	Kit.nudge = Vector2i.ZERO
	return out if out != null else Px.new(16, 16)


static func _trim() -> void:
	if _images.size() > CACHE_CAP:
		_images.clear()
	if _textures.size() > CACHE_CAP:
		_textures.clear()


static func image(p: Dictionary, frame: int) -> Image:
	var key: String = stamp(p) + "#" + str(frame)
	if _images.has(key):
		return _images[key]
	_trim()
	var img: Image = paint(p, frame).to_image()
	_images[key] = img
	return img


static func texture(p: Dictionary, frame: int) -> ImageTexture:
	var key: String = stamp(p) + "#" + str(frame)
	if _textures.has(key):
		return _textures[key]
	_trim()
	var tex: ImageTexture = ImageTexture.create_from_image(image(p, frame))
	_textures[key] = tex
	return tex


static func forget() -> void:
	_images.clear()
	_textures.clear()
	_previews.clear()


static func preview_texture(p: Dictionary, w: int, h: int) -> ImageTexture:
	var key: String = stamp(p) + "@" + str(w) + "x" + str(h)
	if _previews.has(key):
		return _previews[key]
	if _previews.size() > CACHE_CAP:
		_previews.clear()
	var tex: ImageTexture = ImageTexture.create_from_image(preview_image(p, w, h))
	_previews[key] = tex
	return tex


static func preview_image(p: Dictionary, w: int, h: int, frame: int = 0) -> Image:
	var out: Image = Image.create_empty(maxi(w, 2), maxi(h, 2), false, Image.FORMAT_RGBA8)
	var sq: int = maxi(out.get_height() / 8, 2)
	for y: int in out.get_height():
		for x: int in out.get_width():
			var light: bool = ((x / sq) + (y / sq)) % 2 == 0
			out.set_pixel(x, y, Color(0.42, 0.42, 0.42) if light else Color(0.32, 0.32, 0.32))
	var art: Image = image(p, frame).duplicate()
	if Catalogue.is_tile(id_of(p)):
		var tiled: Image = Image.create_empty(out.get_width(), out.get_height(), false, Image.FORMAT_RGBA8)
		var cell: int = maxi(int(round(float(out.get_height()) / 2.0)), 1)
		var tile: Image = art.duplicate()
		tile.resize(cell, maxi(int(round(float(cell) * float(art.get_height()) / float(maxi(art.get_width(), 1)))), 1), Image.INTERPOLATE_NEAREST)
		for ty: int in range(0, out.get_height(), tile.get_height()):
			for tx: int in range(0, out.get_width(), tile.get_width()):
				tiled.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i(tx, ty))
		return tiled
	var k: float = minf(float(out.get_width()) / float(art.get_width()), float(out.get_height()) / float(art.get_height()))
	if k >= 1.0:
		k = floor(k)
	var nw: int = maxi(int(round(float(art.get_width()) * k)), 1)
	var nh: int = maxi(int(round(float(art.get_height()) * k)), 1)
	art.resize(nw, nh, Image.INTERPOLATE_NEAREST)
	out.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), Vector2i((out.get_width() - nw) / 2, (out.get_height() - nh) / 2))
	return out
