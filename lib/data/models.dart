import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'data_provider.dart';
import 'firebase/firebase_service.dart';
import 'models/note_model.dart';
import 'models/user_model.dart';

class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  NotesListModel({List<NoteModel>? notes}) : _notes = notes ?? [];

  late final Collection<NoteModel> notesCollection = DataProvider.notes;
  late final UserData<UserModel> userData = DataProvider.userData;

  /// Controller used to notify of the new data entries that are added.
  StreamController<List<NoteModel>>? _controller;

  List<NoteModel> _notes;
  List<NoteModel> get notes => _notes;
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
  /// See also:
  ///
  ///  * [isLoading], to obtain if is currently loading.
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
    late Future<List<NoteModel>> futureResult;
    if (userData.isSignedIn) {
      futureResult = notesCollection.data(
        (query) => query.where('userId', isEqualTo: user!.uid),
      );
    } else {
      futureResult = Future.value(_notes);
    }

    return _load(
      () => futureResult,
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future<List<NoteModel>> refresh() => loadData(notifyIsLoading: false);

  /// Returns a future completed with the result of the [operation] execution.
  /// If the parameter [notifyIsLoading] is set to true, it notifies when the
  /// future data is requested, and notifies again when the data is resolved and
  /// completed.
  ///
  /// See also:
  ///
  ///  * [isLoading], to obtain if is currently loading.
  Future<List<NoteModel>> _load(Future<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) {
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
    late Stream<List<NoteModel>> streamResult;
    if (userData.isSignedIn) {
      streamResult = notesCollection.stream(
        (query) => query.where('userId', isEqualTo: user!.uid).orderBy('lastEdit', descending: true),
      );
    } else {
      streamResult = Stream.value(_notes);
    }

    return _pipeStream(streamResult);
  }

  /// Returns a stream from the the result stream of the [operation] execution.
  Stream<List<NoteModel>> _pipeStream(Stream<List<NoteModel>> operation) {
    var isDone = false;
    late StreamSubscription<List<NoteModel>> subscription;
    void onListen() {
      developer.log('StreamController onListen');
      subscription = operation.listen(
        (value) {
          developer.log('StreamController operation.onData');
          _notes = [...value];
          _controller!.add(_notes);
        },
        onError: (error, stack) {
          developer.log('StreamController operation.onError');
          _controller!.addError(error, stack);
        },
        onDone: () {
          isDone = true;
          developer.log('StreamController operation.onDone');
          _controller!.close();
        },
      );
    }

    void onCancel() {
      developer.log('StreamController onCancel');
      if (isDone) subscription.cancel();
    }

    _controller ??= StreamController.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );

    return _controller!.stream;
  }

  /// Returns a stream from the the result stream of the [operation] execution.
  @Deprecated('')
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
    if (userData.isSignedIn) {
      notesCollection.insert(note);
    } else {
      _controller?.add(_notes);
    }
    notifyListeners();
  }

  void updateNote(NoteModel note) {
    assert(_notes.isNotEmpty);
    final replaceIndex = _notes.indexWhere((element) => element.id == note.id);
    _notes[replaceIndex] = note;
    if (userData.isSignedIn) {
      notesCollection.update(note.id, note.toMap());
    } else {
      _controller?.add(_notes);
    }
    notifyListeners();
  }

  void removeNote(NoteModel note) {
    _notes.removeWhere((element) => element.id == note.id);
    if (userData.isSignedIn) {
      notesCollection.delete(note.id);
    } else {
      _controller?.add(_notes);
    }
    notifyListeners();
  }

  NoteModel? noteById(String id) {
    return _notes.firstWhereOrNull(
      (element) => element.id == id,
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('notes', _notes));
    properties.add(FlagProperty('isLoading', value: isLoading));
  }
}
