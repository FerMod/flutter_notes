import 'dart:convert';

typedef Condition<T> = bool Function(T entity);
typedef FromMap<T> = T Function(Map<String, dynamic> map);
typedef ToMap<T> = Map<String, dynamic> Function(T data);

abstract class LocalDatabaseService<T> {
  Future<T> load();
  Future save(T entity);
}

abstract class ReactiveDatabaseService<T extends DatabaseEntity> {
  Future<List<T>> data({Condition<T> test});

  Stream<List<T>> stream({Condition<T> test});

  Future<void> insert(T entity);

  Future<void> update(T entity);

  //Future<void> upsert(T entity, Condition<T> test);

  Future<void> delete(T entity);
}

abstract class DatabaseEntity {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const DatabaseEntity();

  // factory DatabaseEntity.fromMap(Map<String, dynamic> data);
  // factory DatabaseEntity.fromJson(String str) => DatabaseEntity.fromMap(JsonDecoder().convert(str));

  Map<String, dynamic> toMap();
  String toJson() => JsonEncoder().convert(toMap());
}

// abstract class EntityMapper<T extends DatabaseEntity> {
//   Map<String, dynamic> toMap(T entity);
//   T fromMap(Map<String, dynamic> map);
// }

// class _DefaultEntityMapper extends EntityMapper {
//   @override
//   DatabaseEntity fromMap(Map<String, dynamic> map) {
//     throw UnimplementedError();
//   }

//   @override
//   Map<String, dynamic> toMap(DatabaseEntity entity) {
//     throw UnimplementedError();
//   }
// }

// class MyThing extends DatabaseEntity {
//   String id;
//   MyThing({String id})
//       : id = '',
//         super(null);
// }

// class MyThingMapper extends EntityMapper<MyThing> {
//   @override
//   MyThing fromMap(Map<String, dynamic> map) {
//     return MyThing(
//       id: map['id'] ?? '',
//     );
//   }

//   @override
//   Map<String, dynamic> toMap(MyThing entity) {
//     return {
//       'id': entity.id,
//     };
//   }
// }

// class EntityParser<T extends DatabaseEntity> {

//   T Function(Map<String, dynamic> data) fromMap;
//   Map<String, dynamic> Function() toMap;

//   // static fromMap(Map<String, dynamic> data) => fromMap;
//   T fromJson(String str) => fromMap(JsonDecoder().convert(str));

//   // Map<String, dynamic> toMap() = toMap;
//   String toJson() => JsonEncoder().convert(toMap());
// }

// class MyThing extends EntityParser {
//   String id;
//   MyThing({String id}) : id = '';

//   @override
//   DatabaseEntity Function(Map<String, dynamic> data) get fromMap => super.fromMap;

// }

// class MyThing extends DatabaseEntity {
//   String id;
//   MyThing({String id}) : id = '';

//   @override
//   Map<String, dynamic> toMap() {
//     // TODO: implement toMap
//     throw UnimplementedError();
//   }
// }

// void main() {
//   var test = MyThing.fromMap({'id': 'test id'});
//   print(test);
// }
