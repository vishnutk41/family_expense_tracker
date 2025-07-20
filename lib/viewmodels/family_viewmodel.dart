import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/family_repository.dart';
import '../models/family_model.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(FirebaseFirestore.instance);
});

final familyViewModelProvider = StateNotifierProvider<FamilyViewModel, AsyncValue<String?>>((ref) {
  return FamilyViewModel(ref.read(familyRepositoryProvider));
});

final familyIdProvider = StateProvider<String?>((ref) => null);

class FamilyViewModel extends StateNotifier<AsyncValue<String?>> {
  final FamilyRepository _familyRepository;
  
  FamilyViewModel(this._familyRepository) : super(const AsyncValue.loading());

  Future<void> loadUserFamilyId(String userId) async {
    try {
      final familyId = await _familyRepository.getUserFamilyId(userId);
      state = AsyncValue.data(familyId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to get user family ID: $e');
    }
  }

  Future<String> createFamily(String name) async {
    try {
      final familyId = await _familyRepository.createFamily(name);
      state = AsyncValue.data(familyId);
      return familyId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to create family: $e');
    }
  }

  Future<void> joinFamily(String userId, String familyId) async {
    try {
      await _familyRepository.joinFamily(userId, familyId);
      state = AsyncValue.data(familyId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to join family: $e');
    }
  }

  Stream<String?> getUserFamilyIdStream(String userId) {
    return _familyRepository.getUserFamilyIdStream(userId);
  }
} 