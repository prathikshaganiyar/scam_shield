// PLACEHOLDER — get free API keys and put them here before those checks work.
//
// WHOIS (domain age):
//   1. Sign up free at https://whoisjson.com or https://whoisxmlapi.com
//   2. Paste the key below
//
// MCA company verification:
//   MCA data isn't a free government API — it's wrapped by paid KYB
//   vendors. https://ekycnow.com gives 5 free checks with no credit card,
//   enough to build and demo against. Past that it's a paid product —
//   be upfront about this cost if you ever pitch this as sellable.
//
// Reverse image search (logo forensics):
//   Uses Google Cloud Vision API's Web Detection feature.
//   1. Create a project at https://console.cloud.google.com
//   2. Enable the "Cloud Vision API"
//   3. Create an API key under APIs & Services → Credentials
//   4. Free tier: 1,000 units/month — enough for dev/demo
//
// For a real deployed app, don't commit real keys to source control —
// move these to environment variables or --dart-define at build time.
class ApiKeys {
  static const String whoisApiKey = 'YOUR_WHOIS_API_KEY_HERE';
  static const String mcaApiKey = 'YOUR_EKYCNOW_API_KEY_HERE';
  static const String visionApiKey = 'YOUR_GOOGLE_CLOUD_VISION_API_KEY_HERE';
}
