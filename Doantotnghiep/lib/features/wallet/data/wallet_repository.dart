import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/exceptions/app_exceptions.dart';
import 'package:doantotnghiep/features/wallet/domain/models/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(apiClientProvider));
});

class WalletRepository {
  final ApiClient _client;

  WalletRepository(this._client);

  Future<WalletState> getWalletInfo() async {
    try {
      final response = await _client.get('/wallet');
      // Response: { balance: ..., transactions: ..., has_payment_pin: bool }
      if (response is Map<String, dynamic>) {
        final balance = double.tryParse(response['balance'].toString()) ?? 0;
        final hasPin = response['has_payment_pin'] == true;
        final transactionsList = response['transactions'] as List?;
        final transactions = transactionsList?.map((e) => WalletTransaction.fromJson(e)).toList() ?? [];
        
        return WalletState(balance: balance, hasPaymentPin: hasPin, transactions: transactions);
      }
      return WalletState();
    } catch (e) {
      print('Error fetching wallet: $e');
      rethrow;
    }
  }

  Future<bool> deposit(double amount) async {
    await _client.post('/wallet/deposit', data: {'amount': amount});
    return true;
  }

  Future<bool> withdraw(double amount, String bankName, String accountNumber, String accountName) async {
    try {
      await _client.post('/wallet/withdraw', data: {
        'amount': amount,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- PIN SYSTEM ---
  Future<void> setupPin(String pin) async {
      await _client.post('/wallet/pin/setup', data: {
        'pin': pin,
        'pin_confirmation': pin,
      });
  }

  Future<void> changePin(String oldPin, String newPin) async {
      await _client.post('/wallet/pin/change', data: {
        'old_pin': oldPin,
        'new_pin': newPin,
        'new_pin_confirmation': newPin,
      });
  }

  Future<bool> verifyPin(String pin) async {
      try {
        await _client.post('/wallet/pin/verify', data: {'pin': pin});
        return true;
      } on ApiException {
        rethrow;
      }
  }

  Future<bool> simulateDeposit(double amount, int userId) async {
    return deposit(amount);
  }
}
