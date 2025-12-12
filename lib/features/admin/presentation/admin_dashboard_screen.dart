import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Quản trị hệ thống', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  value: '45.2M',
                  icon: Icons.attach_money,
                  color: const Color(0xFF6C5CE7),
                  gradient: const LinearGradient(colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)]),
                ),
                _buildStatCard(
                  context,
                  title: 'Người dùng',
                  value: '1,234',
                  icon: Icons.people,
                  color: const Color(0xFF00B894),
                  gradient: const LinearGradient(colors: [Color(0xFF55efc4), Color(0xFF00b894)]),
                ),
                _buildStatCard(
                  context,
                  title: 'Gia sư',
                  value: '89',
                  icon: Icons.school,
                  color: const Color(0xFFFD79A8),
                  gradient: const LinearGradient(colors: [Color(0xFFfdcb6e), Color(0xFFfd79a8)]),
                ),
                _buildStatCard(
                  context,
                  title: 'Chờ duyệt',
                  value: '12',
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
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
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
            title: Text('Gia sư Nguyễn Văn ${String.fromCharCode(65 + index)} vừa đăng ký'),
            subtitle: Text('${index + 2} phút trước'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        );
      },
    );
  }
}
