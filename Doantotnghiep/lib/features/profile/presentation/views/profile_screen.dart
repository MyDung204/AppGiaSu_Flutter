import 'package:doantotnghiep/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/features/notification/presentation/providers/notification_provider.dart';
import 'package:doantotnghiep/features/verification/data/verification_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileViewModelProvider);
    final user = userAsync.value;

    // ... logic ...
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isTutor ? 'Gia sư' : 'Học viên',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              Icons.account_balance_wallet,
              'Ví & Thu nhập',
              () => context.push('/wallet'),
            ),

            if (isTutor) ...[
              _buildMenuItem(
                context,
                Icons.quiz,
                'Quản lý Bài kiểm tra',
                () => context.push('/tutor-quiz-management'),
              ),
              _buildMenuItem(
                context,
                Icons.calendar_month,
                'Quản lý lịch dạy',
                () => context.push('/tutor-schedule-management'),
              ),
              _buildMenuItem(
                context,
                Icons.badge_outlined,
                'Chỉnh sửa hồ sơ gia sư',
                () => context.push(
                  '/tutor-profile-edit',
                  extra: user?.tutorProfile,
                ),
              ),
              _buildMenuItem(
                context,
                Icons.folder_shared_outlined,
                'Quản lý tài liệu',
                () => context.push('/tutor-materials'),
              ),
            ],

            _buildMenuItem(context, Icons.history, 'Lịch sử buổi học', () {
              context.push('/schedule');
            }),
            if (!isTutor) ...[
              _buildMenuItem(
                context,
                Icons.favorite,
                'Gia sư yêu thích',
                () => context.push('/favorite-tutors'),
              ),
              _buildMenuItem(
                context,
                Icons.quiz_outlined,
                'Bài thi trắc nghiệm',
                () => context.push('/quizzes'),
              ),
              _buildMenuItem(
                context,
                Icons.assignment,
                'Yêu cầu tìm dạy kèm 1-1',
                () => context.push('/my-requests'),
              ),
              _buildMenuItem(
                context,
                Icons.group,
                'Lớp học nhóm của tôi',
                () => context.push('/my-enrolled-classes'),
              ),
            ],

            _buildMenuItem(
              context,
              Icons.verified_user,
              'Xác thực danh tính (eKYC)',
              () async {
                final latestStatus = await ref.read(verificationRepositoryProvider).getStatus();
                if (!context.mounted) return;

                final isVerified = isTutor
                    ? (user?.tutorProfile?['is_verified'] == true ||
                          user?.tutorProfile?['is_verified'] == 1)
                    : false;
                final hasApprovedVerification =
                    latestStatus.status == VerificationStatus.approved ||
                    isVerified ||
                    user?.identityVerifiedAt != null;

                if (hasApprovedVerification) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đã xác thực danh tính thành công.'),
                    ),
                  );
                } else {
                  context.push(
                    Uri(
                      path: '/ekyc',
                      queryParameters: {'isTutor': isTutor.toString()},
                    ).toString(),
                  );
                }
              },
            ),
            _buildMenuItem(
              context,
              Icons.settings,
              'Cài đặt',
              () => context.push('/settings'),
            ),
            _buildMenuItem(
              context,
              Icons.notifications_active,
              'Test Notification',
              () async {
                final service = ref.read(notificationServiceProvider);
                await service.showNotification(
                  title: 'Test Notification',
                  body: 'Nếu bạn thấy thông báo này, app đã nhận quyền!',
                );
              },
            ),
            const Divider(),
            _buildMenuItem(context, Icons.logout, 'Đăng xuất', () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Đồng ý'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              await ref.read(profileViewModelProvider.notifier).logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng xuất thành công')),
                );
                context.go('/login');
              }
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
