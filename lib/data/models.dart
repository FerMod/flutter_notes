import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;

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
  NotesListModel({List<Note> notes}) : _notes = notes ?? [];

  List<Note> _notes;

  UnmodifiableListView<Note> get notes => UnmodifiableListView(_notes);

  set notes(List<Note> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedNotes = await Future.delayed(Duration(seconds: 0), () async => notesList);
      _notes.addAll(loadedNotes);
      // final loadedNotes = await repository.loadNotes();
      // _notes.addAll(loadedNotes.map(Note.fromEntity));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  /*  Future load() {
    _isLoading = true;
    notifyListeners();

    return repository.loadNotes().then((loadedNotes) {
      _notes.addAll(loadedNotes.map(Note.fromEntity));
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  } */

  void add(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void remove(Note note) {
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

  Note noteById(String id) {
    return _notes.firstWhere((element) => element.id == id, orElse: () => null);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('notes', notes));
  }
}

@deprecated
final List<Note> notesList = [
  Note(
      title: "Note title",
      content:
          'The note content, this should be extense text.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc dignissim pretium felis, aliquet ultrices risus dapibus quis. Integer non egestas dui, eu volutpat risus. Phasellus congue erat enim, quis iaculis nibh faucibus non. Phasellus commodo elementum porta. Morbi volutpat pulvinar vestibulum. In hac habitasse platea dictumst. Maecenas eget bibendum sapien. Fusce congue mauris a nisl faucibus malesuada. In imperdiet facilisis sem aliquet posuere. Etiam ornare lobortis auctor. Donec sollicitudin, dui id cursus fermentum, leo est ultrices orci, in commodo erat eros ut dolor. Donec felis justo, faucibus et varius a, lacinia eu leo. Donec dolor elit, suscipit eget molestie fringilla, feugiat a nisl. Interdum et malesuada fames ac ante ipsum primis in faucibus.\nDonec venenatis blandit eros iaculis viverra. Proin quis velit augue. Phasellus sit amet nunc augue. Proin eget neque et ex malesuada faucibus. Fusce dictum nunc ut molestie interdum. Suspendisse potenti. Donec ut elementum urna, tempor lobortis lectus. Phasellus eget neque risus. Nulla pretium eget quam eget eleifend. Donec pretium sapien at lectus lobortis tincidunt. Praesent imperdiet neque vitae dapibus scelerisque. Quisque vel turpis justo.'),
  Note(title: "Another note", content: "The content should be here."),
  // Note(id: 2, title: "Note title", content: "The note content, this should be extense text."),
  // Note(id: 3, title: "Note 3", content: "The note 3 content, this should be extense text."),
  // Note(id: 4, title: "Note 4", content: "The note 4 content, this should be extense text."),
  // Note(id: 5, title: "Note 5", content: "The note 5 content, this should be extense text."),
  // Note(id: 6, title: "Note 6", content: "The note 6 content, this should be extense text."),
  // Note(id: 7, title: "Note 7", content: "The note 7 content, this should be extense text."),
  // Note(id: 8, title: "Note 8", content: "The note 8 content, this should be extense text."),
  // Note(id: 9, title: "Note 9", content: "The note 9 content, this should be extense text."),
  // Note(id: 10, title: "Note 10", content: "The note10 content, this should be extense text."),
  // Note(id: 11, title: "Note 11", content: "The note11 content, this should be extense text."),
  // Note(id: 12, title: "Note 12", content: "The note12 content, this should be extense text."),
  // Note(id: 13, title: "Note 13", content: "The note13 content, this should be extense text."),
  // Note(id: 14, title: "Note 14", content: "The note14 content, this should be extense text."),
];
