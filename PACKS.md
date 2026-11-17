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
