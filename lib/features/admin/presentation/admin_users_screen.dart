import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final List<Map<String, dynamic>> _users = List.generate(
    15,
    (index) => {
      'id': index,
      'name': index % 3 == 0 ? 'Gia sư Trần Văn $index' : 'Học viên Nguyễn Thị $index',
      'email': index % 3 == 0 ? 'tutor$index@example.com' : 'student$index@example.com',
      'role': index % 3 == 0 ? 'Gia sư' : 'Học viên',
      'isBanned': false,
      'joinDate': DateTime.now().subtract(Duration(days: index * 5)),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isTutor = user['role'] == 'Gia sư';
          final isBanned = user['isBanned'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isBanned 
                    ? Colors.grey 
                    : (isTutor ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
                child: Icon(
                  isTutor ? Icons.school : Icons.person,
                  color: isBanned ? Colors.white : (isTutor ? Colors.orange : Colors.blue),
                ),
              ),
              title: Text(
                user['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isBanned ? TextDecoration.lineThrough : null,
                  color: isBanned ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']),
                  Text(user['role'], style: TextStyle(fontSize: 12, color: isTutor ? Colors.orange : Colors.blue)),
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
                    value: 'view',
                    child: Row(
                      children: [
                         Icon(Icons.visibility, color: Colors.blue, size: 20),
                         SizedBox(width: 8),
                         Text('Xem chi tiết'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'ban') {
                    setState(() {
                      user['isBanned'] = !isBanned;
                    });
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isBanned ? 'Đã mở khóa tài khoản.' : 'Đã khóa tài khoản.')),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
