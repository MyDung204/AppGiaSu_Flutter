import 'package:doantotnghiep/features/wallet/data/wallet_repository.dart';
import 'package:doantotnghiep/features/wallet/domain/models/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

class WalletNotifier extends AsyncNotifier<WalletState> {
  @override
  Future<WalletState> build() async {
    return ref.read(walletRepositoryProvider).getWalletInfo();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(walletRepositoryProvider).getWalletInfo());
  }
  
  Future<void> deposit(double amount) async {
      final success = await ref.read(walletRepositoryProvider).deposit(amount);
      if (success) refresh();
  }
}
