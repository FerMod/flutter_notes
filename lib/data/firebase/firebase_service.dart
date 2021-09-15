import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:google_sign_in/google_sign_in.dart';

typedef QueryFunction<T> = T Function(T query);

abstract class FirebaseDocument<T> {
  const FirebaseDocument();

  Future<T?> data();
  Stream<T?> stream();
  Future<void> update(Map<String, Object?> data);
  Future<void> delete();
}

abstract class FirebaseCollection<T> {
  const FirebaseCollection();

  Future<List<T>> data();
  Stream<List<T>> stream();
  Future<FirebaseDocument<T>> insert(T data, {String? id, bool merge = false});
  Future<void> update(String id, Map<String, Object?> data);
  Future<void> delete(String id);
}

@immutable
class FirestoreConverter<T> {
  const FirestoreConverter({
    required this.fromFirestore,
    required this.toFirestore,
  });

  final FromFirestore<T> fromFirestore;
  final ToFirestore<T> toFirestore;
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
/// See also:
///
///  * <https://firebase.google.com/docs/firestore/data-model#documents>
class Document<T> extends FirebaseDocument<T> {
  /// An object that refers to a Firestore document path.
  final DocumentReference<T> reference;
  final FirestoreConverter<T> converter;

  /// Creates a document with the specified [reference].
  const Document({
    required this.reference,
    required this.converter,
  });

  /// Creates a document with a [reference] with the specified [path].
  ///
  /// An optional [firestore] parameter can be given to provide a
  /// FirebaseFirestore instance, used to access the document. If none is
  /// provided, the default instance given by [FirebaseFirestore.instance] is
  /// used instead.
  factory Document.path(String path, {required FirestoreConverter<T> converter, FirebaseFirestore? firestore}) {
    firestore ??= FirebaseFirestore.instance;
    return Document(
      reference: firestore.doc(path).withConverter<T>(
            fromFirestore: converter.fromFirestore,
            toFirestore: converter.toFirestore,
          ),
      converter: converter,
    );
  }

  T parseSnapshot(DocumentSnapshot<T> snapshot) {
    return snapshot.data() as T;
  }

  @override
  Future<T> data() async {
    return reference.get().then(parseSnapshot);
  }

  @override
  Stream<T> stream() {
    return reference.snapshots().map(parseSnapshot);
  }

  /// Updates data on the document. The data will be merged with any existing
  /// document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(Map<String, Object?> data) async {
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
/// See also:
///
///  * <https://firebase.google.com/docs/firestore/data-model#collections>
class Collection<T> extends FirebaseCollection<T> {
  /// An object that refers to a Firestore collection path.
  final CollectionReference<T> reference;
  final FirestoreConverter<T> converter;

  /// Creates a collection with the specified [reference].
  const Collection({
    required this.reference,
    required this.converter,
  });

  /// Creates a collection with a [reference] with the specified [path].
  ///
  /// An optional [firestore] parameter can be given to provide a
  /// [FirebaseFirestore] instance, used to access the collection. If none is
  /// provided, the default instance given by [FirebaseFirestore.instance] is
  /// used instead.
  factory Collection.path(String path, {required FirestoreConverter<T> converter, FirebaseFirestore? firestore}) {
    firestore ??= FirebaseFirestore.instance;
    return Collection(
      reference: firestore.collection(path).withConverter<T>(
            fromFirestore: converter.fromFirestore,
            toFirestore: converter.toFirestore,
          ),
      converter: converter,
    );
  }

  List<T> parseSnapshot(QuerySnapshot<T> snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<T>> data([QueryFunction<Query<T>>? query]) async {
    final queryFunction = query?.call(reference) ?? reference;
    return queryFunction.get().then(parseSnapshot);
  }

  @override
  Stream<List<T>> stream([QueryFunction<Query<T>>? query]) {
    final queryFunction = query?.call(reference) ?? reference;
    return queryFunction.snapshots().map(parseSnapshot);
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
  Future<FirebaseDocument<T>> insert(T data, {String? id, bool merge = false}) async {
    final newDocument = reference.doc(id);
    await newDocument.set(data, SetOptions(merge: merge));
    return Document<T>(
      reference: newDocument,
      converter: converter,
    );
  }

  /// Updates data on the document with provided [id]. Data will be merged with
  /// any existing document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(String id, Map<String, Object?> data) async {
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

/// An object that represents a Firebase Auth user that is used to store user
/// data.
class UserData<T> implements FirebaseAuthentication {
  final FirebaseAuth _auth;
  final T Function(User user) converter;

  /// Creates a user data access class with a [converter].
  ///
  /// An optional [auth] parameter can be given to provide a [FirebaseAuth]
  /// instance. If none is provided, the default instance given by
  /// [FirebaseAuth.instance] is used instead.
  UserData({
    required this.converter,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  ///
  /// The returned stream never provides two consecutive data events that are
  /// equal. Errors are passed through to the returned stream, and data events
  /// are passed through if they are distinct from the most recently emitted
  /// data event.
  Stream<User?> authStateChanges() => _auth.authStateChanges().distinct();

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
  Stream<User?> idTokenChanges() => _auth.idTokenChanges().distinct();

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
  Stream<User?> userChanges() => _auth.userChanges().distinct();

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// You should not use this getter to listen to users state changes, instead
  /// use [authStateChanges], [idTokenChanges] or [userChanges] to subscribe to
  /// updates.
  User? get currentUser => _auth.currentUser;

  /// Whether there is currently a [User] signed-in.
  ///
  /// Returns `true` if [currentUser] is not `null`, therefore, a user is
  /// currently signed-in.
  ///
  /// See also:
  ///
  ///  * [currentUser] to obtain the current signed-in user.
  bool get isSignedIn => _auth.currentUser != null;

  /// Update the user's display name.
  void updateDisplayName(String? displayName) {
    _auth.currentUser?.updateDisplayName(displayName);
  }

  /// Update the user's profile image.
  void updateImageUrl(String? imageUrl) {
    _auth.currentUser?.updatePhotoURL(imageUrl);
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    late UserCredential userCredential;
    try {
      userCredential = await _auth.signInAnonymously();

      final user = userCredential.user!;
      await user.updateDisplayName('Anonymous');
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      rethrow;
    }

    return userCredential;
  }

  /// Sign in with Google account.
  Future<UserCredential> signInWithGoogle() async {
    late UserCredential userCredential;
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      userCredential = await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      developer.log('$e');
      rethrow;
    }

    return userCredential;
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    late UserCredential userCredential;
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
  Future<UserCredential> signUp(String email, String password, {String? displayName, String? photoURL}) async {
    late UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
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
    // throw UnimplementedError();

    final user = _auth.currentUser;
    if (user == null) return;

    // return user.sendEmailVerification();

    if (!user.emailVerified) {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://fermod.github.io/flutter_notes/?verify=${user.email}',
        dynamicLinkDomain: 'fermodflutter.page.link',
        androidPackageName: 'com.fermod.flutter_notes',
        androidMinimumVersion: '21',
        iOSBundleId: 'com.fermod.flutter_notes',
        handleCodeInApp: true,
      );

      await user
          .sendEmailVerification(actionCodeSettings)
          .catchError((onError) => developer.log('Error sending email verification $onError'))
          .then((value) => developer.log('Successfully sent email verification'));
    }
  }

  Future<void> verifyAccount(String oobCode) async {
    // TODO: implement sendEmailVerification
    // throw UnimplementedError();

    await _auth.checkActionCode(oobCode);
    await _auth.applyActionCode(oobCode);

    // If successful, reload the user:
    await _auth.currentUser?.reload();
  }

  /// Signs out the current user.
  ///
  /// If the operation is successful, it also notifies and updates any
  /// [authStateChanges], [idTokenChanges] or [userChanges] stream listeners,
  /// and [currentUser] will return `null`.
  @override
  Future<void> signOut() => _auth.signOut();
}
