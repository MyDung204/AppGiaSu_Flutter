/// Admin Users Screen
/// 
/// **Purpose:**
/// - Quản lý danh sách người dùng trong hệ thống
/// - Cho phép admin tìm kiếm, lọc theo role, và quản lý tài khoản
/// 
/// **Features:**
/// - Tìm kiếm người dùng theo tên, email
/// - Lọc theo role (Tất cả, Gia sư, Học viên)
/// - Xem thông tin người dùng
/// - Khóa/Mở khóa tài khoản
/// - Xóa người dùng (TODO: cần implement)
/// 
/// **User Actions:**
/// - Khóa tài khoản: Ngăn user đăng nhập và sử dụng hệ thống
/// - Mở khóa tài khoản: Khôi phục quyền truy cập
/// - Xóa người dùng: Xóa vĩnh viễn (cần xác nhận)

import 'package:doantotnghiep/features/admin/data/admin_repository.dart';
import 'package:doantotnghiep/features/admin/data/admin_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Màn hình quản lý người dùng của admin
/// 
/// **Usage:**
/// - Truy cập từ admin navigation → "Người dùng"
/// - Hiển thị danh sách tất cả người dùng với filter và search
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  String _selectedRole = 'All'; // All, Gia sư, Học viên

  @override
  Widget build(BuildContext context) {
    // Watch with params
    final usersAsync = ref.watch(adminUsersProvider(
      UserFilter(search: _searchQuery, role: _selectedRole),
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (val) {
                    // Debounce search: Đợi 500ms sau khi user ngừng gõ
                    // Tránh gọi API quá nhiều lần
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted && val == _searchQuery) return; // Đã thay đổi, bỏ qua
                      setState(() {
                        _searchQuery = val;
                      });
                    });
                  },
                  onSubmitted: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Gia sư', 'Gia sư'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Học viên', 'Học viên'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // User List
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Empty state: Hiển thị khi không tìm thấy user nào
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy người dùng nào.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Thử tìm kiếm với từ khóa khác.'
                              : 'Chưa có người dùng nào trong hệ thống.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
           setState(() => _selectedRole = value);
        }
      },
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  /// Build user card widget
  /// 
  /// **Purpose:**
  /// - Hiển thị thông tin một user dưới dạng card
  /// - Có menu actions để quản lý user (khóa, xóa)
  /// 
  /// **Parameters:**
  /// - `user`: User object từ API (Map<String, dynamic>)
  Widget _buildUserCard(Map<String, dynamic> user) {
     // Xác định role của user
     final isTutor = user['role'] == 'tutor' || user['role'] == 'Gia sư';
     
     // TODO: Backend cần trả về trạng thái ban status
     // Hiện tại mặc định là active (chưa bị khóa)
     final isBanned = user['is_banned'] == true || user['status'] == 'banned'; 
     
     final avatarUrl = user['avatar_url'] ?? (isTutor ? 'https://i.pravatar.cc/150?img=3' : 'https://i.pravatar.cc/150?img=5');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isTutor ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
          child: Icon(isTutor ? Icons.school : Icons.person, color: isTutor ? Colors.orange : Colors.blue),
        ),
        title: Text(
          user['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isTutor ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isTutor ? 'Gia sư' : 'Học viên',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isTutor ? Colors.orange : Colors.blue),
                  ),
                ),
                if (user['created_at'] != null) ...[
                   const SizedBox(width: 8),
                   Text(
                     'Tham gia: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(user['created_at']))}',
                     style: const TextStyle(fontSize: 10, color: Colors.grey),
                   ),
                ]
              ],
            )
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ban',
              child: Row(
                children: [
                  Icon(isBanned ? Icons.lock_open : Icons.block, color: isBanned ? Colors.green : Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(isBanned ? 'Mở khóa' : 'Khóa tài khoản'),
                ],
              ),
            ),
             const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text('Xóa người dùng'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'ban') {
              // Xác nhận trước khi khóa/mở khóa
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isBanned ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
                  content: Text(
                    isBanned
                        ? 'Bạn có chắc chắn muốn mở khóa tài khoản của ${user['name']}?'
                        : 'Bạn có chắc chắn muốn khóa tài khoản của ${user['name']}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => ctx.pop(false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: isBanned ? Colors.green : Colors.red,
                      ),
                      child: Text(isBanned ? 'Mở khóa' : 'Khóa'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final success = await ref.read(adminRepositoryProvider).toggleBan(user['id']);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBanned 
                              ? 'Đã mở khóa tài khoản thành công.'
                              : 'Đã khóa tài khoản thành công.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh user list
                    ref.invalidate(adminUsersProvider(UserFilter(
                      search: _searchQuery,
                      role: _selectedRole,
                    )));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật trạng thái thất bại. Vui lòng thử lại.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            } else if (value == 'delete') {
              // TODO: Implement delete user functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng xóa người dùng đang được phát triển.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
