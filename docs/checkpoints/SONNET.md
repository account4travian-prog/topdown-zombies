# Sonnet Checkpoint — Gameplay Vertical Slice

Timestamp: 2026-09-06 02:38 CST (-0500)
Agent: Sonnet (gameplay implementation)
Scope owned: `game/`, `scenes/`, `tests/`, this file.

## Behavior delivered

A complete, offline, single-player Godot 4.7 vertical slice with procedural
(`_draw()`) art everywhere final art is not yet integrated. No third-party
addons. Typed GDScript throughout.

- **Phase loop** — `PhaseClock` (node-free). Production defaults are exactly
  300 s DAY / 300 s NIGHT (`Balance.DAY_SECONDS` / `NIGHT_SECONDS`). Debug
  overrides via `GameConfig.set_debug_phase_durations()`, the pause-menu
  "Apply override" control, and CLI user args (`-- --day=<s> --night=<s>`).
  Overrides never mutate the `Balance` constants. Overshoot time carries into
  the next phase; `day_number` advances on each NIGHT→DAY flip.
- **Movement + aiming** — `Player` (`CharacterBody2D`). WASD / arrow keys +
  virtual-stick fields (`touch_move`), mouse aim + `touch_aim`, mouse-wheel /
  touch parity. Aim assist (0–1) slerps aim toward the nearest zombie; strength
  is a live setting.
- **Firing** — hold or tap: left mouse / Space / `touch_firing`, cooldown-gated
  (`Balance.PLAYER_FIRE_COOLDOWN`). `Bullet` is a pooled-free `Area2D` that
  damages the first zombie hit; player and auto-turrets share the spawner.
- **Enemies** — `Zombie` (`CharacterBody2D`) navigates straight at the player
  when within aggro range, otherwise at the base core, and attacks any
  `attackable` (barricade / trap / turret / core / player) within touch range
  on an interval. Per-wave health/speed scaling from `Balance.wave_zombie_stats`.
- **Damage / death / restart** — player and base core have health, hit flashes,
  and death paths. Either death shows a Game Over overlay with **Restart**
  (wipes autosave, reloads the scene).
- **Resources** — `ResourceLedger` (node-free). Scrap / wood / parts. `Pickup`
  diamonds spawn around the map during DAY only (interval + max-active caps).
  All-or-nothing affordability; a rejected purchase spends nothing; totals
  clamp at zero. Surviving a night grants `Balance.NIGHT_CLEAR_REWARD`.
- **Night waves** — `WaveDirector` (node-free). Each NIGHT bumps the wave;
  later waves send more zombies (`WAVE_BASE_COUNT + 3·idx`), tougher (+18 %/wave
  HP), faster (+5 %/wave), on a shrinking spawn interval clamped to a floor.
  Spawns are time-gated (not a single burst). A wave reports "cleared" only
  once every scheduled zombie is dead; leftover spawns are cancelled at dawn.
- **Base core** — `BaseCore` (`StaticBody2D`), 500 HP, generates a no-build
  keep-out ring.
- **Build mode** — toggle with `B` or the HUD hotbar; keys `1/2/3` select.
  `BuildSystem` (node-free) validates bounds, keep-outs, min centre spacing and
  AABB overlap, and cost — in that order — then spends via the ledger on
  success. Ghost preview shows green/red legality at the grid-snapped cursor.
  Barricade (blocks movement), spike trap (non-blocking `Area2D`, periodic
  contact damage, self-wears), auto-turret (blocks, auto-fires at nearest
  zombie in range).
- **HUD** (`Hud`, `CanvasLayer`, code-built) — phase + day, mm:ss countdown,
  wave (+ active / incoming), resource stockpile, player health bar, base-core
  health bar, build hotbar with costs, transient message line.
- **Save** — `SaveSystem`, versioned JSON (`version` envelope + `data` +
  `saved_at`). Byte-oriented core (`encode_snapshot` / `decode_snapshot`) with
  a migration hook, plus `user://` autosave on every phase transition and
  `save_to_path` / `load_from_path` wrappers. Settings persist separately to
  `user://settings.json`.
- **Export / import** — `export_to_path` / `import_from_path` drive the desktop
  flow through native `FileDialog`s in the pause menu. The byte APIs
  (`encode_snapshot` / `decode_snapshot`) are the Android SAF seam: a document
  picker hands back bytes/URI, integration code feeds them straight in. Import
  reports typed statuses (bad JSON, not an object, missing/unsupported version,
  file not found) instead of crashing.
- **Pause / settings** — `Esc` toggles. Master / SFX / music volume sliders
  (master wired to the `Master` audio bus), aim-assist slider, debug phase
  override, Resume / Restart / Export / Import.

## Architecture notes

- No autoloads and `project.godot` is untouched (not my lane). All shared
  state is owned and wired by `Game` (`game/game.gd`), the main-scene root.
  Core rules are `class_name` RefCounted classes with zero node/tree
  dependencies so headless tests drive them directly with fixed deltas.
- Entities are pure scripts that build their own collision shapes in `_ready()`;
  `Game` spawns them with `.new()`. Only `scenes/main.tscn` is a scene file.
- Tuning tables live in `game/data/balance.gd`; per-run options in
  `game/data/game_config.gd`. Collision layer bits + group names are centralised
  in `game/core/phys.gd`.

## ACTION FOR PRIMARY AGENT

Set `run/main_scene` in root `project.godot` to:

    [application]
    run/main_scene="res://scenes/main.tscn"

Optionally add named input actions (`move_up/down/left/right`, `fire`,
`build_mode`) — the slice works without them today (raw key polling +
built-in `ui_*` actions), but named actions would let the touch HUD and
remapping settings bind cleanly later.

## Exact files added

game/data/balance.gd
game/data/game_config.gd
game/core/phys.gd
game/core/phase_clock.gd
game/core/resource_ledger.gd
game/core/wave_director.gd
game/core/build_system.gd
game/core/save_system.gd
game/entities/player.gd
game/entities/zombie.gd
game/entities/base_core.gd
game/entities/bullet.gd
game/entities/pickup.gd
game/entities/structure.gd
game/entities/spike_trap.gd
game/ui/hud.gd
game/ui/pause_menu.gd
game/game.gd
scenes/main.tscn
tests/test_framework.gd
tests/run_tests.gd
tests/test_phase_timing.gd
tests/test_resource_costs.gd
tests/test_placement_rules.gd
tests/test_save_roundtrip.gd
tests/test_wave_progression.gd
(+ Godot-generated `*.gd.uid` siblings)

## Verification commands + results

Binary: `%USERPROFILE%\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe`

1. Headless import — no script parse failures:
   `... --headless --path . --import`
   → All 25 global classes registered, assets reimported, `[ DONE ]`. No errors.

2. Owned deterministic tests:
   `... --headless --path . --script res://tests/run_tests.gd`
   → TestPhaseTiming    320 passed, 0 failed
     TestResourceCosts   18 passed, 0 failed
     TestPlacementRules  16 passed, 0 failed
     TestSaveRoundtrip   19 passed, 0 failed
     TestWaveProgression 22 passed, 0 failed
     TOTAL: 395 passed, 0 failed  (exit code 0)
   Covers: phase timing (300 s defaults, flips, carryover, debug override,
   dict roundtrip), resource costs (all-or-nothing, debit-all, inert on
   failure, pickups/rewards, no-negative), placement rules (bounds, keep-out,
   spacing, affordability order, spend-on-success, null-on-illegal, dict
   roundtrip), save roundtrip (data preserved, versioned envelope, bad JSON /
   non-object / missing / future version rejected, on-disk `user://` roundtrip,
   missing file), wave progression (per-night increment, count/HP/speed/
   interval escalation + floor, time-gated spawns, full release over time,
   clear only after all dead, dawn cancels pending).

3. Headless runtime smoke of the main scene:
   `... --headless --path . res://scenes/main.tscn --quit-after 600 --fixed-fps 60 -- --day=2 --night=2`
   → Ran clean, no script/runtime errors. Autosave written to
     `user://save_game.json` (reached Day 3 / Wave 2, night-clear rewards
     accumulated), confirming phase transitions, wave spawning, zombie
     navigation and save I/O all execute at runtime.

## Blockers

- None blocking. Visual acceptance is explicitly NOT claimed — no real
  windowed play-through has been performed (headless only).
- Named `project.godot` input actions and `run/main_scene` are the primary
  agent's lane (see ACTION above).
- Android document-picker plugin is not wired (Haiku / primary lane); the
  save API is already structured for it via the byte-oriented seam.

## Next safe task

- Integrate craftpix sprites behind the procedural `_draw()` fallbacks
  (swap-in per entity; keep `_draw()` as the no-asset path).
- Add on-screen virtual joysticks / fire pad that write `Player.touch_move` /
  `touch_aim` / `touch_firing` for touch devices.
- Add a lightweight object pool for `Bullet` / `Zombie` if profiling on device
  shows churn.
