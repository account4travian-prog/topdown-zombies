# Project Agent Contract

## Product target

Build a portrait/landscape-safe Android-first Godot 4 survival shooter. A five-minute day is for scavenging and base construction; a five-minute night is for defending against escalating zombie waves. The game has no account system. Saves are local and can be exported/imported by the player.

## Non-negotiable boundaries

- Preserve `.source-kit/` as local, ignored licensed source material. Never commit or redistribute it.
- Only copy art actually used at runtime into `assets/third_party/craftpix/`.
- Record every external dependency and asset in `THIRD_PARTY_NOTICES.md`.
- Do not edit another agent's owned files while that agent is active.
- Do not erase, reset, stash, or overwrite unrelated work. Inspect `git status` first.
- Godot-generated `.godot/` content is never committed.
- No login, analytics SDK, ads SDK, remote service, or invasive Android permission without owner approval.
- Use typed GDScript where practical and keep gameplay deterministic enough for headless tests.
- A headless pass is not visual acceptance. Record desktop/mobile window checks separately.

## Ownership for initial build

- Sonnet: `game/`, `scenes/`, `tests/` gameplay implementation and `docs/checkpoints/SONNET.md`.
- Haiku: `docs/release/`, `tools/`, Android readiness checks, and `docs/checkpoints/HAIKU.md`.
- Luna: read-only kit asset inventory; no file ownership.
- Primary Codex agent: root config, licensed runtime assets, integration, imports/exports, final verification, and `DEVELOPMENT_STATE.md`.

## Required checkpoint format

Every implementation agent must update its checkpoint with: timestamp, scope completed, files changed, exact verification commands/results, current blockers, and the next safe task. Commit only files within owned scope with a descriptive message.

## Verification gates

1. `project.godot` imports headlessly with no script parse failures.
2. Automated gameplay tests cover day/night timing, resource accounting, building placement, save roundtrip, and wave progression.
3. A real game window is played through representative movement, shooting, building, phase transition, death/restart, and save/export flows.
4. Android debug export installs/boots on an emulator or device.
5. Release AAB export passes signing/configuration checks and contains required notices/privacy metadata.

