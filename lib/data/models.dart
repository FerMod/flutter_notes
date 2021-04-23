import 'dart:async';
import 'dart:collection';
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'firebase_service.dart';
import 'models/note_model.dart';
import 'models/user_model.dart';

class UserDataModel with ChangeNotifier, DiagnosticableTreeMixin {
  final UserData<UserModel> userData = UserData<UserModel>(collection: 'users');

  //TODO: Fill body
}

class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  final Collection<NoteModel> collection = Collection<NoteModel>.path('notes');
  final UserData<UserModel> userData = UserData<UserModel>(collection: 'users');

  StreamController<List<NoteModel>>? _controller;

  NotesListModel({List<NoteModel>? notes}) : _notes = notes ?? const [];

  List<NoteModel> _notes = const [];
  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);
  set notes(List<NoteModel> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @Deprecated('It\'s only used for debugging')
  Future<List<NoteModel>> loadDelayed({
    Duration duration = const Duration(seconds: 2),
    bool notifyIsLoading = true,
  }) async {
    developer.log('loadDelayed(duration: $duration, notifyIsLoading: $notifyIsLoading)');

    return Future.delayed(
      duration,
      () => loadData(notifyIsLoading: notifyIsLoading),
    );
  }

  Future<List<NoteModel>> loadData({bool notifyIsLoading = true}) {
    final user = userData.currentUser;
    if (user == null) {
      return Future.value([]);
    }

    return load(
      () => collection.data(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query.where('userId', isEqualTo: user.uid),
      ),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future<List<NoteModel>> refresh() => loadData(notifyIsLoading: false);

  Future<List<NoteModel>> load(Future<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) async {
    _isLoading = true;
    if (notifyIsLoading) notifyListeners();

    try {
      return operation().then((value) => _notes = value);
    } finally {
      // Whetever if it does complete with an error or not
      _isLoading = false;
      notifyListeners();
    }
  }

  @Deprecated('It\'s only used for debugging')
  Stream<List<NoteModel>> streamDelayed({Duration duration = const Duration(seconds: 2)}) {
    developer.log('loadDelayed(duration: $duration)');
    return streamData().delay(duration);
  }

  Stream<List<NoteModel>> streamData() {
    final user = userData.currentUser;
    if (user == null) {
      return Stream.value([]); // TODO: what if user is null?
    }

    return stream(
      () => collection.stream(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query.where('userId', isEqualTo: user.uid).orderBy('lastEdit', descending: true),
      ),
    );
  }

  Stream<List<NoteModel>> stream(Stream<List<NoteModel>> Function() operation) {
    _controller ??= StreamController<List<NoteModel>>.broadcast(onListen: () {
      // Listen for events of this stream and update the list content
      _controller!.stream.listen((notes) => _notes = notes);
      // Pipe events of the data stream into this stream
      operation().pipe(_controller!);
    });
    return _controller!.stream;
  }

  void addNote(NoteModel note) {
    _notes.add(note);
    collection.insert(note.toMap());
    notifyListeners();
  }

  void updateNote(NoteModel note) {
    assert(note.id != null);
    final replaceIndex = _notes.indexWhere((element) => element.id == note.id);
    _notes.replaceRange(replaceIndex, replaceIndex + 1, [note]);
    collection.update(note.id!, note.toMap());
    notifyListeners();
  }

  @deprecated
  void upsertNote(NoteModel note) {
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
    collection.delete(note.id!);
    notifyListeners();
  }

  NoteModel? noteById(String id) {
    return _notes.firstWhereOrNull(
      (element) => element.id == id,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('notes', notes));
    properties.add(FlagProperty('isLoading', value: isLoading));
  }
}
