import 'dart:ui' show Color;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:uuid/uuid.dart';

@immutable
class NoteModel {
  final String id;
  final String? userId;
  final String title;
  final String content;
  final Color color;
  final DateTime lastEdit;

  final DocumentReference? reference;

  NoteModel({
    String? id,
    this.userId,
    this.title = '',
    this.content = '',
    this.color = const Color(0xFFFFFF8D),
    DateTime? lastEdit,
    this.reference,
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, Object?>> snapshot) {
    return NoteModel(
      id: snapshot.id,
      userId: snapshot['userId'],
      title: snapshot['title'],
      content: snapshot['content'],
      color: Color(snapshot['color'] as int),
      lastEdit: (snapshot['lastEdit'] as Timestamp).toDate(),
      reference: snapshot.reference,
    );
  }

  Map<String, Object?> toMap() {
    return {
      // 'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'color': color.value,
      'lastEdit': Timestamp.fromDate(lastEdit),
    };
  }

  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    Color? color,
    DateTime? lastEdit,
    DocumentReference? reference,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      lastEdit: lastEdit ?? this.lastEdit,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NoteModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.content == content &&
        other.color == color &&
        other.lastEdit == lastEdit;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        title,
        content,
        color,
        lastEdit,
      );

  @override
  String toString() {
    return 'NoteModel('
        'id: $id, '
        'userId: $userId, '
        'title: $title, '
        'content: $content, '
        'color: $color, '
        'lastEdit: $lastEdit, '
        'reference: $reference)';
  }
}
