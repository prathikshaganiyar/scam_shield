import 'package:flutter/material.dart';
import '../main.dart';
import '../models/fraud_report.dart';
import '../services/fraud_lookup_service.dart';
import '../widgets/lookup_result_card.dart';
import 'report_screen.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _controller = TextEditingController();
  IdentifierType _type = IdentifierType.upi;
  LookupResult? _result;
  bool _loading = false;
  String? _error;

  Future<void> _runLookup() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await FraudLookupService.lookup(input, _type);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'Couldn\'t reach the community database. Check your connection and try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Check UPI / Phone')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Community lookup isn\'t set up yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature needs a free Firebase project. Run `flutterfire configure` '
                'and see the README\'s "Firebase setup" section.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Check UPI / Phone')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check if a UPI ID or phone number has been reported by others before you pay or reply.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            SegmentedButton<IdentifierType>(
              segments: const [
                ButtonSegment(value: IdentifierType.upi, label: Text('UPI ID'), icon: Icon(Icons.account_balance_wallet)),
                ButtonSegment(value: IdentifierType.phone, label: Text('Phone'), icon: Icon(Icons.phone)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: _type == IdentifierType.phone ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _type == IdentifierType.upi ? 'e.g. name@okaxis' : 'e.g. 98765 43210',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _runLookup,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search),
                label: Text(_loading ? 'Checking...' : 'Check for Reports'),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_result != null) ...[
              Expanded(child: SingleChildScrollView(child: LookupResultCard(result: _result!))),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReportScreen(prefillIdentifier: _controller.text, type: _type)),
                  );
                },
                icon: const Icon(Icons.flag_outlined),
                label: const Text('This scammed me — report it'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
