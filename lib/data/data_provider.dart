import 'package:flutter/foundation.dart' show immutable;

import 'firebase/firebase_service.dart';
import 'models/note_model.dart';
import 'models/user_model.dart';

@immutable
class DataProvider {
  DataProvider._internal();
  static final DataProvider _instance = DataProvider._internal();
  factory DataProvider() = DataProvider._internal;

  static UserData<UserModel> get userData => _instance._userData;
  late final UserData<UserModel> _userData = UserData(
    converter: (user) => UserModel.fromAuthUser(user),
  );

  static Collection<NoteModel> get notes => _instance._notes;
  late final Collection<NoteModel> _notes = Collection<NoteModel>.path(
    'notes',
    converter: FirestoreConverter(
      fromFirestore: (snapshot, options) => NoteModel.fromSnapshot(snapshot),
      toFirestore: (value, options) => value.toMap(),
    ),
  );
}
