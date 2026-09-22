import 'package:flutter/material.dart';
import '../models/company_check_result.dart';

class CompanyCheckCard extends StatelessWidget {
  final CompanyCheckResult result;
  const CompanyCheckCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String title;
    String subtitle;

    switch (result.status) {
      case CompanyStatus.registered:
        color = Colors.green;
        icon = Icons.verified;
        title = 'Registered with MCA';
        subtitle = result.matchedLegalName != null
            ? '${result.matchedLegalName}${result.cin != null ? " · CIN: ${result.cin}" : ""}'
            : 'Match found in MCA records';
        break;
      case CompanyStatus.notFound:
        color = Colors.red;
        icon = Icons.dangerous;
        title = 'No MCA record found';
        subtitle = '"${result.queriedName}" doesn\'t match any registered company — treat this as a strong warning sign.';
        break;
      case CompanyStatus.unknown:
        color = Colors.grey;
        icon = Icons.help_outline;
        title = 'Couldn\'t verify';
        subtitle = result.error ?? 'Lookup unavailable.';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
