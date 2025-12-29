import 'package:doantotnghiep/features/booking/domain/models/booking_summary.dart';
import 'package:doantotnghiep/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Review screen before confirming booking
/// Shows booking summary and allows user to confirm or go back
class BookingReviewScreen extends ConsumerWidget {
  final Tutor tutor;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final double totalPrice;

  const BookingReviewScreen({
    super.key,
    required this.tutor,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final durationHours = 2; // Default 2 hours

    final summary = BookingSummary(
      tutor: tutor,
      date: selectedDate,
      timeSlot: selectedTimeSlot,
      totalPrice: totalPrice,
      durationHours: durationHours,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem lại đặt lịch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutor Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                      onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tutor.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${tutor.rating} (${tutor.reviewCount} đánh giá)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Booking Details
            Text(
              'Chi tiết đặt lịch',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Ngày học',
                      value: dateFormat.format(selectedDate),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time,
                      label: 'Khung giờ',
                      value: selectedTimeSlot,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.timer,
                      label: 'Thời lượng',
                      value: '$durationHours giờ',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Price Breakdown
            Text(
              'Chi phí',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPriceRow(
                      context,
                      label: 'Giá mỗi giờ',
                      value: currencyFormat.format(tutor.hourlyRate),
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      context,
                      label: 'Số giờ',
                      value: '$durationHours giờ',
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      context,
                      label: 'Tổng cộng',
                      value: currencyFormat.format(totalPrice),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cancellation Policy
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chính sách hủy',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bạn có thể hủy đặt lịch trước 24 giờ để được hoàn tiền 100%.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[900],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to booking screen and confirm
                        context.pop(); // Pop review screen
                        // The booking screen will handle the confirmation
                        final viewModel = ref.read(
                          bookingViewModelProvider(tutor).notifier,
                        );
                        viewModel.confirmBooking();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Xác nhận & Thanh toán'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isTotal ? null : Colors.grey[600],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 18 : null,
                color: isTotal ? Theme.of(context).primaryColor : null,
              ),
        ),
      ],
    );
  }
}

