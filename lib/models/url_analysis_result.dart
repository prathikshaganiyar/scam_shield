class UrlAnalysisResult {
  final String url;
  final String domain;
  final int riskScore;
  final String riskLevel;
  final List<String> reasons;

  const UrlAnalysisResult({
    required this.url,
    required this.domain,
    required this.riskScore,
    required this.riskLevel,
    required this.reasons,
  });

  factory UrlAnalysisResult.fromJson(Map<String, dynamic> json) {
    return UrlAnalysisResult(
      url: json['url'] as String,
      domain: json['domain'] as String,
      riskScore: (json['risk_score'] as num).toInt(),
      riskLevel: json['risk_level'] as String,
      reasons: json['reasons'] != null
          ? List<String>.from(json['reasons'])
          : const [],
    );
  }
}