import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final firebaseAuthProvider = Provider((_) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider((_) => FirebaseFirestore.instance);
final firebaseMessagingProvider = Provider((_) => FirebaseMessaging.instance);
