import 'package:doantotnghiep/features/chat/domain/models/course_offer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isSystem; // New field for system notifications
  final CourseOffer? offer;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isSystem = false,
    this.offer,
  });
}

// Map<TutorID, List<ChatMessage>>
class ChatState extends Notifier<Map<String, List<ChatMessage>>> {
  @override
  Map<String, List<ChatMessage>> build() {
    return {};
  }

  void sendMessage(String tutorId, String text, {bool isUser = true, bool isSystem = false, CourseOffer? offer}) {
    final currentMessages = state[tutorId] ?? [];
    
    // Mock initial greeting if empty
    if (currentMessages.isEmpty && !isSystem) {
       currentMessages.add(ChatMessage(
        text: 'Chào bạn, mình có thể giúp gì cho bạn?',
        isUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ));
    }

    state = {
      ...state,
      tutorId: [
        ...currentMessages,
        ChatMessage(
          text: text,
          isUser: isUser,
          time: DateTime.now(),
          isSystem: isSystem,
          offer: offer,
        ),
      ],
    };
  }
}

final chatProvider = NotifierProvider<ChatState, Map<String, List<ChatMessage>>>(ChatState.new);
