import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo & Khiếu nại')),
      body: ListView.builder(
        itemCount: 4,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Quan trọng', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text('Report #00${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('2 giờ trước', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Gia sư không đến dạy đúng giờ nhưng vẫn trừ tiền.'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Bỏ qua')),
                      ElevatedButton(onPressed: () {}, child: const Text('Xử lý')),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
