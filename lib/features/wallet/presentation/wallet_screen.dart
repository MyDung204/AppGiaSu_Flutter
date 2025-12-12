import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    const double balance = 1500000;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final transactions = [
      {'id': '1', 'title': 'Nạp tiền Momo', 'amount': 500000, 'date': '10/12/2023', 'type': 'credit'},
      {'id': '2', 'title': 'Thanh toán buổi học #123', 'amount': -200000, 'date': '09/12/2023', 'type': 'debit'},
      {'id': '3', 'title': 'Hoàn tiền buổi học #120', 'amount': 200000, 'date': '08/12/2023', 'type': 'credit'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ví của tôi')),
      body: SingleChildScrollView(
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
                      _buildActionButton(context, Icons.add, 'Nạp tiền', () {}),
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
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isCredit = tx['type'] == 'credit';
                final amount = tx['amount'] as int;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(tx['title'] as String),
                  subtitle: Text(tx['date'] as String),
                  trailing: Text(
                    '${isCredit ? '+' : ''}${currencyFormat.format(amount)}',
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
}
