# Development State

Updated: 2026-09-06

## Current milestone

M2 — playable Android vertical slice; device validation and owner release identity remain.

## Confirmed environment

- Workspace began empty and without Git history.
- Godot 4.7.1 is installed at `%USERPROFILE%\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe`.
- JDK 17 is installed.
- Android SDK installed at `%USERPROFILE%\AppData\Local\Android\Sdk`: API 36, Build Tools 36.1.0, Platform Tools 37.0.1, NDK 29.0.14206865, and CMake 3.22.1.
- Godot 4.7.1 Android debug/release/source templates are installed and verified against the official release checksum.
- Source kit: `%USERPROFILE%\Downloads\craftpix-871156-zombie-tds-2d-game-kit.zip`.
- Raw kit extracted under ignored `.source-kit/` for local inspection.

## Product decisions

- Working title: **Last Stand Homestead**.
- Offline single-player, no account.
- Five-minute day and five-minute night phases; debug/test overrides allowed outside release builds.
- Day: explore a bounded map, collect scrap/wood/parts/ammo, return and build.
- Night: the base is locked into defense mode; escalating waves target the player and base core.
- Touch: left virtual stick moves; right-side aim/fire pad; contextual build button and compact hotbar.
- Save: versioned JSON under `user://`, automatic phase/checkpoint saves, explicit export/import via Android document picker when available.
- Initial buildables: barricade, spike trap, auto-turret.
- Session loop: survive nights, earn permanent unlock points, and chase a local high score.

## Agent lanes

- Sonnet owns gameplay implementation in `game/`, `scenes/`, and `tests/`.
- Haiku owns Android/release checks in `docs/release/` and `tools/`.
- Luna is auditing source-kit contents read-only.
- Primary agent integrates assets/config, verifies, and publishes checkpoints.

## Verified now

- Main scene: `res://scenes/main.tscn`.
- 123 selected CraftPix PNGs are integrated for animated player/zombies, terrain, props, and icon.
- Touch move, aim/fire, build, and pause controls render in the Android layout.
- 395 deterministic gameplay checks pass.
- Accelerated fresh day/night runtime smoke passes without stderr errors.
- GPU-rendered 1280x720 movie capture shows distinct day/night lighting and incoming animated zombies.
- Debug APK exports successfully, targets API 36/min API 24, and passes Android v2 signature verification.
- Debug-built AAB exports successfully; it is intentionally not an upload artifact because no owner release keystore has been created.

## Remaining release gates

1. Install/boot the APK on a physical Android device or emulator; none was attached during this checkpoint.
2. Perform a human touch playthrough: movement, aim/fire, resource pickup, all three buildables, phase transition, death/restart, pause, and save export/import.
3. Choose/confirm the permanent Play package ID (`com.example.laststandhomestead` is the current candidate).
4. Owner creates and securely stores the Play upload keystore; do not commit credentials.
5. Produce and verify the release-signed AAB, store screenshots/feature graphic, privacy-policy URL, content rating, and Play Console submission.
