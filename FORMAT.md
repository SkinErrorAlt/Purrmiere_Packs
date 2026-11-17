# Purrmiere_Packs: repository layout and catalog format (version 1)

Repo: https://github.com/SkinErrorAlt/Purrmiere_Packs (public, not advertised), branch `main`.
Raw file base: `https://raw.githubusercontent.com/SkinErrorAlt/Purrmiere_Packs/main/`.
Local working copy on Ava's PC: `C:\Purrmiere_Packs`.

## Layout

```
catalog.json                     the index Purrmiere reads first (small)
FORMAT.md                        this file
README.md                        what the repo is
PACKS.md                         how to add a pack and publish (for Claude and Ava)
tools/build_catalog.py           rebuilds every pack's items.json, thumbnails and catalog.json
packs/<pack_id>/
  pack.json                      the pack's manifest (hand written)
  items_meta.json                optional, hand kept: per item labels, tags, source urls, order and extra (survives rebuilds)
  items.json                     generated: every item with files, sizes, sha256 and thumbnail
  _preview.png                   generated: 512x288 contact sheet for the library card
  _thumbs/<item_id>.png|.gif     generated: small preview (max 128 px side), animated GIF for animated items
  <group>/<files>                the real content, one sub folder per group (for example flames/, dividers/)
  _code/<files>.gd               code packs only: the scripts the pack runs (shared by all its items)
```

## pack.json (hand written)

```
{
  "id": "old_web",                 lower case letters, digits, underscores, starting with a letter
  "label": "Old web (1999)",
  "kind": "assets" | "code" | "effects" | "voices" | "text_styles" | "text_anims",
  "about": "one or two sentences",
  "source": "where it came from (url or 'Purrmiere')",
  "licence": "plain words about reuse",
  "era": "optional",
  "order": 10,
  "groups": ["Banners", "Dividers", ...],            display names; the folder of a group is its name in lower case with _ for spaces
  "min_purrmiere": 1,                                  catalog format version the pack needs
  "crisp": true                                        optional: pixel art, show and scale it with nearest filtering
}
```

## items_meta.json (hand kept, optional)

```
{"items": {"<item id>": {"label": "...", "tags": [...], "url": "...", "order": 3, "kind": "...", "extra": {...}}}}
```

Every key is optional. `order` sorts items inside their group (items without one follow, by name). `extra` is merged
over what the builder works out itself (for pictures: `size`, and for animated ones `frames` and `seconds`, using the
browser rule that a frame shorter than 20 ms shows for 100 ms). The builder refuses an entry for an item that is not
there.

Item ids come from the file name (or, for effects, the folder name): lower case, every run of other characters becomes
one `_` (`angry-smile.png` is `angry_smile`). Inside a group folder, files that share a name form one item.

## items.json (generated)

```
{
  "pack": "old_web",
  "items": [
    {
      "id": "flames_4",                                unique inside the pack
      "label": "Flames 4",
      "group": "Flames",
      "kind": "picture" | "animated" | "piece" | "effect" | "voice" | "text_style" | "text_anim",
      "files": [{"path": "flames/flames_4.gif", "size": 12345, "sha256": "..."}],
      "thumb": "_thumbs/flames_4.gif",
      "preview": "banners/banner_night.gif",          code packs only, optional: a real render of the piece, not downloaded with it
      "tags": ["fire"],
      "url": "original source url, optional",
      "extra": {}                                       kind specific (for example a piece's catalogue entry and defaults)
    }
  ],
  "code": [{"path": "_code/pack.gd", "size": 0, "sha256": "..."}]     code packs: always downloaded with the first item
}
```

Kind notes:
- `picture` / `animated`: real image files (PNG, JPG, GIF, APNG). Placed as normal media.
- `piece`: an item drawn by the pack's code (`_code/`), like the 1999 pack's pieces. `extra` holds what the code needs.
  Its `files` are its data files (`<group>/<id>.json`); a picture with the same name next to them is its `preview`.
- `effect`: one effect folder (effect.json plus its shader files), installed into the user effects folder.
- `voice`: one voice effect preset JSON.
- `text_style`: one text style row JSON (the doc/text_styles.gd row format), installed as a user text style.
- `text_anim`: one text animation preset JSON.

## catalog.json (generated)

```
{
  "format": 1,
  "updated": "2026-11-17T00:00:00Z",
  "packs": [
    {"id": "...", "label": "...", "kind": "...", "about": "...", "source": "...", "licence": "...", "order": 10,
     "era": "...", "crisp": false, "min_purrmiere": 1,
     "groups": [...], "group_counts": {"Flames": 32}, "item_count": 599, "size_bytes": 10066329, "preview": "packs/<id>/_preview.png",
     "items": "packs/<id>/items.json", "items_sha256": "...", "updated": "..."}
  ]
}
```

`size_bytes` is what downloading every item and the code costs (thumbnails and previews not counted). `updated` only
changes when something in the pack's entry changes, so rebuilding without changes leaves every file as it was.

## Code pack handles (on the Program monitor)

A code pack's `_code/pack.gd` gives the monitor its handles:

- `handles(id, size, values)` returns a list of `{id, at, look, name}` (`at` in layer pixels; looks `dot`, `ring`,
  `arrow`, `corner`). This is all older Purrmiere versions ask for.
- `handles(id, size, values, how)`: when Purrmiere passes `how = {"acts": true}`, each handle may also carry
  `act` (`move` hands the press to the clip's own move, `fit` runs Fit clip below, `resize` with a `side` such as
  `l`, `r`, `t`, `b`, `tl`; any other act is a live drag), `from` (the point an arrow handle is drawn from), `push`
  (a screen offset in pixels), `label` (the undo step's name) and the looks `square`, `diamond`, `cross`, `button`.
- `drag(id, handle_id, at, size, values)` returns the changed field values. With a 6th argument
  `how = {"press": Vector2, "alt": bool}` it may also return `width`, `height`, `rect` (where the layer lands, in the
  old layer's coordinates, so the opposite edge stays put) and `chip` (the text shown while dragging).
- Optional `guides(id, size, values)` returns boxes to draw: `{kind: "outline" | "dashed" | "region", rect, name}`.
- Optional `size_for(id, values)` returns the layer size a piece needs for its values (for example a counter's digits),
  so Purrmiere resizes the layer when a value changes.

Purrmiere counts each function's arguments, so packs written the old way keep working.

## On the user's PC

- Cache root: Purrmiere's user data folder `packs/` (Settings shows it, with an Open folder button).
  Mirrors the repo paths: `packs/catalog.json`, `packs/<pack_id>/items.json`, `packs/<pack_id>/<group>/<file>`.
- An item is present when every file in its `files` exists with the matching sha256; nothing already present is
  downloaded again. Thumbnails download on demand while the library shows them.
- Projects store an item reference `pack://<pack_id>/<item_id>` plus the cached path; opening a project whose item
  is missing downloads just that item (when online) and shows a clear placeholder until it arrives.
