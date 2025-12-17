class Conversation {
  final String id;
  final String partnerId;
  final String partnerName;
  final String partnerAvatar;
  final String lastMessage; // content
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Determine partner from backend response (assuming backend sends 'partner' object or similar)
    // Adjust logic based on actual backend response
    final partner = json['partner'] ?? {};
    return Conversation(
      id: json['id'].toString(),
      partnerId: partner['id']?.toString() ?? '',
      partnerName: partner['name'] ?? 'Người dùng',
      partnerAvatar: partner['avatar_url'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
