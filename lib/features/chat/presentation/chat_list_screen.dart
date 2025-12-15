import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';

// Mock Tutor for demo
final mockTutorsForChat = [
  Tutor(
    id: 'tutor-1',
    name: 'Cô Lan (Toán)',
    bio: 'Chuyên dạy Toán cấp 2, 3.',
    hourlyRate: 150000,
    subjects: ['Toán'],
    rating: 4.8,
    avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
    reviewCount: 120,
    location: 'TP. Hồ Chí Minh',
    gender: 'Nữ',
    teachingMode: ['Online', 'Offline'],
    address: 'Quận 1, TP.HCM',
    weeklySchedule: {},
  ),
  Tutor(
    id: 'tutor-2',
    name: 'Thầy Hưng (Lý)',
    bio: 'Luyện thi Đại học môn Lý.',
    hourlyRate: 200000,
    subjects: ['Lý'],
    rating: 4.9,
    avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    reviewCount: 85,
    location: 'Hà Nội',
    gender: 'Nam',
    teachingMode: ['Online'],
    address: 'Cầu Giấy, Hà Nội',
    weeklySchedule: {},
  ),
];

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockTutorsForChat.length,
        itemBuilder: (context, index) {
          final tutor = mockTutorsForChat[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(tutor.avatarUrl),
              ),
              title: Text(tutor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Chào bạn, mình có thể nhận lớp này...', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   const Text('10:30', style: TextStyle(fontSize: 12, color: Colors.grey)),
                   if (index == 0)
                     Container(
                       margin: const EdgeInsets.only(top: 4),
                       padding: const EdgeInsets.all(6),
                       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                       child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)),
                     )
                ],
              ),
              onTap: () {
                context.push('/chat', extra: tutor);
              },
            ),
          );
        },
      ),
    );
  }
}
