/// Guesses the company name being referenced in a message, so it can be
/// checked against MCA records without the user typing it separately.
/// Pure heuristic, no network — deliberately conservative: returning null
/// when unsure is better than confidently extracting the wrong name and
/// checking it against MCA, since a wrong MCA lookup is worse than none.
class CompanyNameExtractor {
  static final _patterns = [
RegExp(r'(?:HR Manager|Recruiter|HR Team|Hiring Manager) at ([A-Z][A-Za-z0-9&.\- ]{2,40}?)(?:\.|\s+(?:is|we|has|have|offers?|is hiring)\b)', caseSensitive: true),
    RegExp(r'from ([A-Z][A-Za-z0-9&.\- ]{2,40}) (?:HR|Recruitment|Team)', caseSensitive: true),
    RegExp(r'([A-Z][A-Za-z0-9&.\- ]{2,40}) is hiring', caseSensitive: true),
    RegExp(r'welcome to ([A-Z][A-Za-z0-9&.\- ]{2,40})', caseSensitive: false),
    RegExp(r'offer letter from ([A-Z][A-Za-z0-9&.\- ]{2,40})', caseSensitive: false),
  ];

  static String? extract(String text) {
    for (final pattern in _patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final name = match.group(1)?.trim();
        if (name != null && name.length > 2) {
          return _cleanTrailingWords(name);
        }
      }
    }
    return null;
  }

  // Trims trailing connector words a greedy match sometimes picks up,
  // e.g. "Amazon India for the" -> "Amazon India"
  static String _cleanTrailingWords(String name) {
    const trailingStopWords = ['for', 'the', 'and', 'to', 'is', 'we'];
    final words = name.split(RegExp(r'\s+'));
    while (words.isNotEmpty && trailingStopWords.contains(words.last.toLowerCase())) {
      words.removeLast();
    }
    return words.join(' ').trim();
  }
}
