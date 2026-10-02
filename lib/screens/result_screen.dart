import 'package:flutter/material.dart';

import '../models/red_flag.dart';
import '../models/scan_result.dart';
import '../models/domain_check_result.dart';
import '../models/url_analysis_result.dart';
import '../services/api_service.dart';
import '../services/url_extractor.dart';
import '../services/domain_check_service.dart';
import '../widgets/domain_check_card.dart';
import '../widgets/url_analysis_card.dart';

class ResultScreen extends StatefulWidget {
  final ScanResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<DomainCheckResult> _domainResults = [];
  List<UrlAnalysisResult> _urlAnalysisResults = [];

  bool _checkingDomains = false;
  bool _analyzingUrls = false;

  @override
  void initState() {
    super.initState();

    _runDomainChecks();
    _runUrlAnalysis();
  }

  // ------------------------------------------------------------
  // DOMAIN VERIFICATION
  // ------------------------------------------------------------

  Future<void> _runDomainChecks() async {
    final domains =
        UrlExtractor.extractDomains(widget.result.originalText);

    if (domains.isEmpty) {
      return;
    }

    setState(() {
      _checkingDomains = true;
    });

    try {
      final results = await DomainCheckService.checkAll(domains);

      if (!mounted) return;

      setState(() {
        _domainResults = results;
        _checkingDomains = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _checkingDomains = false;
      });
    }
  }

  // ------------------------------------------------------------
  // URL SECURITY ANALYSIS
  // ------------------------------------------------------------

  Future<void> _runUrlAnalysis() async {
    final urls =
        UrlExtractor.extractUrls(widget.result.originalText);

    if (urls.isEmpty) {
      return;
    }

    setState(() {
      _analyzingUrls = true;
    });

    final results = <UrlAnalysisResult>[];

    for (final url in urls) {
      try {
        final result = await ApiService.analyzeUrl(url);
        results.add(result);
      } catch (_) {
        // Ignore individual URL failures.
      }
    }

    if (!mounted) return;

    setState(() {
      _urlAnalysisResults = results;
      _analyzingUrls = false;
    });
  }

  // ------------------------------------------------------------
  // RISK HELPERS
  // ------------------------------------------------------------

  Color _riskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _riskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Icons.dangerous_outlined;
      case 'medium':
        return Icons.warning_amber_rounded;
      case 'low':
        return Icons.verified_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _riskLabel(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'HIGH RISK';
      case 'medium':
        return 'MEDIUM RISK';
      case 'low':
        return 'LOW RISK';
      default:
        return 'RISK UNKNOWN';
    }
  }

  // ------------------------------------------------------------
  // SIGNAL CARD
  // ------------------------------------------------------------

  Widget _signalCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
Widget _explanationRow({
  required IconData icon,
  required String title,
  required String description,
  required int score,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context)
              .colorScheme
              .surface,
        ),
        child: Icon(
          icon,
          size: 22,
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: riskColorForScore(score),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Color riskColorForScore(int score) {
  if (score >= 15) {
    return Colors.red;
  }

  if (score >= 8) {
    return Colors.orange;
  }

  return Colors.green;
}
  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    final riskColor = _riskColor(result.riskLevel);
    final riskLabel = _riskLabel(result.riskLevel);

    final scamPercentage =
        (result.scamProbability * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScamShield Report'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====================================================
            // RISK SUMMARY
            // ====================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: riskColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _riskIcon(result.riskLevel),
                        color: riskColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ScamShield Risk',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    '${result.finalRiskScore} / 100',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: (result.finalRiskScore / 100)
                        .clamp(0.0, 1.0),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: riskColor,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Risk signal breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _signalCard(
                          context,
                          icon: Icons.psychology_outlined,
                          label: 'ML',
                          value: result.mlScore,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _signalCard(
                          context,
                          icon: Icons.warning_amber_rounded,
                          label: 'Rules',
                          value: result.ruleScore,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _signalCard(
                          context,
                          icon: Icons.link,
                          label: 'URL',
                          value: result.urlScore,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'ML scam probability: $scamPercentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Prediction: '
                    '${result.scamProbability >= 0.5 ? 'SCAM' : 'LEGITIMATE'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
// ====================================================
// HOW SCAMSHIELD DECIDED
// ====================================================

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Theme.of(context)
        .colorScheme
        .surfaceContainerHighest,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: riskColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'How ScamShield decided',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      _explanationRow(
        icon: Icons.psychology_outlined,
        title: 'Machine Learning',
        description:
            'The ML model analyzed the message for patterns associated with scam messages.',
        score: result.mlScore,
      ),

      const SizedBox(height: 14),

      _explanationRow(
        icon: Icons.rule_outlined,
        title: 'Security Rules',
        description:
            'Rule-based checks looked for suspicious language, payment requests, urgency, and sensitive information requests.',
        score: result.ruleScore,
      ),

      const SizedBox(height: 14),

      _explanationRow(
        icon: Icons.link_outlined,
        title: 'URL Analysis',
        description:
            'URLs were checked for phishing indicators such as suspicious keywords, unusual domains, and deceptive patterns.',
        score: result.urlScore,
      ),

      const Divider(height: 28),

      Row(
        children: [
          const Icon(
            Icons.calculate_outlined,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'These independent signals are combined into the final risk score.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 24),
            // ====================================================
            // WHY THIS WAS FLAGGED
            // ====================================================

            if (result.reasons.isNotEmpty) ...[
              Text(
                'Why this was flagged',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              ...result.reasons.map(
                (reason) => Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: riskColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(reason),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            // ====================================================
            // RULE-BASED RED FLAGS
            // ====================================================

            if (result.flags.isNotEmpty) ...[
              Text(
                'Detected red flags',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              ...result.flags.map(
                (flag) => _redFlagCard(flag),
              ),

              const SizedBox(height: 24),
            ],

            // ====================================================
            // URL SECURITY ANALYSIS
            // ====================================================

            if (_analyzingUrls) ...[
              const Text(
                'Analyzing URLs...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: CircularProgressIndicator(),
              ),

              const SizedBox(height: 24),
            ],

            if (_urlAnalysisResults.isNotEmpty) ...[
              Text(
                'URL Security Analysis',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              ..._urlAnalysisResults.map(
                (result) => UrlAnalysisCard(
                  result: result,
                ),
              ),

              const SizedBox(height: 24),
            ],

            // ====================================================
            // DOMAIN VERIFICATION
            // ====================================================

            if (_checkingDomains) ...[
              Text(
                'Checking domains...',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: CircularProgressIndicator(),
              ),

              const SizedBox(height: 24),
            ],

            if (_domainResults.isNotEmpty) ...[
              Text(
                'Domain Verification',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              ..._domainResults.map(
                (result) => DomainCheckCard(
                  result: result,
                ),
              ),

              const SizedBox(height: 24),
            ],

            // ====================================================
            // ORIGINAL MESSAGE
            // ====================================================

            Text(
              'Scanned Message',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                result.originalText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ====================================================
            // SAFETY CHECKLIST
            // ====================================================

            Text(
              'Safety Checklist',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            _safetyItem(
              icon: Icons.payments_outlined,
              text: 'Never pay upfront fees for a job or prize.',
            ),

            _safetyItem(
              icon: Icons.lock_outline,
              text: 'Never share OTPs, passwords, CVV or PINs.',
            ),

            _safetyItem(
              icon: Icons.link_off,
              text: 'Verify suspicious links before opening them.',
            ),

            _safetyItem(
              icon: Icons.verified_user_outlined,
              text: 'Verify the company using its official website.',
            ),

            const SizedBox(height: 20),

            // ====================================================
            // DISCLAIMER
            // ====================================================

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ScamShield provides an automated risk assessment '
                      'based on machine learning and security heuristics. '
                      'It should not be treated as absolute proof that a '
                      'message or URL is fraudulent.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // RED FLAG CARD
  // ------------------------------------------------------------

  Widget _redFlagCard(RedFlag flag) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.flag_outlined,
              color: Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    flag.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
Text(
  flag.explanation,
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    height: 1.4,
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SAFETY CHECKLIST ITEM
  // ------------------------------------------------------------

  Widget _safetyItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}