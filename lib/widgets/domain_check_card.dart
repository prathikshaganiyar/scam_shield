import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/domain_check_result.dart';

class DomainCheckCard extends StatelessWidget {
  final DomainCheckResult result;
  const DomainCheckCard({super.key, required this.result});

  Color get _color {
    switch (result.risk) {
      case DomainRisk.critical:
        return Colors.red;
      case DomainRisk.high:
        return Colors.deepOrange;
      case DomainRisk.medium:
        return Colors.orange;
      case DomainRisk.low:
        return Colors.green;
      case DomainRisk.unknown:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (result.risk) {
      case DomainRisk.critical:
      case DomainRisk.high:
        return Icons.dangerous;
      case DomainRisk.medium:
        return Icons.warning_amber;
      case DomainRisk.low:
        return Icons.verified;
      case DomainRisk.unknown:
        return Icons.help_outline;
    }
  }

  String get _summary {
    if (result.error != null) return result.error!;
    final age = result.ageInDays;
    if (age == null) return 'Registration date unavailable';
    if (age < 30) return 'Registered only $age day${age == 1 ? '' : 's'} ago — very new';
    if (age < 90) return 'Registered $age days ago — recent';
    if (age < 365) return 'Registered ${(age / 30).round()} months ago';
    return 'Registered ${(age / 365).floor()}+ years ago — established';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(_icon, color: _color),
        title: Text(result.domain, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          result.registrar != null ? '$_summary · ${result.registrar}' : _summary,
        ),
      ),
    );
  }
}
