
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String image;

  DocumentReference reference;

  UserModel({
    String id,
    this.name = '',
    this.image = '',
    this.reference,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    return UserModel(
      id: snapshot.id,
      name: data['name'],
      image: data['image'],
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
    };
  }

  @override
  String toString() => 'UserModel(id: "$id", name: "$name", image: "$image", reference: $reference)';
}
