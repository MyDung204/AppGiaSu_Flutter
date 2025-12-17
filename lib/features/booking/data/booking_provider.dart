import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/wallet/data/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BookingItem {
  final String id;
  final String userId;
  final Tutor tutor; // Can be partial object
  final DateTime date;
  final String timeSlot;
  final double price;
  final String status; 
  final DateTime? lockedUntil;

  BookingItem({
    required this.id,
    required this.userId,
    required this.tutor,
    required this.date,
    required this.timeSlot,
    required this.price,
    this.status = 'Upcoming',
    this.lockedUntil,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      tutor: Tutor.fromJson(json['tutor']), // Ensure Tutor has fromJson
      date: DateTime.parse(json['date']),
      timeSlot: json['time_slot'],
      price: double.parse(json['price'].toString()),
      status: json['status'],
      lockedUntil: json['locked_until'] != null ? DateTime.parse(json['locked_until']) : null,
    );
  }

  BookingItem copyWith({
    String? status,
    DateTime? lockedUntil,
  }) {
    return BookingItem(
      id: id,
      userId: userId,
      tutor: tutor,
      date: date,
      timeSlot: timeSlot,
      price: price,
      status: status ?? this.status,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }
}

class BookingNotifier extends AsyncNotifier<List<BookingItem>> {
  @override
  Future<List<BookingItem>> build() async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.get(ApiConstants.bookings);
      if (response is List) {
        return response.map((e) => BookingItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API Error (Fetch Bookings): $e');
      return [];
    }
  }

  // Check availability (Client-Side Optimistic Check + Server Check ideally)
  bool isSlotAvailable(String tutorId, DateTime date, String time) {
    // With AsyncNotifier, we look at the latest value
    final currentList = state.value ?? [];
    final dateStr = DateFormat('yyyyMMdd').format(date);
    
    return !currentList.any((b) => 
      b.tutor.id == tutorId &&
      DateFormat('yyyyMMdd').format(b.date) == dateStr &&
      b.timeSlot == time &&
      (b.status == 'Upcoming' || b.status == 'Locked')
    );
  }

  Future<void> lockSlot(BookingItem item) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      // POST /bookings/lock
      await apiClient.post('${ApiConstants.bookings}/lock', data: {
        'tutor_id': item.tutor.id,
        'date': item.date.toIso8601String(),
        'time_slot': item.timeSlot,
        'price': item.price,
      });
      ref.invalidateSelf();
    } catch (e) {
      throw Exception("Không thể giữ chỗ: $e");
    }
  }

  Future<void> confirmBooking(String id) async {
     final apiClient = ref.read(apiClientProvider);
     try {
       await apiClient.post('${ApiConstants.bookings}/$id/confirm');
       ref.invalidateSelf();
     } catch (e) {
       print('Confirm Error: $e');
     }
  }

  Future<void> cancelBooking(String id) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      // Server handles refund logic logic
      await apiClient.post('${ApiConstants.bookings}/$id/cancel');
      ref.invalidateSelf();
    } catch (e) {
      print('Cancel Error: $e');
    }
  }
}

final bookingProvider = AsyncNotifierProvider<BookingNotifier, List<BookingItem>>(BookingNotifier.new);
