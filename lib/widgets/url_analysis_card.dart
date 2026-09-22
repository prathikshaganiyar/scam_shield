import 'package:flutter/material.dart';

import '../models/url_analysis_result.dart';

class UrlAnalysisCard extends StatelessWidget {
  final UrlAnalysisResult result;

  const UrlAnalysisCard({
    super.key,
    required this.result,
  });

  Color _riskColor() {
    switch (result.riskLevel.toLowerCase()) {
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

  IconData _riskIcon() {
    switch (result.riskLevel.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final color = _riskColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'URL Security Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  _riskIcon(),
                  color: color,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              result.url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Domain: ${result.domain}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${result.riskScore}/100',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  '${result.riskLevel.toUpperCase()} RISK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: result.riskScore / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: color,
            ),

            if (result.reasons.isNotEmpty) ...[
              const SizedBox(height: 16),

              Text(
                'Security indicators',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 6),

              ...result.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(reason),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}