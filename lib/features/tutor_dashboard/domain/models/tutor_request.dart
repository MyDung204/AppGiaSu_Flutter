
class TutorRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String gradeLevel;
  final double minBudget;
  final double maxBudget;
  final String schedule; // e.g. "Mon, Wed, Fri 18:00"
  final String description;
  final String location;
  final DateTime createdAt;
  final String status; // 'open', 'closed'

  TutorRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.gradeLevel,
    required this.minBudget,
    required this.maxBudget,
    required this.schedule,
    required this.description,
    required this.location,
    required this.createdAt,
    this.status = 'open',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'schedule': schedule,
      'description': description,
      'location': location,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory TutorRequest.fromMap(Map<String, dynamic> map) {
    return TutorRequest(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      minBudget: (map['minBudget'] ?? 0).toDouble(),
      maxBudget: (map['maxBudget'] ?? 0).toDouble(),
      schedule: map['schedule'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      status: map['status'] ?? 'open',
    );
  }
}
