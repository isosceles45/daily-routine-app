import 'dart:convert';
import 'dart:math';

/// Deterministic per-day content selection (IMPLEMENTATION.md §22).
///
/// Each feature hashes `"$date:$contentType"` rather than the bare date, so the
/// streams are independent. A single shared seed would correlate today's
/// Pokémon with today's joke category — pick a "lucky" number and every section
/// would move in lockstep.
///
/// FNV-1a, 32-bit: tiny, stable across platforms and releases, and — unlike
/// [String.hashCode] — guaranteed not to change between Dart versions, which
/// matters because a shifting hash would silently reshuffle past days.
int dailySeed(String date, String contentType) {
  const int fnvPrime = 0x01000193;
  const int fnvOffset = 0x811C9DC5;

  var hash = fnvOffset;
  for (final byte in utf8.encode('$date:$contentType')) {
    hash ^= byte;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash;
}

/// A reproducible RNG for a given day and content type.
Random dailyRandom(String date, String contentType) =>
    Random(dailySeed(date, contentType));

/// Picks an index in `[0, length)` deterministically for the day.
int dailyIndex(String date, String contentType, int length) {
  if (length <= 0) throw ArgumentError.value(length, 'length', 'must be > 0');
  return dailySeed(date, contentType) % length;
}

/// Picks an element of [items] deterministically for the day.
T dailyPick<T>(String date, String contentType, List<T> items) =>
    items[dailyIndex(date, contentType, items.length)];
