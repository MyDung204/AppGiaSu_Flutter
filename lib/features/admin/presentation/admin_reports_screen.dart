import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final List<Map<String, dynamic>> _reports = List.generate(
    5,
    (index) => {
      'id': index,
      'title': index % 2 == 0 ? 'Gia sư không đến dạy đúng giờ' : 'Học viên spam tin nhắn',
      'user': index % 2 == 0 ? 'Phụ huynh A' : 'Gia sư B',
      'time': '${index + 1} giờ trước',
      'status': 'pending',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Khiếu nại'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _reports.isEmpty 
          ? const Center(child: Text("Không có báo cáo nào cần xử lý."))
          : ListView.builder(
              itemCount: _reports.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Dismissible(
                  key: ValueKey(report['id']),
                  onDismissed: (direction) {
                    setState(() {
                      _reports.removeAt(index);
                    });
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã ẩn báo cáo.')));
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              Text('Report #${report['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(report['time'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(report['title'], style: const TextStyle(fontSize: 16)),
                          Text('Báo cáo bởi: ${report['user']}', style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                   setState(() {
                                    _reports.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bỏ qua.')));
                                },
                                child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _reports.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã giải quyết khiếu nại.')));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                child: const Text('Giải quyết'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
