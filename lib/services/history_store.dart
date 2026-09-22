import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

/// Stores past scans locally on-device. No server, no account needed for v1 —
/// this keeps the privacy story simple ("we never see your messages") which
/// matters a lot for a fraud-detection app people need to trust.
class HistoryStore {
  static const _key = 'scan_history_v1';
  static const _maxEntries = 100;

  static Future<void> save(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.insert(0, jsonEncode(result.toJson()));
    if (existing.length > _maxEntries) {
      existing.removeRange(_maxEntries, existing.length);
    }
    await prefs.setStringList(_key, existing);
  }

  static Future<List<ScanResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    return existing
        .map((s) => ScanResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
