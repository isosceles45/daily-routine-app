/// A day's Japan discovery.
class JapanEntry {
  const JapanEntry({
    required this.title,
    required this.extract,
    required this.category,
    this.description,
    this.imageUrl,
    this.pageUrl,
  });

  final String title;

  /// The Wikipedia summary, used as the body text.
  final String extract;

  /// Which curated category this came from, e.g. "Gardens".
  final String category;

  /// Wikipedia's one-line descriptor, shown as a chip when present.
  final String? description;

  final String? imageUrl;
  final String? pageUrl;

  /// The canvas shows tag chips. Wikipedia's short description is the only
  /// honest source for them, so a missing description simply means no chips
  /// rather than invented ones.
  List<String> get tags => [
        category,
        if (description != null && description!.isNotEmpty) description!,
      ];

  /// The canvas has a "Did You Know?" block under the body. There is no second
  /// source for it, so it is the tail of the extract — genuinely additional
  /// text, or nothing at all.
  String? get didYouKnow {
    final sentences = _sentences(extract);
    if (sentences.length < 3) return null;
    return sentences.skip(2).join(' ').trim();
  }

  /// The lead paragraph, kept separate so the body isn't duplicated by
  /// [didYouKnow].
  String get lead {
    final sentences = _sentences(extract);
    return sentences.take(2).join(' ').trim();
  }

  /// Abbreviations whose full stop does not end a sentence. Wikipedia's
  /// geography and history prose is full of them, and splitting on "Mt. Fuji"
  /// truncates the lead mid-phrase.
  static const _abbreviations = {
    'Mt', 'Mts', 'St', 'Ste', 'Dr', 'Prof', 'Rev', 'Jr', 'Sr', 'No', 'Vol',
    'c', 'ca', 'approx', 'est', 'fl', 'r', 'b', 'd',
    'e.g', 'i.e', 'etc', 'vs', 'Co', 'Inc', 'Ltd', 'Mr', 'Mrs', 'Ms',
  };

  static List<String> _sentences(String text) {
    final parts = text.split(RegExp(r'(?<=[.!?])\s+(?=[A-Z0-9])'));

    // Re-join anywhere the split landed after an abbreviation rather than a
    // genuine sentence end.
    final sentences = <String>[];
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      if (sentences.isNotEmpty && _endsWithAbbreviation(sentences.last)) {
        sentences[sentences.length - 1] = '${sentences.last} $trimmed';
      } else {
        sentences.add(trimmed);
      }
    }
    return sentences;
  }

  static bool _endsWithAbbreviation(String sentence) {
    if (!sentence.endsWith('.')) return false;
    final match = RegExp(r'([A-Za-z.]+)\.$').firstMatch(sentence);
    if (match == null) return false;
    return _abbreviations.contains(match.group(1));
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'extract': extract,
        'category': category,
        'description': description,
        'imageUrl': imageUrl,
        'pageUrl': pageUrl,
      };

  factory JapanEntry.fromJson(Map<String, dynamic> json) => JapanEntry(
        title: json['title'] as String,
        extract: json['extract'] as String,
        category: json['category'] as String? ?? 'Japan',
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        pageUrl: json['pageUrl'] as String?,
      );
}

/// The Wikipedia categories the feature draws from.
///
/// This is a list of *categories*, not of places — the members of each are
/// enumerated from the API, so what shows up is Wikipedia's editorial judgement
/// rather than a hand-written content bank. Only tightly curated categories
/// are listed: broad ones like "Japanese cuisine" return meta-articles and
/// obscure entries that make for a poor daily discovery.
class JapanCategory {
  const JapanCategory(this.wikiCategory, this.label);

  /// The Wikipedia category name, without the `Category:` prefix.
  final String wikiCategory;

  /// What to call it in the UI.
  final String label;

  static const all = [
    JapanCategory('World_Heritage_Sites_in_Japan', 'World Heritage'),
    JapanCategory('Gardens_in_Japan', 'Gardens'),
    JapanCategory('Prefectures_of_Japan', 'Prefectures'),
    JapanCategory('Festivals_in_Japan', 'Festivals'),
    JapanCategory('Buddhist_temples_in_Japan', 'Temples'),
    JapanCategory('Shinto_shrines_in_Japan', 'Shrines'),
    JapanCategory('Japanese_folklore', 'Folklore'),
    JapanCategory('National_Treasures_of_Japan', 'National Treasures'),
  ];
}
