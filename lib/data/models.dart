import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime lastEdit;
  Color color;

  Note({
    String id,
    this.title = '',
    this.content = '',
    DateTime lastEdit,
    Color color = const Color(0xFFFFFF8D),
  })  : id = id ?? Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  factory Note.fromMap(Map<String, dynamic> data) {
    return Note(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      lastEdit: data['lastEdit'] ?? DateTime.now(),
      color: data['color'] ?? const Color(0xFFFFFF8D),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lastEdit': lastEdit,
      'color': color,
    };
  }

  factory Note.fromJson(String str) => Note.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Note("$id", "$title", "$content", "$lastEdit", ${color.toString()})';
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

  @deprecated
  Future loadDelayed() {
    return load(() => Future.delayed(Duration(seconds: 2), () async => _notesList));
  }

  @deprecated
  Future refreshDelayed() {
    return refresh(() => Future.delayed(Duration(seconds: 2), () async => _notesList));
  }

  Future load(Future<List<Note>> operation(), {bool notifyLoading = false}) {
    _isLoading = true;
    notifyListeners();

    return operation().then((loadedNotes) {
      _notes = loadedNotes;
    }).whenComplete(() {
      // Whetever if it does complete with an error or not
      _isLoading = false;
      notifyListeners();
    });
  }

  Future refresh(Future<List<Note>> operation()) {
    return operation().then((loadedNotes) {
      _notes = loadedNotes;
    }).whenComplete(notifyListeners);
  }

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
    var replaceIndex = _notes.indexWhere((element) => element.id == note.id);
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
    properties.add(FlagProperty('isLoading', value: isLoading));
  }
}

@deprecated
final List<Note> _notesList = [
  Note(
      title: "Note title",
      content:
          'The note content, this should be extense text.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc dignissim pretium felis, aliquet ultrices risus dapibus quis. Integer non egestas dui, eu volutpat risus. Phasellus congue erat enim, quis iaculis nibh faucibus non. Phasellus commodo elementum porta. Morbi volutpat pulvinar vestibulum. In hac habitasse platea dictumst. Maecenas eget bibendum sapien. Fusce congue mauris a nisl faucibus malesuada. In imperdiet facilisis sem aliquet posuere. Etiam ornare lobortis auctor. Donec sollicitudin, dui id cursus fermentum, leo est ultrices orci, in commodo erat eros ut dolor. Donec felis justo, faucibus et varius a, lacinia eu leo. Donec dolor elit, suscipit eget molestie fringilla, feugiat a nisl. Interdum et malesuada fames ac ante ipsum primis in faucibus.\nDonec venenatis blandit eros iaculis viverra. Proin quis velit augue. Phasellus sit amet nunc augue. Proin eget neque et ex malesuada faucibus. Fusce dictum nunc ut molestie interdum. Suspendisse potenti. Donec ut elementum urna, tempor lobortis lectus. Phasellus eget neque risus. Nulla pretium eget quam eget eleifend. Donec pretium sapien at lectus lobortis tincidunt. Praesent imperdiet neque vitae dapibus scelerisque. Quisque vel turpis justo.'),
  Note(title: "Another note", content: "The content should be here."),
  Note(title: "Note title", content: "The note content, this should be extense text.", color: Colors.yellowAccent),
  Note(title: "Note 1", content: "The note 1 content, this should be extense text."),
  Note(title: "Note 2", content: "The note 2 content, this should be extense text."),
  Note(title: "Note 3", content: "The note 3 content, this should be extense text."),
  Note(title: "Note 4", content: "The note 4 content, this should be extense text."),
  Note(title: "Note 5", content: "The note 5 content, this should be extense text."),
  Note(title: "Note 6", content: "The note 6 content, this should be extense text."),
  Note(title: "Note 7", content: "The note 7 content, this should be extense text."),
  Note(title: "Note 8", content: "The note 8 content, this should be extense text."),
  Note(title: "Note 9", content: "The note 9 content, this should be extense text."),
  Note(title: "Note 10", content: "The note 10 content, this should be extense text."),
  Note(title: "Note 11", content: "The note 11 content, this should be extense text."),
  Note(title: "Note 12", content: "The note 12 content, this should be extense text."),
  Note(title: "Note 13", content: "The note 13 content, this should be extense text."),
  Note(title: "Note 14", content: "The note 14 content, this should be extense text."),
];
