/// My Classes Screen
/// 
/// **Purpose:**
/// - Hiển thị danh sách các lớp học mà học viên đã đăng ký
/// - Cho phép học viên xem chi tiết lớp học và rời lớp nếu cần
/// 
/// **Features:**
/// - Xem danh sách lớp đã đăng ký
/// - Xem chi tiết lớp học (giảng viên, lịch học, học phí, v.v.)
/// - Refresh danh sách
/// 
/// **Data Flow:**
/// - Fetches from `/my-courses` API endpoint
/// - Displays empty state if no courses
/// - Navigates to detail screen on tap

import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Provider để lấy danh sách lớp học của học viên
/// 
/// **Purpose:**
/// - Tự động fetch danh sách lớp học từ API
/// - Auto-dispose khi không còn sử dụng (tiết kiệm memory)
/// - Refresh khi cần thiết
final myCoursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  return ref.watch(sharedLearningRepositoryProvider).getMyCourses();
});

/// Màn hình hiển thị các lớp học của học viên
/// 
/// **Usage:**
/// - Truy cập từ Profile Screen → "Lớp học của tôi" (nếu có)
/// - Hoặc từ Search Screen → Tab "Lớp học" → "Lớp của tôi"
/// - Hiển thị tất cả lớp học mà user đã đăng ký
class MyClassesScreen extends ConsumerWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(myCoursesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text('Lớp học của tôi')),
      body: coursesAsync.when(
        data: (courses) {
           // Empty state: Hiển thị khi chưa tham gia lớp nào
           if (courses.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade300),
                   const SizedBox(height: 16),
                   const Text(
                     'Bạn chưa tham gia lớp học nào.',
                     style: TextStyle(fontSize: 16, color: Colors.grey),
                   ),
                   const SizedBox(height: 24),
                   ElevatedButton.icon(
                     onPressed: () => context.push('/search'),
                     icon: const Icon(Icons.search),
                     label: const Text('Tìm lớp học'),
                     style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                     ),
                   ),
                 ],
               ),
             );
           }
           
           // List view: Hiển thị danh sách lớp học
           return RefreshIndicator(
             onRefresh: () async {
               ref.invalidate(myCoursesProvider);
             },
             child: ListView.builder(
               padding: const EdgeInsets.all(16),
               itemCount: courses.length,
               itemBuilder: (context, index) {
                  final course = courses[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.push('/class-detail', extra: course).then((_) {
                          // Refresh list when coming back from detail screen
                          ref.refresh(myCoursesProvider);
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'GV: ${course.tutorName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    course.schedule,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 4),
                                Text(
                                  currencyFormat.format(course.price),
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
               },
             ),
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
