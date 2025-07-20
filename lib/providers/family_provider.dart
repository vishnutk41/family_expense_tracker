import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import 'firebase_providers.dart';

final familyIdProvider = StateProvider<String?>((ref) => null);

final familyActionsProvider = Provider((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateProvider).asData!.value!;
  final familyIdController = ref.read(familyIdProvider.notifier);
  return FamilyActions(firestore, user.uid, familyIdController);
});

class FamilyActions {
  final FirebaseFirestore _firestore;
  final String _uid;
  final StateController<String?> _familyIdController;
  FamilyActions(this._firestore, this._uid, this._familyIdController);

  Future<void> createFamily(String name) async {
    final doc = await _firestore.collection('families').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _familyIdController.state = doc.id;
    await _firestore.collection('users').doc(_uid)
      .set({'familyId': doc.id}, SetOptions(merge: true));
  }

  Future<void> joinFamily(String id) async {
    _familyIdController.state = id;
    await _firestore.collection('users').doc(_uid)
      .set({'familyId': id}, SetOptions(merge: true));
  }

  Future<void> loadFamilyId() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    _familyIdController.state = doc.data()?['familyId'];
  }
}
