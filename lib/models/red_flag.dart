/// Severity buckets used to weight the overall risk score.
enum FlagSeverity { low, medium, high, critical }

/// A single fraud indicator detected in a message/posting.
class RedFlag {
  final String title;
  final String explanation;
  final FlagSeverity severity;
  final String matchedText;

  const RedFlag({
    required this.title,
    required this.explanation,
    required this.severity,
    required this.matchedText,
  });

  /// Points contributed to the overall risk score (0-100 scale).
  int get weight {
    switch (severity) {
      case FlagSeverity.critical:
        return 35;
      case FlagSeverity.high:
        return 22;
      case FlagSeverity.medium:
        return 12;
      case FlagSeverity.low:
        return 6;
    }
  }
}
