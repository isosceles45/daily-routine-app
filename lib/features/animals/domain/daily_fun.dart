import '../../../core/dates/daily_date_service.dart';
import '../../../core/utils/daily_seed.dart';
import '../../../shared/widgets/ritual_icon.dart';

/// The flavours the daily fun slot rotates through (§9).
enum FunKind {
  cat('Cat', RitualIcons.cat),
  dog('Dog', RitualIcons.dog),
  fox('Fox', RitualIcons.fox),
  duck('Duck', RitualIcons.duck),
  bunny('Bunny', RitualIcons.bunny),
  joke('A Joke', RitualIcons.joke),
  darkJoke('A Dark Joke', RitualIcons.jokeDark),
  weirdFact('Weird Fact', RitualIcons.fact);

  const FunKind(this.label, this.icon);

  final String label;
  final RitualIcons icon;

  /// Every kind that is an actual animal, in the order Explore lists them.
  ///
  /// Kept separate from [values] because the animal slot must never randomly
  /// serve a joke, and Explore's species picker must never offer one.
  static const animals = [cat, dog, fox, duck, bunny];

  bool get isAnimal => animals.contains(this);

  /// The §9 rotation. Weekday fixes the *flavour* so the week keeps its
  /// rhythm — but the three animal days now draw from the whole menagerie
  /// rather than alternating cat and dog forever.
  static FunKind forDate(String date) {
    final weekday = DailyDateService.parse(date).weekday;
    return switch (weekday) {
      DateTime.monday ||
      DateTime.wednesday ||
      DateTime.friday => dailyPick(date, 'fun-animal', animals),
      DateTime.tuesday => FunKind.joke,
      DateTime.thursday => FunKind.weirdFact,
      DateTime.saturday => FunKind.darkJoke,
      _ => dailyPick(date, 'fun-kind', FunKind.values),
    };
  }
}

/// A day's fun content. Either half may be absent — a joke has no image, and
/// an image source can succeed while its paired text source fails.
class DailyFun {
  const DailyFun({
    required this.kind,
    required this.source,
    this.text,
    this.imageUrl,
  });

  final FunKind kind;
  final String source;
  final String? text;
  final String? imageUrl;

  bool get hasContent => (text?.isNotEmpty ?? false) || imageUrl != null;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'source': source,
    'text': text,
    'imageUrl': imageUrl,
  };

  factory DailyFun.fromJson(Map<String, dynamic> json) => DailyFun(
    kind: FunKind.values.firstWhere(
      (k) => k.name == json['kind'],
      orElse: () => FunKind.weirdFact,
    ),
    source: json['source'] as String? ?? 'Unknown',
    text: json['text'] as String?,
    imageUrl: json['imageUrl'] as String?,
  );
}
