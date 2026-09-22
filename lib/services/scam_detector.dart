import '../models/red_flag.dart';
import '../models/scan_result.dart';

/// Rule-based scam detector for job postings / recruiter messages.
///
/// This is deliberately rule-based (not ML) for v1: it's explainable,
/// needs no training data or model hosting to ship, and every flag can be
/// shown to the user with a plain-English reason. Once you're collecting
/// real scan history, the labelled data becomes the training set for a
/// v2 classifier — swap it in behind [ScamDetector.scan] without touching
/// any UI code.
class ScamDetector {
  static ScanResult scan(String rawText) {
  final text = rawText.trim();

  if (text.isEmpty) {
    return ScanResult(
      originalText: text,
      riskScore: 0,
      verdict: ScanResult.verdictFromScore(0),
      flags: const [],
      scannedAt: DateTime.now(),
    );
  }

  final lower = text.toLowerCase();
  final flags = <RedFlag>[];

    _checkUpfrontPayment(lower, flags);
    _checkUrgencyPressure(lower, flags);
    _checkOffPlatformOnly(lower, flags);
    _checkUnrealisticPay(lower, flags);
    _checkVagueRole(lower, flags);
    _checkSuspiciousContact(lower, text, flags);
    _checkTooEasySelection(lower, flags);
    _checkPersonalInfoRequest(lower, flags);

    final score = flags.fold<int>(0, (sum, f) => sum + f.weight).clamp(0, 100);

    return ScanResult(
      originalText: text,
      riskScore: score,
      verdict: ScanResult.verdictFromScore(score),
      flags: flags,
      scannedAt: DateTime.now(),
    );
  }

  static void _checkUpfrontPayment(String lower, List<RedFlag> flags) {
    final patterns = [
      'registration fee', 'security deposit', 'training fee', 'processing fee',
      'refundable deposit', 'pay to start', 'pay ₹', 'pay rs', 'pay inr',
      'deposit to unlock', 'unlock your earnings', 'activation fee',
      'kit fee', 'id card fee',
    ];
    for (final p in patterns) {
      if (lower.contains(p)) {
        flags.add(RedFlag(
          title: 'Requests upfront payment',
          explanation:
              'Legitimate employers never charge candidates a fee to be hired, trained, or "unlock" earnings. This is the single strongest scam signal.',
          severity: FlagSeverity.critical,
          matchedText: p,
        ));
        return; // one match is enough, avoid double counting near-duplicates
      }
    }
  }

  static void _checkUrgencyPressure(String lower, List<RedFlag> flags) {
    final patterns = [
      'reply within', 'limited slots', 'act now', 'immediate joining only',
      'offer expires today', 'hurry', 'only few seats', 'respond in',
      'urgent hiring', 'today only',
    ];
    if (patterns.any((p) => lower.contains(p))) {
      flags.add(const RedFlag(
        title: 'Artificial urgency',
        explanation:
            'Pressuring you to decide immediately is a classic scam tactic — it\'s designed to stop you from checking or asking questions.',
        severity: FlagSeverity.medium,
        matchedText: 'urgency language',
      ));
    }
  }

  static void _checkOffPlatformOnly(String lower, List<RedFlag> flags) {
    final platforms = ['whatsapp', 'telegram', 'signal only'];
    final hasOffPlatform = platforms.any((p) => lower.contains(p));
    final hasOfficialChannel = lower.contains('@') && !lower.contains('gmail.com') && !lower.contains('yahoo.com');
    if (hasOffPlatform && !hasOfficialChannel) {
      flags.add(const RedFlag(
        title: 'Off-platform, no official email',
        explanation:
            'Recruitment conducted entirely over WhatsApp/Telegram with no verifiable company email is a common scam pattern — real HR teams use company email.',
        severity: FlagSeverity.high,
        matchedText: 'off-platform contact',
      ));
    }
  }

  static void _checkUnrealisticPay(String lower, List<RedFlag> flags) {
    final patterns = [
      'no experience needed', 'earn from home', 'easy money', 'work 2 hours',
      'guaranteed income', 'daily payout', 'no qualification required',
    ];
    if (patterns.any((p) => lower.contains(p))) {
      flags.add(const RedFlag(
        title: 'Unrealistic pay-to-effort ratio',
        explanation:
            'High pay for minimal effort/skill/experience is a hallmark of data-entry and task-based scam listings.',
        severity: FlagSeverity.medium,
        matchedText: 'unrealistic pay claim',
      ));
    }
  }

  static void _checkVagueRole(String lower, List<RedFlag> flags) {
    final hasRoleDetail = RegExp(r'(responsibilit|requirement|qualification|experience in|skills? (required|needed))')
        .hasMatch(lower);
    final isShort = lower.split(RegExp(r'\s+')).length < 40;
    if (!hasRoleDetail && isShort) {
      flags.add(const RedFlag(
        title: 'Vague job description',
        explanation:
            'Real job postings describe responsibilities and requirements. A short message with no role detail is a weak signal on its own, worth combining with the others above.',
        severity: FlagSeverity.low,
        matchedText: 'missing role detail',
      ));
    }
  }

  static void _checkSuspiciousContact(String lower, String original, List<RedFlag> flags) {
    // crude check for lookalike/free-mail domains posing as a company recruiter
    final emailMatch = RegExp(r'[\w.\-]+@([\w\-]+\.[\w.\-]+)').firstMatch(lower);
    if (emailMatch != null) {
      final domain = emailMatch.group(1) ?? '';
      final freeMailDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'rediffmail.com', 'hotmail.com'];
      final claimsBigCompany = ['amazon', 'google', 'microsoft', 'tcs', 'infosys', 'wipro', 'accenture']
          .any((c) => lower.contains(c));
      if (claimsBigCompany && freeMailDomains.any((d) => domain.contains(d))) {
        flags.add(RedFlag(
          title: 'Company mismatch with email domain',
          explanation:
              'Message claims to be from a large company but the contact email is a free personal mail domain ($domain), not the company\'s own domain. Real corporate recruiters use @company.com.',
          severity: FlagSeverity.critical,
          matchedText: domain,
        ));
      }
    }
  }

  static void _checkTooEasySelection(String lower, List<RedFlag> flags) {
    final patterns = ['shortlisted', 'selected without interview', 'no interview required', 'congratulations you have been selected'];
    if (patterns.any((p) => lower.contains(p)) && !lower.contains('interview will be')) {
      flags.add(const RedFlag(
        title: 'Selection without a real process',
        explanation:
            'Being "selected" or "shortlisted" with no interview, test, or actual evaluation is a strong scam pattern — scammers skip vetting because they aren\'t actually hiring.',
        severity: FlagSeverity.high,
        matchedText: 'no interview process',
      ));
    }
  }

  static void _checkPersonalInfoRequest(String lower, List<RedFlag> flags) {
    final patterns = ['aadhaar number', 'bank account details', 'otp', 'pan card number', 'debit card', 'credit card number'];
    if (patterns.any((p) => lower.contains(p))) {
      flags.add(const RedFlag(
        title: 'Requests sensitive personal/financial info early',
        explanation:
            'No legitimate employer needs your bank details, OTP, or ID numbers before a formal offer and verified onboarding process.',
        severity: FlagSeverity.high,
        matchedText: 'sensitive info request',
      ));
    }
  }
}
