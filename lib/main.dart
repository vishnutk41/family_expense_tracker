import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:convert';
import 'home_page.dart';
import 'screens/members_expenses_screen.dart';
import 'screens/profile_page.dart';
import 'screens/notifications_screen.dart';
import 'providers/notifications_provider.dart';
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
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _navigateFromData(Map<String, dynamic> data) {
  final String? route = data['route'] ?? data['screen'];
  switch (route) {
    case 'members':
      navigatorKey.currentState?.pushNamed('/members');
      break;
    case 'profile':
      navigatorKey.currentState?.pushNamed('/profile');
      break;
    case 'home':
      navigatorKey.currentState?.pushNamed('/home');
      break;
    default:
      navigatorKey.currentState?.pushNamed('/home');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
  await _localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final String? payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
          _navigateFromData(data);
        } catch (_) {}
      }
    },
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.getToken().then((t) => debugPrint('FCM token: $t'));
  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _navigateFromData(initialMessage.data);
  }
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      final container = ProviderScope.containerOf(ctx);
      final n = message.notification;
      final img = message.data['image'] ?? message.data['imageUrl'];
      container.read(notificationsControllerProvider.notifier).addFromParts(
        n?.title,
        n?.body,
        img is String ? img : null,
        message.data,
      );
    }
    _navigateFromData(message.data);
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = notification?.android;
    if (notification != null) {
      String? imageUrl;
      if (android != null) {
        try {
          final dynamic raw = (android as dynamic);
          if (raw.imageUrl is String) {
            imageUrl = raw.imageUrl as String;
          }
        } catch (_) {}
      }
      imageUrl ??= message.data['image'] ?? message.data['imageUrl'];

      AndroidBitmap<Object>? largeIconBitmap;
      BigPictureStyleInformation? bigPictureStyle;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(imageUrl);
          final client = HttpClient();
          final req = await client.getUrl(uri);
          final resp = await req.close();
          final filePath = '${Directory.systemTemp.path}/notif_${DateTime.now().millisecondsSinceEpoch}.img';
          final file = File(filePath);
          final sink = file.openWrite();
          await resp.forEach(sink.add);
          await sink.close();
          largeIconBitmap = FilePathAndroidBitmap(filePath);
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            hideExpandedLargeIcon: false,
          );
        } catch (_) {}
      }

      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF008080),
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        largeIcon: largeIconBitmap,
        styleInformation: bigPictureStyle,
      );

      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        final container = ProviderScope.containerOf(ctx);
        container.read(notificationsControllerProvider.notifier).addFromParts(
          notification.title,
          notification.body,
          imageUrl,
          message.data,
        );
      }

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
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
      navigatorKey: navigatorKey,
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
        '/home': (context) => HomePage(),
        '/members': (context) => MembersExpensesScreen(),
        '/profile': (context) => ProfilePage(),
        '/notifications': (context) => NotificationsScreen(),
      },
      home: AppConfig(),
    );
  }
}
