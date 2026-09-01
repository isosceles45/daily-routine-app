/// One slot of a surprise. Any slot may be missing — a pack with five of six
/// is still a pack, and better than an error screen (§23).
class SurpriseSlot {
  const SurpriseSlot({required this.label, required this.value, this.imageUrl});

  final String label;
  final String value;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'imageUrl': imageUrl,
  };

  factory SurpriseSlot.fromJson(Map<String, dynamic> json) => SurpriseSlot(
    label: json['label'] as String,
    value: json['value'] as String,
    imageUrl: json['imageUrl'] as String?,
  );
}

/// A generated "random internet pack" (§12).
class SurprisePack {
  const SurprisePack({required this.slots, required this.challenge});

  /// Animal, Pokémon, fact, joke — whichever arrived.
  final List<SurpriseSlot> slots;

  /// Drawn separately because the canvas gives it its own accent card.
  final String challenge;

  bool get isEmpty => slots.isEmpty;

  Map<String, dynamic> toJson() => {
    'slots': slots.map((s) => s.toJson()).toList(),
    'challenge': challenge,
  };

  factory SurprisePack.fromJson(Map<String, dynamic> json) => SurprisePack(
    slots: (json['slots'] as List<dynamic>)
        .map((e) => SurpriseSlot.fromJson(e as Map<String, dynamic>))
        .toList(),
    challenge: json['challenge'] as String,
  );
}
