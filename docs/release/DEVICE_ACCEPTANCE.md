# Physical Device Acceptance Checklist — Last Stand Homestead

Complete this checklist on a real Android device (phone or tablet) before any Google Play submission. Do not skip sections; each verifies critical gameplay and data-handling flows.

---

## Pre-Test Setup

### Device Requirements

- **Physical device** (phone or tablet) or **emulator** (Android 7.0 or higher)
- **Minimum SDK:** API 24 (Android 7.0) ✓ verify in device Settings > About
- **Storage:** At least 200 MB free disk space
- **Network:** WiFi or cellular (for Play Store updates; gameplay is offline)

### Installation

```powershell
# On development machine, in project root:
cd %USERPROFILE%\Documents\TopDownZombies

# Build debug APK
# Via Godot editor: Project > Export > Android > Export Project > LastStandHomestead-debug.apk

# Install to device
adb install -r LastStandHomestead-debug.apk

# Verify installation succeeded
adb shell pm list packages | findstr laststandhomestead
```

**Expected:** Package `com.example.laststandhomestead` installed.

---

## Core Gameplay (5–7 minutes)

### App Launch & Main Menu

- [ ] App icon appears on home screen (correct icon, no debug label)
- [ ] Tap icon → app launches (no crash, no black screen >2 seconds)
- [ ] Main menu renders in landscape orientation ✓
- [ ] Menu buttons are responsive (touch input recognized)
- [ ] No visual glitches, texture errors, or rendering artifacts

### Day Phase (5 minutes real-time)

**Start a new game session:**

- [ ] Game starts with DAY phase indicator visible
- [ ] Map loads with terrain, props, and base visible
- [ ] Player character renders at spawn point
- [ ] HUD shows: health, resources (scrap/wood/parts/ammo), phase timer

**Movement & Camera:**

- [ ] Left virtual stick moves player character smoothly
- [ ] Character faces direction of movement (no spinning/jitter)
- [ ] Screen camera follows player (no disconnect between position and view)
- [ ] Landscape orientation maintained (no rotation glitches)

**Resource Collection:**

- [ ] Walk to resource pile (wood, scrap, parts, or ammo)
- [ ] Tap/interact to pick up
- [ ] Resource count in HUD increases ✓
- [ ] Multiple items can be picked up (repeat 3+ times)
- [ ] No permission errors in logcat (`adb logcat`)

**Building (at least one of three):**

- [ ] Tap BUILD button (or hotbar icon)
- [ ] Build menu appears, listing: Barricade, Spike Trap, Auto-Turret
- [ ] Tap each buildable to place:
  - [ ] **Barricade** places and renders at cursor
  - [ ] **Spike Trap** places and renders at cursor
  - [ ] **Auto-Turret** places and renders at cursor
- [ ] Deselect build mode (return to normal gameplay)
- [ ] No crashes after placing multiple structures

**Phase Transition (Day → Night):**

- [ ] Timer counts down (5:00 → 0:00 during day)
- [ ] Visual shift (lighting, sky color) indicates approaching night
- [ ] At 0:00, screen transitions to night with visual indicator (red haze, music change, or text)
- [ ] Base becomes locked / player movement may be restricted (design-dependent)

### Night Phase (5 minutes real-time)

**Zombie Waves:**

- [ ] Zombies spawn at wave start (animated, visible)
- [ ] Zombies move toward base or player
- [ ] Zombies are animated (walking, attacking)
- [ ] Defend: Use right-side aim/fire pad to shoot
  - [ ] Fire button responds (visible tracer/bullet feedback)
  - [ ] Zombies take damage (health indicator or death animation)
- [ ] Waves escalate (more or stronger zombies over time)

**Survival & Wave Progression:**

- [ ] Base health visible (if shown in UI)
- [ ] Player health bar updates (take damage from zombies)
- [ ] Ammo count decreases with each shot
- [ ] Structures provide defense (if adjacent to zombies, barrier reduces damage)
- [ ] Survive waves without base destruction (if possible, for first session)

**Night → Day Transition:**

- [ ] Timer counts down (5:00 → 0:00 during night)
- [ ] If player/base survives, transition to next day
- [ ] Screen shifts back to day lighting/colors
- [ ] Wave progress or session stats displayed (optional)

---

## Save & Export (Critical)

### Auto-Save Verification

- [ ] Play game for 3+ minutes (accumulate resources, build, survive a wave)
- [ ] Pause game (if pause menu exists) or exit to main menu
- [ ] Restart app (or continue from last session)
- [ ] **Expected:** Game resumes at last checkpoint, resources/structures intact

### Manual Export

**Export a save file:**

1. In-game menu → "Export Save" (or similar)
2. Android native document picker appears
   - [ ] Picker is responsive (no hang or freeze)
   - [ ] Can select destination folder (Downloads, Documents, or custom)
3. File saved as `.json` (or similar text format)
   - [ ] File appears in chosen location (verify via file manager)
   - [ ] File size > 0 bytes (not empty)
   - [ ] File is readable text (not corrupted binary)

**Expected:** Save file exported successfully, accessible to player.

### Manual Import

**Import the exported save:**

1. In-game menu → "Import Save" (or new game, then import)
2. Android native document picker appears
3. Select the previously exported `.json` file
   - [ ] File picker is responsive
   - [ ] Selection succeeds
4. Game loads save data
   - [ ] Resources match the exported state
   - [ ] Structures are in same locations
   - [ ] Progress/score preserved

**Expected:** Save round-trip complete; data integrity verified.

### Delete & Re-import (Optional Stress Test)

- [ ] Export save again
- [ ] Delete save from device (in-game "New Game" or direct file deletion)
- [ ] Verify game state reset (empty resources, no structures)
- [ ] Import previously exported save
- [ ] Verify all data restored

---

## UI & Controls

### Pause Menu

- [ ] Pause button/gesture works (gameplay freezes)
- [ ] Pause menu displays options (Resume, Settings, Exit)
- [ ] Resume → gameplay continues from pause point
- [ ] Settings → any configurable options (if present)
- [ ] Exit → returns to main menu (no crash)

### Touch Response

- [ ] All buttons respond within 100 ms of tap (no input lag)
- [ ] Virtual stick is smooth and responsive
- [ ] No phantom touches or input echoes
- [ ] Landscape orientation maintained during all touches

### Visual Quality

- [ ] No graphical glitches (texture misalignment, flickering)
- [ ] Animation smooth (60 FPS or stable frame rate)
- [ ] Text readable (font size adequate for 5–6 inch screen)
- [ ] Colors correct (no color-space errors, no oversaturation)

---

## Performance & Stability

### Frame Rate

- [ ] Game runs smoothly without visible stuttering
- [ ] Frame rate consistent during gameplay and phase transitions
- [ ] No frame drops during wave spawns or structure placement

### Memory & Battery

- [ ] App memory usage stable (< 500 MB estimated, depends on device)
- [ ] No memory leaks (app does not slow down over time)
- [ ] Battery drain is normal (expect ~5% per minute during 5-min session)

### Crashes & Errors

- [ ] No app crashes during 10-minute session
- [ ] No ANR (Application Not Responding) dialogs
- [ ] No visible error popups or uncaught exceptions
- [ ] Logcat clean (run `adb logcat` during play, check for ERROR/FATAL)

---

## Audio (If Present)

- [ ] Background music plays (or silence if not implemented)
- [ ] Sound effects play (gunshots, zombie growls, building placement, etc.)
- [ ] Audio is not distorted or clipped
- [ ] Volume adjustable via device volume buttons

---

## Permissions & Storage

### Storage Access

- [ ] Save export uses Android document picker (not broad storage permission)
- [ ] No "Storage access denied" errors
- [ ] No permission request popups (unless first-time export)
- [ ] Exported `.json` files are world-readable (user can share if desired)

### Dangerous Permissions

- [ ] **NO internet permission** in manifest (verify in Settings > Apps > App Info > Permissions)
- [ ] **NO location permission** requested
- [ ] **NO camera/microphone permission** requested
- [ ] **NO contacts permission** requested
- [ ] **NO call permission** requested

**Verify:**
```powershell
adb shell pm dump com.example.laststandhomestead | findstr -i "uses-permission"
```

Expected: Only non-dangerous permissions (e.g., `INTERNET` only if needed for crash reporting; in our case, NO internet expected).

---

## Edge Cases & Stress

### Battery Low

- [ ] Reduce device battery to <10% (or simulate via settings)
- [ ] App continues to run without premature exit
- [ ] Save export still works (does not require power-saving mode)

### Minimal Storage

- [ ] If device has <50 MB free, save export still works
- [ ] App provides a message if storage is full (expected behavior)

### Rapid Orientation Changes

- [ ] Rotate device 5–10 times rapidly
- [ ] Game handles rotation gracefully (no crash, minimal pause)
- [ ] HUD and gameplay resume correctly

### Long Session (Optional)

- [ ] Play for 20+ minutes
- [ ] Check for memory creep or frame rate degradation
- [ ] Verify save/export still works after extended play

---

## Acceptance Sign-Off

| Checklist Section | Pass/Fail | Notes |
|-------------------|-----------|-------|
| App Launch & Menu | ✓ / ✗ | |
| Day Phase | ✓ / ✗ | |
| Night Phase | ✓ / ✗ | |
| Save & Export | ✓ / ✗ | |
| UI & Controls | ✓ / ✗ | |
| Performance | ✓ / ✗ | |
| Permissions | ✓ / ✗ | |

**Overall Status:** ✓ PASS / ✗ FAIL

**Tested on:**
- Device: [manufacturer model, e.g., "Samsung Galaxy S23"]
- Android Version: [e.g., "Android 14 (API 34)"]
- Date: [e.g., "2026-09-06"]
- Tester: [name or role]

**Issues Found (if any):**

1. Issue description
2. Issue description
3. ...

**Recommendations for Next Release:**

- [ ] Resolved all critical issues (crashes, permission errors, save data loss)
- [ ] Verified gameplay loop from day spawn → night survival → phase transition
- [ ] Confirmed save/export/import round-trip works
- [ ] Device accepted; ready for Play Store submission

---

## Blockers Requiring Owner Action

- [ ] Release keystore not created → follow `ANDROID_RELEASE_GUIDE.md` § Signing
- [ ] Package ID not confirmed → decide and update in Godot export settings
- [ ] Store assets not prepared → follow `STORE_ASSETS.md`
- [ ] Privacy policy not published → complete template in `CONTENT_RATING_AND_PRIVACY.md`

---

## Next Steps (After Acceptance)

1. **Create release keystore** (if not already done)
2. **Export release AAB** — follow `ANDROID_RELEASE_GUIDE.md` § Release Builds
3. **Submit to Google Play Console:**
   - Upload AAB
   - Complete store listing (icon, screenshots, description)
   - Answer content rating questionnaire (IARC)
   - Review and publish
4. **Monitor Play Store** for crashes, reviews, and user feedback

---

## References

- [Godot Android Export](https://docs.godotengine.org/en/4.0/tutorials/export/exporting_for_android.html)
- [Android App Manifest Permissions](https://developer.android.com/guide/topics/manifest/uses-permission-element)
- [Google Play Console — Publishing Guide](https://support.google.com/googleplay/android-developer/answer/7159011)
