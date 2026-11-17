extends SceneTree

const PACK_REL := "packs/old_web/_code/pack.gd"
const CATALOGUE_REL := "packs/old_web/_code/old_web_catalogue.gd"
const CANVAS_REL := "tools/old_web_canvas.gd"
const OUT_REL := "tools/_render/old_web"
const TILE_W := 480
const TILE_H := 270
const MARQUEE_CAP := 150
const LAYOUT_FRAMES := 12
const LAYOUT_FPS := 6.0

var pack: GDScript = null
var repo: String = ""
var canvas_path: String = ""
var out_dir: String = ""
var vp: SubViewport = null
var canvas: Control = null


func _initialize() -> void:
	_run()


func _frame(id: String, values: Dictionary, size: Vector2i, t: float) -> Image:
	vp.size = size
	canvas.size = Vector2(size)
	canvas.set("object_id", id)
	canvas.set("values", values)
	canvas.set("t", t)
	canvas.queue_redraw()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img


func _run() -> void:
	await process_frame
	repo = (get_script() as GDScript).resource_path.get_base_dir().get_base_dir()
	canvas_path = repo.path_join(CANVAS_REL)
	out_dir = repo.path_join(OUT_REL)
	pack = load(repo.path_join(PACK_REL))
	vp = SubViewport.new()
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	canvas = (load(canvas_path) as GDScript).new()
	canvas.set("pack", pack)
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vp.add_child(canvas)
	root.add_child(vp)
	DirAccess.make_dir_recursive_absolute(out_dir)
	var catalogue: GDScript = load(repo.path_join(CATALOGUE_REL))
	var cat: Dictionary = {}
	for c: Dictionary in catalogue.call("entries"):
		cat[String(c["id"])] = c
	var items: Array = []
	for e: Dictionary in pack.call("entries"):
		var id: String = String(e["id"])
		var cid: String = String(e["old_web"])
		var item_id: String = cid if not cid.is_empty() else "page"
		var defaults: Dictionary = {}
		for f: Dictionary in e["fields"]:
			defaults[String(f["key"])] = f["default"]
		var size: Vector2i = pack.call("size_for", id, defaults)
		var values: Dictionary = defaults.duplicate(true)
		var frames: int = int(e["frames"])
		var fps: float = float(e["fps"])
		var lp: float = float(e["loop"])
		if bool(e["full_frame"]):
			size = Vector2i(TILE_W, TILE_H)
			values["scale"] = int(values.get("scale", 2)) * 1080 / TILE_H
		if id == "old_web_page":
			size = Vector2i(96, 72)
		if cid == "marquee":
			frames = MARQUEE_CAP
		var dir: String = out_dir.path_join(item_id)
		DirAccess.make_dir_recursive_absolute(dir)
		for f2: int in frames:
			var clock: float = (float(f2) + 0.5) / fps
			var t: float = fposmod(clock, lp) if lp > 0.0 else clock
			var img: Image = await _frame(id, values, size, t)
			img.save_png(dir.path_join("%04d.png" % f2))
		var row: Dictionary = e.duplicate(true)
		row["item"] = item_id
		row["catalogue"] = cat.get(cid, {})
		row["preview_frames"] = frames
		row["preview_size"] = [size.x, size.y]
		items.append(row)
	var lay: Dictionary = (pack.call("layouts") as Array)[0]
	var styles: Dictionary = {}
	for st: Dictionary in pack.call("text_styles"):
		styles[String(st["id"])] = st
	var ldir: String = out_dir.path_join("homepage_1999")
	DirAccess.make_dir_recursive_absolute(ldir)
	var big: SubViewport = SubViewport.new()
	big.size = Vector2i(1920, 1080)
	big.transparent_bg = false
	big.disable_3d = true
	big.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(big)
	var back: ColorRect = ColorRect.new()
	back.color = Color(0.0, 0.0, 0.0, 1.0)
	back.size = Vector2(1920, 1080)
	big.add_child(back)
	var parts: Array = []
	for p: Dictionary in lay["pieces"]:
		var c: Control = (load(canvas_path) as GDScript).new()
		c.set("pack", pack)
		c.set("object_id", String(p["object"]))
		var defs: Dictionary = {}
		for f3: Dictionary in pack.call("entries"):
			if String(f3["id"]) == String(p["object"]):
				for fd: Dictionary in f3["fields"]:
					defs[String(fd["key"])] = fd["default"]
		for k: Variant in (p["values"] as Dictionary).keys():
			defs[k] = p["values"][k]
		c.set("values", defs)
		c.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var r: Array = p["rect"]
		c.position = Vector2(float(r[0]), float(r[1]))
		c.size = Vector2(float(r[2]), float(r[3]))
		big.add_child(c)
		parts.append(c)
	var words: Control = (load(canvas_path) as GDScript).new()
	words.set("pack", pack)
	words.size = Vector2(1920, 1080)
	var tlist: Array = []
	for tx: Dictionary in lay["texts"]:
		var look: Dictionary = (styles[String(tx["style"])] as Dictionary)["look"]
		var sf: SystemFont = SystemFont.new()
		sf.font_names = PackedStringArray([String(look["font"]), "serif"])
		sf.font_weight = 700 if bool(look.get("bold", false)) else 400
		var lines: PackedStringArray = String(tx["text"]).split("\n")
		var longest: int = 1
		for ln: String in lines:
			longest = maxi(longest, ln.length())
		var r2: Array = tx["rect"]
		var px: float = clampf(minf(float(r2[3]) * 0.72 / float(lines.size()), float(r2[2]) / (float(longest) * 0.56)), 10.0, 600.0)
		tlist.append({"rect": r2, "text": String(tx["text"]), "px": int(round(px)), "colour": look["colour"], "font": sf})
	words.set("texts", tlist)
	big.add_child(words)
	for lf: int in LAYOUT_FRAMES:
		var lt: float = (float(lf) + 0.5) / LAYOUT_FPS
		for c2: Control in parts:
			var oid: String = String(c2.get("object_id"))
			var lpp: float = 0.0
			for f4: Dictionary in pack.call("entries"):
				if String(f4["id"]) == oid:
					lpp = float(f4["loop"])
			c2.set("t", fposmod(lt, lpp) if lpp > 0.0 else lt)
			c2.queue_redraw()
		words.queue_redraw()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var li: Image = big.get_texture().get_image()
		li.convert(Image.FORMAT_RGBA8)
		li.save_png(ldir.path_join("%04d.png" % lf))
	var out: Dictionary = {"items": items, "layout": lay, "styles": pack.call("text_styles"), "layout_frames": LAYOUT_FRAMES, "layout_fps": LAYOUT_FPS, "info": pack.call("info")}
	var fa: FileAccess = FileAccess.open(out_dir.path_join("export.json"), FileAccess.WRITE)
	fa.store_string(JSON.stringify(out, "  ", false))
	fa.close()
	big.free()
	vp.free()
	print("old_web_render: %d pieces and the homepage written to %s" % [items.size(), out_dir])
	quit(0)
