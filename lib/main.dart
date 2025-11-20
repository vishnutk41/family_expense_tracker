import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'app/app_config.dart';
import 'utils/constants.dart';
import 'utils/route_animations.dart';
import '../sign_up.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
  await _localNotifications.initialize(initSettings);
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.getToken().then((t) => debugPrint('FCM token: $t'));
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = notification?.android;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  });
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.blueAccent,
          background: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
            TargetPlatform.macOS: CustomPageTransitionsBuilder(),
            TargetPlatform.windows: CustomPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      routes: {
        '/signup': (context) => SignUpScreen(),
      },
      home: AppConfig(),
    );
  }
}
