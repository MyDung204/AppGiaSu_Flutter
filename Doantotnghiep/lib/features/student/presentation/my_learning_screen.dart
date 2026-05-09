import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:doantotnghiep/features/rating/data/review_repository.dart';
import 'package:doantotnghiep/features/rating/presentation/review_modal.dart';
import 'package:doantotnghiep/features/student/presentation/my_enrolled_classes_screen.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneToOneLearningGroup {
  final Tutor tutor;
  final List<BookingItem> bookings;

  const OneToOneLearningGroup({
    required this.tutor,
    required this.bookings,
  });

  BookingItem? get nextBooking {
    final upcoming = bookings.where((booking) {
      final status = booking.status.toLowerCase();
      return status == 'upcoming' || status == 'locked' || status == 'pending';
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  int get completedCount => bookings.where((booking) => booking.status.toLowerCase() == 'completed').length;

  bool get isCompleted {
    final activeBookings = bookings.where((booking) {
      final status = booking.status.toLowerCase();
      return status != 'cancelled' && status != 'canceled';
    }).toList();

    return activeBookings.isNotEmpty &&
        activeBookings.every((booking) {
          final status = booking.status.toLowerCase();
          return status == 'completed' || status == 'finished';
        });
  }

  String get completionAckKey {
    final bookingIds = bookings.map((booking) => booking.id).toList()..sort();
    return 'one_to_one_completion_ack_${tutor.id}_${bookingIds.join('_')}';
  }
}

class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduTheme.background,
      appBar: AppBar(
        title: const Text('Học tập của tôi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dạy kèm 1-1'),
            Tab(text: 'Lớp nhóm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OneToOneLearningTab(),
          _GroupLearningTab(),
        ],
      ),
    );
  }
}

class _OneToOneLearningTab extends ConsumerStatefulWidget {
  const _OneToOneLearningTab();

  @override
  ConsumerState<_OneToOneLearningTab> createState() => _OneToOneLearningTabState();
}

class _OneToOneLearningTabState extends ConsumerState<_OneToOneLearningTab> {
  static const _ackPrefsKey = 'student_acknowledged_completed_one_to_one';
  Set<String> _acknowledgedCompletionKeys = {};

  @override
  void initState() {
    super.initState();
    _loadAcknowledgedCompletions();
  }

  Future<void> _loadAcknowledgedCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_ackPrefsKey) ?? const [];
    if (mounted) {
      setState(() => _acknowledgedCompletionKeys = keys.toSet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(bookingProvider.future);
      },
      child: bookingsAsync.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(child: Text('Lỗi tải danh sách 1-1: $error')),
            ),
          ],
        ),
        data: (bookings) {
          final groups = _groupByTutor(bookings)
              .where((group) =>
                  !group.isCompleted ||
                  !_acknowledgedCompletionKeys.contains(group.completionAckKey))
              .toList();

          if (groups.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Bạn chưa có gia sư 1-1 nào',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Các gia sư bạn đã đặt lịch 1-1 sẽ hiển thị tại đây.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => context.push('/search'),
                            icon: const Icon(Icons.person_search_outlined),
                            label: const Text('Tìm gia sư'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OneToOneTutorCard(
              group: groups[index],
              onTap: () => _handleGroupTap(groups[index]),
            ),
          );
        },
      ),
    );
  }

  List<OneToOneLearningGroup> _groupByTutor(List<BookingItem> bookings) {
    final filtered = bookings.where((booking) {
      final status = booking.status.toLowerCase();
      return status != 'cancelled';
    }).toList();

    final grouped = <String, List<BookingItem>>{};
    for (final booking in filtered) {
      grouped.putIfAbsent(booking.tutor.id, () => []).add(booking);
    }

    final result = grouped.values.map((items) {
      items.sort((a, b) => a.date.compareTo(b.date));
      return OneToOneLearningGroup(tutor: items.first.tutor, bookings: items);
    }).toList();

    result.sort((a, b) {
      final aNext = a.nextBooking?.date ?? DateTime(2100);
      final bNext = b.nextBooking?.date ?? DateTime(2100);
      return aNext.compareTo(bNext);
    });

    return result;
  }

  Future<void> _handleGroupTap(OneToOneLearningGroup group) async {
    if (!group.isCompleted) {
      context.push('/student-one-to-one-detail', extra: group);
      return;
    }

    final action = await showDialog<_CompletedCourseAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Khóa học đã hoàn thành'),
        content: const Text(
          'Khóa học 1-1 đã hoàn thành. Vui lòng đánh giá gia sư hoặc bỏ qua để ẩn khóa học khỏi danh sách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _CompletedCourseAction.skip),
            child: const Text('Bỏ qua'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, _CompletedCourseAction.review),
            child: const Text('Đánh giá'),
          ),
        ],
      ),
    );

    if (action == null) return;

    if (action == _CompletedCourseAction.review) {
      final submitted = await _submitReview(group);
      if (!submitted) return;
    }

    await _acknowledgeCompletion(group.completionAckKey);
  }

  Future<bool> _submitReview(OneToOneLearningGroup group) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const ReviewModal(),
    );

    if (result == null) return false;

    final rating = (result['rating'] as num?)?.round() ?? 5;

    try {
      await ref.read(reviewRepositoryProvider).submitTutorReview(
            group.tutor.id,
            rating: rating,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đánh giá gia sư.')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không gửi được đánh giá: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _acknowledgeCompletion(String key) async {
    final updated = {..._acknowledgedCompletionKeys, key};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ackPrefsKey, updated.toList());
    if (mounted) {
      setState(() => _acknowledgedCompletionKeys = updated);
    }
  }
}

enum _CompletedCourseAction { review, skip }

class _OneToOneTutorCard extends StatelessWidget {
  final OneToOneLearningGroup group;
  final VoidCallback onTap;

  const _OneToOneTutorCard({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final next = group.nextBooking;
    final subject = group.tutor.subjects.isNotEmpty ? group.tutor.subjects.first : 'Dạy kèm 1-1';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: EduTheme.primary.withOpacity(0.1),
                backgroundImage: group.tutor.avatarUrl.isNotEmpty ? NetworkImage(group.tutor.avatarUrl) : null,
                child: group.tutor.avatarUrl.isEmpty ? const Icon(Icons.person, color: EduTheme.primary) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.tutor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(subject, style: const TextStyle(color: EduTheme.textSecondary)),
                    if (group.isCompleted) ...[
                      const SizedBox(height: 8),
                      const _CompletedChip(),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      group.isCompleted
                          ? 'Khóa học đã hoàn thành'
                          : next == null
                              ? 'Đã học ${group.completedCount}/${group.bookings.length} buổi'
                              : 'Buổi tới: ${DateFormat('dd/MM').format(next.date)}, ${next.timeSlot}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: EduTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: EduTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  const _CompletedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: EduTheme.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Đã hoàn thành',
        style: TextStyle(
          color: EduTheme.success,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GroupLearningTab extends ConsumerWidget {
  const _GroupLearningTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(myEnrolledCoursesProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(myEnrolledCoursesProvider.future);
      },
      child: coursesAsync.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(child: Text('Lỗi tải lớp nhóm: $error')),
            ),
          ],
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa tham gia lớp nhóm nào',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => context.push('/search?tab=classes'),
                          icon: const Icon(Icons.search),
                          label: const Text('Tìm lớp nhóm'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CourseCard(
              course: courses[index],
              currencyFormat: currencyFormat,
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final NumberFormat currencyFormat;

  const _CourseCard({required this.course, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/class-detail', extra: course),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.groups, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${course.subject} - ${course.gradeLevel}',
                          style: const TextStyle(color: EduTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: EduTheme.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: EduTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd/MM/yyyy').format(course.startDate)),
                  const Spacer(),
                  Text(
                    currencyFormat.format(course.price),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
