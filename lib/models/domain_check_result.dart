enum DomainRisk { critical, high, medium, low, unknown }

class DomainCheckResult {
  final String domain;
  final DateTime? createdDate;
  final String? registrar;
  final DomainRisk risk;
  final String? error; // set when the lookup itself failed (network/API issue)

  DomainCheckResult({
    required this.domain,
    required this.risk,
    this.createdDate,
    this.registrar,
    this.error,
  });

  int? get ageInDays => createdDate == null ? null : DateTime.now().difference(createdDate!).inDays;

  /// Classifies domain age into a risk bucket. Scam sites are very
  /// frequently registered days or weeks before use, then abandoned —
  /// this is exactly the fact a chatbot reasoning over a screenshot has
  /// no way to check, since it requires a live registry lookup.
  static DomainRisk classify(DateTime? createdDate) {
    if (createdDate == null) return DomainRisk.unknown;
    final ageInDays = DateTime.now().difference(createdDate).inDays;
    if (ageInDays < 30) return DomainRisk.critical;
    if (ageInDays < 90) return DomainRisk.high;
    if (ageInDays < 365) return DomainRisk.medium;
    return DomainRisk.low;
  }

  factory DomainCheckResult.error(String domain, String message) =>
      DomainCheckResult(domain: domain, risk: DomainRisk.unknown, error: message);
}
