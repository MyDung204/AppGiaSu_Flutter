import 'package:doantotnghiep/features/wallet/data/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Ví của tôi')),
      body: walletAsync.when(
        data: (walletState) {
          final balance = walletState.balance;
          final transactions = walletState.transactions;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Balance Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Colors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      const Text('Số dư khả dụng', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(balance),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(context, Icons.add, 'Nạp tiền', () {
                             _showDepositDialog(context, ref);
                          }),
                          _buildActionButton(context, Icons.arrow_upward, 'Rút tiền', () {}),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Lịch sử giao dịch', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const Padding(padding: EdgeInsets.all(16), child: Text("Chưa có giao dịch nào."))
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      // Determine Credit/Debit based on backend types
                      final isCredit = tx.type == 'deposit' || tx.type == 'earning' || tx.type == 'refund';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(tx.title), // Backend description mapped to title
                        subtitle: Text(dateFormat.format(tx.date)),
                        trailing: Text(
                          '${isCredit ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                          style: TextStyle(
                            color: isCredit ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải ví: $err')),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(30)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  void _showDepositDialog(BuildContext context, WidgetRef ref) {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nạp tiền Demo'),
          content: TextField(
             controller: controller,
             keyboardType: TextInputType.number,
             decoration: const InputDecoration(labelText: 'Số tiền (VNĐ)', hintText: 'VD: 500000'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            FilledButton(
               onPressed: () {
                 final amount = double.tryParse(controller.text);
                 if (amount != null && amount >= 10000) {
                    ref.read(walletProvider.notifier).deposit(amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang xử lý nạp tiền...')));
                 }
               }, 
               child: const Text('Nạp ngay')
            ),
          ],
        ),
      );
  }
}
