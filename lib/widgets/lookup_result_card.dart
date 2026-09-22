import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fraud_report.dart';
import '../services/fraud_lookup_service.dart';

class LookupResultCard extends StatelessWidget {
  final LookupResult result;
  const LookupResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (!result.hasReports) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('No reports found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This doesn\'t confirm it\'s safe — it just means nobody has reported it here yet. '
              'Still verify independently before paying anything.',
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reported ${result.reportCount} time${result.reportCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
          if (result.firstReported != null) ...[
            const SizedBox(height: 4),
            Text(
              'First reported ${DateFormat.yMMMd().format(result.firstReported!)}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Reported as:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.categoryBreakdown.entries.map((e) {
              return Chip(
                label: Text('${e.key.label} (${e.value})'),
                backgroundColor: Colors.red.shade50,
                side: BorderSide(color: Colors.red.shade200),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const Text('Recent reports:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...result.reports.take(5).map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.note?.isNotEmpty == true ? r.note! : r.category.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
