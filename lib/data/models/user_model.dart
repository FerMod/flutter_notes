import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../../extensions/theme_mode_extension.dart';

class UserModel {
  String? id;
  String? name;
  String? image;
  Locale locale;
  ThemeMode? themeMode;

  DocumentReference? reference;

  UserModel({
    this.id,
    this.name = '',
    this.image = '',
    this.locale = const Locale('und'),
    this.themeMode = ThemeMode.system,
    this.reference,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      id: snapshot.id,
      name: data['name'],
      image: data['image'],
      locale: Locale(data['locale']),
      themeMode: ThemeMode.values.firstWhereOrNull(
        (e) => e.name == data['themeMode'],
      ),
      reference: snapshot.reference,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'image': image,
      'locale': locale.languageCode,
      'themeMode': themeMode!.name,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? image,
    Locale? locale,
    ThemeMode? themeMode,
    DocumentReference? reference,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      reference: reference ?? this.reference,
    );
  }

  @override
  String toString() => 'UserModel(id: "$id", name: "$name", image: "$image", locale: ${locale.toLanguageTag()}, themeMode: $themeMode, reference: $reference)';
}
