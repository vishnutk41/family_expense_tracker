import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'notifications/background_handler.dart';
import 'notifications/notifications_service.dart';
import 'app/app.dart';

// app initialization only

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsService.init();
  await FirebaseMessaging.instance.getToken().then((t) => debugPrint('FCM token: $t'));
  await NotificationsService.handleInitialMessage();
  runApp(ProviderScope(child: MyApp()));
}

// MyApp moved to app/app.dart
