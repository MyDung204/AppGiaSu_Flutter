import 'dart:async';
import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/chat/data/chat_repository.dart';
import 'package:doantotnghiep/features/chat/domain/models/chat_message.dart';
import 'package:doantotnghiep/features/chat/domain/models/course_offer.dart';
import 'package:doantotnghiep/features/chat/domain/models/conversation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Conversations List (Unchanged)
final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getConversations();
  return res.map((e) => Conversation.fromJson(e)).toList();
});

// 2. Server Messages (Read-Only State from API)
final chatMessagesProvider = FutureProvider.autoDispose.family<List<ChatMessage>, String>((ref, partnerId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final user = ref.read(authRepositoryProvider).currentUser;
  final currentUserId = int.tryParse(user?.id ?? '0') ?? 0;

  final conversationId = await repo.findConversationId(partnerId);

  if (conversationId != null) {
    final msgsJson = await repo.getMessages(conversationId);
    return msgsJson.map((e) => ChatMessage.fromJson(e, currentUserId)).toList();
  }
  return [];
});

// 3. Pending Messages (Optimistic Updates - using StateProvider for simplicity)
final pendingMessagesProvider = StateProvider.autoDispose.family<List<ChatMessage>, String>((ref, partnerId) {
  return [];
});

// 4. Chat Controller (Orchestrator)
final chatControllerProvider = Provider.autoDispose.family<ChatController, String>((ref, partnerId) {
  return ChatController(ref, partnerId);
});

class ChatController {
  final Ref ref;
  final String partnerId;

  ChatController(this.ref, this.partnerId);

  Future<void> sendMessage(String text, {CourseOffer? offer}) async {
    final repo = ref.read(chatRepositoryProvider);
    
    // 1. Optimistic Update: Add to pending
    final tempId = -DateTime.now().millisecondsSinceEpoch; 
    final tempMessage = ChatMessage(
      id: tempId,
      text: text,
      isUser: true,
      time: DateTime.now(),
      offer: offer,
    );

    ref.read(pendingMessagesProvider(partnerId).notifier).update((state) => [...state, tempMessage]);

    try {
      final conversationId = await repo.findConversationId(partnerId);
      final response = await repo.sendMessage(
        conversationId: conversationId,
        receiverId: conversationId == null ? int.tryParse(partnerId) : null,
        content: text,
      );

      if (response != null) {
        // 2. Success: Refresh server messages
        // We await the refresh so the new message appears in server list
        await ref.refresh(chatMessagesProvider(partnerId).future);
        
        // 3. Remove from pending (now it's in server list)
        ref.read(pendingMessagesProvider(partnerId).notifier).update((state) => state.where((m) => m.id != tempId).toList());
      }
    } catch (e) {
      print("Send message failed: $e");
      // Optional: keep in pending or handle error
    }
  }
}
