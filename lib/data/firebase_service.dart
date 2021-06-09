import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

typedef QueryFunction<T> = T Function(T query);
typedef Converter<T, S> = T Function(S value);

// typedef FromMap<T> = T Function(Map<String, dynamic> data);
// typedef ToMap<T> = Map<String, dynamic> Function(T entity);

abstract class FirebaseDocument<T> {
  const FirebaseDocument();

  Future<T> data();
  Stream<T> stream();
  Future<void> update(Map<String, dynamic> data);
  Future<void> delete();
}

abstract class FirebaseCollection<T> {
  const FirebaseCollection();

  Future<List<T>> data();
  Stream<List<T>> stream();
  Future<FirebaseDocument<T>> insert(Map<String, dynamic> data, {String? id, bool merge = false});
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

abstract class FirebaseAuthentication {
  const FirebaseAuthentication();

  Future<UserCredential> signInAnonymously();
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> delete();
}

/// An object that represents a Firebase document.
///
/// See:
/// * <https://firebase.google.com/docs/firestore/data-model#documents>
class Document<T> extends FirebaseDocument<T> {
  /// An object that refers to a Firestore document path.
  final DocumentReference reference;
  final Converter<T, DocumentSnapshot> converter;

  /// Creates a document with the specified [reference].
  const Document({
    required this.reference,
    required this.converter,
  });

  /// Creates a document with a [reference] with the specified [path].
  factory Document.path(String path, Converter<T, DocumentSnapshot> converter) {
    return Document(
      reference: FirebaseFirestore.instance.doc(path),
      converter: converter,
    );
  }

  @override
  Future<T> data() {
    return reference.get().then(converter);
  }

  @override
  Stream<T> stream() {
    return reference.snapshots().map(converter);
  }

  /// Updates data on the document. The data will be merged with any existing
  /// document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(Map<String, dynamic> data) async {
    try {
      return reference.update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        developer.log('Error updating document: ${e.message}');
        rethrow;
      }
      developer.log('$e');
    }
  }

  @override
  Future<void> delete() async {
    return reference.delete();
  }
}

/// An object that represents a Firebase collection.
///
/// See:
/// * <https://firebase.google.com/docs/firestore/data-model#collections>
class Collection<T> extends FirebaseCollection<T> {
  /// An object that refers to a Firestore collection path.
  final CollectionReference reference;

  final Converter<T, DocumentSnapshot> converter;

  /// Creates a collection with the specified [reference].
  const Collection({
    required this.reference,
    required this.converter,
  });

  /// Creates a collection with a [reference] with the specified [path].
  factory Collection.path(String path, Converter<T, DocumentSnapshot> converter) {
    return Collection(
      reference: FirebaseFirestore.instance.collection(path),
      converter: converter,
    );
  }

  @override
  Future<List<T>> data([QueryFunction<Query>? query]) async {
    final queryFunction = query?.call(reference) ?? reference;
    final snapshots = await queryFunction.get();
    return snapshots.docs.map(converter).toList();
  }

  @override
  Stream<List<T>> stream([QueryFunction<Query>? query]) {
    final queryFunction = query?.call(reference) ?? reference;
    return queryFunction.snapshots().map((snapshot) => snapshot.docs.map(converter).toList());
  }

  /// Returns a `DocumentReference` after populating it with the provided [data].
  ///
  /// If no [id] is provided, an auto-generated ID is used.
  /// When populating the data on the document, it overwrites any existing data.
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is set to `true`, the data will be merged into an existing
  /// document instead of overwriting.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  @override
  Future<Document<T>> insert(Map<String, dynamic> data, {String? id, bool merge = false}) async {
    final newDocument = reference.doc(id);
    await newDocument.set(data, SetOptions(merge: merge));
    return Document(reference: newDocument, converter: converter);
  }

  /// Updates data on the document with provided [id]. Data will be merged with
  /// any existing document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      return reference.doc(id).update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        developer.log('Error updating document: ${e.message}');
        rethrow;
      }
      developer.log('$e');
    }
  }

  @override
  Future<void> delete(String id) async {
    return reference.doc(id).delete();
  }
}

/// An object that represents a Firebase document that is used to store user
/// data.
class UserData<T> extends FirebaseDocument<T?> implements FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Collection<T> collection;

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  ///
  /// The returned stream never provides two consecutive data events that are
  /// equal. Errors are passed through to the returned stream, and data events
  /// are passed through if they are distinct from the most recently emitted
  /// data event.
  Stream<User?> get authStateChanges => _auth.authStateChanges().distinct();

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  ///
  /// It notifies the same state changes as [authStateChanges] in addition to
  /// notifications about token refresh events.
  ///
  /// The returned stream never provides two consecutive data events that are
  /// equal. Errors are passed through to the returned stream, and data events
  /// are passed through if they are distinct from the most recently emitted
  /// data event.
  Stream<User?> get idTokenChanges => _auth.idTokenChanges().distinct();

  /// Notifies about changes to any user updates.
  ///
  /// This is a superset of both [authStateChanges] and [idTokenChanges].
  /// It provides events on all user changes, such as when credentials are
  /// linked, unlinked and when updates to the user profile are made.
  ///
  /// The purpose of this Stream is to for listening to realtime updates to the
  /// user.
  ///
  /// The returned stream never provides two consecutive data events that are
  /// equal. Errors are passed through to the returned stream, and data events
  /// are passed through if they are distinct from the most recently emitted
  /// data event.
  Stream<User?> get userChanges => _auth.userChanges().distinct();

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// You should not use this getter to listen to users state changes, instead
  /// use [authStateChanges], [idTokenChanges] or [userChanges] to subscribe to
  /// updates.
  User? get currentUser => _auth.currentUser;

  /// Whether there is currently a [User] signed-in.
  bool get isSignedIn => currentUser != null;

  UserData({
    required this.collection,
  });

  factory UserData.path(String path, Converter<T, DocumentSnapshot> converter) {
    return UserData(collection: Collection<T>.path(path, converter));
  }

  @override
  Future<T?> data() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = Document<T?>.path('$collection/${user.uid}', collection.converter);
    return doc.data();
  }

  @override
  Stream<T?> stream() {
    return userChanges.switchMap((user) {
      if (user == null) {
        print('User is currently signed out!');
        return Stream<T?>.value(null);
      }

      print('User is signed in!');
      final doc = Document<T?>.path('$collection/${user.uid}', collection.converter);
      return doc.stream();
    });
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    return collection.update(user.uid, data);
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user!;
    await collection.insert({
      'name': user.displayName ?? '',
      'image': user.photoURL ?? '',
    }, id: user.uid);

    return userCredential;
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      rethrow;
    }

    return userCredential;
  }

  @override
  Future<UserCredential> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;

      data ??= {
        'name': user.displayName ?? '',
        'image': user.photoURL ?? '',
      };
      // TODO: Show message, when no it could not connect to the database
      // ignore: unawaited_futures
      collection.insert(data, id: user.uid);
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      rethrow;
    }

    return userCredential;
  }

  @override
  Future<void> delete() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
      return collection.delete(user.uid);
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      // if (e.code == 'requires-recent-login') {
      //   print('The user must reauthenticate before this operation can be executed.');
      // }
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
    /*
    final user = _auth.currentUser;
    if (user == null) return;

    if (!user.emailVerified) {
      var actionCodeSettings = ActionCodeSettings(
        url: 'https://www.example.com/?email=${user.email}',
        dynamicLinkDomain: 'example.page.link',
        androidPackageName: 'com.example.android',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.example.ios',
        handleCodeInApp: true,
      );

      await user.sendEmailVerification(actionCodeSettings);
    }
    */
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
