import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_statistics_provider.dart';
import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:intl/intl.dart';

class TutorStatisticsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const TutorStatisticsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<TutorStatisticsScreen> createState() => _TutorStatisticsScreenState();
}

class _TutorStatisticsScreenState extends ConsumerState<TutorStatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final statsAsync = ref.watch(tutorStatisticsProvider);
    final tuitionsAsync = ref.watch(tutorTuitionsProvider);
    
    return Scaffold(
      backgroundColor: EduTheme.background,
      appBar: AppBar(
        title: const Text('Ví & Thống kê'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EduTheme.primary,
          labelColor: EduTheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Ví & Thu nhập'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(statsAsync, currency),
          _buildWalletTab(tuitionsAsync, statsAsync, currency),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<Map<String, dynamic>> statsAsync, NumberFormat currency) {
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Revenue Card
              _buildRevenueCard(currency, stats),
              const SizedBox(height: 24),

              // Performance Grid
              const Text(
                'Hiệu suất giảng dạy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPerformanceGrid(stats),
              const SizedBox(height: 24),

              // Student Distribution
              const Text(
                'Phân bổ học viên',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStudentDistribution(),
              const SizedBox(height: 24),

              // Rating History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử đánh giá',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
                ],
              ),
              _buildRatingList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletTab(AsyncValue<List<dynamic>> tuitionsAsync, AsyncValue<Map<String, dynamic>> statsAsync, NumberFormat currency) {
    return Column(
      children: [
        // Balance Section
        statsAsync.maybeWhen(
          data: (stats) => Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số dư khả dụng', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(currency.format(stats['total_revenue'] ?? 0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: EduTheme.primary)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showWithdrawBottomSheet(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EduTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Rút tiền'),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),

        // Transactions List
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Lịch sử thu nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: tuitionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Lỗi tải dữ liệu')),
            data: (tuitions) {
              if (tuitions.isEmpty) {
                return const Center(child: Text('Chưa có lịch sử thu nhập'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: tuitions.length,
                itemBuilder: (context, index) {
                  final t = tuitions[index];
                  return _buildTuitionItem(t, currency);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTuitionItem(Map<String, dynamic> t, NumberFormat currency) {
    final bool isCompleted = t['status'] == 'completed';
    final String studentName = t['student']?['name'] ?? 'Học viên';
    final DateTime date = DateTime.parse(t['date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.add_rounded : Icons.schedule_rounded,
              color: isCompleted ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Học phí $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            currency.format(t['total_price'] ?? 0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawBottomSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yêu cầu Rút tiền', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền (VNĐ)',
                hintText: 'Tối thiểu 50.000đ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount < 50000) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền tối thiểu là 50.000đ')));
                    return;
                  }
                  
                  final success = await ref.read(tutorRepositoryProvider).requestWithdrawal('Default', 'Default', amount);
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu rút tiền!'), backgroundColor: Colors.green));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: EduTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Gửi yêu cầu'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(NumberFormat currency, Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EduTheme.primary, EduTheme.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EduTheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng thu nhập quyết toán',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(stats['total_revenue'] ?? 0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
               _buildMiniStat('Lớp học', '${stats['active_classes'] ?? 0}', Icons.school),
               const SizedBox(width: 24),
               _buildMiniStat('Đánh giá', '${stats['rating'] ?? 0} ⭐ (${stats['review_count'] ?? 0})', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildPerformanceCard('Tỉ lệ hoàn thành', '${stats['completion_rate'] ?? 0}%', Icons.check_circle, Colors.green),
        _buildPerformanceCard('Tỉ lệ phản hồi', '${stats['response_time'] ?? 'N/A'}', Icons.bolt, Colors.orange),
        _buildPerformanceCard('Tổng học viên', '${stats['total_students'] ?? 0}', Icons.person, Colors.blue),
        _buildPerformanceCard('Giờ đã dạy', '${stats['teaching_hours'] ?? 0}h', Icons.calendar_today, Colors.purple),
      ],
    );
  }

  Widget _buildPerformanceCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStudentDistribution() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildDistRow('Toán học', 0.6, Colors.blue),
          const SizedBox(height: 12),
          _buildDistRow('Tiếng Anh', 0.3, Colors.purple),
          const SizedBox(height: 12),
          _buildDistRow('Khác', 0.1, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDistRow(String label, double val, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(val * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: val,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildRatingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: EduTheme.primary, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trần Văn B', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < 5 ? Colors.amber : Colors.grey)),
                    ),
                  ],
                ),
              ),
              Text('2 ngày trước', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}
