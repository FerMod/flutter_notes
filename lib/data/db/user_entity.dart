import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'database_service.dart';

class UserEntity extends DatabaseEntity {
  String id;
  String name;
  String image;

  UserEntity({String id, this.name = '', this.image = ''}) : id = id ?? Uuid().v4();

  factory UserEntity.fromJson(String str) => UserEntity.fromMap(json.decode(str));

  factory UserEntity.fromMap(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'] ?? '',
      name: data['displayName'] ?? '',
      image: data['image'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  @override
  String toString() => 'UserEntity(id: "$id", name: "$name", image: "$image")';
}
