import 'package:doantotnghiep/features/chat/data/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
             return const Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(conv.partnerAvatar),
                    onBackgroundImageError: (_, __) => const Icon(Icons.person),
                  ),
                  title: Text(conv.partnerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(DateFormat('HH:mm').format(conv.lastMessageTime), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       if (conv.unreadCount > 0)
                         Container(
                           margin: const EdgeInsets.only(top: 4),
                           padding: const EdgeInsets.all(6),
                           decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                           child: Text(conv.unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                         )
                    ],
                  ),
                  onTap: () {
                    context.push('/chat', extra: {
                        'conversation_id': conv.id,
                        'partner_id': conv.partnerId,
                        'partner_name': conv.partnerName,
                        'partner_avatar': conv.partnerAvatar
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
