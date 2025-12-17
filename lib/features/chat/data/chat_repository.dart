import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/features/chat/domain/models/conversation.dart';
import 'package:doantotnghiep/features/chat/domain/models/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

class ChatRepository {
  final ApiClient _client;

  ChatRepository(this._client);

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _client.get('/conversations');
      if (response is List) {
        return response.map((e) => Conversation.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _client.get('/conversations/$conversationId/messages');
      if (response is List) {
        return response.map((e) => Message.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<Message?> sendMessage({String? conversationId, String? receiverId, required String content}) async {
    try {
      final response = await _client.post('/messages', data: {
        if (conversationId != null) 'conversation_id': conversationId,
        if (receiverId != null) 'receiver_id': receiverId,
        'content': content,
      });
      return Message.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}
