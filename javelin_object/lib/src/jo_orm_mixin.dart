mixin JoOrmMixin {
  Set<String>? _modifiedFields;

  /// Start tracking field updates.
  ///
  /// When fields are tracked, only updated fields will be sent.
  void joStartTrackingFieldUpdates() => _modifiedFields = {};

  /// Stop tracking field updates.
  ///
  /// When fields are not tracked, then all fields will be updated.
  void joStopTrackingFieldUpdates() => _modifiedFields = null;

  bool joDoesFieldRequireUpdate(String fieldName) {
    final localModifiedFields = _modifiedFields;
    return localModifiedFields == null ||
        localModifiedFields.contains(fieldName);
  }

  void joTagFieldUpdated(String fieldName) {
    final localModifiedFields = _modifiedFields;
    if (localModifiedFields == null) return;
    localModifiedFields.add(fieldName);
  }

  /// Returns all of the columns required to persist the object.
  ///
  /// toMap() will return all of the fields in the object, but subobjects create
  /// their own maps.
  ///
  /// toOrmMap() instead will have object references, and flattened objects.
  ///
  /// For comparison:
  ///   @Table
  ///   User {
  ///     Int id;
  ///     String name;
  ///     Company company;
  ///     PhoneNumber phoneNumber;
  ///   }
  ///
  ///   @Table
  ///   Company {
  ///     Int id;
  ///     String name;
  ///   }
  ///
  ///   // Not a @Table
  ///   PhoneNumber {
  ///     Int countryCode;
  ///     String nationalNumber;
  ///   }
  ///
  /// toMap() will return:
  ///    id: 1,
  ///    name: 'John Smith',
  ///    company: {
  ///      id: 2,
  ///      name: 'Some Company Pty Ltd.',
  ///    }
  ///    phoneNumber: {
  ///      countryCode: 61,
  ///      nationalNumber: '9876 5432',
  ///    }
  ///
  /// Whereas toOrmMap() will return:
  ///    id: 1,
  ///    name: 'John Smith',
  ///    company: company.id,
  ///    phoneNumber.countryCode: 61,
  ///    phoneNumber.nationalNumber: '9876 5432',
  Map<String, Object?> toOrmMap();
}
