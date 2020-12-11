import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef QueryFunction = Query Function(Query query);
typedef FromSnapshot<T> = T Function(DocumentSnapshot snapshot);
// typedef FromMap<T> = T Function(Map<String, dynamic> data);
// typedef ToMap<T> = Map<String, dynamic> Function(T entity);

abstract class FirebaseDocument<T> {
  Future<T> data(FromSnapshot<T> entityFromSnapshot);
  Stream<T> stream(FromSnapshot<T> entityFromSnapshot);
  Future<void> update(Map<String, dynamic> data);
  Future<void> delete();
}

abstract class FirebaseCollection<T> {
  Future<List<T>> data(FromSnapshot<T> entityFromSnapshot);
  Stream<List<T>> stream(FromSnapshot<T> entityFromSnapshot);
  Future<DocumentReference> insert(Map<String, dynamic> data, {String id, bool merge});
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

abstract class FirebaseAuthentication {
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
    return reference.get().then(entityFromSnapshot);
  }

  @override
  Stream<T> stream(FromSnapshot<T> entityFromSnapshot) {
    return reference.snapshots().map(entityFromSnapshot);
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
    final queryFunction = query(reference) ?? reference;
    final snapshots = await queryFunction.get();
    return snapshots.docs.map(entityFromSnapshot).toList();
  }

  @override
  Stream<List<T>> stream(FromSnapshot<T> entityFromSnapshot, [QueryFunction query]) {
    final queryFunction = query(reference) ?? reference;
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

@deprecated
class AuthService extends FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<User> get currentUser => _auth.authStateChanges().first;

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }

  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInAnonymously() {
    // TODO: implement signInAnonymously
    throw UnimplementedError();
  }
}

class UserData<T> extends FirebaseDocument<T> implements FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

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
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        print('User is currently signed out!');
        return Stream<T>.value(null);
      }

      print('User is signed in!');
      final doc = Document<T>(path: '$collection/${user.uid}');
      return doc.stream(entityFromSnapshot);
    });
  }

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
    var userCredential;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          print('No user found for that email.');
          break;
        case 'wrong-password':
          print('Wrong password provided for that user.');
          break;
      }
    }

    return userCredential;
  }

  Future<UserCredential> signUp(String email, String password) async {
    var userCredential;

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
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print('The password provided is too weak.');
          rethrow;
          break;
        case 'email-already-in-use':
          print('The account already exists for that email.');
          rethrow;
          break;
      }
    } on Exception catch (e) {
      print(e);
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
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
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
  Future<void> signOut() async {
    _auth.signOut();
  }

  // Stream<T> get documentStream {

  //   return _auth.authStateChanges().switchMap((user) {
  //     if (user != null) {
  //       var doc = Document<T>(path: '$collection/${user.uid}');
  //       return doc.stream();
  //     } else {
  //       return Stream<T>.value(null);
  //     }
  //   });
  // }

  // Future<T> getDocument() async {
  //   final user = await _auth.currentUser;

  //   if (user != null) {
  //     final doc = Document<T>(path: '$collection/${user.uid}');
  //     return doc.data((snapshot) => User);
  //   } else {
  //     return null;
  //   }
  // }

  // Future<void> update(Map data) async {
  //   final user = await _auth.currentUser;
  //   final doc = Document<T>(path: '$collection/${user.uid}');
  //   return doc.update(data);
  // }
}

// class UserData<T> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final String collection;

//   UserData({this.collection});

//   Stream<T> get documentStream {
//     return _auth.onAuthStateChanged.switchMap((user) {
//       if (user != null) {
//         Document<T> doc = Document<T>(path: '$collection/${user.uid}');
//         return doc.streamData();
//       } else {
//         return Stream<T>.value(null);
//       }
//     });
//   }

//   Future<T> getDocument() async {
//     FirebaseUser user = await _auth.currentUser();

//     if (user != null) {
//       Document doc = Document<T>(path: '$collection/${user.uid}');
//       return doc.getData();
//     } else {
//       return null;
//     }
//   }

//   Future<void> upsert(Map data) async {
//     FirebaseUser user = await _auth.currentUser();
//     Document<T> ref = Document(path: '$collection/${user.uid}');
//     return ref.upsert(data);
//   }
// }

