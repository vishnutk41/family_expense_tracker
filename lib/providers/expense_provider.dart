import 'package:firebase1/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import 'firebase_providers.dart';
import 'family_provider.dart';

final userNamesProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final familyId = ref.watch(familyIdProvider);
  
  if (familyId == null) return {};
  
  // Get all users in the family
  final usersQuery = await firestore.collection('users')
    .where('familyId', isEqualTo: familyId)
    .get();
  
  final userNames = <String, String>{};
  for (final doc in usersQuery.docs) {
    userNames[doc.id] = doc.data()['name'] ?? 'Unknown User';
  }
  
  return userNames;
});

final expenseListProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final uid = ref.watch(authStateProvider).asData!.value!.uid;
  final familyId = ref.watch(familyIdProvider);

  if (familyId == null) {
    return Stream.value([]);
  }

  final query = firestore.collection('expenses')
    .where('familyId', isEqualTo: familyId);

  return query.snapshots().map((snap) {
    final expenses = snap.docs.map((d) => Expense.fromFirestore(d)).toList();
    // Sort by timestamp in descending order in Dart
    expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return expenses;
  });
});

final expenseActionsProvider = Provider((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final uid = ref.watch(authStateProvider).asData!.value!.uid;
  final familyId = ref.watch(familyIdProvider);
  return ExpenseActions(firestore, uid, familyId);
});

class ExpenseActions {
  final FirebaseFirestore _firestore;
  final String _uid;
  final String? _familyId;

  ExpenseActions(this._firestore, this._uid, this._familyId);

  Future<void> addExpense(String category, double amount) {
    if (_familyId == null) throw 'No family selected';
    final data = {
      'uid': _uid,
      'familyId': _familyId,
      'category': category,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    };
    return _firestore.collection('expenses').add(data);
  }
}
