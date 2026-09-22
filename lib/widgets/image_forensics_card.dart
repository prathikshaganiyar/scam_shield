import 'package:flutter/material.dart';
import '../models/image_forensics_result.dart';

class ImageForensicsCard extends StatelessWidget {
  final ImageForensicsResult result;
  const ImageForensicsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.error != null) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.grey),
          title: const Text('Image check unavailable', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(result.error!),
        ),
      );
    }

    final suspicious = result.risk == ImageForensicsRisk.suspicious;
    final color = suspicious ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(suspicious ? Icons.warning_amber : Icons.image_search, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suspicious
                        ? 'This image appears on ${result.matchCount} other pages'
                        : result.matchCount == 0
                            ? 'No other matches found for this image'
                            : 'Image found on ${result.matchCount} page(s) — normal range',
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ],
            ),
            if (suspicious && result.matchingDomains.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'A logo/letterhead showing up on many unrelated sites suggests it was copied from a generic source, not the real company\'s own material.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.matchingDomains
                    .take(6)
                    .map((d) => Chip(label: Text(d, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
