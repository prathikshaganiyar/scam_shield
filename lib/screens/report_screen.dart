import 'package:flutter/material.dart';
import '../models/fraud_report.dart';
import '../services/fraud_lookup_service.dart';

class ReportScreen extends StatefulWidget {
  final String prefillIdentifier;
  final IdentifierType type;
  const ReportScreen({super.key, required this.prefillIdentifier, required this.type});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final TextEditingController _idController;
  final _noteController = TextEditingController();
  FraudCategory _category = FraudCategory.advanceFeeJob;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.prefillIdentifier);
  }

  Future<void> _submit() async {
    if (_idController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await FraudLookupService.submitReport(
        rawIdentifier: _idController.text,
        type: widget.type,
        category: _category,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks — this helps protect others.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t submit. Check your connection and try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Scam')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.type == IdentifierType.upi ? 'UPI ID' : 'Phone number',
              ),
            ),
            const SizedBox(height: 16),
            const Text('What kind of scam was it?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...FraudCategory.values.map((c) => RadioListTile<FraudCategory>(
                  value: c,
                  groupValue: _category,
                  title: Text(c.label),
                  onChanged: (v) => setState(() => _category = v!),
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Brief description (optional)',
                hintText: 'e.g. asked for ₹3,000 registration fee before internship start',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your report is anonymous — we don\'t attach your name, phone, or account to it.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Submitting...' : 'Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
