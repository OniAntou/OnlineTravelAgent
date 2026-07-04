// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DestinationsTableTable extends DestinationsTable
    with TableInfo<$DestinationsTableTable, DestinationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DestinationsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _reviewsCountMeta = const VerificationMeta(
    'reviewsCount',
  );
  @override
  late final GeneratedColumn<String> reviewsCount = GeneratedColumn<String>(
    'reviews_count',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('Địa điểm'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isRecommendedMeta = const VerificationMeta(
    'isRecommended',
  );
  @override
  late final GeneratedColumn<bool> isRecommended = GeneratedColumn<bool>(
    'is_recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recommended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    rating,
    duration,
    imagePath,
    isFavorite,
    description,
    price,
    reviewsCount,
    category,
    latitude,
    longitude,
    isRecommended,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'destinations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DestinationsTableData> instance, {
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
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('reviews_count')) {
      context.handle(
        _reviewsCountMeta,
        reviewsCount.isAcceptableOrUnknown(
          data['reviews_count']!,
          _reviewsCountMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('is_recommended')) {
      context.handle(
        _isRecommendedMeta,
        isRecommended.isAcceptableOrUnknown(
          data['is_recommended']!,
          _isRecommendedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DestinationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DestinationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price'],
      )!,
      reviewsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviews_count'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      isRecommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recommended'],
      )!,
    );
  }

  @override
  $DestinationsTableTable createAlias(String alias) {
    return $DestinationsTableTable(attachedDatabase, alias);
  }
}

class DestinationsTableData extends DataClass
    implements Insertable<DestinationsTableData> {
  final String id;
  final String name;
  final String location;
  final String rating;
  final String duration;
  final String imagePath;
  final bool isFavorite;
  final String description;
  final String price;
  final String reviewsCount;
  final String category;
  final double latitude;
  final double longitude;
  final bool isRecommended;
  const DestinationsTableData({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.duration,
    required this.imagePath,
    required this.isFavorite,
    required this.description,
    required this.price,
    required this.reviewsCount,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.isRecommended,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    map['rating'] = Variable<String>(rating);
    map['duration'] = Variable<String>(duration);
    map['image_path'] = Variable<String>(imagePath);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['description'] = Variable<String>(description);
    map['price'] = Variable<String>(price);
    map['reviews_count'] = Variable<String>(reviewsCount);
    map['category'] = Variable<String>(category);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['is_recommended'] = Variable<bool>(isRecommended);
    return map;
  }

  DestinationsTableCompanion toCompanion(bool nullToAbsent) {
    return DestinationsTableCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      rating: Value(rating),
      duration: Value(duration),
      imagePath: Value(imagePath),
      isFavorite: Value(isFavorite),
      description: Value(description),
      price: Value(price),
      reviewsCount: Value(reviewsCount),
      category: Value(category),
      latitude: Value(latitude),
      longitude: Value(longitude),
      isRecommended: Value(isRecommended),
    );
  }

  factory DestinationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DestinationsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      rating: serializer.fromJson<String>(json['rating']),
      duration: serializer.fromJson<String>(json['duration']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      description: serializer.fromJson<String>(json['description']),
      price: serializer.fromJson<String>(json['price']),
      reviewsCount: serializer.fromJson<String>(json['reviewsCount']),
      category: serializer.fromJson<String>(json['category']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      isRecommended: serializer.fromJson<bool>(json['isRecommended']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'rating': serializer.toJson<String>(rating),
      'duration': serializer.toJson<String>(duration),
      'imagePath': serializer.toJson<String>(imagePath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'description': serializer.toJson<String>(description),
      'price': serializer.toJson<String>(price),
      'reviewsCount': serializer.toJson<String>(reviewsCount),
      'category': serializer.toJson<String>(category),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'isRecommended': serializer.toJson<bool>(isRecommended),
    };
  }

  DestinationsTableData copyWith({
    String? id,
    String? name,
    String? location,
    String? rating,
    String? duration,
    String? imagePath,
    bool? isFavorite,
    String? description,
    String? price,
    String? reviewsCount,
    String? category,
    double? latitude,
    double? longitude,
    bool? isRecommended,
  }) => DestinationsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location ?? this.location,
    rating: rating ?? this.rating,
    duration: duration ?? this.duration,
    imagePath: imagePath ?? this.imagePath,
    isFavorite: isFavorite ?? this.isFavorite,
    description: description ?? this.description,
    price: price ?? this.price,
    reviewsCount: reviewsCount ?? this.reviewsCount,
    category: category ?? this.category,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isRecommended: isRecommended ?? this.isRecommended,
  );
  DestinationsTableData copyWithCompanion(DestinationsTableCompanion data) {
    return DestinationsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      rating: data.rating.present ? data.rating.value : this.rating,
      duration: data.duration.present ? data.duration.value : this.duration,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      reviewsCount: data.reviewsCount.present
          ? data.reviewsCount.value
          : this.reviewsCount,
      category: data.category.present ? data.category.value : this.category,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isRecommended: data.isRecommended.present
          ? data.isRecommended.value
          : this.isRecommended,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DestinationsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('rating: $rating, ')
          ..write('duration: $duration, ')
          ..write('imagePath: $imagePath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isRecommended: $isRecommended')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    rating,
    duration,
    imagePath,
    isFavorite,
    description,
    price,
    reviewsCount,
    category,
    latitude,
    longitude,
    isRecommended,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DestinationsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.rating == this.rating &&
          other.duration == this.duration &&
          other.imagePath == this.imagePath &&
          other.isFavorite == this.isFavorite &&
          other.description == this.description &&
          other.price == this.price &&
          other.reviewsCount == this.reviewsCount &&
          other.category == this.category &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isRecommended == this.isRecommended);
}

class DestinationsTableCompanion
    extends UpdateCompanion<DestinationsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> location;
  final Value<String> rating;
  final Value<String> duration;
  final Value<String> imagePath;
  final Value<bool> isFavorite;
  final Value<String> description;
  final Value<String> price;
  final Value<String> reviewsCount;
  final Value<String> category;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<bool> isRecommended;
  final Value<int> rowid;
  const DestinationsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.rating = const Value.absent(),
    this.duration = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    this.category = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isRecommended = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DestinationsTableCompanion.insert({
    required String id,
    required String name,
    required String location,
    this.rating = const Value.absent(),
    this.duration = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    this.category = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isRecommended = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       location = Value(location);
  static Insertable<DestinationsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? rating,
    Expression<String>? duration,
    Expression<String>? imagePath,
    Expression<bool>? isFavorite,
    Expression<String>? description,
    Expression<String>? price,
    Expression<String>? reviewsCount,
    Expression<String>? category,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? isRecommended,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (rating != null) 'rating': rating,
      if (duration != null) 'duration': duration,
      if (imagePath != null) 'image_path': imagePath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (reviewsCount != null) 'reviews_count': reviewsCount,
      if (category != null) 'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isRecommended != null) 'is_recommended': isRecommended,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DestinationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? location,
    Value<String>? rating,
    Value<String>? duration,
    Value<String>? imagePath,
    Value<bool>? isFavorite,
    Value<String>? description,
    Value<String>? price,
    Value<String>? reviewsCount,
    Value<String>? category,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<bool>? isRecommended,
    Value<int>? rowid,
  }) {
    return DestinationsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      price: price ?? this.price,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRecommended: isRecommended ?? this.isRecommended,
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
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (reviewsCount.present) {
      map['reviews_count'] = Variable<String>(reviewsCount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isRecommended.present) {
      map['is_recommended'] = Variable<bool>(isRecommended.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DestinationsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('rating: $rating, ')
          ..write('duration: $duration, ')
          ..write('imagePath: $imagePath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isRecommended: $isRecommended, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriesTableData> instance, {
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  const CategoriesTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(id: Value(id), name: Value(name));
  }

  factory CategoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoriesTableData copyWith({String? id, String? name}) =>
      CategoriesTableData(id: id ?? this.id, name: name ?? this.name);
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HotelsTableTable extends HotelsTable
    with TableInfo<$HotelsTableTable, HotelsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HotelsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _priceFromMeta = const VerificationMeta(
    'priceFrom',
  );
  @override
  late final GeneratedColumn<double> priceFrom = GeneratedColumn<double>(
    'price_from',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amenitiesMeta = const VerificationMeta(
    'amenities',
  );
  @override
  late final GeneratedColumn<String> amenities = GeneratedColumn<String>(
    'amenities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    latitude,
    longitude,
    rating,
    imagePath,
    description,
    priceFrom,
    address,
    amenities,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hotels_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HotelsTableData> instance, {
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
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
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
    if (data.containsKey('price_from')) {
      context.handle(
        _priceFromMeta,
        priceFrom.isAcceptableOrUnknown(data['price_from']!, _priceFromMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('amenities')) {
      context.handle(
        _amenitiesMeta,
        amenities.isAcceptableOrUnknown(data['amenities']!, _amenitiesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HotelsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HotelsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      priceFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_from'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      amenities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amenities'],
      )!,
    );
  }

  @override
  $HotelsTableTable createAlias(String alias) {
    return $HotelsTableTable(attachedDatabase, alias);
  }
}

class HotelsTableData extends DataClass implements Insertable<HotelsTableData> {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String rating;
  final String imagePath;
  final String description;
  final double priceFrom;
  final String address;
  final String amenities;
  const HotelsTableData({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.imagePath,
    required this.description,
    required this.priceFrom,
    required this.address,
    required this.amenities,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['rating'] = Variable<String>(rating);
    map['image_path'] = Variable<String>(imagePath);
    map['description'] = Variable<String>(description);
    map['price_from'] = Variable<double>(priceFrom);
    map['address'] = Variable<String>(address);
    map['amenities'] = Variable<String>(amenities);
    return map;
  }

  HotelsTableCompanion toCompanion(bool nullToAbsent) {
    return HotelsTableCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      latitude: Value(latitude),
      longitude: Value(longitude),
      rating: Value(rating),
      imagePath: Value(imagePath),
      description: Value(description),
      priceFrom: Value(priceFrom),
      address: Value(address),
      amenities: Value(amenities),
    );
  }

  factory HotelsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HotelsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      rating: serializer.fromJson<String>(json['rating']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      description: serializer.fromJson<String>(json['description']),
      priceFrom: serializer.fromJson<double>(json['priceFrom']),
      address: serializer.fromJson<String>(json['address']),
      amenities: serializer.fromJson<String>(json['amenities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'rating': serializer.toJson<String>(rating),
      'imagePath': serializer.toJson<String>(imagePath),
      'description': serializer.toJson<String>(description),
      'priceFrom': serializer.toJson<double>(priceFrom),
      'address': serializer.toJson<String>(address),
      'amenities': serializer.toJson<String>(amenities),
    };
  }

  HotelsTableData copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    String? rating,
    String? imagePath,
    String? description,
    double? priceFrom,
    String? address,
    String? amenities,
  }) => HotelsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location ?? this.location,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    rating: rating ?? this.rating,
    imagePath: imagePath ?? this.imagePath,
    description: description ?? this.description,
    priceFrom: priceFrom ?? this.priceFrom,
    address: address ?? this.address,
    amenities: amenities ?? this.amenities,
  );
  HotelsTableData copyWithCompanion(HotelsTableCompanion data) {
    return HotelsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      rating: data.rating.present ? data.rating.value : this.rating,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      description: data.description.present
          ? data.description.value
          : this.description,
      priceFrom: data.priceFrom.present ? data.priceFrom.value : this.priceFrom,
      address: data.address.present ? data.address.value : this.address,
      amenities: data.amenities.present ? data.amenities.value : this.amenities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HotelsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rating: $rating, ')
          ..write('imagePath: $imagePath, ')
          ..write('description: $description, ')
          ..write('priceFrom: $priceFrom, ')
          ..write('address: $address, ')
          ..write('amenities: $amenities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    latitude,
    longitude,
    rating,
    imagePath,
    description,
    priceFrom,
    address,
    amenities,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HotelsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.rating == this.rating &&
          other.imagePath == this.imagePath &&
          other.description == this.description &&
          other.priceFrom == this.priceFrom &&
          other.address == this.address &&
          other.amenities == this.amenities);
}

class HotelsTableCompanion extends UpdateCompanion<HotelsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> location;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> rating;
  final Value<String> imagePath;
  final Value<String> description;
  final Value<double> priceFrom;
  final Value<String> address;
  final Value<String> amenities;
  final Value<int> rowid;
  const HotelsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rating = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.description = const Value.absent(),
    this.priceFrom = const Value.absent(),
    this.address = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HotelsTableCompanion.insert({
    required String id,
    required String name,
    required String location,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rating = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.description = const Value.absent(),
    this.priceFrom = const Value.absent(),
    this.address = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       location = Value(location);
  static Insertable<HotelsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? rating,
    Expression<String>? imagePath,
    Expression<String>? description,
    Expression<double>? priceFrom,
    Expression<String>? address,
    Expression<String>? amenities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rating != null) 'rating': rating,
      if (imagePath != null) 'image_path': imagePath,
      if (description != null) 'description': description,
      if (priceFrom != null) 'price_from': priceFrom,
      if (address != null) 'address': address,
      if (amenities != null) 'amenities': amenities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HotelsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? location,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? rating,
    Value<String>? imagePath,
    Value<String>? description,
    Value<double>? priceFrom,
    Value<String>? address,
    Value<String>? amenities,
    Value<int>? rowid,
  }) {
    return HotelsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      priceFrom: priceFrom ?? this.priceFrom,
      address: address ?? this.address,
      amenities: amenities ?? this.amenities,
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
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priceFrom.present) {
      map['price_from'] = Variable<double>(priceFrom.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (amenities.present) {
      map['amenities'] = Variable<String>(amenities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HotelsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rating: $rating, ')
          ..write('imagePath: $imagePath, ')
          ..write('description: $description, ')
          ..write('priceFrom: $priceFrom, ')
          ..write('address: $address, ')
          ..write('amenities: $amenities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTableTable extends RoomsTable
    with TableInfo<$RoomsTableTable, RoomsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hotelIdMeta = const VerificationMeta(
    'hotelId',
  );
  @override
  late final GeneratedColumn<String> hotelId = GeneratedColumn<String>(
    'hotel_id',
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amenitiesMeta = const VerificationMeta(
    'amenities',
  );
  @override
  late final GeneratedColumn<String> amenities = GeneratedColumn<String>(
    'amenities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hotelId,
    name,
    description,
    price,
    capacity,
    imagePath,
    amenities,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hotel_id')) {
      context.handle(
        _hotelIdMeta,
        hotelId.isAcceptableOrUnknown(data['hotel_id']!, _hotelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hotelIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('amenities')) {
      context.handle(
        _amenitiesMeta,
        amenities.isAcceptableOrUnknown(data['amenities']!, _amenitiesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hotelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      amenities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amenities'],
      )!,
    );
  }

  @override
  $RoomsTableTable createAlias(String alias) {
    return $RoomsTableTable(attachedDatabase, alias);
  }
}

class RoomsTableData extends DataClass implements Insertable<RoomsTableData> {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final String imagePath;
  final String amenities;
  const RoomsTableData({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.imagePath,
    required this.amenities,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hotel_id'] = Variable<String>(hotelId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['price'] = Variable<double>(price);
    map['capacity'] = Variable<int>(capacity);
    map['image_path'] = Variable<String>(imagePath);
    map['amenities'] = Variable<String>(amenities);
    return map;
  }

  RoomsTableCompanion toCompanion(bool nullToAbsent) {
    return RoomsTableCompanion(
      id: Value(id),
      hotelId: Value(hotelId),
      name: Value(name),
      description: Value(description),
      price: Value(price),
      capacity: Value(capacity),
      imagePath: Value(imagePath),
      amenities: Value(amenities),
    );
  }

  factory RoomsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomsTableData(
      id: serializer.fromJson<String>(json['id']),
      hotelId: serializer.fromJson<String>(json['hotelId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      capacity: serializer.fromJson<int>(json['capacity']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      amenities: serializer.fromJson<String>(json['amenities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hotelId': serializer.toJson<String>(hotelId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'price': serializer.toJson<double>(price),
      'capacity': serializer.toJson<int>(capacity),
      'imagePath': serializer.toJson<String>(imagePath),
      'amenities': serializer.toJson<String>(amenities),
    };
  }

  RoomsTableData copyWith({
    String? id,
    String? hotelId,
    String? name,
    String? description,
    double? price,
    int? capacity,
    String? imagePath,
    String? amenities,
  }) => RoomsTableData(
    id: id ?? this.id,
    hotelId: hotelId ?? this.hotelId,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    capacity: capacity ?? this.capacity,
    imagePath: imagePath ?? this.imagePath,
    amenities: amenities ?? this.amenities,
  );
  RoomsTableData copyWithCompanion(RoomsTableCompanion data) {
    return RoomsTableData(
      id: data.id.present ? data.id.value : this.id,
      hotelId: data.hotelId.present ? data.hotelId.value : this.hotelId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      amenities: data.amenities.present ? data.amenities.value : this.amenities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomsTableData(')
          ..write('id: $id, ')
          ..write('hotelId: $hotelId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('capacity: $capacity, ')
          ..write('imagePath: $imagePath, ')
          ..write('amenities: $amenities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hotelId,
    name,
    description,
    price,
    capacity,
    imagePath,
    amenities,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomsTableData &&
          other.id == this.id &&
          other.hotelId == this.hotelId &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.capacity == this.capacity &&
          other.imagePath == this.imagePath &&
          other.amenities == this.amenities);
}

class RoomsTableCompanion extends UpdateCompanion<RoomsTableData> {
  final Value<String> id;
  final Value<String> hotelId;
  final Value<String> name;
  final Value<String> description;
  final Value<double> price;
  final Value<int> capacity;
  final Value<String> imagePath;
  final Value<String> amenities;
  final Value<int> rowid;
  const RoomsTableCompanion({
    this.id = const Value.absent(),
    this.hotelId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.capacity = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsTableCompanion.insert({
    required String id,
    required String hotelId,
    required String name,
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.capacity = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hotelId = Value(hotelId),
       name = Value(name);
  static Insertable<RoomsTableData> custom({
    Expression<String>? id,
    Expression<String>? hotelId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<int>? capacity,
    Expression<String>? imagePath,
    Expression<String>? amenities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hotelId != null) 'hotel_id': hotelId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (capacity != null) 'capacity': capacity,
      if (imagePath != null) 'image_path': imagePath,
      if (amenities != null) 'amenities': amenities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hotelId,
    Value<String>? name,
    Value<String>? description,
    Value<double>? price,
    Value<int>? capacity,
    Value<String>? imagePath,
    Value<String>? amenities,
    Value<int>? rowid,
  }) {
    return RoomsTableCompanion(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      imagePath: imagePath ?? this.imagePath,
      amenities: amenities ?? this.amenities,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hotelId.present) {
      map['hotel_id'] = Variable<String>(hotelId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (amenities.present) {
      map['amenities'] = Variable<String>(amenities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsTableCompanion(')
          ..write('id: $id, ')
          ..write('hotelId: $hotelId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('capacity: $capacity, ')
          ..write('imagePath: $imagePath, ')
          ..write('amenities: $amenities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TourPackagesTableTable extends TourPackagesTable
    with TableInfo<$TourPackagesTableTable, TourPackagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TourPackagesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _originalPriceMeta = const VerificationMeta(
    'originalPrice',
  );
  @override
  late final GeneratedColumn<double> originalPrice = GeneratedColumn<double>(
    'original_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationsMeta = const VerificationMeta(
    'destinations',
  );
  @override
  late final GeneratedColumn<String> destinations = GeneratedColumn<String>(
    'destinations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _includesMeta = const VerificationMeta(
    'includes',
  );
  @override
  late final GeneratedColumn<String> includes = GeneratedColumn<String>(
    'includes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _departureMeta = const VerificationMeta(
    'departure',
  );
  @override
  late final GeneratedColumn<String> departure = GeneratedColumn<String>(
    'departure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _departureDateMeta = const VerificationMeta(
    'departureDate',
  );
  @override
  late final GeneratedColumn<String> departureDate = GeneratedColumn<String>(
    'departure_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPopularMeta = const VerificationMeta(
    'isPopular',
  );
  @override
  late final GeneratedColumn<bool> isPopular = GeneratedColumn<bool>(
    'is_popular',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_popular" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includesGuideMeta = const VerificationMeta(
    'includesGuide',
  );
  @override
  late final GeneratedColumn<bool> includesGuide = GeneratedColumn<bool>(
    'includes_guide',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("includes_guide" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _guideFeeMeta = const VerificationMeta(
    'guideFee',
  );
  @override
  late final GeneratedColumn<double> guideFee = GeneratedColumn<double>(
    'guide_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(50.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    imagePath,
    duration,
    price,
    originalPrice,
    destinations,
    includes,
    departure,
    departureDate,
    isPopular,
    includesGuide,
    guideFee,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tour_packages_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TourPackagesTableData> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('original_price')) {
      context.handle(
        _originalPriceMeta,
        originalPrice.isAcceptableOrUnknown(
          data['original_price']!,
          _originalPriceMeta,
        ),
      );
    }
    if (data.containsKey('destinations')) {
      context.handle(
        _destinationsMeta,
        destinations.isAcceptableOrUnknown(
          data['destinations']!,
          _destinationsMeta,
        ),
      );
    }
    if (data.containsKey('includes')) {
      context.handle(
        _includesMeta,
        includes.isAcceptableOrUnknown(data['includes']!, _includesMeta),
      );
    }
    if (data.containsKey('departure')) {
      context.handle(
        _departureMeta,
        departure.isAcceptableOrUnknown(data['departure']!, _departureMeta),
      );
    }
    if (data.containsKey('departure_date')) {
      context.handle(
        _departureDateMeta,
        departureDate.isAcceptableOrUnknown(
          data['departure_date']!,
          _departureDateMeta,
        ),
      );
    }
    if (data.containsKey('is_popular')) {
      context.handle(
        _isPopularMeta,
        isPopular.isAcceptableOrUnknown(data['is_popular']!, _isPopularMeta),
      );
    }
    if (data.containsKey('includes_guide')) {
      context.handle(
        _includesGuideMeta,
        includesGuide.isAcceptableOrUnknown(
          data['includes_guide']!,
          _includesGuideMeta,
        ),
      );
    }
    if (data.containsKey('guide_fee')) {
      context.handle(
        _guideFeeMeta,
        guideFee.isAcceptableOrUnknown(data['guide_fee']!, _guideFeeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TourPackagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TourPackagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      originalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_price'],
      ),
      destinations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destinations'],
      )!,
      includes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}includes'],
      )!,
      departure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departure'],
      )!,
      departureDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departure_date'],
      ),
      isPopular: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_popular'],
      )!,
      includesGuide: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}includes_guide'],
      )!,
      guideFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}guide_fee'],
      )!,
    );
  }

  @override
  $TourPackagesTableTable createAlias(String alias) {
    return $TourPackagesTableTable(attachedDatabase, alias);
  }
}

class TourPackagesTableData extends DataClass
    implements Insertable<TourPackagesTableData> {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String duration;
  final double price;
  final double? originalPrice;
  final String destinations;
  final String includes;
  final String departure;
  final String? departureDate;
  final bool isPopular;
  final bool includesGuide;
  final double guideFee;
  const TourPackagesTableData({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.duration,
    required this.price,
    this.originalPrice,
    required this.destinations,
    required this.includes,
    required this.departure,
    this.departureDate,
    required this.isPopular,
    required this.includesGuide,
    required this.guideFee,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['image_path'] = Variable<String>(imagePath);
    map['duration'] = Variable<String>(duration);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || originalPrice != null) {
      map['original_price'] = Variable<double>(originalPrice);
    }
    map['destinations'] = Variable<String>(destinations);
    map['includes'] = Variable<String>(includes);
    map['departure'] = Variable<String>(departure);
    if (!nullToAbsent || departureDate != null) {
      map['departure_date'] = Variable<String>(departureDate);
    }
    map['is_popular'] = Variable<bool>(isPopular);
    map['includes_guide'] = Variable<bool>(includesGuide);
    map['guide_fee'] = Variable<double>(guideFee);
    return map;
  }

  TourPackagesTableCompanion toCompanion(bool nullToAbsent) {
    return TourPackagesTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      imagePath: Value(imagePath),
      duration: Value(duration),
      price: Value(price),
      originalPrice: originalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(originalPrice),
      destinations: Value(destinations),
      includes: Value(includes),
      departure: Value(departure),
      departureDate: departureDate == null && nullToAbsent
          ? const Value.absent()
          : Value(departureDate),
      isPopular: Value(isPopular),
      includesGuide: Value(includesGuide),
      guideFee: Value(guideFee),
    );
  }

  factory TourPackagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TourPackagesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      duration: serializer.fromJson<String>(json['duration']),
      price: serializer.fromJson<double>(json['price']),
      originalPrice: serializer.fromJson<double?>(json['originalPrice']),
      destinations: serializer.fromJson<String>(json['destinations']),
      includes: serializer.fromJson<String>(json['includes']),
      departure: serializer.fromJson<String>(json['departure']),
      departureDate: serializer.fromJson<String?>(json['departureDate']),
      isPopular: serializer.fromJson<bool>(json['isPopular']),
      includesGuide: serializer.fromJson<bool>(json['includesGuide']),
      guideFee: serializer.fromJson<double>(json['guideFee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'imagePath': serializer.toJson<String>(imagePath),
      'duration': serializer.toJson<String>(duration),
      'price': serializer.toJson<double>(price),
      'originalPrice': serializer.toJson<double?>(originalPrice),
      'destinations': serializer.toJson<String>(destinations),
      'includes': serializer.toJson<String>(includes),
      'departure': serializer.toJson<String>(departure),
      'departureDate': serializer.toJson<String?>(departureDate),
      'isPopular': serializer.toJson<bool>(isPopular),
      'includesGuide': serializer.toJson<bool>(includesGuide),
      'guideFee': serializer.toJson<double>(guideFee),
    };
  }

  TourPackagesTableData copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? duration,
    double? price,
    Value<double?> originalPrice = const Value.absent(),
    String? destinations,
    String? includes,
    String? departure,
    Value<String?> departureDate = const Value.absent(),
    bool? isPopular,
    bool? includesGuide,
    double? guideFee,
  }) => TourPackagesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imagePath: imagePath ?? this.imagePath,
    duration: duration ?? this.duration,
    price: price ?? this.price,
    originalPrice: originalPrice.present
        ? originalPrice.value
        : this.originalPrice,
    destinations: destinations ?? this.destinations,
    includes: includes ?? this.includes,
    departure: departure ?? this.departure,
    departureDate: departureDate.present
        ? departureDate.value
        : this.departureDate,
    isPopular: isPopular ?? this.isPopular,
    includesGuide: includesGuide ?? this.includesGuide,
    guideFee: guideFee ?? this.guideFee,
  );
  TourPackagesTableData copyWithCompanion(TourPackagesTableCompanion data) {
    return TourPackagesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      duration: data.duration.present ? data.duration.value : this.duration,
      price: data.price.present ? data.price.value : this.price,
      originalPrice: data.originalPrice.present
          ? data.originalPrice.value
          : this.originalPrice,
      destinations: data.destinations.present
          ? data.destinations.value
          : this.destinations,
      includes: data.includes.present ? data.includes.value : this.includes,
      departure: data.departure.present ? data.departure.value : this.departure,
      departureDate: data.departureDate.present
          ? data.departureDate.value
          : this.departureDate,
      isPopular: data.isPopular.present ? data.isPopular.value : this.isPopular,
      includesGuide: data.includesGuide.present
          ? data.includesGuide.value
          : this.includesGuide,
      guideFee: data.guideFee.present ? data.guideFee.value : this.guideFee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TourPackagesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('duration: $duration, ')
          ..write('price: $price, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('destinations: $destinations, ')
          ..write('includes: $includes, ')
          ..write('departure: $departure, ')
          ..write('departureDate: $departureDate, ')
          ..write('isPopular: $isPopular, ')
          ..write('includesGuide: $includesGuide, ')
          ..write('guideFee: $guideFee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    imagePath,
    duration,
    price,
    originalPrice,
    destinations,
    includes,
    departure,
    departureDate,
    isPopular,
    includesGuide,
    guideFee,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TourPackagesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.duration == this.duration &&
          other.price == this.price &&
          other.originalPrice == this.originalPrice &&
          other.destinations == this.destinations &&
          other.includes == this.includes &&
          other.departure == this.departure &&
          other.departureDate == this.departureDate &&
          other.isPopular == this.isPopular &&
          other.includesGuide == this.includesGuide &&
          other.guideFee == this.guideFee);
}

class TourPackagesTableCompanion
    extends UpdateCompanion<TourPackagesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> imagePath;
  final Value<String> duration;
  final Value<double> price;
  final Value<double?> originalPrice;
  final Value<String> destinations;
  final Value<String> includes;
  final Value<String> departure;
  final Value<String?> departureDate;
  final Value<bool> isPopular;
  final Value<bool> includesGuide;
  final Value<double> guideFee;
  final Value<int> rowid;
  const TourPackagesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.duration = const Value.absent(),
    this.price = const Value.absent(),
    this.originalPrice = const Value.absent(),
    this.destinations = const Value.absent(),
    this.includes = const Value.absent(),
    this.departure = const Value.absent(),
    this.departureDate = const Value.absent(),
    this.isPopular = const Value.absent(),
    this.includesGuide = const Value.absent(),
    this.guideFee = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TourPackagesTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.duration = const Value.absent(),
    this.price = const Value.absent(),
    this.originalPrice = const Value.absent(),
    this.destinations = const Value.absent(),
    this.includes = const Value.absent(),
    this.departure = const Value.absent(),
    this.departureDate = const Value.absent(),
    this.isPopular = const Value.absent(),
    this.includesGuide = const Value.absent(),
    this.guideFee = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<TourPackagesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<String>? duration,
    Expression<double>? price,
    Expression<double>? originalPrice,
    Expression<String>? destinations,
    Expression<String>? includes,
    Expression<String>? departure,
    Expression<String>? departureDate,
    Expression<bool>? isPopular,
    Expression<bool>? includesGuide,
    Expression<double>? guideFee,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (duration != null) 'duration': duration,
      if (price != null) 'price': price,
      if (originalPrice != null) 'original_price': originalPrice,
      if (destinations != null) 'destinations': destinations,
      if (includes != null) 'includes': includes,
      if (departure != null) 'departure': departure,
      if (departureDate != null) 'departure_date': departureDate,
      if (isPopular != null) 'is_popular': isPopular,
      if (includesGuide != null) 'includes_guide': includesGuide,
      if (guideFee != null) 'guide_fee': guideFee,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TourPackagesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? imagePath,
    Value<String>? duration,
    Value<double>? price,
    Value<double?>? originalPrice,
    Value<String>? destinations,
    Value<String>? includes,
    Value<String>? departure,
    Value<String?>? departureDate,
    Value<bool>? isPopular,
    Value<bool>? includesGuide,
    Value<double>? guideFee,
    Value<int>? rowid,
  }) {
    return TourPackagesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      destinations: destinations ?? this.destinations,
      includes: includes ?? this.includes,
      departure: departure ?? this.departure,
      departureDate: departureDate ?? this.departureDate,
      isPopular: isPopular ?? this.isPopular,
      includesGuide: includesGuide ?? this.includesGuide,
      guideFee: guideFee ?? this.guideFee,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (originalPrice.present) {
      map['original_price'] = Variable<double>(originalPrice.value);
    }
    if (destinations.present) {
      map['destinations'] = Variable<String>(destinations.value);
    }
    if (includes.present) {
      map['includes'] = Variable<String>(includes.value);
    }
    if (departure.present) {
      map['departure'] = Variable<String>(departure.value);
    }
    if (departureDate.present) {
      map['departure_date'] = Variable<String>(departureDate.value);
    }
    if (isPopular.present) {
      map['is_popular'] = Variable<bool>(isPopular.value);
    }
    if (includesGuide.present) {
      map['includes_guide'] = Variable<bool>(includesGuide.value);
    }
    if (guideFee.present) {
      map['guide_fee'] = Variable<double>(guideFee.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TourPackagesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('duration: $duration, ')
          ..write('price: $price, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('destinations: $destinations, ')
          ..write('includes: $includes, ')
          ..write('departure: $departure, ')
          ..write('departureDate: $departureDate, ')
          ..write('isPopular: $isPopular, ')
          ..write('includesGuide: $includesGuide, ')
          ..write('guideFee: $guideFee, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTableTable extends TripsTable
    with TableInfo<$TripsTableTable, TripsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<String> guests = GeneratedColumn<String>(
    'guests',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('upcoming'),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isUpcomingMeta = const VerificationMeta(
    'isUpcoming',
  );
  @override
  late final GeneratedColumn<bool> isUpcoming = GeneratedColumn<bool>(
    'is_upcoming',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_upcoming" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _flightIdMeta = const VerificationMeta(
    'flightId',
  );
  @override
  late final GeneratedColumn<String> flightId = GeneratedColumn<String>(
    'flight_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hotelIdMeta = const VerificationMeta(
    'hotelId',
  );
  @override
  late final GeneratedColumn<String> hotelId = GeneratedColumn<String>(
    'hotel_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    destination,
    location,
    date,
    guests,
    status,
    imagePath,
    isUpcoming,
    flightId,
    hotelId,
    roomId,
    totalPrice,
    isCustom,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('guests')) {
      context.handle(
        _guestsMeta,
        guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_upcoming')) {
      context.handle(
        _isUpcomingMeta,
        isUpcoming.isAcceptableOrUnknown(data['is_upcoming']!, _isUpcomingMeta),
      );
    }
    if (data.containsKey('flight_id')) {
      context.handle(
        _flightIdMeta,
        flightId.isAcceptableOrUnknown(data['flight_id']!, _flightIdMeta),
      );
    }
    if (data.containsKey('hotel_id')) {
      context.handle(
        _hotelIdMeta,
        hotelId.isAcceptableOrUnknown(data['hotel_id']!, _hotelIdMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      guests: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guests'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      isUpcoming: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_upcoming'],
      )!,
      flightId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flight_id'],
      ),
      hotelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_id'],
      ),
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripsTableTable createAlias(String alias) {
    return $TripsTableTable(attachedDatabase, alias);
  }
}

class TripsTableData extends DataClass implements Insertable<TripsTableData> {
  final String id;
  final String destination;
  final String location;
  final String date;
  final String guests;
  final String status;
  final String imagePath;
  final bool isUpcoming;
  final String? flightId;
  final String? hotelId;
  final String? roomId;
  final double? totalPrice;
  final bool isCustom;
  final String createdAt;
  const TripsTableData({
    required this.id,
    required this.destination,
    required this.location,
    required this.date,
    required this.guests,
    required this.status,
    required this.imagePath,
    required this.isUpcoming,
    this.flightId,
    this.hotelId,
    this.roomId,
    this.totalPrice,
    required this.isCustom,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['destination'] = Variable<String>(destination);
    map['location'] = Variable<String>(location);
    map['date'] = Variable<String>(date);
    map['guests'] = Variable<String>(guests);
    map['status'] = Variable<String>(status);
    map['image_path'] = Variable<String>(imagePath);
    map['is_upcoming'] = Variable<bool>(isUpcoming);
    if (!nullToAbsent || flightId != null) {
      map['flight_id'] = Variable<String>(flightId);
    }
    if (!nullToAbsent || hotelId != null) {
      map['hotel_id'] = Variable<String>(hotelId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || totalPrice != null) {
      map['total_price'] = Variable<double>(totalPrice);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TripsTableCompanion toCompanion(bool nullToAbsent) {
    return TripsTableCompanion(
      id: Value(id),
      destination: Value(destination),
      location: Value(location),
      date: Value(date),
      guests: Value(guests),
      status: Value(status),
      imagePath: Value(imagePath),
      isUpcoming: Value(isUpcoming),
      flightId: flightId == null && nullToAbsent
          ? const Value.absent()
          : Value(flightId),
      hotelId: hotelId == null && nullToAbsent
          ? const Value.absent()
          : Value(hotelId),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      totalPrice: totalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPrice),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory TripsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripsTableData(
      id: serializer.fromJson<String>(json['id']),
      destination: serializer.fromJson<String>(json['destination']),
      location: serializer.fromJson<String>(json['location']),
      date: serializer.fromJson<String>(json['date']),
      guests: serializer.fromJson<String>(json['guests']),
      status: serializer.fromJson<String>(json['status']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      isUpcoming: serializer.fromJson<bool>(json['isUpcoming']),
      flightId: serializer.fromJson<String?>(json['flightId']),
      hotelId: serializer.fromJson<String?>(json['hotelId']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      totalPrice: serializer.fromJson<double?>(json['totalPrice']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'destination': serializer.toJson<String>(destination),
      'location': serializer.toJson<String>(location),
      'date': serializer.toJson<String>(date),
      'guests': serializer.toJson<String>(guests),
      'status': serializer.toJson<String>(status),
      'imagePath': serializer.toJson<String>(imagePath),
      'isUpcoming': serializer.toJson<bool>(isUpcoming),
      'flightId': serializer.toJson<String?>(flightId),
      'hotelId': serializer.toJson<String?>(hotelId),
      'roomId': serializer.toJson<String?>(roomId),
      'totalPrice': serializer.toJson<double?>(totalPrice),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  TripsTableData copyWith({
    String? id,
    String? destination,
    String? location,
    String? date,
    String? guests,
    String? status,
    String? imagePath,
    bool? isUpcoming,
    Value<String?> flightId = const Value.absent(),
    Value<String?> hotelId = const Value.absent(),
    Value<String?> roomId = const Value.absent(),
    Value<double?> totalPrice = const Value.absent(),
    bool? isCustom,
    String? createdAt,
  }) => TripsTableData(
    id: id ?? this.id,
    destination: destination ?? this.destination,
    location: location ?? this.location,
    date: date ?? this.date,
    guests: guests ?? this.guests,
    status: status ?? this.status,
    imagePath: imagePath ?? this.imagePath,
    isUpcoming: isUpcoming ?? this.isUpcoming,
    flightId: flightId.present ? flightId.value : this.flightId,
    hotelId: hotelId.present ? hotelId.value : this.hotelId,
    roomId: roomId.present ? roomId.value : this.roomId,
    totalPrice: totalPrice.present ? totalPrice.value : this.totalPrice,
    isCustom: isCustom ?? this.isCustom,
    createdAt: createdAt ?? this.createdAt,
  );
  TripsTableData copyWithCompanion(TripsTableCompanion data) {
    return TripsTableData(
      id: data.id.present ? data.id.value : this.id,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      location: data.location.present ? data.location.value : this.location,
      date: data.date.present ? data.date.value : this.date,
      guests: data.guests.present ? data.guests.value : this.guests,
      status: data.status.present ? data.status.value : this.status,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isUpcoming: data.isUpcoming.present
          ? data.isUpcoming.value
          : this.isUpcoming,
      flightId: data.flightId.present ? data.flightId.value : this.flightId,
      hotelId: data.hotelId.present ? data.hotelId.value : this.hotelId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableData(')
          ..write('id: $id, ')
          ..write('destination: $destination, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('guests: $guests, ')
          ..write('status: $status, ')
          ..write('imagePath: $imagePath, ')
          ..write('isUpcoming: $isUpcoming, ')
          ..write('flightId: $flightId, ')
          ..write('hotelId: $hotelId, ')
          ..write('roomId: $roomId, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    destination,
    location,
    date,
    guests,
    status,
    imagePath,
    isUpcoming,
    flightId,
    hotelId,
    roomId,
    totalPrice,
    isCustom,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripsTableData &&
          other.id == this.id &&
          other.destination == this.destination &&
          other.location == this.location &&
          other.date == this.date &&
          other.guests == this.guests &&
          other.status == this.status &&
          other.imagePath == this.imagePath &&
          other.isUpcoming == this.isUpcoming &&
          other.flightId == this.flightId &&
          other.hotelId == this.hotelId &&
          other.roomId == this.roomId &&
          other.totalPrice == this.totalPrice &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class TripsTableCompanion extends UpdateCompanion<TripsTableData> {
  final Value<String> id;
  final Value<String> destination;
  final Value<String> location;
  final Value<String> date;
  final Value<String> guests;
  final Value<String> status;
  final Value<String> imagePath;
  final Value<bool> isUpcoming;
  final Value<String?> flightId;
  final Value<String?> hotelId;
  final Value<String?> roomId;
  final Value<double?> totalPrice;
  final Value<bool> isCustom;
  final Value<String> createdAt;
  final Value<int> rowid;
  const TripsTableCompanion({
    this.id = const Value.absent(),
    this.destination = const Value.absent(),
    this.location = const Value.absent(),
    this.date = const Value.absent(),
    this.guests = const Value.absent(),
    this.status = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isUpcoming = const Value.absent(),
    this.flightId = const Value.absent(),
    this.hotelId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsTableCompanion.insert({
    required String id,
    required String destination,
    this.location = const Value.absent(),
    this.date = const Value.absent(),
    this.guests = const Value.absent(),
    this.status = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isUpcoming = const Value.absent(),
    this.flightId = const Value.absent(),
    this.hotelId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       destination = Value(destination);
  static Insertable<TripsTableData> custom({
    Expression<String>? id,
    Expression<String>? destination,
    Expression<String>? location,
    Expression<String>? date,
    Expression<String>? guests,
    Expression<String>? status,
    Expression<String>? imagePath,
    Expression<bool>? isUpcoming,
    Expression<String>? flightId,
    Expression<String>? hotelId,
    Expression<String>? roomId,
    Expression<double>? totalPrice,
    Expression<bool>? isCustom,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (destination != null) 'destination': destination,
      if (location != null) 'location': location,
      if (date != null) 'date': date,
      if (guests != null) 'guests': guests,
      if (status != null) 'status': status,
      if (imagePath != null) 'image_path': imagePath,
      if (isUpcoming != null) 'is_upcoming': isUpcoming,
      if (flightId != null) 'flight_id': flightId,
      if (hotelId != null) 'hotel_id': hotelId,
      if (roomId != null) 'room_id': roomId,
      if (totalPrice != null) 'total_price': totalPrice,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? destination,
    Value<String>? location,
    Value<String>? date,
    Value<String>? guests,
    Value<String>? status,
    Value<String>? imagePath,
    Value<bool>? isUpcoming,
    Value<String?>? flightId,
    Value<String?>? hotelId,
    Value<String?>? roomId,
    Value<double?>? totalPrice,
    Value<bool>? isCustom,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return TripsTableCompanion(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      location: location ?? this.location,
      date: date ?? this.date,
      guests: guests ?? this.guests,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      flightId: flightId ?? this.flightId,
      hotelId: hotelId ?? this.hotelId,
      roomId: roomId ?? this.roomId,
      totalPrice: totalPrice ?? this.totalPrice,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (guests.present) {
      map['guests'] = Variable<String>(guests.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isUpcoming.present) {
      map['is_upcoming'] = Variable<bool>(isUpcoming.value);
    }
    if (flightId.present) {
      map['flight_id'] = Variable<String>(flightId.value);
    }
    if (hotelId.present) {
      map['hotel_id'] = Variable<String>(hotelId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableCompanion(')
          ..write('id: $id, ')
          ..write('destination: $destination, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('guests: $guests, ')
          ..write('status: $status, ')
          ..write('imagePath: $imagePath, ')
          ..write('isUpcoming: $isUpcoming, ')
          ..write('flightId: $flightId, ')
          ..write('hotelId: $hotelId, ')
          ..write('roomId: $roomId, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripScheduleDaysTableTable extends TripScheduleDaysTable
    with TableInfo<$TripScheduleDaysTableTable, TripScheduleDaysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripScheduleDaysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, tripId, dayNumber, date, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_schedule_days_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripScheduleDaysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripScheduleDaysTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripScheduleDaysTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
    );
  }

  @override
  $TripScheduleDaysTableTable createAlias(String alias) {
    return $TripScheduleDaysTableTable(attachedDatabase, alias);
  }
}

class TripScheduleDaysTableData extends DataClass
    implements Insertable<TripScheduleDaysTableData> {
  final String id;
  final String tripId;
  final int dayNumber;
  final String? date;
  final String title;
  const TripScheduleDaysTableData({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
    required this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['day_number'] = Variable<int>(dayNumber);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    map['title'] = Variable<String>(title);
    return map;
  }

  TripScheduleDaysTableCompanion toCompanion(bool nullToAbsent) {
    return TripScheduleDaysTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      dayNumber: Value(dayNumber),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      title: Value(title),
    );
  }

  factory TripScheduleDaysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripScheduleDaysTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      date: serializer.fromJson<String?>(json['date']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'date': serializer.toJson<String?>(date),
      'title': serializer.toJson<String>(title),
    };
  }

  TripScheduleDaysTableData copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    Value<String?> date = const Value.absent(),
    String? title,
  }) => TripScheduleDaysTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    dayNumber: dayNumber ?? this.dayNumber,
    date: date.present ? date.value : this.date,
    title: title ?? this.title,
  );
  TripScheduleDaysTableData copyWithCompanion(
    TripScheduleDaysTableCompanion data,
  ) {
    return TripScheduleDaysTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleDaysTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('date: $date, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, dayNumber, date, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripScheduleDaysTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.dayNumber == this.dayNumber &&
          other.date == this.date &&
          other.title == this.title);
}

class TripScheduleDaysTableCompanion
    extends UpdateCompanion<TripScheduleDaysTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<int> dayNumber;
  final Value<String?> date;
  final Value<String> title;
  final Value<int> rowid;
  const TripScheduleDaysTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripScheduleDaysTableCompanion.insert({
    required String id,
    required String tripId,
    this.dayNumber = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId);
  static Insertable<TripScheduleDaysTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<int>? dayNumber,
    Expression<String>? date,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (dayNumber != null) 'day_number': dayNumber,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripScheduleDaysTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<int>? dayNumber,
    Value<String?>? date,
    Value<String>? title,
    Value<int>? rowid,
  }) {
    return TripScheduleDaysTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleDaysTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripScheduleItemsTableTable extends TripScheduleItemsTable
    with TableInfo<$TripScheduleItemsTableTable, TripScheduleItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripScheduleItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusOverrideMeta = const VerificationMeta(
    'statusOverride',
  );
  @override
  late final GeneratedColumn<String> statusOverride = GeneratedColumn<String>(
    'status_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    startTime,
    endTime,
    title,
    description,
    locationName,
    latitude,
    longitude,
    sortOrder,
    statusOverride,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_schedule_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripScheduleItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
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
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('status_override')) {
      context.handle(
        _statusOverrideMeta,
        statusOverride.isAcceptableOrUnknown(
          data['status_override']!,
          _statusOverrideMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripScheduleItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripScheduleItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      statusOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_override'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TripScheduleItemsTableTable createAlias(String alias) {
    return $TripScheduleItemsTableTable(attachedDatabase, alias);
  }
}

class TripScheduleItemsTableData extends DataClass
    implements Insertable<TripScheduleItemsTableData> {
  final String id;
  final String dayId;
  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final int sortOrder;
  final String? statusOverride;
  final String? note;
  final String? updatedAt;
  const TripScheduleItemsTableData({
    required this.id,
    required this.dayId,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.sortOrder,
    this.statusOverride,
    this.note,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_id'] = Variable<String>(dayId);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['location_name'] = Variable<String>(locationName);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || statusOverride != null) {
      map['status_override'] = Variable<String>(statusOverride);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TripScheduleItemsTableCompanion toCompanion(bool nullToAbsent) {
    return TripScheduleItemsTableCompanion(
      id: Value(id),
      dayId: Value(dayId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      title: Value(title),
      description: Value(description),
      locationName: Value(locationName),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      sortOrder: Value(sortOrder),
      statusOverride: statusOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(statusOverride),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TripScheduleItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripScheduleItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      dayId: serializer.fromJson<String>(json['dayId']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      locationName: serializer.fromJson<String>(json['locationName']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      statusOverride: serializer.fromJson<String?>(json['statusOverride']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayId': serializer.toJson<String>(dayId),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'locationName': serializer.toJson<String>(locationName),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'statusOverride': serializer.toJson<String?>(statusOverride),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TripScheduleItemsTableData copyWith({
    String? id,
    String? dayId,
    String? startTime,
    String? endTime,
    String? title,
    String? description,
    String? locationName,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    int? sortOrder,
    Value<String?> statusOverride = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => TripScheduleItemsTableData(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    title: title ?? this.title,
    description: description ?? this.description,
    locationName: locationName ?? this.locationName,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    sortOrder: sortOrder ?? this.sortOrder,
    statusOverride: statusOverride.present
        ? statusOverride.value
        : this.statusOverride,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TripScheduleItemsTableData copyWithCompanion(
    TripScheduleItemsTableCompanion data,
  ) {
    return TripScheduleItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      statusOverride: data.statusOverride.present
          ? data.statusOverride.value
          : this.statusOverride,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleItemsTableData(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('statusOverride: $statusOverride, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    startTime,
    endTime,
    title,
    description,
    locationName,
    latitude,
    longitude,
    sortOrder,
    statusOverride,
    note,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripScheduleItemsTableData &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.title == this.title &&
          other.description == this.description &&
          other.locationName == this.locationName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.sortOrder == this.sortOrder &&
          other.statusOverride == this.statusOverride &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class TripScheduleItemsTableCompanion
    extends UpdateCompanion<TripScheduleItemsTableData> {
  final Value<String> id;
  final Value<String> dayId;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> title;
  final Value<String> description;
  final Value<String> locationName;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> sortOrder;
  final Value<String?> statusOverride;
  final Value<String?> note;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const TripScheduleItemsTableCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.statusOverride = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripScheduleItemsTableCompanion.insert({
    required String id,
    required String dayId,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.statusOverride = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayId = Value(dayId);
  static Insertable<TripScheduleItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? dayId,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? locationName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? sortOrder,
    Expression<String>? statusOverride,
    Expression<String>? note,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (statusOverride != null) 'status_override': statusOverride,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripScheduleItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? dayId,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? title,
    Value<String>? description,
    Value<String>? locationName,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? sortOrder,
    Value<String?>? statusOverride,
    Value<String?>? note,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripScheduleItemsTableCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortOrder: sortOrder ?? this.sortOrder,
      statusOverride: statusOverride ?? this.statusOverride,
      note: note ?? this.note,
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
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (statusOverride.present) {
      map['status_override'] = Variable<String>(statusOverride.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('statusOverride: $statusOverride, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripScheduleUpdatesTableTable extends TripScheduleUpdatesTable
    with
        TableInfo<
          $TripScheduleUpdatesTableTable,
          TripScheduleUpdatesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripScheduleUpdatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tripId, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_schedule_updates_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripScheduleUpdatesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
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
  TripScheduleUpdatesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripScheduleUpdatesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripScheduleUpdatesTableTable createAlias(String alias) {
    return $TripScheduleUpdatesTableTable(attachedDatabase, alias);
  }
}

class TripScheduleUpdatesTableData extends DataClass
    implements Insertable<TripScheduleUpdatesTableData> {
  final String id;
  final String tripId;
  final String message;
  final String createdAt;
  const TripScheduleUpdatesTableData({
    required this.id,
    required this.tripId,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TripScheduleUpdatesTableCompanion toCompanion(bool nullToAbsent) {
    return TripScheduleUpdatesTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory TripScheduleUpdatesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripScheduleUpdatesTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  TripScheduleUpdatesTableData copyWith({
    String? id,
    String? tripId,
    String? message,
    String? createdAt,
  }) => TripScheduleUpdatesTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  TripScheduleUpdatesTableData copyWithCompanion(
    TripScheduleUpdatesTableCompanion data,
  ) {
    return TripScheduleUpdatesTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleUpdatesTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripScheduleUpdatesTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class TripScheduleUpdatesTableCompanion
    extends UpdateCompanion<TripScheduleUpdatesTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> message;
  final Value<String> createdAt;
  final Value<int> rowid;
  const TripScheduleUpdatesTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripScheduleUpdatesTableCompanion.insert({
    required String id,
    required String tripId,
    required String message,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<TripScheduleUpdatesTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? message,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripScheduleUpdatesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? message,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return TripScheduleUpdatesTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripScheduleUpdatesTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewsTableTable extends ReviewsTable
    with TableInfo<$ReviewsTableTable, ReviewsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    userName,
    targetType,
    targetId,
    rating,
    comment,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviews_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
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
  ReviewsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReviewsTableTable createAlias(String alias) {
    return $ReviewsTableTable(attachedDatabase, alias);
  }
}

class ReviewsTableData extends DataClass
    implements Insertable<ReviewsTableData> {
  final String id;
  final String userId;
  final String userName;
  final String targetType;
  final String targetId;
  final int rating;
  final String comment;
  final String createdAt;
  const ReviewsTableData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.targetType,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_name'] = Variable<String>(userName);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['rating'] = Variable<int>(rating);
    map['comment'] = Variable<String>(comment);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ReviewsTableCompanion toCompanion(bool nullToAbsent) {
    return ReviewsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      userName: Value(userName),
      targetType: Value(targetType),
      targetId: Value(targetId),
      rating: Value(rating),
      comment: Value(comment),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userName: serializer.fromJson<String>(json['userName']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      rating: serializer.fromJson<int>(json['rating']),
      comment: serializer.fromJson<String>(json['comment']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userName': serializer.toJson<String>(userName),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'rating': serializer.toJson<int>(rating),
      'comment': serializer.toJson<String>(comment),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ReviewsTableData copyWith({
    String? id,
    String? userId,
    String? userName,
    String? targetType,
    String? targetId,
    int? rating,
    String? comment,
    String? createdAt,
  }) => ReviewsTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    createdAt: createdAt ?? this.createdAt,
  );
  ReviewsTableData copyWithCompanion(ReviewsTableCompanion data) {
    return ReviewsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      rating: data.rating.present ? data.rating.value : this.rating,
      comment: data.comment.present ? data.comment.value : this.comment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('rating: $rating, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    userName,
    targetType,
    targetId,
    rating,
    comment,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.rating == this.rating &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt);
}

class ReviewsTableCompanion extends UpdateCompanion<ReviewsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userName;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<int> rating;
  final Value<String> comment;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ReviewsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.rating = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewsTableCompanion.insert({
    required String id,
    required String userId,
    this.userName = const Value.absent(),
    required String targetType,
    required String targetId,
    this.rating = const Value.absent(),
    this.comment = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       targetType = Value(targetType),
       targetId = Value(targetId),
       createdAt = Value(createdAt);
  static Insertable<ReviewsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<int>? rating,
    Expression<String>? comment,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userName,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<int>? rating,
    Value<String>? comment,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ReviewsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('rating: $rating, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTableTable extends DocumentsTable
    with TableInfo<$DocumentsTableTable, DocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('description'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#2196F3'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    iconName,
    colorHex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentsTableData> instance, {
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
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentsTableData(
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
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
    );
  }

  @override
  $DocumentsTableTable createAlias(String alias) {
    return $DocumentsTableTable(attachedDatabase, alias);
  }
}

class DocumentsTableData extends DataClass
    implements Insertable<DocumentsTableData> {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  const DocumentsTableData({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon_name'] = Variable<String>(iconName);
    map['color_hex'] = Variable<String>(colorHex);
    return map;
  }

  DocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return DocumentsTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      iconName: Value(iconName),
      colorHex: Value(colorHex),
    );
  }

  factory DocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'iconName': serializer.toJson<String>(iconName),
      'colorHex': serializer.toJson<String>(colorHex),
    };
  }

  DocumentsTableData copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    String? colorHex,
  }) => DocumentsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
  );
  DocumentsTableData copyWithCompanion(DocumentsTableCompanion data) {
    return DocumentsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, iconName, colorHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconName == this.iconName &&
          other.colorHex == this.colorHex);
}

class DocumentsTableCompanion extends UpdateCompanion<DocumentsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> iconName;
  final Value<String> colorHex;
  final Value<int> rowid;
  const DocumentsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<DocumentsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconName,
    Expression<String>? colorHex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (colorHex != null) 'color_hex': colorHex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? iconName,
    Value<String>? colorHex,
    Value<int>? rowid,
  }) {
    return DocumentsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
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
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DestinationsTableTable destinationsTable =
      $DestinationsTableTable(this);
  late final $CategoriesTableTable categoriesTable = $CategoriesTableTable(
    this,
  );
  late final $HotelsTableTable hotelsTable = $HotelsTableTable(this);
  late final $RoomsTableTable roomsTable = $RoomsTableTable(this);
  late final $TourPackagesTableTable tourPackagesTable =
      $TourPackagesTableTable(this);
  late final $TripsTableTable tripsTable = $TripsTableTable(this);
  late final $TripScheduleDaysTableTable tripScheduleDaysTable =
      $TripScheduleDaysTableTable(this);
  late final $TripScheduleItemsTableTable tripScheduleItemsTable =
      $TripScheduleItemsTableTable(this);
  late final $TripScheduleUpdatesTableTable tripScheduleUpdatesTable =
      $TripScheduleUpdatesTableTable(this);
  late final $ReviewsTableTable reviewsTable = $ReviewsTableTable(this);
  late final $DocumentsTableTable documentsTable = $DocumentsTableTable(this);
  late final DestinationsDao destinationsDao = DestinationsDao(
    this as AppDatabase,
  );
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final HotelsDao hotelsDao = HotelsDao(this as AppDatabase);
  late final RoomsDao roomsDao = RoomsDao(this as AppDatabase);
  late final TourPackagesDao tourPackagesDao = TourPackagesDao(
    this as AppDatabase,
  );
  late final TripsDao tripsDao = TripsDao(this as AppDatabase);
  late final TripScheduleDaysDao tripScheduleDaysDao = TripScheduleDaysDao(
    this as AppDatabase,
  );
  late final TripScheduleItemsDao tripScheduleItemsDao = TripScheduleItemsDao(
    this as AppDatabase,
  );
  late final TripScheduleUpdatesDao tripScheduleUpdatesDao =
      TripScheduleUpdatesDao(this as AppDatabase);
  late final ReviewsDao reviewsDao = ReviewsDao(this as AppDatabase);
  late final DocumentsDao documentsDao = DocumentsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    destinationsTable,
    categoriesTable,
    hotelsTable,
    roomsTable,
    tourPackagesTable,
    tripsTable,
    tripScheduleDaysTable,
    tripScheduleItemsTable,
    tripScheduleUpdatesTable,
    reviewsTable,
    documentsTable,
  ];
}

typedef $$DestinationsTableTableCreateCompanionBuilder =
    DestinationsTableCompanion Function({
      required String id,
      required String name,
      required String location,
      Value<String> rating,
      Value<String> duration,
      Value<String> imagePath,
      Value<bool> isFavorite,
      Value<String> description,
      Value<String> price,
      Value<String> reviewsCount,
      Value<String> category,
      Value<double> latitude,
      Value<double> longitude,
      Value<bool> isRecommended,
      Value<int> rowid,
    });
typedef $$DestinationsTableTableUpdateCompanionBuilder =
    DestinationsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> location,
      Value<String> rating,
      Value<String> duration,
      Value<String> imagePath,
      Value<bool> isFavorite,
      Value<String> description,
      Value<String> price,
      Value<String> reviewsCount,
      Value<String> category,
      Value<double> latitude,
      Value<double> longitude,
      Value<bool> isRecommended,
      Value<int> rowid,
    });

class $$DestinationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DestinationsTableTable> {
  $$DestinationsTableTableFilterComposer({
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

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewsCount => $composableBuilder(
    column: $table.reviewsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
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

  ColumnFilters<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DestinationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DestinationsTableTable> {
  $$DestinationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewsCount => $composableBuilder(
    column: $table.reviewsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
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

  ColumnOrderings<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DestinationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DestinationsTableTable> {
  $$DestinationsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get reviewsCount => $composableBuilder(
    column: $table.reviewsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => column,
  );
}

class $$DestinationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DestinationsTableTable,
          DestinationsTableData,
          $$DestinationsTableTableFilterComposer,
          $$DestinationsTableTableOrderingComposer,
          $$DestinationsTableTableAnnotationComposer,
          $$DestinationsTableTableCreateCompanionBuilder,
          $$DestinationsTableTableUpdateCompanionBuilder,
          (
            DestinationsTableData,
            BaseReferences<
              _$AppDatabase,
              $DestinationsTableTable,
              DestinationsTableData
            >,
          ),
          DestinationsTableData,
          PrefetchHooks Function()
        > {
  $$DestinationsTableTableTableManager(
    _$AppDatabase db,
    $DestinationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DestinationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DestinationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DestinationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<String> duration = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> price = const Value.absent(),
                Value<String> reviewsCount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<bool> isRecommended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestinationsTableCompanion(
                id: id,
                name: name,
                location: location,
                rating: rating,
                duration: duration,
                imagePath: imagePath,
                isFavorite: isFavorite,
                description: description,
                price: price,
                reviewsCount: reviewsCount,
                category: category,
                latitude: latitude,
                longitude: longitude,
                isRecommended: isRecommended,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String location,
                Value<String> rating = const Value.absent(),
                Value<String> duration = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> price = const Value.absent(),
                Value<String> reviewsCount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<bool> isRecommended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestinationsTableCompanion.insert(
                id: id,
                name: name,
                location: location,
                rating: rating,
                duration: duration,
                imagePath: imagePath,
                isFavorite: isFavorite,
                description: description,
                price: price,
                reviewsCount: reviewsCount,
                category: category,
                latitude: latitude,
                longitude: longitude,
                isRecommended: isRecommended,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DestinationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DestinationsTableTable,
      DestinationsTableData,
      $$DestinationsTableTableFilterComposer,
      $$DestinationsTableTableOrderingComposer,
      $$DestinationsTableTableAnnotationComposer,
      $$DestinationsTableTableCreateCompanionBuilder,
      $$DestinationsTableTableUpdateCompanionBuilder,
      (
        DestinationsTableData,
        BaseReferences<
          _$AppDatabase,
          $DestinationsTableTable,
          DestinationsTableData
        >,
      ),
      DestinationsTableData,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableTableCreateCompanionBuilder =
    CategoriesTableCompanion Function({
      required String id,
      Value<String> name,
      Value<int> rowid,
    });
typedef $$CategoriesTableTableUpdateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
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
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
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
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
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
}

class $$CategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData,
          $$CategoriesTableTableFilterComposer,
          $$CategoriesTableTableOrderingComposer,
          $$CategoriesTableTableAnnotationComposer,
          $$CategoriesTableTableCreateCompanionBuilder,
          $$CategoriesTableTableUpdateCompanionBuilder,
          (
            CategoriesTableData,
            BaseReferences<
              _$AppDatabase,
              $CategoriesTableTable,
              CategoriesTableData
            >,
          ),
          CategoriesTableData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableTableManager(
    _$AppDatabase db,
    $CategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTableTable,
      CategoriesTableData,
      $$CategoriesTableTableFilterComposer,
      $$CategoriesTableTableOrderingComposer,
      $$CategoriesTableTableAnnotationComposer,
      $$CategoriesTableTableCreateCompanionBuilder,
      $$CategoriesTableTableUpdateCompanionBuilder,
      (
        CategoriesTableData,
        BaseReferences<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData
        >,
      ),
      CategoriesTableData,
      PrefetchHooks Function()
    >;
typedef $$HotelsTableTableCreateCompanionBuilder =
    HotelsTableCompanion Function({
      required String id,
      required String name,
      required String location,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> rating,
      Value<String> imagePath,
      Value<String> description,
      Value<double> priceFrom,
      Value<String> address,
      Value<String> amenities,
      Value<int> rowid,
    });
typedef $$HotelsTableTableUpdateCompanionBuilder =
    HotelsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> location,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> rating,
      Value<String> imagePath,
      Value<String> description,
      Value<double> priceFrom,
      Value<String> address,
      Value<String> amenities,
      Value<int> rowid,
    });

class $$HotelsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HotelsTableTable> {
  $$HotelsTableTableFilterComposer({
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

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
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

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceFrom => $composableBuilder(
    column: $table.priceFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HotelsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HotelsTableTable> {
  $$HotelsTableTableOrderingComposer({
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

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
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

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceFrom => $composableBuilder(
    column: $table.priceFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HotelsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HotelsTableTable> {
  $$HotelsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get priceFrom =>
      $composableBuilder(column: $table.priceFrom, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get amenities =>
      $composableBuilder(column: $table.amenities, builder: (column) => column);
}

class $$HotelsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HotelsTableTable,
          HotelsTableData,
          $$HotelsTableTableFilterComposer,
          $$HotelsTableTableOrderingComposer,
          $$HotelsTableTableAnnotationComposer,
          $$HotelsTableTableCreateCompanionBuilder,
          $$HotelsTableTableUpdateCompanionBuilder,
          (
            HotelsTableData,
            BaseReferences<_$AppDatabase, $HotelsTableTable, HotelsTableData>,
          ),
          HotelsTableData,
          PrefetchHooks Function()
        > {
  $$HotelsTableTableTableManager(_$AppDatabase db, $HotelsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HotelsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HotelsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HotelsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> priceFrom = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HotelsTableCompanion(
                id: id,
                name: name,
                location: location,
                latitude: latitude,
                longitude: longitude,
                rating: rating,
                imagePath: imagePath,
                description: description,
                priceFrom: priceFrom,
                address: address,
                amenities: amenities,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String location,
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> priceFrom = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HotelsTableCompanion.insert(
                id: id,
                name: name,
                location: location,
                latitude: latitude,
                longitude: longitude,
                rating: rating,
                imagePath: imagePath,
                description: description,
                priceFrom: priceFrom,
                address: address,
                amenities: amenities,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HotelsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HotelsTableTable,
      HotelsTableData,
      $$HotelsTableTableFilterComposer,
      $$HotelsTableTableOrderingComposer,
      $$HotelsTableTableAnnotationComposer,
      $$HotelsTableTableCreateCompanionBuilder,
      $$HotelsTableTableUpdateCompanionBuilder,
      (
        HotelsTableData,
        BaseReferences<_$AppDatabase, $HotelsTableTable, HotelsTableData>,
      ),
      HotelsTableData,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableTableCreateCompanionBuilder =
    RoomsTableCompanion Function({
      required String id,
      required String hotelId,
      required String name,
      Value<String> description,
      Value<double> price,
      Value<int> capacity,
      Value<String> imagePath,
      Value<String> amenities,
      Value<int> rowid,
    });
typedef $$RoomsTableTableUpdateCompanionBuilder =
    RoomsTableCompanion Function({
      Value<String> id,
      Value<String> hotelId,
      Value<String> name,
      Value<String> description,
      Value<double> price,
      Value<int> capacity,
      Value<String> imagePath,
      Value<String> amenities,
      Value<int> rowid,
    });

class $$RoomsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RoomsTableTable> {
  $$RoomsTableTableFilterComposer({
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

  ColumnFilters<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoomsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTableTable> {
  $$RoomsTableTableOrderingComposer({
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

  ColumnOrderings<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTableTable> {
  $$RoomsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hotelId =>
      $composableBuilder(column: $table.hotelId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get amenities =>
      $composableBuilder(column: $table.amenities, builder: (column) => column);
}

class $$RoomsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTableTable,
          RoomsTableData,
          $$RoomsTableTableFilterComposer,
          $$RoomsTableTableOrderingComposer,
          $$RoomsTableTableAnnotationComposer,
          $$RoomsTableTableCreateCompanionBuilder,
          $$RoomsTableTableUpdateCompanionBuilder,
          (
            RoomsTableData,
            BaseReferences<_$AppDatabase, $RoomsTableTable, RoomsTableData>,
          ),
          RoomsTableData,
          PrefetchHooks Function()
        > {
  $$RoomsTableTableTableManager(_$AppDatabase db, $RoomsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hotelId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsTableCompanion(
                id: id,
                hotelId: hotelId,
                name: name,
                description: description,
                price: price,
                capacity: capacity,
                imagePath: imagePath,
                amenities: amenities,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hotelId,
                required String name,
                Value<String> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsTableCompanion.insert(
                id: id,
                hotelId: hotelId,
                name: name,
                description: description,
                price: price,
                capacity: capacity,
                imagePath: imagePath,
                amenities: amenities,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoomsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTableTable,
      RoomsTableData,
      $$RoomsTableTableFilterComposer,
      $$RoomsTableTableOrderingComposer,
      $$RoomsTableTableAnnotationComposer,
      $$RoomsTableTableCreateCompanionBuilder,
      $$RoomsTableTableUpdateCompanionBuilder,
      (
        RoomsTableData,
        BaseReferences<_$AppDatabase, $RoomsTableTable, RoomsTableData>,
      ),
      RoomsTableData,
      PrefetchHooks Function()
    >;
typedef $$TourPackagesTableTableCreateCompanionBuilder =
    TourPackagesTableCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<String> imagePath,
      Value<String> duration,
      Value<double> price,
      Value<double?> originalPrice,
      Value<String> destinations,
      Value<String> includes,
      Value<String> departure,
      Value<String?> departureDate,
      Value<bool> isPopular,
      Value<bool> includesGuide,
      Value<double> guideFee,
      Value<int> rowid,
    });
typedef $$TourPackagesTableTableUpdateCompanionBuilder =
    TourPackagesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> imagePath,
      Value<String> duration,
      Value<double> price,
      Value<double?> originalPrice,
      Value<String> destinations,
      Value<String> includes,
      Value<String> departure,
      Value<String?> departureDate,
      Value<bool> isPopular,
      Value<bool> includesGuide,
      Value<double> guideFee,
      Value<int> rowid,
    });

class $$TourPackagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TourPackagesTableTable> {
  $$TourPackagesTableTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinations => $composableBuilder(
    column: $table.destinations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get includes => $composableBuilder(
    column: $table.includes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departure => $composableBuilder(
    column: $table.departure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureDate => $composableBuilder(
    column: $table.departureDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPopular => $composableBuilder(
    column: $table.isPopular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includesGuide => $composableBuilder(
    column: $table.includesGuide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get guideFee => $composableBuilder(
    column: $table.guideFee,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TourPackagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TourPackagesTableTable> {
  $$TourPackagesTableTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinations => $composableBuilder(
    column: $table.destinations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get includes => $composableBuilder(
    column: $table.includes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departure => $composableBuilder(
    column: $table.departure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureDate => $composableBuilder(
    column: $table.departureDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPopular => $composableBuilder(
    column: $table.isPopular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includesGuide => $composableBuilder(
    column: $table.includesGuide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get guideFee => $composableBuilder(
    column: $table.guideFee,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TourPackagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TourPackagesTableTable> {
  $$TourPackagesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinations => $composableBuilder(
    column: $table.destinations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get includes =>
      $composableBuilder(column: $table.includes, builder: (column) => column);

  GeneratedColumn<String> get departure =>
      $composableBuilder(column: $table.departure, builder: (column) => column);

  GeneratedColumn<String> get departureDate => $composableBuilder(
    column: $table.departureDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPopular =>
      $composableBuilder(column: $table.isPopular, builder: (column) => column);

  GeneratedColumn<bool> get includesGuide => $composableBuilder(
    column: $table.includesGuide,
    builder: (column) => column,
  );

  GeneratedColumn<double> get guideFee =>
      $composableBuilder(column: $table.guideFee, builder: (column) => column);
}

class $$TourPackagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TourPackagesTableTable,
          TourPackagesTableData,
          $$TourPackagesTableTableFilterComposer,
          $$TourPackagesTableTableOrderingComposer,
          $$TourPackagesTableTableAnnotationComposer,
          $$TourPackagesTableTableCreateCompanionBuilder,
          $$TourPackagesTableTableUpdateCompanionBuilder,
          (
            TourPackagesTableData,
            BaseReferences<
              _$AppDatabase,
              $TourPackagesTableTable,
              TourPackagesTableData
            >,
          ),
          TourPackagesTableData,
          PrefetchHooks Function()
        > {
  $$TourPackagesTableTableTableManager(
    _$AppDatabase db,
    $TourPackagesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TourPackagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TourPackagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TourPackagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> duration = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> originalPrice = const Value.absent(),
                Value<String> destinations = const Value.absent(),
                Value<String> includes = const Value.absent(),
                Value<String> departure = const Value.absent(),
                Value<String?> departureDate = const Value.absent(),
                Value<bool> isPopular = const Value.absent(),
                Value<bool> includesGuide = const Value.absent(),
                Value<double> guideFee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourPackagesTableCompanion(
                id: id,
                name: name,
                description: description,
                imagePath: imagePath,
                duration: duration,
                price: price,
                originalPrice: originalPrice,
                destinations: destinations,
                includes: includes,
                departure: departure,
                departureDate: departureDate,
                isPopular: isPopular,
                includesGuide: includesGuide,
                guideFee: guideFee,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> duration = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> originalPrice = const Value.absent(),
                Value<String> destinations = const Value.absent(),
                Value<String> includes = const Value.absent(),
                Value<String> departure = const Value.absent(),
                Value<String?> departureDate = const Value.absent(),
                Value<bool> isPopular = const Value.absent(),
                Value<bool> includesGuide = const Value.absent(),
                Value<double> guideFee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourPackagesTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                imagePath: imagePath,
                duration: duration,
                price: price,
                originalPrice: originalPrice,
                destinations: destinations,
                includes: includes,
                departure: departure,
                departureDate: departureDate,
                isPopular: isPopular,
                includesGuide: includesGuide,
                guideFee: guideFee,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TourPackagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TourPackagesTableTable,
      TourPackagesTableData,
      $$TourPackagesTableTableFilterComposer,
      $$TourPackagesTableTableOrderingComposer,
      $$TourPackagesTableTableAnnotationComposer,
      $$TourPackagesTableTableCreateCompanionBuilder,
      $$TourPackagesTableTableUpdateCompanionBuilder,
      (
        TourPackagesTableData,
        BaseReferences<
          _$AppDatabase,
          $TourPackagesTableTable,
          TourPackagesTableData
        >,
      ),
      TourPackagesTableData,
      PrefetchHooks Function()
    >;
typedef $$TripsTableTableCreateCompanionBuilder =
    TripsTableCompanion Function({
      required String id,
      required String destination,
      Value<String> location,
      Value<String> date,
      Value<String> guests,
      Value<String> status,
      Value<String> imagePath,
      Value<bool> isUpcoming,
      Value<String?> flightId,
      Value<String?> hotelId,
      Value<String?> roomId,
      Value<double?> totalPrice,
      Value<bool> isCustom,
      Value<String> createdAt,
      Value<int> rowid,
    });
typedef $$TripsTableTableUpdateCompanionBuilder =
    TripsTableCompanion Function({
      Value<String> id,
      Value<String> destination,
      Value<String> location,
      Value<String> date,
      Value<String> guests,
      Value<String> status,
      Value<String> imagePath,
      Value<bool> isUpcoming,
      Value<String?> flightId,
      Value<String?> hotelId,
      Value<String?> roomId,
      Value<double?> totalPrice,
      Value<bool> isCustom,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$TripsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableFilterComposer({
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

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUpcoming => $composableBuilder(
    column: $table.isUpcoming,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flightId => $composableBuilder(
    column: $table.flightId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableOrderingComposer({
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

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUpcoming => $composableBuilder(
    column: $table.isUpcoming,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flightId => $composableBuilder(
    column: $table.flightId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isUpcoming => $composableBuilder(
    column: $table.isUpcoming,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flightId =>
      $composableBuilder(column: $table.flightId, builder: (column) => column);

  GeneratedColumn<String> get hotelId =>
      $composableBuilder(column: $table.hotelId, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TripsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTableTable,
          TripsTableData,
          $$TripsTableTableFilterComposer,
          $$TripsTableTableOrderingComposer,
          $$TripsTableTableAnnotationComposer,
          $$TripsTableTableCreateCompanionBuilder,
          $$TripsTableTableUpdateCompanionBuilder,
          (
            TripsTableData,
            BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
          ),
          TripsTableData,
          PrefetchHooks Function()
        > {
  $$TripsTableTableTableManager(_$AppDatabase db, $TripsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> isUpcoming = const Value.absent(),
                Value<String?> flightId = const Value.absent(),
                Value<String?> hotelId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<double?> totalPrice = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion(
                id: id,
                destination: destination,
                location: location,
                date: date,
                guests: guests,
                status: status,
                imagePath: imagePath,
                isUpcoming: isUpcoming,
                flightId: flightId,
                hotelId: hotelId,
                roomId: roomId,
                totalPrice: totalPrice,
                isCustom: isCustom,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String destination,
                Value<String> location = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> isUpcoming = const Value.absent(),
                Value<String?> flightId = const Value.absent(),
                Value<String?> hotelId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<double?> totalPrice = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion.insert(
                id: id,
                destination: destination,
                location: location,
                date: date,
                guests: guests,
                status: status,
                imagePath: imagePath,
                isUpcoming: isUpcoming,
                flightId: flightId,
                hotelId: hotelId,
                roomId: roomId,
                totalPrice: totalPrice,
                isCustom: isCustom,
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

typedef $$TripsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTableTable,
      TripsTableData,
      $$TripsTableTableFilterComposer,
      $$TripsTableTableOrderingComposer,
      $$TripsTableTableAnnotationComposer,
      $$TripsTableTableCreateCompanionBuilder,
      $$TripsTableTableUpdateCompanionBuilder,
      (
        TripsTableData,
        BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
      ),
      TripsTableData,
      PrefetchHooks Function()
    >;
typedef $$TripScheduleDaysTableTableCreateCompanionBuilder =
    TripScheduleDaysTableCompanion Function({
      required String id,
      required String tripId,
      Value<int> dayNumber,
      Value<String?> date,
      Value<String> title,
      Value<int> rowid,
    });
typedef $$TripScheduleDaysTableTableUpdateCompanionBuilder =
    TripScheduleDaysTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<int> dayNumber,
      Value<String?> date,
      Value<String> title,
      Value<int> rowid,
    });

class $$TripScheduleDaysTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripScheduleDaysTableTable> {
  $$TripScheduleDaysTableTableFilterComposer({
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

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripScheduleDaysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripScheduleDaysTableTable> {
  $$TripScheduleDaysTableTableOrderingComposer({
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

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripScheduleDaysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripScheduleDaysTableTable> {
  $$TripScheduleDaysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
}

class $$TripScheduleDaysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripScheduleDaysTableTable,
          TripScheduleDaysTableData,
          $$TripScheduleDaysTableTableFilterComposer,
          $$TripScheduleDaysTableTableOrderingComposer,
          $$TripScheduleDaysTableTableAnnotationComposer,
          $$TripScheduleDaysTableTableCreateCompanionBuilder,
          $$TripScheduleDaysTableTableUpdateCompanionBuilder,
          (
            TripScheduleDaysTableData,
            BaseReferences<
              _$AppDatabase,
              $TripScheduleDaysTableTable,
              TripScheduleDaysTableData
            >,
          ),
          TripScheduleDaysTableData,
          PrefetchHooks Function()
        > {
  $$TripScheduleDaysTableTableTableManager(
    _$AppDatabase db,
    $TripScheduleDaysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripScheduleDaysTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TripScheduleDaysTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TripScheduleDaysTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleDaysTableCompanion(
                id: id,
                tripId: tripId,
                dayNumber: dayNumber,
                date: date,
                title: title,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<int> dayNumber = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleDaysTableCompanion.insert(
                id: id,
                tripId: tripId,
                dayNumber: dayNumber,
                date: date,
                title: title,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripScheduleDaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripScheduleDaysTableTable,
      TripScheduleDaysTableData,
      $$TripScheduleDaysTableTableFilterComposer,
      $$TripScheduleDaysTableTableOrderingComposer,
      $$TripScheduleDaysTableTableAnnotationComposer,
      $$TripScheduleDaysTableTableCreateCompanionBuilder,
      $$TripScheduleDaysTableTableUpdateCompanionBuilder,
      (
        TripScheduleDaysTableData,
        BaseReferences<
          _$AppDatabase,
          $TripScheduleDaysTableTable,
          TripScheduleDaysTableData
        >,
      ),
      TripScheduleDaysTableData,
      PrefetchHooks Function()
    >;
typedef $$TripScheduleItemsTableTableCreateCompanionBuilder =
    TripScheduleItemsTableCompanion Function({
      required String id,
      required String dayId,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> title,
      Value<String> description,
      Value<String> locationName,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> sortOrder,
      Value<String?> statusOverride,
      Value<String?> note,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$TripScheduleItemsTableTableUpdateCompanionBuilder =
    TripScheduleItemsTableCompanion Function({
      Value<String> id,
      Value<String> dayId,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> title,
      Value<String> description,
      Value<String> locationName,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> sortOrder,
      Value<String?> statusOverride,
      Value<String?> note,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$TripScheduleItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripScheduleItemsTableTable> {
  $$TripScheduleItemsTableTableFilterComposer({
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

  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
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

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusOverride => $composableBuilder(
    column: $table.statusOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripScheduleItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripScheduleItemsTableTable> {
  $$TripScheduleItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
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

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusOverride => $composableBuilder(
    column: $table.statusOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripScheduleItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripScheduleItemsTableTable> {
  $$TripScheduleItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get statusOverride => $composableBuilder(
    column: $table.statusOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripScheduleItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripScheduleItemsTableTable,
          TripScheduleItemsTableData,
          $$TripScheduleItemsTableTableFilterComposer,
          $$TripScheduleItemsTableTableOrderingComposer,
          $$TripScheduleItemsTableTableAnnotationComposer,
          $$TripScheduleItemsTableTableCreateCompanionBuilder,
          $$TripScheduleItemsTableTableUpdateCompanionBuilder,
          (
            TripScheduleItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $TripScheduleItemsTableTable,
              TripScheduleItemsTableData
            >,
          ),
          TripScheduleItemsTableData,
          PrefetchHooks Function()
        > {
  $$TripScheduleItemsTableTableTableManager(
    _$AppDatabase db,
    $TripScheduleItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripScheduleItemsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TripScheduleItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TripScheduleItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> statusOverride = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleItemsTableCompanion(
                id: id,
                dayId: dayId,
                startTime: startTime,
                endTime: endTime,
                title: title,
                description: description,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                sortOrder: sortOrder,
                statusOverride: statusOverride,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dayId,
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> statusOverride = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleItemsTableCompanion.insert(
                id: id,
                dayId: dayId,
                startTime: startTime,
                endTime: endTime,
                title: title,
                description: description,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                sortOrder: sortOrder,
                statusOverride: statusOverride,
                note: note,
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

typedef $$TripScheduleItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripScheduleItemsTableTable,
      TripScheduleItemsTableData,
      $$TripScheduleItemsTableTableFilterComposer,
      $$TripScheduleItemsTableTableOrderingComposer,
      $$TripScheduleItemsTableTableAnnotationComposer,
      $$TripScheduleItemsTableTableCreateCompanionBuilder,
      $$TripScheduleItemsTableTableUpdateCompanionBuilder,
      (
        TripScheduleItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $TripScheduleItemsTableTable,
          TripScheduleItemsTableData
        >,
      ),
      TripScheduleItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$TripScheduleUpdatesTableTableCreateCompanionBuilder =
    TripScheduleUpdatesTableCompanion Function({
      required String id,
      required String tripId,
      required String message,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$TripScheduleUpdatesTableTableUpdateCompanionBuilder =
    TripScheduleUpdatesTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> message,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$TripScheduleUpdatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripScheduleUpdatesTableTable> {
  $$TripScheduleUpdatesTableTableFilterComposer({
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

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripScheduleUpdatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripScheduleUpdatesTableTable> {
  $$TripScheduleUpdatesTableTableOrderingComposer({
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

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripScheduleUpdatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripScheduleUpdatesTableTable> {
  $$TripScheduleUpdatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TripScheduleUpdatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripScheduleUpdatesTableTable,
          TripScheduleUpdatesTableData,
          $$TripScheduleUpdatesTableTableFilterComposer,
          $$TripScheduleUpdatesTableTableOrderingComposer,
          $$TripScheduleUpdatesTableTableAnnotationComposer,
          $$TripScheduleUpdatesTableTableCreateCompanionBuilder,
          $$TripScheduleUpdatesTableTableUpdateCompanionBuilder,
          (
            TripScheduleUpdatesTableData,
            BaseReferences<
              _$AppDatabase,
              $TripScheduleUpdatesTableTable,
              TripScheduleUpdatesTableData
            >,
          ),
          TripScheduleUpdatesTableData,
          PrefetchHooks Function()
        > {
  $$TripScheduleUpdatesTableTableTableManager(
    _$AppDatabase db,
    $TripScheduleUpdatesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripScheduleUpdatesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TripScheduleUpdatesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TripScheduleUpdatesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleUpdatesTableCompanion(
                id: id,
                tripId: tripId,
                message: message,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String message,
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TripScheduleUpdatesTableCompanion.insert(
                id: id,
                tripId: tripId,
                message: message,
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

typedef $$TripScheduleUpdatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripScheduleUpdatesTableTable,
      TripScheduleUpdatesTableData,
      $$TripScheduleUpdatesTableTableFilterComposer,
      $$TripScheduleUpdatesTableTableOrderingComposer,
      $$TripScheduleUpdatesTableTableAnnotationComposer,
      $$TripScheduleUpdatesTableTableCreateCompanionBuilder,
      $$TripScheduleUpdatesTableTableUpdateCompanionBuilder,
      (
        TripScheduleUpdatesTableData,
        BaseReferences<
          _$AppDatabase,
          $TripScheduleUpdatesTableTable,
          TripScheduleUpdatesTableData
        >,
      ),
      TripScheduleUpdatesTableData,
      PrefetchHooks Function()
    >;
typedef $$ReviewsTableTableCreateCompanionBuilder =
    ReviewsTableCompanion Function({
      required String id,
      required String userId,
      Value<String> userName,
      required String targetType,
      required String targetId,
      Value<int> rating,
      Value<String> comment,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$ReviewsTableTableUpdateCompanionBuilder =
    ReviewsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> userName,
      Value<String> targetType,
      Value<String> targetId,
      Value<int> rating,
      Value<String> comment,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$ReviewsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewsTableTable> {
  $$ReviewsTableTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewsTableTable> {
  $$ReviewsTableTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewsTableTable> {
  $$ReviewsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReviewsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewsTableTable,
          ReviewsTableData,
          $$ReviewsTableTableFilterComposer,
          $$ReviewsTableTableOrderingComposer,
          $$ReviewsTableTableAnnotationComposer,
          $$ReviewsTableTableCreateCompanionBuilder,
          $$ReviewsTableTableUpdateCompanionBuilder,
          (
            ReviewsTableData,
            BaseReferences<_$AppDatabase, $ReviewsTableTable, ReviewsTableData>,
          ),
          ReviewsTableData,
          PrefetchHooks Function()
        > {
  $$ReviewsTableTableTableManager(_$AppDatabase db, $ReviewsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewsTableCompanion(
                id: id,
                userId: userId,
                userName: userName,
                targetType: targetType,
                targetId: targetId,
                rating: rating,
                comment: comment,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> userName = const Value.absent(),
                required String targetType,
                required String targetId,
                Value<int> rating = const Value.absent(),
                Value<String> comment = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewsTableCompanion.insert(
                id: id,
                userId: userId,
                userName: userName,
                targetType: targetType,
                targetId: targetId,
                rating: rating,
                comment: comment,
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

typedef $$ReviewsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewsTableTable,
      ReviewsTableData,
      $$ReviewsTableTableFilterComposer,
      $$ReviewsTableTableOrderingComposer,
      $$ReviewsTableTableAnnotationComposer,
      $$ReviewsTableTableCreateCompanionBuilder,
      $$ReviewsTableTableUpdateCompanionBuilder,
      (
        ReviewsTableData,
        BaseReferences<_$AppDatabase, $ReviewsTableTable, ReviewsTableData>,
      ),
      ReviewsTableData,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableTableCreateCompanionBuilder =
    DocumentsTableCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      Value<String> iconName,
      Value<String> colorHex,
      Value<int> rowid,
    });
typedef $$DocumentsTableTableUpdateCompanionBuilder =
    DocumentsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> iconName,
      Value<String> colorHex,
      Value<int> rowid,
    });

class $$DocumentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableFilterComposer({
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

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);
}

class $$DocumentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTableTable,
          DocumentsTableData,
          $$DocumentsTableTableFilterComposer,
          $$DocumentsTableTableOrderingComposer,
          $$DocumentsTableTableAnnotationComposer,
          $$DocumentsTableTableCreateCompanionBuilder,
          $$DocumentsTableTableUpdateCompanionBuilder,
          (
            DocumentsTableData,
            BaseReferences<
              _$AppDatabase,
              $DocumentsTableTable,
              DocumentsTableData
            >,
          ),
          DocumentsTableData,
          PrefetchHooks Function()
        > {
  $$DocumentsTableTableTableManager(
    _$AppDatabase db,
    $DocumentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion(
                id: id,
                title: title,
                description: description,
                iconName: iconName,
                colorHex: colorHex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                iconName: iconName,
                colorHex: colorHex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTableTable,
      DocumentsTableData,
      $$DocumentsTableTableFilterComposer,
      $$DocumentsTableTableOrderingComposer,
      $$DocumentsTableTableAnnotationComposer,
      $$DocumentsTableTableCreateCompanionBuilder,
      $$DocumentsTableTableUpdateCompanionBuilder,
      (
        DocumentsTableData,
        BaseReferences<_$AppDatabase, $DocumentsTableTable, DocumentsTableData>,
      ),
      DocumentsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DestinationsTableTableTableManager get destinationsTable =>
      $$DestinationsTableTableTableManager(_db, _db.destinationsTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$HotelsTableTableTableManager get hotelsTable =>
      $$HotelsTableTableTableManager(_db, _db.hotelsTable);
  $$RoomsTableTableTableManager get roomsTable =>
      $$RoomsTableTableTableManager(_db, _db.roomsTable);
  $$TourPackagesTableTableTableManager get tourPackagesTable =>
      $$TourPackagesTableTableTableManager(_db, _db.tourPackagesTable);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db, _db.tripsTable);
  $$TripScheduleDaysTableTableTableManager get tripScheduleDaysTable =>
      $$TripScheduleDaysTableTableTableManager(_db, _db.tripScheduleDaysTable);
  $$TripScheduleItemsTableTableTableManager get tripScheduleItemsTable =>
      $$TripScheduleItemsTableTableTableManager(
        _db,
        _db.tripScheduleItemsTable,
      );
  $$TripScheduleUpdatesTableTableTableManager get tripScheduleUpdatesTable =>
      $$TripScheduleUpdatesTableTableTableManager(
        _db,
        _db.tripScheduleUpdatesTable,
      );
  $$ReviewsTableTableTableManager get reviewsTable =>
      $$ReviewsTableTableTableManager(_db, _db.reviewsTable);
  $$DocumentsTableTableTableManager get documentsTable =>
      $$DocumentsTableTableTableManager(_db, _db.documentsTable);
}
