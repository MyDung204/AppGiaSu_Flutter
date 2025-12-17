import 'package:doantotnghiep/features/chat/data/chat_repository.dart';
import 'package:doantotnghiep/features/chat/domain/models/conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getConversations();
});
