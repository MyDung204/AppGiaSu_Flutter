import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_class.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends StatelessWidget {
  final TutorClass tutorClass;

  const ClassDetailScreen({super.key, required this.tutorClass});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết lớp học'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng chỉnh sửa đang phát triển")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // Confirm dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn đóng/hủy lớp học này không?'),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () {
                         ctx.pop();
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đóng lớp đang phát triển")));
                      }, 
                      child: const Text('Đồng ý', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(child: Icon(Icons.class_, size: 30, color: Colors.blue)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutorClass.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tutorClass.status == 'upcoming' ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tutorClass.status == 'upcoming' ? 'Sắp diễn ra' : 'Đang hoạt động',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tutorClass.mode,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Grid
            const Text("Thông tin chi tiết", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, "Lịch học", tutorClass.schedule),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, "Địa điểm", tutorClass.address ?? "Online"),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money, "Học phí", currencyFormat.format(tutorClass.price)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people, "Học viên", "${tutorClass.enrolledStudentCount} đã đăng ký"),

            const SizedBox(height: 24),
             const Text("Mô tả", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 8),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.grey.shade200),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Text(
                 tutorClass.description.isNotEmpty ? tutorClass.description : "Chưa có mô tả chi tiết.",
                 style: const TextStyle(color: Colors.black87, height: 1.4),
               ),
             ),
             
             const SizedBox(height: 24),
             if (tutorClass.studentIds.isNotEmpty) ...[
               const Text("Danh sách học viên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 8),
               // Placeholder list
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: tutorClass.studentIds.length,
                 itemBuilder: (context, index) {
                   return ListTile(
                     leading: const CircleAvatar(child: Icon(Icons.person)),
                     title: Text(tutorClass.studentIds[index]),
                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   );
                 },
               )
             ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }
}
