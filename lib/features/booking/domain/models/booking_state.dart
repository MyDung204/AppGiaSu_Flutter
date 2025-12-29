import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';

/// State class for Booking feature
class BookingState {
  final Tutor? tutor;
  final BookingStatus status;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? bookingId;
  final String? errorMessage;
  final bool isLoading;

  const BookingState({
    this.tutor,
    required this.status,
    this.selectedDate,
    this.selectedTimeSlot,
    this.bookingId,
    this.errorMessage,
    this.isLoading = false,
  });

  factory BookingState.initial({Tutor? tutor}) => BookingState(
        tutor: tutor,
        status: BookingStatus.idle,
        selectedDate: null,
        selectedTimeSlot: null,
      );

  BookingState copyWith({
    Tutor? tutor,
    BookingStatus? status,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? bookingId,
    String? errorMessage,
    bool? isLoading,
  }) {
    return BookingState(
      tutor: tutor ?? this.tutor,
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      bookingId: bookingId ?? this.bookingId,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get canConfirm => 
      status == BookingStatus.idle && 
      selectedDate != null && 
      selectedTimeSlot != null && 
      !isLoading;
}

enum BookingStatus {
  idle,
  processing,
  locking,
  confirming,
  success,
  error,
}



