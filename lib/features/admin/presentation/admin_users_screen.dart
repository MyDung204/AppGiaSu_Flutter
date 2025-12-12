import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final isTutor = index % 3 == 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isTutor ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
              child: Icon(
                isTutor ? Icons.school : Icons.person,
                color: isTutor ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(isTutor ? 'Gia sư $index' : 'Học viên $index'),
            subtitle: Text(isTutor ? 'tutor$index@example.com' : 'student$index@example.com'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ban',
                  child: Text('Khóa tài khoản', style: TextStyle(color: Colors.red)),
                ),
                const PopupMenuItem(
                  value: 'view',
                  child: Text('Xem chi tiết'),
                ),
              ],
              onSelected: (value) {
                // Handle action
              },
            ),
          );
        },
      ),
    );
  }
}
