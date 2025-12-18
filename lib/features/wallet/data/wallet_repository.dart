import 'package:doantotnghiep/core/network/api_client.dart';
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
      // Response: { balance: 5000000, transactions: [...] }
      if (response is Map<String, dynamic>) {
        final balance = double.tryParse(response['balance'].toString()) ?? 0;
        final transactionsList = response['transactions'] as List?;
        final transactions = transactionsList?.map((e) => WalletTransaction.fromJson(e)).toList() ?? [];
        
        return WalletState(balance: balance, transactions: transactions);
      }
      return WalletState();
    } catch (e) {
      print('Error fetching wallet: $e');
      return WalletState(); // Return empty on error
    }
  }

  Future<bool> deposit(double amount) async {
    try {
      await _client.post('/wallet/deposit', data: {'amount': amount});
      return true;
    } catch (e) {
      return false;
    }
  }
}
