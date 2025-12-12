import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingControllerProvider = AsyncNotifierProvider<BookingController, void>(() {
  return BookingController();
});

class BookingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createBooking({
    required String tutorId,
    required DateTime date,
    required String timeSlot,
    required double amount,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Simulate API call and Escrow logic
      await Future.delayed(const Duration(seconds: 2));
      // TODO: Call Repository to save booking to Firestore
      // TODO: Deduct balance from Wallet
    });
  }
}
