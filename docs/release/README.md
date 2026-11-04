# Android Release Documentation

This directory contains release scaffolding and guides for Last Stand Homestead on Android/Google Play.

## Files

- **ANDROID_RELEASE_GUIDE.md** — Complete Android build and export workflow, command reference, and configuration details.
- **PREFLIGHT_CHECKLIST.md** — Reproducible preflight checks before each build/submission.
- **CONTENT_RATING_AND_PRIVACY.md** — Content rating questionnaire answers, privacy policy framework, and data safety submission guide.
- **STORE_ASSETS.md** — Requirements and specifications for Google Play listing (icon, screenshots, graphics).

## Quick Start

1. **Check readiness:** Run `.\tools\check-android-readiness.ps1` from the project root.
2. **Review checklist:** See `PREFLIGHT_CHECKLIST.md` before any export.
3. **Debug export (APK):** See `ANDROID_RELEASE_GUIDE.md` § Debug Builds.
4. **Release export (AAB):** See `ANDROID_RELEASE_GUIDE.md` § Release Builds.
5. **Google Play upload:** See `CONTENT_RATING_AND_PRIVACY.md` and `STORE_ASSETS.md`.

## Key Assumptions (verify against current Godot/Play docs)

- **Target SDK:** API 36 (required for new Play submissions as of 2026-08-31)
- **Min SDK:** API 24 (Android 7.0; project baseline to verify on devices)
- **Godot version:** 4.7.1 stable
- **Package ID candidate:** `com.example.laststandhomestead` (owner must confirm before first Play upload)
- **Signing:** Debug keystore auto-created by Godot; release keystore must be generated and backed up

**⚠️ Important:** Facts about Google Play requirements, SDK versions, and Android policies drift annually. Before each submission, verify against:
- [Godot 4 Android Export](https://docs.godotengine.org/en/4.0/tutorials/export/exporting_for_android.html)
- [Google Play Console Help — App Requirements](https://support.google.com/googleplay/android-developer/answer/113469)
- [Google Play Content Rating System](https://support.google.com/googleplay/android-developer/answer/188189)
