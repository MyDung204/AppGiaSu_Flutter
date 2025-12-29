/// Booking ViewModel
/// 
/// Manages business logic for the booking flow using MVVM pattern.
/// Handles:
/// - Date and time slot selection
/// - Booking confirmation with lock mechanism
/// - Time slot availability checking
/// - Error handling with user-friendly messages
/// 
/// **State Management:**
/// - Uses `BookingState` to track booking progress
/// - Status flow: idle → locking → confirming → success/error
/// 
/// **Booking Flow:**
/// 1. User selects date and time slot
/// 2. System locks slot for 10 minutes (prevents double booking)
/// 3. Payment simulation (TODO: integrate real payment gateway)
/// 4. Confirm booking (hard lock)
/// 5. Send notification to tutor via chat
/// 6. Refresh booking list

import 'package:doantotnghiep/core/base/base_view_model.dart';
import 'package:doantotnghiep/core/exceptions/app_exceptions.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/booking/domain/models/booking_state.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// ViewModel for Booking feature
/// 
/// Implements MVVM pattern with Riverpod 2.x StateNotifier.
/// Separates business logic from UI, making code testable and maintainable.
/// 
/// **Key Responsibilities:**
/// - Manage booking state (date, time slot, status)
/// - Handle booking confirmation flow
/// - Check time slot availability
/// - Provide time slot status for UI display
class BookingViewModel extends BaseStateNotifier<BookingState> {
  /// Tutor reference - được truyền vào qua constructor
  /// Lưu tutor để sử dụng trong các methods
  final Tutor _tutor;

  /// Constructor nhận ref và tutor từ family provider
  /// 
  /// **Parameters:**
  /// - `ref`: Ref for accessing providers (Riverpod 2.x)
  /// - `tutor`: Tutor object để đặt lịch học
  /// 
  /// **Purpose:**
  /// - Lưu tutor vào field để sử dụng trong các methods
  /// - Khởi tạo state với tutor trong super constructor
  BookingViewModel(Ref ref, Tutor tutor) 
      : _tutor = tutor, 
        super(ref, BookingState.initial(tutor: tutor));

  /// Lấy tutor cho booking này
  /// 
  /// **Returns:**
  /// - `Tutor`: Gia sư đang được đặt lịch
  /// 
  /// **Note:**
  /// - Tutor luôn có giá trị vì được truyền vào constructor
  /// - Không cần kiểm tra null vì tutor là required parameter
  Tutor get tutor => _tutor;

  /// Update selected booking date
  /// 
  /// **Parameters:**
  /// - `date`: Selected date for the booking
  /// 
  /// **Side Effects:**
  /// - Resets selected time slot to null (user must reselect time after changing date)
  /// - Updates state to reflect new date selection
  /// 
  /// **Why reset time slot?**
  /// - Different dates may have different available time slots
  /// - Prevents invalid state (time slot from previous date)
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeSlot: null, // Reset time slot when date changes
    );
  }

  /// Update selected time slot
  /// 
  /// **Parameters:**
  /// - `timeSlot`: Selected time slot string (e.g., "09:00 - 11:00")
  ///   Can be null to deselect current selection
  /// 
  /// **Usage:**
  /// - Call with time slot string to select
  /// - Call with null to deselect
  void selectTimeSlot(String? timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  /// Confirm booking - Main business logic
  /// 
  /// **Purpose:**
  /// - Executes the complete booking flow with lock mechanism
  /// - Prevents double booking through server-side validation
  /// - Handles payment simulation and confirmation
  /// 
  /// **Process:**
  /// 1. **Validation:** Checks if date and time slot are selected
  /// 2. **Lock Slot:** Reserves time slot for 10 minutes (soft lock)
  /// 3. **Payment:** Simulates payment process (TODO: integrate real payment)
  /// 4. **Confirm:** Converts soft lock to hard lock (confirmed booking)
  /// 5. **Notification:** Sends message to tutor via chat system
  /// 6. **Refresh:** Updates booking list to reflect new booking
  /// 
  /// **Error Handling:**
  /// - Catches and converts exceptions to user-friendly messages
  /// - Updates state with error status and message
  /// 
  /// **State Transitions:**
  /// - idle → locking → confirming → success
  /// - Or: idle → locking → error (if any step fails)
  /// 
  /// **Returns:**
  /// - `Future<void>`: Completes when booking is confirmed or fails
  /// 
  /// **Example:**
  /// ```dart
  /// await viewModel.confirmBooking();
  /// if (viewModel.state.status == BookingStatus.success) {
  ///   // Show success message
  /// }
  /// ```
  /// 
  /// **TODO:**
  /// - Replace payment simulation with real payment gateway (VNPay/Momo)
  /// - Add retry mechanism for network errors
  /// - Implement offline queue for failed bookings
  Future<void> confirmBooking() async {
    // Early return if booking cannot be confirmed
    // Validates that date and time slot are selected
    if (!state.canConfirm) return;

    // Extract booking details from state
    final selectedDate = state.selectedDate!;
    final selectedTimeSlot = state.selectedTimeSlot!;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final clientBookingId = const Uuid().v4(); // Generate unique ID for client-side tracking
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    try {
      // ============================================
      // STEP 1: LOCK SLOT (Soft Lock - 10 minutes)
      // ============================================
      // Purpose: Reserve time slot temporarily to prevent double booking
      // Duration: 10 minutes (enough time for payment process)
      // Status: 'Locked' - can be released if payment fails
      state = state.copyWith(
        status: BookingStatus.locking,
        isLoading: true,
      );

      // Create booking item with lock status
      // NOTE: totalPrice is calculated as hourlyRate * 2 (default 2-hour session)
      // TODO: Make session duration configurable
      final lockItem = BookingItem(
        id: clientBookingId,
        userId: userId,
        tutor: tutor,
        date: selectedDate,
        timeSlot: selectedTimeSlot,
        totalPrice: tutor.hourlyRate * 2, // Default 2-hour session
        status: 'Locked',
        lockedUntil: DateTime.now().add(const Duration(minutes: 10)), // 10-minute lock window
      );

      // Send lock request to server
      // Server validates slot availability and creates lock
      final serverBookingId = await ref.read(bookingProvider.notifier).lockSlot(lockItem);

      // Validate server response
      if (serverBookingId.isEmpty) {
        throw Exception("Server did not return a valid Booking ID");
      }

      // ============================================
      // STEP 2: PAYMENT SIMULATION
      // ============================================
      // TODO: Replace with real payment gateway integration (VNPay/Momo)
      // Current implementation: Simulates 1-second payment delay
      // In production: Call payment gateway, wait for callback/response
      await Future.delayed(const Duration(seconds: 1));

      // ============================================
      // STEP 3: CONFIRM BOOKING (Hard Lock)
      // ============================================
      // Purpose: Convert soft lock to confirmed booking
      // Status: 'Upcoming' - permanent booking, cannot be released
      state = state.copyWith(status: BookingStatus.confirming);
      await ref.read(bookingProvider.notifier).confirmBooking(serverBookingId);

      // ============================================
      // STEP 4: SEND NOTIFICATION TO TUTOR
      // ============================================
      // Purpose: Notify tutor about new booking via chat system
      // Error handling: If chat fails, booking still succeeds (non-critical)
      try {
        ref.read(chatControllerProvider(tutor.id)).sendMessage(
          'Hệ thống: Bạn đã đặt lịch học thành công vào ngày $formattedDate, khung giờ $selectedTimeSlot.',
        );
      } catch (_) {
        // Ignore chat error - booking is the main flow
        // Chat notification is nice-to-have, not critical
        // Log error in production for monitoring
      }

      // ============================================
      // STEP 5: REFRESH BOOKING DATA
      // ============================================
      // Purpose: Update booking list to include new booking
      // Invalidates provider to trigger refetch from server
      ref.invalidate(bookingProvider);

      // ============================================
      // STEP 6: UPDATE STATE TO SUCCESS
      // ============================================
      // Purpose: Signal UI that booking completed successfully
      // UI will show success dialog and navigate to schedule screen
      state = state.copyWith(
        status: BookingStatus.success,
        bookingId: serverBookingId,
        isLoading: false,
      );
    } catch (e) {
      // ============================================
      // ERROR HANDLING: Convert exceptions to user-friendly messages
      // ============================================
      String userMessage;
      
      if (e is BookingException) {
        // Booking-specific errors (slot already booked, etc.)
        userMessage = e.userMessage;
      } else if (e is ApiException) {
        // API errors - map status codes to user messages
        if (e.statusCode == 409) {
          // 409 Conflict: Slot already taken by another user
          userMessage = BookingException.slotAlreadyBooked().userMessage;
        } else {
          // Other API errors (400, 401, 500, etc.)
          userMessage = e.userMessage;
        }
      } else if (e is NetworkException) {
        // Network errors (no connection, timeout)
        userMessage = e.userMessage;
      } else {
        // Unknown errors - fallback message
        // TODO: Log technical error for debugging
        userMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }

      // Update state with error
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: userMessage,
        isLoading: false,
      );
    }
  }

  /// Reset booking status after showing success/error message
  /// 
  /// **Purpose:**
  /// - Clears success/error status to allow new booking attempt
  /// - Called by UI after displaying success/error dialog
  /// 
  /// **When to call:**
  /// - After user dismisses success dialog
  /// - After user dismisses error snackbar
  /// 
  /// **State Transition:**
  /// - success → idle (ready for new booking)
  /// - error → idle (ready to retry)
  void resetStatus() {
    if (state.status == BookingStatus.success || state.status == BookingStatus.error) {
      state = state.copyWith(
        status: BookingStatus.idle,
        errorMessage: null,
        bookingId: null,
      );
    }
  }

  /// Check if a time slot is available for booking
  /// 
  /// **Parameters:**
  /// - `timeSlot`: Time slot string (e.g., "09:00 - 11:00")
  /// - `date`: Date to check availability for
  /// 
  /// **Returns:**
  /// - `bool`: true if slot is available, false if booked or locked
  /// 
  /// **Logic:**
  /// - Checks existing bookings for same tutor, date, and time slot
  /// - Returns false if:
  ///   - Slot has status 'Upcoming' (permanently booked)
  ///   - Slot has status 'Locked' and lock hasn't expired (temporarily reserved)
  /// - Returns true if slot is free or lock has expired
  /// 
  /// **NOTE:** This is client-side check. Server also validates on lock/confirm.
  /// Client check is for UX (disable unavailable slots), server check is for security.
  bool isTimeSlotAvailable(String timeSlot, DateTime date) {
    final existingBookings = ref.read(bookingProvider).value ?? [];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final dateStr = DateFormat('yyyyMMdd').format(date);

    for (var booking in existingBookings) {
      if (booking.tutor.id == tutor.id &&
          DateFormat('yyyyMMdd').format(booking.date) == dateStr &&
          booking.timeSlot == timeSlot &&
          booking.status != 'Cancelled') {
        if (booking.status == 'Upcoming') {
          return false; // Already booked
        } else if (booking.status == 'Locked') {
          if (booking.lockedUntil != null && booking.lockedUntil!.isAfter(DateTime.now())) {
            if (booking.userId != currentUserId) {
              return false; // Locked by someone else
            }
          }
        }
      }
    }
    return true;
  }

  /// Get time slot status for UI display
  /// 
  /// **Parameters:**
  /// - `timeSlot`: Time slot string to check
  /// - `date`: Date to check status for
  /// 
  /// **Returns:**
  /// - `TimeSlotStatus`: Status enum for UI rendering
  ///   - `available`: Slot is free and can be booked
  ///   - `booked`: Slot is permanently booked (cannot select)
  ///   - `lockedByOthers`: Slot is temporarily locked by another user
  ///   - `myLock`: Slot is locked by current user (can still select)
  /// 
  /// **Purpose:**
  /// - Provides detailed status for UI to show appropriate visual feedback
  /// - Different from `isTimeSlotAvailable()` which only returns bool
  /// - Used to display labels like "(Đã kín)", "(Đang giao dịch)", etc.
  /// 
  /// **UI Usage:**
  /// - `available`: Normal chip, can be selected
  /// - `booked`: Disabled chip, gray color, shows "(Đã kín)"
  /// - `lockedByOthers`: Disabled chip, shows "(Đang giao dịch)"
  /// - `myLock`: Enabled chip, orange color, shows "(Bạn đang giữ)"
  TimeSlotStatus getTimeSlotStatus(String timeSlot, DateTime date) {
    final existingBookings = ref.read(bookingProvider).value ?? [];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final dateStr = DateFormat('yyyyMMdd').format(date);

    for (var booking in existingBookings) {
      if (booking.tutor.id == tutor.id &&
          DateFormat('yyyyMMdd').format(booking.date) == dateStr &&
          booking.timeSlot == timeSlot &&
          booking.status != 'Cancelled') {
        if (booking.status == 'Upcoming') {
          return TimeSlotStatus.booked;
        } else if (booking.status == 'Locked') {
          if (booking.lockedUntil != null && booking.lockedUntil!.isAfter(DateTime.now())) {
            if (booking.userId == currentUserId) {
              return TimeSlotStatus.myLock;
            } else {
              return TimeSlotStatus.lockedByOthers;
            }
          }
        }
      }
    }
    return TimeSlotStatus.available;
  }
}

/// Time slot status enum for UI display
/// 
/// Used to determine how to render time slot chips in booking screen.
enum TimeSlotStatus {
  /// Slot is available and can be booked
  available,
  
  /// Slot is permanently booked (confirmed booking)
  booked,
  
  /// Slot is temporarily locked by another user (within 10-minute window)
  lockedByOthers,
  
  /// Slot is locked by current user (can still proceed with booking)
  myLock,
}

/// Provider for BookingViewModel (Family Provider)
/// 
/// **Purpose:**
/// - Creates a separate ViewModel instance for each tutor
/// - Auto-disposes when no longer used (memory efficient)
/// 
/// **Usage:**
/// ```dart
/// final viewModel = ref.watch(bookingViewModelProvider(tutor));
/// final viewModelNotifier = ref.read(bookingViewModelProvider(tutor).notifier);
/// ```
/// 
/// **Note:** Trong Riverpod 2.x, family provider factory function nhận
/// `ref` và family parameter (tutor).
/// 
/// **Initialization:**
/// - Tạo ViewModel instance với tutor từ constructor
/// - Constructor khởi tạo state với tutor
final bookingViewModelProvider = StateNotifierProvider.autoDispose
    .family<BookingViewModel, BookingState, Tutor>(
  (ref, tutor) {
    // Truyền ref và tutor vào constructor
    // Constructor sẽ khởi tạo state với tutor này
    return BookingViewModel(ref, tutor);
  },
);

