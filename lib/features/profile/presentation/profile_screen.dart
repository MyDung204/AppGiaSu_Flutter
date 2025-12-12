import 'package:doantotnghiep/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    // Simple Role Detection based on current location/context assumption
    // If we are nested in TutorScaffold, the path starts with /tutor-dashboard.
    // However, ProfileScreen is shared.
    // Let's check GoRouterState.
    final String location = GoRouterState.of(context).uri.toString();
    final bool isTutor = location.startsWith('/tutor-dashboard');

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user'),
            ),
            const SizedBox(height: 16),
            Text(
              isTutor ? 'Gia sư Nguyễn Văn A' : 'Lê Mỹ Dung', // Mock Name
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(isTutor ? 'Gia sư' : 'Học viên', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(context, Icons.account_balance_wallet, 'Ví của tôi', () => context.push('/wallet')),
            _buildMenuItem(
              context, 
              Icons.history, 
              'Lịch sử buổi học', 
              () {
                if (isTutor) {
                   context.go('/tutor-dashboard/manage-schedule'); // Or schedule if we separate
                } else {
                   context.go('/schedule');
                }
              }
            ),
            _buildMenuItem(
              context, 
              Icons.verified_user, 
              'Xác thực danh tính (eKYC)', 
              () => context.push(Uri(path: '/ekyc', queryParameters: {'isTutor': isTutor.toString()}).toString())
            ),
            _buildMenuItem(context, Icons.settings, 'Cài đặt', () {}),
            const Divider(),
            _buildMenuItem(
              context,
              Icons.logout,
              'Đăng xuất',
              () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
