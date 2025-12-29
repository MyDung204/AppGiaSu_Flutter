import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/booking/domain/models/booking_state.dart';
import 'package:doantotnghiep/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Booking Screen - MVVM Pattern
/// View layer: Only handles UI rendering and user interactions
/// Business logic is handled by BookingViewModel
class BookingScreen extends ConsumerStatefulWidget {
  final Tutor tutor;

  const BookingScreen({super.key, required this.tutor});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize with current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider(widget.tutor).notifier)
          .selectDate(DateTime.now());
    });
  }

  void _handleSuccess(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công!'),
        content: const Text('Yêu cầu đặt lịch của bạn đã được gửi. Bạn vui lòng vào đúng giờ nhé!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/schedule');
            },
            child: const Text('Xem Lịch học'),
          ),
        ],
      ),
    );
  }

  void _handleError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $errorMessage')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(bookingViewModelProvider(widget.tutor));
    final viewModelNotifier = ref.read(bookingViewModelProvider(widget.tutor).notifier);

    // Handle state changes
    if (viewModel.status == BookingStatus.success && viewModel.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSuccess(viewModel.bookingId!);
        viewModelNotifier.resetStatus();
      });
    }

    if (viewModel.status == BookingStatus.error && viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleError(viewModel.errorMessage!);
        viewModelNotifier.resetStatus();
      });
    }

    final selectedDate = viewModel.selectedDate ?? DateTime.now();
    final selectedTimeSlot = viewModel.selectedTimeSlot;
    final isLoading = viewModel.isLoading;
    final canConfirm = viewModel.canConfirm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch học'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutor Info
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: widget.tutor.avatarUrl.isNotEmpty 
                    ? NetworkImage(widget.tutor.avatarUrl) 
                    : null,
                onBackgroundImageError: widget.tutor.avatarUrl.isNotEmpty 
                    ? (_, __) {} 
                    : null,
                child: widget.tutor.avatarUrl.isEmpty 
                    ? const Icon(Icons.person, color: Colors.grey) 
                    : null,
              ),
              title: Text(widget.tutor.name),
              subtitle: Text(
                '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.tutor.hourlyRate)}/h',
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Date Picker
            Text(
              'Chọn ngày',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                viewModelNotifier.selectDate(date);
              },
            ),
            const SizedBox(height: 16),

            // Time Slot Picker
            Text(
              'Chọn giờ học',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildTimeSlotSelector(
              context,
              selectedDate,
              selectedTimeSlot,
              viewModelNotifier,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: canConfirm && !isLoading
                ? () {
                    // Navigate to review screen first
                    context.push(
                      '/booking-review',
                      extra: {
                        'tutor': widget.tutor,
                        'date': selectedDate,
                        'timeSlot': selectedTimeSlot!,
                        'totalPrice': widget.tutor.hourlyRate * 2,
                      },
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Xác nhận đặt lịch & Thanh toán'),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelector(
    BuildContext context,
    DateTime selectedDate,
    String? selectedTimeSlot,
    BookingViewModel viewModel,
  ) {
    final weekday = selectedDate.weekday;
    final scheduleKey = (weekday == 7) ? '8' : (weekday + 1).toString();
    final availableSlots = widget.tutor.weeklySchedule[scheduleKey] ?? [];

    if (availableSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Gia sư không có lịch rảnh vào ngày này.',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableSlots.map((slot) {
            final status = viewModel.getTimeSlotStatus(slot, selectedDate);
            final isDisabled = status == TimeSlotStatus.booked ||
                status == TimeSlotStatus.lockedByOthers;
            final isSelected = selectedTimeSlot == slot;

            String label = slot;
            switch (status) {
              case TimeSlotStatus.booked:
                label += ' (Đã kín)';
                break;
              case TimeSlotStatus.lockedByOthers:
                label += ' (Đang giao dịch)';
                break;
              case TimeSlotStatus.myLock:
                label += ' (Bạn đang giữ)';
                break;
              case TimeSlotStatus.available:
                break;
            }

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: isDisabled
                  ? null
                  : (selected) {
                      if (selected) {
                        viewModel.selectTimeSlot(slot);
                      } else {
                        viewModel.selectTimeSlot(null);
                      }
                    },
              disabledColor: Colors.grey[300],
              selectedColor: status == TimeSlotStatus.myLock
                  ? Colors.orangeAccent
                  : null,
            );
          }).toList(),
        );
      },
    );
  }
}
