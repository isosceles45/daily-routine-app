// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailyStatesTable extends DailyStates
    with TableInfo<$DailyStatesTable, DailyState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greetingShownMeta = const VerificationMeta(
    'greetingShown',
  );
  @override
  late final GeneratedColumn<bool> greetingShown = GeneratedColumn<bool>(
    'greeting_shown',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("greeting_shown" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [date, createdAt, greetingShown];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('greeting_shown')) {
      context.handle(
        _greetingShownMeta,
        greetingShown.isAcceptableOrUnknown(
          data['greeting_shown']!,
          _greetingShownMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyState(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      greetingShown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}greeting_shown'],
      )!,
    );
  }

  @override
  $DailyStatesTable createAlias(String alias) {
    return $DailyStatesTable(attachedDatabase, alias);
  }
}

class DailyState extends DataClass implements Insertable<DailyState> {
  /// `yyyy-MM-dd`, local calendar date.
  final String date;
  final DateTime createdAt;

  /// Whether the "Happy New Day" greeting has been shown for this date (§5).
  final bool greetingShown;
  const DailyState({
    required this.date,
    required this.createdAt,
    required this.greetingShown,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['greeting_shown'] = Variable<bool>(greetingShown);
    return map;
  }

  DailyStatesCompanion toCompanion(bool nullToAbsent) {
    return DailyStatesCompanion(
      date: Value(date),
      createdAt: Value(createdAt),
      greetingShown: Value(greetingShown),
    );
  }

  factory DailyState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyState(
      date: serializer.fromJson<String>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      greetingShown: serializer.fromJson<bool>(json['greetingShown']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'greetingShown': serializer.toJson<bool>(greetingShown),
    };
  }

  DailyState copyWith({
    String? date,
    DateTime? createdAt,
    bool? greetingShown,
  }) => DailyState(
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    greetingShown: greetingShown ?? this.greetingShown,
  );
  DailyState copyWithCompanion(DailyStatesCompanion data) {
    return DailyState(
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      greetingShown: data.greetingShown.present
          ? data.greetingShown.value
          : this.greetingShown,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyState(')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('greetingShown: $greetingShown')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, createdAt, greetingShown);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyState &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.greetingShown == this.greetingShown);
}

class DailyStatesCompanion extends UpdateCompanion<DailyState> {
  final Value<String> date;
  final Value<DateTime> createdAt;
  final Value<bool> greetingShown;
  final Value<int> rowid;
  const DailyStatesCompanion({
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.greetingShown = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStatesCompanion.insert({
    required String date,
    required DateTime createdAt,
    this.greetingShown = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<DailyState> custom({
    Expression<String>? date,
    Expression<DateTime>? createdAt,
    Expression<bool>? greetingShown,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (greetingShown != null) 'greeting_shown': greetingShown,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStatesCompanion copyWith({
    Value<String>? date,
    Value<DateTime>? createdAt,
    Value<bool>? greetingShown,
    Value<int>? rowid,
  }) {
    return DailyStatesCompanion(
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      greetingShown: greetingShown ?? this.greetingShown,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (greetingShown.present) {
      map['greeting_shown'] = Variable<bool>(greetingShown.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatesCompanion(')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('greetingShown: $greetingShown, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyContentsTable extends DailyContents
    with TableInfo<$DailyContentsTable, DailyContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    contentType,
    source,
    sourceId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_contents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyContent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, contentType};
  @override
  DailyContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyContent(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyContentsTable createAlias(String alias) {
    return $DailyContentsTable(attachedDatabase, alias);
  }
}

class DailyContent extends DataClass implements Insertable<DailyContent> {
  final String date;

  /// `trivia`, `pokemon`, `fun`, `japan`, `challenge`, `catQuant`…
  final String contentType;

  /// Which API produced it, for attribution and debugging.
  final String source;
  final String? sourceId;

  /// The raw JSON payload.
  final String payload;
  final DateTime createdAt;
  const DailyContent({
    required this.date,
    required this.contentType,
    required this.source,
    this.sourceId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['content_type'] = Variable<String>(contentType);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyContentsCompanion toCompanion(bool nullToAbsent) {
    return DailyContentsCompanion(
      date: Value(date),
      contentType: Value(contentType),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory DailyContent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyContent(
      date: serializer.fromJson<String>(json['date']),
      contentType: serializer.fromJson<String>(json['contentType']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'contentType': serializer.toJson<String>(contentType),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyContent copyWith({
    String? date,
    String? contentType,
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? payload,
    DateTime? createdAt,
  }) => DailyContent(
    date: date ?? this.date,
    contentType: contentType ?? this.contentType,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyContent copyWithCompanion(DailyContentsCompanion data) {
    return DailyContent(
      date: data.date.present ? data.date.value : this.date,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyContent(')
          ..write('date: $date, ')
          ..write('contentType: $contentType, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, contentType, source, sourceId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyContent &&
          other.date == this.date &&
          other.contentType == this.contentType &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class DailyContentsCompanion extends UpdateCompanion<DailyContent> {
  final Value<String> date;
  final Value<String> contentType;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyContentsCompanion({
    this.date = const Value.absent(),
    this.contentType = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyContentsCompanion.insert({
    required String date,
    required String contentType,
    required String source,
    this.sourceId = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       contentType = Value(contentType),
       source = Value(source),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<DailyContent> custom({
    Expression<String>? date,
    Expression<String>? contentType,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (contentType != null) 'content_type': contentType,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyContentsCompanion copyWith({
    Value<String>? date,
    Value<String>? contentType,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyContentsCompanion(
      date: date ?? this.date,
      contentType: contentType ?? this.contentType,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyContentsCompanion(')
          ..write('date: $date, ')
          ..write('contentType: $contentType, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChallengesTable extends Challenges
    with TableInfo<$ChallengesTable, Challenge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [date, prompt, completed, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Challenge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  Challenge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Challenge(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ChallengesTable createAlias(String alias) {
    return $ChallengesTable(attachedDatabase, alias);
  }
}

class Challenge extends DataClass implements Insertable<Challenge> {
  final String date;

  /// The challenge itself. Named `prompt` rather than `text` because a column
  /// called `text` would shadow Drift's own `text()` column builder.
  final String prompt;
  final bool completed;
  final DateTime? completedAt;
  const Challenge({
    required this.date,
    required this.prompt,
    required this.completed,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['prompt'] = Variable<String>(prompt);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ChallengesCompanion toCompanion(bool nullToAbsent) {
    return ChallengesCompanion(
      date: Value(date),
      prompt: Value(prompt),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Challenge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Challenge(
      date: serializer.fromJson<String>(json['date']),
      prompt: serializer.fromJson<String>(json['prompt']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'prompt': serializer.toJson<String>(prompt),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Challenge copyWith({
    String? date,
    String? prompt,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Challenge(
    date: date ?? this.date,
    prompt: prompt ?? this.prompt,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Challenge copyWithCompanion(ChallengesCompanion data) {
    return Challenge(
      date: data.date.present ? data.date.value : this.date,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Challenge(')
          ..write('date: $date, ')
          ..write('prompt: $prompt, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, prompt, completed, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          other.date == this.date &&
          other.prompt == this.prompt &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class ChallengesCompanion extends UpdateCompanion<Challenge> {
  final Value<String> date;
  final Value<String> prompt;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ChallengesCompanion({
    this.date = const Value.absent(),
    this.prompt = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengesCompanion.insert({
    required String date,
    required String prompt,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       prompt = Value(prompt);
  static Insertable<Challenge> custom({
    Expression<String>? date,
    Expression<String>? prompt,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (prompt != null) 'prompt': prompt,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengesCompanion copyWith({
    Value<String>? date,
    Value<String>? prompt,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ChallengesCompanion(
      date: date ?? this.date,
      prompt: prompt ?? this.prompt,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengesCompanion(')
          ..write('date: $date, ')
          ..write('prompt: $prompt, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordleResultsTable extends WordleResults
    with TableInfo<$WordleResultsTable, WordleResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordleResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordleNumberMeta = const VerificationMeta(
    'wordleNumber',
  );
  @override
  late final GeneratedColumn<int> wordleNumber = GeneratedColumn<int>(
    'wordle_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hardModeMeta = const VerificationMeta(
    'hardMode',
  );
  @override
  late final GeneratedColumn<bool> hardMode = GeneratedColumn<bool>(
    'hard_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hard_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gridMeta = const VerificationMeta('grid');
  @override
  late final GeneratedColumn<String> grid = GeneratedColumn<String>(
    'grid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    wordleNumber,
    score,
    completed,
    hardMode,
    grid,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wordle_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordleResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('wordle_number')) {
      context.handle(
        _wordleNumberMeta,
        wordleNumber.isAcceptableOrUnknown(
          data['wordle_number']!,
          _wordleNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordleNumberMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('hard_mode')) {
      context.handle(
        _hardModeMeta,
        hardMode.isAcceptableOrUnknown(data['hard_mode']!, _hardModeMeta),
      );
    }
    if (data.containsKey('grid')) {
      context.handle(
        _gridMeta,
        grid.isAcceptableOrUnknown(data['grid']!, _gridMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  WordleResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordleResult(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      wordleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wordle_number'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      hardMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hard_mode'],
      )!,
      grid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grid'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $WordleResultsTable createAlias(String alias) {
    return $WordleResultsTable(attachedDatabase, alias);
  }
}

class WordleResult extends DataClass implements Insertable<WordleResult> {
  final String date;
  final int wordleNumber;

  /// Guesses used, 1–6. Null means the puzzle was failed (`X/6`).
  final int? score;
  final bool completed;
  final bool hardMode;

  /// The emoji grid, newline separated. Null when the share text omitted it.
  final String? grid;
  final DateTime importedAt;
  const WordleResult({
    required this.date,
    required this.wordleNumber,
    this.score,
    required this.completed,
    required this.hardMode,
    this.grid,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['wordle_number'] = Variable<int>(wordleNumber);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['completed'] = Variable<bool>(completed);
    map['hard_mode'] = Variable<bool>(hardMode);
    if (!nullToAbsent || grid != null) {
      map['grid'] = Variable<String>(grid);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  WordleResultsCompanion toCompanion(bool nullToAbsent) {
    return WordleResultsCompanion(
      date: Value(date),
      wordleNumber: Value(wordleNumber),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      completed: Value(completed),
      hardMode: Value(hardMode),
      grid: grid == null && nullToAbsent ? const Value.absent() : Value(grid),
      importedAt: Value(importedAt),
    );
  }

  factory WordleResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordleResult(
      date: serializer.fromJson<String>(json['date']),
      wordleNumber: serializer.fromJson<int>(json['wordleNumber']),
      score: serializer.fromJson<int?>(json['score']),
      completed: serializer.fromJson<bool>(json['completed']),
      hardMode: serializer.fromJson<bool>(json['hardMode']),
      grid: serializer.fromJson<String?>(json['grid']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'wordleNumber': serializer.toJson<int>(wordleNumber),
      'score': serializer.toJson<int?>(score),
      'completed': serializer.toJson<bool>(completed),
      'hardMode': serializer.toJson<bool>(hardMode),
      'grid': serializer.toJson<String?>(grid),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  WordleResult copyWith({
    String? date,
    int? wordleNumber,
    Value<int?> score = const Value.absent(),
    bool? completed,
    bool? hardMode,
    Value<String?> grid = const Value.absent(),
    DateTime? importedAt,
  }) => WordleResult(
    date: date ?? this.date,
    wordleNumber: wordleNumber ?? this.wordleNumber,
    score: score.present ? score.value : this.score,
    completed: completed ?? this.completed,
    hardMode: hardMode ?? this.hardMode,
    grid: grid.present ? grid.value : this.grid,
    importedAt: importedAt ?? this.importedAt,
  );
  WordleResult copyWithCompanion(WordleResultsCompanion data) {
    return WordleResult(
      date: data.date.present ? data.date.value : this.date,
      wordleNumber: data.wordleNumber.present
          ? data.wordleNumber.value
          : this.wordleNumber,
      score: data.score.present ? data.score.value : this.score,
      completed: data.completed.present ? data.completed.value : this.completed,
      hardMode: data.hardMode.present ? data.hardMode.value : this.hardMode,
      grid: data.grid.present ? data.grid.value : this.grid,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordleResult(')
          ..write('date: $date, ')
          ..write('wordleNumber: $wordleNumber, ')
          ..write('score: $score, ')
          ..write('completed: $completed, ')
          ..write('hardMode: $hardMode, ')
          ..write('grid: $grid, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    wordleNumber,
    score,
    completed,
    hardMode,
    grid,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordleResult &&
          other.date == this.date &&
          other.wordleNumber == this.wordleNumber &&
          other.score == this.score &&
          other.completed == this.completed &&
          other.hardMode == this.hardMode &&
          other.grid == this.grid &&
          other.importedAt == this.importedAt);
}

class WordleResultsCompanion extends UpdateCompanion<WordleResult> {
  final Value<String> date;
  final Value<int> wordleNumber;
  final Value<int?> score;
  final Value<bool> completed;
  final Value<bool> hardMode;
  final Value<String?> grid;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const WordleResultsCompanion({
    this.date = const Value.absent(),
    this.wordleNumber = const Value.absent(),
    this.score = const Value.absent(),
    this.completed = const Value.absent(),
    this.hardMode = const Value.absent(),
    this.grid = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordleResultsCompanion.insert({
    required String date,
    required int wordleNumber,
    this.score = const Value.absent(),
    this.completed = const Value.absent(),
    this.hardMode = const Value.absent(),
    this.grid = const Value.absent(),
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       wordleNumber = Value(wordleNumber),
       importedAt = Value(importedAt);
  static Insertable<WordleResult> custom({
    Expression<String>? date,
    Expression<int>? wordleNumber,
    Expression<int>? score,
    Expression<bool>? completed,
    Expression<bool>? hardMode,
    Expression<String>? grid,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (wordleNumber != null) 'wordle_number': wordleNumber,
      if (score != null) 'score': score,
      if (completed != null) 'completed': completed,
      if (hardMode != null) 'hard_mode': hardMode,
      if (grid != null) 'grid': grid,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordleResultsCompanion copyWith({
    Value<String>? date,
    Value<int>? wordleNumber,
    Value<int?>? score,
    Value<bool>? completed,
    Value<bool>? hardMode,
    Value<String?>? grid,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return WordleResultsCompanion(
      date: date ?? this.date,
      wordleNumber: wordleNumber ?? this.wordleNumber,
      score: score ?? this.score,
      completed: completed ?? this.completed,
      hardMode: hardMode ?? this.hardMode,
      grid: grid ?? this.grid,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (wordleNumber.present) {
      map['wordle_number'] = Variable<int>(wordleNumber.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (hardMode.present) {
      map['hard_mode'] = Variable<bool>(hardMode.value);
    }
    if (grid.present) {
      map['grid'] = Variable<String>(grid.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordleResultsCompanion(')
          ..write('date: $date, ')
          ..write('wordleNumber: $wordleNumber, ')
          ..write('score: $score, ')
          ..write('completed: $completed, ')
          ..write('hardMode: $hardMode, ')
          ..write('grid: $grid, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TriviaResultsTable extends TriviaResults
    with TableInfo<$TriviaResultsTable, TriviaResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedAnswerMeta = const VerificationMeta(
    'selectedAnswer',
  );
  @override
  late final GeneratedColumn<String> selectedAnswer = GeneratedColumn<String>(
    'selected_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredMeta = const VerificationMeta(
    'answered',
  );
  @override
  late final GeneratedColumn<bool> answered = GeneratedColumn<bool>(
    'answered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("answered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    questionId,
    selectedAnswer,
    answered,
    correct,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_answer')) {
      context.handle(
        _selectedAnswerMeta,
        selectedAnswer.isAcceptableOrUnknown(
          data['selected_answer']!,
          _selectedAnswerMeta,
        ),
      );
    }
    if (data.containsKey('answered')) {
      context.handle(
        _answeredMeta,
        answered.isAcceptableOrUnknown(data['answered']!, _answeredMeta),
      );
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  TriviaResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaResult(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      selectedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_answer'],
      ),
      answered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}answered'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  $TriviaResultsTable createAlias(String alias) {
    return $TriviaResultsTable(attachedDatabase, alias);
  }
}

class TriviaResult extends DataClass implements Insertable<TriviaResult> {
  final String date;
  final String questionId;
  final String? selectedAnswer;
  final bool answered;
  final bool correct;
  final DateTime? answeredAt;
  const TriviaResult({
    required this.date,
    required this.questionId,
    this.selectedAnswer,
    required this.answered,
    required this.correct,
    this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['question_id'] = Variable<String>(questionId);
    if (!nullToAbsent || selectedAnswer != null) {
      map['selected_answer'] = Variable<String>(selectedAnswer);
    }
    map['answered'] = Variable<bool>(answered);
    map['correct'] = Variable<bool>(correct);
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    return map;
  }

  TriviaResultsCompanion toCompanion(bool nullToAbsent) {
    return TriviaResultsCompanion(
      date: Value(date),
      questionId: Value(questionId),
      selectedAnswer: selectedAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedAnswer),
      answered: Value(answered),
      correct: Value(correct),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory TriviaResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaResult(
      date: serializer.fromJson<String>(json['date']),
      questionId: serializer.fromJson<String>(json['questionId']),
      selectedAnswer: serializer.fromJson<String?>(json['selectedAnswer']),
      answered: serializer.fromJson<bool>(json['answered']),
      correct: serializer.fromJson<bool>(json['correct']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'questionId': serializer.toJson<String>(questionId),
      'selectedAnswer': serializer.toJson<String?>(selectedAnswer),
      'answered': serializer.toJson<bool>(answered),
      'correct': serializer.toJson<bool>(correct),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
    };
  }

  TriviaResult copyWith({
    String? date,
    String? questionId,
    Value<String?> selectedAnswer = const Value.absent(),
    bool? answered,
    bool? correct,
    Value<DateTime?> answeredAt = const Value.absent(),
  }) => TriviaResult(
    date: date ?? this.date,
    questionId: questionId ?? this.questionId,
    selectedAnswer: selectedAnswer.present
        ? selectedAnswer.value
        : this.selectedAnswer,
    answered: answered ?? this.answered,
    correct: correct ?? this.correct,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  TriviaResult copyWithCompanion(TriviaResultsCompanion data) {
    return TriviaResult(
      date: data.date.present ? data.date.value : this.date,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedAnswer: data.selectedAnswer.present
          ? data.selectedAnswer.value
          : this.selectedAnswer,
      answered: data.answered.present ? data.answered.value : this.answered,
      correct: data.correct.present ? data.correct.value : this.correct,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResult(')
          ..write('date: $date, ')
          ..write('questionId: $questionId, ')
          ..write('selectedAnswer: $selectedAnswer, ')
          ..write('answered: $answered, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    questionId,
    selectedAnswer,
    answered,
    correct,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaResult &&
          other.date == this.date &&
          other.questionId == this.questionId &&
          other.selectedAnswer == this.selectedAnswer &&
          other.answered == this.answered &&
          other.correct == this.correct &&
          other.answeredAt == this.answeredAt);
}

class TriviaResultsCompanion extends UpdateCompanion<TriviaResult> {
  final Value<String> date;
  final Value<String> questionId;
  final Value<String?> selectedAnswer;
  final Value<bool> answered;
  final Value<bool> correct;
  final Value<DateTime?> answeredAt;
  final Value<int> rowid;
  const TriviaResultsCompanion({
    this.date = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedAnswer = const Value.absent(),
    this.answered = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TriviaResultsCompanion.insert({
    required String date,
    required String questionId,
    this.selectedAnswer = const Value.absent(),
    this.answered = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       questionId = Value(questionId);
  static Insertable<TriviaResult> custom({
    Expression<String>? date,
    Expression<String>? questionId,
    Expression<String>? selectedAnswer,
    Expression<bool>? answered,
    Expression<bool>? correct,
    Expression<DateTime>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (questionId != null) 'question_id': questionId,
      if (selectedAnswer != null) 'selected_answer': selectedAnswer,
      if (answered != null) 'answered': answered,
      if (correct != null) 'correct': correct,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TriviaResultsCompanion copyWith({
    Value<String>? date,
    Value<String>? questionId,
    Value<String?>? selectedAnswer,
    Value<bool>? answered,
    Value<bool>? correct,
    Value<DateTime?>? answeredAt,
    Value<int>? rowid,
  }) {
    return TriviaResultsCompanion(
      date: date ?? this.date,
      questionId: questionId ?? this.questionId,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      answered: answered ?? this.answered,
      correct: correct ?? this.correct,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (selectedAnswer.present) {
      map['selected_answer'] = Variable<String>(selectedAnswer.value);
    }
    if (answered.present) {
      map['answered'] = Variable<bool>(answered.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResultsCompanion(')
          ..write('date: $date, ')
          ..write('questionId: $questionId, ')
          ..write('selectedAnswer: $selectedAnswer, ')
          ..write('answered: $answered, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatQuantResultsTable extends CatQuantResults
    with TableInfo<$CatQuantResultsTable, CatQuantResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatQuantResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredMeta = const VerificationMeta(
    'answered',
  );
  @override
  late final GeneratedColumn<bool> answered = GeneratedColumn<bool>(
    'answered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("answered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    questionId,
    topic,
    difficulty,
    selectedIndex,
    answered,
    correct,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cat_quant_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatQuantResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    }
    if (data.containsKey('answered')) {
      context.handle(
        _answeredMeta,
        answered.isAcceptableOrUnknown(data['answered']!, _answeredMeta),
      );
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  CatQuantResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatQuantResult(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      ),
      answered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}answered'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  $CatQuantResultsTable createAlias(String alias) {
    return $CatQuantResultsTable(attachedDatabase, alias);
  }
}

class CatQuantResult extends DataClass implements Insertable<CatQuantResult> {
  final String date;
  final String questionId;
  final String topic;
  final String difficulty;
  final int? selectedIndex;
  final bool answered;
  final bool correct;
  final DateTime? answeredAt;
  const CatQuantResult({
    required this.date,
    required this.questionId,
    required this.topic,
    required this.difficulty,
    this.selectedIndex,
    required this.answered,
    required this.correct,
    this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['question_id'] = Variable<String>(questionId);
    map['topic'] = Variable<String>(topic);
    map['difficulty'] = Variable<String>(difficulty);
    if (!nullToAbsent || selectedIndex != null) {
      map['selected_index'] = Variable<int>(selectedIndex);
    }
    map['answered'] = Variable<bool>(answered);
    map['correct'] = Variable<bool>(correct);
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    return map;
  }

  CatQuantResultsCompanion toCompanion(bool nullToAbsent) {
    return CatQuantResultsCompanion(
      date: Value(date),
      questionId: Value(questionId),
      topic: Value(topic),
      difficulty: Value(difficulty),
      selectedIndex: selectedIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedIndex),
      answered: Value(answered),
      correct: Value(correct),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory CatQuantResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatQuantResult(
      date: serializer.fromJson<String>(json['date']),
      questionId: serializer.fromJson<String>(json['questionId']),
      topic: serializer.fromJson<String>(json['topic']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      selectedIndex: serializer.fromJson<int?>(json['selectedIndex']),
      answered: serializer.fromJson<bool>(json['answered']),
      correct: serializer.fromJson<bool>(json['correct']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'questionId': serializer.toJson<String>(questionId),
      'topic': serializer.toJson<String>(topic),
      'difficulty': serializer.toJson<String>(difficulty),
      'selectedIndex': serializer.toJson<int?>(selectedIndex),
      'answered': serializer.toJson<bool>(answered),
      'correct': serializer.toJson<bool>(correct),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
    };
  }

  CatQuantResult copyWith({
    String? date,
    String? questionId,
    String? topic,
    String? difficulty,
    Value<int?> selectedIndex = const Value.absent(),
    bool? answered,
    bool? correct,
    Value<DateTime?> answeredAt = const Value.absent(),
  }) => CatQuantResult(
    date: date ?? this.date,
    questionId: questionId ?? this.questionId,
    topic: topic ?? this.topic,
    difficulty: difficulty ?? this.difficulty,
    selectedIndex: selectedIndex.present
        ? selectedIndex.value
        : this.selectedIndex,
    answered: answered ?? this.answered,
    correct: correct ?? this.correct,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  CatQuantResult copyWithCompanion(CatQuantResultsCompanion data) {
    return CatQuantResult(
      date: data.date.present ? data.date.value : this.date,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      topic: data.topic.present ? data.topic.value : this.topic,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      answered: data.answered.present ? data.answered.value : this.answered,
      correct: data.correct.present ? data.correct.value : this.correct,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatQuantResult(')
          ..write('date: $date, ')
          ..write('questionId: $questionId, ')
          ..write('topic: $topic, ')
          ..write('difficulty: $difficulty, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('answered: $answered, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    questionId,
    topic,
    difficulty,
    selectedIndex,
    answered,
    correct,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatQuantResult &&
          other.date == this.date &&
          other.questionId == this.questionId &&
          other.topic == this.topic &&
          other.difficulty == this.difficulty &&
          other.selectedIndex == this.selectedIndex &&
          other.answered == this.answered &&
          other.correct == this.correct &&
          other.answeredAt == this.answeredAt);
}

class CatQuantResultsCompanion extends UpdateCompanion<CatQuantResult> {
  final Value<String> date;
  final Value<String> questionId;
  final Value<String> topic;
  final Value<String> difficulty;
  final Value<int?> selectedIndex;
  final Value<bool> answered;
  final Value<bool> correct;
  final Value<DateTime?> answeredAt;
  final Value<int> rowid;
  const CatQuantResultsCompanion({
    this.date = const Value.absent(),
    this.questionId = const Value.absent(),
    this.topic = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.answered = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatQuantResultsCompanion.insert({
    required String date,
    required String questionId,
    required String topic,
    required String difficulty,
    this.selectedIndex = const Value.absent(),
    this.answered = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       questionId = Value(questionId),
       topic = Value(topic),
       difficulty = Value(difficulty);
  static Insertable<CatQuantResult> custom({
    Expression<String>? date,
    Expression<String>? questionId,
    Expression<String>? topic,
    Expression<String>? difficulty,
    Expression<int>? selectedIndex,
    Expression<bool>? answered,
    Expression<bool>? correct,
    Expression<DateTime>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (questionId != null) 'question_id': questionId,
      if (topic != null) 'topic': topic,
      if (difficulty != null) 'difficulty': difficulty,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (answered != null) 'answered': answered,
      if (correct != null) 'correct': correct,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatQuantResultsCompanion copyWith({
    Value<String>? date,
    Value<String>? questionId,
    Value<String>? topic,
    Value<String>? difficulty,
    Value<int?>? selectedIndex,
    Value<bool>? answered,
    Value<bool>? correct,
    Value<DateTime?>? answeredAt,
    Value<int>? rowid,
  }) {
    return CatQuantResultsCompanion(
      date: date ?? this.date,
      questionId: questionId ?? this.questionId,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      answered: answered ?? this.answered,
      correct: correct ?? this.correct,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (answered.present) {
      map['answered'] = Variable<bool>(answered.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatQuantResultsCompanion(')
          ..write('date: $date, ')
          ..write('questionId: $questionId, ')
          ..write('topic: $topic, ')
          ..write('difficulty: $difficulty, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('answered: $answered, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SurprisesTable extends Surprises
    with TableInfo<$SurprisesTable, Surprise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurprisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surprises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Surprise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Surprise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Surprise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SurprisesTable createAlias(String alias) {
    return $SurprisesTable(attachedDatabase, alias);
  }
}

class Surprise extends DataClass implements Insertable<Surprise> {
  final int id;
  final String date;
  final String payload;
  final DateTime createdAt;
  const Surprise({
    required this.id,
    required this.date,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SurprisesCompanion toCompanion(bool nullToAbsent) {
    return SurprisesCompanion(
      id: Value(id),
      date: Value(date),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory Surprise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Surprise(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Surprise copyWith({
    int? id,
    String? date,
    String? payload,
    DateTime? createdAt,
  }) => Surprise(
    id: id ?? this.id,
    date: date ?? this.date,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  Surprise copyWithCompanion(SurprisesCompanion data) {
    return Surprise(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Surprise(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Surprise &&
          other.id == this.id &&
          other.date == this.date &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SurprisesCompanion extends UpdateCompanion<Surprise> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SurprisesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SurprisesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String payload,
    required DateTime createdAt,
  }) : date = Value(date),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<Surprise> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SurprisesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SurprisesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurprisesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderAtMeta = const VerificationMeta(
    'reminderAt',
  );
  @override
  late final GeneratedColumn<DateTime> reminderAt = GeneratedColumn<DateTime>(
    'reminder_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    completed,
    priority,
    createdAt,
    updatedAt,
    dueDate,
    reminderAt,
    completedAt,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Todo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
        _reminderAtMeta,
        reminderAt.isAcceptableOrUnknown(data['reminder_at']!, _reminderAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      reminderAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends DataClass implements Insertable<Todo> {
  final String id;
  final String title;
  final String? description;
  final bool completed;

  /// 0 = low, 1 = normal, 2 = high. Mirrors `TodoPriority`.
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final String? category;
  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.reminderAt,
    this.completedAt,
    this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['completed'] = Variable<bool>(completed);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<DateTime>(reminderAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      completed: Value(completed),
      priority: Value(priority),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory Todo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      completed: serializer.fromJson<bool>(json['completed']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'completed': serializer.toJson<bool>(completed),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'category': serializer.toJson<String?>(category),
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? completed,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> reminderAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> category = const Value.absent(),
  }) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    completed: completed ?? this.completed,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    category: category.present ? category.value : this.category,
  );
  Todo copyWithCompanion(TodosCompanion data) {
    return Todo(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      completed: data.completed.present ? data.completed.value : this.completed,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('completed: $completed, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    completed,
    priority,
    createdAt,
    updatedAt,
    dueDate,
    reminderAt,
    completedAt,
    category,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.completed == this.completed &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dueDate == this.dueDate &&
          other.reminderAt == this.reminderAt &&
          other.completedAt == this.completedAt &&
          other.category == this.category);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> completed;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> reminderAt;
  final Value<DateTime?> completedAt;
  final Value<String?> category;
  final Value<int> rowid;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.completed = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.completed = const Value.absent(),
    this.priority = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.dueDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Todo> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? completed,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? reminderAt,
    Expression<DateTime>? completedAt,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (completed != null) 'completed': completed,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? completed,
    Value<int>? priority,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? reminderAt,
    Value<DateTime?>? completedAt,
    Value<String?>? category,
    Value<int>? rowid,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<DateTime>(reminderAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('completed: $completed, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    date,
    note,
    emoji,
    pinned,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String title;

  /// The day it happens, local calendar date as `yyyy-MM-dd`.
  ///
  /// Stored as text rather than DateTime for the same reason every other date
  /// in this app is: a countdown is measured in calendar days, and a UTC
  /// instant would tip over a day early or late depending on the timezone.
  final String date;
  final String? note;

  /// Optional emoji shown on the countdown card.
  final String? emoji;

  /// Pinned events lead the list and surface on Today.
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Event({
    required this.id,
    required this.title,
    required this.date,
    this.note,
    this.emoji,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      pinned: Value(pinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'note': serializer.toJson<String?>(note),
      'emoji': serializer.toJson<String?>(emoji),
      'pinned': serializer.toJson<bool>(pinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? date,
    Value<String?> note = const Value.absent(),
    Value<String?> emoji = const Value.absent(),
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    emoji: emoji.present ? emoji.value : this.emoji,
    pinned: pinned ?? this.pinned,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('emoji: $emoji, ')
          ..write('pinned: $pinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, date, note, emoji, pinned, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.note == this.note &&
          other.emoji == this.emoji &&
          other.pinned == this.pinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> date;
  final Value<String?> note;
  final Value<String?> emoji;
  final Value<bool> pinned;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.emoji = const Value.absent(),
    this.pinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required String date,
    this.note = const Value.absent(),
    this.emoji = const Value.absent(),
    this.pinned = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? note,
    Expression<String>? emoji,
    Expression<bool>? pinned,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (emoji != null) 'emoji': emoji,
      if (pinned != null) 'pinned': pinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? date,
    Value<String?>? note,
    Value<String?>? emoji,
    Value<bool>? pinned,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      emoji: emoji ?? this.emoji,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('emoji: $emoji, ')
          ..write('pinned: $pinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSlotsTable extends WorkoutSlots
    with TableInfo<$WorkoutSlotsTable, WorkoutSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wgerCategoryMeta = const VerificationMeta(
    'wgerCategory',
  );
  @override
  late final GeneratedColumn<int> wgerCategory = GeneratedColumn<int>(
    'wger_category',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    weekday,
    focus,
    wgerCategory,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    if (data.containsKey('wger_category')) {
      context.handle(
        _wgerCategoryMeta,
        wgerCategory.isAcceptableOrUnknown(
          data['wger_category']!,
          _wgerCategoryMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday};
  @override
  WorkoutSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSlot(
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
      wgerCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wger_category'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutSlotsTable createAlias(String alias) {
    return $WorkoutSlotsTable(attachedDatabase, alias);
  }
}

class WorkoutSlot extends DataClass implements Insertable<WorkoutSlot> {
  final int weekday;

  /// What that day trains — a wger category name such as "Chest", or "Rest".
  final String focus;

  /// The wger category id this focus maps to, so suggestions can be fetched.
  /// Null for a rest day, or a focus the user typed that maps to nothing.
  final int? wgerCategory;
  final DateTime updatedAt;
  const WorkoutSlot({
    required this.weekday,
    required this.focus,
    this.wgerCategory,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['focus'] = Variable<String>(focus);
    if (!nullToAbsent || wgerCategory != null) {
      map['wger_category'] = Variable<int>(wgerCategory);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutSlotsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSlotsCompanion(
      weekday: Value(weekday),
      focus: Value(focus),
      wgerCategory: wgerCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(wgerCategory),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSlot(
      weekday: serializer.fromJson<int>(json['weekday']),
      focus: serializer.fromJson<String>(json['focus']),
      wgerCategory: serializer.fromJson<int?>(json['wgerCategory']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'focus': serializer.toJson<String>(focus),
      'wgerCategory': serializer.toJson<int?>(wgerCategory),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutSlot copyWith({
    int? weekday,
    String? focus,
    Value<int?> wgerCategory = const Value.absent(),
    DateTime? updatedAt,
  }) => WorkoutSlot(
    weekday: weekday ?? this.weekday,
    focus: focus ?? this.focus,
    wgerCategory: wgerCategory.present ? wgerCategory.value : this.wgerCategory,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutSlot copyWithCompanion(WorkoutSlotsCompanion data) {
    return WorkoutSlot(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      focus: data.focus.present ? data.focus.value : this.focus,
      wgerCategory: data.wgerCategory.present
          ? data.wgerCategory.value
          : this.wgerCategory,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSlot(')
          ..write('weekday: $weekday, ')
          ..write('focus: $focus, ')
          ..write('wgerCategory: $wgerCategory, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, focus, wgerCategory, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSlot &&
          other.weekday == this.weekday &&
          other.focus == this.focus &&
          other.wgerCategory == this.wgerCategory &&
          other.updatedAt == this.updatedAt);
}

class WorkoutSlotsCompanion extends UpdateCompanion<WorkoutSlot> {
  final Value<int> weekday;
  final Value<String> focus;
  final Value<int?> wgerCategory;
  final Value<DateTime> updatedAt;
  const WorkoutSlotsCompanion({
    this.weekday = const Value.absent(),
    this.focus = const Value.absent(),
    this.wgerCategory = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WorkoutSlotsCompanion.insert({
    this.weekday = const Value.absent(),
    required String focus,
    this.wgerCategory = const Value.absent(),
    required DateTime updatedAt,
  }) : focus = Value(focus),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutSlot> custom({
    Expression<int>? weekday,
    Expression<String>? focus,
    Expression<int>? wgerCategory,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (focus != null) 'focus': focus,
      if (wgerCategory != null) 'wger_category': wgerCategory,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WorkoutSlotsCompanion copyWith({
    Value<int>? weekday,
    Value<String>? focus,
    Value<int?>? wgerCategory,
    Value<DateTime>? updatedAt,
  }) {
    return WorkoutSlotsCompanion(
      weekday: weekday ?? this.weekday,
      focus: focus ?? this.focus,
      wgerCategory: wgerCategory ?? this.wgerCategory,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (wgerCategory.present) {
      map['wger_category'] = Variable<int>(wgerCategory.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSlotsCompanion(')
          ..write('weekday: $weekday, ')
          ..write('focus: $focus, ')
          ..write('wgerCategory: $wgerCategory, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutLogsTable extends WorkoutLogs
    with TableInfo<$WorkoutLogsTable, WorkoutLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<String> done = GeneratedColumn<String>(
    'done',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    focus,
    done,
    completed,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  WorkoutLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutLog(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $WorkoutLogsTable createAlias(String alias) {
    return $WorkoutLogsTable(attachedDatabase, alias);
  }
}

class WorkoutLog extends DataClass implements Insertable<WorkoutLog> {
  final String date;
  final String focus;

  /// Exercise names the user ticked off, JSON-encoded.
  final String? done;
  final bool completed;
  final DateTime? completedAt;
  const WorkoutLog({
    required this.date,
    required this.focus,
    this.done,
    required this.completed,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['focus'] = Variable<String>(focus);
    if (!nullToAbsent || done != null) {
      map['done'] = Variable<String>(done);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  WorkoutLogsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutLogsCompanion(
      date: Value(date),
      focus: Value(focus),
      done: done == null && nullToAbsent ? const Value.absent() : Value(done),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory WorkoutLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutLog(
      date: serializer.fromJson<String>(json['date']),
      focus: serializer.fromJson<String>(json['focus']),
      done: serializer.fromJson<String?>(json['done']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'focus': serializer.toJson<String>(focus),
      'done': serializer.toJson<String?>(done),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  WorkoutLog copyWith({
    String? date,
    String? focus,
    Value<String?> done = const Value.absent(),
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => WorkoutLog(
    date: date ?? this.date,
    focus: focus ?? this.focus,
    done: done.present ? done.value : this.done,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  WorkoutLog copyWithCompanion(WorkoutLogsCompanion data) {
    return WorkoutLog(
      date: data.date.present ? data.date.value : this.date,
      focus: data.focus.present ? data.focus.value : this.focus,
      done: data.done.present ? data.done.value : this.done,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLog(')
          ..write('date: $date, ')
          ..write('focus: $focus, ')
          ..write('done: $done, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, focus, done, completed, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutLog &&
          other.date == this.date &&
          other.focus == this.focus &&
          other.done == this.done &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class WorkoutLogsCompanion extends UpdateCompanion<WorkoutLog> {
  final Value<String> date;
  final Value<String> focus;
  final Value<String?> done;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const WorkoutLogsCompanion({
    this.date = const Value.absent(),
    this.focus = const Value.absent(),
    this.done = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutLogsCompanion.insert({
    required String date,
    required String focus,
    this.done = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       focus = Value(focus);
  static Insertable<WorkoutLog> custom({
    Expression<String>? date,
    Expression<String>? focus,
    Expression<String>? done,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (focus != null) 'focus': focus,
      if (done != null) 'done': done,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutLogsCompanion copyWith({
    Value<String>? date,
    Value<String>? focus,
    Value<String?>? done,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkoutLogsCompanion(
      date: date ?? this.date,
      focus: focus ?? this.focus,
      done: done ?? this.done,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (done.present) {
      map['done'] = Variable<String>(done.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLogsCompanion(')
          ..write('date: $date, ')
          ..write('focus: $focus, ')
          ..write('done: $done, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameScoresTable extends GameScores
    with TableInfo<$GameScoresTable, GameScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    game,
    score,
    detail,
    date,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $GameScoresTable createAlias(String alias) {
    return $GameScoresTable(attachedDatabase, alias);
  }
}

class GameScore extends DataClass implements Insertable<GameScore> {
  final int id;

  /// Matches `GameKind.name`.
  final String game;

  /// Higher is better for every game here, which is what lets one table serve
  /// all of them.
  final int score;

  /// Per-game extras — difficulty, duration, accuracy — as JSON.
  final String? detail;

  /// The calendar date the run happened, for per-day history.
  final String date;
  final DateTime playedAt;
  const GameScore({
    required this.id,
    required this.game,
    required this.score,
    this.detail,
    required this.date,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game'] = Variable<String>(game);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['date'] = Variable<String>(date);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  GameScoresCompanion toCompanion(bool nullToAbsent) {
    return GameScoresCompanion(
      id: Value(id),
      game: Value(game),
      score: Value(score),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      date: Value(date),
      playedAt: Value(playedAt),
    );
  }

  factory GameScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameScore(
      id: serializer.fromJson<int>(json['id']),
      game: serializer.fromJson<String>(json['game']),
      score: serializer.fromJson<int>(json['score']),
      detail: serializer.fromJson<String?>(json['detail']),
      date: serializer.fromJson<String>(json['date']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'game': serializer.toJson<String>(game),
      'score': serializer.toJson<int>(score),
      'detail': serializer.toJson<String?>(detail),
      'date': serializer.toJson<String>(date),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  GameScore copyWith({
    int? id,
    String? game,
    int? score,
    Value<String?> detail = const Value.absent(),
    String? date,
    DateTime? playedAt,
  }) => GameScore(
    id: id ?? this.id,
    game: game ?? this.game,
    score: score ?? this.score,
    detail: detail.present ? detail.value : this.detail,
    date: date ?? this.date,
    playedAt: playedAt ?? this.playedAt,
  );
  GameScore copyWithCompanion(GameScoresCompanion data) {
    return GameScore(
      id: data.id.present ? data.id.value : this.id,
      game: data.game.present ? data.game.value : this.game,
      score: data.score.present ? data.score.value : this.score,
      detail: data.detail.present ? data.detail.value : this.detail,
      date: data.date.present ? data.date.value : this.date,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameScore(')
          ..write('id: $id, ')
          ..write('game: $game, ')
          ..write('score: $score, ')
          ..write('detail: $detail, ')
          ..write('date: $date, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, game, score, detail, date, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameScore &&
          other.id == this.id &&
          other.game == this.game &&
          other.score == this.score &&
          other.detail == this.detail &&
          other.date == this.date &&
          other.playedAt == this.playedAt);
}

class GameScoresCompanion extends UpdateCompanion<GameScore> {
  final Value<int> id;
  final Value<String> game;
  final Value<int> score;
  final Value<String?> detail;
  final Value<String> date;
  final Value<DateTime> playedAt;
  const GameScoresCompanion({
    this.id = const Value.absent(),
    this.game = const Value.absent(),
    this.score = const Value.absent(),
    this.detail = const Value.absent(),
    this.date = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  GameScoresCompanion.insert({
    this.id = const Value.absent(),
    required String game,
    required int score,
    this.detail = const Value.absent(),
    required String date,
    required DateTime playedAt,
  }) : game = Value(game),
       score = Value(score),
       date = Value(date),
       playedAt = Value(playedAt);
  static Insertable<GameScore> custom({
    Expression<int>? id,
    Expression<String>? game,
    Expression<int>? score,
    Expression<String>? detail,
    Expression<String>? date,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (game != null) 'game': game,
      if (score != null) 'score': score,
      if (detail != null) 'detail': detail,
      if (date != null) 'date': date,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  GameScoresCompanion copyWith({
    Value<int>? id,
    Value<String>? game,
    Value<int>? score,
    Value<String?>? detail,
    Value<String>? date,
    Value<DateTime>? playedAt,
  }) {
    return GameScoresCompanion(
      id: id ?? this.id,
      game: game ?? this.game,
      score: score ?? this.score,
      detail: detail ?? this.detail,
      date: date ?? this.date,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameScoresCompanion(')
          ..write('id: $id, ')
          ..write('game: $game, ')
          ..write('score: $score, ')
          ..write('detail: $detail, ')
          ..write('date: $date, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $PuzzleStatesTable extends PuzzleStates
    with TableInfo<$PuzzleStatesTable, PuzzleState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [game, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {game};
  @override
  PuzzleState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleState(
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PuzzleStatesTable createAlias(String alias) {
    return $PuzzleStatesTable(attachedDatabase, alias);
  }
}

class PuzzleState extends DataClass implements Insertable<PuzzleState> {
  /// Matches `GameKind.name`.
  final String game;

  /// The whole board, JSON-encoded. Kept opaque for the same reason
  /// `daily_contents` is: a game changing its representation must not need a
  /// schema migration.
  final String payload;
  final DateTime updatedAt;
  const PuzzleState({
    required this.game,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game'] = Variable<String>(game);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PuzzleStatesCompanion toCompanion(bool nullToAbsent) {
    return PuzzleStatesCompanion(
      game: Value(game),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory PuzzleState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleState(
      game: serializer.fromJson<String>(json['game']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game': serializer.toJson<String>(game),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PuzzleState copyWith({String? game, String? payload, DateTime? updatedAt}) =>
      PuzzleState(
        game: game ?? this.game,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PuzzleState copyWithCompanion(PuzzleStatesCompanion data) {
    return PuzzleState(
      game: data.game.present ? data.game.value : this.game,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleState(')
          ..write('game: $game, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(game, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleState &&
          other.game == this.game &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class PuzzleStatesCompanion extends UpdateCompanion<PuzzleState> {
  final Value<String> game;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PuzzleStatesCompanion({
    this.game = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PuzzleStatesCompanion.insert({
    required String game,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : game = Value(game),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<PuzzleState> custom({
    Expression<String>? game,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (game != null) 'game': game,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PuzzleStatesCompanion copyWith({
    Value<String>? game,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PuzzleStatesCompanion(
      game: game ?? this.game,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleStatesCompanion(')
          ..write('game: $game, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyStatesTable dailyStates = $DailyStatesTable(this);
  late final $DailyContentsTable dailyContents = $DailyContentsTable(this);
  late final $ChallengesTable challenges = $ChallengesTable(this);
  late final $WordleResultsTable wordleResults = $WordleResultsTable(this);
  late final $TriviaResultsTable triviaResults = $TriviaResultsTable(this);
  late final $CatQuantResultsTable catQuantResults = $CatQuantResultsTable(
    this,
  );
  late final $SurprisesTable surprises = $SurprisesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $WorkoutSlotsTable workoutSlots = $WorkoutSlotsTable(this);
  late final $WorkoutLogsTable workoutLogs = $WorkoutLogsTable(this);
  late final $GameScoresTable gameScores = $GameScoresTable(this);
  late final $PuzzleStatesTable puzzleStates = $PuzzleStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailyStates,
    dailyContents,
    challenges,
    wordleResults,
    triviaResults,
    catQuantResults,
    surprises,
    todos,
    appSettings,
    events,
    workoutSlots,
    workoutLogs,
    gameScores,
    puzzleStates,
  ];
}

typedef $$DailyStatesTableCreateCompanionBuilder =
    DailyStatesCompanion Function({
      required String date,
      required DateTime createdAt,
      Value<bool> greetingShown,
      Value<int> rowid,
    });
typedef $$DailyStatesTableUpdateCompanionBuilder =
    DailyStatesCompanion Function({
      Value<String> date,
      Value<DateTime> createdAt,
      Value<bool> greetingShown,
      Value<int> rowid,
    });

class $$DailyStatesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatesTable> {
  $$DailyStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get greetingShown => $composableBuilder(
    column: $table.greetingShown,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatesTable> {
  $$DailyStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get greetingShown => $composableBuilder(
    column: $table.greetingShown,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatesTable> {
  $$DailyStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get greetingShown => $composableBuilder(
    column: $table.greetingShown,
    builder: (column) => column,
  );
}

class $$DailyStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStatesTable,
          DailyState,
          $$DailyStatesTableFilterComposer,
          $$DailyStatesTableOrderingComposer,
          $$DailyStatesTableAnnotationComposer,
          $$DailyStatesTableCreateCompanionBuilder,
          $$DailyStatesTableUpdateCompanionBuilder,
          (
            DailyState,
            BaseReferences<_$AppDatabase, $DailyStatesTable, DailyState>,
          ),
          DailyState,
          PrefetchHooks Function()
        > {
  $$DailyStatesTableTableManager(_$AppDatabase db, $DailyStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> greetingShown = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatesCompanion(
                date: date,
                createdAt: createdAt,
                greetingShown: greetingShown,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required DateTime createdAt,
                Value<bool> greetingShown = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatesCompanion.insert(
                date: date,
                createdAt: createdAt,
                greetingShown: greetingShown,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStatesTable,
      DailyState,
      $$DailyStatesTableFilterComposer,
      $$DailyStatesTableOrderingComposer,
      $$DailyStatesTableAnnotationComposer,
      $$DailyStatesTableCreateCompanionBuilder,
      $$DailyStatesTableUpdateCompanionBuilder,
      (
        DailyState,
        BaseReferences<_$AppDatabase, $DailyStatesTable, DailyState>,
      ),
      DailyState,
      PrefetchHooks Function()
    >;
typedef $$DailyContentsTableCreateCompanionBuilder =
    DailyContentsCompanion Function({
      required String date,
      required String contentType,
      required String source,
      Value<String?> sourceId,
      required String payload,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailyContentsTableUpdateCompanionBuilder =
    DailyContentsCompanion Function({
      Value<String> date,
      Value<String> contentType,
      Value<String> source,
      Value<String?> sourceId,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailyContentsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyContentsTable> {
  $$DailyContentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyContentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyContentsTable> {
  $$DailyContentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyContentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyContentsTable> {
  $$DailyContentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyContentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyContentsTable,
          DailyContent,
          $$DailyContentsTableFilterComposer,
          $$DailyContentsTableOrderingComposer,
          $$DailyContentsTableAnnotationComposer,
          $$DailyContentsTableCreateCompanionBuilder,
          $$DailyContentsTableUpdateCompanionBuilder,
          (
            DailyContent,
            BaseReferences<_$AppDatabase, $DailyContentsTable, DailyContent>,
          ),
          DailyContent,
          PrefetchHooks Function()
        > {
  $$DailyContentsTableTableManager(_$AppDatabase db, $DailyContentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyContentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyContentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyContentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyContentsCompanion(
                date: date,
                contentType: contentType,
                source: source,
                sourceId: sourceId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String contentType,
                required String source,
                Value<String?> sourceId = const Value.absent(),
                required String payload,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyContentsCompanion.insert(
                date: date,
                contentType: contentType,
                source: source,
                sourceId: sourceId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyContentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyContentsTable,
      DailyContent,
      $$DailyContentsTableFilterComposer,
      $$DailyContentsTableOrderingComposer,
      $$DailyContentsTableAnnotationComposer,
      $$DailyContentsTableCreateCompanionBuilder,
      $$DailyContentsTableUpdateCompanionBuilder,
      (
        DailyContent,
        BaseReferences<_$AppDatabase, $DailyContentsTable, DailyContent>,
      ),
      DailyContent,
      PrefetchHooks Function()
    >;
typedef $$ChallengesTableCreateCompanionBuilder = ChallengesCompanion Function({
  required String date,
  required String prompt,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$ChallengesTableUpdateCompanionBuilder = ChallengesCompanion Function({
  Value<String> date,
  Value<String> prompt,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$ChallengesTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ChallengesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengesTable,
          Challenge,
          $$ChallengesTableFilterComposer,
          $$ChallengesTableOrderingComposer,
          $$ChallengesTableAnnotationComposer,
          $$ChallengesTableCreateCompanionBuilder,
          $$ChallengesTableUpdateCompanionBuilder,
          (
            Challenge,
            BaseReferences<_$AppDatabase, $ChallengesTable, Challenge>,
          ),
          Challenge,
          PrefetchHooks Function()
        > {
  $$ChallengesTableTableManager(_$AppDatabase db, $ChallengesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengesCompanion(
                date: date,
                prompt: prompt,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String prompt,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengesCompanion.insert(
                date: date,
                prompt: prompt,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengesTable,
      Challenge,
      $$ChallengesTableFilterComposer,
      $$ChallengesTableOrderingComposer,
      $$ChallengesTableAnnotationComposer,
      $$ChallengesTableCreateCompanionBuilder,
      $$ChallengesTableUpdateCompanionBuilder,
      (Challenge, BaseReferences<_$AppDatabase, $ChallengesTable, Challenge>),
      Challenge,
      PrefetchHooks Function()
    >;
typedef $$WordleResultsTableCreateCompanionBuilder =
    WordleResultsCompanion Function({
      required String date,
      required int wordleNumber,
      Value<int?> score,
      Value<bool> completed,
      Value<bool> hardMode,
      Value<String?> grid,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$WordleResultsTableUpdateCompanionBuilder =
    WordleResultsCompanion Function({
      Value<String> date,
      Value<int> wordleNumber,
      Value<int?> score,
      Value<bool> completed,
      Value<bool> hardMode,
      Value<String?> grid,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$WordleResultsTableFilterComposer
    extends Composer<_$AppDatabase, $WordleResultsTable> {
  $$WordleResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordleNumber => $composableBuilder(
    column: $table.wordleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hardMode => $composableBuilder(
    column: $table.hardMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grid => $composableBuilder(
    column: $table.grid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordleResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordleResultsTable> {
  $$WordleResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordleNumber => $composableBuilder(
    column: $table.wordleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hardMode => $composableBuilder(
    column: $table.hardMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grid => $composableBuilder(
    column: $table.grid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordleResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordleResultsTable> {
  $$WordleResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get wordleNumber => $composableBuilder(
    column: $table.wordleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get hardMode =>
      $composableBuilder(column: $table.hardMode, builder: (column) => column);

  GeneratedColumn<String> get grid =>
      $composableBuilder(column: $table.grid, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$WordleResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordleResultsTable,
          WordleResult,
          $$WordleResultsTableFilterComposer,
          $$WordleResultsTableOrderingComposer,
          $$WordleResultsTableAnnotationComposer,
          $$WordleResultsTableCreateCompanionBuilder,
          $$WordleResultsTableUpdateCompanionBuilder,
          (
            WordleResult,
            BaseReferences<_$AppDatabase, $WordleResultsTable, WordleResult>,
          ),
          WordleResult,
          PrefetchHooks Function()
        > {
  $$WordleResultsTableTableManager(_$AppDatabase db, $WordleResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordleResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordleResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordleResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> wordleNumber = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> hardMode = const Value.absent(),
                Value<String?> grid = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordleResultsCompanion(
                date: date,
                wordleNumber: wordleNumber,
                score: score,
                completed: completed,
                hardMode: hardMode,
                grid: grid,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required int wordleNumber,
                Value<int?> score = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> hardMode = const Value.absent(),
                Value<String?> grid = const Value.absent(),
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordleResultsCompanion.insert(
                date: date,
                wordleNumber: wordleNumber,
                score: score,
                completed: completed,
                hardMode: hardMode,
                grid: grid,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordleResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordleResultsTable,
      WordleResult,
      $$WordleResultsTableFilterComposer,
      $$WordleResultsTableOrderingComposer,
      $$WordleResultsTableAnnotationComposer,
      $$WordleResultsTableCreateCompanionBuilder,
      $$WordleResultsTableUpdateCompanionBuilder,
      (
        WordleResult,
        BaseReferences<_$AppDatabase, $WordleResultsTable, WordleResult>,
      ),
      WordleResult,
      PrefetchHooks Function()
    >;
typedef $$TriviaResultsTableCreateCompanionBuilder =
    TriviaResultsCompanion Function({
      required String date,
      required String questionId,
      Value<String?> selectedAnswer,
      Value<bool> answered,
      Value<bool> correct,
      Value<DateTime?> answeredAt,
      Value<int> rowid,
    });
typedef $$TriviaResultsTableUpdateCompanionBuilder =
    TriviaResultsCompanion Function({
      Value<String> date,
      Value<String> questionId,
      Value<String?> selectedAnswer,
      Value<bool> answered,
      Value<bool> correct,
      Value<DateTime?> answeredAt,
      Value<int> rowid,
    });

class $$TriviaResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TriviaResultsTable> {
  $$TriviaResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedAnswer => $composableBuilder(
    column: $table.selectedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get answered => $composableBuilder(
    column: $table.answered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TriviaResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TriviaResultsTable> {
  $$TriviaResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedAnswer => $composableBuilder(
    column: $table.selectedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get answered => $composableBuilder(
    column: $table.answered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TriviaResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriviaResultsTable> {
  $$TriviaResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedAnswer => $composableBuilder(
    column: $table.selectedAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get answered =>
      $composableBuilder(column: $table.answered, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$TriviaResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriviaResultsTable,
          TriviaResult,
          $$TriviaResultsTableFilterComposer,
          $$TriviaResultsTableOrderingComposer,
          $$TriviaResultsTableAnnotationComposer,
          $$TriviaResultsTableCreateCompanionBuilder,
          $$TriviaResultsTableUpdateCompanionBuilder,
          (
            TriviaResult,
            BaseReferences<_$AppDatabase, $TriviaResultsTable, TriviaResult>,
          ),
          TriviaResult,
          PrefetchHooks Function()
        > {
  $$TriviaResultsTableTableManager(_$AppDatabase db, $TriviaResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriviaResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriviaResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriviaResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String?> selectedAnswer = const Value.absent(),
                Value<bool> answered = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriviaResultsCompanion(
                date: date,
                questionId: questionId,
                selectedAnswer: selectedAnswer,
                answered: answered,
                correct: correct,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String questionId,
                Value<String?> selectedAnswer = const Value.absent(),
                Value<bool> answered = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriviaResultsCompanion.insert(
                date: date,
                questionId: questionId,
                selectedAnswer: selectedAnswer,
                answered: answered,
                correct: correct,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TriviaResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriviaResultsTable,
      TriviaResult,
      $$TriviaResultsTableFilterComposer,
      $$TriviaResultsTableOrderingComposer,
      $$TriviaResultsTableAnnotationComposer,
      $$TriviaResultsTableCreateCompanionBuilder,
      $$TriviaResultsTableUpdateCompanionBuilder,
      (
        TriviaResult,
        BaseReferences<_$AppDatabase, $TriviaResultsTable, TriviaResult>,
      ),
      TriviaResult,
      PrefetchHooks Function()
    >;
typedef $$CatQuantResultsTableCreateCompanionBuilder =
    CatQuantResultsCompanion Function({
      required String date,
      required String questionId,
      required String topic,
      required String difficulty,
      Value<int?> selectedIndex,
      Value<bool> answered,
      Value<bool> correct,
      Value<DateTime?> answeredAt,
      Value<int> rowid,
    });
typedef $$CatQuantResultsTableUpdateCompanionBuilder =
    CatQuantResultsCompanion Function({
      Value<String> date,
      Value<String> questionId,
      Value<String> topic,
      Value<String> difficulty,
      Value<int?> selectedIndex,
      Value<bool> answered,
      Value<bool> correct,
      Value<DateTime?> answeredAt,
      Value<int> rowid,
    });

class $$CatQuantResultsTableFilterComposer
    extends Composer<_$AppDatabase, $CatQuantResultsTable> {
  $$CatQuantResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get answered => $composableBuilder(
    column: $table.answered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatQuantResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatQuantResultsTable> {
  $$CatQuantResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get answered => $composableBuilder(
    column: $table.answered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatQuantResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatQuantResultsTable> {
  $$CatQuantResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get answered =>
      $composableBuilder(column: $table.answered, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$CatQuantResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatQuantResultsTable,
          CatQuantResult,
          $$CatQuantResultsTableFilterComposer,
          $$CatQuantResultsTableOrderingComposer,
          $$CatQuantResultsTableAnnotationComposer,
          $$CatQuantResultsTableCreateCompanionBuilder,
          $$CatQuantResultsTableUpdateCompanionBuilder,
          (
            CatQuantResult,
            BaseReferences<
              _$AppDatabase,
              $CatQuantResultsTable,
              CatQuantResult
            >,
          ),
          CatQuantResult,
          PrefetchHooks Function()
        > {
  $$CatQuantResultsTableTableManager(
    _$AppDatabase db,
    $CatQuantResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatQuantResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatQuantResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatQuantResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int?> selectedIndex = const Value.absent(),
                Value<bool> answered = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatQuantResultsCompanion(
                date: date,
                questionId: questionId,
                topic: topic,
                difficulty: difficulty,
                selectedIndex: selectedIndex,
                answered: answered,
                correct: correct,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String questionId,
                required String topic,
                required String difficulty,
                Value<int?> selectedIndex = const Value.absent(),
                Value<bool> answered = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatQuantResultsCompanion.insert(
                date: date,
                questionId: questionId,
                topic: topic,
                difficulty: difficulty,
                selectedIndex: selectedIndex,
                answered: answered,
                correct: correct,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatQuantResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatQuantResultsTable,
      CatQuantResult,
      $$CatQuantResultsTableFilterComposer,
      $$CatQuantResultsTableOrderingComposer,
      $$CatQuantResultsTableAnnotationComposer,
      $$CatQuantResultsTableCreateCompanionBuilder,
      $$CatQuantResultsTableUpdateCompanionBuilder,
      (
        CatQuantResult,
        BaseReferences<_$AppDatabase, $CatQuantResultsTable, CatQuantResult>,
      ),
      CatQuantResult,
      PrefetchHooks Function()
    >;
typedef $$SurprisesTableCreateCompanionBuilder = SurprisesCompanion Function({
  Value<int> id,
  required String date,
  required String payload,
  required DateTime createdAt,
});
typedef $$SurprisesTableUpdateCompanionBuilder = SurprisesCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<String> payload,
  Value<DateTime> createdAt,
});

class $$SurprisesTableFilterComposer
    extends Composer<_$AppDatabase, $SurprisesTable> {
  $$SurprisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurprisesTableOrderingComposer
    extends Composer<_$AppDatabase, $SurprisesTable> {
  $$SurprisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurprisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurprisesTable> {
  $$SurprisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SurprisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SurprisesTable,
          Surprise,
          $$SurprisesTableFilterComposer,
          $$SurprisesTableOrderingComposer,
          $$SurprisesTableAnnotationComposer,
          $$SurprisesTableCreateCompanionBuilder,
          $$SurprisesTableUpdateCompanionBuilder,
          (Surprise, BaseReferences<_$AppDatabase, $SurprisesTable, Surprise>),
          Surprise,
          PrefetchHooks Function()
        > {
  $$SurprisesTableTableManager(_$AppDatabase db, $SurprisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurprisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurprisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurprisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SurprisesCompanion(
                id: id,
                date: date,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String payload,
                required DateTime createdAt,
              }) => SurprisesCompanion.insert(
                id: id,
                date: date,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurprisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SurprisesTable,
      Surprise,
      $$SurprisesTableFilterComposer,
      $$SurprisesTableOrderingComposer,
      $$SurprisesTableAnnotationComposer,
      $$SurprisesTableCreateCompanionBuilder,
      $$SurprisesTableUpdateCompanionBuilder,
      (Surprise, BaseReferences<_$AppDatabase, $SurprisesTable, Surprise>),
      Surprise,
      PrefetchHooks Function()
    >;
typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  Value<bool> completed,
  Value<int> priority,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> reminderAt,
  Value<DateTime?> completedAt,
  Value<String?> category,
  Value<int> rowid,
});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<bool> completed,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> reminderAt,
  Value<DateTime?> completedAt,
  Value<String?> category,
  Value<int> rowid,
});

class $$TodosTableFilterComposer extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTable,
          Todo,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
          Todo,
          PrefetchHooks Function()
        > {
  $$TodosTableTableManager(_$AppDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                title: title,
                description: description,
                completed: completed,
                priority: priority,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dueDate: dueDate,
                reminderAt: reminderAt,
                completedAt: completedAt,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> priority = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion.insert(
                id: id,
                title: title,
                description: description,
                completed: completed,
                priority: priority,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dueDate: dueDate,
                reminderAt: reminderAt,
                completedAt: completedAt,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTable,
      Todo,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
      Todo,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String title,
  required String date,
  Value<String?> note,
  Value<String?> emoji,
  Value<bool> pinned,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> date,
  Value<String?> note,
  Value<String?> emoji,
  Value<bool> pinned,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                title: title,
                date: date,
                note: note,
                emoji: emoji,
                pinned: pinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String date,
                Value<String?> note = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                title: title,
                date: date,
                note: note,
                emoji: emoji,
                pinned: pinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSlotsTableCreateCompanionBuilder =
    WorkoutSlotsCompanion Function({
      Value<int> weekday,
      required String focus,
      Value<int?> wgerCategory,
      required DateTime updatedAt,
    });
typedef $$WorkoutSlotsTableUpdateCompanionBuilder =
    WorkoutSlotsCompanion Function({
      Value<int> weekday,
      Value<String> focus,
      Value<int?> wgerCategory,
      Value<DateTime> updatedAt,
    });

class $$WorkoutSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSlotsTable> {
  $$WorkoutSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wgerCategory => $composableBuilder(
    column: $table.wgerCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSlotsTable> {
  $$WorkoutSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wgerCategory => $composableBuilder(
    column: $table.wgerCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSlotsTable> {
  $$WorkoutSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<int> get wgerCategory => $composableBuilder(
    column: $table.wgerCategory,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkoutSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSlotsTable,
          WorkoutSlot,
          $$WorkoutSlotsTableFilterComposer,
          $$WorkoutSlotsTableOrderingComposer,
          $$WorkoutSlotsTableAnnotationComposer,
          $$WorkoutSlotsTableCreateCompanionBuilder,
          $$WorkoutSlotsTableUpdateCompanionBuilder,
          (
            WorkoutSlot,
            BaseReferences<_$AppDatabase, $WorkoutSlotsTable, WorkoutSlot>,
          ),
          WorkoutSlot,
          PrefetchHooks Function()
        > {
  $$WorkoutSlotsTableTableManager(_$AppDatabase db, $WorkoutSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<int?> wgerCategory = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutSlotsCompanion(
                weekday: weekday,
                focus: focus,
                wgerCategory: wgerCategory,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                required String focus,
                Value<int?> wgerCategory = const Value.absent(),
                required DateTime updatedAt,
              }) => WorkoutSlotsCompanion.insert(
                weekday: weekday,
                focus: focus,
                wgerCategory: wgerCategory,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSlotsTable,
      WorkoutSlot,
      $$WorkoutSlotsTableFilterComposer,
      $$WorkoutSlotsTableOrderingComposer,
      $$WorkoutSlotsTableAnnotationComposer,
      $$WorkoutSlotsTableCreateCompanionBuilder,
      $$WorkoutSlotsTableUpdateCompanionBuilder,
      (
        WorkoutSlot,
        BaseReferences<_$AppDatabase, $WorkoutSlotsTable, WorkoutSlot>,
      ),
      WorkoutSlot,
      PrefetchHooks Function()
    >;
typedef $$WorkoutLogsTableCreateCompanionBuilder =
    WorkoutLogsCompanion Function({
      required String date,
      required String focus,
      Value<String?> done,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$WorkoutLogsTableUpdateCompanionBuilder =
    WorkoutLogsCompanion Function({
      Value<String> date,
      Value<String> focus,
      Value<String?> done,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$WorkoutLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<String> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$WorkoutLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutLogsTable,
          WorkoutLog,
          $$WorkoutLogsTableFilterComposer,
          $$WorkoutLogsTableOrderingComposer,
          $$WorkoutLogsTableAnnotationComposer,
          $$WorkoutLogsTableCreateCompanionBuilder,
          $$WorkoutLogsTableUpdateCompanionBuilder,
          (
            WorkoutLog,
            BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLog>,
          ),
          WorkoutLog,
          PrefetchHooks Function()
        > {
  $$WorkoutLogsTableTableManager(_$AppDatabase db, $WorkoutLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<String?> done = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogsCompanion(
                date: date,
                focus: focus,
                done: done,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String focus,
                Value<String?> done = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogsCompanion.insert(
                date: date,
                focus: focus,
                done: done,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutLogsTable,
      WorkoutLog,
      $$WorkoutLogsTableFilterComposer,
      $$WorkoutLogsTableOrderingComposer,
      $$WorkoutLogsTableAnnotationComposer,
      $$WorkoutLogsTableCreateCompanionBuilder,
      $$WorkoutLogsTableUpdateCompanionBuilder,
      (
        WorkoutLog,
        BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLog>,
      ),
      WorkoutLog,
      PrefetchHooks Function()
    >;
typedef $$GameScoresTableCreateCompanionBuilder = GameScoresCompanion Function({
  Value<int> id,
  required String game,
  required int score,
  Value<String?> detail,
  required String date,
  required DateTime playedAt,
});
typedef $$GameScoresTableUpdateCompanionBuilder = GameScoresCompanion Function({
  Value<int> id,
  Value<String> game,
  Value<int> score,
  Value<String?> detail,
  Value<String> date,
  Value<DateTime> playedAt,
});

class $$GameScoresTableFilterComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$GameScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameScoresTable,
          GameScore,
          $$GameScoresTableFilterComposer,
          $$GameScoresTableOrderingComposer,
          $$GameScoresTableAnnotationComposer,
          $$GameScoresTableCreateCompanionBuilder,
          $$GameScoresTableUpdateCompanionBuilder,
          (
            GameScore,
            BaseReferences<_$AppDatabase, $GameScoresTable, GameScore>,
          ),
          GameScore,
          PrefetchHooks Function()
        > {
  $$GameScoresTableTableManager(_$AppDatabase db, $GameScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => GameScoresCompanion(
                id: id,
                game: game,
                score: score,
                detail: detail,
                date: date,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String game,
                required int score,
                Value<String?> detail = const Value.absent(),
                required String date,
                required DateTime playedAt,
              }) => GameScoresCompanion.insert(
                id: id,
                game: game,
                score: score,
                detail: detail,
                date: date,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameScoresTable,
      GameScore,
      $$GameScoresTableFilterComposer,
      $$GameScoresTableOrderingComposer,
      $$GameScoresTableAnnotationComposer,
      $$GameScoresTableCreateCompanionBuilder,
      $$GameScoresTableUpdateCompanionBuilder,
      (GameScore, BaseReferences<_$AppDatabase, $GameScoresTable, GameScore>),
      GameScore,
      PrefetchHooks Function()
    >;
typedef $$PuzzleStatesTableCreateCompanionBuilder =
    PuzzleStatesCompanion Function({
      required String game,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PuzzleStatesTableUpdateCompanionBuilder =
    PuzzleStatesCompanion Function({
      Value<String> game,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PuzzleStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PuzzleStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleStatesTable,
          PuzzleState,
          $$PuzzleStatesTableFilterComposer,
          $$PuzzleStatesTableOrderingComposer,
          $$PuzzleStatesTableAnnotationComposer,
          $$PuzzleStatesTableCreateCompanionBuilder,
          $$PuzzleStatesTableUpdateCompanionBuilder,
          (
            PuzzleState,
            BaseReferences<_$AppDatabase, $PuzzleStatesTable, PuzzleState>,
          ),
          PuzzleState,
          PrefetchHooks Function()
        > {
  $$PuzzleStatesTableTableManager(_$AppDatabase db, $PuzzleStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuzzleStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> game = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PuzzleStatesCompanion(
                game: game,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String game,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PuzzleStatesCompanion.insert(
                game: game,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleStatesTable,
      PuzzleState,
      $$PuzzleStatesTableFilterComposer,
      $$PuzzleStatesTableOrderingComposer,
      $$PuzzleStatesTableAnnotationComposer,
      $$PuzzleStatesTableCreateCompanionBuilder,
      $$PuzzleStatesTableUpdateCompanionBuilder,
      (
        PuzzleState,
        BaseReferences<_$AppDatabase, $PuzzleStatesTable, PuzzleState>,
      ),
      PuzzleState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyStatesTableTableManager get dailyStates =>
      $$DailyStatesTableTableManager(_db, _db.dailyStates);
  $$DailyContentsTableTableManager get dailyContents =>
      $$DailyContentsTableTableManager(_db, _db.dailyContents);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db, _db.challenges);
  $$WordleResultsTableTableManager get wordleResults =>
      $$WordleResultsTableTableManager(_db, _db.wordleResults);
  $$TriviaResultsTableTableManager get triviaResults =>
      $$TriviaResultsTableTableManager(_db, _db.triviaResults);
  $$CatQuantResultsTableTableManager get catQuantResults =>
      $$CatQuantResultsTableTableManager(_db, _db.catQuantResults);
  $$SurprisesTableTableManager get surprises =>
      $$SurprisesTableTableManager(_db, _db.surprises);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$WorkoutSlotsTableTableManager get workoutSlots =>
      $$WorkoutSlotsTableTableManager(_db, _db.workoutSlots);
  $$WorkoutLogsTableTableManager get workoutLogs =>
      $$WorkoutLogsTableTableManager(_db, _db.workoutLogs);
  $$GameScoresTableTableManager get gameScores =>
      $$GameScoresTableTableManager(_db, _db.gameScores);
  $$PuzzleStatesTableTableManager get puzzleStates =>
      $$PuzzleStatesTableTableManager(_db, _db.puzzleStates);
}
