import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/user_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepository(this._firestore);

  Stream<List<Expense>> getExpensesByFamily(String familyId) {
    return _firestore
        .collection('expenses')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) {
      final expenses = snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return expenses;
    });
  }

  Future<void> addExpense(String uid, String familyId, String category, double amount) async {
    await _firestore.collection('expenses').add({
      'uid': uid,
      'familyId': familyId,
      'category': category,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, UserModel>> getFamilyMembers(String familyId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('familyId', isEqualTo: familyId)
        .get();
    
    final members = <String, UserModel>{};
    for (final doc in querySnapshot.docs) {
      members[doc.id] = UserModel.fromMap(doc.id, doc.data());
    }
    return members;
  }
} 