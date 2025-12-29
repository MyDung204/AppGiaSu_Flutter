/// Admin Dashboard Screen
/// 
/// **Purpose:**
/// - Màn hình tổng quan hệ thống cho admin
/// - Hiển thị các thống kê quan trọng: doanh thu, số người dùng, số gia sư, số yêu cầu chờ duyệt
/// - Hiển thị hoạt động gần đây của hệ thống
/// 
/// **Features:**
/// - Thống kê tổng quan (stats cards)
/// - Hoạt động gần đây (recent activities)
/// - Refresh data
/// - Navigation đến các màn hình quản lý khác
/// 
/// **Stats Cards:**
/// - Tổng doanh thu: Tổng số tiền thu được từ các booking
/// - Người dùng: Tổng số người dùng trong hệ thống
/// - Gia sư: Tổng số gia sư đã được duyệt
/// - Chờ duyệt: Số gia sư đang chờ phê duyệt (click để xem chi tiết)
/// - Bản đồ Nhiệt: Xem bản đồ nhu cầu thị trường (click để xem chi tiết)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/auth/presentation/auth_controller.dart';
import 'package:doantotnghiep/features/admin/data/admin_dashboard_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Màn hình dashboard của admin
/// 
/// **Usage:**
/// - Truy cập từ admin navigation → "Tổng quan"
/// - Hiển thị thống kê tổng quan và hoạt động gần đây
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Quản trị hệ thống', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => ref.invalidate(adminDashboardStatsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          // Format currency cho doanh thu
          final currencyFormat = NumberFormat.compactCurrency(locale: 'vi_VN', symbol: 'đ');
          
          // Parse revenue từ backend (có thể là num hoặc string)
          final revenueVal = stats['total_revenue'];
          final revenueNum = revenueVal is num 
              ? revenueVal 
              : double.tryParse(revenueVal?.toString() ?? '0') ?? 0;
          final revenue = currencyFormat.format(revenueNum);
          
          // Parse các thống kê khác
          final users = stats['total_users']?.toString() ?? '0';
          final tutors = stats['total_tutors']?.toString() ?? '0';
          final pending = stats['pending_tutors']?.toString() ?? '0';
          final activities = stats['activities'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng quan hệ thống',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Tổng doanh thu',
                      value: revenue,
                      icon: Icons.attach_money,
                      color: const Color(0xFF6C5CE7),
                      gradient: const LinearGradient(colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)]),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Người dùng',
                      value: users,
                      icon: Icons.people,
                      color: const Color(0xFF00B894),
                      gradient: const LinearGradient(colors: [Color(0xFF55efc4), Color(0xFF00b894)]),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Gia sư',
                      value: tutors,
                      icon: Icons.school,
                      color: const Color(0xFFFD79A8),
                      gradient: const LinearGradient(colors: [Color(0xFFfdcb6e), Color(0xFFfd79a8)]),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Chờ duyệt',
                      value: pending,
                      icon: Icons.verified_user,
                      color: const Color(0xFF0984E3),
                      gradient: const LinearGradient(colors: [Color(0xFF74b9ff), Color(0xFF0984e3)]),
                      onTap: () => context.push('/admin/approve'),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Bản đồ Nhiệt',
                      value: 'Live',
                      icon: Icons.map_outlined,
                      color: const Color(0xFFE84393),
                      gradient: const LinearGradient(colors: [Color(0xFFfd79a8), Color(0xFFe84393)]),
                      onTap: () => context.push('/admin/market-map'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Hoạt động gần đây',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                _buildActivityList(activities),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu: $err')),
      ),
    );
  }

  /// Build stat card widget
  /// 
  /// **Purpose:**
  /// - Hiển thị một thống kê dưới dạng card với gradient background
  /// - Có thể click để navigate đến màn hình chi tiết
  /// 
  /// **Parameters:**
  /// - `title`: Tiêu đề của stat (e.g., "Tổng doanh thu")
  /// - `value`: Giá trị hiển thị (e.g., "1.2M đ")
  /// - `icon`: Icon hiển thị
  /// - `color`: Màu chủ đạo
  /// - `gradient`: Gradient background
  /// - `onTap`: Callback khi click (optional)
  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      required Gradient gradient,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build activity list widget
  /// 
  /// **Purpose:**
  /// - Hiển thị danh sách hoạt động gần đây của hệ thống
  /// - Mỗi activity có title, body và time_ago
  /// 
  /// **Parameters:**
  /// - `activities`: List các activity objects từ API
  Widget _buildActivityList(List<dynamic> activities) {
    // Empty state: Hiển thị khi chưa có hoạt động
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            const Text(
              "Chưa có hoạt động nào.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final act = activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.notifications, color: Colors.blue, size: 20),
            ),
            title: Text(act['title'] ?? 'Thông báo'),
            subtitle: Text(act['body'] ?? ''),
            trailing: Text(act['time_ago'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
