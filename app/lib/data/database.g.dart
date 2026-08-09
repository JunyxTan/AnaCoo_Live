// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatsappNumberMeta = const VerificationMeta(
    'whatsappNumber',
  );
  @override
  late final GeneratedColumn<String> whatsappNumber = GeneratedColumn<String>(
    'whatsapp_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    id,
    name,
    phone,
    whatsappNumber,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('whatsapp_number')) {
      context.handle(
        _whatsappNumberMeta,
        whatsappNumber.isAcceptableOrUnknown(
          data['whatsapp_number']!,
          _whatsappNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      whatsappNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whatsapp_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;

  /// E.164 where we could normalise it (MY/SG), raw input otherwise.
  final String? phone;
  final String? whatsappNumber;
  final String? notes;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.whatsappNumber,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || whatsappNumber != null) {
      map['whatsapp_number'] = Variable<String>(whatsappNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      whatsappNumber: whatsappNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(whatsappNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      whatsappNumber: serializer.fromJson<String?>(json['whatsappNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'whatsappNumber': serializer.toJson<String?>(whatsappNumber),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> whatsappNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    whatsappNumber: whatsappNumber.present
        ? whatsappNumber.value
        : this.whatsappNumber,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsappNumber: data.whatsappNumber.present
          ? data.whatsappNumber.value
          : this.whatsappNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsappNumber: $whatsappNumber, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, whatsappNumber, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.whatsappNumber == this.whatsappNumber &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> whatsappNumber;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsappNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.whatsappNumber = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? whatsappNumber,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? whatsappNumber,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsappNumber.present) {
      map['whatsapp_number'] = Variable<String>(whatsappNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsappNumber: $whatsappNumber, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ServiceType, String> service =
      GeneratedColumn<String>(
        'service',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ServiceType>($JobsTable.$converterservice);
  static const VerificationMeta _serviceFreeTextMeta = const VerificationMeta(
    'serviceFreeText',
  );
  @override
  late final GeneratedColumn<String> serviceFreeText = GeneratedColumn<String>(
    'service_free_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemDescriptionMeta = const VerificationMeta(
    'itemDescription',
  );
  @override
  late final GeneratedColumn<String> itemDescription = GeneratedColumn<String>(
    'item_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _quotedPriceMeta = const VerificationMeta(
    'quotedPrice',
  );
  @override
  late final GeneratedColumn<double> quotedPrice = GeneratedColumn<double>(
    'quoted_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositPaidMeta = const VerificationMeta(
    'depositPaid',
  );
  @override
  late final GeneratedColumn<double> depositPaid = GeneratedColumn<double>(
    'deposit_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobStatus>($JobsTable.$converterstatus);
  static const VerificationMeta _isRushMeta = const VerificationMeta('isRush');
  @override
  late final GeneratedColumn<bool> isRush = GeneratedColumn<bool>(
    'is_rush',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rush" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _readyAtMeta = const VerificationMeta(
    'readyAt',
  );
  @override
  late final GeneratedColumn<DateTime> readyAt = GeneratedColumn<DateTime>(
    'ready_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    service,
    serviceFreeText,
    itemDescription,
    quantity,
    quotedPrice,
    depositPaid,
    status,
    isRush,
    notes,
    rawMessage,
    createdAt,
    readyAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('service_free_text')) {
      context.handle(
        _serviceFreeTextMeta,
        serviceFreeText.isAcceptableOrUnknown(
          data['service_free_text']!,
          _serviceFreeTextMeta,
        ),
      );
    }
    if (data.containsKey('item_description')) {
      context.handle(
        _itemDescriptionMeta,
        itemDescription.isAcceptableOrUnknown(
          data['item_description']!,
          _itemDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('quoted_price')) {
      context.handle(
        _quotedPriceMeta,
        quotedPrice.isAcceptableOrUnknown(
          data['quoted_price']!,
          _quotedPriceMeta,
        ),
      );
    }
    if (data.containsKey('deposit_paid')) {
      context.handle(
        _depositPaidMeta,
        depositPaid.isAcceptableOrUnknown(
          data['deposit_paid']!,
          _depositPaidMeta,
        ),
      );
    }
    if (data.containsKey('is_rush')) {
      context.handle(
        _isRushMeta,
        isRush.isAcceptableOrUnknown(data['is_rush']!, _isRushMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
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
    if (data.containsKey('ready_at')) {
      context.handle(
        _readyAtMeta,
        readyAt.isAcceptableOrUnknown(data['ready_at']!, _readyAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      service: $JobsTable.$converterservice.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}service'],
        )!,
      ),
      serviceFreeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_free_text'],
      ),
      itemDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_description'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      quotedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quoted_price'],
      ),
      depositPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}deposit_paid'],
      ),
      status: $JobsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      isRush: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rush'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      readyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ready_at'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ServiceType, String, String> $converterservice =
      const EnumNameConverter<ServiceType>(ServiceType.values);
  static JsonTypeConverter2<JobStatus, String, String> $converterstatus =
      const EnumNameConverter<JobStatus>(JobStatus.values);
}

class Job extends DataClass implements Insertable<Job> {
  final int id;
  final int customerId;
  final ServiceType service;

  /// Free text that goes with the enum — always populated for
  /// [ServiceType.other], and used to keep the customer's own wording.
  final String? serviceFreeText;
  final String? itemDescription;
  final int quantity;

  /// MYR. Nullable — most jobs are quoted after the garment is seen.
  final double? quotedPrice;
  final double? depositPaid;
  final JobStatus status;
  final bool isRush;
  final String? notes;

  /// Whatever arrived over WhatsApp, verbatim. Never dropped, even when the
  /// parser understood every field.
  final String? rawMessage;
  final DateTime createdAt;

  /// Set when the job entered [JobStatus.ready], cleared when it leaves.
  /// Drives the "sitting in ready for N days" nudge.
  final DateTime? readyAt;
  const Job({
    required this.id,
    required this.customerId,
    required this.service,
    this.serviceFreeText,
    this.itemDescription,
    required this.quantity,
    this.quotedPrice,
    this.depositPaid,
    required this.status,
    required this.isRush,
    this.notes,
    this.rawMessage,
    required this.createdAt,
    this.readyAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    {
      map['service'] = Variable<String>(
        $JobsTable.$converterservice.toSql(service),
      );
    }
    if (!nullToAbsent || serviceFreeText != null) {
      map['service_free_text'] = Variable<String>(serviceFreeText);
    }
    if (!nullToAbsent || itemDescription != null) {
      map['item_description'] = Variable<String>(itemDescription);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || quotedPrice != null) {
      map['quoted_price'] = Variable<double>(quotedPrice);
    }
    if (!nullToAbsent || depositPaid != null) {
      map['deposit_paid'] = Variable<double>(depositPaid);
    }
    {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status),
      );
    }
    map['is_rush'] = Variable<bool>(isRush);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || rawMessage != null) {
      map['raw_message'] = Variable<String>(rawMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readyAt != null) {
      map['ready_at'] = Variable<DateTime>(readyAt);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      service: Value(service),
      serviceFreeText: serviceFreeText == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceFreeText),
      itemDescription: itemDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(itemDescription),
      quantity: Value(quantity),
      quotedPrice: quotedPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(quotedPrice),
      depositPaid: depositPaid == null && nullToAbsent
          ? const Value.absent()
          : Value(depositPaid),
      status: Value(status),
      isRush: Value(isRush),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      rawMessage: rawMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(rawMessage),
      createdAt: Value(createdAt),
      readyAt: readyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readyAt),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      service: $JobsTable.$converterservice.fromJson(
        serializer.fromJson<String>(json['service']),
      ),
      serviceFreeText: serializer.fromJson<String?>(json['serviceFreeText']),
      itemDescription: serializer.fromJson<String?>(json['itemDescription']),
      quantity: serializer.fromJson<int>(json['quantity']),
      quotedPrice: serializer.fromJson<double?>(json['quotedPrice']),
      depositPaid: serializer.fromJson<double?>(json['depositPaid']),
      status: $JobsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      isRush: serializer.fromJson<bool>(json['isRush']),
      notes: serializer.fromJson<String?>(json['notes']),
      rawMessage: serializer.fromJson<String?>(json['rawMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readyAt: serializer.fromJson<DateTime?>(json['readyAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'service': serializer.toJson<String>(
        $JobsTable.$converterservice.toJson(service),
      ),
      'serviceFreeText': serializer.toJson<String?>(serviceFreeText),
      'itemDescription': serializer.toJson<String?>(itemDescription),
      'quantity': serializer.toJson<int>(quantity),
      'quotedPrice': serializer.toJson<double?>(quotedPrice),
      'depositPaid': serializer.toJson<double?>(depositPaid),
      'status': serializer.toJson<String>(
        $JobsTable.$converterstatus.toJson(status),
      ),
      'isRush': serializer.toJson<bool>(isRush),
      'notes': serializer.toJson<String?>(notes),
      'rawMessage': serializer.toJson<String?>(rawMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readyAt': serializer.toJson<DateTime?>(readyAt),
    };
  }

  Job copyWith({
    int? id,
    int? customerId,
    ServiceType? service,
    Value<String?> serviceFreeText = const Value.absent(),
    Value<String?> itemDescription = const Value.absent(),
    int? quantity,
    Value<double?> quotedPrice = const Value.absent(),
    Value<double?> depositPaid = const Value.absent(),
    JobStatus? status,
    bool? isRush,
    Value<String?> notes = const Value.absent(),
    Value<String?> rawMessage = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> readyAt = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    service: service ?? this.service,
    serviceFreeText: serviceFreeText.present
        ? serviceFreeText.value
        : this.serviceFreeText,
    itemDescription: itemDescription.present
        ? itemDescription.value
        : this.itemDescription,
    quantity: quantity ?? this.quantity,
    quotedPrice: quotedPrice.present ? quotedPrice.value : this.quotedPrice,
    depositPaid: depositPaid.present ? depositPaid.value : this.depositPaid,
    status: status ?? this.status,
    isRush: isRush ?? this.isRush,
    notes: notes.present ? notes.value : this.notes,
    rawMessage: rawMessage.present ? rawMessage.value : this.rawMessage,
    createdAt: createdAt ?? this.createdAt,
    readyAt: readyAt.present ? readyAt.value : this.readyAt,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      service: data.service.present ? data.service.value : this.service,
      serviceFreeText: data.serviceFreeText.present
          ? data.serviceFreeText.value
          : this.serviceFreeText,
      itemDescription: data.itemDescription.present
          ? data.itemDescription.value
          : this.itemDescription,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quotedPrice: data.quotedPrice.present
          ? data.quotedPrice.value
          : this.quotedPrice,
      depositPaid: data.depositPaid.present
          ? data.depositPaid.value
          : this.depositPaid,
      status: data.status.present ? data.status.value : this.status,
      isRush: data.isRush.present ? data.isRush.value : this.isRush,
      notes: data.notes.present ? data.notes.value : this.notes,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readyAt: data.readyAt.present ? data.readyAt.value : this.readyAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('service: $service, ')
          ..write('serviceFreeText: $serviceFreeText, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('quantity: $quantity, ')
          ..write('quotedPrice: $quotedPrice, ')
          ..write('depositPaid: $depositPaid, ')
          ..write('status: $status, ')
          ..write('isRush: $isRush, ')
          ..write('notes: $notes, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('readyAt: $readyAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    service,
    serviceFreeText,
    itemDescription,
    quantity,
    quotedPrice,
    depositPaid,
    status,
    isRush,
    notes,
    rawMessage,
    createdAt,
    readyAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.service == this.service &&
          other.serviceFreeText == this.serviceFreeText &&
          other.itemDescription == this.itemDescription &&
          other.quantity == this.quantity &&
          other.quotedPrice == this.quotedPrice &&
          other.depositPaid == this.depositPaid &&
          other.status == this.status &&
          other.isRush == this.isRush &&
          other.notes == this.notes &&
          other.rawMessage == this.rawMessage &&
          other.createdAt == this.createdAt &&
          other.readyAt == this.readyAt);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<ServiceType> service;
  final Value<String?> serviceFreeText;
  final Value<String?> itemDescription;
  final Value<int> quantity;
  final Value<double?> quotedPrice;
  final Value<double?> depositPaid;
  final Value<JobStatus> status;
  final Value<bool> isRush;
  final Value<String?> notes;
  final Value<String?> rawMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readyAt;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.service = const Value.absent(),
    this.serviceFreeText = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quotedPrice = const Value.absent(),
    this.depositPaid = const Value.absent(),
    this.status = const Value.absent(),
    this.isRush = const Value.absent(),
    this.notes = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readyAt = const Value.absent(),
  });
  JobsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required ServiceType service,
    this.serviceFreeText = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quotedPrice = const Value.absent(),
    this.depositPaid = const Value.absent(),
    required JobStatus status,
    this.isRush = const Value.absent(),
    this.notes = const Value.absent(),
    this.rawMessage = const Value.absent(),
    required DateTime createdAt,
    this.readyAt = const Value.absent(),
  }) : customerId = Value(customerId),
       service = Value(service),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Job> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? service,
    Expression<String>? serviceFreeText,
    Expression<String>? itemDescription,
    Expression<int>? quantity,
    Expression<double>? quotedPrice,
    Expression<double>? depositPaid,
    Expression<String>? status,
    Expression<bool>? isRush,
    Expression<String>? notes,
    Expression<String>? rawMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readyAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (service != null) 'service': service,
      if (serviceFreeText != null) 'service_free_text': serviceFreeText,
      if (itemDescription != null) 'item_description': itemDescription,
      if (quantity != null) 'quantity': quantity,
      if (quotedPrice != null) 'quoted_price': quotedPrice,
      if (depositPaid != null) 'deposit_paid': depositPaid,
      if (status != null) 'status': status,
      if (isRush != null) 'is_rush': isRush,
      if (notes != null) 'notes': notes,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (readyAt != null) 'ready_at': readyAt,
    });
  }

  JobsCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<ServiceType>? service,
    Value<String?>? serviceFreeText,
    Value<String?>? itemDescription,
    Value<int>? quantity,
    Value<double?>? quotedPrice,
    Value<double?>? depositPaid,
    Value<JobStatus>? status,
    Value<bool>? isRush,
    Value<String?>? notes,
    Value<String?>? rawMessage,
    Value<DateTime>? createdAt,
    Value<DateTime?>? readyAt,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      service: service ?? this.service,
      serviceFreeText: serviceFreeText ?? this.serviceFreeText,
      itemDescription: itemDescription ?? this.itemDescription,
      quantity: quantity ?? this.quantity,
      quotedPrice: quotedPrice ?? this.quotedPrice,
      depositPaid: depositPaid ?? this.depositPaid,
      status: status ?? this.status,
      isRush: isRush ?? this.isRush,
      notes: notes ?? this.notes,
      rawMessage: rawMessage ?? this.rawMessage,
      createdAt: createdAt ?? this.createdAt,
      readyAt: readyAt ?? this.readyAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(
        $JobsTable.$converterservice.toSql(service.value),
      );
    }
    if (serviceFreeText.present) {
      map['service_free_text'] = Variable<String>(serviceFreeText.value);
    }
    if (itemDescription.present) {
      map['item_description'] = Variable<String>(itemDescription.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (quotedPrice.present) {
      map['quoted_price'] = Variable<double>(quotedPrice.value);
    }
    if (depositPaid.present) {
      map['deposit_paid'] = Variable<double>(depositPaid.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status.value),
      );
    }
    if (isRush.present) {
      map['is_rush'] = Variable<bool>(isRush.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readyAt.present) {
      map['ready_at'] = Variable<DateTime>(readyAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('service: $service, ')
          ..write('serviceFreeText: $serviceFreeText, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('quantity: $quantity, ')
          ..write('quotedPrice: $quotedPrice, ')
          ..write('depositPaid: $depositPaid, ')
          ..write('status: $status, ')
          ..write('isRush: $isRush, ')
          ..write('notes: $notes, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('readyAt: $readyAt')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppointmentType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AppointmentType>($AppointmentsTable.$convertertype);
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppointmentStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AppointmentStatus>($AppointmentsTable.$converterstatus);
  static const VerificationMeta _reminderRulesMeta = const VerificationMeta(
    'reminderRules',
  );
  @override
  late final GeneratedColumn<String> reminderRules = GeneratedColumn<String>(
    'reminder_rules',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    type,
    scheduledAt,
    durationMinutes,
    status,
    reminderRules,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reminder_rules')) {
      context.handle(
        _reminderRulesMeta,
        reminderRules.isAcceptableOrUnknown(
          data['reminder_rules']!,
          _reminderRulesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      type: $AppointmentsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      status: $AppointmentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      reminderRules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_rules'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppointmentType, String, String> $convertertype =
      const EnumNameConverter<AppointmentType>(AppointmentType.values);
  static JsonTypeConverter2<AppointmentStatus, String, String>
  $converterstatus = const EnumNameConverter<AppointmentStatus>(
    AppointmentStatus.values,
  );
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final int id;
  final int jobId;
  final AppointmentType type;

  /// Stored as a UTC instant; always rendered and scheduled through the shop
  /// timezone so a device clock or timezone change cannot drift it.
  final DateTime scheduledAt;
  final int durationMinutes;
  final AppointmentStatus status;

  /// Encoded `ReminderRule` list. Null means "use the Settings defaults".
  final String? reminderRules;
  final String? notes;
  const Appointment({
    required this.id,
    required this.jobId,
    required this.type,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.reminderRules,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    {
      map['type'] = Variable<String>(
        $AppointmentsTable.$convertertype.toSql(type),
      );
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    {
      map['status'] = Variable<String>(
        $AppointmentsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || reminderRules != null) {
      map['reminder_rules'] = Variable<String>(reminderRules);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      type: Value(type),
      scheduledAt: Value(scheduledAt),
      durationMinutes: Value(durationMinutes),
      status: Value(status),
      reminderRules: reminderRules == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderRules),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      type: $AppointmentsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      status: $AppointmentsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      reminderRules: serializer.fromJson<String?>(json['reminderRules']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'type': serializer.toJson<String>(
        $AppointmentsTable.$convertertype.toJson(type),
      ),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'status': serializer.toJson<String>(
        $AppointmentsTable.$converterstatus.toJson(status),
      ),
      'reminderRules': serializer.toJson<String?>(reminderRules),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Appointment copyWith({
    int? id,
    int? jobId,
    AppointmentType? type,
    DateTime? scheduledAt,
    int? durationMinutes,
    AppointmentStatus? status,
    Value<String?> reminderRules = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Appointment(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    type: type ?? this.type,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    status: status ?? this.status,
    reminderRules: reminderRules.present
        ? reminderRules.value
        : this.reminderRules,
    notes: notes.present ? notes.value : this.notes,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      type: data.type.present ? data.type.value : this.type,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      status: data.status.present ? data.status.value : this.status,
      reminderRules: data.reminderRules.present
          ? data.reminderRules.value
          : this.reminderRules,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('type: $type, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('reminderRules: $reminderRules, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    type,
    scheduledAt,
    durationMinutes,
    status,
    reminderRules,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.type == this.type &&
          other.scheduledAt == this.scheduledAt &&
          other.durationMinutes == this.durationMinutes &&
          other.status == this.status &&
          other.reminderRules == this.reminderRules &&
          other.notes == this.notes);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<AppointmentType> type;
  final Value<DateTime> scheduledAt;
  final Value<int> durationMinutes;
  final Value<AppointmentStatus> status;
  final Value<String?> reminderRules;
  final Value<String?> notes;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.type = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderRules = const Value.absent(),
    this.notes = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required AppointmentType type,
    required DateTime scheduledAt,
    this.durationMinutes = const Value.absent(),
    required AppointmentStatus status,
    this.reminderRules = const Value.absent(),
    this.notes = const Value.absent(),
  }) : jobId = Value(jobId),
       type = Value(type),
       scheduledAt = Value(scheduledAt),
       status = Value(status);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<String>? type,
    Expression<DateTime>? scheduledAt,
    Expression<int>? durationMinutes,
    Expression<String>? status,
    Expression<String>? reminderRules,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (type != null) 'type': type,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (status != null) 'status': status,
      if (reminderRules != null) 'reminder_rules': reminderRules,
      if (notes != null) 'notes': notes,
    });
  }

  AppointmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<AppointmentType>? type,
    Value<DateTime>? scheduledAt,
    Value<int>? durationMinutes,
    Value<AppointmentStatus>? status,
    Value<String?>? reminderRules,
    Value<String?>? notes,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      reminderRules: reminderRules ?? this.reminderRules,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AppointmentsTable.$convertertype.toSql(type.value),
      );
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $AppointmentsTable.$converterstatus.toSql(status.value),
      );
    }
    if (reminderRules.present) {
      map['reminder_rules'] = Variable<String>(reminderRules.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('type: $type, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('reminderRules: $reminderRules, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $BlockedDatesTable extends BlockedDates
    with TableInfo<$BlockedDatesTable, BlockedDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockedDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [day, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocked_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockedDate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  BlockedDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockedDate(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $BlockedDatesTable createAlias(String alias) {
    return $BlockedDatesTable(attachedDatabase, alias);
  }
}

class BlockedDate extends DataClass implements Insertable<BlockedDate> {
  /// Local calendar day as `YYYY-MM-DD` — a blocked day is a day in the shop's
  /// own calendar, not an instant, so it must not be stored as a timestamp.
  final String day;
  final String? reason;
  const BlockedDate({required this.day, this.reason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  BlockedDatesCompanion toCompanion(bool nullToAbsent) {
    return BlockedDatesCompanion(
      day: Value(day),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory BlockedDate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockedDate(
      day: serializer.fromJson<String>(json['day']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  BlockedDate copyWith({
    String? day,
    Value<String?> reason = const Value.absent(),
  }) => BlockedDate(
    day: day ?? this.day,
    reason: reason.present ? reason.value : this.reason,
  );
  BlockedDate copyWithCompanion(BlockedDatesCompanion data) {
    return BlockedDate(
      day: data.day.present ? data.day.value : this.day,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockedDate(')
          ..write('day: $day, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockedDate &&
          other.day == this.day &&
          other.reason == this.reason);
}

class BlockedDatesCompanion extends UpdateCompanion<BlockedDate> {
  final Value<String> day;
  final Value<String?> reason;
  final Value<int> rowid;
  const BlockedDatesCompanion({
    this.day = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlockedDatesCompanion.insert({
    required String day,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<BlockedDate> custom({
    Expression<String>? day,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlockedDatesCompanion copyWith({
    Value<String>? day,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return BlockedDatesCompanion(
      day: day ?? this.day,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
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
    return (StringBuffer('BlockedDatesCompanion(')
          ..write('day: $day, ')
          ..write('reason: $reason, ')
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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _defaultReminderRulesMeta =
      const VerificationMeta('defaultReminderRules');
  @override
  late final GeneratedColumn<String> defaultReminderRules =
      GeneratedColumn<String>(
        'default_reminder_rules',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _workingHoursMeta = const VerificationMeta(
    'workingHours',
  );
  @override
  late final GeneratedColumn<String> workingHours = GeneratedColumn<String>(
    'working_hours',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMinutesMeta = const VerificationMeta(
    'slotMinutes',
  );
  @override
  late final GeneratedColumn<int> slotMinutes = GeneratedColumn<int>(
    'slot_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _defaultTurnaroundDaysMeta =
      const VerificationMeta('defaultTurnaroundDays');
  @override
  late final GeneratedColumn<int> defaultTurnaroundDays = GeneratedColumn<int>(
    'default_turnaround_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _dailyAgendaMinutesMeta =
      const VerificationMeta('dailyAgendaMinutes');
  @override
  late final GeneratedColumn<int> dailyAgendaMinutes = GeneratedColumn<int>(
    'daily_agenda_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9 * 60),
  );
  static const VerificationMeta _dailyAgendaEnabledMeta =
      const VerificationMeta('dailyAgendaEnabled');
  @override
  late final GeneratedColumn<bool> dailyAgendaEnabled = GeneratedColumn<bool>(
    'daily_agenda_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_agenda_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _readyNudgeDaysMeta = const VerificationMeta(
    'readyNudgeDays',
  );
  @override
  late final GeneratedColumn<int> readyNudgeDays = GeneratedColumn<int>(
    'ready_nudge_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _overdueNudgesEnabledMeta =
      const VerificationMeta('overdueNudgesEnabled');
  @override
  late final GeneratedColumn<bool> overdueNudgesEnabled = GeneratedColumn<bool>(
    'overdue_nudges_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("overdue_nudges_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _templatesMeta = const VerificationMeta(
    'templates',
  );
  @override
  late final GeneratedColumn<String> templates = GeneratedColumn<String>(
    'templates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryExplainerSeenMeta =
      const VerificationMeta('batteryExplainerSeen');
  @override
  late final GeneratedColumn<bool> batteryExplainerSeen = GeneratedColumn<bool>(
    'battery_explainer_seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("battery_explainer_seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultReminderRules,
    workingHours,
    slotMinutes,
    defaultTurnaroundDays,
    dailyAgendaMinutes,
    dailyAgendaEnabled,
    languageCode,
    readyNudgeDays,
    overdueNudgesEnabled,
    templates,
    batteryExplainerSeen,
  ];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_reminder_rules')) {
      context.handle(
        _defaultReminderRulesMeta,
        defaultReminderRules.isAcceptableOrUnknown(
          data['default_reminder_rules']!,
          _defaultReminderRulesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultReminderRulesMeta);
    }
    if (data.containsKey('working_hours')) {
      context.handle(
        _workingHoursMeta,
        workingHours.isAcceptableOrUnknown(
          data['working_hours']!,
          _workingHoursMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workingHoursMeta);
    }
    if (data.containsKey('slot_minutes')) {
      context.handle(
        _slotMinutesMeta,
        slotMinutes.isAcceptableOrUnknown(
          data['slot_minutes']!,
          _slotMinutesMeta,
        ),
      );
    }
    if (data.containsKey('default_turnaround_days')) {
      context.handle(
        _defaultTurnaroundDaysMeta,
        defaultTurnaroundDays.isAcceptableOrUnknown(
          data['default_turnaround_days']!,
          _defaultTurnaroundDaysMeta,
        ),
      );
    }
    if (data.containsKey('daily_agenda_minutes')) {
      context.handle(
        _dailyAgendaMinutesMeta,
        dailyAgendaMinutes.isAcceptableOrUnknown(
          data['daily_agenda_minutes']!,
          _dailyAgendaMinutesMeta,
        ),
      );
    }
    if (data.containsKey('daily_agenda_enabled')) {
      context.handle(
        _dailyAgendaEnabledMeta,
        dailyAgendaEnabled.isAcceptableOrUnknown(
          data['daily_agenda_enabled']!,
          _dailyAgendaEnabledMeta,
        ),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('ready_nudge_days')) {
      context.handle(
        _readyNudgeDaysMeta,
        readyNudgeDays.isAcceptableOrUnknown(
          data['ready_nudge_days']!,
          _readyNudgeDaysMeta,
        ),
      );
    }
    if (data.containsKey('overdue_nudges_enabled')) {
      context.handle(
        _overdueNudgesEnabledMeta,
        overdueNudgesEnabled.isAcceptableOrUnknown(
          data['overdue_nudges_enabled']!,
          _overdueNudgesEnabledMeta,
        ),
      );
    }
    if (data.containsKey('templates')) {
      context.handle(
        _templatesMeta,
        templates.isAcceptableOrUnknown(data['templates']!, _templatesMeta),
      );
    } else if (isInserting) {
      context.missing(_templatesMeta);
    }
    if (data.containsKey('battery_explainer_seen')) {
      context.handle(
        _batteryExplainerSeenMeta,
        batteryExplainerSeen.isAcceptableOrUnknown(
          data['battery_explainer_seen']!,
          _batteryExplainerSeenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultReminderRules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_reminder_rules'],
      )!,
      workingHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_hours'],
      )!,
      slotMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_minutes'],
      )!,
      defaultTurnaroundDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_turnaround_days'],
      )!,
      dailyAgendaMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_agenda_minutes'],
      )!,
      dailyAgendaEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_agenda_enabled'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      readyNudgeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ready_nudge_days'],
      )!,
      overdueNudgesEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}overdue_nudges_enabled'],
      )!,
      templates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}templates'],
      )!,
      batteryExplainerSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}battery_explainer_seen'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String defaultReminderRules;
  final String workingHours;
  final int slotMinutes;
  final int defaultTurnaroundDays;

  /// Daily agenda notification time, minutes from local midnight.
  final int dailyAgendaMinutes;
  final bool dailyAgendaEnabled;

  /// `en`, `zh`, `ms`, or `system`.
  final String languageCode;

  /// Nudge when a job has been `ready` this many days.
  final int readyNudgeDays;
  final bool overdueNudgesEnabled;

  /// WhatsApp reply templates, `{lang: {templateKey: body}}`.
  final String templates;

  /// One-time Doze / OEM battery-optimisation explainer.
  final bool batteryExplainerSeen;
  const AppSetting({
    required this.id,
    required this.defaultReminderRules,
    required this.workingHours,
    required this.slotMinutes,
    required this.defaultTurnaroundDays,
    required this.dailyAgendaMinutes,
    required this.dailyAgendaEnabled,
    required this.languageCode,
    required this.readyNudgeDays,
    required this.overdueNudgesEnabled,
    required this.templates,
    required this.batteryExplainerSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_reminder_rules'] = Variable<String>(defaultReminderRules);
    map['working_hours'] = Variable<String>(workingHours);
    map['slot_minutes'] = Variable<int>(slotMinutes);
    map['default_turnaround_days'] = Variable<int>(defaultTurnaroundDays);
    map['daily_agenda_minutes'] = Variable<int>(dailyAgendaMinutes);
    map['daily_agenda_enabled'] = Variable<bool>(dailyAgendaEnabled);
    map['language_code'] = Variable<String>(languageCode);
    map['ready_nudge_days'] = Variable<int>(readyNudgeDays);
    map['overdue_nudges_enabled'] = Variable<bool>(overdueNudgesEnabled);
    map['templates'] = Variable<String>(templates);
    map['battery_explainer_seen'] = Variable<bool>(batteryExplainerSeen);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      defaultReminderRules: Value(defaultReminderRules),
      workingHours: Value(workingHours),
      slotMinutes: Value(slotMinutes),
      defaultTurnaroundDays: Value(defaultTurnaroundDays),
      dailyAgendaMinutes: Value(dailyAgendaMinutes),
      dailyAgendaEnabled: Value(dailyAgendaEnabled),
      languageCode: Value(languageCode),
      readyNudgeDays: Value(readyNudgeDays),
      overdueNudgesEnabled: Value(overdueNudgesEnabled),
      templates: Value(templates),
      batteryExplainerSeen: Value(batteryExplainerSeen),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      defaultReminderRules: serializer.fromJson<String>(
        json['defaultReminderRules'],
      ),
      workingHours: serializer.fromJson<String>(json['workingHours']),
      slotMinutes: serializer.fromJson<int>(json['slotMinutes']),
      defaultTurnaroundDays: serializer.fromJson<int>(
        json['defaultTurnaroundDays'],
      ),
      dailyAgendaMinutes: serializer.fromJson<int>(json['dailyAgendaMinutes']),
      dailyAgendaEnabled: serializer.fromJson<bool>(json['dailyAgendaEnabled']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      readyNudgeDays: serializer.fromJson<int>(json['readyNudgeDays']),
      overdueNudgesEnabled: serializer.fromJson<bool>(
        json['overdueNudgesEnabled'],
      ),
      templates: serializer.fromJson<String>(json['templates']),
      batteryExplainerSeen: serializer.fromJson<bool>(
        json['batteryExplainerSeen'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultReminderRules': serializer.toJson<String>(defaultReminderRules),
      'workingHours': serializer.toJson<String>(workingHours),
      'slotMinutes': serializer.toJson<int>(slotMinutes),
      'defaultTurnaroundDays': serializer.toJson<int>(defaultTurnaroundDays),
      'dailyAgendaMinutes': serializer.toJson<int>(dailyAgendaMinutes),
      'dailyAgendaEnabled': serializer.toJson<bool>(dailyAgendaEnabled),
      'languageCode': serializer.toJson<String>(languageCode),
      'readyNudgeDays': serializer.toJson<int>(readyNudgeDays),
      'overdueNudgesEnabled': serializer.toJson<bool>(overdueNudgesEnabled),
      'templates': serializer.toJson<String>(templates),
      'batteryExplainerSeen': serializer.toJson<bool>(batteryExplainerSeen),
    };
  }

  AppSetting copyWith({
    int? id,
    String? defaultReminderRules,
    String? workingHours,
    int? slotMinutes,
    int? defaultTurnaroundDays,
    int? dailyAgendaMinutes,
    bool? dailyAgendaEnabled,
    String? languageCode,
    int? readyNudgeDays,
    bool? overdueNudgesEnabled,
    String? templates,
    bool? batteryExplainerSeen,
  }) => AppSetting(
    id: id ?? this.id,
    defaultReminderRules: defaultReminderRules ?? this.defaultReminderRules,
    workingHours: workingHours ?? this.workingHours,
    slotMinutes: slotMinutes ?? this.slotMinutes,
    defaultTurnaroundDays: defaultTurnaroundDays ?? this.defaultTurnaroundDays,
    dailyAgendaMinutes: dailyAgendaMinutes ?? this.dailyAgendaMinutes,
    dailyAgendaEnabled: dailyAgendaEnabled ?? this.dailyAgendaEnabled,
    languageCode: languageCode ?? this.languageCode,
    readyNudgeDays: readyNudgeDays ?? this.readyNudgeDays,
    overdueNudgesEnabled: overdueNudgesEnabled ?? this.overdueNudgesEnabled,
    templates: templates ?? this.templates,
    batteryExplainerSeen: batteryExplainerSeen ?? this.batteryExplainerSeen,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      defaultReminderRules: data.defaultReminderRules.present
          ? data.defaultReminderRules.value
          : this.defaultReminderRules,
      workingHours: data.workingHours.present
          ? data.workingHours.value
          : this.workingHours,
      slotMinutes: data.slotMinutes.present
          ? data.slotMinutes.value
          : this.slotMinutes,
      defaultTurnaroundDays: data.defaultTurnaroundDays.present
          ? data.defaultTurnaroundDays.value
          : this.defaultTurnaroundDays,
      dailyAgendaMinutes: data.dailyAgendaMinutes.present
          ? data.dailyAgendaMinutes.value
          : this.dailyAgendaMinutes,
      dailyAgendaEnabled: data.dailyAgendaEnabled.present
          ? data.dailyAgendaEnabled.value
          : this.dailyAgendaEnabled,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      readyNudgeDays: data.readyNudgeDays.present
          ? data.readyNudgeDays.value
          : this.readyNudgeDays,
      overdueNudgesEnabled: data.overdueNudgesEnabled.present
          ? data.overdueNudgesEnabled.value
          : this.overdueNudgesEnabled,
      templates: data.templates.present ? data.templates.value : this.templates,
      batteryExplainerSeen: data.batteryExplainerSeen.present
          ? data.batteryExplainerSeen.value
          : this.batteryExplainerSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('defaultReminderRules: $defaultReminderRules, ')
          ..write('workingHours: $workingHours, ')
          ..write('slotMinutes: $slotMinutes, ')
          ..write('defaultTurnaroundDays: $defaultTurnaroundDays, ')
          ..write('dailyAgendaMinutes: $dailyAgendaMinutes, ')
          ..write('dailyAgendaEnabled: $dailyAgendaEnabled, ')
          ..write('languageCode: $languageCode, ')
          ..write('readyNudgeDays: $readyNudgeDays, ')
          ..write('overdueNudgesEnabled: $overdueNudgesEnabled, ')
          ..write('templates: $templates, ')
          ..write('batteryExplainerSeen: $batteryExplainerSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultReminderRules,
    workingHours,
    slotMinutes,
    defaultTurnaroundDays,
    dailyAgendaMinutes,
    dailyAgendaEnabled,
    languageCode,
    readyNudgeDays,
    overdueNudgesEnabled,
    templates,
    batteryExplainerSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.defaultReminderRules == this.defaultReminderRules &&
          other.workingHours == this.workingHours &&
          other.slotMinutes == this.slotMinutes &&
          other.defaultTurnaroundDays == this.defaultTurnaroundDays &&
          other.dailyAgendaMinutes == this.dailyAgendaMinutes &&
          other.dailyAgendaEnabled == this.dailyAgendaEnabled &&
          other.languageCode == this.languageCode &&
          other.readyNudgeDays == this.readyNudgeDays &&
          other.overdueNudgesEnabled == this.overdueNudgesEnabled &&
          other.templates == this.templates &&
          other.batteryExplainerSeen == this.batteryExplainerSeen);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> defaultReminderRules;
  final Value<String> workingHours;
  final Value<int> slotMinutes;
  final Value<int> defaultTurnaroundDays;
  final Value<int> dailyAgendaMinutes;
  final Value<bool> dailyAgendaEnabled;
  final Value<String> languageCode;
  final Value<int> readyNudgeDays;
  final Value<bool> overdueNudgesEnabled;
  final Value<String> templates;
  final Value<bool> batteryExplainerSeen;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultReminderRules = const Value.absent(),
    this.workingHours = const Value.absent(),
    this.slotMinutes = const Value.absent(),
    this.defaultTurnaroundDays = const Value.absent(),
    this.dailyAgendaMinutes = const Value.absent(),
    this.dailyAgendaEnabled = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.readyNudgeDays = const Value.absent(),
    this.overdueNudgesEnabled = const Value.absent(),
    this.templates = const Value.absent(),
    this.batteryExplainerSeen = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String defaultReminderRules,
    required String workingHours,
    this.slotMinutes = const Value.absent(),
    this.defaultTurnaroundDays = const Value.absent(),
    this.dailyAgendaMinutes = const Value.absent(),
    this.dailyAgendaEnabled = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.readyNudgeDays = const Value.absent(),
    this.overdueNudgesEnabled = const Value.absent(),
    required String templates,
    this.batteryExplainerSeen = const Value.absent(),
  }) : defaultReminderRules = Value(defaultReminderRules),
       workingHours = Value(workingHours),
       templates = Value(templates);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? defaultReminderRules,
    Expression<String>? workingHours,
    Expression<int>? slotMinutes,
    Expression<int>? defaultTurnaroundDays,
    Expression<int>? dailyAgendaMinutes,
    Expression<bool>? dailyAgendaEnabled,
    Expression<String>? languageCode,
    Expression<int>? readyNudgeDays,
    Expression<bool>? overdueNudgesEnabled,
    Expression<String>? templates,
    Expression<bool>? batteryExplainerSeen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultReminderRules != null)
        'default_reminder_rules': defaultReminderRules,
      if (workingHours != null) 'working_hours': workingHours,
      if (slotMinutes != null) 'slot_minutes': slotMinutes,
      if (defaultTurnaroundDays != null)
        'default_turnaround_days': defaultTurnaroundDays,
      if (dailyAgendaMinutes != null)
        'daily_agenda_minutes': dailyAgendaMinutes,
      if (dailyAgendaEnabled != null)
        'daily_agenda_enabled': dailyAgendaEnabled,
      if (languageCode != null) 'language_code': languageCode,
      if (readyNudgeDays != null) 'ready_nudge_days': readyNudgeDays,
      if (overdueNudgesEnabled != null)
        'overdue_nudges_enabled': overdueNudgesEnabled,
      if (templates != null) 'templates': templates,
      if (batteryExplainerSeen != null)
        'battery_explainer_seen': batteryExplainerSeen,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? defaultReminderRules,
    Value<String>? workingHours,
    Value<int>? slotMinutes,
    Value<int>? defaultTurnaroundDays,
    Value<int>? dailyAgendaMinutes,
    Value<bool>? dailyAgendaEnabled,
    Value<String>? languageCode,
    Value<int>? readyNudgeDays,
    Value<bool>? overdueNudgesEnabled,
    Value<String>? templates,
    Value<bool>? batteryExplainerSeen,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      defaultReminderRules: defaultReminderRules ?? this.defaultReminderRules,
      workingHours: workingHours ?? this.workingHours,
      slotMinutes: slotMinutes ?? this.slotMinutes,
      defaultTurnaroundDays:
          defaultTurnaroundDays ?? this.defaultTurnaroundDays,
      dailyAgendaMinutes: dailyAgendaMinutes ?? this.dailyAgendaMinutes,
      dailyAgendaEnabled: dailyAgendaEnabled ?? this.dailyAgendaEnabled,
      languageCode: languageCode ?? this.languageCode,
      readyNudgeDays: readyNudgeDays ?? this.readyNudgeDays,
      overdueNudgesEnabled: overdueNudgesEnabled ?? this.overdueNudgesEnabled,
      templates: templates ?? this.templates,
      batteryExplainerSeen: batteryExplainerSeen ?? this.batteryExplainerSeen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultReminderRules.present) {
      map['default_reminder_rules'] = Variable<String>(
        defaultReminderRules.value,
      );
    }
    if (workingHours.present) {
      map['working_hours'] = Variable<String>(workingHours.value);
    }
    if (slotMinutes.present) {
      map['slot_minutes'] = Variable<int>(slotMinutes.value);
    }
    if (defaultTurnaroundDays.present) {
      map['default_turnaround_days'] = Variable<int>(
        defaultTurnaroundDays.value,
      );
    }
    if (dailyAgendaMinutes.present) {
      map['daily_agenda_minutes'] = Variable<int>(dailyAgendaMinutes.value);
    }
    if (dailyAgendaEnabled.present) {
      map['daily_agenda_enabled'] = Variable<bool>(dailyAgendaEnabled.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (readyNudgeDays.present) {
      map['ready_nudge_days'] = Variable<int>(readyNudgeDays.value);
    }
    if (overdueNudgesEnabled.present) {
      map['overdue_nudges_enabled'] = Variable<bool>(
        overdueNudgesEnabled.value,
      );
    }
    if (templates.present) {
      map['templates'] = Variable<String>(templates.value);
    }
    if (batteryExplainerSeen.present) {
      map['battery_explainer_seen'] = Variable<bool>(
        batteryExplainerSeen.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultReminderRules: $defaultReminderRules, ')
          ..write('workingHours: $workingHours, ')
          ..write('slotMinutes: $slotMinutes, ')
          ..write('defaultTurnaroundDays: $defaultTurnaroundDays, ')
          ..write('dailyAgendaMinutes: $dailyAgendaMinutes, ')
          ..write('dailyAgendaEnabled: $dailyAgendaEnabled, ')
          ..write('languageCode: $languageCode, ')
          ..write('readyNudgeDays: $readyNudgeDays, ')
          ..write('overdueNudgesEnabled: $overdueNudgesEnabled, ')
          ..write('templates: $templates, ')
          ..write('batteryExplainerSeen: $batteryExplainerSeen')
          ..write(')'))
        .toString();
  }
}

class $PendingNotificationsTable extends PendingNotifications
    with TableInfo<$PendingNotificationsTable, PendingNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingNotificationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _appointmentIdMeta = const VerificationMeta(
    'appointmentId',
  );
  @override
  late final GeneratedColumn<int> appointmentId = GeneratedColumn<int>(
    'appointment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredMeta = const VerificationMeta(
    'registered',
  );
  @override
  late final GeneratedColumn<bool> registered = GeneratedColumn<bool>(
    'registered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("registered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appointmentId,
    jobId,
    kind,
    dedupeKey,
    fireAt,
    title,
    body,
    payload,
    registered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
        _appointmentIdMeta,
        appointmentId.isAcceptableOrUnknown(
          data['appointment_id']!,
          _appointmentIdMeta,
        ),
      );
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('registered')) {
      context.handle(
        _registeredMeta,
        registered.isAcceptableOrUnknown(data['registered']!, _registeredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      appointmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}appointment_id'],
      ),
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      registered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}registered'],
      )!,
    );
  }

  @override
  $PendingNotificationsTable createAlias(String alias) {
    return $PendingNotificationsTable(attachedDatabase, alias);
  }
}

class PendingNotification extends DataClass
    implements Insertable<PendingNotification> {
  final int id;
  final int? appointmentId;
  final int? jobId;

  /// `reminder` | `agenda` | `overdueCollection` | `readyNudge`.
  final String kind;

  /// Stable identity for one planned notification, used to diff a rebuild
  /// against what is already scheduled.
  final String dedupeKey;
  final DateTime fireAt;
  final String title;
  final String body;
  final String? payload;
  final bool registered;
  const PendingNotification({
    required this.id,
    this.appointmentId,
    this.jobId,
    required this.kind,
    required this.dedupeKey,
    required this.fireAt,
    required this.title,
    required this.body,
    this.payload,
    required this.registered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || appointmentId != null) {
      map['appointment_id'] = Variable<int>(appointmentId);
    }
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<int>(jobId);
    }
    map['kind'] = Variable<String>(kind);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['registered'] = Variable<bool>(registered);
    return map;
  }

  PendingNotificationsCompanion toCompanion(bool nullToAbsent) {
    return PendingNotificationsCompanion(
      id: Value(id),
      appointmentId: appointmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentId),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      kind: Value(kind),
      dedupeKey: Value(dedupeKey),
      fireAt: Value(fireAt),
      title: Value(title),
      body: Value(body),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      registered: Value(registered),
    );
  }

  factory PendingNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingNotification(
      id: serializer.fromJson<int>(json['id']),
      appointmentId: serializer.fromJson<int?>(json['appointmentId']),
      jobId: serializer.fromJson<int?>(json['jobId']),
      kind: serializer.fromJson<String>(json['kind']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payload: serializer.fromJson<String?>(json['payload']),
      registered: serializer.fromJson<bool>(json['registered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appointmentId': serializer.toJson<int?>(appointmentId),
      'jobId': serializer.toJson<int?>(jobId),
      'kind': serializer.toJson<String>(kind),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payload': serializer.toJson<String?>(payload),
      'registered': serializer.toJson<bool>(registered),
    };
  }

  PendingNotification copyWith({
    int? id,
    Value<int?> appointmentId = const Value.absent(),
    Value<int?> jobId = const Value.absent(),
    String? kind,
    String? dedupeKey,
    DateTime? fireAt,
    String? title,
    String? body,
    Value<String?> payload = const Value.absent(),
    bool? registered,
  }) => PendingNotification(
    id: id ?? this.id,
    appointmentId: appointmentId.present
        ? appointmentId.value
        : this.appointmentId,
    jobId: jobId.present ? jobId.value : this.jobId,
    kind: kind ?? this.kind,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    fireAt: fireAt ?? this.fireAt,
    title: title ?? this.title,
    body: body ?? this.body,
    payload: payload.present ? payload.value : this.payload,
    registered: registered ?? this.registered,
  );
  PendingNotification copyWithCompanion(PendingNotificationsCompanion data) {
    return PendingNotification(
      id: data.id.present ? data.id.value : this.id,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      kind: data.kind.present ? data.kind.value : this.kind,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payload: data.payload.present ? data.payload.value : this.payload,
      registered: data.registered.present
          ? data.registered.value
          : this.registered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingNotification(')
          ..write('id: $id, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('jobId: $jobId, ')
          ..write('kind: $kind, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('fireAt: $fireAt, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('registered: $registered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appointmentId,
    jobId,
    kind,
    dedupeKey,
    fireAt,
    title,
    body,
    payload,
    registered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingNotification &&
          other.id == this.id &&
          other.appointmentId == this.appointmentId &&
          other.jobId == this.jobId &&
          other.kind == this.kind &&
          other.dedupeKey == this.dedupeKey &&
          other.fireAt == this.fireAt &&
          other.title == this.title &&
          other.body == this.body &&
          other.payload == this.payload &&
          other.registered == this.registered);
}

class PendingNotificationsCompanion
    extends UpdateCompanion<PendingNotification> {
  final Value<int> id;
  final Value<int?> appointmentId;
  final Value<int?> jobId;
  final Value<String> kind;
  final Value<String> dedupeKey;
  final Value<DateTime> fireAt;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> payload;
  final Value<bool> registered;
  const PendingNotificationsCompanion({
    this.id = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.jobId = const Value.absent(),
    this.kind = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.registered = const Value.absent(),
  });
  PendingNotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.jobId = const Value.absent(),
    required String kind,
    required String dedupeKey,
    required DateTime fireAt,
    required String title,
    required String body,
    this.payload = const Value.absent(),
    this.registered = const Value.absent(),
  }) : kind = Value(kind),
       dedupeKey = Value(dedupeKey),
       fireAt = Value(fireAt),
       title = Value(title),
       body = Value(body);
  static Insertable<PendingNotification> custom({
    Expression<int>? id,
    Expression<int>? appointmentId,
    Expression<int>? jobId,
    Expression<String>? kind,
    Expression<String>? dedupeKey,
    Expression<DateTime>? fireAt,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payload,
    Expression<bool>? registered,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (jobId != null) 'job_id': jobId,
      if (kind != null) 'kind': kind,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (fireAt != null) 'fire_at': fireAt,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payload != null) 'payload': payload,
      if (registered != null) 'registered': registered,
    });
  }

  PendingNotificationsCompanion copyWith({
    Value<int>? id,
    Value<int?>? appointmentId,
    Value<int?>? jobId,
    Value<String>? kind,
    Value<String>? dedupeKey,
    Value<DateTime>? fireAt,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? payload,
    Value<bool>? registered,
  }) {
    return PendingNotificationsCompanion(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      jobId: jobId ?? this.jobId,
      kind: kind ?? this.kind,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      fireAt: fireAt ?? this.fireAt,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      registered: registered ?? this.registered,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<int>(appointmentId.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (registered.present) {
      map['registered'] = Variable<bool>(registered.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('jobId: $jobId, ')
          ..write('kind: $kind, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('fireAt: $fireAt, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('registered: $registered')
          ..write(')'))
        .toString();
  }
}

class $ImportedMessagesTable extends ImportedMessages
    with TableInfo<$ImportedMessagesTable, ImportedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [fingerprint, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
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
  Set<GeneratedColumn> get $primaryKey => {fingerprint};
  @override
  ImportedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedMessage(
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ImportedMessagesTable createAlias(String alias) {
    return $ImportedMessagesTable(attachedDatabase, alias);
  }
}

class ImportedMessage extends DataClass implements Insertable<ImportedMessage> {
  final String fingerprint;
  final DateTime importedAt;
  const ImportedMessage({required this.fingerprint, required this.importedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fingerprint'] = Variable<String>(fingerprint);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ImportedMessagesCompanion toCompanion(bool nullToAbsent) {
    return ImportedMessagesCompanion(
      fingerprint: Value(fingerprint),
      importedAt: Value(importedAt),
    );
  }

  factory ImportedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedMessage(
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fingerprint': serializer.toJson<String>(fingerprint),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ImportedMessage copyWith({String? fingerprint, DateTime? importedAt}) =>
      ImportedMessage(
        fingerprint: fingerprint ?? this.fingerprint,
        importedAt: importedAt ?? this.importedAt,
      );
  ImportedMessage copyWithCompanion(ImportedMessagesCompanion data) {
    return ImportedMessage(
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedMessage(')
          ..write('fingerprint: $fingerprint, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fingerprint, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedMessage &&
          other.fingerprint == this.fingerprint &&
          other.importedAt == this.importedAt);
}

class ImportedMessagesCompanion extends UpdateCompanion<ImportedMessage> {
  final Value<String> fingerprint;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const ImportedMessagesCompanion({
    this.fingerprint = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedMessagesCompanion.insert({
    required String fingerprint,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : fingerprint = Value(fingerprint),
       importedAt = Value(importedAt);
  static Insertable<ImportedMessage> custom({
    Expression<String>? fingerprint,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedMessagesCompanion copyWith({
    Value<String>? fingerprint,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return ImportedMessagesCompanion(
      fingerprint: fingerprint ?? this.fingerprint,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
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
    return (StringBuffer('ImportedMessagesCompanion(')
          ..write('fingerprint: $fingerprint, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $BlockedDatesTable blockedDates = $BlockedDatesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PendingNotificationsTable pendingNotifications =
      $PendingNotificationsTable(this);
  late final $ImportedMessagesTable importedMessages = $ImportedMessagesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    jobs,
    appointments,
    blockedDates,
    appSettings,
    pendingNotifications,
    importedMessages,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('jobs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('appointments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phone,
      Value<String?> whatsappNumber,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> whatsappNumber,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'customers__id__jobs__customer_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsappNumber => $composableBuilder(
    column: $table.whatsappNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsappNumber => $composableBuilder(
    column: $table.whatsappNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get whatsappNumber => $composableBuilder(
    column: $table.whatsappNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool jobsRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> whatsappNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                whatsappNumber: whatsappNumber,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> whatsappNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                whatsappNumber: whatsappNumber,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (jobsRefs) db.jobs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (jobsRefs)
                    await $_getPrefetchedData<Customer, $CustomersTable, Job>(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._jobsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(db, table, p0).jobsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool jobsRefs})
    >;
typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      required int customerId,
      required ServiceType service,
      Value<String?> serviceFreeText,
      Value<String?> itemDescription,
      Value<int> quantity,
      Value<double?> quotedPrice,
      Value<double?> depositPaid,
      required JobStatus status,
      Value<bool> isRush,
      Value<String?> notes,
      Value<String?> rawMessage,
      required DateTime createdAt,
      Value<DateTime?> readyAt,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<ServiceType> service,
      Value<String?> serviceFreeText,
      Value<String?> itemDescription,
      Value<int> quantity,
      Value<double?> quotedPrice,
      Value<double?> depositPaid,
      Value<JobStatus> status,
      Value<bool> isRush,
      Value<String?> notes,
      Value<String?> rawMessage,
      Value<DateTime> createdAt,
      Value<DateTime?> readyAt,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, Job> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('jobs__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
  _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appointments,
    aliasName: 'jobs__id__appointments__job_id',
  );

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager(
      $_db,
      $_db.appointments,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ServiceType, ServiceType, String>
  get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get serviceFreeText => $composableBuilder(
    column: $table.serviceFreeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quotedPrice => $composableBuilder(
    column: $table.quotedPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depositPaid => $composableBuilder(
    column: $table.depositPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobStatus, JobStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isRush => $composableBuilder(
    column: $table.isRush,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> appointmentsRefs(
    Expression<bool> Function($$AppointmentsTableFilterComposer f) f,
  ) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableFilterComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
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

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceFreeText => $composableBuilder(
    column: $table.serviceFreeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quotedPrice => $composableBuilder(
    column: $table.quotedPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depositPaid => $composableBuilder(
    column: $table.depositPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRush => $composableBuilder(
    column: $table.isRush,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ServiceType, String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get serviceFreeText => $composableBuilder(
    column: $table.serviceFreeText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get quotedPrice => $composableBuilder(
    column: $table.quotedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get depositPaid => $composableBuilder(
    column: $table.depositPaid,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<JobStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isRush =>
      $composableBuilder(column: $table.isRush, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readyAt =>
      $composableBuilder(column: $table.readyAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> appointmentsRefs<T extends Object>(
    Expression<T> Function($$AppointmentsTableAnnotationComposer a) f,
  ) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, $$JobsTableReferences),
          Job,
          PrefetchHooks Function({bool customerId, bool appointmentsRefs})
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<ServiceType> service = const Value.absent(),
                Value<String?> serviceFreeText = const Value.absent(),
                Value<String?> itemDescription = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double?> quotedPrice = const Value.absent(),
                Value<double?> depositPaid = const Value.absent(),
                Value<JobStatus> status = const Value.absent(),
                Value<bool> isRush = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> rawMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> readyAt = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                customerId: customerId,
                service: service,
                serviceFreeText: serviceFreeText,
                itemDescription: itemDescription,
                quantity: quantity,
                quotedPrice: quotedPrice,
                depositPaid: depositPaid,
                status: status,
                isRush: isRush,
                notes: notes,
                rawMessage: rawMessage,
                createdAt: createdAt,
                readyAt: readyAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required ServiceType service,
                Value<String?> serviceFreeText = const Value.absent(),
                Value<String?> itemDescription = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double?> quotedPrice = const Value.absent(),
                Value<double?> depositPaid = const Value.absent(),
                required JobStatus status,
                Value<bool> isRush = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> rawMessage = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> readyAt = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                customerId: customerId,
                service: service,
                serviceFreeText: serviceFreeText,
                itemDescription: itemDescription,
                quantity: quantity,
                quotedPrice: quotedPrice,
                depositPaid: depositPaid,
                status: status,
                isRush: isRush,
                notes: notes,
                rawMessage: rawMessage,
                createdAt: createdAt,
                readyAt: readyAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JobsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, appointmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (appointmentsRefs) db.appointments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$JobsTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (appointmentsRefs)
                        await $_getPrefetchedData<Job, $JobsTable, Appointment>(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._appointmentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).appointmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, $$JobsTableReferences),
      Job,
      PrefetchHooks Function({bool customerId, bool appointmentsRefs})
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      required int jobId,
      required AppointmentType type,
      required DateTime scheduledAt,
      Value<int> durationMinutes,
      required AppointmentStatus status,
      Value<String?> reminderRules,
      Value<String?> notes,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      Value<int> jobId,
      Value<AppointmentType> type,
      Value<DateTime> scheduledAt,
      Value<int> durationMinutes,
      Value<AppointmentStatus> status,
      Value<String?> reminderRules,
      Value<String?> notes,
    });

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('appointments__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<AppointmentType, AppointmentType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppointmentStatus, AppointmentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reminderRules => $composableBuilder(
    column: $table.reminderRules,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderRules => $composableBuilder(
    column: $table.reminderRules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppointmentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AppointmentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reminderRules => $composableBuilder(
    column: $table.reminderRules,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (Appointment, $$AppointmentsTableReferences),
          Appointment,
          PrefetchHooks Function({bool jobId})
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<AppointmentType> type = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<AppointmentStatus> status = const Value.absent(),
                Value<String?> reminderRules = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                jobId: jobId,
                type: type,
                scheduledAt: scheduledAt,
                durationMinutes: durationMinutes,
                status: status,
                reminderRules: reminderRules,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required AppointmentType type,
                required DateTime scheduledAt,
                Value<int> durationMinutes = const Value.absent(),
                required AppointmentStatus status,
                Value<String?> reminderRules = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                jobId: jobId,
                type: type,
                scheduledAt: scheduledAt,
                durationMinutes: durationMinutes,
                status: status,
                reminderRules: reminderRules,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppointmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$AppointmentsTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$AppointmentsTableReferences
                                    ._jobIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (Appointment, $$AppointmentsTableReferences),
      Appointment,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$BlockedDatesTableCreateCompanionBuilder =
    BlockedDatesCompanion Function({
      required String day,
      Value<String?> reason,
      Value<int> rowid,
    });
typedef $$BlockedDatesTableUpdateCompanionBuilder =
    BlockedDatesCompanion Function({
      Value<String> day,
      Value<String?> reason,
      Value<int> rowid,
    });

class $$BlockedDatesTableFilterComposer
    extends Composer<_$AppDatabase, $BlockedDatesTable> {
  $$BlockedDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockedDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockedDatesTable> {
  $$BlockedDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockedDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockedDatesTable> {
  $$BlockedDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$BlockedDatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockedDatesTable,
          BlockedDate,
          $$BlockedDatesTableFilterComposer,
          $$BlockedDatesTableOrderingComposer,
          $$BlockedDatesTableAnnotationComposer,
          $$BlockedDatesTableCreateCompanionBuilder,
          $$BlockedDatesTableUpdateCompanionBuilder,
          (
            BlockedDate,
            BaseReferences<_$AppDatabase, $BlockedDatesTable, BlockedDate>,
          ),
          BlockedDate,
          PrefetchHooks Function()
        > {
  $$BlockedDatesTableTableManager(_$AppDatabase db, $BlockedDatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockedDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockedDatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockedDatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  BlockedDatesCompanion(day: day, reason: reason, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockedDatesCompanion.insert(
                day: day,
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

typedef $$BlockedDatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockedDatesTable,
      BlockedDate,
      $$BlockedDatesTableFilterComposer,
      $$BlockedDatesTableOrderingComposer,
      $$BlockedDatesTableAnnotationComposer,
      $$BlockedDatesTableCreateCompanionBuilder,
      $$BlockedDatesTableUpdateCompanionBuilder,
      (
        BlockedDate,
        BaseReferences<_$AppDatabase, $BlockedDatesTable, BlockedDate>,
      ),
      BlockedDate,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required String defaultReminderRules,
      required String workingHours,
      Value<int> slotMinutes,
      Value<int> defaultTurnaroundDays,
      Value<int> dailyAgendaMinutes,
      Value<bool> dailyAgendaEnabled,
      Value<String> languageCode,
      Value<int> readyNudgeDays,
      Value<bool> overdueNudgesEnabled,
      required String templates,
      Value<bool> batteryExplainerSeen,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> defaultReminderRules,
      Value<String> workingHours,
      Value<int> slotMinutes,
      Value<int> defaultTurnaroundDays,
      Value<int> dailyAgendaMinutes,
      Value<bool> dailyAgendaEnabled,
      Value<String> languageCode,
      Value<int> readyNudgeDays,
      Value<bool> overdueNudgesEnabled,
      Value<String> templates,
      Value<bool> batteryExplainerSeen,
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultReminderRules => $composableBuilder(
    column: $table.defaultReminderRules,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotMinutes => $composableBuilder(
    column: $table.slotMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTurnaroundDays => $composableBuilder(
    column: $table.defaultTurnaroundDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyAgendaMinutes => $composableBuilder(
    column: $table.dailyAgendaMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyAgendaEnabled => $composableBuilder(
    column: $table.dailyAgendaEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readyNudgeDays => $composableBuilder(
    column: $table.readyNudgeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get overdueNudgesEnabled => $composableBuilder(
    column: $table.overdueNudgesEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templates => $composableBuilder(
    column: $table.templates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get batteryExplainerSeen => $composableBuilder(
    column: $table.batteryExplainerSeen,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultReminderRules => $composableBuilder(
    column: $table.defaultReminderRules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotMinutes => $composableBuilder(
    column: $table.slotMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTurnaroundDays => $composableBuilder(
    column: $table.defaultTurnaroundDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyAgendaMinutes => $composableBuilder(
    column: $table.dailyAgendaMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyAgendaEnabled => $composableBuilder(
    column: $table.dailyAgendaEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readyNudgeDays => $composableBuilder(
    column: $table.readyNudgeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get overdueNudgesEnabled => $composableBuilder(
    column: $table.overdueNudgesEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templates => $composableBuilder(
    column: $table.templates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get batteryExplainerSeen => $composableBuilder(
    column: $table.batteryExplainerSeen,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get defaultReminderRules => $composableBuilder(
    column: $table.defaultReminderRules,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slotMinutes => $composableBuilder(
    column: $table.slotMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTurnaroundDays => $composableBuilder(
    column: $table.defaultTurnaroundDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyAgendaMinutes => $composableBuilder(
    column: $table.dailyAgendaMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dailyAgendaEnabled => $composableBuilder(
    column: $table.dailyAgendaEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readyNudgeDays => $composableBuilder(
    column: $table.readyNudgeDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get overdueNudgesEnabled => $composableBuilder(
    column: $table.overdueNudgesEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templates =>
      $composableBuilder(column: $table.templates, builder: (column) => column);

  GeneratedColumn<bool> get batteryExplainerSeen => $composableBuilder(
    column: $table.batteryExplainerSeen,
    builder: (column) => column,
  );
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
                Value<int> id = const Value.absent(),
                Value<String> defaultReminderRules = const Value.absent(),
                Value<String> workingHours = const Value.absent(),
                Value<int> slotMinutes = const Value.absent(),
                Value<int> defaultTurnaroundDays = const Value.absent(),
                Value<int> dailyAgendaMinutes = const Value.absent(),
                Value<bool> dailyAgendaEnabled = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<int> readyNudgeDays = const Value.absent(),
                Value<bool> overdueNudgesEnabled = const Value.absent(),
                Value<String> templates = const Value.absent(),
                Value<bool> batteryExplainerSeen = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                defaultReminderRules: defaultReminderRules,
                workingHours: workingHours,
                slotMinutes: slotMinutes,
                defaultTurnaroundDays: defaultTurnaroundDays,
                dailyAgendaMinutes: dailyAgendaMinutes,
                dailyAgendaEnabled: dailyAgendaEnabled,
                languageCode: languageCode,
                readyNudgeDays: readyNudgeDays,
                overdueNudgesEnabled: overdueNudgesEnabled,
                templates: templates,
                batteryExplainerSeen: batteryExplainerSeen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String defaultReminderRules,
                required String workingHours,
                Value<int> slotMinutes = const Value.absent(),
                Value<int> defaultTurnaroundDays = const Value.absent(),
                Value<int> dailyAgendaMinutes = const Value.absent(),
                Value<bool> dailyAgendaEnabled = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<int> readyNudgeDays = const Value.absent(),
                Value<bool> overdueNudgesEnabled = const Value.absent(),
                required String templates,
                Value<bool> batteryExplainerSeen = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                defaultReminderRules: defaultReminderRules,
                workingHours: workingHours,
                slotMinutes: slotMinutes,
                defaultTurnaroundDays: defaultTurnaroundDays,
                dailyAgendaMinutes: dailyAgendaMinutes,
                dailyAgendaEnabled: dailyAgendaEnabled,
                languageCode: languageCode,
                readyNudgeDays: readyNudgeDays,
                overdueNudgesEnabled: overdueNudgesEnabled,
                templates: templates,
                batteryExplainerSeen: batteryExplainerSeen,
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
typedef $$PendingNotificationsTableCreateCompanionBuilder =
    PendingNotificationsCompanion Function({
      Value<int> id,
      Value<int?> appointmentId,
      Value<int?> jobId,
      required String kind,
      required String dedupeKey,
      required DateTime fireAt,
      required String title,
      required String body,
      Value<String?> payload,
      Value<bool> registered,
    });
typedef $$PendingNotificationsTableUpdateCompanionBuilder =
    PendingNotificationsCompanion Function({
      Value<int> id,
      Value<int?> appointmentId,
      Value<int?> jobId,
      Value<String> kind,
      Value<String> dedupeKey,
      Value<DateTime> fireAt,
      Value<String> title,
      Value<String> body,
      Value<String?> payload,
      Value<bool> registered,
    });

class $$PendingNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingNotificationsTable> {
  $$PendingNotificationsTableFilterComposer({
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

  ColumnFilters<int> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get registered => $composableBuilder(
    column: $table.registered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingNotificationsTable> {
  $$PendingNotificationsTableOrderingComposer({
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

  ColumnOrderings<int> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get registered => $composableBuilder(
    column: $table.registered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingNotificationsTable> {
  $$PendingNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get registered => $composableBuilder(
    column: $table.registered,
    builder: (column) => column,
  );
}

class $$PendingNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingNotificationsTable,
          PendingNotification,
          $$PendingNotificationsTableFilterComposer,
          $$PendingNotificationsTableOrderingComposer,
          $$PendingNotificationsTableAnnotationComposer,
          $$PendingNotificationsTableCreateCompanionBuilder,
          $$PendingNotificationsTableUpdateCompanionBuilder,
          (
            PendingNotification,
            BaseReferences<
              _$AppDatabase,
              $PendingNotificationsTable,
              PendingNotification
            >,
          ),
          PendingNotification,
          PrefetchHooks Function()
        > {
  $$PendingNotificationsTableTableManager(
    _$AppDatabase db,
    $PendingNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> appointmentId = const Value.absent(),
                Value<int?> jobId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<bool> registered = const Value.absent(),
              }) => PendingNotificationsCompanion(
                id: id,
                appointmentId: appointmentId,
                jobId: jobId,
                kind: kind,
                dedupeKey: dedupeKey,
                fireAt: fireAt,
                title: title,
                body: body,
                payload: payload,
                registered: registered,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> appointmentId = const Value.absent(),
                Value<int?> jobId = const Value.absent(),
                required String kind,
                required String dedupeKey,
                required DateTime fireAt,
                required String title,
                required String body,
                Value<String?> payload = const Value.absent(),
                Value<bool> registered = const Value.absent(),
              }) => PendingNotificationsCompanion.insert(
                id: id,
                appointmentId: appointmentId,
                jobId: jobId,
                kind: kind,
                dedupeKey: dedupeKey,
                fireAt: fireAt,
                title: title,
                body: body,
                payload: payload,
                registered: registered,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingNotificationsTable,
      PendingNotification,
      $$PendingNotificationsTableFilterComposer,
      $$PendingNotificationsTableOrderingComposer,
      $$PendingNotificationsTableAnnotationComposer,
      $$PendingNotificationsTableCreateCompanionBuilder,
      $$PendingNotificationsTableUpdateCompanionBuilder,
      (
        PendingNotification,
        BaseReferences<
          _$AppDatabase,
          $PendingNotificationsTable,
          PendingNotification
        >,
      ),
      PendingNotification,
      PrefetchHooks Function()
    >;
typedef $$ImportedMessagesTableCreateCompanionBuilder =
    ImportedMessagesCompanion Function({
      required String fingerprint,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$ImportedMessagesTableUpdateCompanionBuilder =
    ImportedMessagesCompanion Function({
      Value<String> fingerprint,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$ImportedMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportedMessagesTable> {
  $$ImportedMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportedMessagesTable> {
  $$ImportedMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportedMessagesTable> {
  $$ImportedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$ImportedMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportedMessagesTable,
          ImportedMessage,
          $$ImportedMessagesTableFilterComposer,
          $$ImportedMessagesTableOrderingComposer,
          $$ImportedMessagesTableAnnotationComposer,
          $$ImportedMessagesTableCreateCompanionBuilder,
          $$ImportedMessagesTableUpdateCompanionBuilder,
          (
            ImportedMessage,
            BaseReferences<
              _$AppDatabase,
              $ImportedMessagesTable,
              ImportedMessage
            >,
          ),
          ImportedMessage,
          PrefetchHooks Function()
        > {
  $$ImportedMessagesTableTableManager(
    _$AppDatabase db,
    $ImportedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fingerprint = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedMessagesCompanion(
                fingerprint: fingerprint,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fingerprint,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportedMessagesCompanion.insert(
                fingerprint: fingerprint,
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

typedef $$ImportedMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportedMessagesTable,
      ImportedMessage,
      $$ImportedMessagesTableFilterComposer,
      $$ImportedMessagesTableOrderingComposer,
      $$ImportedMessagesTableAnnotationComposer,
      $$ImportedMessagesTableCreateCompanionBuilder,
      $$ImportedMessagesTableUpdateCompanionBuilder,
      (
        ImportedMessage,
        BaseReferences<_$AppDatabase, $ImportedMessagesTable, ImportedMessage>,
      ),
      ImportedMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$BlockedDatesTableTableManager get blockedDates =>
      $$BlockedDatesTableTableManager(_db, _db.blockedDates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PendingNotificationsTableTableManager get pendingNotifications =>
      $$PendingNotificationsTableTableManager(_db, _db.pendingNotifications);
  $$ImportedMessagesTableTableManager get importedMessages =>
      $$ImportedMessagesTableTableManager(_db, _db.importedMessages);
}
