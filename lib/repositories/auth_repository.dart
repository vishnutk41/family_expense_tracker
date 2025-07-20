import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    // Create user document in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> getUserDataStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateUserName(String userId, String newName) async {
    await _firestore.collection('users').doc(userId).update({
      'name': newName,
    });
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'profileImageUrl': imageUrl,
    });
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('$userId.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
} 