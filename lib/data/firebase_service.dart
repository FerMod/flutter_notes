import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef QueryFunction = Query Function(Query query);
typedef FromSnapshot<T> = T Function(DocumentSnapshot snapshot);
// typedef FromMap<T> = T Function(Map<String, dynamic> data);
// typedef ToMap<T> = Map<String, dynamic> Function(T entity);

abstract class FirebaseDocument<T> {
  const FirebaseDocument();

  Future<T> data(FromSnapshot<T> entityFromSnapshot);
  Stream<T> stream(FromSnapshot<T> entityFromSnapshot);
  Future<void> update(Map<String, dynamic> data);
  Future<void> delete();
}

abstract class FirebaseCollection<T> {
  const FirebaseCollection();

  Future<List<T>> data(FromSnapshot<T> entityFromSnapshot);
  Stream<List<T>> stream(FromSnapshot<T> entityFromSnapshot);
  Future<DocumentReference> insert(Map<String, dynamic> data, {String id, bool merge});
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

class Document<T> extends FirebaseDocument<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String path;

  DocumentReference reference;

  Document({@required this.path}) {
    reference = _firestore.doc(path);
  }

  @override
  Future<T> data(FromSnapshot<T> entityFromSnapshot) {
    return reference.get()?.then(entityFromSnapshot);
  }

  @override
  Stream<T> stream(FromSnapshot<T> entityFromSnapshot) {
    return reference.snapshots()?.map(entityFromSnapshot);
  }

  /// Updates data on the document. The data will be merged with any existing
  /// document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(Map<String, dynamic> data) async {
    try {
      reference.update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        developer.log('Error updating document: ${e.message}');
        rethrow;
      }
    }
  }

  @override
  Future<void> delete() async {
    reference.delete();
  }
}

class Collection<T> extends FirebaseCollection<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String path;

  CollectionReference reference;

  Collection({@required this.path}) {
    reference = _firestore.collection(path);
  }

  @override
  Future<List<T>> data(FromSnapshot<T> entityFromSnapshot, [QueryFunction query]) async {
    // final queryFunction = query(reference) ?? reference;
    // final queryFunction = query != null ? query(reference) : reference;
    final queryFunction = query?.call(reference) ?? reference;
    final snapshots = await queryFunction.get();
    return snapshots.docs.map(entityFromSnapshot).toList();
  }

  @override
  Stream<List<T>> stream(FromSnapshot<T> entityFromSnapshot, [QueryFunction query]) {
    final queryFunction = query?.call(reference) ?? reference;
    // final dataStream =
    // StreamController<List<T>> streamController;
    // streamController = StreamController(onListen: () {
    //   streamController.addStream(dataStream);
    // });
    // return streamController.stream;
    return queryFunction.snapshots().map((snapshot) => snapshot.docs.map(entityFromSnapshot).toList());
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
  Future<DocumentReference> insert(Map<String, dynamic> data, {String id, bool merge = false}) async {
    assert(data != null);
    // reference.add(data);
    final newDocument = reference.doc(id);
    await newDocument.set(data, SetOptions(merge: merge));
    return newDocument;
  }

  /// Updates data on the document with provided [id]. Data will be merged with
  /// any existing document data.
  ///
  /// If the document does not exist, a [FirebaseException] with the error code
  /// `not-found` will be thrown.
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    assert(id != null);
    try {
      reference.doc(id).update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        developer.log('Error updating document: ${e.message}');
        rethrow;
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    assert(id != null);
    reference.doc(id).delete();
  }
}

class UserData<T> extends FirebaseDocument<T> implements FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<User> get authStateChange => _auth.authStateChanges().distinct();

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  ///
  /// It notifies the same state changes as [authStateChange] in addition to
  /// notifications about token refresh events.
  Stream<User> get idTokenChanges => _auth.userChanges().distinct();

  /// Notifies about changes to any user updates.
  ///
  /// This is a superset of both [authStateChanges] and [idTokenChanges].
  /// It provides events on all user changes, such as when credentials are
  /// linked, unlinked and when updates to the user profile are made.
  ///
  /// The purpose of this Stream is to for listening to realtime updates to the
  /// user without manually having to call [reload].
  Stream<User> get userChanges => _auth.userChanges().distinct();

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// You should not use this getter to listen to users state changes, instead
  /// use [authStateChanges], [idTokenChanges] or [userChanges] to subscribe to
  /// updates.
  User get currentUser => _auth.currentUser;

  UserData({@required this.collection});

  @override
  Future<T> data(FromSnapshot<T> entityFromSnapshot) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = Document<T>(path: '$collection/${user.uid}');
    return doc.data(entityFromSnapshot);
  }

  @override
  Stream<T> stream(FromSnapshot<T> entityFromSnapshot) {
    final dataStream = userChanges.switchMap((user) {
      if (user == null) {
        print('User is currently signed out!');
        return Stream<T>.value(null);
      }

      print('User is signed in!');
      final doc = Document<T>(path: '$collection/${user.uid}');
      return doc.stream(entityFromSnapshot);
    });

    StreamController<T> streamController;
    streamController = StreamController<T>(onListen: () {
      dataStream.pipe(streamController);
    });
    return streamController.stream;
  }

  //  @override
  // Stream<T> stream(FromSnapshot<T> entityFromSnapshot) {
  //   return authStateChange.switchMap((user) {
  //     if (user == null) {
  //       print('User is currently signed out!');
  //       return Stream<T>.value(null);
  //     }

  //     print('User is signed in!');
  //     final doc = Document<T>(path: '$collection/${user.uid}');
  //     return doc.stream(entityFromSnapshot);
  //   });
  // }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = Collection<T>(path: collection);
    return doc.update(user.uid, data);
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user;
    final col = Collection<T>(path: collection);
    col.insert({
      'name': user.displayName ?? '',
      'image': user.photoURL ?? '',
    }, id: user.uid);

    return userCredential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('${e.code}: ${e.message}');
      // switch (e.code) {
      //   case 'user-not-found':
      //     print('No user found for that email.');
      //     //rethrow;
      //     break;
      //   case 'wrong-password':
      //     print('Wrong password provided for that user.');
      //     // rethrow;
      //     break;
      //   case 'invalid-email':
      //     print('The email address is not valid.');
      //     // rethrow;
      //     break;
      //   case 'user-disabled':
      //     print('The user corresponding to the given email has been disabled.');
      //     // rethrow;
      //     break;
      // }
      rethrow;
    }

    return userCredential;
  }

  Future<UserCredential> signUp(String email, String password) async {
    UserCredential userCredential;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      final col = Collection<T>(path: collection);
      col.insert({
        'name': user.displayName ?? '',
        'image': user.photoURL ?? '',
      }, id: user.uid);
    } on FirebaseAuthException catch (e) {
      developer.log('${e.code}: ${e.message}');
      // switch (e.code) {
      //   case 'weak-password':
      //     print('The password provided is too weak.');
      //     // rethrow;
      //     break;
      //   case 'invalid-email':
      //     print('The email address is not valid.');
      //     // rethrow;
      //     break;
      //   case 'email-already-in-use':
      //     print('The account already exists for that email.');
      //     // rethrow;
      //     break;
      // }
      rethrow;
    } on Exception catch (e) {
      print('Exception thrown when signing up.\n$e');
      rethrow;
    }

    return userCredential;
  }

  @override
  Future<void> delete() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      user.delete();
      final col = Collection<T>(path: collection);
      col.delete(user.uid);
    } on FirebaseAuthException catch (e) {
      developer.log('${e.code}: ${e.message}');
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
          dynamicLinkDomain: "example.page.link",
          androidPackageName: "com.example.android",
          androidInstallApp: true,
          androidMinimumVersion: "12",
          iOSBundleId: "com.example.ios",
          handleCodeInApp: true);

      await user.sendEmailVerification(actionCodeSettings);
    }
    */
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
