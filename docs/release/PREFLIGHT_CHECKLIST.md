# Preflight Checklist — Last Stand Homestead Android Release

Complete this checklist before each debug or release build.

## Readiness (Do Once)

- [x] `.\tools\check-android-readiness.ps1` passes (see § Environment Check) — verified 2026-09-06
- [x] Java 17+ installed and in PATH — JDK 17.0.15.6 confirmed
- [x] Android SDK installed with API 36 platform and Build Tools 36.1.0 — verified
- [x] Godot 4.7.1 export templates installed — verified
- [ ] Release keystore created (if planning Google Play submission) — owner responsibility

## Environment Check (Before Each Build)

```powershell
cd %USERPROFILE%\Documents\TopDownZombies
.\tools\check-android-readiness.ps1
```

**Expected:** ✓ All critical checks pass  
**If warning about Godot path:** OK for headless; editor can still export  
**If warning about release keystore:** OK for debug; required for Play submission

## Code and Assets (Before Each Build)

### Game Logic
- [ ] Latest gameplay changes committed (or intentionally not committing per workflow)
- [ ] No uncommitted `game/`, `scenes/`, or `tests/` changes affecting export
- [ ] Saved all open Godot editor tabs

### Project Configuration
- [ ] `project.godot` loaded successfully (no parse errors in editor)
- [ ] Window orientation correct (landscape or portrait)
- [ ] Rendering method is GL Compatibility (mobile-safe)
- [ ] No invasive permissions (no analytics, ads, accounts)

### Assets
- [ ] All art assets present in `assets/` (no missing imports)
- [ ] Licensed assets properly credited in `THIRD_PARTY_NOTICES.md`
- [ ] No placeholder or test art in export

### Save System
- [ ] Game save/load tested on desktop (File > Export Save)
- [ ] Save import/export UI functional
- [ ] No data loss during round-trip (save → export → delete → import)

## Pre-Export Configuration (Debug APK)

### Package ID
- [ ] Package ID decided and documented: `com.<domain>.<game>`
- [ ] Not a placeholder (if final submission, must be unique and permanent)

### Build Metadata
- [ ] Version code incremented (e.g., 1 → 2 → 3)
- [ ] Version string updated (e.g., "1.0.0" → "1.0.1")
- [ ] App name finalized: "Last Stand Homestead"

### Signing
- [ ] Godot debug keystore present: `%APPDATA%\Godot\keystores\debug.keystore`
- [ ] Godot auto-sign enabled (default for debug)

## Pre-Export Configuration (Release AAB)

### Package ID
- [ ] **Final, permanent package ID confirmed** (cannot change after Play submission)
- [ ] Format: reverse-domain, e.g., `com.homegames.laststandhomestead`

### Build Metadata
- [ ] Version code > previous release (e.g., 2 if previous was 1)
- [ ] Version string >= previous release (semantic versioning: major.minor.patch)

### Signing
- [ ] Release keystore exists: `%APPDATA%\Godot\keystores\release.keystore`
- [ ] Keystore password known and stored securely
- [ ] Key alias is `release`
- [ ] Key password available
- [ ] Backup of release.keystore exists offline

### Privacy and Legal
- [ ] No analytics SDK present
- [ ] No ad SDK present
- [ ] No account login or OAuth
- [ ] `THIRD_PARTY_NOTICES.md` complete and accurate

## Debug APK Export (Testing)

### Export
```powershell
cd %USERPROFILE%\Documents\TopDownZombies

# Via Godot editor:
#   1. Project > Export
#   2. Select Android (debug preset)
#   3. Click Export Project
#   4. Save as "LastStandHomestead-debug.apk"

# Or via CLI (if preset exists):
# & "C:\Program Files\Godot\Godot.exe" --export-debug android "LastStandHomestead-debug.apk"
```

### Verification
- [ ] APK file created (size > 0, typically 50-150 MB)
- [ ] No errors in Godot output console
- [ ] APK is readable (not corrupted)

### Installation
```powershell
# Verify device/emulator connected
adb devices

# Install
adb install -r LastStandHomestead-debug.apk

# Expected: "Success"
```

### Testing on Device
- [ ] App launches (main menu appears)
- [ ] Can start a game session
- [ ] Day/night cycle progresses
- [ ] Can build/move structures
- [ ] Can save game
- [ ] Can export save file
- [ ] No crashes during 3-minute play
- [ ] No permission errors
- [ ] Landscape orientation maintained

### Uninstall (Clean Up)
```powershell
adb uninstall com.example.laststandhomestead
```

## Release AAB Export (Google Play Submission)

### Export
```powershell
cd %USERPROFILE%\Documents\TopDownZombies

# Via Godot editor:
#   1. Project > Export
#   2. Select Android (release preset) or create new
#   3. Configure signing (release keystore, password)
#   4. Click Export Project
#   5. Save as "LastStandHomestead-release.aab"

# Via CLI (if preset exists):
# & "C:\Program Files\Godot\Godot.exe" --export-release android "LastStandHomestead-release.aab"
```

### Verification
- [ ] AAB file created (size > 0, typically 20-100 MB)
- [ ] No errors in Godot output console
- [ ] AAB is valid (signature present, not corrupted)

### Signature Check (Optional)
```powershell
# Verify AAB is signed
$aabPath = "LastStandHomestead-release.aab"

# Extract ZIP and inspect
Expand-Archive -Path $aabPath -DestinationPath "aab-check"
Get-Item -Path "aab-check\META-INF\*.RSA" -ErrorAction SilentlyContinue

# If RSA file exists, signing is present ✓
```

### Pre-Upload to Play Console
- [ ] App not previously submitted, or this is an update
- [ ] Version code > current Play Store version
- [ ] AAB will not cause dependency/permission warnings in Play Console
- [ ] All required store assets prepared (see `STORE_ASSETS.md`)

---

## Post-Build Cleanup

```powershell
# Delete debug APK after testing
Remove-Item "LastStandHomestead-debug.apk" -ErrorAction SilentlyContinue

# Keep release AAB until confirmed uploaded to Play
# Then archive or delete per retention policy
```

---

## Troubleshooting

| Issue | Diagnostic | Resolution |
|-------|-----------|-----------|
| APK export fails | Godot output console shows error | Check § Debug APK Export above; see `ANDROID_RELEASE_GUIDE.md` § Troubleshooting |
| Document picker cannot write a save | File operation reports an error after export | Choose a writable destination and inspect `adb logcat`; do not add broad storage permission |
| AAB signature invalid | Play Console rejects upload | Verify release keystore password; re-export with correct keystore |
| Godot export preset missing | "Export template not found" error | Use Godot editor to save preset once, then retry CLI |
| App crashes on device | `adb logcat` shows exception | Check device logs; test on desktop; review `game/` script changes |

---

## Checklist Sign-Off

| Item | Result | Date |
|------|--------|------|
| Readiness check | ✓ PASS / ⚠ WARN / ✗ FAIL | |
| Code review | ✓ Ready | |
| Asset validation | ✓ Complete | |
| Debug APK test | ✓ Installed, played 3 min | |
| Release AAB export | ✓ Complete, signature valid | |
| Ready for submission | ✓ YES | |

---

## Next Steps (After Build)

- **Debug APK:** Distribute to testers, collect feedback
- **Release AAB:** Upload to Google Play Console, submit for review
- **Post-submission:** Monitor Play Console for crashes, reviews, and engagement metrics
