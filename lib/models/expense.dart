import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id, uid, familyId, category;
  final double amount;
  final DateTime timestamp;

  Expense({required this.id, required this.uid, required this.familyId, required this.category, required this.amount, required this.timestamp});

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      uid: data['uid'],
      familyId: data['familyId'],
      category: data['category'],
      amount: (data['amount'] as num).toDouble(),
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
