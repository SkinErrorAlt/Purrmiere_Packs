extends RefCounted

const Catalogue := preload("old_web_catalogue.gd")
const Art := preload("old_web_art.gd")
const Frames := preload("old_web_paint_frames.gd")
const Bits := preload("old_web_paint_bits.gd")
const PACK_ID := "old_web"
const PREFIX := "old_web_"
const PAGE_ID := "old_web_page"
const LABEL := "Old web (1999)"
const ERA := "1996 to 2001"
const BLURB := "Homepage pixel art from the early web: banners, buttons, counters and stamps."
const ORDER := 0
const BASE_W := 1920.0
const BASE_H := 1080.0
const PAGE_W := 1440.0
const TEXT_MARGIN := 24.0
const BLOCK := 256
const CACHE_CAP := 96
const KEEP := 64
const SCALE_MAX := 16
const NUDGE_MAX := 64
const STEP_MAX := 16
const DIGITS_MAX := 12
const NUMBER_MAX := 999999999999
const FLOW_BASE := 10.0
const FLOW_PER_STEP := 8.0
const RATE_BASE := 6.0
const RATE_PER_DOUBLE := 12.0
const RATE_MAX := 1000.0
const CELL_MIN := 4
const TAIL_MAX := 400
const SCALE_PUSH := 22.0
const ARROW_PUSH := 16.0
const DIGITS_PUSH := 16.0
const TILE_MIN := 16
const TILE_MAX := 16384
const CORNER_SIDES: Array[Vector2i] = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
const EDGE_SIDES: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const SIMPLE_IDS: PackedStringArray = ["words", "flow", "point", "digits", "rate", "tail", "spacing", "cells"]
const SIMPLE_LOOKS: Dictionary = {"cross": "ring", "diamond": "arrow"}
const DIRECTIONS: PackedStringArray = ["right", "left", "down", "up"]
const DIR_VECTORS: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
const FLOWS: PackedStringArray = ["left", "right"]
const COLOUR_LABELS: Dictionary = {"colour_a": "Main colour", "colour_b": "Second colour"}
const FIELD_LABELS: Dictionary = {
	"text": "Text",
	"text2": "Second line",
	"number": "Number shown",
	"digits": "Digits",
	"counting": "Count up while playing",
	"rate": "Counts per second",
	"direction": "Points",
	"step": "Pixels moved each frame",
	"framed": "Purple tile behind the stamp",
	"filled": "Fill the cells",
	"text_dx": "Words moved across (pixels)",
	"text_dy": "Words moved down (pixels)",
	"box_w": "Width (pixels)",
	"box_h": "Height (pixels)",
	"flow": "Scrolls toward",
	"tail_x": "Tail position (pixels)",
	"spacing": "A light every (pixels)",
	"cols": "Cells across",
	"rows": "Cells down",
	"scale": "Pattern scale (whole pixels)",
	"tile_x": "Pattern offset across (pixels)",
	"tile_y": "Pattern offset down (pixels)",
}
const OWN_LABELS: Dictionary = {
	"win_browser": {"text": "Window title", "text2": "Address", "colour_a": "Title bar colour"},
	"win_dialog": {"text": "Window title", "text2": "Message", "colour_a": "Title bar colour"},
	"webring": {"text": "Ring name"},
	"marquee": {"colour_a": "Text colour", "colour_b": "Background"},
	"bubble": {"text": "Words (a | starts a new line)", "colour_a": "Outline and text", "colour_b": "Inside"},
	"banner_night": {"colour_a": "Letters", "colour_b": "Sky"},
	"banner_rainbow": {"colour_b": "Background"},
	"banner_glitter": {"colour_a": "Glitter", "colour_b": "Background"},
	"banner_chrome": {"colour_b": "Sky"},
	"bg_stars": {"colour_b": "Space"},
	"bg_clouds": {"colour_b": "Sky"},
	"bg_marble": {"colour_a": "Veins"},
	"bg_parchment": {"colour_a": "Paper"},
	"bg_purple": {"colour_a": "Base colour"},
	"frame_pixel": {"colour_a": "Frame colour", "colour_b": "Corner gems"},
	"table_cell": {"colour_a": "Cell colour"},
}
const PAGE_STEPS: Array = [
	{"page": "Page", "colour": [1.0, 1.0, 1.0, 1.0], "box": [1440, 1080], "pos": [0.0, 0.0]},
	{"object": "bg_crayon", "box": [112, 1080], "pos": [-664.0, 0.0]},
	{"object": "bg_crayon", "box": [112, 1080], "pos": [664.0, 0.0]},
	{"page": "Left stripe", "colour": [1.0, 1.0, 0.2, 1.0], "box": [12, 1080], "pos": [-602.0, 0.0]},
	{"page": "Right stripe", "colour": [1.0, 1.0, 0.2, 1.0], "box": [12, 1080], "pos": [602.0, 0.0]},
	{"object": "banner_night", "pos": [0.0, -462.0]},
	{"object": "div_crayon", "pos": [0.0, -282.0]},
	{"object": "new_blink", "pos": [-430.0, -60.0]},
	{"object": "construct_cone", "pos": [-370.0, 60.0]},
	{"object": "counter", "pos": [0.0, 50.0]},
	{"object": "email", "pos": [370.0, 30.0]},
	{"object": "div_rainbow", "pos": [0.0, 170.0]},
	{"object": "btn_handmade", "pos": [-288.0, 240.0]},
	{"object": "btn_browser", "pos": [-96.0, 240.0]},
	{"object": "btn_guestbook", "pos": [96.0, 240.0]},
	{"object": "btn_y2k", "pos": [288.0, 240.0]},
	{"object": "webring", "pos": [0.0, 340.0]},
	{"object": "marquee", "pos": [0.0, 440.0]},
]
const PAGE_TEXTS: Array = [
	{"style": "old_web_page_title", "text": "Welcome to My Totally Awesome Homepage!", "size": 54.0, "pos": [0.0, -350.0]},
	{"style": "old_web_page_words", "text": "Hi! Thanks for stopping by my little corner of the web.\nHere you will find my favourite things, my pets\nand some cool links. Sign my guestbook before you go!", "size": 32.0, "pos": [0.0, -175.0]},
	{"style": "old_web_visitor_words", "text": "You are visitor number", "size": 28.0, "pos": [0.0, 0.0]},
	{"style": "old_web_link_words", "text": "Email me!", "size": 26.0, "pos": [370.0, 92.0]},
]

static var _entries: Array[Dictionary] = []
static var _by_id: Dictionary = {}
static var _blocks: Dictionary = {}
static var _kept: Array[Texture2D] = []


static func info() -> Dictionary:
	return {"id": PACK_ID, "label": LABEL, "era": ERA, "blurb": BLURB, "groups": Catalogue.GROUPS.duplicate(), "order": ORDER}


static func entries() -> Array[Dictionary]:
	_build()
	var out: Array[Dictionary] = []
	for e: Dictionary in _entries:
		out.append(e.duplicate(true))
	return out


static func _build() -> void:
	if not _entries.is_empty():
		return
	for c: Dictionary in Catalogue.entries():
		if bool(c.get("layout", false)):
			continue
		var e: Dictionary = entry_of(c)
		_entries.append(e)
		_by_id[String(e["id"])] = e
		if String(c["id"]) == "bg_clouds":
			var pg: Dictionary = page_entry()
			_entries.append(pg)
			_by_id[PAGE_ID] = pg


static func entry_of(c: Dictionary) -> Dictionary:
	var cid: String = String(c["id"])
	var tile: bool = bool(c.get("tile", false))
	var frames: int = int(c.get("frames", 1))
	var live: bool = bool(c.get("live", false))
	var k: int = int(c.get("scale", 2))
	var art: Vector2i = Art.art_size(Catalogue.props_for(cid))
	var size: Array = [int(BASE_W), int(BASE_H)] if tile else [art.x * k, art.y * k]
	var lp: float = float(frames) / float(c["fps"]) if frames > 1 and not live else 0.0
	return {"id": PREFIX + cid, "group": String(c["group"]), "label": String(c["label"]), "size": size, "full_frame": tile, "loop": lp, "crisp": true, "fields": fields_of(c), "old_web": cid, "frames": frames, "fps": float(c["fps"]), "scale": k, "live": live}


static func page_entry() -> Dictionary:
	var f: Dictionary = {"key": "colour_a", "label": "Page colour", "type": "colour", "default": [1.0, 1.0, 1.0, 1.0]}
	return {"id": PAGE_ID, "group": "Backgrounds", "label": "Plain page colour", "size": [int(PAGE_W), int(BASE_H)], "full_frame": false, "loop": 0.0, "crisp": true, "fields": [f], "old_web": "", "frames": 1, "fps": 8.0, "scale": 1, "live": false}


static func label_for(cid: String, key: String) -> String:
	var own: Dictionary = OWN_LABELS.get(cid, {})
	if own.has(key):
		return String(own[key])
	if COLOUR_LABELS.has(key):
		return String(COLOUR_LABELS[key])
	return String(FIELD_LABELS.get(key, key.capitalize()))


static func field(cid: String, key: String, kind: String, dv: Variant, extra: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {"key": key, "label": label_for(cid, key), "type": kind, "default": (dv as Array).duplicate() if dv is Array else dv}
	for k: Variant in extra.keys():
		out[k] = extra[k]
	return out


static func fields_of(c: Dictionary) -> Array[Dictionary]:
	var cid: String = String(c["id"])
	var defs: Dictionary = c["defaults"]
	var out: Array[Dictionary] = []
	for key: Variant in c["fields"]:
		var k: String = String(key)
		var dv: Variant = defs.get(k, null)
		if k == "text" or k == "text2":
			out.append(field(cid, k, "text", String(dv)))
		elif COLOUR_LABELS.has(k):
			out.append(field(cid, k, "colour", dv))
		elif k == "number":
			out.append(field(cid, k, "int", int(dv), {"min": 0, "max": NUMBER_MAX}))
		elif k == "digits":
			out.append(field(cid, k, "int", int(dv), {"min": 1, "max": DIGITS_MAX}))
		elif k == "rate":
			out.append(field(cid, k, "float", float(dv), {"min": 0.0, "max": RATE_MAX, "step": 0.1}))
		elif k == "step":
			out.append(field(cid, k, "int", int(dv), {"min": 1, "max": STEP_MAX}))
		elif k == "direction":
			out.append(field(cid, k, "enum", String(dv), {"options": DIRECTIONS.duplicate()}))
		else:
			out.append(field(cid, k, "bool", bool(dv)))
	if Catalogue.moves_words(cid):
		out.append(field(cid, "text_dx", "int", 0, {"min": -NUDGE_MAX, "max": NUDGE_MAX}))
		out.append(field(cid, "text_dy", "int", 0, {"min": -NUDGE_MAX, "max": NUDGE_MAX}))
	if Catalogue.can_resize(cid):
		var r: Dictionary = Catalogue.resize_of(cid)
		var axes: String = String(r.get("axes", "xy"))
		var base: Array = c["size"]
		if axes.contains("x"):
			out.append(field(cid, "box_w", "int", int(base[0]), {"min": int(r["min"][0]), "max": int(r["max"][0])}))
		if axes.contains("y"):
			out.append(field(cid, "box_h", "int", int(base[1]), {"min": int(r["min"][1]), "max": int(r["max"][1])}))
	if cid == "marquee":
		out.append(field(cid, "flow", "enum", "left", {"options": FLOWS.duplicate()}))
	if cid == "bubble":
		out.append(field(cid, "tail_x", "int", 7, {"min": 0, "max": TAIL_MAX}))
	if cid == "frame_pixel":
		out.append(field(cid, "spacing", "int", Frames.SPACING, {"min": Frames.SPACING_MIN, "max": Frames.SPACING_MAX}))
	if cid == "table_cell":
		out.append(field(cid, "cols", "int", 2, {"min": 1, "max": Frames.CELLS_MAX}))
		out.append(field(cid, "rows", "int", 2, {"min": 1, "max": Frames.CELLS_MAX}))
	if bool(c.get("tile", false)):
		var art: Vector2i = Art.art_size(Catalogue.props_for(cid))
		out.append(field(cid, "scale", "int", int(c.get("scale", 2)), {"min": 1, "max": SCALE_MAX}))
		out.append(field(cid, "tile_x", "int", 0, {"min": 0, "max": maxi(art.x - 1, 1)}))
		out.append(field(cid, "tile_y", "int", 0, {"min": 0, "max": maxi(art.y - 1, 1)}))
	return out


static func cid_of(id: String) -> String:
	if id == PAGE_ID or not id.begins_with(PREFIX):
		return ""
	var cid: String = id.substr(PREFIX.length())
	return cid if not Catalogue.entry(cid).is_empty() and not Catalogue.is_layout(cid) else ""


static func object_for(old_web_id: String) -> String:
	_build()
	return PREFIX + old_web_id if _by_id.has(PREFIX + old_web_id) else ""


static func props_of(id: String, values: Dictionary) -> Dictionary:
	_build()
	var cid: String = cid_of(id)
	var p: Dictionary = Catalogue.props_for(cid)
	var e: Dictionary = _by_id.get(id, {})
	for f: Dictionary in e.get("fields", []):
		var k: String = String(f["key"])
		var v: Variant = values.get(k, f["default"])
		p[k] = (v as Array).duplicate() if v is Array else v
	return p


static func colour_of(v: Variant, fallback: Color) -> Color:
	if v is Color:
		return v
	if v is Array and (v as Array).size() >= 3:
		var a: Array = v
		return Color(float(a[0]), float(a[1]), float(a[2]), float(a[3]) if a.size() > 3 else 1.0)
	return fallback


static func size_for(id: String, values: Dictionary) -> Vector2i:
	_build()
	var e: Dictionary = _by_id.get(id, {})
	if e.is_empty():
		return Vector2i.ZERO
	if bool(e["full_frame"]) or id == PAGE_ID:
		return Vector2i(int((e["size"] as Array)[0]), int((e["size"] as Array)[1]))
	return Art.art_size(props_of(id, values)) * int(e["scale"])


static func frame_of(id: String, t: float, values: Dictionary) -> int:
	if cid_of(id).is_empty():
		return 0
	return Art.frame_at(props_of(id, values), t)


static func image_of(id: String, t: float, values: Dictionary) -> Image:
	if cid_of(id).is_empty():
		return null
	var p: Dictionary = props_of(id, values)
	return Art.image(p, Art.frame_at(p, t))


static func draw(id: String, ci: CanvasItem, size: Vector2, t: float, values: Dictionary) -> void:
	if ci == null or size.x < 1.0 or size.y < 1.0:
		return
	if id == PAGE_ID:
		ci.draw_rect(Rect2(Vector2.ZERO, size), colour_of(values.get("colour_a", null), Color(1.0, 1.0, 1.0, 1.0)), true)
		return
	var cid: String = cid_of(id)
	if cid.is_empty():
		return
	var p: Dictionary = props_of(id, values)
	var frame: int = Art.frame_at(p, t)
	if Catalogue.is_tile(cid):
		_draw_tiles(ci, p, frame, size)
		return
	var tex: Texture2D = Art.texture(p, frame)
	if tex != null:
		_keep(tex)
		ci.draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)


static func _keep(tex: Texture2D) -> void:
	_kept.append(tex)
	if _kept.size() > KEEP:
		_kept.remove_at(0)


static func tile_k(p: Dictionary, size: Vector2) -> float:
	return maxf(float(clampi(int(p.get("scale", 2)), 1, SCALE_MAX)) * size.y / BASE_H, 0.01)


static func tile_shift(p: Dictionary, cell: Vector2) -> Vector2:
	var ox: float = float(p.get("tile_x", 0))
	var oy: float = float(p.get("tile_y", 0))
	if is_zero_approx(ox) and is_zero_approx(oy):
		return Vector2.ZERO
	return Vector2(fposmod(ox, maxf(cell.x, 1.0)) - cell.x, fposmod(oy, maxf(cell.y, 1.0)) - cell.y)


static func _block(p: Dictionary, frame: int) -> ImageTexture:
	var key: String = Art.stamp(p) + "#" + str(frame)
	if _blocks.has(key):
		return _blocks[key]
	if _blocks.size() > CACHE_CAP:
		_blocks.clear()
	var img: Image = Art.image(p, frame)
	var cw: int = maxi(img.get_width(), 1)
	var ch: int = maxi(img.get_height(), 1)
	var rx: int = maxi(int(ceil(float(BLOCK) / float(cw))), 1)
	var ry: int = maxi(int(ceil(float(BLOCK) / float(ch))), 1)
	var block: Image = Image.create_empty(cw * rx, ch * ry, false, Image.FORMAT_RGBA8)
	var src: Image = img
	if src.get_format() != Image.FORMAT_RGBA8:
		src = img.duplicate()
		src.convert(Image.FORMAT_RGBA8)
	for ty: int in ry:
		for tx: int in rx:
			block.blit_rect(src, Rect2i(0, 0, cw, ch), Vector2i(tx * cw, ty * ch))
	var tex: ImageTexture = ImageTexture.create_from_image(block)
	_blocks[key] = tex
	return tex


static func _draw_tiles(ci: CanvasItem, p: Dictionary, frame: int, size: Vector2) -> void:
	var img: Image = Art.image(p, frame)
	if img == null or img.is_empty():
		return
	var k: float = tile_k(p, size)
	var shift: Vector2 = tile_shift(p, Vector2(img.get_size()))
	var block: ImageTexture = _block(p, frame)
	_keep(block)
	var bs: Vector2 = Vector2(block.get_size())
	var span: Vector2 = size / k - shift
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2(k, k))
	var y: float = 0.0
	while y < span.y:
		var h: float = minf(bs.y, span.y - y)
		var x: float = 0.0
		while x < span.x:
			var w: float = minf(bs.x, span.x - x)
			ci.draw_texture_rect_region(block, Rect2(shift + Vector2(x, y), Vector2(w, h)), Rect2(0.0, 0.0, w, h))
			x += bs.x
		y += bs.y
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func is_frame(cid: String) -> bool:
	return String(Catalogue.entry(cid).get("group", "")) == "Frames"


static func inner_rect(id: String, size: Vector2, values: Dictionary) -> Rect2:
	var cid: String = cid_of(id)
	if cid.is_empty() or not is_frame(cid):
		return Rect2()
	var p: Dictionary = props_of(id, values)
	var art: Vector2i = Art.art_size(p)
	var kv: Vector2 = Vector2(size.x / float(maxi(art.x, 1)), size.y / float(maxi(art.y, 1)))
	var r: Rect2i = Frames.inner_rect(cid, art)
	return Rect2(Vector2(r.position) * kv, Vector2(r.size) * kv)


static func words_anchor(cid: String, art: Vector2) -> Vector2:
	if cid.begins_with("btn_"):
		return Vector2((30.0 + art.x - 3.0) * 0.5, art.y * 0.5)
	if cid == "webring":
		return Vector2(art.x * 0.5, 9.0)
	if cid == "guestbook":
		return Vector2(art.x * 0.5, 56.0)
	if cid == "banner_night":
		return Vector2(art.x * 0.5 - 8.0, 16.0)
	return art * 0.5


static func flow_length(step: int, k: float) -> float:
	return (FLOW_BASE + float(step) * FLOW_PER_STEP) * k


static func rate_length(rate: float, k: float) -> float:
	return (RATE_BASE + RATE_PER_DOUBLE * log(1.0 + maxf(rate, 0.0)) / log(2.0)) * k


static func dir_index(p: Dictionary) -> int:
	return maxi(DIRECTIONS.find(String(p.get("direction", "right"))), 0)


static func resize_name(cid: String) -> String:
	var group: String = String(Catalogue.entry(cid).get("group", ""))
	if group == "Frames":
		return "Resize the frame, the border stays sharp"
	if group == "Dividers":
		return "Divider length"
	if group == "Banners":
		return "Banner size, the words stay sharp"
	if cid == "marquee":
		return "Strip length"
	return "Resize"


static func tile_cell(p: Dictionary, layer: Vector2) -> Rect2:
	var k: float = tile_k(p, layer)
	var art: Vector2 = Vector2(Art.art_size(p))
	var cell: Vector2 = art * k
	var o: Vector2 = Vector2(float(p.get("tile_x", 0)), float(p.get("tile_y", 0))) * k
	var origin: Vector2 = Vector2(fposmod(o.x, maxf(cell.x, 1.0)), fposmod(o.y, maxf(cell.y, 1.0)))
	var c: Vector2 = layer * 0.5
	var at: Vector2 = origin + Vector2(floor((c.x - origin.x) / maxf(cell.x, 1.0)) * cell.x, floor((c.y - origin.y) / maxf(cell.y, 1.0)) * cell.y)
	return Rect2(at, cell)


static func max_cells(span: float) -> int:
	return maxi(int((span - 6.0 - float(Frames.CELL_GAP)) / float(Frames.CELL_GAP + CELL_MIN)), 1)


static func handle(hid: String, at: Vector2, look: String, name: String, extra: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {"id": hid, "at": at, "look": look, "name": name}
	for k: Variant in extra.keys():
		out[k] = extra[k]
	return out


static func handles(id: String, size: Vector2, values: Dictionary, how: Dictionary = {}) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var cid: String = cid_of(id)
	if cid.is_empty() or size.x < 1.0 or size.y < 1.0:
		return out
	var p: Dictionary = props_of(id, values)
	if bool(how.get("acts", false)):
		return act_handles(cid, p, size)
	if Catalogue.is_tile(cid):
		var cell: Rect2 = tile_cell(p, size)
		out.append(handle("tile_shift", cell.get_center(), "ring", "Pattern offset, drag to slide the tiles"))
		out.append(handle("tile_scale", cell.end, "corner", "Pattern size, in whole pixels"))
		return out
	if Catalogue.can_resize(cid):
		var axes: String = String(Catalogue.resize_of(cid).get("axes", "xy"))
		out.append(handle("box", size if axes == "xy" else Vector2(size.x, size.y * 0.5), "corner", resize_name(cid)))
	for h: Dictionary in act_handles(cid, p, size):
		var hid: String = String(h["id"])
		if SIMPLE_IDS.has(hid):
			out.append(handle(hid, h["at"], String(SIMPLE_LOOKS.get(String(h["look"]), String(h["look"]))), String(h["name"])))
	return out


static func act_handles(cid: String, p: Dictionary, size: Vector2) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var tile: bool = Catalogue.is_tile(cid)
	var c: Vector2 = size * 0.5
	if tile or Catalogue.can_resize(cid):
		out.append_array(resize_handles(cid, size, tile))
	if tile:
		var cell: Rect2 = tile_cell(p, size)
		out.append(handle("tile_shift", cell.get_center(), "cross", "Pattern offset, drag to slide the tiles", {"act": "tile_shift"}))
		out.append(handle("tile_scale", cell.end, "diamond", "Pattern size, in whole pixels", {"act": "tile_scale"}))
		return out
	var art: Vector2 = Vector2(Art.art_size(p))
	var kv: Vector2 = Vector2(size.x / maxf(art.x, 1.0), size.y / maxf(art.y, 1.0))
	out.append(handle("scale", Vector2(c.x, size.y), "diamond", "Pixel size, drag up or down for bigger or smaller pixels", {"act": "scale", "push": Vector2(0.0, SCALE_PUSH)}))
	if Catalogue.moves_words(cid):
		out.append(handle("words", (words_anchor(cid, art) + Vector2(Art.nudge_of(p))) * kv, "cross", "Move the words", {"act": "words"}))
	if cid == "marquee":
		var step: int = clampi(int(p.get("step", 1)), 1, STEP_MAX)
		var sign_x: float = 1.0 if Bits.flows_right(p) else -1.0
		out.append(handle("flow", c + Vector2(sign_x * flow_length(step, kv.x), 0.0), "arrow", "Scroll direction and speed", {"act": "flow", "from": c}))
	elif cid == "arrows":
		var d: Vector2 = DIR_VECTORS[dir_index(p)]
		var reach: float = absf(d.x) * size.x * 0.5 + absf(d.y) * size.y * 0.5
		out.append(handle("point", c + d * reach, "arrow", "Which way the arrow points", {"act": "point", "from": c, "push": d * ARROW_PUSH}))
	elif cid == "counter":
		out.append(handle("digits", Vector2(size.x, c.y), "diamond", "Digits shown", {"act": "digits", "push": Vector2(DIGITS_PUSH, 0.0)}))
		if bool(p.get("counting", false)):
			out.append(handle("rate", Vector2(c.x, -rate_length(maxf(float(p.get("rate", 1.0)), 0.0), kv.y)), "arrow", "Counts per second", {"act": "rate", "from": Vector2(c.x, 0.0)}))
	elif cid == "bubble":
		var tip: int = Bits.tail_tip(p, int(art.x))
		out.append(handle("tail", Vector2((float(tip) + 0.5) * kv.x, size.y - 0.5 * kv.y), "dot", "Speech bubble tail", {"act": "tail"}))
	if is_frame(cid):
		out.append_array(frame_handles(cid, p, size, kv))
	return out


static func resize_handles(cid: String, size: Vector2, tile: bool) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var axes: String = "xy" if tile else String(Catalogue.resize_of(cid).get("axes", "xy"))
	var name: String = "Background size" if tile else resize_name(cid)
	var extra: Dictionary = {"act": "resize"}
	if is_frame(cid):
		extra["label"] = "Resize frame"
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)]
	if axes == "xy":
		for i: int in 4:
			var e: Dictionary = extra.duplicate()
			e["side"] = CORNER_SIDES[i]
			out.append(handle("c" + str(i), corners[i], "square", name, e))
	for j: int in 4:
		var side: Vector2i = EDGE_SIDES[j]
		if (side.x != 0 and not axes.contains("x")) or (side.y != 0 and not axes.contains("y")):
			continue
		var e2: Dictionary = extra.duplicate()
		e2["side"] = side
		out.append(handle("s" + str(j), (corners[j] + corners[(j + 1) % 4]) * 0.5, "square", name, e2))
	return out


static func frame_handles(cid: String, p: Dictionary, size: Vector2, kv: Vector2) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var art: Vector2i = Art.art_size(p)
	var title: Rect2i = Frames.title_rect(cid, art)
	var move: Dictionary = {"act": "move"}
	if title.size.x > 0:
		var tr: Rect2 = Rect2(Vector2(title.position) * kv, Vector2(title.size) * kv)
		out.append(handle("move", Vector2(tr.position.x + tr.size.x * 0.4, tr.get_center().y), "cross", "Drag the title bar to move the window", move))
	elif cid == "frame_pixel":
		out.append(handle("move", Vector2(size.x * 0.5, float(Frames.BAND) * 0.5 * kv.y), "cross", "Drag the border to move the frame", move))
	else:
		out.append(handle("move", Vector2(size.x * 0.5, 1.5 * kv.y), "cross", "Drag the edge to move the table", move))
	var r: Rect2i = Frames.inner_rect(cid, art)
	var inner: Rect2 = Rect2(Vector2(r.position) * kv, Vector2(r.size) * kv)
	out.append(handle("fit", inner.position + Vector2(12.0, 12.0), "button", "Fit the clip below inside the frame", {"act": "fit"}))
	if cid == "frame_pixel":
		var inset: float = float(Frames.BAND / 2)
		var sp: float = float(Frames.spacing_of(p))
		out.append(handle("spacing", Vector2((inset + sp + 0.5) * kv.x, (inset + 0.5) * kv.y), "dot", "Light spacing, drag along the border", {"act": "spacing"}))
	elif cid == "table_cell":
		var first: Rect2i = Frames.cell_rect(p, art, 0, 0)
		out.append(handle("cells", Vector2(first.end) * kv, "dot", "Number of cells, drag for more or fewer", {"act": "cells"}))
	return out


static func guides(id: String, size: Vector2, values: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var cid: String = cid_of(id)
	if cid.is_empty() or size.x < 1.0 or size.y < 1.0:
		return out
	var p: Dictionary = props_of(id, values)
	var tile: bool = Catalogue.is_tile(cid)
	if tile or Catalogue.can_resize(cid):
		out.append({"kind": "outline", "rect": Rect2(Vector2.ZERO, size), "name": "Layer edge"})
	if tile:
		out.append({"kind": "dash", "rect": tile_cell(p, size), "name": "One tile"})
	if is_frame(cid):
		out.append({"kind": "dash", "rect": inner_rect(PREFIX + cid, size, values), "name": "Inside the frame"})
	return out


static func quantise(lo: float, hi: float, side: int, unit: float, least: int, most: int, start_lo: float, start_hi: float) -> Vector2:
	var n: int = clampi(int(round((hi - lo) / maxf(unit, 0.0001))), least, most)
	var span: float = float(n) * unit
	if side > 0:
		return Vector2(start_lo, start_lo + span)
	if side < 0:
		return Vector2(start_hi - span, start_hi)
	var mid: float = (lo + hi) * 0.5
	return Vector2(mid - span * 0.5, mid + span * 0.5)


static func resize_drag(cid: String, p: Dictionary, size: Vector2, kv: Vector2, side: Vector2i, delta: Vector2, centred: bool) -> Dictionary:
	var tile: bool = Catalogue.is_tile(cid)
	var lo: Vector2 = Vector2.ZERO
	var hi: Vector2 = size
	if side.x > 0:
		hi.x += delta.x
	elif side.x < 0:
		lo.x += delta.x
	if side.y > 0:
		hi.y += delta.y
	elif side.y < 0:
		lo.y += delta.y
	if centred:
		if side.x > 0:
			lo.x -= delta.x
		elif side.x < 0:
			hi.x -= delta.x
		if side.y > 0:
			lo.y -= delta.y
		elif side.y < 0:
			hi.y -= delta.y
	var sx: int = 0 if centred else side.x
	var sy: int = 0 if centred else side.y
	var unit: Vector2 = Vector2.ONE if tile else kv
	var least: Vector2i = Vector2i(TILE_MIN, TILE_MIN)
	var most: Vector2i = Vector2i(TILE_MAX, TILE_MAX)
	if not tile:
		var r: Dictionary = Catalogue.resize_of(cid)
		least = Vector2i(int(r["min"][0]), int(r["min"][1]))
		most = Vector2i(int(r["max"][0]), int(r["max"][1]))
	var nx: Vector2 = Vector2(0.0, size.x)
	var ny: Vector2 = Vector2(0.0, size.y)
	if side.x != 0:
		nx = quantise(lo.x, hi.x, sx, unit.x, least.x, most.x, 0.0, size.x)
	if side.y != 0:
		ny = quantise(lo.y, hi.y, sy, unit.y, least.y, most.y, 0.0, size.y)
	var rect: Rect2 = Rect2(nx.x, ny.x, nx.y - nx.x, ny.y - ny.x)
	var shown: Vector2i = Vector2i(int(round(rect.size.x / unit.x)), int(round(rect.size.y / unit.y)))
	var out: Dictionary = {}
	if tile:
		out["width"] = shown.x
		out["height"] = shown.y
	else:
		if side.x != 0:
			out[Catalogue.BOX_W] = shown.x
		if side.y != 0:
			out[Catalogue.BOX_H] = shown.y
		var q: Dictionary = p.duplicate()
		for k: Variant in out.keys():
			q[k] = out[k]
		var real: Vector2 = Vector2(Art.art_size(q)) * kv
		out["width"] = int(round(real.x))
		out["height"] = int(round(real.y))
	out["rect"] = rect
	out["chip"] = "%d x %d pixels" % [shown.x, shown.y]
	return out


static func drag(id: String, handle_id: String, at: Vector2, size: Vector2, values: Dictionary, how: Dictionary = {}) -> Dictionary:
	var cid: String = cid_of(id)
	if cid.is_empty() or size.x < 1.0 or size.y < 1.0:
		return {}
	var p: Dictionary = props_of(id, values)
	var art: Vector2 = Vector2(Art.art_size(p))
	var kv: Vector2 = Vector2(size.x / maxf(art.x, 1.0), size.y / maxf(art.y, 1.0))
	var c: Vector2 = size * 0.5
	if handle_id == "box" and Catalogue.can_resize(cid):
		var r: Dictionary = Catalogue.resize_of(cid)
		var axes: String = String(r.get("axes", "xy"))
		var box: Dictionary = {"box_w": clampi(int(round(at.x / kv.x)), int(r["min"][0]), int(r["max"][0]))}
		if axes.contains("y"):
			box["box_h"] = clampi(int(round(at.y / kv.y)), int(r["min"][1]), int(r["max"][1]))
		return box
	var g: Dictionary = {}
	for h: Dictionary in act_handles(cid, p, size):
		if String(h["id"]) == handle_id:
			g = h
	if g.is_empty():
		return {}
	var press: Vector2 = how.get("press", g["at"])
	var delta: Vector2 = at - press
	var act: String = String(g.get("act", ""))
	if act == "resize":
		return resize_drag(cid, p, size, kv, g.get("side", Vector2i.ZERO), delta, bool(how.get("alt", false)))
	if act == "tile_shift":
		var k: float = tile_k(p, size)
		var o0: Vector2 = Vector2(float(p.get("tile_x", 0)), float(p.get("tile_y", 0)))
		var o: Vector2i = Vector2i(posmod(int(round(o0.x + delta.x / k)), maxi(int(art.x), 1)), posmod(int(round(o0.y + delta.y / k)), maxi(int(art.y), 1)))
		return {"tile_x": o.x, "tile_y": o.y, "chip": "Tiles slid %d, %d pixels" % [o.x, o.y]}
	if act == "tile_scale":
		var q: float = size.y / BASE_H
		var reach: Vector2 = at - tile_cell(p, size).position
		var nk: int = clampi(int(round(maxf(reach.x / maxf(art.x * q, 0.0001), reach.y / maxf(art.y * q, 0.0001)))), 1, SCALE_MAX)
		return {"scale": nk, "chip": "Pattern size %dx" % nk}
	if act == "scale":
		var was: float = press.y - c.y
		if absf(was) < 1.0:
			return {}
		var pk: int = clampi(int(round(kv.y * (at.y - c.y) / was)), 1, SCALE_MAX)
		var ns: Vector2 = art * float(pk)
		return {"width": int(round(ns.x)), "height": int(round(ns.y)), "rect": Rect2(c - ns * 0.5, ns), "chip": "Pixel size %dx" % pk}
	if act == "words":
		var n0: Vector2i = Art.nudge_of(p)
		var lim: Vector2i = Vector2i(mini(int(art.x / 2.0), NUDGE_MAX), mini(int(art.y / 2.0), NUDGE_MAX))
		var n: Vector2i = Vector2i(clampi(n0.x + int(round(delta.x / kv.x)), -lim.x, lim.x), clampi(n0.y + int(round(delta.y / kv.y)), -lim.y, lim.y))
		return {"text_dx": n.x, "text_dy": n.y, "chip": "Words moved %d, %d pixels" % [n.x, n.y]}
	if act == "flow":
		var dx: float = at.x - c.x
		var flow: String = "right" if dx > 0.0 else "left"
		var st: int = clampi(int(round((absf(dx) / kv.x - FLOW_BASE) / FLOW_PER_STEP)), 1, STEP_MAX)
		return {"flow": flow, "step": st, "chip": "Scrolls %s, %d %s a frame" % [flow, st, "pixel" if st == 1 else "pixels"]}
	if act == "point":
		var v: Vector2 = at - c
		var dir: String = ("right" if v.x >= 0.0 else "left") if absf(v.x) >= absf(v.y) else ("down" if v.y >= 0.0 else "up")
		var turned: Dictionary = p.duplicate()
		turned["direction"] = dir
		var size2: Vector2 = Vector2(Art.art_size(turned)) * kv
		return {"direction": dir, "width": int(round(size2.x)), "height": int(round(size2.y)), "rect": Rect2(c - size2 * 0.5, size2), "chip": "Points " + dir}
	if act == "digits":
		var digits: int = clampi(int(round(((size.x + delta.x) / kv.x - 5.0) / 10.0)), 1, DIGITS_MAX)
		var counted: Dictionary = p.duplicate()
		counted["digits"] = digits
		var w: float = float(Art.art_size(counted).x) * kv.x
		return {"digits": digits, "width": int(round(w)), "rect": Rect2(0.0, 0.0, w, size.y), "chip": "%d %s" % [digits, "digit" if digits == 1 else "digits"]}
	if act == "rate":
		var up: float = maxf(-at.y / kv.y, 0.0)
		var rate: float = clampf(pow(2.0, (up - RATE_BASE) / RATE_PER_DOUBLE) - 1.0, 0.0, RATE_MAX)
		rate = snappedf(rate, 0.1) if rate < 10.0 else roundf(rate)
		return {"rate": rate, "chip": "%s counts a second" % String.num(rate, 1).trim_suffix(".0")}
	if act == "tail":
		var tip: int = clampi(int(round(at.x / kv.x - 0.5)), 3, maxi(int(art.x) - 4, 3))
		return {"tail_x": tip, "chip": "Tail at %d pixels" % tip}
	if act == "spacing":
		var inset: float = float(Frames.BAND / 2)
		var sp: int = clampi(int(round(at.x / kv.x - 0.5 - inset)), Frames.SPACING_MIN, Frames.SPACING_MAX)
		return {"spacing": sp, "chip": "A light every %d pixels" % sp}
	if act == "cells":
		var gap: float = float(Frames.CELL_GAP)
		var cw: float = maxf(at.x / kv.x - 3.0 - gap, 1.0)
		var ch: float = maxf(at.y / kv.y - 3.0 - gap, 1.0)
		var cols: int = clampi(int(round((art.x - 6.0 - gap) / (cw + gap))), 1, mini(Frames.CELLS_MAX, max_cells(art.x)))
		var rows: int = clampi(int(round((art.y - 6.0 - gap) / (ch + gap))), 1, mini(Frames.CELLS_MAX, max_cells(art.y)))
		return {"cols": cols, "rows": rows, "chip": "%d across, %d down" % [cols, rows]}
	return {}


static func style(id: String, label: String, detail: String, look: Dictionary) -> Dictionary:
	return {"id": id, "label": label, "group": LABEL, "detail": detail, "look": look, "effects": []}


static func text_styles() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	out.append(style("old_web_page_title", "Homepage title", "Bold purple serif letters, the big title at the top of a 1999 homepage", {"font": "Times New Roman", "bold": true, "colour": [0.6, 0.0, 0.6, 1.0], "align": "center"}))
	out.append(style("old_web_page_words", "Homepage words", "Plain blue serif words, the hello under the title", {"font": "Times New Roman", "colour": [0.0, 0.0, 0.8, 1.0], "align": "center"}))
	out.append(style("old_web_visitor_words", "Visitor words", "Plain black serif words over the hit counter", {"font": "Times New Roman", "colour": [0.0, 0.0, 0.0, 1.0], "align": "center"}))
	out.append(style("old_web_link_words", "Link words", "Bold blue serif words under a link picture", {"font": "Times New Roman", "bold": true, "colour": [0.0, 0.0, 0.8, 1.0], "align": "center"}))
	return out


static func page_rect(box: Vector2, pos: Vector2) -> Array:
	var x: float = BASE_W * 0.5 + pos.x - box.x * 0.5
	var y: float = BASE_H * 0.5 + pos.y - box.y * 0.5
	return [x, y, box.x, box.y]


static func text_box(text: String, px: float) -> Vector2:
	var lines: PackedStringArray = text.split("\n")
	var longest: int = 1
	for ln: String in lines:
		longest = maxi(longest, ln.length())
	var w: float = minf(ceil(px * float(longest) * 0.56) + px * 2.0, PAGE_W - TEXT_MARGIN)
	var h: float = ceil(px * float(lines.size()) / 0.72) + 1.0
	return Vector2(w, h)


static func layouts() -> Array[Dictionary]:
	var pieces: Array = []
	for st: Dictionary in PAGE_STEPS:
		var pos: Vector2 = Vector2(float(st["pos"][0]), float(st["pos"][1]))
		if st.has("page"):
			var box0: Vector2 = Vector2(float(st["box"][0]), float(st["box"][1]))
			pieces.append({"object": PAGE_ID, "rect": page_rect(box0, pos), "values": {"colour_a": (st["colour"] as Array).duplicate()}, "label": String(st["page"])})
			continue
		var oid: String = PREFIX + String(st["object"])
		var box: Vector2 = Vector2(size_for(oid, {}))
		if st.has("box"):
			box = Vector2(float(st["box"][0]), float(st["box"][1]))
		pieces.append({"object": oid, "rect": page_rect(box, pos), "values": {}})
	var texts: Array = []
	for tx: Dictionary in PAGE_TEXTS:
		var tb: Vector2 = text_box(String(tx["text"]), float(tx["size"]))
		texts.append({"style": String(tx["style"]), "text": String(tx["text"]), "rect": page_rect(tb, Vector2(float(tx["pos"][0]), float(tx["pos"][1]))), "align": "center"})
	return [{"id": "homepage_1999", "label": "1999 homepage", "pieces": pieces, "texts": texts}]
