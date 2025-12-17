
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'credit', 'debit'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class WalletState {
  final double balance;
  final List<Transaction> transactions;

  WalletState({required this.balance, required this.transactions});
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    return WalletState(
      balance: 1500000,
      transactions: [
         Transaction(id: '1', title: 'Nạp tiền Momo', amount: 500000, date: DateTime.now().subtract(const Duration(days: 5)), type: 'credit'),
         Transaction(id: '2', title: 'Thanh toán buổi học #123', amount: 200000, date: DateTime.now().subtract(const Duration(days: 6)), type: 'debit'),
      ],
    );
  }

  void addTransaction(Transaction tx) {
    double newBalance = state.balance;
    if (tx.type == 'credit') {
      newBalance += tx.amount;
    } else {
      newBalance -= tx.amount;
    }

    state = WalletState(
      balance: newBalance,
      transactions: [tx, ...state.transactions],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
