import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../services/scam_detector.dart';
import '../services/api_service.dart';
import '../services/history_store.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  List<ScanResult> _history = [];

  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> _loadHistory() async {
    final history = await HistoryStore.getAll();

    if (!mounted) return;

    setState(() {
      _history = history;
    });
  }

  // ============================================================
  // RUN SCAN
  // ============================================================

  Future<void> _runScan() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please paste a message before scanning.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final apiResult = await ApiService.predict(text);

      if (!mounted) return;

      final scamProbability =
          (apiResult['scam_probability'] as num).toDouble();

      final riskScore =
          (scamProbability * 100).round();

      final result =
          ScamDetector.scan(text);

      final backendReasons =
          apiResult['reasons'] != null
              ? List<String>.from(
                  apiResult['reasons'],
                )
              : <String>[];

      final backendRiskLevel =
          apiResult['risk_level'] as String? ??
              'unknown';

      final finalRiskScore =
          (apiResult['final_risk_score'] as num?)
                  ?.toInt() ??
              riskScore;

      final signals =
          apiResult['signals']
                  as Map<String, dynamic>? ??
              {};

      final mlScore =
          (signals['ml_score'] as num?)
                  ?.toInt() ??
              riskScore;

      final ruleScore =
          (signals['rule_score'] as num?)
                  ?.toInt() ??
              0;

      final urlScore =
          (signals['url_score'] as num?)
                  ?.toInt() ??
              0;

      final updatedResult = ScanResult(
        originalText:
            result.originalText,

        riskScore:
            finalRiskScore,

        verdict:
            finalRiskScore >= 70
                ? Verdict.risky
                : finalRiskScore >= 40
                    ? Verdict.caution
                    : Verdict.safe,

        flags:
            result.flags,

        scannedAt:
            DateTime.now(),

        riskLevel:
            backendRiskLevel,

        reasons:
            backendReasons,

        scamProbability:
            scamProbability,

        finalRiskScore:
            finalRiskScore,

        mlScore:
            mlScore,

        ruleScore:
            ruleScore,

        urlScore:
            urlScore,
      );

      await HistoryStore.save(
        updatedResult,
      );

      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: updatedResult,
          ),
        ),
      );

      _controller.clear();

      await _loadHistory();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to ScamShield server: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  Future<void> _clearHistory() async {
    if (_history.isEmpty) return;

    final shouldClear =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear scan history?',
          ),
          content: const Text(
            'This will remove all saved scans from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await HistoryStore.clear();

    if (!mounted) return;

    setState(() {
      _history = [];
    });
  }

  // ============================================================
  // RISK COLOR
  // ============================================================

  Color _riskColor(Verdict verdict) {
    switch (verdict) {
      case Verdict.risky:
        return Colors.red;

      case Verdict.caution:
        return Colors.orange;

      case Verdict.safe:
        return Colors.green;
    }
  }

  // ============================================================
  // RISK LABEL
  // ============================================================

  String _riskLabel(Verdict verdict) {
    switch (verdict) {
      case Verdict.risky:
        return 'HIGH RISK';

      case Verdict.caution:
        return 'MEDIUM RISK';

      case Verdict.safe:
        return 'LOW RISK';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final totalScans =
        _history.length;

    final highRisk =
        _history.where(
      (scan) =>
          scan.verdict ==
          Verdict.risky,
    ).length;

    final mediumRisk =
        _history.where(
      (scan) =>
          scan.verdict ==
          Verdict.caution,
    ).length;

    final lowRisk =
        _history.where(
      (scan) =>
          scan.verdict ==
          Verdict.safe,
    ).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scam Shield',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadHistory,

        child: ListView(
          padding:
              const EdgeInsets.all(16),

          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Text(
              'Stay one step ahead of scams.',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              'Analyze suspicious messages, job offers, '
              'links and payment requests.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SCAN INPUT
            // ==================================================

            Text(
              'Analyze a message',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _controller,
              maxLines: 8,

              decoration:
                  InputDecoration(
                border:
                    const OutlineInputBorder(),

                hintText:
                    'Paste the recruiter message, job posting, suspicious offer, or message here...',

                filled: true,

                fillColor:
                    Theme.of(context)
                        .colorScheme
                        .surface,

                alignLabelWithHint:
                    true,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width:
                  double.infinity,

              height: 52,

              child: FilledButton.icon(
                onPressed:
                    _isScanning
                        ? null
                        : _runScan,

                icon:
                    _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.shield_outlined,
                          ),

                label:
                    Text(
                  _isScanning
                      ? 'Analyzing...'
                      : 'Check for Scam Signs',
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // DASHBOARD HEADER
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan Dashboard',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),

                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed:
                        _clearHistory,

                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),

                    label:
                        const Text(
                      'Clear',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // STAT CARDS
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    context,
                    icon:
                        Icons.analytics_outlined,
                    title:
                        'Total',
                    value:
                        totalScans,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    context,
                    icon:
                        Icons.dangerous_outlined,
                    title:
                        'High',
                    value:
                        highRisk,
                    color:
                        Colors.red,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    context,
                    icon:
                        Icons.warning_amber_rounded,
                    title:
                        'Medium',
                    value:
                        mediumRisk,
                    color:
                        Colors.orange,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    context,
                    icon:
                        Icons.verified_outlined,
                    title:
                        'Low',
                    value:
                        lowRisk,
                    color:
                        Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // RECENT SCANS
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent scans',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),

                if (_history.length > 5)
                  Text(
                    '${_history.length} total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (_history.isEmpty)
              _emptyHistoryCard(
                context,
              )
            else
              ..._history
                  .take(10)
                  .map(
                    (scan) =>
                        _historyCard(
                      context,
                      scan,
                    ),
                  ),

            const SizedBox(height: 30),

            // ==================================================
            // PRIVACY NOTE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(14),

              decoration:
                  BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your scan history is stored locally '
                      'on this device. ScamShield does not '
                      'store your history on the server.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int value,
    Color? color,
  }) {
    final cardColor =
        color ??
        Theme.of(context)
            .colorScheme
            .primary;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),

      decoration:
          BoxDecoration(
        color: cardColor.withValues(
          alpha: 0.10,
        ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              cardColor.withValues(
            alpha: 0.25,
          ),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: cardColor,
            size: 22,
          ),

          const SizedBox(height: 6),

          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: cardColor,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _historyCard(
    BuildContext context,
    ScanResult scan,
  ) {
    final color =
        _riskColor(scan.verdict);

    final label =
        _riskLabel(scan.verdict);

    final preview =
        scan.originalText.trim();

    final shortened =
        preview.length > 75
            ? '${preview.substring(0, 75)}...'
            : preview;

    final date =
        scan.scannedAt;

    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final timeText =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ResultScreen(
                result: scan,
              ),
            ),
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(14),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // RISK INDICATOR
              Container(
                width: 46,
                height: 46,

                decoration:
                    BoxDecoration(
                  color:
                      color.withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Center(
                  child: Text(
                    '${scan.finalRiskScore}',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // MESSAGE INFO
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      shortened,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                color.withValues(
                              alpha: 0.10,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),

                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '$dateText • $timeText',
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.chevron_right,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget _emptyHistoryCard(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(28),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),

        border:
            Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 42,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),

          const SizedBox(height: 12),

          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your analyzed messages will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}