import 'red_flag.dart';

enum Verdict { safe, caution, risky }

class ScanResult {
  final String originalText;
  final int riskScore;
  final Verdict verdict;
  final List<RedFlag> flags;
  final DateTime scannedAt;

  // Backend ML information
  final String riskLevel;
  final List<String> reasons;
  final double scamProbability;

  // Unified ScamShield risk signals
  final int finalRiskScore;
  final int mlScore;
  final int ruleScore;
  final int urlScore;

  ScanResult({
    required this.originalText,
    required this.riskScore,
    required this.verdict,
    required this.flags,
    required this.scannedAt,
    this.riskLevel = 'unknown',
    this.reasons = const [],
    this.scamProbability = 0.0,
    this.finalRiskScore = 0,
    this.mlScore = 0,
    this.ruleScore = 0,
    this.urlScore = 0,
  });

  static Verdict verdictFromScore(int score) {
    if (score >= 55) return Verdict.risky;
    if (score >= 25) return Verdict.caution;
    return Verdict.safe;
  }

  Map<String, dynamic> toJson() => {
        'originalText': originalText,
        'riskScore': riskScore,
        'verdict': verdict.name,
        'flagTitles': flags.map((f) => f.title).toList(),
        'scannedAt': scannedAt.toIso8601String(),
        'riskLevel': riskLevel,
        'reasons': reasons,
        'scamProbability': scamProbability,
        'finalRiskScore': finalRiskScore,
        'mlScore': mlScore,
        'ruleScore': ruleScore,
        'urlScore': urlScore,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        originalText: json['originalText'] as String,
        riskScore: json['riskScore'] as int,
        verdict: Verdict.values.byName(json['verdict'] as String),
        flags: const [],
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        riskLevel: json['riskLevel'] as String? ?? 'unknown',
        reasons: json['reasons'] != null
            ? List<String>.from(json['reasons'])
            : const [],
        scamProbability:
            (json['scamProbability'] as num?)?.toDouble() ?? 0.0,
        finalRiskScore:
            (json['finalRiskScore'] as num?)?.toInt() ?? 0,
        mlScore:
            (json['mlScore'] as num?)?.toInt() ?? 0,
        ruleScore:
            (json['ruleScore'] as num?)?.toInt() ?? 0,
        urlScore:
            (json['urlScore'] as num?)?.toInt() ?? 0,
      );
}