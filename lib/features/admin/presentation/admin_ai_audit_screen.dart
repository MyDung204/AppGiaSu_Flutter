import 'package:flutter/material.dart';

class AdminAiAuditScreen extends StatelessWidget {
  const AdminAiAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mắt Thần AI - Giám Sát'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Cảnh báo Thời gian thực (Real-time)', Icons.warning_amber_rounded, Colors.red),
            const SizedBox(height: 12),
            _buildAlertCard(
              context,
              'Phát hiện gian lận đặt lịch',
              'Gia sư Nguyễn Văn A nhận 15 yêu cầu chỉ trong 1 phút.',
              'Nguy hiểm cao',
              Colors.red,
            ),
            _buildAlertCard(
              context,
              'Từ khóa nhạy cảm',
              'Học viên B gửi tin nhắn chứa từ khóa cấm: "chuyển khoản ngoài".',
              'Cảnh báo',
              Colors.orange,
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Nhật ký Quét Tin nhắn (AI Scan)', Icons.message_outlined, Colors.blue),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '[15:3${index}] AI Scan:',
                          style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đã kiểm tra hội thoại #${10234 + index} - An toàn.',
                            style: const TextStyle(color: Colors.green, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, String title, String description, String badge, Color badgeColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: badgeColor,
                  side: BorderSide(color: badgeColor),
                ),
                child: const Text('Xử lý ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
