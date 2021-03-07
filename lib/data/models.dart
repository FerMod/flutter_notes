import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'models/note_model.dart';
import 'models/user_model.dart';

class UserDataModel with ChangeNotifier, DiagnosticableTreeMixin {
  final UserData<UserModel> userData = UserData<UserModel>(collection: 'users');

  //TODO: Fill body
}

class NotesListModel with ChangeNotifier, DiagnosticableTreeMixin {
  final Collection<NoteModel> collection = Collection<NoteModel>(path: 'notes');
  final UserData<UserModel> userData = UserData<UserModel>(collection: 'users');

  StreamController<List<NoteModel>>? _controller; // = StreamController<List<NoteModel>>.broadcast();

  NotesListModel({List<NoteModel>? notes}) : _notes = notes ?? [] {
    //_controller.stream.pipe(streamConsumer)
  }

  List<NoteModel> _notes = [];
  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);
  set notes(List<NoteModel> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @deprecated
  Future loadDelayed({bool notifyIsLoading = true}) async {
    final user = userData.currentUser;
    if (user == null) {
      return Future<List<NoteModel>>.value(null);
    }

    return load(
      () => Future.delayed(Duration(seconds: 2), () async {
        return load(
          () => collection.data(
            (snapshot) => NoteModel.fromSnapshot(snapshot),
            (query) => query!.where('userId', isEqualTo: user.uid),
          ),
          notifyIsLoading: notifyIsLoading,
        ) as FutureOr<List<NoteModel>>;
      }),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future loadData({bool notifyIsLoading = true}) {
    final user = userData.currentUser;
    if (user == null) {
      return Future<List<NoteModel>>.value(null);
    }

    return load(
      () => collection.data(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query!.where('userId', isEqualTo: user.uid),
      ),
      notifyIsLoading: notifyIsLoading,
    );
  }

  Future refresh() => loadData(notifyIsLoading: false);

  Future load(Future<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) async {
    _isLoading = true;
    if (notifyIsLoading) notifyListeners();

    try {
      final loadedNotes = await operation();
      _notes = loadedNotes;
    } finally {
      // Whetever if it does complete with an error or not
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<NoteModel>> streamData({bool notifyIsLoading = false}) {
    // final userStream = userData.authStateChange;
    // final dataStream = userStream.switchMap((user) {
    //   if (user == null) {
    //     return Stream<List<NoteModel>>.value([]); // TODO: What if user is null?
    //   }
    //   return collection.stream(
    //     (snapshot) => NoteModel.fromSnapshot(snapshot),
    //     (query) => query.where('userId', isEqualTo: user.uid),
    //   );
    // });
    final user = userData.currentUser;
    if (user == null) {
      return Stream<List<NoteModel>>.value([]); // TODO: what if user is null?
    }
    return stream(
      () => collection.stream(
        (snapshot) => NoteModel.fromSnapshot(snapshot),
        (query) => query!.where('userId', isEqualTo: user.uid).orderBy('lastEdit', descending: true),
      ),
      notifyIsLoading: notifyIsLoading,
    ) as Stream<List<NoteModel>>;
  }

  Stream stream(Stream<List<NoteModel>> Function() operation, {bool notifyIsLoading = false}) {
    // final dataStream = operation();
    // dataStream.listen(_controller.add);

    _controller ??= StreamController<List<NoteModel>>.broadcast(onListen: () {
        // Listen for events of this stream and update the list content
        _controller!.stream.listen((notes) => _notes = notes);
        // Pipe events of the data stream into this stream
        operation().pipe(_controller!);
      });

    // _controller.addStream(dataStream);
    // final streamController = StreamController<List<NoteModel>>.broadcast()
    //   ..addStream(dataStream)
    //   ..stream.listen((event) {
    //     _notes = event;
    //     _isLoading = false;
    //     print('listen');
    //     // notifyListeners();
    //   });

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
