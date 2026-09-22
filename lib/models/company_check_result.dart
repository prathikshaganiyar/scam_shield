enum CompanyStatus { registered, notFound, unknown }

class CompanyCheckResult {
  final String queriedName;
  final CompanyStatus status;
  final String? matchedLegalName;
  final String? cin; // Corporate Identification Number, if found
  final String? registrationDate;
  final String? error;

  CompanyCheckResult({
    required this.queriedName,
    required this.status,
    this.matchedLegalName,
    this.cin,
    this.registrationDate,
    this.error,
  });

  factory CompanyCheckResult.error(String queriedName, String message) => CompanyCheckResult(
        queriedName: queriedName,
        status: CompanyStatus.unknown,
        error: message,
      );

  factory CompanyCheckResult.notFound(String queriedName) => CompanyCheckResult(
        queriedName: queriedName,
        status: CompanyStatus.notFound,
      );
}
