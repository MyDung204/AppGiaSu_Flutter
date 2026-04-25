

class GroupRequest {
  final String id;
  final String creatorId;
  final String creatorName;
  final String topic;
  final String subject;
  final String gradeLevel;
  final double pricePerSession; // Per person
  final String location;
  final String description;
  final int currentMembers;
  final int maxMembers;
  final int minMembers;
  final DateTime createdAt;
  final DateTime startTime;
  final String status; // 'open', 'full', 'closed'
  final String? membershipStatus;
  final DateTime? expectedOpeningTime;
  final DateTime? paymentDeadline;
  final int pendingRequestsCount;
  final bool hasNewMessages;
  final String? quizId;
  final String paymentStatus; // 'pending', 'paid'
  final DateTime? joinedAt;

  GroupRequest({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.topic,
    required this.subject,
    required this.gradeLevel,
    required this.pricePerSession,
    required this.location,
    required this.description,
    this.currentMembers = 1,
    required this.maxMembers,
    this.minMembers = 2,
    required this.createdAt,
    required this.startTime,
    this.status = 'open',
    this.membershipStatus,
    this.expectedOpeningTime,
    this.paymentDeadline,
    this.pendingRequestsCount = 0,
    this.hasNewMessages = false,
    this.quizId,
    this.paymentStatus = 'pending',
    this.joinedAt,
  });

  GroupRequest copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? topic,
    String? subject,
    String? gradeLevel,
    double? pricePerSession,
    String? location,
    String? description,
    int? currentMembers,
    int? maxMembers,
    int? minMembers,
    DateTime? createdAt,
    DateTime? startTime,
    String? status,
    String? membershipStatus,
    DateTime? expectedOpeningTime,
    DateTime? paymentDeadline,
    String? quizId,
    String? paymentStatus,
    DateTime? joinedAt,
  }) {
    return GroupRequest(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      topic: topic ?? this.topic,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      pricePerSession: pricePerSession ?? this.pricePerSession,
      location: location ?? this.location,
      description: description ?? this.description,
      currentMembers: currentMembers ?? this.currentMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      minMembers: minMembers ?? this.minMembers,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      expectedOpeningTime: expectedOpeningTime ?? this.expectedOpeningTime,
      paymentDeadline: paymentDeadline ?? this.paymentDeadline,
      quizId: quizId ?? this.quizId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory GroupRequest.fromJson(Map<String, dynamic> json) {
    if (json['pending_requests_count'] != null) {
      print('DEBUG: Group ${json['topic']} has pending: ${json['pending_requests_count']}');
    }
    return GroupRequest(
      id: json['id'].toString(),
      creatorId: json['creator_id']?.toString() ?? '',
      creatorName: json['creator']?['name'] ?? 'Unknown',
      topic: json['topic'] ?? '',
      subject: json['subject'] ?? '',
      gradeLevel: json['grade_level'] ?? '',
      pricePerSession: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      location: json['location'] ?? 'Online',
      description: json['description'] ?? '',
      currentMembers: json['current_members'] ?? 1,
      maxMembers: json['max_members'] ?? 5,
      minMembers: 2,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      startTime: json['expected_opening_time'] != null ? DateTime.parse(json['expected_opening_time']) : DateTime.now(),
      status: json['status'] ?? 'open',
      membershipStatus: json['membership_status'],
      expectedOpeningTime: json['expected_opening_time'] != null ? DateTime.parse(json['expected_opening_time']) : null,
      paymentDeadline: json['payment_deadline'] != null ? DateTime.parse(json['payment_deadline']) : null,
      pendingRequestsCount: json['pending_requests_count'] ?? 0,
      hasNewMessages: json['has_new_messages'] ?? false,
      quizId: json['quiz_id']?.toString(),
      paymentStatus: json['payment_status'] ?? 'pending',
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'topic': topic,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'pricePerSession': pricePerSession,
      'location': location,
      'description': description,
      'currentMembers': currentMembers,
      'maxMembers': maxMembers,
      'minMembers': minMembers,
      'createdAt': createdAt.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'status': status,
      'quiz_id': quizId,
    };
  }
}
