import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/expense_repository.dart';
import '../models/expense.dart';
import '../models/user_model.dart';
import 'family_viewmodel.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(FirebaseFirestore.instance);
});

final expenseViewModelProvider = StateNotifierProvider<ExpenseViewModel, AsyncValue<List<Expense>>>((ref) {
  return ExpenseViewModel(ref.read(expenseRepositoryProvider));
});

final familyMembersProvider = FutureProvider.autoDispose<Map<String, UserModel>>((ref) async {
  final familyId = ref.watch(familyIdProvider);
  if (familyId == null) return {};
  
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getFamilyMembers(familyId);
});

class ExpenseViewModel extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _expenseRepository;
  
  ExpenseViewModel(this._expenseRepository) : super(const AsyncValue.loading());

  Stream<List<Expense>> getExpensesByFamily(String familyId) {
    return _expenseRepository.getExpensesByFamily(familyId);
  }

  Future<void> addExpense(String uid, String familyId, String category, double amount) async {
    try {
      await _expenseRepository.addExpense(uid, familyId, category, amount);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<Map<String, UserModel>> getFamilyMembers(String familyId) async {
    try {
      return await _expenseRepository.getFamilyMembers(familyId);
    } catch (e) {
      throw Exception('Failed to get family members: $e');
    }
  }
} 