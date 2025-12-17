import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:doantotnghiep/features/booking/presentation/booking_controller.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Tutor tutor;

  const BookingScreen({super.key, required this.tutor});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isProcessing = false;

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

    setState(() => _isProcessing = true);

    final bookingId = const Uuid().v4();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

    try {
      // 1. Attempt Soft Lock (10 mins)
      final lockItem = BookingItem(
        id: bookingId,
        userId: userId,
        tutor: widget.tutor,
        date: _selectedDate,
        timeSlot: _selectedTimeSlot!,
        price: widget.tutor.hourlyRate * 2,
        status: 'Locked',
        lockedUntil: DateTime.now().add(const Duration(minutes: 10)),
      );

      ref.read(bookingProvider.notifier).lockSlot(lockItem);

      // 2. Simulate Payment Process (Delay)
      // In real app, navigate to Payment Screen or show Payment Sheet here
      await Future.delayed(const Duration(seconds: 2));

      // 3. Confirm Booking (Hard Lock - Payment Success)
      ref.read(bookingProvider.notifier).confirmBooking(bookingId);

      // 4. Notifications & Backend Sync
      ref.read(chatProvider.notifier).sendMessage(
        widget.tutor.id,
        'Hệ thống: Bạn đã đặt lịch học thành công vào ngày $formattedDate, khung giờ $_selectedTimeSlot!.',
        isSystem: true,
        isUser: true, 
      );

      // Mock Backend Sync
      await ref.read(bookingControllerProvider.notifier).createBooking(
        tutorId: widget.tutor.id,
        date: _selectedDate,
        timeSlot: _selectedTimeSlot!,
        amount: widget.tutor.hourlyRate * 2,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công!'),
            content: const Text('Yêu cầu đặt lịch của bạn đã được gửi. Bạn vui lòng vào đúng giờ nhé!'),
            actions: [
              TextButton(
                onPressed: () => context.go('/schedule'),
                child: const Text('Xem Lịch học'),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _selectedTimeSlot = null; 
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
                 final weekday = _selectedDate.weekday;
                 final scheduleKey = (weekday == 7) ? '8' : (weekday + 1).toString();
                 final availableSlots = widget.tutor.weeklySchedule[scheduleKey] ?? [];

                 // Force cleanup of expired locks before rendering
                 // In a real app, this might be reactive or handled better
                 // ref.read(bookingProvider.notifier).cleanExpiredLocks(); 
                 // Note: calling notifier write method in build is bad practice. 
                 // The 'isSlotAvailable' check inside provider does the check.

                 final existingBookings = ref.watch(bookingProvider).value ?? [];
                 final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
                 
                 final dateStr = DateFormat('yyyyMMdd').format(_selectedDate);

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
                    bool isLockedByOthers = false;
                    bool isBooked = false;
                    bool isMyLock = false;

                    for (var b in existingBookings) {
                      if (b.tutor.id == widget.tutor.id && 
                          DateFormat('yyyyMMdd').format(b.date) == dateStr &&
                          b.timeSlot == slot &&
                          b.status != 'Cancelled') {
                        
                        if (b.status == 'Upcoming') {
                          isBooked = true;
                        } else if (b.status == 'Locked') {
                          if (b.lockedUntil != null && b.lockedUntil!.isAfter(DateTime.now())) {
                             // Valid lock
                             if (b.userId == currentUserId) {
                               isMyLock = true;
                             } else {
                               isLockedByOthers = true;
                             }
                          }
                        }
                      }
                    }

                    final isDisabled = isBooked || isLockedByOthers;
                    final isSelected = _selectedTimeSlot == slot;

                    String label = slot;
                    if (isBooked) label += ' (Đã kín)';
                    else if (isLockedByOthers) label += ' (Đang giao dịch)';
                    else if (isMyLock) label += ' (Bạn đang giữ)';
                    
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: isDisabled ? null : (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? slot : null;
                        });
                      },
                      disabledColor: Colors.grey[300],
                      selectedColor: isMyLock ? Colors.orangeAccent : null, // Highlight if I'm holding it (though this logic is for future selection)
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
            onPressed: (_selectedTimeSlot == null || _isProcessing) ? null : _onConfirmBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Xác nhận đặt lịch & Thanh toán'),
          ),
        ),
      ),
    );
  }
}
