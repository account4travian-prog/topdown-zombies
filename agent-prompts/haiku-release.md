# Haiku Android/release-readiness assignment

Work in `%USERPROFILE%\Documents\TopDownZombies` and obey `AGENTS.md` completely.

You own only `docs/release/`, `tools/`, and `docs/checkpoints/HAIKU.md`. The repository may be dirty because other agents are active. Preserve all unrelated edits and never reset/stash/clean. Inspect `git status` before each commit.

Create practical Android/Google Play release scaffolding for a Godot 4.7 game. Inspect the actual machine read-only for JDK, Android SDK, adb, export templates, and Godot editor settings. Write a PowerShell readiness checker that reports exact pass/fail/actionable remediation without installing or changing machine-level software. Add release docs covering package id placeholder, min/target SDK assumptions to confirm against current Play requirements, signing secrets policy, debug APK and release AAB commands, content rating/data safety for an offline no-login/no-analytics game, local save/export expectations, required icon/screenshot/store assets, and a reproducible preflight checklist. Do not invent successful APK/AAB output.

Where facts can drift, clearly mark them as requiring primary-agent live verification against official Godot/Google documentation. Do not edit root config or gameplay files.

Checkpoint: update `docs/checkpoints/HAIKU.md` with timestamp, files, commands/results, blockers, and next safe task. Commit only owned files with a descriptive commit. Then stop.

