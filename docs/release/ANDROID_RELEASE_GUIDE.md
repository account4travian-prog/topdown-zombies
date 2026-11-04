# Android Release Guide — Last Stand Homestead

Complete reference for building and submitting Last Stand Homestead to Google Play Store.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Readiness Verification](#readiness-verification)
- [Package ID Configuration](#package-id-configuration)
- [Debug Builds (APK for Testing)](#debug-builds-apk-for-testing)
- [Release Builds (AAB for Google Play)](#release-builds-aab-for-google-play)
- [Signing and Keystore Management](#signing-and-keystore-management)
- [SDK Version Strategy](#sdk-version-strategy)
- [Local Save and Export Handling](#local-save-and-export-handling)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Godot 4.7.1** (editor and export templates) — currently installed
- **Java Development Kit (JDK) 17+** (JDK 21 recommended) — currently installed: JDK 17.0.15.6
- **Android SDK** with API 36, Build Tools 36.1.0, Platform Tools 37.0.1, NDK 29.0.14206865, and CMake 3.22.1 (the Godot 4.7.1 documented toolchain) — currently installed
- **Android keystore files** (debug auto-generated; release must be created)

### Required System Environment

Set or verify these environment variables in Windows:

```cmd
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot
ANDROID_HOME=C:\<path-to-android-sdk>
```

**Godot data paths:**
- Keystores: `%APPDATA%\Godot\keystores\` (Windows)
- Export templates: `%APPDATA%\Godot\export_templates\`
- Editor settings: `%APPDATA%\Godot\editor_settings-4.7.tres`

### Running the Readiness Checker

Before any export, verify the environment:

```powershell
cd %USERPROFILE%\Documents\TopDownZombies
.\tools\check-android-readiness.ps1
```

Expected output: **All critical checks passed**. Warnings about missing release keystore or Godot path are normal on first setup.

---

## Package ID Configuration

### Current Candidate

The checked-in Android presets use **`com.example.laststandhomestead`**. Treat it as a candidate until the owner confirms it: once published on Google Play, the package ID is permanent.

### Godot Export Settings

1. Open Godot editor: Project > Export > Android
2. Configure "Package ID (Reverse Domain)" — examples:
   - **Development:** `com.example.laststandhomestead` or `com.yourteam.laststandhomestead`
   - **Production (Google Play):** Unique, permanent, reverse-domain format (e.g., `com.homegames.laststandhomestead`)

3. Save export preset

Once chosen for Google Play, **package ID cannot be changed** — it is permanent and tied to your account.

### Pre-Export Confirmation Checklist

- [ ] Decide on final package ID (reverse-domain format)
- [ ] Confirm with team/stakeholders — this ID is permanent
- [ ] Update `project.godot` or export preset if desired (optional; can be set at export time)

---

## Debug Builds (APK for Testing)

### What is a Debug APK?

- Unsigned or self-signed with Godot's debug keystore
- Can be installed on Android emulator or physical device via `adb`
- **Cannot** be submitted to Google Play
- Useful for rapid iteration, testing features, device compatibility

### Export Steps

#### Via Godot Editor (GUI)

1. Open project in Godot 4.7.1 editor
2. **Project > Export** (or Ctrl+Shift+E)
3. Click **Android** (or add preset if not present)
4. Configure:
   - **Package ID:** `com.example.laststandhomestead` (candidate; confirm before Play upload)
   - **Signing:** Leave debug options enabled (Godot auto-signs)
   - **Orientation:** Landscape (verify in Project Settings > Display)
5. Click **Export Project** → save as `LastStandHomestead-debug.apk`

#### Via Command Line

Godot CLI export (if editor not available):

```powershell
# Requires project.godot to have Android export preset
cd %USERPROFILE%\Documents\TopDownZombies

# Find Godot executable
$godotExe = "C:\Program Files\Godot\Godot.exe"  # Adjust path

# Export debug APK
& $godotExe --export-debug android "LastStandHomestead-debug.apk"
```

**Note:** Command-line export requires valid Android export preset in project. If prompt appears, use editor first to save preset.

### Installing and Testing

```powershell
# List connected devices/emulators
adb devices

# Install APK
adb install -r LastStandHomestead-debug.apk

# Launch app (adjust package ID)
adb shell monkey -p com.example.laststandhomestead 1

# View logs
adb logcat
```

### Debug APK Verification Checklist

- [ ] APK file created successfully (not empty)
- [ ] Installs without errors on test device/emulator
- [ ] App launches and main menu appears
- [ ] Day/night cycle progresses
- [ ] No crashes during 2-minute play session
- [ ] Saves to device storage without permission errors

---

## Release Builds (AAB for Google Play)

### What is AAB (Android App Bundle)?

- **Format:** Google Play's recommended distribution format
- **Signed:** Must be signed with your release keystore
- **Optimization:** Google Play optimizes per-device (smaller downloads)
- **Submission:** Uploaded directly to Google Play Console
- **Not installable locally:** Use debug APK for testing; AAB is for Play Store only

### Release Keystore Creation

If release keystore doesn't exist, create it using Java `keytool`:

```powershell
# Open PowerShell in project root
cd %USERPROFILE%\Documents\TopDownZombies

# Create release keystore (one-time)
# Adjust path if keystores/ folder doesn't exist
$keystoreDir = "$env:APPDATA\Godot\keystores"
$keystorePath = "$keystoreDir\release.keystore"

# Run keytool (Windows)
& "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot\bin\keytool.exe" `
    -genkey -v `
    -keystore $keystorePath `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias release

# Prompts for:
#   - Keystore password (e.g., "YourSecurePassword")
#   - Key password (often same)
#   - Company name, organizational unit, city, state, country
#   - Alias name (release)
```

**⚠️ Critical:** Backup this keystore file and passwords. **If lost, you cannot update your app on Google Play.**

```powershell
# Backup (run after keystore creation)
Copy-Item "$keystoreDir\release.keystore" -Destination "release.keystore.backup" -Force
# Store backup in secure location (e.g., password manager, offline storage)
```

### Export Steps

#### Via Godot Editor

1. **Project > Export > Android**
2. Ensure **Release (AAB)** preset is selected (or create new)
3. Configure:
   - **Package ID:** Your permanent package ID
   - **Signing:** Enable "Release Signing"
   - **Keystore:** Select release keystore (path: `%APPDATA%\Godot\keystores\release.keystore`)
   - **Keystore password:** Enter your keystore password
   - **Key alias:** `release`
   - **Key password:** Enter key password
4. Click **Export Project** → save as `LastStandHomestead-release.aab`

#### Via Command Line

```powershell
cd %USERPROFILE%\Documents\TopDownZombies

# Requires Android release preset saved in project
$godotExe = "C:\Program Files\Godot\Godot.exe"

# Export release AAB (interacts with Godot's Android preset)
& $godotExe --export-release android "LastStandHomestead-release.aab"
```

**Note:** Release export prompts for keystore password interactively unless stored in project settings (not recommended).

### Release Build Verification

- [ ] AAB file created successfully (typically 20-100 MB)
- [ ] File is not empty and valid AAB format
- [ ] Can be uploaded to Google Play Console (no signature errors)
- [ ] Version code and version name match project settings
- [ ] All required metadata present in manifest

---

## Signing and Keystore Management

### Keystore Locations

| Keystore       | Path                                           | Purpose                      |
|----------------|------------------------------------------------|------------------------------|
| **debug**      | `%APPDATA%\Godot\keystores\debug.keystore`   | Auto-testing, dev builds     |
| **release**    | `%APPDATA%\Godot\keystores\release.keystore` | Google Play submissions      |

### Keystore Properties

```
Alias:           release
Algorithm:       RSA
Key Size:        2048 bits
Validity:        10,000 days (~27 years)
Signature Alg:   SHA-256
```

### Password Management

**Do not:**
- Store passwords in project files or version control
- Share keystore files via email or unencrypted channels
- Use weak passwords (minimum 8 characters, mix of types recommended)

**Do:**
- Store passwords in password manager (1Password, LastPass, KeePass)
- Backup keystore offline (external drive, secure cloud)
- Rotate release keystore before its 10-year expiration

### Retrieving Keystore Info

To verify or list keystore certificates:

```powershell
$keystorePath = "$env:APPDATA\Godot\keystores\release.keystore"

& "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot\bin\keytool.exe" `
    -list -v -keystore $keystorePath

# Prompts for keystore password, then displays certificate details
```

---

## SDK Version Strategy

### Target and Minimum SDK Levels

| Setting       | Value  | Notes                                             |
|---------------|--------|---------------------------------------------------|
| **Min SDK**   | 24     | Android 7.0 (API 24); tested compatibility baseline |
| **Target SDK**| 36     | Android 16 (API 36); required for new Play submissions as of 2026-08-31 |

**⚠️ Verification Required:** Google Play's minimum target SDK requirement increases yearly (typically August). Before submission, verify current requirement:
- [Google Play Console Help — App Requirements](https://support.google.com/googleplay/android-developer/answer/113469)

The checked-in `export_presets.cfg` explicitly targets API 36. Re-check the policy before every submission and update both presets when Google raises the requirement.

```
# In project.godot or Godot export settings:
gradle_build/target_sdk = 36
```

Then re-export and test.

### Godot Android Permissions

The game declares **no account system, no analytics, no ads.** Verify `project.godot` does not include:

```
# Should NOT be present:
#   android/permissions (invasive permissions)
#   android/intent_filters (account/OAuth)
#   analytics (Sentry, Firebase, etc.)
#   ads (AdMob, AppLovin, etc.)
```

Current expectation:
- **Required:** no dangerous Android permissions for gameplay or `user://` saves.
- **Save export:** use Android's Storage Access Framework/document picker; do not request legacy broad storage permissions.
- **Not required:** internet, storage, location, camera, microphone, contacts, or phone state.

If `project.godot` is later modified with permissions, re-run this guide's verification section.

---

## Local Save and Export Handling

### Save Files

- **Location:** Device internal storage (app-private folder)
- **Format:** Versioned JSON
- **Player access:** Via the in-game export/import UI and Godot's native file dialog

### Export Behavior

**Game exports saves as:**
- File format: `.json`
- Destination: chosen by the player in the native Android document picker
- Access: Storage Access Framework grant for the selected document; no broad storage permission
- Device acceptance: verify export, delete/local reset, and import round-trip on a physical Android device before release

**Google Play considerations:**
- No cloud sync (offline-first design)
- No account login required
- No telemetry collected

This satisfies "no analytics SDK" requirement and simplifies privacy compliance.

---

## Troubleshooting

### "Android SDK not found"

```powershell
# Set ANDROID_HOME
$env:ANDROID_HOME = "C:\Android\sdk"  # Adjust to your SDK path
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, "User")

# Verify
.\tools\check-android-readiness.ps1
```

### "Export templates not found"

1. Open Godot 4.7.1 editor
2. **Project > Tools > Manage Export Templates**
3. Click **Install** next to 4.7.1 stable
4. Wait for download and extraction (~500 MB)

### "Keystore password incorrect"

```powershell
# Test keystore with correct password
$keystorePath = "$env:APPDATA\Godot\keystores\release.keystore"

& "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot\bin\keytool.exe" `
    -list -keystore $keystorePath

# Prompts for password; if wrong, fails with "Keystore was tampered with"
```

### "Godot headless export fails"

Godot command-line export requires valid export preset. If not saved:

1. Open editor GUI
2. **Project > Export > Android** (or create new)
3. Configure all settings (package ID, signing, etc.)
4. Click **Export** once to cache preset
5. Close editor
6. Retry CLI command

### "AAB fails to upload — missing signing certificate"

Verify release keystore was used:

```powershell
# Extract and inspect AAB signature
$aabPath = "LastStandHomestead-release.aab"

# AAB is ZIP format; inspect with 7-Zip or:
Expand-Archive -Path $aabPath -DestinationPath "aab-inspect"
Get-ChildItem -Path "aab-inspect\META-INF" -Filter "*.RSA" -Recurse
```

If no `.RSA` file or signature mismatch, re-export with correct release keystore.

---

## Additional Resources

- [Godot Android Export (Official Docs)](https://docs.godotengine.org/en/4.0/tutorials/export/exporting_for_android.html)
- [Android Developers — App Publishing](https://developer.android.com/distribute)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android SDK Platform Release Notes](https://developer.android.com/about/versions)
