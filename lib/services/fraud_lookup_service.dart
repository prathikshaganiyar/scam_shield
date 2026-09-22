import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fraud_report.dart';

class LookupResult {
  final String identifier;
  final IdentifierType type;
  final List<FraudReport> reports;

  LookupResult({required this.identifier, required this.type, required this.reports});

  bool get hasReports => reports.isNotEmpty;
  int get reportCount => reports.length;

  /// Distinct reporters matter more than raw report count for trust — five
  /// reports from what's clearly the same flow (same category, same day)
  /// is weaker signal than five reports spread over months.
  Map<FraudCategory, int> get categoryBreakdown {
    final map = <FraudCategory, int>{};
    for (final r in reports) {
      map[r.category] = (map[r.category] ?? 0) + 1;
    }
    return map;
  }

  DateTime? get firstReported =>
      reports.isEmpty ? null : reports.map((r) => r.reportedAt).reduce((a, b) => a.isBefore(b) ? a : b);
}

/// Talks to the shared Firestore 'fraud_reports' collection. This is the
/// piece a stateless AI chat tool structurally cannot do: read and write
/// data that accumulates across every user of the app, not just reason
/// over what's in one conversation.
class FraudLookupService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'fraud_reports';

  /// Ensures the current device has an anonymous Firebase auth session.
  /// This isn't strong anti-abuse (a determined spammer can still create
  /// many anonymous identities) but it removes the trivial case of a
  /// fully unauthenticated write, and gives you a uid to rate-limit
  /// against later (e.g. "max 5 reports per uid per day") via Firestore
  /// security rules or a Cloud Function.
  static Future<void> ensureSignedIn() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  static Future<LookupResult> lookup(String rawIdentifier, IdentifierType type) async {
    final normalized = FraudReport.normalize(rawIdentifier, type);
    final snapshot = await _db
        .collection(_collection)
        .where('normalizedIdentifier', isEqualTo: normalized)
        .where('type', isEqualTo: type.name)
        .orderBy('reportedAt', descending: true)
        .limit(50)
        .get();

    final reports = snapshot.docs.map((d) => FraudReport.fromFirestore(d.id, d.data())).toList();
    return LookupResult(identifier: normalized, type: type, reports: reports);
  }

  static Future<void> submitReport({
    required String rawIdentifier,
    required IdentifierType type,
    required FraudCategory category,
    String? note,
  }) async {
    await ensureSignedIn();
    final normalized = FraudReport.normalize(rawIdentifier, type);
    if (normalized.isEmpty) {
      throw ArgumentError('Identifier cannot be empty after normalization.');
    }
    await _db.collection(_collection).add({
      'type': type.name,
      'normalizedIdentifier': normalized,
      'category': category.name,
      'note': note,
      'reportedAt': Timestamp.now(),
      'reporterUid': FirebaseAuth.instance.currentUser?.uid, // for abuse tracking only, never shown in UI
    });
  }
}
