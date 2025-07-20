import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;
  
  AuthViewModel(this._authRepository) : super(const AsyncValue.loading()) {
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _authRepository.signIn(email, password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      return await _authRepository.signUp(email, password, name);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      return await _authRepository.getUserData(userId);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Stream<UserModel?> getUserDataStream(String userId) {
    return _authRepository.getUserDataStream(userId);
  }

  Future<void> updateUserName(String userId, String newName) async {
    try {
      await _authRepository.updateUserName(userId, newName);
    } catch (e) {
      throw Exception('Failed to update user name: $e');
    }
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _authRepository.updateProfileImage(userId, imageUrl);
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }
} 