import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/rating/presentation/review_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch học'),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingList(context, ref),
            _buildHistoryList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi tải lịch học: $err')),
      data: (allBookings) {
        final bookings = allBookings.where((b) => b.status == 'Upcoming').toList();

        if (bookings.isEmpty) {
          return const Center(child: Text('Chưa có lịch học sắp tới.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(booking.date);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Sắp diễn ra', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                             _showActionSheet(context);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${booking.tutor.subjects.first} - ${booking.tutor.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                     Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$dateStr, ${booking.timeSlot}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Vào phòng học'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi tải lịch sử: $err')),
      data: (allBookings) {
        final historyBookings = allBookings.where((b) {
           final status = b.status.toLowerCase();
           return status == 'completed' || status == 'cancelled' || status == 'finished';
        }).toList();

        if (historyBookings.isEmpty) {
          return const Center(child: Text('Chưa có lịch sử buổi học.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyBookings.length,
          itemBuilder: (context, index) {
            final booking = historyBookings[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(booking.date);

            return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                booking.status.toLowerCase() == 'completed' ? 'Đã hoàn thành' : 'Đã hủy', 
                                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)
                            ),
                          ),
                          Text(currencyFormat.format(booking.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${booking.tutor.subjects.isNotEmpty ? booking.tutor.subjects.first : "Môn học"} - ${booking.tutor.name}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${booking.timeSlot}, $dateStr', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context, 
                              useRootNavigator: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                              builder: (context) => const ReviewModal()
                            );
                          },
                          icon: const Icon(Icons.star_border),
                          label: const Text('Đánh giá'),
                        ),
                      ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_problem, color: Colors.orange),
                title: const Text('Báo cáo sự cố'),
                onTap: () {
                  context.pop();
                  context.push('/report');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Hủy lịch học'),
                onTap: () {
                   context.pop();
                   // Handle cancel
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
