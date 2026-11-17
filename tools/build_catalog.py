import argparse
import datetime
import hashlib
import io
import json
import math
import re
import sys
from pathlib import Path

from PIL import Image, ImageSequence

ROOT = Path(__file__).resolve().parent.parent
PACKS = ROOT / "packs"
CATALOG = ROOT / "catalog.json"
FORMAT = 1
MAX_FILE = 50 * 1024 * 1024
THUMB = 128
PREVIEW_W = 512
PREVIEW_H = 288
BACKDROP = (30, 30, 34, 255)
MIN_DELAY_MS = 20
SLOW_DELAY_MS = 100
PACK_KINDS = ("assets", "code", "effects", "voices", "text_styles", "text_anims")
ITEM_KINDS = ("picture", "animated", "piece", "effect", "voice", "text_style", "text_anim")
KIND_OF_PACK = {"code": "piece", "effects": "effect", "voices": "voice", "text_styles": "text_style", "text_anims": "text_anim"}
IMAGE_EXTS = (".png", ".apng", ".gif", ".jpg", ".jpeg", ".webp", ".bmp")
DATA_EXTS = (".json",)
ROOT_FILES = ("pack.json", "items.json", "items_meta.json", "_preview.png")
SKIP_FILES = ("Thumbs.db", ".DS_Store", "desktop.ini")
PACK_REQUIRED = {"id": str, "label": str, "kind": str, "about": str, "source": str, "licence": str, "groups": list}
PACK_OPTIONAL = {"era": str, "order": int, "min_purrmiere": int, "crisp": bool}
META_KEYS = ("label", "tags", "url", "kind", "extra", "order")
ID_RE = re.compile(r"^[a-z][a-z0-9_]*$")


class Problems:
    def __init__(self):
        self.lines = []

    def add(self, where, what):
        self.lines.append(where + ": " + what)

    def any(self):
        return len(self.lines) > 0


def slug(text):
    out = []
    bar = False
    for c in text.lower():
        if ("a" <= c <= "z") or ("0" <= c <= "9"):
            out.append(c)
            bar = False
        elif not bar and out:
            out.append("_")
            bar = True
    return "".join(out).strip("_")


def natural(text):
    return [int(p) if p.isdigit() else p for p in re.split(r"(\d+)", text.lower())]


def folder_of(group):
    return group.lower().replace(" ", "_")


def rel(path):
    return path.relative_to(ROOT).as_posix()


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def read_json(path, problems):
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        problems.add(rel(path), "is not UTF-8 text")
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError as e:
        problems.add(rel(path), "is not valid JSON (line %d, column %d: %s)" % (e.lineno, e.colno, e.msg))
        return None


def dumps(value):
    return json.dumps(value, ensure_ascii=False, separators=(", ", ": "))


def pretty(value):
    return json.dumps(value, ensure_ascii=False, indent=2) + "\n"


def items_text(pack_id, items, code):
    lines = ["{", '  "pack": ' + dumps(pack_id) + ","]
    if items:
        lines.append('  "items": [')
        for i, it in enumerate(items):
            lines.append("    " + dumps(it) + ("," if i < len(items) - 1 else ""))
        lines.append("  ]" + ("," if code is not None else ""))
    else:
        lines.append('  "items": []' + ("," if code is not None else ""))
    if code is not None:
        lines.append('  "code": [')
        for i, c in enumerate(code):
            lines.append("    " + dumps(c) + ("," if i < len(code) - 1 else ""))
        lines.append("  ]")
    lines.append("}")
    return "\n".join(lines) + "\n"


def check_pack(path, folder, problems):
    where = rel(path)
    data = read_json(path, problems)
    if data is None:
        return None
    if not isinstance(data, dict):
        problems.add(where, "does not hold an object")
        return None
    bad = False
    for key, kind in PACK_REQUIRED.items():
        if key not in data:
            problems.add(where, "has no " + key)
            bad = True
        elif not isinstance(data[key], kind) or (kind is str and not data[key].strip()):
            problems.add(where, key + " must be " + ("a list" if kind is list else "words"))
            bad = True
    for key, value in data.items():
        if key in PACK_REQUIRED:
            continue
        if key not in PACK_OPTIONAL:
            problems.add(where, "has an unknown key " + key)
            bad = True
        elif not isinstance(value, PACK_OPTIONAL[key]) or (PACK_OPTIONAL[key] is int and isinstance(value, bool)):
            problems.add(where, key + " has the wrong type")
            bad = True
    if bad:
        return None
    if not ID_RE.match(data["id"]):
        problems.add(where, "id must be lower case letters, digits and underscores, starting with a letter")
        bad = True
    elif data["id"] != folder:
        problems.add(where, "id " + data["id"] + " is not the folder name " + folder)
        bad = True
    if data["kind"] not in PACK_KINDS:
        problems.add(where, "kind must be one of " + ", ".join(PACK_KINDS))
        bad = True
    groups = data["groups"]
    if not groups:
        problems.add(where, "has no groups")
        bad = True
    seen = {}
    for g in groups:
        if not isinstance(g, str) or not g.strip() or g != g.strip():
            problems.add(where, "a group name must be words with no spaces at the ends")
            bad = True
            continue
        f = folder_of(g)
        if not re.match(r"^[a-z0-9][a-z0-9_]*$", f):
            problems.add(where, "group " + g + " makes the folder name " + f + ", which may only hold letters, digits and spaces")
            bad = True
        if f in seen:
            problems.add(where, "groups " + seen[f] + " and " + g + " share the folder " + f)
            bad = True
        seen[f] = g
    if data.get("min_purrmiere", 1) > FORMAT:
        problems.add(where, "min_purrmiere is newer than catalog format %d" % FORMAT)
        bad = True
    return None if bad else data


def check_meta(pack_dir, problems):
    path = pack_dir / "items_meta.json"
    if not path.exists():
        return {}
    where = rel(path)
    data = read_json(path, problems)
    if data is None:
        return None
    if not isinstance(data, dict) or set(data.keys()) != {"items"} or not isinstance(data["items"], dict):
        problems.add(where, 'must be {"items": {"<item id>": {...}}}')
        return None
    ok = True
    for iid, m in data["items"].items():
        if not isinstance(m, dict):
            problems.add(where, iid + " is not an object")
            ok = False
            continue
        for key, value in m.items():
            if key not in META_KEYS:
                problems.add(where, iid + " has an unknown key " + key + " (allowed: " + ", ".join(META_KEYS) + ")")
                ok = False
            elif key == "label" and (not isinstance(value, str) or not value.strip()):
                problems.add(where, iid + ": label must be words")
                ok = False
            elif key == "tags" and (not isinstance(value, list) or not all(isinstance(t, str) and t.strip() for t in value)):
                problems.add(where, iid + ": tags must be a list of words")
                ok = False
            elif key == "url" and not isinstance(value, str):
                problems.add(where, iid + ": url must be words")
                ok = False
            elif key == "kind" and value not in ITEM_KINDS:
                problems.add(where, iid + ": kind must be one of " + ", ".join(ITEM_KINDS))
                ok = False
            elif key == "extra" and not isinstance(value, dict):
                problems.add(where, iid + ": extra must be an object")
                ok = False
            elif key == "order" and (not isinstance(value, int) or isinstance(value, bool)):
                problems.add(where, iid + ": order must be a whole number")
                ok = False
    return data["items"] if ok else None


def open_image(path, problems):
    try:
        im = Image.open(path)
        im.load()
        return im
    except Exception as e:
        problems.add(rel(path), "is not a picture Pillow can read (" + str(e) + ")")
        return None


def delay_ms(value):
    d = int(round(float(value or 0)))
    return d if d >= MIN_DELAY_MS else SLOW_DELAY_MS


def frame_count(im):
    return getattr(im, "n_frames", 1) if getattr(im, "is_animated", False) else 1


def image_facts(path, problems):
    im = open_image(path, problems)
    if im is None:
        return None
    n = frame_count(im)
    facts = {"size": [im.width, im.height]}
    if n > 1:
        total = 0
        for i in range(n):
            im.seek(i)
            total += delay_ms(im.info.get("duration", 0))
        facts["frames"] = n
        facts["seconds"] = round(total / 1000.0, 3)
    im.close()
    return facts


def too_big(path, problems):
    size = path.stat().st_size
    if size > MAX_FILE:
        problems.add(rel(path), "is %.1f MB; files must stay under 50 MB" % (size / 1048576.0))
        return True
    return False


def file_record(path, problems):
    return {"path": path.relative_to(path_pack(path)).as_posix(), "size": path.stat().st_size, "sha256": sha256_of(path)}


def path_pack(path):
    p = path
    while p.parent != PACKS:
        p = p.parent
    return p


def walk_files(folder):
    out = []
    for p in sorted(folder.rglob("*"), key=lambda q: q.as_posix()):
        if p.is_file() and p.name not in SKIP_FILES:
            out.append(p)
    return out


def collect_items(pack, pack_dir, problems):
    kind = pack["kind"]
    found = []
    folders = {folder_of(g): g for g in pack["groups"]}
    for child in sorted(pack_dir.iterdir(), key=lambda q: q.name):
        if child.is_file():
            if child.name not in ROOT_FILES and child.name not in SKIP_FILES:
                problems.add(rel(child), "is not a known pack file; content goes in a group folder")
            continue
        if child.name.startswith("_"):
            if child.name == "_thumbs":
                continue
            if child.name == "_code":
                if kind != "code":
                    problems.add(rel(child), "only code packs have a _code folder")
                continue
            problems.add(rel(child), "folders starting with _ are kept for _thumbs and _code")
            continue
        if child.name not in folders:
            problems.add(rel(child), "is not the folder of any group in pack.json (groups: " + ", ".join(pack["groups"]) + ")")
            continue
    for f, g in folders.items():
        gdir = pack_dir / f
        if not gdir.is_dir():
            problems.add(rel(pack_dir), "group " + g + " has no folder " + f + "/")
            continue
        stems = {}
        for child in sorted(gdir.iterdir(), key=lambda q: q.name):
            if child.name in SKIP_FILES:
                continue
            if child.is_dir():
                found.append({"group": g, "stem": child.name, "dir": child, "files": walk_files(child)})
                continue
            stems.setdefault(child.stem, []).append(child)
        for stem, files in stems.items():
            found.append({"group": g, "stem": stem, "dir": None, "files": files})
        if not any(it["group"] == g for it in found):
            problems.add(rel(gdir), "is empty")
    return found


def label_from(stem):
    words = re.sub(r"[_\-]+", " ", stem).strip()
    return words[:1].upper() + words[1:] if words else stem


def build_items(pack, pack_dir, meta, problems):
    kind = pack["kind"]
    raw = collect_items(pack, pack_dir, problems)
    by_id = {}
    items = []
    for r in raw:
        iid = slug(r["stem"])
        where = rel(r["dir"] if r["dir"] is not None else r["files"][0])
        if not iid:
            problems.add(where, "has no usable name for an item id")
            continue
        if iid in by_id:
            problems.add(where, "makes the item id " + iid + ", already used by " + by_id[iid])
            continue
        by_id[iid] = where
        if any([too_big(p, problems) for p in r["files"]]):
            continue
        m = meta.get(iid, {})
        images = [p for p in r["files"] if p.suffix.lower() in IMAGE_EXTS]
        data = [p for p in r["files"] if p.suffix.lower() in DATA_EXTS]
        other = [p for p in r["files"] if p not in images and p not in data]
        item_kind = m.get("kind")
        facts = None
        files = []
        thumb_src = None
        preview = None
        if r["dir"] is not None:
            if kind != "effects" and item_kind != "effect":
                problems.add(where, "a folder inside a group is only allowed for effect packs")
                continue
            item_kind = item_kind or "effect"
            if not (r["dir"] / "effect.json").is_file():
                problems.add(where, "an effect folder needs effect.json")
                continue
            for p in data:
                read_json(p, problems)
            files = r["files"]
            thumb_src = next((p for p in images if p.stem in ("preview", "thumb")), None)
        elif kind == "assets":
            if len(r["files"]) != 1:
                problems.add(where, "several files share the name " + r["stem"] + ": " + ", ".join(p.name for p in r["files"]))
                continue
            p = r["files"][0]
            if p.suffix.lower() not in IMAGE_EXTS:
                problems.add(rel(p), "is not a picture (" + ", ".join(IMAGE_EXTS) + ")")
                continue
            facts = image_facts(p, problems)
            if facts is None:
                continue
            if item_kind is None:
                item_kind = "animated" if facts.get("frames", 1) > 1 else "picture"
            files = [p]
            thumb_src = p
        else:
            item_kind = item_kind or KIND_OF_PACK[kind]
            if not data:
                problems.add(where, "a " + item_kind + " item needs a .json data file")
                continue
            if other:
                problems.add(where, "files of an unknown type: " + ", ".join(p.name for p in other))
                continue
            if len(images) > 1:
                problems.add(where, "only one preview picture per item: " + ", ".join(p.name for p in images))
                continue
            for p in data:
                read_json(p, problems)
            files = data
            if images:
                if open_image(images[0], problems) is None:
                    continue
                preview = images[0]
                thumb_src = preview
        records = [file_record(p, problems) for p in files]
        item = {"id": iid, "label": m.get("label", label_from(r["stem"])), "group": r["group"], "kind": item_kind, "files": records}
        item["_thumb_src"] = thumb_src
        if preview is not None:
            item["preview"] = preview.relative_to(pack_dir).as_posix()
        item["tags"] = list(m.get("tags", []))
        if m.get("url"):
            item["url"] = m["url"]
        extra = dict(facts) if facts else {}
        extra.update(m.get("extra", {}))
        item["extra"] = extra
        item["_order"] = m.get("order")
        items.append(item)
    for iid in meta:
        if iid not in by_id:
            problems.add(rel(pack_dir / "items_meta.json"), "names the item " + iid + " but there is no such item")
    gi = {g: i for i, g in enumerate(pack["groups"])}
    items.sort(key=lambda it: (gi[it["group"]], 0 if it["_order"] is not None else 1, it["_order"] if it["_order"] is not None else 0, natural(it["id"])))
    return items


def code_records(pack_dir, problems):
    code_dir = pack_dir / "_code"
    if not code_dir.is_dir():
        problems.add(rel(pack_dir), "a code pack needs a _code folder")
        return []
    if not (code_dir / "pack.gd").is_file():
        problems.add(rel(code_dir), "a code pack needs _code/pack.gd")
    files = walk_files(code_dir)
    if any([too_big(p, problems) for p in files]):
        return []
    return [file_record(p, problems) for p in files]


def frames_of(path, crisp):
    im = Image.open(path)
    if im.format == "JPEG":
        im.draft("RGB", (THUMB * 2, THUMB * 2))
    n = frame_count(im)
    frames = []
    durations = []
    if n > 1:
        for fr in ImageSequence.Iterator(im):
            frames.append(fr.convert("RGBA"))
            durations.append(delay_ms(fr.info.get("duration", 0)))
    else:
        frames.append(im.convert("RGBA"))
        durations.append(0)
    im.close()
    return frames, durations


def fit_size(w, h, side):
    k = min(1.0, side / float(max(w, h)))
    return max(1, int(round(w * k))), max(1, int(round(h * k)))


def to_gif_frame(fr):
    alpha = fr.getchannel("A")
    rgb = Image.new("RGB", fr.size, (0, 0, 0))
    rgb.paste(fr.convert("RGB"), mask=alpha)
    p = rgb.quantize(colors=255, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    pal = p.getpalette()[: 255 * 3]
    pal += [0] * (256 * 3 - len(pal))
    p.putpalette(pal)
    mask = alpha.point(lambda a: 255 if a < 128 else 0)
    p.paste(255, mask=mask)
    return p


def thumb_bytes(src, crisp):
    with Image.open(src) as im:
        fmt = im.format
        fits = max(im.width, im.height) <= THUMB
        n = frame_count(im)
    if fits and (fmt == "GIF" or (fmt == "PNG" and n == 1)):
        return src.read_bytes(), ".gif" if fmt == "GIF" else ".png"
    frames, durations = frames_of(src, crisp)
    w, h = fit_size(frames[0].width, frames[0].height, THUMB)
    method = Image.Resampling.NEAREST if crisp else Image.Resampling.LANCZOS
    sized = [fr if fr.size == (w, h) else fr.resize((w, h), method) for fr in frames]
    buf = io.BytesIO()
    if len(sized) > 1:
        gif = [to_gif_frame(fr) for fr in sized]
        gif[0].save(buf, "GIF", save_all=True, append_images=gif[1:], duration=durations, loop=0, disposal=2, transparency=255, optimize=False)
        return buf.getvalue(), ".gif"
    sized[0].save(buf, "PNG", optimize=False)
    return buf.getvalue(), ".png"


def first_frame(src):
    im = Image.open(src)
    if im.format == "JPEG":
        im.draft("RGB", (PREVIEW_W, PREVIEW_H))
    im.seek(0)
    out = im.convert("RGBA")
    im.close()
    return out


def pick(items, n):
    if len(items) <= n:
        return list(items)
    return [items[int(round(i * (len(items) - 1) / float(n - 1)))] for i in range(n)]


def preview_bytes(items, crisp):
    with_src = [it for it in items if it["_thumb_src"] is not None]
    sheet = Image.new("RGBA", (PREVIEW_W, PREVIEW_H), BACKDROP)
    if not with_src:
        buf = io.BytesIO()
        sheet.save(buf, "PNG", optimize=False)
        return buf.getvalue()
    sizes = []
    for it in with_src:
        fx = it["extra"].get("size") if isinstance(it["extra"].get("size"), list) else None
        if fx is None:
            with Image.open(it["_thumb_src"]) as im:
                fx = [im.width, im.height]
        sizes.append(max(fx))
    sizes.sort()
    photo = sizes[len(sizes) // 2] >= 400 and not crisp
    gap = 2
    if photo:
        cols, rows = 4, 3
    else:
        cols, rows = 8, 4
        if len(with_src) < cols * rows:
            cols = max(1, int(math.ceil(math.sqrt(len(with_src) * 16.0 / 9.0))))
            rows = max(1, int(math.ceil(len(with_src) / float(cols))))
    chosen = pick(with_src, cols * rows)
    cw = (PREVIEW_W - gap * (cols + 1)) // cols
    ch = (PREVIEW_H - gap * (rows + 1)) // rows
    ox = (PREVIEW_W - (cw * cols + gap * (cols + 1))) // 2
    oy = (PREVIEW_H - (ch * rows + gap * (rows + 1))) // 2
    for i, it in enumerate(chosen):
        c = i % cols
        r = i // cols
        x0 = ox + gap + c * (cw + gap)
        y0 = oy + gap + r * (ch + gap)
        img = first_frame(it["_thumb_src"])
        if photo:
            k = max(cw / float(img.width), ch / float(img.height))
            nw, nh = max(cw, int(math.ceil(img.width * k))), max(ch, int(math.ceil(img.height * k)))
            img = img.resize((nw, nh), Image.Resampling.LANCZOS)
            left = (nw - cw) // 2
            top = (nh - ch) // 2
            img = img.crop((left, top, left + cw, top + ch))
            sheet.alpha_composite(img, (x0, y0))
            continue
        pad = 4
        aw, ah = cw - pad * 2, ch - pad * 2
        if img.width <= aw and img.height <= ah:
            k = max(1, min(aw // img.width, ah // img.height))
            nw, nh = img.width * k, img.height * k
            img = img.resize((nw, nh), Image.Resampling.NEAREST)
        else:
            k = min(aw / float(img.width), ah / float(img.height))
            nw, nh = max(1, int(round(img.width * k))), max(1, int(round(img.height * k)))
            img = img.resize((nw, nh), Image.Resampling.NEAREST if crisp else Image.Resampling.LANCZOS)
        sheet.alpha_composite(img, (x0 + (cw - nw) // 2, y0 + (ch - nh) // 2))
    buf = io.BytesIO()
    sheet.save(buf, "PNG", optimize=False)
    return buf.getvalue()


class Writer:
    def __init__(self, check):
        self.check = check
        self.changed = []

    def put(self, path, data):
        if isinstance(data, str):
            data = data.encode("utf-8")
        if path.exists() and path.read_bytes() == data:
            return
        self.changed.append(rel(path))
        if not self.check:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)

    def drop(self, path):
        if path.exists():
            self.changed.append(rel(path) + " (removed)")
            if not self.check:
                path.unlink()


def plan_pack(pack_dir, problems):
    pack = check_pack(pack_dir / "pack.json", pack_dir.name, problems)
    if pack is None:
        return None
    meta = check_meta(pack_dir, problems)
    items = build_items(pack, pack_dir, meta if meta is not None else {}, problems)
    code = code_records(pack_dir, problems) if pack["kind"] == "code" else None
    return {"pack": pack, "dir": pack_dir, "items": items, "code": code}


def write_pack(plan, writer):
    pack = plan["pack"]
    pack_dir = plan["dir"]
    crisp = bool(pack.get("crisp", False))
    thumbs = pack_dir / "_thumbs"
    made = set()
    for it in plan["items"]:
        src = it["_thumb_src"]
        if src is None:
            continue
        data, ext = thumb_bytes(src, crisp)
        name = it["id"] + ext
        writer.put(thumbs / name, data)
        made.add(name)
        it["thumb"] = "_thumbs/" + name
    if thumbs.is_dir():
        for p in sorted(thumbs.iterdir()):
            if p.name not in made:
                writer.drop(p)
    writer.put(pack_dir / "_preview.png", preview_bytes(plan["items"], crisp))
    out = []
    for it in plan["items"]:
        row = {"id": it["id"], "label": it["label"], "group": it["group"], "kind": it["kind"], "files": it["files"]}
        if "thumb" in it:
            row["thumb"] = it["thumb"]
        if "preview" in it:
            row["preview"] = it["preview"]
        row["tags"] = it["tags"]
        if "url" in it:
            row["url"] = it["url"]
        row["extra"] = it["extra"]
        out.append(row)
    text = items_text(pack["id"], out, plan["code"])
    writer.put(pack_dir / "items.json", text)
    size = sum(f["size"] for it in out for f in it["files"]) + sum(c["size"] for c in (plan["code"] or []))
    counts = {}
    for it in out:
        counts[it["group"]] = counts.get(it["group"], 0) + 1
    entry = {"id": pack["id"], "label": pack["label"], "kind": pack["kind"], "about": pack["about"], "source": pack["source"], "licence": pack["licence"]}
    if "era" in pack:
        entry["era"] = pack["era"]
    entry["order"] = pack.get("order", 500)
    entry["crisp"] = crisp
    entry["min_purrmiere"] = pack.get("min_purrmiere", 1)
    entry["groups"] = list(pack["groups"])
    entry["group_counts"] = {g: counts.get(g, 0) for g in pack["groups"]}
    entry["item_count"] = len(out)
    entry["size_bytes"] = size
    entry["preview"] = "packs/" + pack["id"] + "/_preview.png"
    entry["items"] = "packs/" + pack["id"] + "/items.json"
    entry["items_sha256"] = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return entry, out


def now_text():
    return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).strftime("%Y-%m-%dT%H:%M:%SZ")


def human(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return ("%d %s" % (n, unit)) if unit == "B" else ("%.1f %s" % (n, unit))
        n /= 1024.0


def main():
    ap = argparse.ArgumentParser(description="Rebuild every pack's items.json, thumbnails and preview, and catalog.json.")
    ap.add_argument("--check", action="store_true", help="validate and report what would change, write nothing; exits 1 if anything would change")
    args = ap.parse_args()
    problems = Problems()
    if not PACKS.is_dir():
        print("build_catalog: there is no packs folder at " + str(PACKS))
        return 1
    plans = []
    for d in sorted(PACKS.iterdir(), key=lambda q: q.name):
        if d.name in SKIP_FILES:
            continue
        if not d.is_dir():
            problems.add(rel(d), "only pack folders belong in packs/")
            continue
        if not (d / "pack.json").is_file():
            problems.add(rel(d), "has no pack.json")
            continue
        plan = plan_pack(d, problems)
        if plan is not None:
            plans.append(plan)
    if problems.any():
        print("build_catalog: %d problem%s, nothing was written" % (len(problems.lines), "" if len(problems.lines) == 1 else "s"))
        for line in problems.lines:
            print("  " + line)
        return 1
    writer = Writer(args.check)
    old = {}
    old_updated = None
    if CATALOG.exists():
        try:
            prev = json.loads(CATALOG.read_text(encoding="utf-8"))
            old = {p.get("id"): p for p in prev.get("packs", []) if isinstance(p, dict)}
            old_updated = prev.get("updated")
        except (json.JSONDecodeError, AttributeError):
            old = {}
    stamp = now_text()
    entries = []
    report = []
    for plan in plans:
        entry, items = write_pack(plan, writer)
        prev = old.get(entry["id"])
        same = prev is not None and {k: v for k, v in prev.items() if k != "updated"} == entry
        entry["updated"] = prev.get("updated", stamp) if same else stamp
        entries.append(entry)
        report.append((plan, entry, items))
    entries.sort(key=lambda e: (e["order"], e["label"].lower(), e["id"]))
    report.sort(key=lambda r: (r[1]["order"], r[1]["label"].lower(), r[1]["id"]))
    updated = max([e["updated"] for e in entries]) if entries else (old_updated or stamp)
    writer.put(CATALOG, pretty({"format": FORMAT, "updated": updated, "packs": entries}))
    total_repo = sum(p.stat().st_size for p in ROOT.rglob("*") if p.is_file() and ".git" not in p.relative_to(ROOT).parts)
    for plan, entry, items in report:
        print("%s (%s): %d items, %s" % (entry["id"], entry["kind"], entry["item_count"], human(entry["size_bytes"])))
        print("  groups: " + ", ".join("%s %d" % (g, n) for g, n in entry["group_counts"].items()))
        files = sorted(((f["size"], plan["dir"].name + "/" + f["path"]) for it in items for f in it["files"]), reverse=True)[:3]
        print("  largest: " + ", ".join("%s %s" % (p, human(s)) for s, p in files))
    print("repository: %d packs, %d items, %s on disk without .git" % (len(entries), sum(e["item_count"] for e in entries), human(total_repo)))
    if args.check:
        if writer.changed:
            print("build_catalog --check: %d file%s would change" % (len(writer.changed), "" if len(writer.changed) == 1 else "s"))
            for c in writer.changed[:40]:
                print("  " + c)
            return 1
        print("build_catalog --check: everything is up to date")
        return 0
    print("build_catalog: %d file%s written" % (len(writer.changed), "" if len(writer.changed) == 1 else "s"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
