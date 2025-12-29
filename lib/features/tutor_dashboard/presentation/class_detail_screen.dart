import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/group/data/course_provider.dart';
import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends ConsumerWidget {
  final Course course;

  const ClassDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final isTutor = user?.role == 'tutor' && user?.id == course.tutorId;
    // Sử dụng isEnrolled từ Course model (đã được set từ API)
    final isEnrolled = course.isEnrolled;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết lớp học'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isTutor) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                 context.push('/create-class', extra: course);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ] else if (isEnrolled) ...[
            TextButton.icon(
              onPressed: () => _confirmLeave(context, ref),
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text('Rời lớp', style: TextStyle(color: Colors.red)),
            ),
          ] else if (user?.role == 'student' && !isEnrolled) ...[
             // Only students can register
             FilledButton(
               onPressed: () => _confirmJoin(context, ref), 
               child: const Text("Đăng ký ngay")
             ),
          ],
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
                          course.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: course.status == 'open' ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                course.status == 'open' ? 'Đang tuyển' : 'Đã đóng',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.mode,
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
            _buildInfoRow(Icons.calendar_today, "Ngày bắt đầu", DateFormat('dd/MM/yyyy').format(course.startDate)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.schedule, "Lịch học", course.schedule),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, "Địa điểm", course.address ?? "Online"),
             const SizedBox(height: 12),
             _buildInfoRow(Icons.book, "Môn học", "${course.subject} - ${course.gradeLevel}"),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money, "Học phí", currencyFormat.format(course.price)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people, "Học viên", "${course.students.length} / ${course.maxStudents}"),
            if (isTutor) ...[
              const SizedBox(height: 12),
               _buildInfoRow(Icons.monetization_on_outlined, "Doanh thu dự kiến", currencyFormat.format(course.price * course.students.length)),
            ],

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
                 course.description.isNotEmpty ? course.description : "Chưa có mô tả chi tiết.",
                 style: const TextStyle(color: Colors.black87, height: 1.4),
               ),
             ),
             
             const SizedBox(height: 24),
             if (course.students.isNotEmpty) ...[
               Text("Danh sách học viên (${course.students.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 8),
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: course.students.length,
                 itemBuilder: (context, index) {
                   final s = course.students[index];
                   return ListTile(
                     leading: const CircleAvatar(child: Icon(Icons.person)),
                     title: Text(s['name'] ?? 'Học viên'),
                     subtitle: Text('ID: ${s['id']}'),
                     trailing: isTutor 
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _confirmKick(context, ref, s['id'].toString(), s['name'] ?? ''),
                          )
                        : null,
                   );
                 },
               )
             ]
          ],
        ),
      ),
    );
  }

  /// Build info row widget
  /// 
  /// **Purpose:**
  /// - Hiển thị một dòng thông tin với icon, label và value
  /// - Sử dụng trong phần "Thông tin chi tiết"
  /// 
  /// **Parameters:**
  /// - `icon`: Icon hiển thị bên trái
  /// - `label`: Label text (màu xám, nhỏ)
  /// - `value`: Value text (màu đen, đậm)
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

  /// Xác nhận xóa lớp học
  /// 
  /// **Purpose:**
  /// - Hiển thị dialog xác nhận trước khi xóa lớp
  /// - Chỉ gia sư (chủ lớp) mới có thể xóa
  /// - Gọi API để xóa lớp và refresh danh sách
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext để hiển thị dialog
  /// - `ref`: WidgetRef để truy cập providers
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đóng lớp'),
        content: const Text('Bạn có chắc muốn đóng/hủy lớp học này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
               ctx.pop(); 
               final success = await ref.read(sharedLearningRepositoryProvider).deleteCourse(course.id);
               if (context.mounted) {
                   if (success) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa lớp học thành công")));
                       ref.invalidate(coursesProvider);
                       context.pop(); 
                   } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa lớp")));
                   }
               }
            }, 
            child: const Text('Đồng ý', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rời lớp học'),
        content: const Text('Bạn có chắc muốn hủy đăng ký lớp học này không?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
               ctx.pop(); 
               final success = await ref.read(sharedLearningRepositoryProvider).leaveCourse(course.id);
               if (context.mounted) {
                   if (success) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã rời lớp học")));
                       ref.invalidate(coursesProvider);
                       context.pop(); 
                   } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi rời lớp")));
                   }
               }
            }, 
            child: const Text('Rời lớp', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  /// Xác nhận xóa học viên khỏi lớp
  /// 
  /// **Purpose:**
  /// - Hiển thị dialog xác nhận trước khi xóa học viên
  /// - Chỉ gia sư (chủ lớp) mới có thể xóa học viên
  /// - Gọi API để xóa học viên và refresh danh sách
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext để hiển thị dialog
  /// - `ref`: WidgetRef để truy cập providers
  /// - `studentId`: ID của học viên cần xóa
  /// - `studentName`: Tên của học viên (để hiển thị trong dialog)
  void _confirmKick(BuildContext context, WidgetRef ref, String studentId, String studentName) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa học viên'),
        content: Text('Xóa học viên $studentName khỏi lớp?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
               ctx.pop(); 
               final success = await ref.read(sharedLearningRepositoryProvider).removeStudentFromCourse(course.id, studentId);
               if (context.mounted) {
                   if (success) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa học viên")));
                       ref.invalidate(coursesProvider);
                       // Can't simple refresh current screen because it takes course from prop. 
                       // Should pop or refresh the course detail if it was fetched via ID.
                       // Here we passed object, so it will be stale.
                       // Ideally ClassDetail should fetch fresh data or we close it.
                       context.pop();
                   } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa học viên")));
                   }
               }
            }, 
            child: const Text('Xóa', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _confirmJoin(BuildContext context, WidgetRef ref) {
     final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text('Xác nhận đăng ký'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text('Bạn đang đăng ký tham gia lớp:', style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 8),
             Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const Divider(height: 24),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween, 
               children: [
                 const Text('Học phí:'),
                 Text(currencyFormat.format(course.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
               ]
             ),
             const SizedBox(height: 8),
             Text('Lịch học: ${course.schedule}'),
             const SizedBox(height: 16),
             Row(
               children: [
                 const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                 const SizedBox(width: 6),
                 Expanded(
                   child: Text(
                     'Vui lòng liên hệ gia sư để hoàn tất học phí.', 
                     style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic)
                   ),
                 ),
               ],
             ),
           ],
         ),
         actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
            FilledButton(
               onPressed: () async {
                   ctx.pop();
                   final success = await ref.read(sharedLearningRepositoryProvider).joinCourse(course.id);
                   if (context.mounted) {
                       if (success) {
                          _showSuccessDialog(context, ref);
                       } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thất bại hoặc bạn đã tham gia.')));
                       }
                   }
               },
               child: const Text('Xác nhận đăng ký'),
            )
         ],
       ),
     );
  }

  void _showSuccessDialog(BuildContext context, WidgetRef ref) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               const Icon(Icons.check_circle, color: Colors.green, size: 60),
               const SizedBox(height: 16),
               const Text('Đăng ký thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               const Text('Bạn có thể xem lớp học trong mục "Lớp của tôi".', textAlign: TextAlign.center),
             ],
           ),
           actions: [
              TextButton(onPressed: () {
                  ctx.pop();
                  ref.invalidate(coursesProvider);
                  // Refresh current screen or pop? 
                  // If we pop, we go back to list.
                  context.pop(); 
              }, child: const Text('Đóng'))
           ],
        )
      );
  }
}
