extends Control

var pack: GDScript = null
var object_id: String = ""
var values: Dictionary = {}
var t: float = 0.0
var texts: Array = []
var font: Font = null


func _draw() -> void:
	if pack == null:
		return
	if not object_id.is_empty():
		pack.call("draw", object_id, self, size, t, values)
		return
	for tx: Dictionary in texts:
		var r: Array = tx["rect"]
		var lines: PackedStringArray = String(tx["text"]).split("\n")
		var px: int = int(tx["px"])
		var col: Array = tx["colour"]
		var f: Font = tx["font"]
		var asc: float = f.get_ascent(px)
		var lh: float = f.get_height(px)
		var top: float = float(r[1]) + (float(r[3]) - lh * float(lines.size())) * 0.5
		for i: int in lines.size():
			var w: float = f.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			draw_string(f, Vector2(float(r[0]) + (float(r[2]) - w) * 0.5, top + asc + lh * float(i)), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, px, Color(float(col[0]), float(col[1]), float(col[2]), float(col[3])))
