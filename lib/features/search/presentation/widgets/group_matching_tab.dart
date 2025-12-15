import 'package:doantotnghiep/features/group/data/group_request_provider.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GroupMatchingTab extends ConsumerWidget {
  const GroupMatchingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(groupRequestsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/create-group');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Tạo nhóm học mới'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
            ),
          ),
        ),
        Expanded(
          child: requests.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text("Chưa có nhóm nào đang tìm thành viên.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return _buildGroupCard(context, req, currencyFormat);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupRequest req, NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Đang chờ: ${req.currentMembers}/${req.maxMembers} HS',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  '${currencyFormat.format(req.pricePerSession)}/buổi',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${req.subject} - ${req.gradeLevel}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Tạo bởi: ${req.creatorName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              req.description,
              style: const TextStyle(color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
               children: [
                 const Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey),
                 const SizedBox(width: 4),
                  Text(req.location, style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
               ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showJoinConfirmation(context, req);
                },
                style: OutlinedButton.styleFrom(
                   side: const BorderSide(color: Colors.blueAccent),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   foregroundColor: Colors.blueAccent,
                ),
                child: const Text('Tham gia nhóm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinConfirmation(BuildContext context, GroupRequest req) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận tham gia'),
        content: Text('Bạn có chắc chắn muốn tham gia nhóm "${req.subject}" này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Logic to join group would go here (update members count etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi yêu cầu tham gia thành công!')),
              );
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }
}
