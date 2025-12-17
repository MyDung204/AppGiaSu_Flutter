
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_class_provider.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
          ? const Center(child: Text('Chưa có lớp học nào.'))
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
                              ref.read(chatProvider.notifier).sendMessage(
                                studentId, 
                                "Chào bạn, sắp đến hạn đóng học phí cho lớp ${cls.name}. Vui lòng thanh toán sớm nhé!",
                                isUser: false, // Sent by Tutor (me)
                                isSystem: false, // Real chat
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
