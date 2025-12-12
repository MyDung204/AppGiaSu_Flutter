import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';

class AdminTutorApprovalScreen extends StatefulWidget {
  const AdminTutorApprovalScreen({super.key});

  @override
  State<AdminTutorApprovalScreen> createState() => _AdminTutorApprovalScreenState();
}

class _AdminTutorApprovalScreenState extends State<AdminTutorApprovalScreen> {
  // Mock data for pending tutors
  final List<Tutor> _pendingTutors = List.generate(
    5,
    (index) => Tutor(
      id: 'pending_$index',
      name: 'Gia sư Chờ Duyệt ${index + 1}',
      avatarUrl: 'https://i.pravatar.cc/150?u=pending_$index',
      bio: 'Tôi là sinh viên năm cuối ĐH Sư Phạm...',
      hourlyRate: 150000,
      subjects: ['Toán', 'Lý'],
      rating: 0,
      reviewCount: 0,
      location: 'Hà Nội',
      isVerified: false,
      gender: 'Nam',
      teachingMode: ['Online'],
      address: '123 Đường ABC, Hà Nội',
      weeklySchedule: const {'2': ['08:00 - 10:00']}, // Mock schedule
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Phê duyệt Gia sư'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _pendingTutors.isEmpty
          ? const Center(child: Text('Không có yêu cầu nào đang chờ.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingTutors.length,
              itemBuilder: (context, index) {
                final tutor = _pendingTutors[index];
                return Dismissible(
                  key: Key(tutor.id),
                  background: _buildSwipeAction(Colors.green, Icons.check, Alignment.centerLeft),
                  secondaryBackground: _buildSwipeAction(Colors.red, Icons.close, Alignment.centerRight),
                  onDismissed: (direction) {
                    setState(() {
                      _pendingTutors.removeAt(index);
                    });
                    final action = direction == DismissDirection.startToEnd ? 'Đã duyệt' : 'Đã từ chối';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action ${tutor.name}')));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(tutor.avatarUrl),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tutor.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tutor.subjects.join(', '),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(tutor.location),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.close, color: Colors.red),
                                label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  setState(() {
                                    _pendingTutors.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã từ chối ${tutor.name}')),
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Duyệt ngay'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                   setState(() {
                                    _pendingTutors.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã duyệt ${tutor.name}')),
                                  );
                                },
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

  Widget _buildSwipeAction(Color color, IconData icon, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
