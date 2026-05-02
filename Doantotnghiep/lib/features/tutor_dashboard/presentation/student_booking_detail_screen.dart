import 'package:doantotnghiep/features/tutor_dashboard/presentation/widgets/class_materials_tab.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/widgets/class_quiz_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/features/auth/domain/models/app_user.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';

class _EduTheme {
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}

class StudentBookingDetailScreen extends ConsumerWidget {
  final AppUser student;
  final List<BookingItem> initialBookings;
  
  const StudentBookingDetailScreen({
    super.key,
    required this.student,
    this.initialBookings = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingProvider);
    final studentBookingsFromRoute = initialBookings
        .where((b) => b.student?.id == student.id || b.userId == student.id)
        .toList();
    final hasInitialBookings = studentBookingsFromRoute.isNotEmpty;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _EduTheme.background,
        appBar: AppBar(
          title: const Text('Chi tiết dạy kèm 1-1', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: _EduTheme.textPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            labelColor: _EduTheme.primary,
            unselectedLabelColor: _EduTheme.textSecondary,
            indicatorColor: _EduTheme.primary,
            tabs: [
              Tab(text: 'Lịch học'),
              Tab(text: 'Tài liệu'),
              Tab(text: 'Trắc nghiệm'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Bookings List
            hasInitialBookings
                ? _buildBookingsTab(context, ref, studentBookingsFromRoute)
                : bookingsAsync.when(
              data: (bookings) {
                final studentBookings = bookings
                    .where((b) => b.student?.id == student.id || b.userId == student.id)
                    .toList();

                if (studentBookings.isEmpty) {
                  return const Center(child: Text('Không tìm thấy lịch học'));
                }

                return _buildBookingsTab(context, ref, studentBookings);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
            
            // Tab 2: Materials
            ClassMaterialsTab(
              studentId: int.tryParse(student.id.toString()),
              isTutor: true,
            ),
            
            // Tab 3: Quizzes
            ClassQuizTab(
              studentId: int.tryParse(student.id.toString()),
              isTutor: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context, WidgetRef ref, List<BookingItem> studentBookings) {
    studentBookings.sort((a, b) => b.date.compareTo(a.date));

    final total = studentBookings.length;
    final completed = studentBookings.where((b) => b.status.toLowerCase() == 'completed').length;
    final progress = total > 0 ? completed / total : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentProfileCard(context, total, completed, progress),
          const SizedBox(height: 16),
          _buildOneToOneActions(context, ref, studentBookings),
          const SizedBox(height: 24),
          const Text(
            'Lịch sử buổi học',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _EduTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingItem(context, ref, studentBookings[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(BuildContext context, int total, int completed, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: _EduTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           Row(
             children: [
               CircleAvatar(
                 radius: 30,
                 backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                 backgroundColor: _EduTheme.primary.withValues(alpha: 0.1),
                 child: student.avatarUrl == null ? Text(student.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _EduTheme.primary)) : null,
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       student.name,
                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _EduTheme.textPrimary),
                     ),
                     const SizedBox(height: 4),
                     Text(
                       student.email,
                       style: const TextStyle(fontSize: 14, color: _EduTheme.textSecondary),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           const Divider(height: 32),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildStatItem('Tổng buổi', '$total'),
               _buildStatItem('Hoàn thành', '$completed', color: _EduTheme.success),
               _buildStatItem('Còn lại', '${total - completed}', color: _EduTheme.secondary),
             ],
           ),
           const SizedBox(height: 20),
           ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _EduTheme.background,
              valueColor: const AlwaysStoppedAnimation<Color>(_EduTheme.success),
              minHeight: 8,
            ),
           ),
           const SizedBox(height: 8),
           Align(
             alignment: Alignment.centerRight,
             child: Text('${(progress * 100).toInt()}% Hoàn thành', style: const TextStyle(fontSize: 12, color: _EduTheme.textSecondary)),
           ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? _EduTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: _EduTheme.textSecondary)),
      ],
    );
  }

  Widget _buildOneToOneActions(BuildContext context, WidgetRef ref, List<BookingItem> bookings) {
    return Container(
      decoration: BoxDecoration(
        color: _EduTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý dạy kèm 1-1',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _EduTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Áp dụng thay đổi cho tất cả buổi học sắp tới của học viên này.',
            style: TextStyle(fontSize: 13, color: _EduTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancelOneToOne(context, ref, bookings),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Hủy 1-1'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _EduTheme.error,
                    side: const BorderSide(color: _EduTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showUpdateOneToOneDialog(context, ref, bookings),
                  icon: const Icon(Icons.tune_outlined, size: 18),
                  label: const Text('Cập nhật 1-1'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _EduTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BookingItem> _getUpcomingBookings(List<BookingItem> bookings) {
    final upcoming = bookings.where(_isUpcomingBooking).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  bool _isUpcomingBooking(BookingItem booking) {
    final status = booking.status.toLowerCase();
    return status == 'upcoming' || status == 'confirmed' || status == 'locked' || status == 'pending';
  }

  Widget _buildBookingItem(BuildContext context, WidgetRef ref, BookingItem booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusText = _getStatusText(booking.status);
    final status = booking.status.toLowerCase();
    final isUpcoming = _isUpcomingBooking(booking);
    final canUpdate = status != 'cancelled';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _EduTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.class_outlined, color: statusColor, size: 24),
          ),
          title: Text(
            DateFormat('dd/MM/yyyy - HH:mm').format(booking.date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: statusColor.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(4),
                     ),
                     child: Text(statusText, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                   ),
                   const SizedBox(width: 8),
                   if (booking.gradeLevel != null)
                   Text(booking.gradeLevel!, style: const TextStyle(fontSize: 12, color: _EduTheme.textSecondary)),
                ],
              ),
              if (canUpdate) ...[
                const SizedBox(height: 10),
                _buildBookingActions(context, ref, booking, canCancel: isUpcoming),
              ],
            ],
          ),
          children: [
             Padding(
               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Divider(),
                   ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: Icon(
                       booking.learningMode == 'offline' ? Icons.location_on_outlined : Icons.videocam_outlined,
                       color: _EduTheme.primary,
                     ),
                     title: const Text('Cách học', style: TextStyle(fontSize: 14)),
                     subtitle: Text(
                       booking.learningMode == 'offline'
                           ? 'Offline${(booking.address ?? '').isNotEmpty ? ' - ${booking.address}' : ''}'
                           : 'Online',
                     ),
                   ),

                   if ((booking.meetingLink ?? '').isNotEmpty)
                     ListTile(
                       contentPadding: EdgeInsets.zero,
                       leading: const Icon(Icons.link, color: Colors.blue),
                       title: const Text('Link học', style: TextStyle(fontSize: 14)),
                       subtitle: Text(booking.meetingLink!, style: const TextStyle(color: Colors.blue)),
                       onTap: () {
                         // Launch URL logic
                       },
                     ),
                    
                   if ((booking.tutorFeedback ?? '').isNotEmpty) ...[
                      const Text('Đánh giá của bạn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(booking.tutorFeedback!, style: const TextStyle(color: _EduTheme.textSecondary, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 12),
                   ],

                   if (isUpcoming) 
                   Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                      TextButton(
                        onPressed: () => _confirmCancelBooking(context, ref, booking),
                         child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                       ),
                       const SizedBox(width: 8),
                       ElevatedButton(
                         onPressed: () {
                            _showUpdateSessionDialog(context, ref, booking);
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: _EduTheme.primary,
                           foregroundColor: Colors.white,
                         ),
                         child: const Text('Cập nhật'),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingActions(
    BuildContext context,
    WidgetRef ref,
    BookingItem booking, {
    required bool canCancel,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (canCancel)
          OutlinedButton.icon(
            onPressed: () => _confirmCancelBooking(context, ref, booking),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Hủy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _EduTheme.error,
              side: const BorderSide(color: _EduTheme.error),
              visualDensity: VisualDensity.compact,
            ),
          ),
        FilledButton.icon(
          onPressed: () => _showUpdateSessionDialog(context, ref, booking),
          icon: const Icon(Icons.edit_calendar_outlined, size: 16),
          label: const Text('Cập nhật'),
          style: FilledButton.styleFrom(
            backgroundColor: _EduTheme.primary,
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'confirmed': return _EduTheme.primary;
      case 'completed': return _EduTheme.success;
      case 'cancelled': return _EduTheme.error;
      case 'locked':
      case 'pending': return _EduTheme.secondary;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'confirmed': return 'Sắp tới';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'locked':
      case 'pending': return 'Chờ xác nhận';
      default: return status;
    }
  }

  Future<void> _confirmCancelOneToOne(BuildContext context, WidgetRef ref, List<BookingItem> bookings) async {
    final upcomingBookings = _getUpcomingBookings(bookings);
    if (upcomingBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có buổi 1-1 sắp tới để hủy')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy dạy kèm 1-1'),
        content: Text('Hủy ${upcomingBookings.length} buổi học sắp tới của học viên này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy 1-1', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    var successCount = 0;
    final notifier = ref.read(bookingProvider.notifier);
    for (final booking in upcomingBookings) {
      final success = await notifier.cancelBooking(booking.id);
      if (success) successCount++;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã hủy $successCount/${upcomingBookings.length} buổi 1-1 sắp tới'),
          backgroundColor: successCount == upcomingBookings.length ? _EduTheme.success : _EduTheme.error,
        ),
      );
    }
  }

  void _showUpdateOneToOneDialog(BuildContext context, WidgetRef ref, List<BookingItem> bookings) {
    final upcomingBookings = _getUpcomingBookings(bookings);
    if (upcomingBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có buổi 1-1 sắp tới để cập nhật')),
      );
      return;
    }

    final firstBooking = upcomingBookings.first;
    var selectedMode = firstBooking.learningMode == 'offline' ? 'offline' : 'online';
    final linkController = TextEditingController(text: firstBooking.meetingLink ?? '');
    final addressController = TextEditingController(text: firstBooking.address ?? '');
    final noteController = TextEditingController(text: firstBooking.tutorFeedback ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Cập nhật dạy kèm 1-1'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Áp dụng cho ${upcomingBookings.length} buổi học sắp tới.',
                  style: const TextStyle(color: _EduTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMode,
                  decoration: const InputDecoration(
                    labelText: 'Cách học',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'online', child: Text('Online')),
                    DropdownMenuItem(value: 'offline', child: Text('Offline')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMode = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (selectedMode == 'online')
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      labelText: 'Link phòng học',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                  )
                else
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ học offline',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú cho học viên',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final notifier = ref.read(bookingProvider.notifier);
                var successCount = 0;

                for (final booking in upcomingBookings) {
                  try {
                    await notifier.updateSessionInfo(
                      booking.id,
                      learningMode: selectedMode,
                      meetingLink: selectedMode == 'online' ? linkController.text.trim() : '',
                      address: selectedMode == 'offline' ? addressController.text.trim() : '',
                      tutorFeedback: noteController.text.trim(),
                    );
                    successCount++;
                  } catch (_) {
                    // Continue the batch and report partial success after the loop.
                  }
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật $successCount/${upcomingBookings.length} buổi 1-1 sắp tới'),
                      backgroundColor: successCount == upcomingBookings.length ? _EduTheme.success : _EduTheme.error,
                    ),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancelBooking(BuildContext context, WidgetRef ref, BookingItem booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy lịch dạy 1-1'),
        content: const Text('Bạn có chắc muốn hủy buổi dạy kèm 1-1 này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy lịch', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ref.read(bookingProvider.notifier).cancelBooking(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã hủy lịch dạy 1-1' : 'Hủy lịch thất bại'),
            backgroundColor: success ? _EduTheme.success : _EduTheme.error,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hủy lịch thất bại'), backgroundColor: _EduTheme.error),
        );
      }
    }
  }

  void _showUpdateSessionDialog(BuildContext context, WidgetRef ref, BookingItem booking) {
    final linkController = TextEditingController(text: booking.meetingLink);
    final noteController = TextEditingController(text: booking.tutorFeedback);
    bool markCompleted = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Cập nhật buổi học'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Link phòng học (Google Meet/Zoom)',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú / Đánh giá',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                 title: const Text('Đánh dấu đã hoàn thành'),
                 value: markCompleted,
                 onChanged: (val) => setState(() => markCompleted = val!),
                 contentPadding: EdgeInsets.zero,
                 activeColor: _EduTheme.success,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                 Navigator.pop(ctx);
                 final notifier = ref.read(bookingProvider.notifier);
                 await notifier.updateSessionInfo(
                   booking.id, 
                   meetingLink: linkController.text,
                   tutorFeedback: noteController.text,
                   completed: markCompleted
                 );
              }, 
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
