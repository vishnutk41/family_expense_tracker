import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import 'auth_viewmodel.dart';

class ProfileState {
  final bool isLoading;
  final bool isEditingName;
  final UserModel? user;
  final String? error;

  ProfileState({
    this.isLoading = false,
    this.isEditingName = false,
    this.user,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isEditingName,
    UserModel? user,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isEditingName: isEditingName ?? this.isEditingName,
      user: user ?? this.user,
      error: error,
    );
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref.read(authViewModelProvider.notifier));
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final AuthViewModel _authViewModel;
  
  ProfileViewModel(this._authViewModel) : super(ProfileState());

  Future<void> loadUserProfile(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final userData = await _authViewModel.getUserData(userId);
      state = state.copyWith(isLoading: false, user: userData, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setEditingName(bool editing) {
    state = state.copyWith(isEditingName: editing);
  }

  Future<void> updateUserName(String userId, String newName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authViewModel.updateUserName(userId, newName);
      await loadUserProfile(userId);
      state = state.copyWith(isEditingName: false, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('profile_images/$userId.jpg');
      final file = File(imageFile.path);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      await _authViewModel.updateProfileImage(userId, downloadUrl);
      await loadUserProfile(userId);
      state = state.copyWith(isLoading: false, error: null);
      return downloadUrl;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      throw Exception('Failed to pick image: $e');
    }
  }
} 