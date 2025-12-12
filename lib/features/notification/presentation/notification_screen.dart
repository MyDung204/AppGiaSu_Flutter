import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final notifications = [
      _NotificationItem(
        title: 'Đặt lịch thành công',
        body: 'Gia sư Nguyễn Văn A đã xác nhận yêu cầu đặt lịch của bạn vào 14:00 hôm nay.',
        time: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        type: 'booking',
      ),
      _NotificationItem(
        title: 'Tin nhắn mới',
        body: 'Bạn có tin nhắn mới từ Gia sư Trần Thị B.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'message',
      ),
      _NotificationItem(
        title: 'Nhắc nhở lịch học',
        body: 'Bạn có buổi học môn Toán với Gia sư A vào lúc 09:00 ngày mai.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'reminder',
      ),
      _NotificationItem(
        title: 'Khuyến mãi đặc biệt',
        body: 'Giảm 20% phí đặt lịch cho lần đầu tiên sử dụng ví thanh toán.',
        time: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: 'promotion',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu đã đọc tất cả',
            onPressed: () {},
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa có thông báo nào', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isRead ? Colors.grey[200] : Colors.blue[50],
                    child: Icon(
                      _getIconForType(item.type),
                      color: item.isRead ? Colors.grey : Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyle(
                          color: item.isRead ? Colors.black54 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(item.time),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: item.isRead ? Colors.transparent : Colors.blue.withOpacity(0.02),
                  onTap: () {
                    // Navigate to detail if needed
                  },
                );
              },
            ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'reminder':
        return Icons.alarm;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}

class _NotificationItem {
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String type;

  _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
