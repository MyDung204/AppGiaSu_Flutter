
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
  final DateTime createdAt;
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
    required this.createdAt,
    this.status = 'open',
  });

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
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status,
    };
  }
}
