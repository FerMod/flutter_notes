import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../src/utils/locale_utils.dart';

class UserModel {
  String? id;
  String? name;
  String? image;
  Locale locale;
  ThemeMode? themeMode;

  DocumentReference? reference;

  UserModel({
    this.id,
    String? name,
    String? image,
    Locale? locale,
    ThemeMode? themeMode,
    this.reference,
  })  : name = name ?? '',
        image = image ?? '',
        locale = locale ?? const Locale('und'),
        themeMode = themeMode ?? ThemeMode.system;

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data == null) return UserModel();
    return UserModel(
      id: snapshot.id,
      name: snapshot.get('name'),
      image: data['image'],
      locale: LocaleUtils.localeFromLanguageTag(data['locale']),
      themeMode: ThemeMode.values.firstWhereOrNull(
        (e) => describeEnum(e) == data['themeMode'],
      ),
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'image': image,
      'locale': locale.languageCode,
      'themeMode': describeEnum(themeMode!),
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
