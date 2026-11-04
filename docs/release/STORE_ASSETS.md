# Google Play Store Assets — Last Stand Homestead

Required graphics, screenshots, descriptions, and media for the Google Play Store listing.

## Asset Checklist

| Asset | Requirement | Format | Size | Status |
|-------|-------------|--------|------|--------|
| App Icon | Required | PNG | 512×512 px | ⏳ TODO |
| Feature Graphic | Recommended | PNG/JPG | 1024×500 px | ⏳ TODO |
| Screenshots (3–8) | Required | PNG/JPG | 1440×2560 px (landscape: 2560×1440) | ⏳ TODO |
| Video Preview | Recommended | MP4 | 1280×720 or higher | ⏳ TODO |
| Promo Graphic | Optional | PNG/JPG | 180×120 px | ⏳ TODO |

---

## App Icon

### Specifications

- **Dimensions:** 512×512 pixels
- **Format:** PNG (32-bit, RGBA with alpha channel)
- **Safe area:** 48×48 to 464×464 px (inner safe zone, avoid edges)
- **Background:** Can be transparent or solid; avoid pure white for contrast
- **Style:** Consistent with game branding

### Design Notes

- Should be recognizable at small sizes (48px, 96px)
- No text or version numbers on icon
- Avoid intricate details (scales down poorly)
- Consider colorblind accessibility (avoid red-green only)
- Must clearly represent "survival/base-building" theme

### File Location

Save as: `docs/release/assets/app_icon_512.png`

---

## Feature Graphic

### Specifications

- **Dimensions:** 1024×500 pixels (exact)
- **Format:** PNG or JPG
- **File size:** < 2 MB
- **Style:** Marketing-focused, eye-catching
- **Text:** Optional (if used, ensure readable at small sizes)

### Content Suggestion

- Key art from game (base-building, zombie combat)
- Title "LAST STAND HOMESTEAD"
- Tagline or USP (e.g., "Survive. Build. Fight. Repeat.")
- Avoid small details; keep bold and scannable

### File Location

Save as: `docs/release/assets/feature_graphic_1024x500.png`

---

## Screenshots

### Specifications

- **Quantity:** 3–8 screenshots (recommended: 5–8 for better coverage)
- **Dimensions:** 
  - Landscape: 2560×1440 pixels (preferred for Android tablet/phone landscape)
  - Portrait: 1440×2560 pixels (if portrait mode available)
- **Format:** PNG or JPG
- **File size:** Each < 5 MB
- **Aspect ratio:** 16:9 (landscape) or 9:16 (portrait)

### Recommended Screenshot Sequence

1. **Main menu / initial view** — Shows title, main menu buttons, inviting UI
2. **Day phase gameplay** — Scavenging, resource collection, base visible
3. **Building/construction** — Placing structures, UI clarity
4. **Night phase engagement** — Combat, zombie waves, action
5. **Save/export feature** — Player data control (unique selling point)
6. **Game over or progression** — Shows narrative/progression (optional)
7. **Graphics/settings variety** — If multiple rendering modes available (optional)
8. **Mobile UI in action** — Controls, HUD, readability on phone (optional)

### Design Notes

- Include **captions or overlays** (optional but recommended):
  - "5-minute day: Scavenge and build"
  - "5-minute night: Defend your base"
  - "Offline play — No account required"
  - "Export saves anytime"

- Ensure text is **large and readable** (minimum 24px font)
- Show **actual gameplay**, not just menus
- Avoid temporary debug UI, placeholder art, or error messages
- Showcase **unique features** (base-building, survival mechanics, save export)

### File Location

Save as:
```
docs/release/assets/screenshot_1.png
docs/release/assets/screenshot_2.png
... (up to 8)
```

---

## Video Preview (Recommended)

### Specifications

- **Duration:** 15–60 seconds (recommended: 20–30 sec)
- **Resolution:** 1280×720 (720p) minimum; 1920×1080 (1080p) preferred
- **Format:** MP4 (H.264 video, AAC audio)
- **Frame rate:** 30 fps
- **File size:** < 100 MB
- **Audio:** In-game audio + optional subtitle captions

### Content Suggestion

- **0–5 sec:** Cinematic intro / title screen
- **5–15 sec:** Day phase gameplay (building, scavenging)
- **15–25 sec:** Transition to night / wave survival
- **25–30 sec:** Combat highlights, wave progression
- **30+ sec:** Base-building capabilities, save export
- **Final 3 sec:** Tagline or rating

### File Location

Save as: `docs/release/assets/preview_video.mp4`

---

## Promo Graphic (Optional)

### Specifications

- **Dimensions:** 180×120 pixels
- **Format:** PNG or JPG
- **Style:** Simplified icon/key art
- **Use:** Small promotional tiles in store

Not critical for initial release but useful for promotional campaigns.

### File Location

Save as: `docs/release/assets/promo_graphic_180x120.png`

---

## Text Content for Play Store Listing

### App Name

**Last Stand Homestead**

(Max 50 characters, no special characters beyond hyphen, underscore)

### Short Description

(Max 80 characters)

```
Survive, build, and defend your homestead against waves of zombies.
```

### Full Description

(Max 4000 characters; use line breaks for readability)

```
LAST STAND HOMESTEAD

A survival game where every decision matters. You have one goal: survive the night.

GAMEPLAY

- 5-Minute Days: Scavenge for resources, gather supplies, and expand your base.
- 5-Minute Nights: Defend against escalating waves of zombies.
- Build & Defend: Construct walls, towers, and fortifications.
- Permadeath: Each wave is harder. Can you survive the onslaught?

FEATURES

✓ Offline-First Gameplay — No internet required. No account system.
✓ Local Save/Export — Your saves are yours. Export anytime.
✓ Strategic Building — Place structures wisely; ammunition is limited.
✓ Progression & Waves — Escalating difficulty keeps you engaged.
✓ Portrait & Landscape — Play how you want.
✓ No Ads, No Analytics, No Tracking — Just you, your base, and the zombies.

NO ACCOUNT. NO ADS. NO ANALYTICS.

Every session is a standalone battle for survival. Export your progress whenever 
you want—your data is completely in your control.

Survive the night. Repeat.
```

### Category

- **Primary:** Games
- **Subcategory:** Action or Strategy

### Content Rating

- **ESRB:** E10+ (or IARC equivalent after questionnaire)
- **PEGI:** 7

### Tagline (for marketing use)

```
Survive. Build. Fight. Repeat.
```

---

## Design Guidelines for Store Assets

### Color and Branding

- **Color palette:** Warm (sunset/fire tones) or cool (night) for atmosphere
- **Fonts:** Clear, bold sans-serif (avoid tiny details)
- **Consistency:** All assets should feel cohesive

### Accessibility

- **Color contrast:** Ensure text is readable (WCAG AA minimum: 4.5:1 contrast)
- **Text size:** 24px minimum for screenshots and graphics
- **No flashing:** Videos must not have rapid flashing (epilepsy safety)

### Legal & Compliance

- **Copyright:** Ensure all assets are original or properly licensed
- **No misleading claims:** Screenshots must be from the actual game
- **No spoilers:** Avoid major story beats if narrative exists later

---

## Asset Organization

Suggested directory structure:

```
docs/
├── release/
│   ├── STORE_ASSETS.md (this file)
│   └── assets/
│       ├── app_icon_512.png
│       ├── feature_graphic_1024x500.png
│       ├── screenshot_1.png
│       ├── screenshot_2.png
│       ├── screenshot_3.png
│       ├── screenshot_4.png
│       ├── screenshot_5.png
│       ├── preview_video.mp4
│       └── promo_graphic_180x120.png
```

---

## Uploading to Google Play Console

1. **Log in** to [Google Play Console](https://play.google.com/console)
2. **Select your app** > App content > Screenshots
3. **Add screenshots:**
   - Upload PNG/JPG files
   - Reorder by dragging
   - Add captions (optional, recommended)
4. **Add app icon:**
   - Navigate to Setup > App listings > Main store listing
   - Upload 512×512 PNG under "Icon"
5. **Add feature graphic:**
   - Same location as app icon
   - Field: "Feature graphic"
6. **Add short & full descriptions:**
   - Same location
   - Fields: "Short description" (80 chars) and "Full description" (4000 chars)
7. **Review & save** — Preview your listing before publishing

---

## Performance Notes

- Play Store tracks screenshot views and app rating
- A/B test screenshot order if updating
- Monitor feedback for "misleading screenshot" complaints
- Update screenshots after major visual changes in game

---

## Submission Checklist

- [ ] All assets created and meet specifications
- [ ] App icon is 512×512 PNG, not blurry
- [ ] Feature graphic is exactly 1024×500
- [ ] All screenshots are consistent in size and ratio
- [ ] Screenshots show actual gameplay (not debug/placeholder)
- [ ] Video preview is <100 MB MP4
- [ ] Descriptions are accurate and spell-checked
- [ ] Text is readable and not obscured by UI
- [ ] No misleading or false claims
- [ ] Graphics are original or properly licensed
- [ ] THIRD_PARTY_NOTICES.md credits all art/music

---

## References

- [Google Play Console Help — App Listings](https://support.google.com/googleplay/android-developer/answer/6334316)
- [Google Play Console Help — Create App Graphics](https://support.google.com/googleplay/android-developer/answer/1078870)
- [Android Design Guidelines](https://developer.android.com/design)
