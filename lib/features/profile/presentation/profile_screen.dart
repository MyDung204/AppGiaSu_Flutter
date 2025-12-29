import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoggingOut) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.value;
    
    // Simple Role Detection based on current location/context assumption
    // If we are nested in TutorScaffold, the path starts with /tutor-dashboard.
    // However, ProfileScreen is shared.
    // Let's check GoRouterState.
    // Use user role from auth state mostly
    final isTutor = user?.role == 'tutor';

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 50, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Người dùng',
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
                   // context.go('/tutor-dashboard/manage-schedule'); // If exists
                   // For simplicity redirect to generic schedule but context might diff
                   context.push('/schedule'); 
                } else {
                   context.push('/schedule');
                }
              }
            ),
             if (!isTutor) ...[
               _buildMenuItem(context, Icons.assignment, 'Yêu cầu tìm gia sư', () => context.push('/my-requests')),
               _buildMenuItem(context, Icons.group, 'Nhóm học của tôi', () => context.push('/my-study-groups')),
             ],
               
            _buildMenuItem(
              context, 
              Icons.verified_user, 
              'Xác thực danh tính (eKYC)', 
              () => context.push(Uri(path: '/ekyc', queryParameters: {'isTutor': isTutor.toString()}).toString())
            ),
            _buildMenuItem(context, Icons.settings, 'Cài đặt', () => context.push('/settings')),
            const Divider(),
            _buildMenuItem(
              context,
              Icons.logout,
              'Đăng xuất',
              () async {
                setState(() => _isLoggingOut = true);
                
                await ref.read(authControllerProvider.notifier).logout();
                if (mounted) context.go('/login');
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
