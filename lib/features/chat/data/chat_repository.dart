import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

class ChatRepository {
  final ApiClient _client;

  ChatRepository(this._client);

  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _client.get('/conversations');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMessages(int conversationId) async {
    try {
      final response = await _client.get('/conversations/$conversationId/messages');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<dynamic> sendMessage({int? conversationId, int? receiverId, required String content}) async {
    try {
      final data = {
        'content': content,
        if (conversationId != null) 'conversation_id': conversationId,
        if (receiverId != null) 'receiver_id': receiverId,
      };
      
      final response = await _client.post('/messages', data: data);
      return response;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Helper to find conversation ID by partner ID from list
  Future<int?> findConversationId(String partnerId) async {
    final convs = await getConversations();
    for (var c in convs) {
      // partner object inside conversation
      final partner = c['partner'];
      if (partner != null && partner['id'].toString() == partnerId) {
        return c['id'];
      }
    }
    return null;
  }
}
