# Scam Shield

A Flutter app that scans job postings, recruiter messages, and offer letters for
scam patterns before you respond — paste text now, share-to-app from
WhatsApp/Telegram coming in v1.1.

## Why this exists
Job scam checkers already exist as websites (VerifyJobs, JobScamScore, ScamDekho,
and others). None of them are built as a native app around the moment a scam
message actually arrives — inside WhatsApp or Telegram. This app is built
specifically for that moment: share-intent first, paste-box second.

## Getting started

```bash
flutter pub get
```

### Firebase setup (required before `flutter run`)
The UPI/phone lookup feature needs a real shared database — that's the whole
point, it only works if reports accumulate across users. You need your own
free Firebase project:

1. Create a project at https://console.firebase.google.com (free tier is enough)
2. Firestore Database → Create database → start in test mode for now
3. Authentication → Sign-in method → enable **Anonymous**
4. `dart pub global activate flutterfire_cli`
5. `flutterfire configure` — this regenerates `lib/firebase_options.dart`
   with your real project's keys (the checked-in version is a placeholder
   that intentionally throws until you do this)
6. Deploy the security rules in `firestore.rules`:
   `firebase deploy --only firestore:rules` (needs `firebase-tools` CLI + `firebase init`)

### Domain verification setup (required for WHOIS checks)
1. Get a free API key at https://whoisjson.com (free tier covers dev/demo use)
2. Paste it into `lib/config/api_keys.dart`
3. Without this, the app still runs — domain checks just show
   "WHOIS API key not configured" instead of failing silently

Then:
```bash
flutter run
flutter test
```

## Architecture

```
lib/
  models/
    red_flag.dart        # a single detected fraud indicator + severity weight
    scan_result.dart      # bundles score, verdict, flags for one text scan
    fraud_report.dart     # a single community-submitted UPI/phone report
  services/
    scam_detector.dart    # rule-based text scoring engine
    history_store.dart    # local on-device scan history (no server)
    fraud_lookup_service.dart  # Firestore read/write for community reports
    url_extractor.dart    # pulls candidate domains out of message text
    domain_check_service.dart  # WHOIS lookup + risk classification
  screens/
    home_screen.dart      # paste box + recent scan history (text scanner)
    result_screen.dart    # verdict, score, explained red flags, domain checks
    lookup_screen.dart    # UPI/phone lookup against community reports
    report_screen.dart    # submit a new fraud report
  widgets/
    lookup_result_card.dart  # visual report-count + category breakdown card
    domain_check_card.dart   # visual domain age / registrar risk card
```

### How the three verification layers fit together
1. **Text scan** (instant, no network) — rule-based pattern matching on the
   message itself: upfront fees, urgency language, vague descriptions.
2. **Domain verification** (async, WHOIS API) — any links in the message
   get checked for registration age. A domain registered 6 days ago is a
   concrete, checkable fact — not a guess from reading the text.
3. **UPI/phone lookup** (separate tab, Firestore) — cross-reference a
   payment identifier against everyone else who's reported it.

Each layer answers a different question a chatbot can't: what does the
text pattern suggest, is this domain actually new, and has this exact
payment ID been reported before. Together they're evidence, not opinion.

### Why the UPI/phone lookup is the core differentiator
A chatbot reasoning over a screenshot can only offer an opinion from its
training knowledge — it has no memory across users and can't tell you
"14 other people reported this exact UPI ID this month." This feature can,
because it reads and writes a real shared database (Firestore) that
accumulates across every install of the app. That accumulation is the
actual product, not the UI around it.

**Known limitations, worth being upfront about in an interview:**
- Anonymous auth stops *trivial* spam but not a determined bad actor
  scripting many anonymous sign-ins — a v2 needs either lightweight
  rate-limiting (Cloud Function checking report velocity per uid) or a
  CAPTCHA/App Check on submission.
- No moderation yet — a malicious user could report a real UPI ID to
  harass someone. Report review/dispute flow is a real v1.1 need before
  this goes to real users at scale.
- Reports are self-declared, not verified against an actual complaint
  (like cybercrime.gov.in) — treat the count as a community signal, not
  proof, and say so clearly in the UI (the "no reports found" card
  already does this for the negative case; the positive case should too).

The detector is deliberately **rule-based, not ML, for v1**. Reasons:
- Explainable: every flag comes with a plain-English reason, which matters for
  user trust in a fraud tool.
- No training data or model hosting needed to ship something real this week.
- As real scan history accumulates (with user consent), it becomes labelled
  training data for a v2 classifier — the interface (`ScamDetector.scan`)
  stays the same, so swapping in a model later doesn't touch any UI code.

## Current detection rules (v1)
- Upfront payment / fee requests (critical)
- Company name claimed but contact email uses a free-mail domain (critical)
- "Selected" / "shortlisted" with no real interview process (high)
- Off-platform-only contact (WhatsApp/Telegram) with no verifiable email (high)
- Artificial urgency language (medium)
- Unrealistic pay-to-effort ratio (medium)
- Vague job description with no role detail (low)
- Requests for sensitive personal/financial info early (high)

## Roadmap
- [x] v1.1: UPI/phone lookup against community-reported fraud (Firestore)
- [x] v1.2: Domain age (WHOIS) verification for links in scanned text
- [ ] v1.3: WhatsApp/Telegram share-intent (package already in pubspec:
      `receive_sharing_intent`) — wire up `ReceiveSharingIntent` in `main.dart`
- [ ] v1.4: Reverse-image search on logos in uploaded offer letters
- [ ] v1.5: Community reporting for domains too, not just UPI/phone
- [ ] v2: Replace rule-based text scoring with a trained classifier once
      you have a real labelled dataset from user scans (with consent)
- [ ] v2: OCR support for screenshot uploads, not just pasted text

## Privacy note
All scans and history are stored locally on-device via `shared_preferences`.
Nothing is sent to a server in v1. Keep this true as long as possible — it's
a real trust advantage for a fraud-detection tool, and worth stating clearly
in your app store listing.
