import 'dart:ui';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String? userId;
  String title;
  String content;
  Color color;
  DateTime lastEdit;

  DocumentReference? reference;

  NoteModel({
    String? id,
    this.userId,
    this.title = '',
    this.content = '',
    this.color = const Color(0xFFFFFF8D),
    DateTime? lastEdit,
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  factory NoteModel.fromSnapshot(DocumentSnapshot snapshot) {
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

  Map<String, dynamic> toMap() {
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
  String toString() {
    return 'NoteModel(id: $id, userId: $userId, title: $title, content: $content, color: $color, lastEdit: $lastEdit, reference: $reference)';
  }
}
