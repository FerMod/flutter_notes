import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:uuid/uuid.dart';

@immutable
class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? imageUrl;

  UserModel({
    String? id,
    required this.email,
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
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is UserModel && other.id == id && other.email == email && other.displayName == displayName && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        displayName,
        imageUrl,
      );

  @override
  String toString() {
    return '$UserModel(id: $id, email: $email, displayName: $displayName, imageUrl: $imageUrl)';
  }
}
