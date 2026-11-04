# Google Play Store Listing Copy — Last Stand Homestead

Final copy and metadata ready for submission to Google Play Console.

---

## App Identity

| Field | Value |
|-------|-------|
| **App Name** | Last Stand Homestead |
| **Developer Account** | [OWNER: Your developer account name] |
| **Package ID** | `com.example.laststandhomestead` (permanent after first submission) |
| **Category** | Games > Action |
| **Content Rating** | ESRB E10+ / PEGI 7 (from IARC questionnaire) |

---

## Store Listing Text

### Short Description (80 characters max)

```
Survive, build, and defend your homestead against waves of zombies.
```

**Character count:** 68 ✓

### Full Description (4000 characters max)

```
LAST STAND HOMESTEAD

A survival game where every decision matters. You have one goal: survive the night.

═══════════════════════════════════════════════════════════════════════════════

GAMEPLAY

🌅 5-Minute Days
Scavenge for resources across a procedural map. Gather scrap, wood, ammunition, 
and parts. Build fortifications around your homestead. Prepare for the night.

🌙 5-Minute Nights
The base is locked. Defend against escalating waves of undead. Manage your ammo, 
target approaching zombies, and hold the line until dawn.

🏗️ Strategic Building
Construct walls, spike traps, and auto-turrets. Ammunition is limited. Every 
placement matters. Outwit the horde with clever positioning.

📈 Escalating Challenge
Each night is harder. Zombie count and aggression increase with every wave. 
Survive as long as you can. Compete for the highest score.

═══════════════════════════════════════════════════════════════════════════════

KEY FEATURES

✓ Offline-First Gameplay
No internet required. No account system. No ads. No analytics. Just you, your 
base, and the horde.

✓ Your Data, Your Control
Saves are stored locally on your device. Export anytime. Import anywhere. Your 
progress is completely yours. No cloud sync, no data loss, no lock-in.

✓ Touch-Optimized Controls
Left stick: move. Right pad: aim and fire. Dedicated build button. Compact hotbar. 
Responsive on all screen sizes.

✓ Cross-Device Orientation
Play in portrait or landscape. Game adapts to your preference and rotation.

✓ No Tracking
We don't track you. We don't sell your data. We don't integrate analytics SDKs. 
Enjoy pure gameplay.

═════════════════════════════════════════════════════════════════════════════════

WHAT YOU GET

A complete, playable survival experience. Day phase: exploration and base building. 
Night phase: defense and combat. Local saves you control. No wait. No paywalls. 
No surprises.

Session length: 10 minutes (5-minute day + 5-minute night). Repeat and compete for 
high scores.

═════════════════════════════════════════════════════════════════════════════════

NO ACCOUNT. NO ADS. NO ANALYTICS.

Every session is a standalone battle for survival. Export your progress whenever 
you want—your data is completely in your control.

Survive the night. Repeat.

═════════════════════════════════════════════════════════════════════════════════

COMPLIANCE

• Privacy Policy: [OWNER: Insert URL after hosting policy document]
• Content Rating: PEGI 7 / ESRB E10+ (violence: cartoonish; no gore, no realistic weapons)
• Permissions: Storage only (for save export/import via document picker)
• Third-Party Libraries: Godot Engine (open source)
• Third-Party Art: Licensed CraftPix 2D zombie survivor kit (see THIRD_PARTY_NOTICES.md)
```

**Character count:** [Approximately 2800 / 4000 characters] ✓

---

## Store Listing Metadata

### Tagline (for marketing, not visible in store)

```
Survive. Build. Fight. Repeat.
```

### Promotional Text (optional, appears in Play Store featured sections)

```
Face escalating zombie waves in this offline survival game. Build, defend, and 
export your progress. No account, no ads, no analytics.
```

---

## Content Rating & Compliance Checklist

Before submission to Google Play Console:

- [ ] Privacy policy drafted and hosted at public URL (use template in `CONTENT_RATING_AND_PRIVACY.md`)
- [ ] IARC questionnaire completed at [https://www.iarc.org/](https://www.iarc.org/)
- [ ] IARC certificate received (typically within 24 hours)
- [ ] Content rating confirmed: **PEGI 7** / **ESRB E10+**
- [ ] Google Play Console > Policies > Privacy Policy URL entered
- [ ] Google Play Console > App content > Data Safety section completed:
  - [ ] "Does your app collect sensitive user data?" → No
  - [ ] "Is personal data encrypted in transit?" → N/A (no transmission)
  - [ ] "Does your app allow users to request their data?" → N/A (no data collected)
  - [ ] "Is your app designed for children?" → No (rated E10+ / PEGI 7+)
- [ ] `THIRD_PARTY_NOTICES.md` present in app and accurate
- [ ] No analytics, ads, or account SDKs active in `project.godot`

---

## Store Assets Checklist

| Asset | Format | Dimensions | Status | Notes |
|-------|--------|-----------|--------|-------|
| App Icon | PNG | 512×512 px | ⏳ READY | Save as `docs/release/assets/app_icon_512.png` |
| Feature Graphic | PNG/JPG | 1024×500 px (exact) | ⏳ READY | Save as `docs/release/assets/feature_graphic_1024x500.png` |
| Screenshots (5–8) | PNG/JPG | 2560×1440 px landscape | ⏳ READY | Save as `docs/release/assets/screenshot_N.png` |
| Video Preview | MP4 | 1280×720+ | ⏳ OPTIONAL | 20–30 sec gameplay video |
| Promo Graphic | PNG/JPG | 180×120 px | ⏳ OPTIONAL | For promotional tiles |

**Note:** All asset dimensions, specifications, and design guidance in `STORE_ASSETS.md`.

---

## Version Information

### Current Release

| Field | Value |
|-------|-------|
| **Version Name** | 0.1.0 |
| **Version Code** | 1 |
| **Min SDK** | API 24 (Android 7.0) |
| **Target SDK** | API 36 (Android 16) |
| **Release Date** | [OWNER: Fill in after Play Store approval] |

---

## Pre-Submission Checklist

Before uploading AAB to Google Play Console:

- [ ] Release AAB exported and signed with release keystore
- [ ] AAB file verified (non-empty, valid ZIP structure)
- [ ] All store assets prepared (icon, screenshots, feature graphic)
- [ ] App name confirmed: "Last Stand Homestead"
- [ ] Short description entered: "Survive, build, and defend your homestead against waves of zombies."
- [ ] Full description pasted above
- [ ] Privacy policy URL entered
- [ ] Content rating (PEGI 7 / ESRB E10+) selected
- [ ] Data Safety section completed
- [ ] No screenshots contain debug UI, placeholder art, or errors
- [ ] Device acceptance testing complete (see `DEVICE_ACCEPTANCE.md`)
- [ ] Package ID confirmed permanent and unique: `com.example.laststandhomestead`
- [ ] No uncommitted changes in Git
- [ ] `THIRD_PARTY_NOTICES.md` accurate and includes CraftPix license

---

## Upload Instructions

### Step 1: Log In to Google Play Console

1. Navigate to [https://play.google.com/console](https://play.google.com/console)
2. Sign in with your Google developer account
3. Select or create your app

### Step 2: Upload AAB

1. Navigate to **Release** > **Production**
2. Click **Create new release**
3. Upload the **AAB file** (`LastStandHomestead-release.aab`)
4. Godot will validate the signature and manifest

### Step 3: Add Store Listing

1. Navigate to **Store listing**
2. Fill in:
   - **App name:** "Last Stand Homestead"
   - **Short description:** (max 80 characters)
   - **Full description:** (paste from above, max 4000)
   - **App icon:** Upload 512×512 PNG
   - **Feature graphic:** Upload 1024×500 PNG
   - **Screenshots:** Upload 5–8 images (2560×1440 or 1440×2560)

### Step 4: Add Content Rating

1. Navigate to **App content** > **Content rating questionnaire**
2. Fill out IARC questionnaire (if not done already)
3. Receive and apply IARC certificate

### Step 5: Data Safety

1. Navigate to **App content** > **Data Safety**
2. Complete the security and data practices section
3. Confirm:
   - No sensitive user data collected
   - No analytics, ads, or account SDKs
   - Offline-only, local saves

### Step 6: Review & Publish

1. Review all fields for accuracy
2. Accept Google Play policies
3. Click **Review** > **Submit for review**

### Step 7: Monitor Review

- Google Play review typically takes 3–24 hours
- Monitor Play Console for approval or rejection
- If rejected, address feedback and resubmit
- Once approved, app is live

---

## Post-Launch Monitoring

### Key Metrics to Track

- Install count
- Daily active users (DAU)
- Average rating and star count
- Crash reports (via Godot logs or custom reporting)
- User reviews and feedback

### Update Cycle

Plan updates for:
- Bug fixes (as needed)
- Gameplay balance adjustments (monthly or quarterly)
- New features (seasonal)
- Content rating changes (if new content added)

Each update requires:
- Version code increment (e.g., 1 → 2 → 3)
- Version name bump (e.g., 0.1.0 → 0.2.0)
- Re-export and re-sign AAB
- Re-submission to Play Console

---

## Owner Responsibilities (Before Submission)

- [ ] Confirm package ID: `com.example.laststandhomestead` is final and unique
- [ ] Create and secure the release keystore (do not commit to Git)
- [ ] Host privacy policy at a public URL (use template from `CONTENT_RATING_AND_PRIVACY.md`)
- [ ] Complete IARC questionnaire and receive certificate
- [ ] Prepare store assets (icon, screenshots, feature graphic)
- [ ] Test on physical Android device (follow `DEVICE_ACCEPTANCE.md`)
- [ ] Sign release AAB with release keystore
- [ ] Upload AAB and store assets to Google Play Console
- [ ] Monitor Play Store for approval

---

## References

- [Godot Android Export Documentation](https://docs.godotengine.org/en/4.0/tutorials/export/exporting_for_android.html)
- [Google Play Console Help — App Listings](https://support.google.com/googleplay/android-developer/answer/6334316)
- [Google Play Console Help — Publishing Guide](https://support.google.com/googleplay/android-developer/answer/7159011)
- [IARC Ratings System](https://www.iarc.org/)
- [ESRB Ratings](https://www.esrb.org/)
- [PEGI Ratings](https://pegi.info/)

---

## File Organization

All files referenced in this document:

```
docs/release/
├── STORE_LISTING_COPY.md (this file)
├── CONTENT_RATING_AND_PRIVACY.md (privacy policy template)
├── STORE_ASSETS.md (asset specifications)
├── ANDROID_RELEASE_GUIDE.md (build reference)
├── PREFLIGHT_CHECKLIST.md (pre-export checklist)
├── DEVICE_ACCEPTANCE.md (device testing checklist)
├── README.md (quick start guide)
└── assets/
    ├── app_icon_512.png
    ├── feature_graphic_1024x500.png
    ├── screenshot_1.png
    ├── screenshot_2.png
    ├── screenshot_3.png
    ├── screenshot_4.png
    ├── screenshot_5.png
    └── preview_video.mp4 (optional)

tools/
├── check-android-readiness.ps1
└── build-release-signing-command.ps1

THIRD_PARTY_NOTICES.md (in project root)
```
