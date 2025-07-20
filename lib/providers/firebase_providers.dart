import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseAuthProvider = Provider((_) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider((_) => FirebaseFirestore.instance);
