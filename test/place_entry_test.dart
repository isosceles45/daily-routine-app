import 'package:daily_ritual/features/places/domain/place_entry.dart';
import 'package:flutter_test/flutter_test.dart';

PlaceEntry entry(String extract) => PlaceEntry(
  title: 'Kenroku-en',
  extract: extract,
  category: 'Gardens',
  region: 'Japan',
  description: 'Japanese garden in Kanazawa',
);

void main() {
  group('lead and did-you-know split', () {
    test('the lead is the first two sentences', () {
      final e = entry('One. Two. Three. Four.');
      expect(e.lead, 'One. Two.');
      expect(e.didYouKnow, 'Three. Four.');
    });

    test('a short extract has no did-you-know rather than a repeat', () {
      // Two sentences are all lead; inventing a second block would just
      // duplicate the body.
      final e = entry('Only one sentence here. And a second one.');
      expect(e.didYouKnow, isNull);
      expect(e.lead, isNotEmpty);
    });

    test('a single sentence still yields a lead', () {
      final e = entry('Just the one.');
      expect(e.lead, 'Just the one.');
      expect(e.didYouKnow, isNull);
    });

    test('does not split on abbreviations mid-sentence', () {
      // "Mt. Fuji" must not become two sentences.
      final e = entry(
        'It sits near Mt. Fuji and the sea. It opened in 1676. '
        'It is famous. It has a fountain.',
      );
      expect(e.lead, contains('Mt. Fuji'));
      expect(e.lead, contains('1676'));
    });
  });

  group('tags', () {
    test('leads with region, then category and description', () {
      expect(entry('A. B. C. D.').tags, [
        'Japan',
        'Gardens',
        'Japanese garden in Kanazawa',
      ]);
    });

    test('a missing description yields no invented chip', () {
      const e = PlaceEntry(
        title: 'X',
        extract: 'A. B. C.',
        category: 'Gardens',
        region: 'Peru',
      );
      expect(e.tags, ['Peru', 'Gardens']);
    });
  });

  test('survives a cache round-trip', () {
    final original = entry('One. Two. Three.');
    final restored = PlaceEntry.fromJson(original.toJson());
    expect(restored.title, original.title);
    expect(restored.extract, original.extract);
    expect(restored.category, 'Gardens');
  });

  test('the curated category list is non-empty and unique', () {
    expect(PlaceCategory.all, isNotEmpty);
    expect(
      PlaceCategory.all.map((c) => c.wikiCategory).toSet(),
      hasLength(PlaceCategory.all.length),
    );
  });
}
