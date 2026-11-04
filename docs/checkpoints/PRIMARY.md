# Primary Integration Checkpoint

Timestamp: 2026-09-06 (America/Chicago)

## Delivered

- Initialized Git and established agent ownership/recovery contracts.
- Kept the purchased 1.4 GB CraftPix source kit ignored; selected only 123 runtime PNGs and recorded provenance.
- Integrated licensed animated player/zombie art, tiled terrain, props, application icon, night tint, and procedural fallbacks.
- Added Android touch controls for move, aim/fire, build mode, and pause.
- Wired `res://scenes/main.tscn`, fresh-run debug flag, Android texture compression, and API-36 export presets.
- Installed current official Android SDK components and the checksum-verified Godot 4.7.1 Android templates.
- Corrected release docs/checker from stale API 34 guidance to the current API 36 policy.

## Verification

```text
Godot headless import: PASS, no script parse errors
tests/run_tests.gd: 395 passed, 0 failed
accelerated runtime (--fresh --day=2 --night=2 --touch-ui): PASS, no stderr errors
GPU movie capture: 720 frames at 1280x720/60 FPS, distinct DAY/NIGHT renders inspected
Android readiness checker: PASS (release-keystore/device warnings remain)
Android Debug APK: 86,272,441 bytes; export PASS
APK SHA-256: E238DD629A6F66D04D6BE390B7E1B21E5361CBEF714C557765E007FE5D629014
APK signature: v2 verified; debug Godot certificate
APK manifest: package com.example.laststandhomestead, minSdk 24, targetSdk/compileSdk 36
Android debug validation AAB: 34,384,195 bytes; Gradle export PASS
AAB SHA-256: 60D565AEEBBBB3432C47FE91931FD851598FE830283FEF012886471FC2F50C4D
Android native JSON export/import picker: wired; physical-device round-trip remains an acceptance gate
ADB: no attached device
```

## Agent handoffs

- Sonnet gameplay checkpoint: `docs/checkpoints/SONNET.md`, commit `c8f0d20`.
- Haiku release checkpoint: `docs/checkpoints/HAIKU.md`, commit `586f618`; its historical environment snapshot predates SDK installation.
- Luna performed a read-only source-kit inventory; primary agent used standardized animation frames to preserve stable pivots.

## Next safe action

Connect a physical Android device (or install an emulator) and execute the touch/save acceptance checklist. The owner must choose the permanent package ID and create/store the Play upload keystore before any release-signed AAB can be produced.
