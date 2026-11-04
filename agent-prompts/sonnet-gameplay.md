# Sonnet gameplay implementation assignment

Work in `%USERPROFILE%\Documents\TopDownZombies` and obey `AGENTS.md` completely.

You own only `game/`, `scenes/`, `tests/`, and `docs/checkpoints/SONNET.md`. The repository may be dirty because other agents are active. Preserve all unrelated edits and never reset/stash/clean. Inspect `git status` before each commit.

Build a complete playable Godot 4 vertical slice using procedural drawing where final art is not yet integrated. Requirements: offline single-player; top-down movement and mouse/touch aiming; hold/tap fire; enemies that navigate simply toward player/base; damage, death and restart; resources collected during DAY; exactly 300-second DAY and 300-second NIGHT production defaults with debug overrides; night wave escalation; base core; build mode for barricade, spike trap, and auto-turret with collision/costs; HUD with phase/timer/resources/health/wave; versioned local JSON save/autosave; export/import API that works on desktop path and is structured for Android document picker; pause/settings with volume and aim assist; deterministic tests for phase timing, resource costs, placement rules, save roundtrip, and wave progression.

Keep architecture compact and data-driven. Do not depend on third-party addons. Use typed GDScript and Godot 4.7 syntax. Set up a main scene under your ownership, but do not edit root `project.godot`; document the intended `run/main_scene` in your checkpoint for the primary agent.

Verification: run Godot headless import and the owned tests using `%USERPROFILE%\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe`. Fix all parse/runtime failures in owned files. Do not claim visual acceptance.

Checkpoint: update `docs/checkpoints/SONNET.md` with timestamp, behavior delivered, exact files, commands/results, blockers, and next safe task. Commit only owned files with a descriptive commit. Then stop.

