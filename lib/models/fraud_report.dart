import 'package:cloud_firestore/cloud_firestore.dart';

enum IdentifierType { upi, phone }

enum FraudCategory {
  advanceFeeJob,
  fakeInternship,
  fakeOfferLetter,
  taskBasedScam,
  other,
}

extension FraudCategoryLabel on FraudCategory {
  String get label {
    switch (this) {
      case FraudCategory.advanceFeeJob:
        return 'Asked for money before hiring';
      case FraudCategory.fakeInternship:
        return 'Fake internship / paid-to-join';
      case FraudCategory.fakeOfferLetter:
        return 'Fake offer letter';
      case FraudCategory.taskBasedScam:
        return 'Task-based / "easy money" scam';
      case FraudCategory.other:
        return 'Other';
    }
  }
}

/// A single, anonymized report submitted by a user about a UPI ID or phone
/// number used in a scam. Multiple reports against the same normalized
/// identifier accumulate into a lookup match — this accumulation is the
/// core thing a stateless AI chat tool cannot replicate.
class FraudReport {
  final String id;
  final IdentifierType type;
  final String normalizedIdentifier; // lowercase, no spaces/dashes/country code
  final FraudCategory category;
  final String? note; // short anonymized description, no PII about the reporter
  final DateTime reportedAt;

  FraudReport({
    required this.id,
    required this.type,
    required this.normalizedIdentifier,
    required this.category,
    required this.reportedAt,
    this.note,
  });

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'normalizedIdentifier': normalizedIdentifier,
        'category': category.name,
        'note': note,
        'reportedAt': Timestamp.fromDate(reportedAt),
      };

  factory FraudReport.fromFirestore(String id, Map<String, dynamic> data) {
    return FraudReport(
      id: id,
      type: IdentifierType.values.byName(data['type'] as String),
      normalizedIdentifier: data['normalizedIdentifier'] as String,
      category: FraudCategory.values.byName(data['category'] as String),
      note: data['note'] as String?,
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
    );
  }

  /// Strips formatting so "9876543210", "+91 98765 43210", and "98765-43210"
  /// all match the same identifier. Same idea for UPI IDs: lowercase and
  /// trimmed so "User@OkAxis" and "user@okaxis" match.
  static String normalize(String raw, IdentifierType type) {
    if (type == IdentifierType.phone) {
      var digits = raw.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.length > 10) {
        digits = digits.substring(digits.length - 10); // drop country code
      }
      return digits;
    }
    return raw.trim().toLowerCase().replaceAll(' ', '');
  }
}
