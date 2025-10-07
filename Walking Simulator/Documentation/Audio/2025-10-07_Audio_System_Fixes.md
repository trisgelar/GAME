### Audio System Fixes and Configuration (2025-10-07)

#### What we achieved
- Implemented config-aware `CulturalAudioManagerEnhanced.gd` that auto-loads `Resources/Audio/AudioConfig.tres`.
- Restored SFX routing: `footstep_player` and `effect_player` with per-category volumes.
- Added direct calls from `PlayerControllerIntegrated_tambora.gd` for footsteps, jump, and land.
- Stopped menu/ambient overlap, ensured region ambience selection is correct.

#### Key files
- `Systems/Audio/CulturalAudioManager.tscn` (scene)
- `Systems/Audio/CulturalAudioManagerEnhanced.gd` (manager)
- `Resources/Audio/AudioConfig.tres` (single source of truth)
- `Player Controller/PlayerControllerIntegrated_tambora.gd` (direct SFX calls)

#### How volumes work (linear scale)
- `master_volume`, `ambient_volume`, `menu_volume`, `effects_volume`, `footsteps_volume`, `music_volume`, `ui_volume` in `AudioConfig.tres` are 0.0–1.0 linear values.
- The manager applies: `player.volume_db = linear_to_db(category_volume × master_volume)`.
- Do NOT enter dB values (e.g., -6.0) in `AudioConfig.tres`.

Recommended testing mix
- master_volume: 1.0
- ambient_volume: 0.0 (to test SFX)
- effects_volume: 1.0
- footsteps_volume: 1.0

#### Wiring in player controllers
- Tambora (`PlayerControllerIntegrated_tambora.gd`):
  - Footsteps: `Global.audio_manager.play_footstep(current_surface_type)` via a timer while grounded and moving.
  - Jump: `Global.audio_manager.play_player_audio("jump")`.
  - Land: `Global.audio_manager.play_player_audio("land")`.
- Papua (`PlayerControllerIntegrated.gd`): currently emits `GlobalSignals` for footsteps. For consistency, we can convert to direct calls (same as Tambora).

#### Common issues and fixes
- If you see `Volume can't be set to NaN`: a volume in config is invalid (e.g., -6.0). Replace with 0.0–1.0.
- If ambience overwhelms SFX: lower `ambient_volume` and/or add bus mixing (SFX, UI, Music) in an Audio Bus Layout.
- WASAPI warnings (Windows audio device switching): avoid changing devices mid-run; set device to 48 kHz; disable exclusive mode.

#### Region ambience mapping (fallback)
- Indonesia Barat / PasarScene → `market_ambience.ogg`
- Indonesia Tengah / TamboraScene → `mountain_wind.ogg`
- Indonesia Timur / PapuaScene → `jungle_sounds.ogg`

#### Next actions (optional)
- Assign engine audio buses (Ambient→Music/Ambient, Footstep/Effects→SFX, UI→UI) and save to `Resources/Audio/bus_layout.tres`.
- Convert Papua controller to direct SFX calls like Tambora.

