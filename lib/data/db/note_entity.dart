import 'dart:convert';
import 'dart:ui';

import 'package:uuid/uuid.dart';

import 'database_service.dart';

class NoteEntity extends DatabaseEntity {
  String id;
  String userId;
  String title;
  String content;
  Color color;
  DateTime lastEdit;

  NoteEntity({
    String id,
    this.title = '',
    this.content = '',
    this.color = const Color(0xFFFFFF8D),
    DateTime lastEdit,
  })  : id = id ?? Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  factory NoteEntity.fromJson(String str) => NoteEntity.fromMap(json.decode(str));

  factory NoteEntity.fromMap(Map<String, dynamic> data) {
    return NoteEntity(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      color: Color(data['color']),
      lastEdit: data['lastEdit'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'lastEdit': lastEdit,
    };
  }

  @override
  String toString() => 'NoteEntity(id: "$id", title: "$title", content: "$content", color: "$color", lastEdit: "$lastEdit")';
}
