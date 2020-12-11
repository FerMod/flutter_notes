import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String userId;
  String title;
  String content;
  Color color;
  DateTime lastEdit;

  DocumentReference reference;

  NoteModel({
    this.id,
    this.userId,
    this.title = '',
    this.content = '',
    this.color = const Color(0xFFFFFF8D),
    DateTime lastEdit,
    this.reference,
  }) : lastEdit = lastEdit ?? DateTime.now();

  factory NoteModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    return NoteModel(
      id: snapshot.id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      color: Color(data['color']),
      lastEdit: (data['lastEdit'] as Timestamp).toDate(),
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'color': color.value,
      'lastEdit': Timestamp.fromDate(lastEdit),
    };
  }

  @override
  String toString() => 'NoteModel(id: "$id", userId: "$userId", title: "$title", content: "$content", color: $color, lastEdit: "$lastEdit",  reference: $reference)';
}
