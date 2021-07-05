import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  String id;
  String? name;
  String? image;

  DocumentReference? reference;

  UserModel({
    String? id,
    this.name,
    this.image,
    this.reference,
  }) : id = id ?? const Uuid().v4();

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
      id: snapshot.id,
      name: snapshot['name'],
      image: snapshot['image'],
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'image': image,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? image,
    DocumentReference? reference,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      reference: reference ?? this.reference,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, image: $image, reference: $reference)';
  }
}
