import 'package:doantotnghiep/core/config/jitsi_config.dart';
import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/rating/data/review_repository.dart';
import 'package:doantotnghiep/features/rating/domain/models/review.dart';
import 'package:doantotnghiep/features/student/presentation/my_learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final studentTutorReviewStatusProvider =
    FutureProvider.autoDispose.family<ReviewStatus, String>((ref, tutorId) {
  return ref.watch(reviewRepositoryProvider).getMyReviewStatus(tutorId);
});

class StudentOneToOneDetailScreen extends ConsumerWidget {
  final OneToOneLearningGroup group;

  const StudentOneToOneDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = [...group.bookings]
      ..sort((a, b) => a.date.compareTo(b.date));
    final monthBookings = bookings.where(_isInCurrentMonth).toList();
    final joinableBookings = monthBookings.where(_canJoinBooking).toList();
    final subject = group.tutor.subjects.isNotEmpty
        ? group.tutor.subjects.first
        : 'Dạy kèm 1-1';

    return Scaffold(
      backgroundColor: EduTheme.background,
      appBar: AppBar(title: const Text('Chi tiết dạy kèm 1-1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TutorHeader(group: group, subject: subject),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/chat', extra: group.tutor),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Nhắn tin'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: joinableBookings.isEmpty
                      ? null
                      : () => _openUpcomingClass(context, joinableBookings.first),
                  icon: const Icon(Icons.video_camera_front_outlined),
                  label: const Text('Vào học'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatsRow(total: monthBookings.length, joinable: joinableBookings.length),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch học 1-1 trong tháng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                DateFormat('MM/yyyy').format(DateTime.now()),
                style: const TextStyle(color: EduTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (monthBookings.isEmpty)
            const _EmptyCard(text: 'Không có buổi học nào trong tháng này.')
          else
            ...monthBookings.map((booking) => _BookingTile(
                  booking: booking,
                  onJoin: _canJoinBooking(booking)
                      ? () => _openUpcomingClass(context, booking)
                      : null,
                )),
          const SizedBox(height: 10),
          _ReviewCard(tutorId: group.tutor.id),
        ],
      ),
    );
  }

  static bool _isInCurrentMonth(BookingItem booking) {
    final now = DateTime.now();
    return booking.date.year == now.year && booking.date.month == now.month;
  }

  static bool _canJoinBooking(BookingItem booking) {
    if (booking.learningMode.toLowerCase() != 'online') return false;
    final rawStatus = booking.status.toLowerCase();
    if (rawStatus == 'cancelled' ||
        rawStatus == 'canceled' ||
        rawStatus == 'completed' ||
        rawStatus == 'finished') {
      return false;
    }
    final (_, end) = _bookingDateRange(booking);
    return !DateTime.now().isAfter(end);
  }

  void _openUpcomingClass(BuildContext context, BookingItem booking) {
    var meetingLink = booking.meetingLink ?? '';
    if (meetingLink.isEmpty || !_isValidAppJitsiUrl(meetingLink)) {
      meetingLink = _buildOneToOneMeetingUrl(booking);
    }

    context.push('/video-call', extra: {
      'bookingId': booking.id,
      'meetingLink': meetingLink,
    });
  }

  String _buildOneToOneMeetingUrl(BookingItem booking) {
    final seed = '${booking.id}-${booking.userId}-${booking.tutor.id}';
    final hash = seed.hashCode.abs().toRadixString(36);
    return JitsiConfig.buildMeetingUrl('AppGiaSuV2-${booking.id}-$hash');
  }

  bool _isValidAppJitsiUrl(String url) {
    return url.contains('AppGiaSuV2-');
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  final String tutorId;

  const _ReviewCard({required this.tutorId});

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(studentTutorReviewStatusProvider(widget.tutorId));

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        if (status.hasReview) {
          return _ReviewSubmittedCard(review: status.review);
        }

        if (!status.canReview) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đánh giá gia sư',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bạn có thể đánh giá sau khi toàn bộ lịch học 1-1 đã kết thúc. Gia sư chỉ thấy số sao và nhận xét, không thấy danh tính người đánh giá.',
                style: TextStyle(color: EduTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _submitting ? null : () => setState(() => _rating = value),
                    icon: Icon(
                      value <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Nhận xét thêm (không bắt buộc)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('Gửi đánh giá'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(reviewRepositoryProvider).submitTutorReview(
            widget.tutorId,
            rating: _rating,
            comment: _commentController.text,
          );
      ref.invalidate(studentTutorReviewStatusProvider(widget.tutorId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đánh giá gia sư.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không gửi được đánh giá: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _ReviewSubmittedCard extends StatelessWidget {
  final Review? review;

  const _ReviewSubmittedCard({this.review});

  @override
  Widget build(BuildContext context) {
    final rating = review?.rating.round() ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: EduTheme.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bạn đã đánh giá gia sư $rating/5 sao.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _bookingSessionStatus(BookingItem booking) {
  final rawStatus = booking.status.toLowerCase();
  if (rawStatus == 'cancelled' || rawStatus == 'canceled') return 'Đã hủy';
  if (rawStatus == 'completed' || rawStatus == 'finished') return 'Đã học';

  final (start, end) = _bookingDateRange(booking);
  final now = DateTime.now();
  if (now.isBefore(start)) return 'Sắp tới';
  if (now.isAfter(end)) return 'Đã học';
  return 'Đang học';
}

Color _bookingStatusColor(String status) {
  return switch (status) {
    'Đã học' => EduTheme.success,
    'Đang học' => Colors.orange,
    'Đã hủy' => EduTheme.error,
    _ => EduTheme.primary,
  };
}

(DateTime start, DateTime end) _bookingDateRange(BookingItem booking) {
  final parts = booking.timeSlot.split('-');
  final start = _dateWithTime(booking.date, parts.isNotEmpty ? parts[0] : '');
  final end = _dateWithTime(
    booking.date,
    parts.length > 1 ? parts[1] : '',
    fallback: start.add(const Duration(hours: 1)),
  );
  return (start, end);
}

DateTime _dateWithTime(DateTime date, String time, {DateTime? fallback}) {
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);
  if (match == null) return fallback ?? date;
  return DateTime(
    date.year,
    date.month,
    date.day,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
  );
}

class _TutorHeader extends StatelessWidget {
  final OneToOneLearningGroup group;
  final String subject;

  const _TutorHeader({required this.group, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: EduTheme.primary.withValues(alpha: 0.1),
            backgroundImage: group.tutor.avatarUrl.isNotEmpty
                ? NetworkImage(group.tutor.avatarUrl)
                : null,
            child: group.tutor.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: EduTheme.primary, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.tutor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subject, style: const TextStyle(color: EduTheme.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${group.tutor.rating.toStringAsFixed(1)} (${group.tutor.reviewCount})'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int joinable;

  const _StatsRow({required this.total, required this.joinable});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Buổi trong tháng', value: '$total')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Có thể vào học', value: '$joinable')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: EduTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final BookingItem booking;
  final VoidCallback? onJoin;

  const _BookingTile({
    required this.booking,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final status = _bookingSessionStatus(booking);
    final statusColor = _bookingStatusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                onJoin != null ? Icons.event_available : Icons.history,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(booking.date)}, ${booking.timeSlot}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.learningMode.toLowerCase() == 'offline'
                        ? 'Offline${(booking.address ?? '').isNotEmpty ? ' - ${booking.address}' : ''}'
                        : 'Online',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: EduTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onJoin != null)
              IconButton(
                onPressed: onJoin,
                icon: const Icon(Icons.video_camera_front, color: EduTheme.primary),
                tooltip: 'Vào học',
              )
            else
              _StatusChip(text: status, color: statusColor),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: EduTheme.textSecondary)),
      ),
    );
  }
}
