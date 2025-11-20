import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String? title;
  final String? body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool unread;
  AppNotification({this.title, this.body, this.imageUrl, required this.data, required this.timestamp, this.unread = true});
  AppNotification copyWith({bool? unread}) {
    return AppNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      timestamp: timestamp,
      unread: unread ?? this.unread,
    );
  }
}

class NotificationsController extends StateNotifier<List<AppNotification>> {
  NotificationsController() : super(const []);
  void add(AppNotification n) => state = [n, ...state];
  void addFromParts(String? title, String? body, String? imageUrl, Map<String, dynamic> data) {
    add(AppNotification(title: title, body: body, imageUrl: imageUrl, data: data, timestamp: DateTime.now()));
  }
  void clear() => state = const [];
  void markRead(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated[index] = updated[index].copyWith(unread: false);
    state = updated;
  }
}

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, List<AppNotification>>(
  (ref) => NotificationsController(),
);
