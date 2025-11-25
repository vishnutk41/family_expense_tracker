import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_provider.dart';
import '../router/router.dart';
import '../router/navigation.dart';

class NotificationsService {
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
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
            navigateFromData(data);
          } catch (_) {}
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final ctx = appRouter.navigatorKey.currentContext;
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
      navigateFromData(message.data);
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

        final ctx = appRouter.navigatorKey.currentContext;
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
  }

  static Future<void> handleInitialMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      navigateFromData(initialMessage.data);
    }
  }
}

