import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Note {
  String id;
  String title;
  String content;

  Note({String id, this.title = '', this.content = ''}) : id = id ?? Uuid().v4();

  factory Note.fromMap(Map<String, dynamic> data) {
    return Note(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  factory Note.fromJson(String str) => Note.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  @override
  String toString() => '${objectRuntimeType(this, 'Note')}("$id", "$title", "$content")';
}

class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  final List<Note> _notes;
  List<Note> get notes => _notes;

  NotesListModel({List<Note> notes}) : _notes = notes ?? [];

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void removeNote(Note note) {
    _notes.removeWhere((element) => element.id == note.id);
    notifyListeners();
  }

  void updateNote(Note note) {
    assert(note != null);
    assert(note.id != null);
    var oldNote = _notes.firstWhere((element) => element.id == note.id);
    var replaceIndex = _notes.indexOf(oldNote);
    _notes.replaceRange(replaceIndex, replaceIndex + 1, [note]);
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('notes', notes));
  }
}
