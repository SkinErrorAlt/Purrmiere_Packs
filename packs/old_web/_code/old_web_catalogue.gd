extends RefCounted

const PATTERN := "oldweb"
const ID_PROP := "oldweb"
const SCALE_PROP := "art_scale"
const FPS_PROP := "anim_fps"
const CRISP_PROP := "pixel_crisp"
const GROUPS: PackedStringArray = ["Banners", "Dividers", "Backgrounds", "Small objects", "Stamps", "Frames", "Layouts"]
const LAYOUT_ID := "homepage_1999"
const YELLOW := [1.0, 0.8, 0.0, 1.0]
const NAVY := [0.0, 0.0, 0.2, 1.0]
const WHITE := [1.0, 1.0, 1.0, 1.0]
const STAMP_SIZE := [32, 32]
const BUTTON_SIZE := [88, 31]
const BOX_W := "box_w"
const BOX_H := "box_h"
const RESIZE: Dictionary = {
	"win_browser": {"axes": "xy", "min": [200, 130], "max": [1200, 900]},
	"win_dialog": {"axes": "xy", "min": [130, 64], "max": [900, 600]},
	"frame_pixel": {"axes": "xy", "min": [32, 32], "max": [1200, 900]},
	"table_cell": {"axes": "xy", "min": [40, 40], "max": [1200, 900]},
	"div_crayon": {"axes": "x", "min": [60, 18], "max": [1600, 18]},
	"div_rainbow": {"axes": "x", "min": [24, 6], "max": [1600, 6]},
	"div_flame": {"axes": "xy", "min": [24, 10], "max": [1600, 120]},
	"div_sparkle": {"axes": "x", "min": [30, 14], "max": [1600, 14]},
	"div_chain": {"axes": "x", "min": [20, 12], "max": [1600, 12]},
	"div_bevel": {"axes": "x", "min": [8, 4], "max": [1600, 4]},
	"banner_night": {"axes": "xy", "min": [120, 40], "max": [960, 240]},
	"banner_rainbow": {"axes": "x", "min": [160, 48], "max": [960, 48]},
	"banner_glitter": {"axes": "xy", "min": [120, 32], "max": [960, 240]},
	"banner_chrome": {"axes": "xy", "min": [120, 40], "max": [960, 240]},
	"construct_digger": {"axes": "x", "min": [200, 60], "max": [960, 60]},
	"webring": {"axes": "x", "min": [200, 42], "max": [960, 42]},
	"marquee": {"axes": "x", "min": [80, 14], "max": [1600, 14]},
	"cursor_trail": {"axes": "xy", "min": [60, 40], "max": [960, 540]},
}
const WORDS: PackedStringArray = ["banner_night", "banner_glitter", "banner_chrome", "new_burst", "award", "btn_html", "btn_browser", "btn_guestbook", "btn_y2k", "btn_handmade", "webring", "guestbook"]


static func e(id: String, group: String, label: String, size: Array, scale: int, frames: int, fps: float, fields: Array, defaults: Dictionary = {}, extra: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {"id": id, "group": group, "label": label, "size": size, "scale": scale, "frames": frames, "fps": fps, "fields": fields, "defaults": defaults}
	for k: Variant in extra.keys():
		out[k] = extra[k]
	return out


static func entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	out.append(e("banner_night", "Banners", "Welcome banner, night skyline", [240, 56], 2, 8, 8.0, ["text", "colour_a", "colour_b"], {"text": "WELCOME", "colour_a": YELLOW, "colour_b": [0.0, 0.0, 0.2, 1.0]}))
	out.append(e("banner_rainbow", "Banners", "Welcome banner, rainbow", [256, 48], 2, 12, 10.0, ["text", "colour_b"], {"text": "WELCOME", "colour_b": WHITE}))
	out.append(e("banner_glitter", "Banners", "Welcome banner, glitter", [256, 56], 2, 8, 10.0, ["text", "colour_a", "colour_b"], {"text": "WELCOME", "colour_a": [1.0, 0.4, 0.8, 1.0], "colour_b": [0.15, 0.0, 0.25, 1.0]}))
	out.append(e("banner_chrome", "Banners", "Welcome banner, chrome", [256, 56], 2, 16, 12.0, ["text", "colour_b"], {"text": "WELCOME", "colour_b": [0.0, 0.0, 0.3, 1.0]}))
	out.append(e("construct_digger", "Banners", "Under construction, digger", [240, 60], 2, 8, 10.0, ["text", "text2"], {"text": "UNDER", "text2": "CONSTRUCTION"}))
	out.append(e("construct_cone", "Banners", "Under construction, cone", [120, 84], 2, 8, 8.0, ["text", "text2"], {"text": "UNDER", "text2": "CONSTRUCTION"}))
	out.append(e("new_burst", "Banners", "New! burst", [64, 48], 2, 6, 8.0, ["text", "colour_a", "colour_b"], {"text": "NEW!", "colour_a": [1.0, 0.0, 0.0, 1.0], "colour_b": [1.0, 1.0, 0.0, 1.0]}))
	out.append(e("award", "Banners", "Neat page award badge", [104, 112], 2, 8, 8.0, ["text", "text2", "colour_a"], {"text": "NEAT PAGE", "text2": "OF THE DAY", "colour_a": [0.0, 0.2, 0.8, 1.0]}))
	out.append(e("div_crayon", "Dividers", "Crayon line", [320, 18], 2, 1, 8.0, []))
	out.append(e("div_rainbow", "Dividers", "Rainbow rule", [400, 6], 2, 12, 10.0, []))
	out.append(e("div_flame", "Dividers", "Flame bar", [320, 24], 2, 8, 12.0, []))
	out.append(e("div_sparkle", "Dividers", "Sparkle line", [320, 14], 2, 8, 10.0, ["colour_a"], {"colour_a": [1.0, 0.4, 1.0, 1.0]}))
	out.append(e("div_chain", "Dividers", "Pixel chain", [320, 12], 2, 8, 10.0, []))
	out.append(e("div_bevel", "Dividers", "Beveled grey rule", [400, 4], 2, 1, 8.0, []))
	out.append(e("bg_crayon", "Backgrounds", "Crayon scribble tile", [64, 64], 2, 1, 8.0, [], {}, {"tile": true}))
	out.append(e("bg_stars", "Backgrounds", "Starfield tile", [64, 64], 2, 8, 8.0, ["colour_b"], {"colour_b": [0.0, 0.0, 0.0, 1.0]}, {"tile": true}))
	out.append(e("bg_nebula", "Backgrounds", "Space nebula tile", [128, 128], 2, 1, 8.0, [], {}, {"tile": true}))
	out.append(e("bg_marble", "Backgrounds", "Marble tile", [96, 96], 2, 1, 8.0, ["colour_a"], {"colour_a": [0.4, 0.45, 0.6, 1.0]}, {"tile": true}))
	out.append(e("bg_parchment", "Backgrounds", "Parchment tile", [96, 96], 2, 1, 8.0, ["colour_a"], {"colour_a": [0.95, 0.85, 0.62, 1.0]}, {"tile": true}))
	out.append(e("bg_purple", "Backgrounds", "Dark purple dither tile", [8, 8], 2, 1, 8.0, ["colour_a"], {"colour_a": [0.2, 0.0, 0.25, 1.0]}, {"tile": true}))
	out.append(e("bg_stripes", "Backgrounds", "Rainbow stripes tile", [48, 48], 2, 12, 10.0, [], {}, {"tile": true}))
	out.append(e("bg_clouds", "Backgrounds", "Clouds tile", [128, 96], 2, 1, 8.0, ["colour_b"], {"colour_b": [0.4, 0.6, 1.0, 1.0]}, {"tile": true}))
	out.append(e("btn_html", "Small objects", "88x31 button, valid HTML", BUTTON_SIZE, 2, 1, 8.0, ["text", "text2"], {"text": "VALID", "text2": "HTML 4.01"}))
	out.append(e("btn_browser", "Small objects", "88x31 button, best viewed in any browser", BUTTON_SIZE, 2, 8, 8.0, ["text", "text2"], {"text": "BEST VIEWED IN", "text2": "ANY BROWSER"}))
	out.append(e("btn_guestbook", "Small objects", "88x31 button, sign my guestbook", BUTTON_SIZE, 2, 8, 8.0, ["text", "text2"], {"text": "SIGN MY", "text2": "GUESTBOOK"}))
	out.append(e("btn_y2k", "Small objects", "88x31 button, Y2K ready", BUTTON_SIZE, 2, 8, 8.0, ["text", "text2"], {"text": "Y2K", "text2": "READY!"}))
	out.append(e("btn_handmade", "Small objects", "88x31 button, hand coded", BUTTON_SIZE, 2, 8, 8.0, ["text", "text2"], {"text": "HAND CODED", "text2": "WITH LOVE"}))
	out.append(e("counter", "Small objects", "Hit counter", [65, 17], 2, 1, 12.0, ["number", "digits", "counting", "rate"], {"number": 4527, "digits": 6, "counting": false, "rate": 1.0}, {"live": true}))
	out.append(e("email", "Small objects", "Spinning email envelope", [32, 32], 2, 12, 12.0, []))
	out.append(e("mailbox", "Small objects", "Mailbox", [40, 40], 2, 8, 8.0, []))
	out.append(e("new_blink", "Small objects", "Blinking NEW", [30, 13], 2, 8, 8.0, ["text"], {"text": "NEW"}))
	out.append(e("globe", "Small objects", "Spinning globe", [32, 32], 2, 16, 12.0, []))
	out.append(e("arrows", "Small objects", "Bouncing arrow", [40, 24], 2, 8, 12.0, ["direction", "colour_a"], {"direction": "right", "colour_a": [1.0, 0.8, 0.0, 1.0]}))
	out.append(e("webring", "Small objects", "Webring bar", [300, 42], 2, 8, 8.0, ["text"], {"text": "Webring"}))
	out.append(e("marquee", "Small objects", "Marquee text strip", [300, 14], 2, 1, 15.0, ["text", "colour_a", "colour_b", "step"], {"text": "*** Welcome to my corner of the web! Thanks for stopping by, come back soon! ***", "colour_a": [1.0, 1.0, 0.0, 1.0], "colour_b": NAVY, "step": 1}, {"live": true}))
	out.append(e("guestbook", "Small objects", "Guestbook sign", [120, 72], 2, 8, 8.0, ["text"], {"text": "Sign my Guestbook!"}))
	out.append(e("cursor_trail", "Small objects", "Cursor sparkle trail", [200, 120], 2, 24, 12.0, []))
	out.append(e("bubble", "Small objects", "Speech bubble", [80, 40], 2, 1, 8.0, ["text", "colour_a", "colour_b"], {"text": "I made this page|all by myself!", "colour_a": [0.0, 0.0, 0.0, 1.0], "colour_b": WHITE}, {"auto_size": true}))
	for st: Array in [["star", "Star"], ["eye", "Eye"], ["check", "Check mark"], ["coin", "Coin"], ["house", "House"], ["skull", "Skull"], ["no", "No sign"], ["arrow", "Down arrow"], ["happy", "Smiley, happy"], ["sad", "Smiley, sad"], ["angry", "Smiley, angry"], ["shocked", "Smiley, shocked"], ["laughing", "Smiley, laughing"], ["cool", "Smiley, cool"]]:
		var moving: bool = String(st[0]) == "coin" or String(st[0]) == "eye"
		out.append(e("stamp_" + String(st[0]), "Stamps", "Stamp, " + String(st[1]).to_lower(), STAMP_SIZE, 2, 8 if moving else 1, 8.0, ["framed"], {"framed": true}))
	out.append(e("win_browser", "Frames", "Retro browser window", [320, 240], 2, 8, 8.0, ["text", "text2", "colour_a"], {"text": "My Cool Homepage", "text2": "http://www.example.com/~me/", "colour_a": [0.4, 0.0, 0.6, 1.0]}))
	out.append(e("win_dialog", "Frames", "Retro desktop dialog", [200, 92], 2, 1, 8.0, ["text", "text2", "colour_a"], {"text": "Message", "text2": "Are you sure you want to leave my page? There is more to see!", "colour_a": [0.4, 0.0, 0.6, 1.0]}))
	out.append(e("frame_pixel", "Frames", "Pixel border frame with lights", [160, 120], 2, 8, 8.0, ["colour_a", "colour_b"], {"colour_a": [0.6, 0.0, 0.6, 1.0], "colour_b": [1.0, 0.8, 0.0, 1.0]}))
	out.append(e("table_cell", "Frames", "Beveled table cells", [200, 120], 2, 1, 8.0, ["colour_a", "filled"], {"colour_a": [0.75, 0.75, 0.75, 1.0], "filled": true}))
	out.append(e(LAYOUT_ID, "Layouts", "1999 homepage", [720, 540], 2, 1, 8.0, [], {}, {"layout": true}))
	return out


static func entry(id: String) -> Dictionary:
	for d: Dictionary in entries():
		if String(d["id"]) == id:
			return d
	return {}


static func ids() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for d: Dictionary in entries():
		out.append(String(d["id"]))
	return out


static func is_tile(id: String) -> bool:
	return bool(entry(id).get("tile", false))


static func is_layout(id: String) -> bool:
	return bool(entry(id).get("layout", false))


static func resize_of(id: String) -> Dictionary:
	return RESIZE.get(id, {})


static func can_resize(id: String) -> bool:
	return RESIZE.has(id)


static func moves_words(id: String) -> bool:
	return WORDS.has(id)


static func props_for(id: String) -> Dictionary:
	var d: Dictionary = entry(id)
	if d.is_empty():
		return {}
	var p: Dictionary = {"pattern": PATTERN, ID_PROP: id, SCALE_PROP: int(d["scale"]), FPS_PROP: float(d["fps"]), CRISP_PROP: true}
	var defs: Dictionary = d["defaults"]
	for k: Variant in defs.keys():
		var v: Variant = defs[k]
		p[k] = (v as Array).duplicate() if v is Array else v
	return p
