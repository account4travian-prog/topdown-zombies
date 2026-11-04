# Content Rating and Privacy Guide — Last Stand Homestead

Reference for Google Play Console submissions, including content rating answers, privacy policy framework, and data safety disclosures.

## Overview

**Last Stand Homestead** is an offline survival game with:
- **No account system** — no login, no user data collection
- **No analytics SDK** — no telemetry, no crash reporting, no usage tracking
- **No ads SDK** — no advertising or third-party ad network
- **No remote services** — all gameplay is local and deterministic
- **Local saves only** — player controls all save data via in-game export/import

This simplification dramatically reduces privacy complexity and makes compliance straightforward.

---

## Content Rating Questionnaire (IARC)

### Required Information

Before submission to Google Play, complete the IARC Content Rating questionnaire at [https://www.iarc.org/rating-system-select.jsp](https://www.iarc.org/rating-system-select.jsp).

The questionnaire will ask about content in your app. Below are the answers for Last Stand Homestead.

### Question by Question

#### Violence

**Q: Does the app contain violence?**

**Answer:** Yes, cartoonish

**Explanation:** The game features combat against stylized zombie enemies. Violence is:
- Cartoonish and not realistic
- No blood or gore
- No depiction of realistic weapons or injury
- Fantasy/arcade-style

**IARC Rating Impact:** Likely PEGI 7 / ESRB E10+ (depending on region)

---

#### Scary/Horror

**Q: Does the app contain content that might be frightening to young children?**

**Answer:** Possibly — Mild

**Explanation:** Zombies are stylized but may be mildly scary for very young children (under 5). Atmosphere is not horror-focused; gameplay is action-oriented.

**IARC Rating Impact:** PEGI 7+ / ESRB E10+

---

#### Alcohol / Tobacco / Drugs

**Q: Does the app contain references to or use of alcohol, tobacco, or drugs?**

**Answer:** No

**Explanation:** None present.

---

#### Sexual Content / Nudity

**Q: Does the app contain sexual content or nudity?**

**Answer:** No

**Explanation:** None present.

---

#### Profanity

**Q: Does the app contain profanity or crude language?**

**Answer:** No

**Explanation:** All in-game text (UI, dialogue) uses appropriate language. No profanity.

---

#### In-App Purchasing

**Q: Does the app contain in-app purchases or links to a store?**

**Answer:** No

**Explanation:** Game is free-to-play with no purchasable items, ads, or monetization.

---

#### In-App Advertising

**Q: Does the app contain advertisements?**

**Answer:** No

**Explanation:** No ads present. No ad SDK integrated.

---

#### User-Generated Content

**Q: Does the app allow user-generated content (e.g., screenshots, videos, messages)?**

**Answer:** No

**Explanation:** Game does not allow players to generate, upload, or share content directly from the app.

---

#### Location Data

**Q: Does the app collect or request location data?**

**Answer:** No

**Explanation:** GPS/location permission not requested or used.

---

#### Personal Information

**Q: Does the app collect personal information (name, email, address)?**

**Answer:** No

**Explanation:** Game is fully offline. No account required. No personal information requested or stored.

---

#### Social Features

**Q: Does the app contain social networking or communication features?**

**Answer:** No

**Explanation:** No multiplayer, chat, or social connectivity.

---

### Expected IARC Classification

Based on above answers:

- **PEGI 7** (Europe)
- **ESRB E10+** (North America — "Everyone 10 and older")
- **USK 6** (Germany)
- **ClassInd L** (Brazil — "General Audiences")
- **GRAC** (South Korea — equivalent to E10+)

**Note:** Final rating determined by IARC after questionnaire submission. Above is based on current game description.

---

## Privacy Policy

### Required Privacy Policy

Google Play **requires a privacy policy URL** in your app listing, even if the app collects no data. Below is a template for a zero-collection privacy policy.

### Template Privacy Policy

```
LAST STAND HOMESTEAD
PRIVACY POLICY

Effective Date: 2026-09-06

1. OVERVIEW

Last Stand Homestead ("we," "our," or "the App") is committed to protecting your 
privacy. This Privacy Policy explains our practices regarding data collection and use.

2. INFORMATION WE DO NOT COLLECT

The App does NOT:
- Collect personal information (name, email, address, phone number)
- Collect device identifiers (IDFA, GAID, IMEIs)
- Collect location data (GPS, WiFi location)
- Collect analytics or usage telemetry
- Integrate third-party analytics SDKs (Firebase, Sentry, Amplitude, etc.)
- Integrate advertising or ad network SDKs (Google Ads, AppLovin, Facebook, etc.)
- Require account login or registration
- Transmit data to remote servers

3. LOCAL SAVES

The App stores game progress locally on your device only. You control when saves are:
- Created (automatic after each game session)
- Exported (manual, player-initiated)
- Deleted (manual, player-initiated)
- Imported (manual, player-initiated)

Exported saves remain under your control and are not transmitted to us.

4. PERMISSIONS

The App does not request broad storage permission. Save files stay in the app's
private local storage. When the player chooses Export or Import, Android's native
document picker grants access only to the document the player selects. No save
data is collected or transmitted.

5. CHILDREN'S PRIVACY

The App is not directed to children under 13 (COPPA) or the equivalent in your 
region. If you believe a child has submitted personal information, contact us 
immediately (see § 7).

6. UPDATES TO THIS POLICY

We may update this Privacy Policy. Changes will be posted here with an updated 
effective date. Continued use of the App constitutes acceptance of changes.

7. CONTACT

Questions about this Privacy Policy? Contact:

[OWNER: Insert contact email or support address before publishing]

[OWNER: Insert website or social media link, or "No official website" if applicable]
```

### Implementation

1. Save the above as `privacy_policy.html` or `.md` in your project (or host on a website)
2. Host on a publicly accessible URL (e.g., `https://yourwebsite.com/privacy`)
3. In Google Play Console, provide the URL in "Policies" > "Privacy Policy"

---

## Data Safety Section (Google Play)

As of 2022, Google Play requires all apps to complete a "Data Safety" declaration. This section guides you through each category.

### Google Play Console > App Content > Data Safety

#### 1. Does your app collect or request permission to access sensitive user data?

**Answer:** No

**Explanation:** The app does not request or access:
- Personal information
- Location
- Contacts
- Calendar
- Health data
- Financial information
- Biometrics
- Photos or videos (beyond accessing saved games in storage)

---

#### 2. Is personal data encrypted in transit?

**N/A** — No data is transmitted

---

#### 3. Is personal data encrypted at rest?

**N/A** — No personal data is stored

**Note:** Save game files are stored locally on device (app-private storage or Downloads folder, user-selected). No special encryption needed for offline game state.

---

#### 4. Is personal data retained after user deletion?

**N/A** — No personal data is collected

**Local saves:** The player controls deletion via in-game export/import interface.

---

#### 5. Does your app allow users to request and download their data?

**N/A** — No data is collected

**Equivalent for saves:** Players can export their saved game at any time via in-game UI, giving them full control over their data.

---

#### 6. Is your app compliant with play policies on payments?

**Answer:** Yes / N/A

**Explanation:** The app has no in-app purchases, ad monetization, or payment processing.

---

#### 7. Is your app designed for children (under 13)?

**Answer:** No

**Explanation:** While family-friendly, the game is not specifically designed for children under 13. It is rated ESRB E10+ (10 and up).

---

### Data Safety Checklist for Play Console

- [ ] App collects no sensitive user data
- [ ] No third-party SDKs (analytics, ads, crash reporting)
- [ ] App does not access location, contacts, calendar, or other protected data
- [ ] All data stored locally on device
- [ ] Privacy policy linked and publicly accessible
- [ ] No account system or remote authentication
- [ ] No child-directed features (content not specifically designed for under-13)

---

## Compliance Summary

| Requirement | Last Stand Homestead | Status |
|-------------|----------------------|--------|
| Privacy Policy | ✓ Required, provided above | Ready |
| IARC Rating | ✓ PEGI 7 / ESRB E10+ | Submit questionnaire |
| Data Safety | ✓ No sensitive data collected | Declare in Play Console |
| Analytics SDK | ✗ Not present | ✓ Compliant |
| Ads SDK | ✗ Not present | ✓ Compliant |
| Account System | ✗ Not present | ✓ Compliant |
| Child Safety (COPPA) | ✓ Not targeted at under-13 | ✓ Compliant |
| Permissions | ✓ Only storage (for saves) | ✓ Justified |

---

## Pre-Submission Checklist

Before uploading to Google Play:

- [ ] Privacy Policy drafted and hosted (or use template above)
- [ ] IARC questionnaire completed at iarc.org
- [ ] IARC certificate received (usually within 24 hours)
- [ ] Google Play Console > Policies > Privacy Policy linked
- [ ] App Content questionnaire completed
- [ ] Data Safety section filled with correct answers
- [ ] No analytics, ads, or third-party tracking SDKs active
- [ ] `project.godot` reviewed for no unexpected permissions
- [ ] `THIRD_PARTY_NOTICES.md` accurate and complete

---

## References

- [Google Play Console Help — Privacy Policy](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Google Play Console Help — Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [IARC Ratings System](https://www.iarc.org/)
- [ESRB Ratings Explanation](https://www.esrb.org/)
- [PEGI Ratings Explanation](https://pegi.info/)

---

## Updates and Maintenance

After each game update:

1. Review if any new content changes IARC rating
2. If rating changes, resubmit IARC questionnaire
3. Update privacy policy if any data practices change
4. Confirm no new SDKs or permissions were inadvertently added

Currently, no changes expected because:
- Gameplay is offline-only
- No planned monetization
- No planned account/social features
- No planned analytics or telemetry
