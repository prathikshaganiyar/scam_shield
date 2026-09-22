enum ImageForensicsRisk { suspicious, clean, unknown }

class ImageForensicsResult {
  final int matchCount; // how many other pages this exact image appears on
  final List<String> matchingDomains;
  final ImageForensicsRisk risk;
  final String? error;

  ImageForensicsResult({
    required this.matchCount,
    required this.matchingDomains,
    required this.risk,
    this.error,
  });

  factory ImageForensicsResult.error(String message) => ImageForensicsResult(
        matchCount: 0,
        matchingDomains: [],
        risk: ImageForensicsRisk.unknown,
        error: message,
      );

  /// A logo/letterhead image that shows up on many unrelated sites is a
  /// strong signal it was lifted from a stock/generic source rather than
  /// being the real company's actual letterhead. A handful of matches
  /// (e.g. the company's own site appearing more than once) is normal
  /// and not itself suspicious — the threshold matters here.
  static ImageForensicsRisk classify(int matchCount) {
    if (matchCount > 10) return ImageForensicsRisk.suspicious;
    return ImageForensicsRisk.clean;
  }
}
