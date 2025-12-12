import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingItem {
  final String id;
  final Tutor tutor;
  final DateTime date;
  final String timeSlot;
  final double price;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'

  BookingItem({
    required this.id,
    required this.tutor,
    required this.date,
    required this.timeSlot,
    required this.price,
    this.status = 'Upcoming',
  });
}

class BookingNotifier extends Notifier<List<BookingItem>> {
  @override
  List<BookingItem> build() {
    return [];
  }

  void addBooking(BookingItem booking) {
    state = [...state, booking];
  }

  void cancelBooking(String id) {
    state = [
      for (final b in state)
        if (b.id == id)
           BookingItem(
             id: b.id, 
             tutor: b.tutor, 
             date: b.date, 
             timeSlot: b.timeSlot, 
             price: b.price, 
             status: 'Cancelled'
           )
        else
          b
    ];
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, List<BookingItem>>(BookingNotifier.new);
