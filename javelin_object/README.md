# Javelin Objects

A Javelin Object is one that can be serialized for storage or RPC whilst 
still being lightweight enough to use outside of code specifically dealing 
with RPC or storage.

## Goals

* Unify representation of rpc object, data object and database objects.

* Tight integration with dart.

* Enforce type and null safety. Optional types are suffixed with '?'
  * Bool
  * Int8 / Int32 / Int64 / Uint8 / Uint32 / Uint64
  * Float / Double
  * String
  * Bytes
  * List<T>
  * Set<T>
  * Map<K, V>

* Support multiple storage mechanisms.

* Support multiple serialization mechanisms.
  * binary
  * text
  * json
  * yaml
  * messagepack
  * proto
  * dart-map
  * dart-tostring
  * xml

* Only generates code for required features, e.g. If an object is only used
  for RPC purposes, then it does not generate DB related code.

* Automatically generate query code using simple descriptor language.

* Conditional code generation, e.g. debug builds may want a toString(), but 
  release builds may not.

## Syntax

A .jo format is used to describe the related data and looks a lot like dart.

```dart
@Buildable
@CopyWith
@Convert(fromJson: true, toJson: true)
@Comparable(fields: ['firstName', 'lastName'], orderedOperators: true)
@Storable(stores: ['postgres', 'mysql'])
class Person {
  @Column(primary: true)
  @ProtoField(include: false)
  0: Int64? id;

  @Column
  1: String firstName;

  @Column
  2: String lastName;

  @Column(name: 'home')
  3: PhoneNumber? homePhoneNumber;  

  @Column(name: 'work')
  4: PhoneNumber? workPhoneNumber;

  @GenerateQuery(query: 'id == {id}')
  Person fetchById(Int id);

  @GenerateQuery(query: 'name.contains({searchTerm})')
  List<Person> fetchByNameContaining(String searchTerm);

  @GenerateQuery(query: 'id == {id}')
  Bool containsId(Int id);

  @GenerateQuery(query: 'name == "John"')
  Int32 countJohns();

  @GenerateQuery(query: 'homePhoneNumber.country == 1')
  List<Person> fetchAmericanHomePhonenumbers();
}

class PhoneNumber {
  @Column(name: 'country')
  Int32 countryCode;

  @Column
  String nationalNumber;
}
```

### Generated code

```dart
  class Person {
    const Person({
      this.id,
      required this.firstName,
      required this.lastName,
      this.homePhoneNumber,
       this.workPhoneNumber,
    });

    final int? id;
    final String firstName;
    final String lastName;
    final PhoneNumber? homePhoneNumber;
    final PhoneNumber? workPhoneNumber;
  }

```

Due to `@Buildable` being present:

```dart
  class Person {
    ...

    static _PersonBuilder builder() => _PersonBuilder();

    ...

    _Personbuilder toBuilder() => _PersonBuilder(
      id: id,
      firstName: firstName,
      lastName: lastName,
      homePhoneNumber: homePhoneNumber,
      workPhoneNumber: workPhoneNumber,
    );
  }

  class _PersonBuilder {
    _PersonBuilder({
      this.id,
      this.firstName,
      this.lastName,
      this.homePhoneNumber,
      this.workPhoneNumber,
    });

    int? id;
    String? firstName;
    String? lastName;
    PhoneNumber? homePhoneNumber;
    PhoneNumber? workPhoneNumber;

    Person build() => Person(
      id: id,
      firstName: firstName!,
      lastName: lastName!,
      homePhoneNumber: homePhoneNumber,
      workPhoneNumber: workPhoneNumber,
    );
  }
```

Due to `@CopyWith` being present:

```dart
  class Person {
    ...

    Person copyWith({
      int? id,
      String? firstName,
      String? lastName,
      PhoneNumber? homePhoneNumber,
      PhoneNumber? workPhoneNumber,
    }) {
      return Person(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        homePhoneNumber: homePhoneNumber ?? this.homePhoneNumber,
        workPhoneNumber: workPhoneNumber ?? this.workPhoneNumber,
      );
    }
  }
```

Due to `@Comparable(fields: [firstName, lastName], generateOrderedOperators: true)` being present:

Comparable will provide operator==

```dart
  class Person implements Comparable<Person> {
    ...

    @override
    int get hashCode {
      ...
    }

    @override
    int compareTo(Person other) {

    }

    @override
    bool operator==(Object other) => other is Person && compareTo(other) == 0;

    bool operator!=(Object other) => other is! Person || compareTo(other) != 0;

    bool operator<(Person other) => compareTo(other) < 0;
    bool operator<=(Person other) => compareTo(other) <= 0;
    bool operator>(Person other) => compareTo(other) > 0;
    bool operator<=(Person other) => compareTo(other) >= 0;
```

# Stores

It is possible to use a serializer to convert to/from a representation that
can be stored, but JavelinDataObjects provides a richer

# Serializers

## Serializer.binary

Adds the following capabilities to the object:

```dart
  final person = Person.fromBinary(Uint8List binary);
  final binary = person.toBinary();
```

## Serializer.text

Adds the following capabilities to the object:

```dart
  final person = Person.fromText(String text);
  final text = person.toText();
```

## Serializer.json

Adds the following capabilities to the object:

```dart
  final person = Person.fromJson(String json);
  final json = person.toJson();
  final json = person.toJson(pretty: true);
```

## Serializer.messagePack

Adds the following capabilities to the object:

```dart
  final person = Person.fromMessagePack(Uint8List messagePackBytes);
  final messagePack = person.toMessagePack();
```

## Serializer.proto

Adds the following capabilities to the object:

```dart
  final person = Person.fromProto(Uint8List protoBytes);
  final bytes = person.toProto();
```

# Usage

```dart
  final person = Person.builder()
    ..firstName = 'John'
    ..lastName = 'Smith'
    ..build();
```

```dart
  final person = Person(
    firstName: 'John',
    lastName: 'Smith',
  );

  person.save();
```

# BNF

```bnf
statement := import_statement
             | class_declaration
             | union_declaration
             | enum_declaration

import_statement := 'import' path ';'

class_declaration := [annotation_list] ['extendable' | 'virtual'] 
                     'class' class_name 
                     ['extends' class_name] 
                     '{' class_element* '}'

class_element := field_declaration
                 | method_declaration

union_declaration := [annotation_list] 'union' union_name 
                     '{' union_element* '}'

union_element := field_declaration

field_declaration := [annotation_list] [id ':'] type name ['=' default_value] ';'

method_declaration := [annotation_list] type name '(' parameter_list ')' ';'

enum_declaration := [annotation_list] 'enum' enum_name '{' enum_element '}'

enum_element := field_declaration
                | enum_value_declaration

enum_value_declaration := [annotation_list] [id ':'] enum_value_name ['=' enum_field_values] ';'

enum_field_value := field_value_list
                    | named_field_value_list

field_value_list := (value [','])+ ';'

named_field_value_list := (field_name ':' value [','])* ';'

type := type_base ['?']
type_base := 'Bool'
             | 'Int8'
             | 'Uint8'
             | 'Int32'
             | 'Int64'
             | 'Uint32'
             | 'Uint64'
             | 'Float'
             | 'Double'
             | 'String'
             | 'Bytes'
             | 'List' '<' type '>'
             | 'Set' '<' type '>'
             | 'Map' '<' type ',' type '>'
             | identifier
```

