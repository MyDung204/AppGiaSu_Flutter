import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_class_provider.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TutorDashboardScreen extends ConsumerWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(tutorClassProvider);
    final requestsAsync = ref.watch(tutorRequestsProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('Xin chào, Gia sư!', style: TextStyle(fontSize: 14, color: Colors.grey)),
             Text(user?.name ?? 'Gia sư', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thu nhập tháng này', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  const Text(
                    '0 đ',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildIncomeBadge(Icons.trending_up, 'Chưa có dữ liệu'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       context.push('/create-class');
                    },
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Mở lớp học'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      elevation: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                 Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       context.push('/create-group');
                    },
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('Tạo nhóm'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                       backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upcoming Classes
            const Text('Lớp học đang mở', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            classesAsync.when(
              data: (classes) {
                if (classes.isEmpty) {
                   return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Chưa có lớp học nào.", style: TextStyle(color: Colors.grey))));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classes.take(3).length, 
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 50, width: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(child: Icon(Icons.class_outlined, color: Colors.blue)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(cls.schedule, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${cls.enrolledStudentCount} HV', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            
            const SizedBox(height: 30),
             // Pending Requests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Học viên đang tìm lớp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.go('/tutor-dashboard/find-students'), 
                  child: const Text('Xem tất cả')
                ),
              ],
            ),
            const SizedBox(height: 10),
            requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                   return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Chưa có yêu cầu nào.", style: TextStyle(color: Colors.grey))));
                }
                final displayRequests = requests.take(3).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayRequests.length,
                  itemBuilder: (context, index) {
                    final req = displayRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.orange)),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Học viên muốn tìm gia sư ${req.subject} (${req.gradeLevel})', style: const TextStyle(fontWeight: FontWeight.w500))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(req.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
