

class GroupRequest {
  final String id;
  final String creatorId;
  final String creatorName;
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

  GroupRequest({
    required this.id,
    required this.creatorId,
    required this.creatorName,
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
  });

  GroupRequest copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
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
  }) {
    return GroupRequest(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'pricePerSession': pricePerSession,
      'location': location,
      'description': description,
      'currentMembers': currentMembers,
      'maxMembers': maxMembers,
      'minMembers': minMembers,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'status': status,
    };
  }
}
