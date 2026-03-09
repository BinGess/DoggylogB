// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CalendarEntriesTableTable extends CalendarEntriesTable
    with TableInfo<$CalendarEntriesTableTable, CalendarEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEntriesTableTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindersJsonMeta = const VerificationMeta(
    'remindersJson',
  );
  @override
  late final GeneratedColumn<String> remindersJson = GeneratedColumn<String>(
    'reminders_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemEntryIdMeta = const VerificationMeta(
    'systemEntryId',
  );
  @override
  late final GeneratedColumn<String> systemEntryId = GeneratedColumn<String>(
    'system_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    startAt,
    endAt,
    category,
    petId,
    remindersJson,
    source,
    createdAt,
    updatedAt,
    systemEntryId,
    isCompleted,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEntriesTableData> instance, {
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
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    }
    if (data.containsKey('reminders_json')) {
      context.handle(
        _remindersJsonMeta,
        remindersJson.isAcceptableOrUnknown(
          data['reminders_json']!,
          _remindersJsonMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
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
    if (data.containsKey('system_entry_id')) {
      context.handle(
        _systemEntryIdMeta,
        systemEntryId.isAcceptableOrUnknown(
          data['system_entry_id']!,
          _systemEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEntriesTableData(
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
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      ),
      remindersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      systemEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_entry_id'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CalendarEntriesTableTable createAlias(String alias) {
    return $CalendarEntriesTableTable(attachedDatabase, alias);
  }
}

class CalendarEntriesTableData extends DataClass
    implements Insertable<CalendarEntriesTableData> {
  final String id;
  final String title;
  final String description;
  final int startAt;
  final int endAt;
  final String category;
  final String? petId;
  final String remindersJson;
  final String source;
  final int createdAt;
  final int updatedAt;
  final String? systemEntryId;
  final bool isCompleted;
  final bool isDeleted;
  const CalendarEntriesTableData({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.category,
    this.petId,
    required this.remindersJson,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.systemEntryId,
    required this.isCompleted,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['start_at'] = Variable<int>(startAt);
    map['end_at'] = Variable<int>(endAt);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || petId != null) {
      map['pet_id'] = Variable<String>(petId);
    }
    map['reminders_json'] = Variable<String>(remindersJson);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || systemEntryId != null) {
      map['system_entry_id'] = Variable<String>(systemEntryId);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CalendarEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return CalendarEntriesTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      startAt: Value(startAt),
      endAt: Value(endAt),
      category: Value(category),
      petId: petId == null && nullToAbsent
          ? const Value.absent()
          : Value(petId),
      remindersJson: Value(remindersJson),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      systemEntryId: systemEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemEntryId),
      isCompleted: Value(isCompleted),
      isDeleted: Value(isDeleted),
    );
  }

  factory CalendarEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int>(json['endAt']),
      category: serializer.fromJson<String>(json['category']),
      petId: serializer.fromJson<String?>(json['petId']),
      remindersJson: serializer.fromJson<String>(json['remindersJson']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      systemEntryId: serializer.fromJson<String?>(json['systemEntryId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int>(endAt),
      'category': serializer.toJson<String>(category),
      'petId': serializer.toJson<String?>(petId),
      'remindersJson': serializer.toJson<String>(remindersJson),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'systemEntryId': serializer.toJson<String?>(systemEntryId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CalendarEntriesTableData copyWith({
    String? id,
    String? title,
    String? description,
    int? startAt,
    int? endAt,
    String? category,
    Value<String?> petId = const Value.absent(),
    String? remindersJson,
    String? source,
    int? createdAt,
    int? updatedAt,
    Value<String?> systemEntryId = const Value.absent(),
    bool? isCompleted,
    bool? isDeleted,
  }) => CalendarEntriesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    category: category ?? this.category,
    petId: petId.present ? petId.value : this.petId,
    remindersJson: remindersJson ?? this.remindersJson,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    systemEntryId: systemEntryId.present
        ? systemEntryId.value
        : this.systemEntryId,
    isCompleted: isCompleted ?? this.isCompleted,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  CalendarEntriesTableData copyWithCompanion(
    CalendarEntriesTableCompanion data,
  ) {
    return CalendarEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      category: data.category.present ? data.category.value : this.category,
      petId: data.petId.present ? data.petId.value : this.petId,
      remindersJson: data.remindersJson.present
          ? data.remindersJson.value
          : this.remindersJson,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      systemEntryId: data.systemEntryId.present
          ? data.systemEntryId.value
          : this.systemEntryId,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntriesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('category: $category, ')
          ..write('petId: $petId, ')
          ..write('remindersJson: $remindersJson, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('systemEntryId: $systemEntryId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    startAt,
    endAt,
    category,
    petId,
    remindersJson,
    source,
    createdAt,
    updatedAt,
    systemEntryId,
    isCompleted,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEntriesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.category == this.category &&
          other.petId == this.petId &&
          other.remindersJson == this.remindersJson &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.systemEntryId == this.systemEntryId &&
          other.isCompleted == this.isCompleted &&
          other.isDeleted == this.isDeleted);
}

class CalendarEntriesTableCompanion
    extends UpdateCompanion<CalendarEntriesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> startAt;
  final Value<int> endAt;
  final Value<String> category;
  final Value<String?> petId;
  final Value<String> remindersJson;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> systemEntryId;
  final Value<bool> isCompleted;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CalendarEntriesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.category = const Value.absent(),
    this.petId = const Value.absent(),
    this.remindersJson = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.systemEntryId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEntriesTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required int startAt,
    required int endAt,
    required String category,
    this.petId = const Value.absent(),
    this.remindersJson = const Value.absent(),
    required String source,
    required int createdAt,
    required int updatedAt,
    this.systemEntryId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       startAt = Value(startAt),
       endAt = Value(endAt),
       category = Value(category),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CalendarEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<String>? category,
    Expression<String>? petId,
    Expression<String>? remindersJson,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? systemEntryId,
    Expression<bool>? isCompleted,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (category != null) 'category': category,
      if (petId != null) 'pet_id': petId,
      if (remindersJson != null) 'reminders_json': remindersJson,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (systemEntryId != null) 'system_entry_id': systemEntryId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? startAt,
    Value<int>? endAt,
    Value<String>? category,
    Value<String?>? petId,
    Value<String>? remindersJson,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? systemEntryId,
    Value<bool>? isCompleted,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CalendarEntriesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      category: category ?? this.category,
      petId: petId ?? this.petId,
      remindersJson: remindersJson ?? this.remindersJson,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      systemEntryId: systemEntryId ?? this.systemEntryId,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (remindersJson.present) {
      map['reminders_json'] = Variable<String>(remindersJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (systemEntryId.present) {
      map['system_entry_id'] = Variable<String>(systemEntryId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('category: $category, ')
          ..write('petId: $petId, ')
          ..write('remindersJson: $remindersJson, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('systemEntryId: $systemEntryId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PetProfilesTableTable extends PetProfilesTable
    with TableInfo<$PetProfilesTableTable, PetProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loyaltyPointsMeta = const VerificationMeta(
    'loyaltyPoints',
  );
  @override
  late final GeneratedColumn<int> loyaltyPoints = GeneratedColumn<int>(
    'loyalty_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _selectedSkinIdMeta = const VerificationMeta(
    'selectedSkinId',
  );
  @override
  late final GeneratedColumn<String> selectedSkinId = GeneratedColumn<String>(
    'selected_skin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedSkinIdsJsonMeta =
      const VerificationMeta('unlockedSkinIdsJson');
  @override
  late final GeneratedColumn<String> unlockedSkinIdsJson =
      GeneratedColumn<String>(
        'unlocked_skin_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSelectedMeta = const VerificationMeta(
    'isSelected',
  );
  @override
  late final GeneratedColumn<bool> isSelected = GeneratedColumn<bool>(
    'is_selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_selected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    breed,
    loyaltyPoints,
    selectedSkinId,
    unlockedSkinIdsJson,
    createdAt,
    isSelected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pet_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PetProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('loyalty_points')) {
      context.handle(
        _loyaltyPointsMeta,
        loyaltyPoints.isAcceptableOrUnknown(
          data['loyalty_points']!,
          _loyaltyPointsMeta,
        ),
      );
    }
    if (data.containsKey('selected_skin_id')) {
      context.handle(
        _selectedSkinIdMeta,
        selectedSkinId.isAcceptableOrUnknown(
          data['selected_skin_id']!,
          _selectedSkinIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedSkinIdMeta);
    }
    if (data.containsKey('unlocked_skin_ids_json')) {
      context.handle(
        _unlockedSkinIdsJsonMeta,
        unlockedSkinIdsJson.isAcceptableOrUnknown(
          data['unlocked_skin_ids_json']!,
          _unlockedSkinIdsJsonMeta,
        ),
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
    if (data.containsKey('is_selected')) {
      context.handle(
        _isSelectedMeta,
        isSelected.isAcceptableOrUnknown(data['is_selected']!, _isSelectedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PetProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PetProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      )!,
      loyaltyPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loyalty_points'],
      )!,
      selectedSkinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_skin_id'],
      )!,
      unlockedSkinIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlocked_skin_ids_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_selected'],
      )!,
    );
  }

  @override
  $PetProfilesTableTable createAlias(String alias) {
    return $PetProfilesTableTable(attachedDatabase, alias);
  }
}

class PetProfilesTableData extends DataClass
    implements Insertable<PetProfilesTableData> {
  final String id;
  final String name;
  final String breed;
  final int loyaltyPoints;
  final String selectedSkinId;
  final String unlockedSkinIdsJson;
  final int createdAt;
  final bool isSelected;
  const PetProfilesTableData({
    required this.id,
    required this.name,
    required this.breed,
    required this.loyaltyPoints,
    required this.selectedSkinId,
    required this.unlockedSkinIdsJson,
    required this.createdAt,
    required this.isSelected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['breed'] = Variable<String>(breed);
    map['loyalty_points'] = Variable<int>(loyaltyPoints);
    map['selected_skin_id'] = Variable<String>(selectedSkinId);
    map['unlocked_skin_ids_json'] = Variable<String>(unlockedSkinIdsJson);
    map['created_at'] = Variable<int>(createdAt);
    map['is_selected'] = Variable<bool>(isSelected);
    return map;
  }

  PetProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return PetProfilesTableCompanion(
      id: Value(id),
      name: Value(name),
      breed: Value(breed),
      loyaltyPoints: Value(loyaltyPoints),
      selectedSkinId: Value(selectedSkinId),
      unlockedSkinIdsJson: Value(unlockedSkinIdsJson),
      createdAt: Value(createdAt),
      isSelected: Value(isSelected),
    );
  }

  factory PetProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PetProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      breed: serializer.fromJson<String>(json['breed']),
      loyaltyPoints: serializer.fromJson<int>(json['loyaltyPoints']),
      selectedSkinId: serializer.fromJson<String>(json['selectedSkinId']),
      unlockedSkinIdsJson: serializer.fromJson<String>(
        json['unlockedSkinIdsJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isSelected: serializer.fromJson<bool>(json['isSelected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'breed': serializer.toJson<String>(breed),
      'loyaltyPoints': serializer.toJson<int>(loyaltyPoints),
      'selectedSkinId': serializer.toJson<String>(selectedSkinId),
      'unlockedSkinIdsJson': serializer.toJson<String>(unlockedSkinIdsJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'isSelected': serializer.toJson<bool>(isSelected),
    };
  }

  PetProfilesTableData copyWith({
    String? id,
    String? name,
    String? breed,
    int? loyaltyPoints,
    String? selectedSkinId,
    String? unlockedSkinIdsJson,
    int? createdAt,
    bool? isSelected,
  }) => PetProfilesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    breed: breed ?? this.breed,
    loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    selectedSkinId: selectedSkinId ?? this.selectedSkinId,
    unlockedSkinIdsJson: unlockedSkinIdsJson ?? this.unlockedSkinIdsJson,
    createdAt: createdAt ?? this.createdAt,
    isSelected: isSelected ?? this.isSelected,
  );
  PetProfilesTableData copyWithCompanion(PetProfilesTableCompanion data) {
    return PetProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      breed: data.breed.present ? data.breed.value : this.breed,
      loyaltyPoints: data.loyaltyPoints.present
          ? data.loyaltyPoints.value
          : this.loyaltyPoints,
      selectedSkinId: data.selectedSkinId.present
          ? data.selectedSkinId.value
          : this.selectedSkinId,
      unlockedSkinIdsJson: data.unlockedSkinIdsJson.present
          ? data.unlockedSkinIdsJson.value
          : this.unlockedSkinIdsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSelected: data.isSelected.present
          ? data.isSelected.value
          : this.isSelected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PetProfilesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('selectedSkinId: $selectedSkinId, ')
          ..write('unlockedSkinIdsJson: $unlockedSkinIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSelected: $isSelected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    breed,
    loyaltyPoints,
    selectedSkinId,
    unlockedSkinIdsJson,
    createdAt,
    isSelected,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PetProfilesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.breed == this.breed &&
          other.loyaltyPoints == this.loyaltyPoints &&
          other.selectedSkinId == this.selectedSkinId &&
          other.unlockedSkinIdsJson == this.unlockedSkinIdsJson &&
          other.createdAt == this.createdAt &&
          other.isSelected == this.isSelected);
}

class PetProfilesTableCompanion extends UpdateCompanion<PetProfilesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> breed;
  final Value<int> loyaltyPoints;
  final Value<String> selectedSkinId;
  final Value<String> unlockedSkinIdsJson;
  final Value<int> createdAt;
  final Value<bool> isSelected;
  final Value<int> rowid;
  const PetProfilesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.breed = const Value.absent(),
    this.loyaltyPoints = const Value.absent(),
    this.selectedSkinId = const Value.absent(),
    this.unlockedSkinIdsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PetProfilesTableCompanion.insert({
    required String id,
    required String name,
    required String breed,
    this.loyaltyPoints = const Value.absent(),
    required String selectedSkinId,
    this.unlockedSkinIdsJson = const Value.absent(),
    required int createdAt,
    this.isSelected = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       breed = Value(breed),
       selectedSkinId = Value(selectedSkinId),
       createdAt = Value(createdAt);
  static Insertable<PetProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? breed,
    Expression<int>? loyaltyPoints,
    Expression<String>? selectedSkinId,
    Expression<String>? unlockedSkinIdsJson,
    Expression<int>? createdAt,
    Expression<bool>? isSelected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (breed != null) 'breed': breed,
      if (loyaltyPoints != null) 'loyalty_points': loyaltyPoints,
      if (selectedSkinId != null) 'selected_skin_id': selectedSkinId,
      if (unlockedSkinIdsJson != null)
        'unlocked_skin_ids_json': unlockedSkinIdsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (isSelected != null) 'is_selected': isSelected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PetProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? breed,
    Value<int>? loyaltyPoints,
    Value<String>? selectedSkinId,
    Value<String>? unlockedSkinIdsJson,
    Value<int>? createdAt,
    Value<bool>? isSelected,
    Value<int>? rowid,
  }) {
    return PetProfilesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      unlockedSkinIdsJson: unlockedSkinIdsJson ?? this.unlockedSkinIdsJson,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (loyaltyPoints.present) {
      map['loyalty_points'] = Variable<int>(loyaltyPoints.value);
    }
    if (selectedSkinId.present) {
      map['selected_skin_id'] = Variable<String>(selectedSkinId.value);
    }
    if (unlockedSkinIdsJson.present) {
      map['unlocked_skin_ids_json'] = Variable<String>(
        unlockedSkinIdsJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isSelected.present) {
      map['is_selected'] = Variable<bool>(isSelected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('loyaltyPoints: $loyaltyPoints, ')
          ..write('selectedSkinId: $selectedSkinId, ')
          ..write('unlockedSkinIdsJson: $unlockedSkinIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSelected: $isSelected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountdownItemsTableTable extends CountdownItemsTable
    with TableInfo<$CountdownItemsTableTable, CountdownItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountdownItemsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasCelebratedMeta = const VerificationMeta(
    'hasCelebrated',
  );
  @override
  late final GeneratedColumn<bool> hasCelebrated = GeneratedColumn<bool>(
    'has_celebrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_celebrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    dueAt,
    createdAt,
    petId,
    isPinned,
    hasCelebrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countdown_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountdownItemsTableData> instance, {
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
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('has_celebrated')) {
      context.handle(
        _hasCelebratedMeta,
        hasCelebrated.isAcceptableOrUnknown(
          data['has_celebrated']!,
          _hasCelebratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CountdownItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountdownItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      hasCelebrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_celebrated'],
      )!,
    );
  }

  @override
  $CountdownItemsTableTable createAlias(String alias) {
    return $CountdownItemsTableTable(attachedDatabase, alias);
  }
}

class CountdownItemsTableData extends DataClass
    implements Insertable<CountdownItemsTableData> {
  final String id;
  final String title;
  final int dueAt;
  final int createdAt;
  final String? petId;
  final bool isPinned;
  final bool hasCelebrated;
  const CountdownItemsTableData({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.createdAt,
    this.petId,
    required this.isPinned,
    required this.hasCelebrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['due_at'] = Variable<int>(dueAt);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || petId != null) {
      map['pet_id'] = Variable<String>(petId);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['has_celebrated'] = Variable<bool>(hasCelebrated);
    return map;
  }

  CountdownItemsTableCompanion toCompanion(bool nullToAbsent) {
    return CountdownItemsTableCompanion(
      id: Value(id),
      title: Value(title),
      dueAt: Value(dueAt),
      createdAt: Value(createdAt),
      petId: petId == null && nullToAbsent
          ? const Value.absent()
          : Value(petId),
      isPinned: Value(isPinned),
      hasCelebrated: Value(hasCelebrated),
    );
  }

  factory CountdownItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountdownItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      dueAt: serializer.fromJson<int>(json['dueAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      petId: serializer.fromJson<String?>(json['petId']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      hasCelebrated: serializer.fromJson<bool>(json['hasCelebrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'dueAt': serializer.toJson<int>(dueAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'petId': serializer.toJson<String?>(petId),
      'isPinned': serializer.toJson<bool>(isPinned),
      'hasCelebrated': serializer.toJson<bool>(hasCelebrated),
    };
  }

  CountdownItemsTableData copyWith({
    String? id,
    String? title,
    int? dueAt,
    int? createdAt,
    Value<String?> petId = const Value.absent(),
    bool? isPinned,
    bool? hasCelebrated,
  }) => CountdownItemsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    dueAt: dueAt ?? this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    petId: petId.present ? petId.value : this.petId,
    isPinned: isPinned ?? this.isPinned,
    hasCelebrated: hasCelebrated ?? this.hasCelebrated,
  );
  CountdownItemsTableData copyWithCompanion(CountdownItemsTableCompanion data) {
    return CountdownItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      petId: data.petId.present ? data.petId.value : this.petId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      hasCelebrated: data.hasCelebrated.present
          ? data.hasCelebrated.value
          : this.hasCelebrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountdownItemsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('petId: $petId, ')
          ..write('isPinned: $isPinned, ')
          ..write('hasCelebrated: $hasCelebrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, dueAt, createdAt, petId, isPinned, hasCelebrated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountdownItemsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.petId == this.petId &&
          other.isPinned == this.isPinned &&
          other.hasCelebrated == this.hasCelebrated);
}

class CountdownItemsTableCompanion
    extends UpdateCompanion<CountdownItemsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> dueAt;
  final Value<int> createdAt;
  final Value<String?> petId;
  final Value<bool> isPinned;
  final Value<bool> hasCelebrated;
  final Value<int> rowid;
  const CountdownItemsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.petId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.hasCelebrated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountdownItemsTableCompanion.insert({
    required String id,
    required String title,
    required int dueAt,
    required int createdAt,
    this.petId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.hasCelebrated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       dueAt = Value(dueAt),
       createdAt = Value(createdAt);
  static Insertable<CountdownItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? dueAt,
    Expression<int>? createdAt,
    Expression<String>? petId,
    Expression<bool>? isPinned,
    Expression<bool>? hasCelebrated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (petId != null) 'pet_id': petId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (hasCelebrated != null) 'has_celebrated': hasCelebrated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountdownItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? dueAt,
    Value<int>? createdAt,
    Value<String?>? petId,
    Value<bool>? isPinned,
    Value<bool>? hasCelebrated,
    Value<int>? rowid,
  }) {
    return CountdownItemsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      petId: petId ?? this.petId,
      isPinned: isPinned ?? this.isPinned,
      hasCelebrated: hasCelebrated ?? this.hasCelebrated,
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
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (hasCelebrated.present) {
      map['has_celebrated'] = Variable<bool>(hasCelebrated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountdownItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('petId: $petId, ')
          ..write('isPinned: $isPinned, ')
          ..write('hasCelebrated: $hasCelebrated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoyaltyLedgersTableTable extends LoyaltyLedgersTable
    with TableInfo<$LoyaltyLedgersTableTable, LoyaltyLedgersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoyaltyLedgersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calendarItemIdMeta = const VerificationMeta(
    'calendarItemId',
  );
  @override
  late final GeneratedColumn<String> calendarItemId = GeneratedColumn<String>(
    'calendar_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    calendarItemId,
    points,
    createdAt,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loyalty_ledgers_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoyaltyLedgersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('calendar_item_id')) {
      context.handle(
        _calendarItemIdMeta,
        calendarItemId.isAcceptableOrUnknown(
          data['calendar_item_id']!,
          _calendarItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarItemIdMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoyaltyLedgersTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoyaltyLedgersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      calendarItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_item_id'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $LoyaltyLedgersTableTable createAlias(String alias) {
    return $LoyaltyLedgersTableTable(attachedDatabase, alias);
  }
}

class LoyaltyLedgersTableData extends DataClass
    implements Insertable<LoyaltyLedgersTableData> {
  final String id;
  final String petId;
  final String calendarItemId;
  final int points;
  final int createdAt;
  final String reason;
  const LoyaltyLedgersTableData({
    required this.id,
    required this.petId,
    required this.calendarItemId,
    required this.points,
    required this.createdAt,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pet_id'] = Variable<String>(petId);
    map['calendar_item_id'] = Variable<String>(calendarItemId);
    map['points'] = Variable<int>(points);
    map['created_at'] = Variable<int>(createdAt);
    map['reason'] = Variable<String>(reason);
    return map;
  }

  LoyaltyLedgersTableCompanion toCompanion(bool nullToAbsent) {
    return LoyaltyLedgersTableCompanion(
      id: Value(id),
      petId: Value(petId),
      calendarItemId: Value(calendarItemId),
      points: Value(points),
      createdAt: Value(createdAt),
      reason: Value(reason),
    );
  }

  factory LoyaltyLedgersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoyaltyLedgersTableData(
      id: serializer.fromJson<String>(json['id']),
      petId: serializer.fromJson<String>(json['petId']),
      calendarItemId: serializer.fromJson<String>(json['calendarItemId']),
      points: serializer.fromJson<int>(json['points']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'petId': serializer.toJson<String>(petId),
      'calendarItemId': serializer.toJson<String>(calendarItemId),
      'points': serializer.toJson<int>(points),
      'createdAt': serializer.toJson<int>(createdAt),
      'reason': serializer.toJson<String>(reason),
    };
  }

  LoyaltyLedgersTableData copyWith({
    String? id,
    String? petId,
    String? calendarItemId,
    int? points,
    int? createdAt,
    String? reason,
  }) => LoyaltyLedgersTableData(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    calendarItemId: calendarItemId ?? this.calendarItemId,
    points: points ?? this.points,
    createdAt: createdAt ?? this.createdAt,
    reason: reason ?? this.reason,
  );
  LoyaltyLedgersTableData copyWithCompanion(LoyaltyLedgersTableCompanion data) {
    return LoyaltyLedgersTableData(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      calendarItemId: data.calendarItemId.present
          ? data.calendarItemId.value
          : this.calendarItemId,
      points: data.points.present ? data.points.value : this.points,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyLedgersTableData(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('calendarItemId: $calendarItemId, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, petId, calendarItemId, points, createdAt, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoyaltyLedgersTableData &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.calendarItemId == this.calendarItemId &&
          other.points == this.points &&
          other.createdAt == this.createdAt &&
          other.reason == this.reason);
}

class LoyaltyLedgersTableCompanion
    extends UpdateCompanion<LoyaltyLedgersTableData> {
  final Value<String> id;
  final Value<String> petId;
  final Value<String> calendarItemId;
  final Value<int> points;
  final Value<int> createdAt;
  final Value<String> reason;
  final Value<int> rowid;
  const LoyaltyLedgersTableCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.calendarItemId = const Value.absent(),
    this.points = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoyaltyLedgersTableCompanion.insert({
    required String id,
    required String petId,
    required String calendarItemId,
    required int points,
    required int createdAt,
    required String reason,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       petId = Value(petId),
       calendarItemId = Value(calendarItemId),
       points = Value(points),
       createdAt = Value(createdAt),
       reason = Value(reason);
  static Insertable<LoyaltyLedgersTableData> custom({
    Expression<String>? id,
    Expression<String>? petId,
    Expression<String>? calendarItemId,
    Expression<int>? points,
    Expression<int>? createdAt,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (calendarItemId != null) 'calendar_item_id': calendarItemId,
      if (points != null) 'points': points,
      if (createdAt != null) 'created_at': createdAt,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoyaltyLedgersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? petId,
    Value<String>? calendarItemId,
    Value<int>? points,
    Value<int>? createdAt,
    Value<String>? reason,
    Value<int>? rowid,
  }) {
    return LoyaltyLedgersTableCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      calendarItemId: calendarItemId ?? this.calendarItemId,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (calendarItemId.present) {
      map['calendar_item_id'] = Variable<String>(calendarItemId.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyLedgersTableCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('calendarItemId: $calendarItemId, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeofencePlacesTableTable extends GeofencePlacesTable
    with TableInfo<$GeofencePlacesTableTable, GeofencePlacesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeofencePlacesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sceneModeMeta = const VerificationMeta(
    'sceneMode',
  );
  @override
  late final GeneratedColumn<String> sceneMode = GeneratedColumn<String>(
    'scene_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    radiusMeters,
    sceneMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geofence_places_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeofencePlacesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_radiusMetersMeta);
    }
    if (data.containsKey('scene_mode')) {
      context.handle(
        _sceneModeMeta,
        sceneMode.isAcceptableOrUnknown(data['scene_mode']!, _sceneModeMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeofencePlacesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeofencePlacesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      )!,
      sceneMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_mode'],
      )!,
    );
  }

  @override
  $GeofencePlacesTableTable createAlias(String alias) {
    return $GeofencePlacesTableTable(attachedDatabase, alias);
  }
}

class GeofencePlacesTableData extends DataClass
    implements Insertable<GeofencePlacesTableData> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String sceneMode;
  const GeofencePlacesTableData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.sceneMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['radius_meters'] = Variable<double>(radiusMeters);
    map['scene_mode'] = Variable<String>(sceneMode);
    return map;
  }

  GeofencePlacesTableCompanion toCompanion(bool nullToAbsent) {
    return GeofencePlacesTableCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      radiusMeters: Value(radiusMeters),
      sceneMode: Value(sceneMode),
    );
  }

  factory GeofencePlacesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeofencePlacesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      radiusMeters: serializer.fromJson<double>(json['radiusMeters']),
      sceneMode: serializer.fromJson<String>(json['sceneMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'radiusMeters': serializer.toJson<double>(radiusMeters),
      'sceneMode': serializer.toJson<String>(sceneMode),
    };
  }

  GeofencePlacesTableData copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? sceneMode,
  }) => GeofencePlacesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    sceneMode: sceneMode ?? this.sceneMode,
  );
  GeofencePlacesTableData copyWithCompanion(GeofencePlacesTableCompanion data) {
    return GeofencePlacesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      sceneMode: data.sceneMode.present ? data.sceneMode.value : this.sceneMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeofencePlacesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('sceneMode: $sceneMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, latitude, longitude, radiusMeters, sceneMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeofencePlacesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusMeters == this.radiusMeters &&
          other.sceneMode == this.sceneMode);
}

class GeofencePlacesTableCompanion
    extends UpdateCompanion<GeofencePlacesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> radiusMeters;
  final Value<String> sceneMode;
  final Value<int> rowid;
  const GeofencePlacesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.sceneMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeofencePlacesTableCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required String sceneMode,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       radiusMeters = Value(radiusMeters),
       sceneMode = Value(sceneMode);
  static Insertable<GeofencePlacesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radiusMeters,
    Expression<String>? sceneMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (sceneMode != null) 'scene_mode': sceneMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeofencePlacesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? radiusMeters,
    Value<String>? sceneMode,
    Value<int>? rowid,
  }) {
    return GeofencePlacesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      sceneMode: sceneMode ?? this.sceneMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (sceneMode.present) {
      map['scene_mode'] = Variable<String>(sceneMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeofencePlacesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('sceneMode: $sceneMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTableTable extends PreferencesTable
    with TableInfo<$PreferencesTableTable, PreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferencesTableData> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PreferencesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferencesTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTableTable createAlias(String alias) {
    return $PreferencesTableTable(attachedDatabase, alias);
  }
}

class PreferencesTableData extends DataClass
    implements Insertable<PreferencesTableData> {
  final String key;
  final String value;
  const PreferencesTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return PreferencesTableCompanion(key: Value(key), value: Value(value));
  }

  factory PreferencesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferencesTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  PreferencesTableData copyWith({String? key, String? value}) =>
      PreferencesTableData(key: key ?? this.key, value: value ?? this.value);
  PreferencesTableData copyWithCompanion(PreferencesTableCompanion data) {
    return PreferencesTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferencesTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesTableCompanion extends UpdateCompanion<PreferencesTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<PreferencesTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CalendarEntriesTableTable calendarEntriesTable =
      $CalendarEntriesTableTable(this);
  late final $PetProfilesTableTable petProfilesTable = $PetProfilesTableTable(
    this,
  );
  late final $CountdownItemsTableTable countdownItemsTable =
      $CountdownItemsTableTable(this);
  late final $LoyaltyLedgersTableTable loyaltyLedgersTable =
      $LoyaltyLedgersTableTable(this);
  late final $GeofencePlacesTableTable geofencePlacesTable =
      $GeofencePlacesTableTable(this);
  late final $PreferencesTableTable preferencesTable = $PreferencesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    calendarEntriesTable,
    petProfilesTable,
    countdownItemsTable,
    loyaltyLedgersTable,
    geofencePlacesTable,
    preferencesTable,
  ];
}

typedef $$CalendarEntriesTableTableCreateCompanionBuilder =
    CalendarEntriesTableCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      required int startAt,
      required int endAt,
      required String category,
      Value<String?> petId,
      Value<String> remindersJson,
      required String source,
      required int createdAt,
      required int updatedAt,
      Value<String?> systemEntryId,
      Value<bool> isCompleted,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CalendarEntriesTableTableUpdateCompanionBuilder =
    CalendarEntriesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<int> startAt,
      Value<int> endAt,
      Value<String> category,
      Value<String?> petId,
      Value<String> remindersJson,
      Value<String> source,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> systemEntryId,
      Value<bool> isCompleted,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$CalendarEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEntriesTableTable> {
  $$CalendarEntriesTableTableFilterComposer({
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

  ColumnFilters<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemEntryId => $composableBuilder(
    column: $table.systemEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEntriesTableTable> {
  $$CalendarEntriesTableTableOrderingComposer({
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

  ColumnOrderings<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemEntryId => $composableBuilder(
    column: $table.systemEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEntriesTableTable> {
  $$CalendarEntriesTableTableAnnotationComposer({
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

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get systemEntryId => $composableBuilder(
    column: $table.systemEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CalendarEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEntriesTableTable,
          CalendarEntriesTableData,
          $$CalendarEntriesTableTableFilterComposer,
          $$CalendarEntriesTableTableOrderingComposer,
          $$CalendarEntriesTableTableAnnotationComposer,
          $$CalendarEntriesTableTableCreateCompanionBuilder,
          $$CalendarEntriesTableTableUpdateCompanionBuilder,
          (
            CalendarEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $CalendarEntriesTableTable,
              CalendarEntriesTableData
            >,
          ),
          CalendarEntriesTableData,
          PrefetchHooks Function()
        > {
  $$CalendarEntriesTableTableTableManager(
    _$AppDatabase db,
    $CalendarEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CalendarEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> startAt = const Value.absent(),
                Value<int> endAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> petId = const Value.absent(),
                Value<String> remindersJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> systemEntryId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEntriesTableCompanion(
                id: id,
                title: title,
                description: description,
                startAt: startAt,
                endAt: endAt,
                category: category,
                petId: petId,
                remindersJson: remindersJson,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                systemEntryId: systemEntryId,
                isCompleted: isCompleted,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                required int startAt,
                required int endAt,
                required String category,
                Value<String?> petId = const Value.absent(),
                Value<String> remindersJson = const Value.absent(),
                required String source,
                required int createdAt,
                required int updatedAt,
                Value<String?> systemEntryId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEntriesTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                startAt: startAt,
                endAt: endAt,
                category: category,
                petId: petId,
                remindersJson: remindersJson,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                systemEntryId: systemEntryId,
                isCompleted: isCompleted,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEntriesTableTable,
      CalendarEntriesTableData,
      $$CalendarEntriesTableTableFilterComposer,
      $$CalendarEntriesTableTableOrderingComposer,
      $$CalendarEntriesTableTableAnnotationComposer,
      $$CalendarEntriesTableTableCreateCompanionBuilder,
      $$CalendarEntriesTableTableUpdateCompanionBuilder,
      (
        CalendarEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $CalendarEntriesTableTable,
          CalendarEntriesTableData
        >,
      ),
      CalendarEntriesTableData,
      PrefetchHooks Function()
    >;
typedef $$PetProfilesTableTableCreateCompanionBuilder =
    PetProfilesTableCompanion Function({
      required String id,
      required String name,
      required String breed,
      Value<int> loyaltyPoints,
      required String selectedSkinId,
      Value<String> unlockedSkinIdsJson,
      required int createdAt,
      Value<bool> isSelected,
      Value<int> rowid,
    });
typedef $$PetProfilesTableTableUpdateCompanionBuilder =
    PetProfilesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> breed,
      Value<int> loyaltyPoints,
      Value<String> selectedSkinId,
      Value<String> unlockedSkinIdsJson,
      Value<int> createdAt,
      Value<bool> isSelected,
      Value<int> rowid,
    });

class $$PetProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PetProfilesTableTable> {
  $$PetProfilesTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockedSkinIdsJson => $composableBuilder(
    column: $table.unlockedSkinIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PetProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PetProfilesTableTable> {
  $$PetProfilesTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockedSkinIdsJson => $composableBuilder(
    column: $table.unlockedSkinIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetProfilesTableTable> {
  $$PetProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<int> get loyaltyPoints => $composableBuilder(
    column: $table.loyaltyPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockedSkinIdsJson => $composableBuilder(
    column: $table.unlockedSkinIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => column,
  );
}

class $$PetProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetProfilesTableTable,
          PetProfilesTableData,
          $$PetProfilesTableTableFilterComposer,
          $$PetProfilesTableTableOrderingComposer,
          $$PetProfilesTableTableAnnotationComposer,
          $$PetProfilesTableTableCreateCompanionBuilder,
          $$PetProfilesTableTableUpdateCompanionBuilder,
          (
            PetProfilesTableData,
            BaseReferences<
              _$AppDatabase,
              $PetProfilesTableTable,
              PetProfilesTableData
            >,
          ),
          PetProfilesTableData,
          PrefetchHooks Function()
        > {
  $$PetProfilesTableTableTableManager(
    _$AppDatabase db,
    $PetProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetProfilesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> breed = const Value.absent(),
                Value<int> loyaltyPoints = const Value.absent(),
                Value<String> selectedSkinId = const Value.absent(),
                Value<String> unlockedSkinIdsJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetProfilesTableCompanion(
                id: id,
                name: name,
                breed: breed,
                loyaltyPoints: loyaltyPoints,
                selectedSkinId: selectedSkinId,
                unlockedSkinIdsJson: unlockedSkinIdsJson,
                createdAt: createdAt,
                isSelected: isSelected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String breed,
                Value<int> loyaltyPoints = const Value.absent(),
                required String selectedSkinId,
                Value<String> unlockedSkinIdsJson = const Value.absent(),
                required int createdAt,
                Value<bool> isSelected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetProfilesTableCompanion.insert(
                id: id,
                name: name,
                breed: breed,
                loyaltyPoints: loyaltyPoints,
                selectedSkinId: selectedSkinId,
                unlockedSkinIdsJson: unlockedSkinIdsJson,
                createdAt: createdAt,
                isSelected: isSelected,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PetProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetProfilesTableTable,
      PetProfilesTableData,
      $$PetProfilesTableTableFilterComposer,
      $$PetProfilesTableTableOrderingComposer,
      $$PetProfilesTableTableAnnotationComposer,
      $$PetProfilesTableTableCreateCompanionBuilder,
      $$PetProfilesTableTableUpdateCompanionBuilder,
      (
        PetProfilesTableData,
        BaseReferences<
          _$AppDatabase,
          $PetProfilesTableTable,
          PetProfilesTableData
        >,
      ),
      PetProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$CountdownItemsTableTableCreateCompanionBuilder =
    CountdownItemsTableCompanion Function({
      required String id,
      required String title,
      required int dueAt,
      required int createdAt,
      Value<String?> petId,
      Value<bool> isPinned,
      Value<bool> hasCelebrated,
      Value<int> rowid,
    });
typedef $$CountdownItemsTableTableUpdateCompanionBuilder =
    CountdownItemsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> dueAt,
      Value<int> createdAt,
      Value<String?> petId,
      Value<bool> isPinned,
      Value<bool> hasCelebrated,
      Value<int> rowid,
    });

class $$CountdownItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CountdownItemsTableTable> {
  $$CountdownItemsTableTableFilterComposer({
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

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCelebrated => $composableBuilder(
    column: $table.hasCelebrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountdownItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CountdownItemsTableTable> {
  $$CountdownItemsTableTableOrderingComposer({
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

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCelebrated => $composableBuilder(
    column: $table.hasCelebrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountdownItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountdownItemsTableTable> {
  $$CountdownItemsTableTableAnnotationComposer({
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

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get hasCelebrated => $composableBuilder(
    column: $table.hasCelebrated,
    builder: (column) => column,
  );
}

class $$CountdownItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountdownItemsTableTable,
          CountdownItemsTableData,
          $$CountdownItemsTableTableFilterComposer,
          $$CountdownItemsTableTableOrderingComposer,
          $$CountdownItemsTableTableAnnotationComposer,
          $$CountdownItemsTableTableCreateCompanionBuilder,
          $$CountdownItemsTableTableUpdateCompanionBuilder,
          (
            CountdownItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $CountdownItemsTableTable,
              CountdownItemsTableData
            >,
          ),
          CountdownItemsTableData,
          PrefetchHooks Function()
        > {
  $$CountdownItemsTableTableTableManager(
    _$AppDatabase db,
    $CountdownItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountdownItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountdownItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CountdownItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> dueAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> petId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> hasCelebrated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountdownItemsTableCompanion(
                id: id,
                title: title,
                dueAt: dueAt,
                createdAt: createdAt,
                petId: petId,
                isPinned: isPinned,
                hasCelebrated: hasCelebrated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int dueAt,
                required int createdAt,
                Value<String?> petId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> hasCelebrated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountdownItemsTableCompanion.insert(
                id: id,
                title: title,
                dueAt: dueAt,
                createdAt: createdAt,
                petId: petId,
                isPinned: isPinned,
                hasCelebrated: hasCelebrated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountdownItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountdownItemsTableTable,
      CountdownItemsTableData,
      $$CountdownItemsTableTableFilterComposer,
      $$CountdownItemsTableTableOrderingComposer,
      $$CountdownItemsTableTableAnnotationComposer,
      $$CountdownItemsTableTableCreateCompanionBuilder,
      $$CountdownItemsTableTableUpdateCompanionBuilder,
      (
        CountdownItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $CountdownItemsTableTable,
          CountdownItemsTableData
        >,
      ),
      CountdownItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$LoyaltyLedgersTableTableCreateCompanionBuilder =
    LoyaltyLedgersTableCompanion Function({
      required String id,
      required String petId,
      required String calendarItemId,
      required int points,
      required int createdAt,
      required String reason,
      Value<int> rowid,
    });
typedef $$LoyaltyLedgersTableTableUpdateCompanionBuilder =
    LoyaltyLedgersTableCompanion Function({
      Value<String> id,
      Value<String> petId,
      Value<String> calendarItemId,
      Value<int> points,
      Value<int> createdAt,
      Value<String> reason,
      Value<int> rowid,
    });

class $$LoyaltyLedgersTableTableFilterComposer
    extends Composer<_$AppDatabase, $LoyaltyLedgersTableTable> {
  $$LoyaltyLedgersTableTableFilterComposer({
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

  ColumnFilters<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarItemId => $composableBuilder(
    column: $table.calendarItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoyaltyLedgersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LoyaltyLedgersTableTable> {
  $$LoyaltyLedgersTableTableOrderingComposer({
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

  ColumnOrderings<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarItemId => $composableBuilder(
    column: $table.calendarItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoyaltyLedgersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoyaltyLedgersTableTable> {
  $$LoyaltyLedgersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get calendarItemId => $composableBuilder(
    column: $table.calendarItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$LoyaltyLedgersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoyaltyLedgersTableTable,
          LoyaltyLedgersTableData,
          $$LoyaltyLedgersTableTableFilterComposer,
          $$LoyaltyLedgersTableTableOrderingComposer,
          $$LoyaltyLedgersTableTableAnnotationComposer,
          $$LoyaltyLedgersTableTableCreateCompanionBuilder,
          $$LoyaltyLedgersTableTableUpdateCompanionBuilder,
          (
            LoyaltyLedgersTableData,
            BaseReferences<
              _$AppDatabase,
              $LoyaltyLedgersTableTable,
              LoyaltyLedgersTableData
            >,
          ),
          LoyaltyLedgersTableData,
          PrefetchHooks Function()
        > {
  $$LoyaltyLedgersTableTableTableManager(
    _$AppDatabase db,
    $LoyaltyLedgersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoyaltyLedgersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoyaltyLedgersTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LoyaltyLedgersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<String> calendarItemId = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoyaltyLedgersTableCompanion(
                id: id,
                petId: petId,
                calendarItemId: calendarItemId,
                points: points,
                createdAt: createdAt,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String petId,
                required String calendarItemId,
                required int points,
                required int createdAt,
                required String reason,
                Value<int> rowid = const Value.absent(),
              }) => LoyaltyLedgersTableCompanion.insert(
                id: id,
                petId: petId,
                calendarItemId: calendarItemId,
                points: points,
                createdAt: createdAt,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoyaltyLedgersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoyaltyLedgersTableTable,
      LoyaltyLedgersTableData,
      $$LoyaltyLedgersTableTableFilterComposer,
      $$LoyaltyLedgersTableTableOrderingComposer,
      $$LoyaltyLedgersTableTableAnnotationComposer,
      $$LoyaltyLedgersTableTableCreateCompanionBuilder,
      $$LoyaltyLedgersTableTableUpdateCompanionBuilder,
      (
        LoyaltyLedgersTableData,
        BaseReferences<
          _$AppDatabase,
          $LoyaltyLedgersTableTable,
          LoyaltyLedgersTableData
        >,
      ),
      LoyaltyLedgersTableData,
      PrefetchHooks Function()
    >;
typedef $$GeofencePlacesTableTableCreateCompanionBuilder =
    GeofencePlacesTableCompanion Function({
      required String id,
      required String name,
      required double latitude,
      required double longitude,
      required double radiusMeters,
      required String sceneMode,
      Value<int> rowid,
    });
typedef $$GeofencePlacesTableTableUpdateCompanionBuilder =
    GeofencePlacesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> radiusMeters,
      Value<String> sceneMode,
      Value<int> rowid,
    });

class $$GeofencePlacesTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeofencePlacesTableTable> {
  $$GeofencePlacesTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneMode => $composableBuilder(
    column: $table.sceneMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeofencePlacesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeofencePlacesTableTable> {
  $$GeofencePlacesTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneMode => $composableBuilder(
    column: $table.sceneMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeofencePlacesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeofencePlacesTableTable> {
  $$GeofencePlacesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sceneMode =>
      $composableBuilder(column: $table.sceneMode, builder: (column) => column);
}

class $$GeofencePlacesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeofencePlacesTableTable,
          GeofencePlacesTableData,
          $$GeofencePlacesTableTableFilterComposer,
          $$GeofencePlacesTableTableOrderingComposer,
          $$GeofencePlacesTableTableAnnotationComposer,
          $$GeofencePlacesTableTableCreateCompanionBuilder,
          $$GeofencePlacesTableTableUpdateCompanionBuilder,
          (
            GeofencePlacesTableData,
            BaseReferences<
              _$AppDatabase,
              $GeofencePlacesTableTable,
              GeofencePlacesTableData
            >,
          ),
          GeofencePlacesTableData,
          PrefetchHooks Function()
        > {
  $$GeofencePlacesTableTableTableManager(
    _$AppDatabase db,
    $GeofencePlacesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeofencePlacesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeofencePlacesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GeofencePlacesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                Value<String> sceneMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeofencePlacesTableCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                sceneMode: sceneMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double latitude,
                required double longitude,
                required double radiusMeters,
                required String sceneMode,
                Value<int> rowid = const Value.absent(),
              }) => GeofencePlacesTableCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                sceneMode: sceneMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeofencePlacesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeofencePlacesTableTable,
      GeofencePlacesTableData,
      $$GeofencePlacesTableTableFilterComposer,
      $$GeofencePlacesTableTableOrderingComposer,
      $$GeofencePlacesTableTableAnnotationComposer,
      $$GeofencePlacesTableTableCreateCompanionBuilder,
      $$GeofencePlacesTableTableUpdateCompanionBuilder,
      (
        GeofencePlacesTableData,
        BaseReferences<
          _$AppDatabase,
          $GeofencePlacesTableTable,
          GeofencePlacesTableData
        >,
      ),
      GeofencePlacesTableData,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableTableCreateCompanionBuilder =
    PreferencesTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableTableUpdateCompanionBuilder =
    PreferencesTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableFilterComposer({
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
}

class $$PreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableOrderingComposer({
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
}

class $$PreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableAnnotationComposer({
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
}

class $$PreferencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTableTable,
          PreferencesTableData,
          $$PreferencesTableTableFilterComposer,
          $$PreferencesTableTableOrderingComposer,
          $$PreferencesTableTableAnnotationComposer,
          $$PreferencesTableTableCreateCompanionBuilder,
          $$PreferencesTableTableUpdateCompanionBuilder,
          (
            PreferencesTableData,
            BaseReferences<
              _$AppDatabase,
              $PreferencesTableTable,
              PreferencesTableData
            >,
          ),
          PreferencesTableData,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableTableManager(
    _$AppDatabase db,
    $PreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTableTable,
      PreferencesTableData,
      $$PreferencesTableTableFilterComposer,
      $$PreferencesTableTableOrderingComposer,
      $$PreferencesTableTableAnnotationComposer,
      $$PreferencesTableTableCreateCompanionBuilder,
      $$PreferencesTableTableUpdateCompanionBuilder,
      (
        PreferencesTableData,
        BaseReferences<
          _$AppDatabase,
          $PreferencesTableTable,
          PreferencesTableData
        >,
      ),
      PreferencesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CalendarEntriesTableTableTableManager get calendarEntriesTable =>
      $$CalendarEntriesTableTableTableManager(_db, _db.calendarEntriesTable);
  $$PetProfilesTableTableTableManager get petProfilesTable =>
      $$PetProfilesTableTableTableManager(_db, _db.petProfilesTable);
  $$CountdownItemsTableTableTableManager get countdownItemsTable =>
      $$CountdownItemsTableTableTableManager(_db, _db.countdownItemsTable);
  $$LoyaltyLedgersTableTableTableManager get loyaltyLedgersTable =>
      $$LoyaltyLedgersTableTableTableManager(_db, _db.loyaltyLedgersTable);
  $$GeofencePlacesTableTableTableManager get geofencePlacesTable =>
      $$GeofencePlacesTableTableTableManager(_db, _db.geofencePlacesTable);
  $$PreferencesTableTableTableManager get preferencesTable =>
      $$PreferencesTableTableTableManager(_db, _db.preferencesTable);
}
