/// Tutor Dashboard Screen
/// 
/// **Purpose:**
/// - Màn hình tổng quan cho gia sư
/// - Hiển thị thu nhập, lớp học đang mở, và yêu cầu tìm gia sư
/// 
/// **Features:**
/// - Thu nhập tháng này: Hiển thị tổng thu nhập và số giờ dạy
/// - Quick Actions: Tạo lớp 1-1 hoặc lớp nhóm
/// - Lớp học đang mở: Danh sách các lớp học đã tạo (tối đa 3 lớp)
/// - Học viên đang tìm lớp: Danh sách yêu cầu tìm gia sư (tối đa 3 yêu cầu)
/// 
/// **Navigation:**
/// - Click vào lớp học → Xem chi tiết lớp
/// - Click "Xem tất cả" → Xem danh sách đầy đủ yêu cầu
/// - Click "Mở lớp 1-1" / "Mở lớp nhóm" → Tạo lớp học mới

import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_class_provider.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Màn hình dashboard của gia sư
/// 
/// **Usage:**
/// - Truy cập từ tutor navigation → "Tổng quan"
/// - Hiển thị thống kê và danh sách lớp học, yêu cầu
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6C5CE7).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thu nhập tháng này', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '0 đ',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildIncomeBadge(Icons.trending_up, 'Tăng trưởng 0%', Colors.greenAccent),
                      const SizedBox(width: 12),
                      _buildIncomeBadge(Icons.access_time, '0 giờ dạy', Colors.white70),
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
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Mở lớp 1-1'),
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
                     context.push(Uri(path: '/create-class', queryParameters: {'isGroup': 'true'}).toString());
                    },
                    icon: const Icon(Icons.groups_outlined),
                    label: const Text('Mở lớp nhóm'),
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
                // Empty state: Hiển thị khi chưa có lớp học
                if (classes.isEmpty) {
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.class_outlined, size: 48, color: Colors.grey[300]),
                           const SizedBox(height: 8),
                           const Text(
                             "Chưa có lớp học nào.",
                             style: TextStyle(color: Colors.grey, fontSize: 16),
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton.icon(
                             onPressed: () => context.push('/create-class'),
                             icon: const Icon(Icons.add),
                             label: const Text('Tạo lớp học đầu tiên'),
                           ),
                         ],
                       ),
                     ),
                   );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classes.take(3).length, 
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    return GestureDetector(
                      onTap: () => context.push('/class-detail', extra: cls),
                      child: Container(
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
                                  Text(cls.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                              child: Text('${cls.students.length} HV', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            )
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
                // Empty state: Hiển thị khi chưa có yêu cầu
                if (requests.isEmpty) {
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                           const SizedBox(height: 8),
                           const Text(
                             "Chưa có yêu cầu nào.",
                             style: TextStyle(color: Colors.grey, fontSize: 16),
                           ),
                         ],
                       ),
                     ),
                   );
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

  /// Build income badge widget
  /// 
  /// **Purpose:**
  /// - Hiển thị badge trong income card (tăng trưởng, số giờ dạy)
  /// - Sử dụng trong income card để hiển thị thông tin phụ
  /// 
  /// **Parameters:**
  /// - `icon`: Icon hiển thị
  /// - `text`: Text hiển thị
  /// - `color`: Màu của icon
  Widget _buildIncomeBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
