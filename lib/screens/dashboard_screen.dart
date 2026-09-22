import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../services/history_store.dart';
import 'result_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  List<ScanResult> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history =
        await HistoryStore.getAll();

    if (!mounted) return;

    setState(() {
      _history = history;
      _loading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final total = _history.length;

    final high = _history
        .where(
          (scan) =>
              scan.verdict == Verdict.risky,
        )
        .length;

    final medium = _history
        .where(
          (scan) =>
              scan.verdict == Verdict.caution,
        )
        .length;

    final low = _history
        .where(
          (scan) =>
              scan.verdict == Verdict.safe,
        )
        .length;

    final averageScore = total == 0
        ? 0
        : (_history
                    .map(
                      (scan) =>
                          scan.finalRiskScore,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                total)
            .round();

    final highestRisk = total == 0
        ? 0
        : _history
            .map(
              (scan) =>
                  scan.finalRiskScore,
            )
            .reduce(
              (a, b) => a > b ? a : b,
            );

    final averageMl = total == 0
        ? 0
        : (_history
                    .map(
                      (scan) =>
                          scan.mlScore,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                total)
            .round();

    final averageRules = total == 0
        ? 0
        : (_history
                    .map(
                      (scan) =>
                          scan.ruleScore,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                total)
            .round();

    final averageUrl = total == 0
        ? 0
        : (_history
                    .map(
                      (scan) =>
                          scan.urlScore,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                total)
            .round();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security Dashboard',
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView(
                padding:
                    const EdgeInsets.all(16),
                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 38,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'ScamShield Security Center',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Monitor your scam detection '
                          'activity and review previous '
                          'security assessments.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // OVERVIEW
                  // ==================================================

                  Text(
                    'Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          context,
                          icon:
                              Icons.analytics_outlined,
                          label:
                              'Total Scans',
                          value:
                              '$total',
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _metricCard(
                          context,
                          icon:
                              Icons.speed_outlined,
                          label:
                              'Avg. Risk',
                          value:
                              '$averageScore',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          context,
                          icon:
                              Icons.dangerous_outlined,
                          label:
                              'High Risk',
                          value:
                              '$high',
                          color:
                              Colors.red,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _metricCard(
                          context,
                          icon:
                              Icons.warning_amber_rounded,
                          label:
                              'Medium',
                          value:
                              '$medium',
                          color:
                              Colors.orange,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _metricCard(
                          context,
                          icon:
                              Icons.verified_outlined,
                          label:
                              'Low',
                          value:
                              '$low',
                          color:
                              Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // SECURITY INSIGHTS
                  // ==================================================

                  Text(
                    'Security Insights',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _insightCard(
                          context,
                          icon:
                              Icons.local_fire_department_outlined,
                          title:
                              'Highest Risk',
                          value:
                              '$highestRisk',
                          subtitle:
                              'maximum score',
                          color:
                              Colors.red,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _insightCard(
                          context,
                          icon:
                              Icons.speed_outlined,
                          title:
                              'Average',
                          value:
                              '$averageScore',
                          subtitle:
                              'overall risk',
                          color:
                              Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    padding:
                        const EdgeInsets.all(18),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Average signal contribution',
                              style: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        _signalBar(
                          context,
                          label:
                              'Machine Learning',
                          value:
                              averageMl,
                          maxValue:
                              60,
                          icon:
                              Icons.psychology_outlined,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        _signalBar(
                          context,
                          label:
                              'Security Rules',
                          value:
                              averageRules,
                          maxValue:
                              20,
                          icon:
                              Icons.rule_outlined,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        _signalBar(
                          context,
                          label:
                              'URL Analysis',
                          value:
                              averageUrl,
                          maxValue:
                              20,
                          icon:
                              Icons.link_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // RISK DISTRIBUTION
                  // ==================================================

                  Text(
                    'Risk Distribution',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _riskDistribution(
                    context,
                    high: high,
                    medium: medium,
                    low: low,
                    total: total,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // RECENT ACTIVITY
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent Activity',
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
                        Text(
                          '${_history.length} scans',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (_history.isEmpty)
                    _emptyState(context)
                  else
                    ..._history
                        .take(8)
                        .map(
                          (scan) =>
                              _activityCard(
                            context,
                            scan,
                          ),
                        ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // PRIVACY
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      border:
                          Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacy first',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Your scan history is stored '
                                'locally on your device.',
                                style:
                                    TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
    );
  }

  // ==============================================================
  // METRIC CARD
  // ==============================================================

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final cardColor =
        color ??
            Theme.of(context)
                .colorScheme
                .primary;

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            cardColor.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              cardColor.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: cardColor,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
              color: cardColor,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INSIGHT CARD
  // ==============================================================

  Widget _insightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
              fontSize: 12,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SIGNAL BAR
  // ==============================================================

  Widget _signalBar(
    BuildContext context, {
    required String label,
    required int value,
    required int maxValue,
    required IconData icon,
  }) {
    final progress =
        maxValue == 0
            ? 0.0
            : (value / maxValue)
                .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            Text(
              '$value',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 7,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          child:
              LinearProgressIndicator(
            value: progress,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // RISK DISTRIBUTION
  // ==============================================================

  Widget _riskDistribution(
    BuildContext context, {
    required int high,
    required int medium,
    required int low,
    required int total,
  }) {
    if (total == 0) {
      return Container(
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
        ),
        child: const Text(
          'No scan data available yet.',
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Column(
        children: [
          _distributionRow(
            label: 'High Risk',
            count: high,
            total: total,
            color: Colors.red,
          ),

          const SizedBox(
            height: 14,
          ),

          _distributionRow(
            label: 'Medium Risk',
            count: medium,
            total: total,
            color: Colors.orange,
          ),

          const SizedBox(
            height: 14,
          ),

          _distributionRow(
            label: 'Low Risk',
            count: low,
            total: total,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DISTRIBUTION ROW
  // ==============================================================

  Widget _distributionRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage =
        count / total;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            Text(
              '$count',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 6,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          child:
              LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            color: color,
            backgroundColor:
                color.withValues(
              alpha: 0.12,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // ACTIVITY CARD
  // ==============================================================

  Widget _activityCard(
    BuildContext context,
    ScanResult scan,
  ) {
    final color =
        _riskColor(scan.verdict);

    final label =
        _riskLabel(scan.verdict);

    final text =
        scan.originalText.trim();

    final preview =
        text.length > 70
            ? '${text.substring(0, 70)}...'
            : text;

    return Card(
      margin:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${scan.finalRiskScore}',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      '$label • '
                      '${scan.scannedAt.day.toString().padLeft(2, '0')}/'
                      '${scan.scannedAt.month.toString().padLeft(2, '0')}/'
                      '${scan.scannedAt.year}',
                      style:
                          TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _emptyState(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(28),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
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
            Icons.shield_outlined,
            size: 44,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'No scans yet',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Analyze your first suspicious message '
            'to start building your security history.',
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }
}