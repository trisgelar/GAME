### Audio Bus Layout — Quick Guide (2025-10-07)

This sets up mix control for Ambient/Music, SFX (footsteps/jump/land), and UI.

#### 1) Open the Buses panel
- Bottom panel → Audio → Buses (if hidden: Editor → Panels → Audio).

#### 2) Create buses
- Keep Master at 0 dB.
- Add children of Master:
  - `Music` (or `Ambient`) — for ambience/background.
  - `SFX` — for footsteps, jump/land, player effects.
  - `UI` — for clicks, inventory, notifications.

Optional processors (later):
- `Music`: EQ or slight Ducking (Sidechain from SFX) if you want SFX to cut through.
- `SFX`: Light Compressor to lift quiet assets.

#### 3) Save layout to project
- Click Save in the Buses panel → save as `res://Resources/Audio/bus_layout.tres`.
- Project Settings → General → Application → Config → Default Bus Layout → set to the same path.

#### 4) Route players to buses
- `Systems/Audio/CulturalAudioManager.tscn`:
  - `AmbientPlayer` → `Music`
  - `MusicPlayer` → `Music` (if used)
  - `FootstepPlayer` → `SFX`
  - `EffectPlayer` → `SFX`
  - `UIPlayer` → `UI`

Now you can mix per-bus in real time:
- Lower `Music` by -6 dB to make footsteps more prominent while keeping Master at 0 dB.
- Mute `Music` bus for testing SFX only.

#### 5) Asset loudness tips
- If some footsteps are still quiet, normalize the source files or add a light Compressor on `SFX`.
- Keep per-category volumes in `Resources/Audio/AudioConfig.tres` in linear range 0.0–1.0 (manager converts to dB).

#### 6) Troubleshooting
- No sound after device change: Windows switched audio devices — stop and run again; avoid switching mid-run.
- Distorted/clipping: reduce Master or the affected bus; check you didn’t push `effects_volume`/`footsteps_volume` over 1.0.

