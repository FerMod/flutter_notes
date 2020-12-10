import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_service.dart';

// ignore: prefer_mixin
class UserDataModel with ChangeNotifier, DiagnosticableTreeMixin {
  final UserData<UserModel> userData = UserData<UserModel>(collection: 'users');

  //TODO: Fill body
}

// ignore: prefer_mixin
class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  final Collection<NoteModel> collection = Collection<NoteModel>(path: 'notes');

  NotesListModel({List<NoteModel> notes}) : _notes = notes ?? [];

  List<NoteModel> _notes;

  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);

  set notes(List<NoteModel> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @deprecated
  Future loadDelayed({bool notifyIsLoading = true}) {
    return load(
      () => Future.delayed(Duration(seconds: 2), () async {
        return collection.data((snapshot) => NoteModel.fromSnapshot(snapshot), (query) {
          return query.where('userId', isEqualTo: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY');
        });
      }),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future loadData({bool notifyIsLoading = true}) {
    return load(
      () => collection.data((snapshot) => NoteModel.fromSnapshot(snapshot), (query) {
        return query.where('userId', isEqualTo: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY');
      }),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future refresh() => loadData(notifyIsLoading: false);

  /*{
    _isLoading = true;
    notifyListeners();
   
    return collection.data((snapshot) => NoteModel.fromSnapshot(snapshot)).then((notesList) {
      _notes = notesList;
    }).whenComplete(() {
      // Whetever if it does complete with an error or not
      _isLoading = false;
      notifyListeners();
    });
  
    
    // return collection.reference.get().then((querySnapshot) {
    //   _notes = querySnapshot.docs.map((doc) => Note.fromSnapshot(doc)).toList();
    // }).whenComplete(() {
    //   // Whetever if it does complete with an error or not
    //   _isLoading = false;
    //   notifyListeners();
    // });
  }
  */

  Future load(Future<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) {
    _isLoading = true;
    if (notifyIsLoading) notifyListeners();

    return operation().then((loadedNotes) {
      _notes = loadedNotes;
    }).whenComplete(() {
      // Whetever if it does complete with an error or not
      _isLoading = false;
      notifyListeners();
    });
  }

  void addNote(NoteModel note) {
    _notes.add(note);
    collection.insert(note.toMap());
    notifyListeners();
  }

  void updateNote(NoteModel note) {
    assert(note != null);
    assert(note.id != null);
    final replaceIndex = _notes.indexWhere((element) => element.id == note.id);
    _notes.replaceRange(replaceIndex, replaceIndex + 1, [note]);
    collection.update(note.id, note.toMap());
    notifyListeners();
  }

  @deprecated
  void upsertNote(NoteModel note) {
    assert(note != null);
    assert(note.id != null);
    final replaceIndex = _notes.indexWhere((element) => element.id == note.id);
    if (replaceIndex != -1) {
      _notes.replaceRange(replaceIndex, replaceIndex + 1, [note]);
    } else {
      _notes.add(note);
    }
    collection.insert(note.toMap(), id: note.id, merge: true);
    notifyListeners();
  }

  void removeNote(NoteModel note) {
    _notes.removeWhere((element) => element.id == note.id);
    collection.delete(note.id);
    notifyListeners();
  }

  NoteModel noteById(String id) {
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
List<NoteModel> _notesList = [
  NoteModel(
      userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY',
      title: "Note title",
      content:
          'The note content, this should be extense text.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc dignissim pretium felis, aliquet ultrices risus dapibus quis. Integer non egestas dui, eu volutpat risus. Phasellus congue erat enim, quis iaculis nibh faucibus non. Phasellus commodo elementum porta. Morbi volutpat pulvinar vestibulum. In hac habitasse platea dictumst. Maecenas eget bibendum sapien. Fusce congue mauris a nisl faucibus malesuada. In imperdiet facilisis sem aliquet posuere. Etiam ornare lobortis auctor. Donec sollicitudin, dui id cursus fermentum, leo est ultrices orci, in commodo erat eros ut dolor. Donec felis justo, faucibus et varius a, lacinia eu leo. Donec dolor elit, suscipit eget molestie fringilla, feugiat a nisl. Interdum et malesuada fames ac ante ipsum primis in faucibus.\nDonec venenatis blandit eros iaculis viverra. Proin quis velit augue. Phasellus sit amet nunc augue. Proin eget neque et ex malesuada faucibus. Fusce dictum nunc ut molestie interdum. Suspendisse potenti. Donec ut elementum urna, tempor lobortis lectus. Phasellus eget neque risus. Nulla pretium eget quam eget eleifend. Donec pretium sapien at lectus lobortis tincidunt. Praesent imperdiet neque vitae dapibus scelerisque. Quisque vel turpis justo.'),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 1", content: "The note 1 content, this should be extense text.", color: Color(0xFFE6B904)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 2", content: "The note 2 content, this should be extense text.", color: Color(0xFF65BA5A)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 3", content: "The note 3 content, this should be extense text.", color: Color(0xFFEA86C2)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 4", content: "The note 4 content, this should be extense text.", color: Color(0xFFC78EFF)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 5", content: "The note 5 content, this should be extense text.", color: Color(0xFF5AC0E7)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 6", content: "The note 6 content, this should be extense text.", color: Color(0xFFAAAAAA)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 7", content: "The note 7 content, this should be extense text.", color: Color(0xFF454545)),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 8", content: "The note 8 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 9", content: "The note 9 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 10", content: "The note 10 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 11", content: "The note 11 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 12", content: "The note 12 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 13", content: "The note 13 content, this should be extense text."),
  NoteModel(userId: 'ZqnPFrvhwEb2x4BgsCtrbADSbSSY', title: "Note 14", content: "The note 14 content, this should be extense text."),
];
