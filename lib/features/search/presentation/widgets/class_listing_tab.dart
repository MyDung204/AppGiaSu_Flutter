import 'package:flutter/material.dart';

class ClassListingTab extends StatelessWidget {
  const ClassListingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.blue.shade100,
                  child: Center(
                    child: Icon(Icons.class_outlined, size: 60, color: Colors.blue.shade300),
                  ),
                  // In real app, use Image.network
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Offline', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                         const Text('20/30 HV', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Luyện thi IELTS 6.5 Cấp tốc',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Giảng viên: Thầy John Doe',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Học phí', style: TextStyle(color: Colors.grey, fontSize: 12)),
                             Text('2.5tr/khóa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                           ],
                         ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Đăng ký khóa học'),
                                content: const Text('Bạn muốn đăng ký khóa học này? Học phí sẽ được trừ vào ví của bạn.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Để sau'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra lịch học.')),
                                      );
                                    },
                                    child: const Text('Đăng ký ngay'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Đăng ký'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
