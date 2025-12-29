import 'package:doantotnghiep/features/chat/domain/models/course_offer.dart';

class ChatMessage {
  final int? id;
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isSystem;
  final CourseOffer? offer;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.isSystem = false,
    this.offer,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Assuming backend returns: id, content, sender_id, created_at
    // And system messages might have sender_id = null or specific type?
    // For now assuming all are user messages.
    final senderId = json['sender_id'];
    final isUser = senderId == currentUserId;

    return ChatMessage(
      id: json['id'],
      text: json['content'] ?? '',
      isUser: isUser,
      time: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isSystem: false, // Default
      // offer: ... parse if content is JSON?
    );
  }
}
