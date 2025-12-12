import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:doantotnghiep/features/booking/presentation/booking_controller.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Tutor tutor;

  const BookingScreen({super.key, required this.tutor});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  // Mock time slots
  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '14:00 - 16:00',
    '18:00 - 20:00',
    '20:00 - 22:00',
  ];

  void _onConfirmBooking() async {
    if (_selectedTimeSlot == null) return;

    // 1. Add to Booking Provider (History/Schedule)
    final newBooking = BookingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tutor: widget.tutor,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot!,
      price: widget.tutor.hourlyRate * 2,
    );
    ref.read(bookingProvider.notifier).addBooking(newBooking);

    // 2. Add System Notification to Chat
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    ref.read(chatProvider.notifier).sendMessage(
      widget.tutor.id,
      'Hệ thống: Bạn đã đặt lịch học thành công vào ngày $formattedDate, khung giờ $_selectedTimeSlot!.',
      isSystem: true,
      isUser: true, // Show on user side
    );

    // 3. Backend Call (Mocked via controller)
    await ref.read(bookingControllerProvider.notifier).createBooking(
      tutorId: widget.tutor.id,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot!,
      amount: widget.tutor.hourlyRate * 2,
    );

    if (ref.read(bookingControllerProvider).hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thất bại. Vui lòng thử lại.')),
        );
      }
    } else {
      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công!'),
            content: const Text('Yêu cầu đặt lịch của bạn đã được gửi và lưu vào lịch sử.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.go('/schedule'); // Go to Schedule to see result
                },
                child: const Text('Xem Lịch học'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingControllerProvider);
    final isLoading = bookingState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch học'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutor Info Summary
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.tutor.avatarUrl),
              ),
              title: Text(widget.tutor.name),
              subtitle: Text('${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.tutor.hourlyRate)}/h'),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Date Picker
            Text(
              'Chọn ngày',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTimeSlot = null; // Reset time slot when date changes
                });
              },
            ),
            const SizedBox(height: 16),

            // Time Slot Picker
            Text(
              'Chọn giờ học',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                 // 1. Get Available Slots for Selected Weekday
                 // Weekday in Dart: 1=Mon, 7=Sun. VN Schedule map keys: '2'=Mon... '8'=Sun.
                 // So mapping: Dart(1)->'2', Dart(2)->'3'... Dart(7)->'8'.
                 final weekday = _selectedDate.weekday;
                 final scheduleKey = (weekday == 7) ? '8' : (weekday + 1).toString();
                 
                 final availableSlots = widget.tutor.weeklySchedule[scheduleKey] ?? [];

                 // 2. check for conflicts
                 final existingBookings = ref.watch(bookingProvider);
                 
                 if (availableSlots.isEmpty) {
                   return const Padding(
                     padding: EdgeInsets.symmetric(vertical: 16),
                     child: Text('Gia sư không có lịch rảnh vào ngày này.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                   );
                 }

                 return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableSlots.map((slot) {
                    // Check collision: Same tutor, same date, same slot
                    final isOccupied = existingBookings.any((b) => 
                        b.tutor.id == widget.tutor.id && 
                        DateFormat('yyyyMMdd').format(b.date) == DateFormat('yyyyMMdd').format(_selectedDate) &&
                        b.timeSlot == slot &&
                        b.status != 'Cancelled'
                    );

                    final isSelected = _selectedTimeSlot == slot;
                    
                    return ChoiceChip(
                      label: Text(isOccupied ? '$slot (Đã kín)' : slot),
                      selected: isSelected,
                      onSelected: isOccupied ? null : (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? slot : null;
                        });
                      },
                      disabledColor: Colors.red.withOpacity(0.1),
                    );
                  }).toList(),
                );
              }
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: (_selectedTimeSlot == null || isLoading) ? null : _onConfirmBooking,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Xác nhận đặt lịch'),
          ),
        ),
      ),
    );
  }
}
