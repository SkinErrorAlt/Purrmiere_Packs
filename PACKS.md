# Adding packs and publishing them

Instructions for Claude (and Ava). Ava's standing instruction, 2026-11-17: new packs, shader effects, text
effects, text animations, voice effects and other preset sets go in this repository, and Claude pushes them to
GitHub. This is the one repository Claude pushes to on its own; the main Purrmiere repository is still pushed only
by Ava with `Push to GitHub.bat`.

- GitHub: https://github.com/SkinErrorAlt/Purrmiere_Packs (public, not advertised; branch `main`)
- Local copy: `C:\Purrmiere_Packs`
- Format: [FORMAT.md](FORMAT.md)

## Adding a pack

1. Make `packs/<pack_id>/pack.json` (see FORMAT.md) with the pack's kind, label, about, source, licence and groups.
2. Put the content in one sub folder per group, named after the group in lower case with `_` for spaces
   (for example `packs/cameronsworld/flames/`). Code packs keep their scripts in `_code/`.
3. Do not invent or redraw assets, and do not put Purrmiere branding on anything. Packs come from real sources
   Ava picked (her Pack Sources page), with the source and licence written in pack.json.
4. Rebuild the generated files: `python tools/build_catalog.py` (writes every `items.json`, the thumbnails, each
   `_preview.png` and `catalog.json`). It refuses to run if a file is missing or a manifest is broken.
5. Check it in Purrmiere: Settings, Pack library, set the source to `C:\Purrmiere_Packs` (a local folder works the
   same as GitHub), open the library and download an item from the new pack.

## Notes on the steps (added when the builder was written)

- Step 2: labels, tags, source urls and the order of items come from the pack's optional `items_meta.json` (see
  FORMAT.md); without it an item is labelled from its file name. Keep it when moving or renaming files, the builder
  refuses an entry that names an item that is not there.
- Step 4: the builder needs Python 3 with Pillow (`pip install pillow`). `python tools/build_catalog.py --check` writes
  nothing and exits 1 if a rebuild would change any file; run it before committing.
- Old web code pack: after changing anything in `packs/old_web/_code/`, render its previews and data files again, then
  rebuild:
  1. `Godot_v4.7.2-stable_win64_console.exe --position 3900,60 --path <a Purrmiere copy>\project --script C:/Purrmiere_Packs/tools/old_web_render.gd`
     (needs a window, it renders every piece; it uses only the pack's own code)
  2. `python tools/old_web_write.py` (writes each `<group>/<id>.json`, the preview renders and `items_meta.json`)
  3. `python tools/build_catalog.py`

## Publishing

```
cd C:\Purrmiere_Packs
git add -A
git commit -m "Add <pack name>"
git push origin main
```

- Keep single files under 50 MB (GitHub refuses files over 100 MB) and the whole repository under about 1 GB.
- Purrmiere picks up the new catalog the next time the library opens (or with its Refresh button).
- Write the change in the main project's OUTSTANDING.md so the next session knows the pack exists.
