import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  String id;
  String? email;
  String? displayName;
  String? imageUrl;

  UserModel({
    String? id,
    this.email,
    this.displayName,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  factory UserModel.fromAuthUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      imageUrl: user.photoURL,
    );
  }

  bool get isAnonymous => email == null;

  Map<String, Object?> toMap() {
    return {
      // 'id': id,
      'email': email,
      'displayName': displayName,
      'imageUrl': imageUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, imageUrl: $imageUrl)';
  }
}
