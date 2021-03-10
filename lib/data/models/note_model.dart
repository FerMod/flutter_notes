import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String? id;
  String? userId;
  String? title;
  String? content;
  Color? color;
  DateTime? lastEdit;

  DocumentReference? reference;

  NoteModel({
    this.id,
    this.userId,
    String? title,
    String? content,
    Color? color,
    DateTime? lastEdit,
    this.reference,
  })  : title = title ?? '',
        content = content ?? '',
        color = color ?? const Color(0xFFFFFF8D),
        lastEdit = lastEdit ?? DateTime.now();

  factory NoteModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()!;
    return NoteModel(
      id: snapshot.id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      color: Color(data['color'] as int),
      lastEdit: (data['lastEdit'] as Timestamp).toDate(),
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'color': color!.value,
      'lastEdit': Timestamp.fromDate(lastEdit!),
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
  String toString() => 'NoteModel(id: "$id", userId: "$userId", title: "$title", content: "$content", color: $color, lastEdit: "$lastEdit",  reference: $reference)';
}
