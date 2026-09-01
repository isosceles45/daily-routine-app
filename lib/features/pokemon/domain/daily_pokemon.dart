/// One base stat, as shown in the canvas's bar rows.
class PokemonStat {
  const PokemonStat(this.label, this.value);

  final String label;
  final int value;

  /// Bar fill. The canvas renders a stat of 55 as 55%, so the scale is
  /// value-over-100, clamped. The exact number is always printed beside the
  /// bar, so the clamp costs nothing.
  double get fraction => (value / 100).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory PokemonStat.fromJson(Map<String, dynamic> json) =>
      PokemonStat(json['label'] as String, json['value'] as int);
}

class DailyPokemon {
  const DailyPokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.abilities,
    required this.heightDecimetres,
    required this.weightHectograms,
    required this.artworkUrl,
    required this.stats,
    this.flavorText,
  });

  final int id;
  final String name;
  final List<String> types;
  final List<String> abilities;
  final int heightDecimetres;
  final int weightHectograms;
  final String? artworkUrl;
  final List<PokemonStat> stats;

  /// The Pokédex blurb. Null when the species endpoint had no English entry.
  final String? flavorText;

  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// `#025`, matching the canvas.
  String get dexNumber => '#${id.toString().padLeft(3, '0')}';

  String get heightLabel => '${(heightDecimetres / 10).toStringAsFixed(1)} m';

  String get weightLabel => '${(weightHectograms / 10).toStringAsFixed(1)} kg';

  /// Builds from `/pokemon/{id}` plus the optional `/pokemon-species/{id}`.
  factory DailyPokemon.fromApi(
    Map<String, dynamic> pokemon, {
    Map<String, dynamic>? species,
  }) {
    List<String> namesFrom(String key, String inner) {
      return (pokemon[key] as List<dynamic>? ?? const [])
          .map(
            (e) =>
                ((e as Map<String, dynamic>)[inner]
                        as Map<String, dynamic>)['name']
                    as String,
          )
          .toList(growable: false);
    }

    final statMap = <String, int>{
      for (final entry in (pokemon['stats'] as List<dynamic>? ?? const []))
        ((entry as Map<String, dynamic>)['stat']
                    as Map<String, dynamic>)['name']
                as String:
            entry['base_stat'] as int,
    };

    final sprites = pokemon['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return DailyPokemon(
      id: pokemon['id'] as int,
      name: pokemon['name'] as String,
      types: namesFrom('types', 'type'),
      abilities: namesFrom('abilities', 'ability'),
      heightDecimetres: pokemon['height'] as int? ?? 0,
      weightHectograms: pokemon['weight'] as int? ?? 0,
      artworkUrl:
          artwork?['front_default'] as String? ??
          sprites?['front_default'] as String?,
      stats: [
        PokemonStat('HP', statMap['hp'] ?? 0),
        PokemonStat('ATK', statMap['attack'] ?? 0),
        PokemonStat('DEF', statMap['defense'] ?? 0),
        PokemonStat('SPD', statMap['speed'] ?? 0),
      ],
      flavorText: species == null ? null : _englishFlavorText(species),
    );
  }

  /// Pokédex entries carry hard line breaks and form feeds from the original
  /// cartridge text; collapse them or the blurb renders in ragged fragments.
  static String? _englishFlavorText(Map<String, dynamic> species) {
    final entries =
        species['flavor_text_entries'] as List<dynamic>? ?? const [];
    for (final entry in entries) {
      final map = entry as Map<String, dynamic>;
      final language = map['language'] as Map<String, dynamic>?;
      if (language?['name'] == 'en') {
        return (map['flavor_text'] as String)
            .replaceAll(RegExp(r'[\n\f\r]+'), ' ')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'types': types,
    'abilities': abilities,
    'heightDecimetres': heightDecimetres,
    'weightHectograms': weightHectograms,
    'artworkUrl': artworkUrl,
    'stats': stats.map((s) => s.toJson()).toList(),
    'flavorText': flavorText,
  };

  factory DailyPokemon.fromJson(Map<String, dynamic> json) => DailyPokemon(
    id: json['id'] as int,
    name: json['name'] as String,
    types: (json['types'] as List<dynamic>).cast<String>(),
    abilities: (json['abilities'] as List<dynamic>).cast<String>(),
    heightDecimetres: json['heightDecimetres'] as int,
    weightHectograms: json['weightHectograms'] as int,
    artworkUrl: json['artworkUrl'] as String?,
    stats: (json['stats'] as List<dynamic>)
        .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
        .toList(),
    flavorText: json['flavorText'] as String?,
  );
}
