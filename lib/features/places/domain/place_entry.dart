/// A day's discovery from somewhere in the world.
class PlaceEntry {
  const PlaceEntry({
    required this.title,
    required this.extract,
    required this.category,
    required this.region,
    this.description,
    this.imageUrl,
    this.pageUrl,
  });

  final String title;

  /// The Wikipedia summary, used as the body text.
  final String extract;

  /// Which curated category this came from, e.g. "World Heritage".
  final String category;

  /// Where in the world it is, e.g. "Peru". Shown alongside [category] so the
  /// card says *where* before it says *what*.
  final String region;

  /// Wikipedia's one-line descriptor, shown as a chip when present.
  final String? description;

  final String? imageUrl;
  final String? pageUrl;

  /// The canvas shows tag chips. Wikipedia's short description is the only
  /// honest source for them, so a missing description simply means no chips
  /// rather than invented ones.
  List<String> get tags => [
    region,
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
    'Mt',
    'Mts',
    'St',
    'Ste',
    'Dr',
    'Prof',
    'Rev',
    'Jr',
    'Sr',
    'No',
    'Vol',
    'c',
    'ca',
    'approx',
    'est',
    'fl',
    'r',
    'b',
    'd',
    'e.g',
    'i.e',
    'etc',
    'vs',
    'Co',
    'Inc',
    'Ltd',
    'Mr',
    'Mrs',
    'Ms',
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
    'region': region,
    'description': description,
    'imageUrl': imageUrl,
    'pageUrl': pageUrl,
  };

  factory PlaceEntry.fromJson(Map<String, dynamic> json) => PlaceEntry(
    title: json['title'] as String,
    extract: json['extract'] as String,
    category: json['category'] as String? ?? 'Discovery',
    // Older cached rows predate worldwide places and are all Japanese.
    region: json['region'] as String? ?? 'Japan',
    description: json['description'] as String?,
    imageUrl: json['imageUrl'] as String?,
    pageUrl: json['pageUrl'] as String?,
  );
}

/// The Wikipedia categories the feature draws from.
///
/// This is a list of *categories*, not of places — the members of each are
/// enumerated from the API, so what shows up is Wikipedia's editorial judgement
/// rather than a hand-written content bank. Only tightly curated categories are
/// listed: broad ones like "Japanese cuisine" return meta-articles and obscure
/// entries that make for a poor daily discovery.
///
/// Every category here was probed live and returns real members. A category
/// that goes bad is not fatal — [WikipediaPlaceSource] tries several per day.
class PlaceCategory {
  const PlaceCategory(this.wikiCategory, this.label, this.region);

  /// The Wikipedia category name, without the `Category:` prefix.
  final String wikiCategory;

  /// What kind of thing it is, e.g. "World Heritage".
  final String label;

  /// Where in the world, e.g. "Peru".
  final String region;

  /// Japan is still the largest single block — it is the country the app was
  /// built around — but it is now one region among many rather than the whole
  /// feature.
  static const all = [
    // --- Japan -------------------------------------------------------------
    PlaceCategory('World_Heritage_Sites_in_Japan', 'World Heritage', 'Japan'),
    PlaceCategory('Gardens_in_Japan', 'Gardens', 'Japan'),
    PlaceCategory('Prefectures_of_Japan', 'Prefectures', 'Japan'),
    PlaceCategory('Festivals_in_Japan', 'Festivals', 'Japan'),
    PlaceCategory('Buddhist_temples_in_Japan', 'Temples', 'Japan'),
    PlaceCategory('Shinto_shrines_in_Japan', 'Shrines', 'Japan'),
    PlaceCategory('Japanese_folklore', 'Folklore', 'Japan'),
    PlaceCategory('National_Treasures_of_Japan', 'National Treasures', 'Japan'),

    // --- Asia --------------------------------------------------------------
    PlaceCategory('World_Heritage_Sites_in_India', 'World Heritage', 'India'),
    PlaceCategory('World_Heritage_Sites_in_China', 'World Heritage', 'China'),
    PlaceCategory(
      'World_Heritage_Sites_in_Cambodia',
      'World Heritage',
      'Cambodia',
    ),
    PlaceCategory('World_Heritage_Sites_in_Jordan', 'World Heritage', 'Jordan'),
    PlaceCategory('Archaeological_sites_in_Iran', 'Ancient Sites', 'Iran'),

    // --- Europe ------------------------------------------------------------
    PlaceCategory('World_Heritage_Sites_in_Italy', 'World Heritage', 'Italy'),
    PlaceCategory('World_Heritage_Sites_in_France', 'World Heritage', 'France'),
    PlaceCategory('World_Heritage_Sites_in_Spain', 'World Heritage', 'Spain'),
    PlaceCategory('World_Heritage_Sites_in_Greece', 'World Heritage', 'Greece'),
    PlaceCategory('World_Heritage_Sites_in_Turkey', 'World Heritage', 'Turkey'),

    // --- Africa & the Americas ---------------------------------------------
    PlaceCategory('World_Heritage_Sites_in_Egypt', 'World Heritage', 'Egypt'),
    PlaceCategory('World_Heritage_Sites_in_Peru', 'World Heritage', 'Peru'),
    PlaceCategory('World_Heritage_Sites_in_Mexico', 'World Heritage', 'Mexico'),

    // --- Wild places -------------------------------------------------------
    PlaceCategory(
      'National_parks_of_the_United_States',
      'National Parks',
      'United States',
    ),
    PlaceCategory(
      'National_parks_of_New_Zealand',
      'National Parks',
      'New Zealand',
    ),
  ];
}
