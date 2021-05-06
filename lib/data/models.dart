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

@immutable
class DataProvider {
  DataProvider._internal();
  static final DataProvider _instance = DataProvider._internal();

  late final UserData<UserModel> _userData = UserData<UserModel>.path('users');
  static UserData<UserModel> get userData => _instance._userData;

  late final Collection<NoteModel> _notes = Collection<NoteModel>.path('notes');
  static Collection<NoteModel> get notes => _instance._notes;
}

class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  late final Collection<NoteModel> notesCollection = DataProvider.notes;
  late final UserData<UserModel> userData = DataProvider.userData;

  /// Controller used to notify of the new data entries that are added.
  StreamController<List<NoteModel>>? _controller;

  NotesListModel({List<NoteModel>? notes}) : _notes = notes ?? const [];

  List<NoteModel> _notes = const [];
  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);
  set notes(List<NoteModel> notes) {
    _notes = notes;
    notifyListeners();
  }

  /// The data is currently loading.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  /// Returns the value as a future that runs its computation after a delay.
  ///
  /// The loading of the data will be executed after the given [duration] has
  /// passed, and the future is completed with the result. If [notifyIsLoading]
  /// is set to true, it notifies that the data is loading and notifies again when
  /// is finished loading.
  ///
  /// See:
  /// * [isLoading], to obtain if is currently loading.
  ///
  /// *It should be only used for debugging*
  @visibleForTesting
  Future<List<NoteModel>> loadDelayed({
    Duration duration = const Duration(seconds: 2),
    bool notifyIsLoading = false,
  }) {
    developer.log('loadDelayed(duration: $duration, notifyIsLoading: $notifyIsLoading)');

    return Future.delayed(
      duration,
      () => loadData(notifyIsLoading: notifyIsLoading),
    );
  }

  /// Returns a future completed with the list of notes.
  /// If the parameter [notifyIsLoading] is set to true, it notifies when the
  /// future data is requested, and notifies again when the data is resolved and
  /// completed.
  Future<List<NoteModel>> loadData({bool notifyIsLoading = true}) {
    final user = userData.currentUser;
    if (user == null) {
      return Future.value([]);
    }

    return load(
      () => notesCollection.data(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query.where('userId', isEqualTo: user.uid),
      ),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future<List<NoteModel>> refresh() => loadData(notifyIsLoading: false);

  /// Returns a future completed with the result of the [operation] execution.
  /// If the parameter [notifyIsLoading] is set to true, it notifies when the
  /// future data is requested, and notifies again when the data is resolved and
  /// completed.
  ///
  /// See:
  /// * [isLoading], to obtain if is currently loading.
  Future<List<NoteModel>> load(Future<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) {
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

  /// Returns the value stream that runs its computation after a delay.
  ///
  /// The data stream will be executed after the given [duration] has passed,
  /// and the future is completed with the result.
  ///
  /// *It should be only used for debugging*
  @visibleForTesting
  Stream<List<NoteModel>> streamDelayed({Duration duration = const Duration(seconds: 2)}) {
    developer.log('streamDelayed(duration: $duration)');
    return streamData().delay(duration);
  }

  /// Returns a stream completed with the list of notes.
  Stream<List<NoteModel>> streamData() {
    final user = userData.currentUser;
    if (user == null) {
      return Stream.value([]); // TODO: what if user is null?
    }

    return stream(
      () => notesCollection.stream(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query.where('userId', isEqualTo: user.uid).orderBy('lastEdit', descending: true),
      ),
    );
  }

  /// Returns a stream from the the result stream of the [operation] execution.
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
    notesCollection.insert(note.toMap());
    notifyListeners();
  }

  void updateNote(NoteModel note) {
    assert(note.id != null);
    final replaceIndex = _notes.indexWhere((element) => element.id == note.id);
    _notes.replaceRange(replaceIndex, replaceIndex + 1, [note]);
    notesCollection.update(note.id!, note.toMap());
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
    notesCollection.insert(note.toMap(), id: note.id, merge: true);
    notifyListeners();
  }

  void removeNote(NoteModel note) {
    _notes.removeWhere((element) => element.id == note.id);
    notesCollection.delete(note.id!);
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
