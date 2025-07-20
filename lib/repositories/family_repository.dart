import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';

class FamilyRepository {
  final FirebaseFirestore _firestore;

  FamilyRepository(this._firestore);

  Future<String> createFamily(String name) async {
    final doc = await _firestore.collection('families').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> joinFamily(String userId, String familyId) async {
    await _firestore.collection('users').doc(userId).update({
      'familyId': familyId,
    });
  }

  Future<String?> getUserFamilyId(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['familyId'];
  }

  Stream<String?> getUserFamilyIdStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.data()?['familyId'];
    });
  }
} 