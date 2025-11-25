import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

@RoutePage()
class NotificationsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: items.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final n = items[index];
                final dateStr = DateFormat('dd MMM yyyy').format(n.timestamp);
                final timeStr = DateFormat('h:mm a').format(n.timestamp);
                return GestureDetector(
                  onTap: () {
                    ref.read(notificationsControllerProvider.notifier).markRead(index);
                    final route = n.data['route'] ?? n.data['screen'];
                    if (route is String && route.isNotEmpty) {
                      context.router.pushPath('/$route');
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(top: 14, right: 10),
                        decoration: BoxDecoration(
                          color: n.unread ? Colors.red : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title ?? '',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        n.body ?? '',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            dateStr,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            timeStr,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                if (n.imageUrl != null && n.imageUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      n.imageUrl!,
                                      width: 120,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
