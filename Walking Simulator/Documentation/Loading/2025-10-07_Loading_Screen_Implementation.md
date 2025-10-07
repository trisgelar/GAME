### Loading Screen Implementation (2025-10-07)

#### What we built
- Async scene loading via `Global.change_scene_with_loading(scene_path)` using `ResourceLoader.load_threaded_request`.
- Lightweight in-code overlay (no scene file): `CanvasLayer` + centered splash image + textured progress bar.
- Configurable visuals via `Resources/Loading/LoadingConfig.tres`.

#### Behavior
- Shows immediately when changing scenes; updates progress bar as threaded load advances.
- Splash image modes covered:
  - KEEP (no scale) centered — 1024×1024 image centered on 1920×1080 with black background.
  - KEEP_ASPECT_CENTERED — letterbox, no crop.
  - KEEP_ASPECT_COVERED — cover screen, crop to fill (no letterbox).
- We currently use KEEP with manual centering.

#### Key files
- `Global.gd` (overlay creation, progress updates, threaded load loop).
- `Systems/Core/LoadingConfig.gd` (resource class) and `Resources/Loading/LoadingConfig.tres` (values):
  - design size, splash paths per region (papua/pasar/tambora)
  - progress bar textures (`loading_bar_empty_frame.png`, `loading_bar_fill.png`)
  - bar width/height and vertical position percent

#### Notes
- Use linear volumes for audio; the loader remains responsive even during heavy scene loads.
- If the OS cursor shows “busy” before overlay, ensure calls to `Global.change_scene_with_loading()` are used everywhere (we replaced direct `change_scene_to_file` calls in menu/navigation).

