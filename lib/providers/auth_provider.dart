import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final userDataProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value(null);
  
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('users').doc(user.uid).snapshots().map((doc) => doc.data());
});

final authActionsProvider = Provider((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthActions(auth, firestore);
});

class AuthActions {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  AuthActions(this._auth, this._firestore);

  Future<UserCredential> signIn(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email, password: pass);

  Future<UserCredential> signUp(String email, String pass, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    
    // Store user data in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return userCredential;
  }

  Future<void> signOut() => _auth.signOut();
}
