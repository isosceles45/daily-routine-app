import '../../../core/dates/daily_date_service.dart';
import '../../../core/utils/daily_seed.dart';

/// The flavours the daily fun slot rotates through (§9).
enum FunKind {
  cat('Cat', '🐈'),
  dog('Dog', '🐕'),
  joke('A Joke', '😂'),
  darkJoke('A Dark Joke', '🃏'),
  weirdFact('Weird Fact', '🧠');

  const FunKind(this.label, this.emoji);

  final String label;
  final String emoji;

  /// The §9 rotation. Weekday fixes the flavour so the week has a rhythm;
  /// Sunday is a free pick, seeded by the date so it's still stable per day.
  static FunKind forDate(String date) {
    final weekday = DailyDateService.parse(date).weekday;
    return switch (weekday) {
      DateTime.monday => FunKind.cat,
      DateTime.tuesday => FunKind.joke,
      DateTime.wednesday => FunKind.dog,
      DateTime.thursday => FunKind.weirdFact,
      DateTime.friday => FunKind.cat,
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
