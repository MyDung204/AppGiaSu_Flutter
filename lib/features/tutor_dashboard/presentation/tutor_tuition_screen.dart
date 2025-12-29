/// Tutor Tuition Screen
/// 
/// **Purpose:**
/// - Quản lý học phí và thanh toán của học viên
/// - Cho phép gia sư theo dõi trạng thái thanh toán và nhắc nợ
/// 
/// **Features:**
/// - Xem danh sách lớp học và học viên
/// - Xem trạng thái thanh toán: Đã đóng, Chưa đóng, Quá hạn
/// - Nhắc nợ: Gửi tin nhắn tự động cho học viên chưa đóng học phí
/// - Xem hạn thu học phí
/// 
/// **Payment Status:**
/// - Paid (Đã đóng): Màu xanh, có icon check
/// - Unpaid (Chưa đóng): Màu cam, có button "Nhắc nợ"
/// - Overdue (Quá hạn): Màu đỏ, có button "Nhắc nợ"
/// 
/// **TODO:**
/// - Tích hợp payment gateway để xử lý thanh toán
/// - Thêm tính năng xác nhận thanh toán
/// - Thêm lịch sử thanh toán

import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_class_provider.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Màn hình quản lý học phí của gia sư
/// 
/// **Usage:**
/// - Truy cập từ tutor navigation (nếu có menu item)
/// - Hiển thị danh sách lớp học và trạng thái thanh toán của học viên
class TutorTuitionScreen extends ConsumerWidget {
  const TutorTuitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(tutorClassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Học phí (SaaS)'),
      ),
      body: classes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lớp học nào.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tạo lớp học để bắt đầu quản lý học phí.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final cls = classes[index];
                final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
                final nextPay = cls.nextPaymentDate != null 
                    ? DateFormat('dd/MM/yyyy').format(cls.nextPaymentDate!) 
                    : 'N/A';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Hạn thu: $nextPay | Học phí: ${currency.format(cls.price)}/tháng'),
                    children: [
                      ...cls.studentIds.map((studentId) {
                        final status = cls.paymentStatus[studentId] ?? 'unpaid';
                        Color statusColor;
                        String statusText;

                        switch (status) {
                          case 'paid':
                            statusColor = Colors.green;
                            statusText = 'Đã đóng';
                            break;
                          case 'overdue':
                            statusColor = Colors.red;
                            statusText = 'Quá hạn';
                            break;
                          default:
                            statusColor = Colors.orange;
                            statusText = 'Chưa đóng';
                        }

                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Học viên $studentId'), // Mock name
                          subtitle: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                          trailing: status != 'paid' ? TextButton.icon(
                            icon: const Icon(Icons.notifications_active, size: 18),
                            label: const Text('Nhắc nợ'),
                            onPressed: () {
                              // Auto send chat reminder
                              ref.read(chatControllerProvider(studentId)).sendMessage(
                                "Chào bạn, sắp đến hạn đóng học phí cho lớp ${cls.name}. Vui lòng thanh toán sớm nhé!",
                              );
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã gửi tin nhắn nhắc nợ!')),
                              );
                            },
                          ) : const Icon(Icons.check_circle, color: Colors.green),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
