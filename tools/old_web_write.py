import json
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_catalog as bc

OUT = Path(__file__).resolve().parent / "_render" / "old_web"
PACK = Path(__file__).resolve().parent.parent / "packs" / "old_web"


def gif_or_png(frames, fps, dst_base):
    for old in (dst_base.with_suffix(".gif"), dst_base.with_suffix(".png")):
        if old.exists():
            old.unlink()
    if len(frames) == 1:
        frames[0].save(dst_base.with_suffix(".png"), "PNG", optimize=False)
        return dst_base.with_suffix(".png")
    gif = [bc.to_gif_frame(f) for f in frames]
    ms = int(round(1000.0 / fps))
    gif[0].save(dst_base.with_suffix(".gif"), "GIF", save_all=True, append_images=gif[1:], duration=ms, loop=0, disposal=2, transparency=255, optimize=False)
    return dst_base.with_suffix(".gif")


if not (OUT / "export.json").is_file():
    raise SystemExit("old_web_write: run tools/old_web_render.gd in Godot first (it writes " + str(OUT) + ")")
data = json.loads((OUT / "export.json").read_text(encoding="utf-8"))
meta = {}
order = 0
for row in data["items"]:
    iid = row["item"]
    folder = PACK / bc.folder_of(row["group"])
    folder.mkdir(parents=True, exist_ok=True)
    piece = {k: v for k, v in row.items() if k not in ("item", "preview_frames", "preview_size")}
    (folder / (iid + ".json")).write_text(bc.pretty(piece), encoding="utf-8", newline="\n")
    frames = [Image.open(OUT / iid / ("%04d.png" % i)).convert("RGBA") for i in range(row["preview_frames"])]
    gif_or_png(frames, row["fps"], folder / iid)
    tags = ["old web", row["group"].lower()]
    if row["loop"] > 0 or row["live"]:
        tags.append("animated")
    extra = {"object": row["id"], "size": row["size"], "full_frame": row["full_frame"], "loop": row["loop"], "frames": row["frames"], "fps": row["fps"], "live": row["live"]}
    meta[iid] = {"label": row["label"], "order": order, "tags": tags, "extra": extra}
    order += 1
lay = data["layout"]
ldir = PACK / "layouts"
ldir.mkdir(parents=True, exist_ok=True)
(ldir / (lay["id"] + ".json")).write_text(bc.pretty({"layout": lay, "text_styles": data["styles"]}), encoding="utf-8", newline="\n")
lframes = []
for i in range(data["layout_frames"]):
    im = Image.open(OUT / "homepage_1999" / ("%04d.png" % i)).convert("RGBA")
    lframes.append(im.crop((240, 0, 1680, 1080)).resize((360, 270), Image.Resampling.LANCZOS))
gif_or_png(lframes, data["layout_fps"], ldir / lay["id"])
meta[lay["id"]] = {"label": lay["label"], "order": order, "tags": ["old web", "layouts", "starter scene"], "extra": {"layout": lay["id"], "pieces": len(lay["pieces"]), "texts": len(lay["texts"])}}
lines = ["{", '  "items": {']
keys = list(meta.keys())
for j, k in enumerate(keys):
    lines.append("    " + json.dumps(k) + ": " + bc.dumps(meta[k]) + ("," if j < len(keys) - 1 else ""))
lines.append("  }")
lines.append("}")
(PACK / "items_meta.json").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
print(len(meta), "items written")
