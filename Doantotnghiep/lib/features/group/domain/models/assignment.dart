
class Assignment {
  final int id;
  final int? courseId;
  final int? studyGroupId;
  final int? studentId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? attachmentUrl;
  final DateTime createdAt;
  final int submissionCount;
  final bool isSubmitted;
  final AssignmentSubmission? mySubmission;

  Assignment({
    required this.id,
    this.courseId,
    this.studyGroupId,
    this.studentId,
    required this.title,
    this.description,
    this.dueDate,
    this.attachmentUrl,
    required this.createdAt,
    this.submissionCount = 0,
    this.isSubmitted = false,
    this.mySubmission,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      courseId: json['course_id'] != null ? (json['course_id'] is String ? int.parse(json['course_id']) : json['course_id']) : null,
      studyGroupId: json['study_group_id'] != null ? (json['study_group_id'] is String ? int.parse(json['study_group_id']) : json['study_group_id']) : null,
      studentId: json['student_id'] != null ? (json['student_id'] is String ? int.parse(json['student_id']) : json['student_id']) : null,
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      attachmentUrl: json['attachment_url'],
      createdAt: DateTime.parse(json['created_at']),
      submissionCount: json['submissions_count'] != null 
          ? (json['submissions_count'] is String ? int.parse(json['submissions_count']) : json['submissions_count']) 
          : 0,
      isSubmitted: json['is_submitted'] ?? false,
      mySubmission: json['my_submission'] != null ? AssignmentSubmission.fromJson(json['my_submission']) : null,
    );
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

class AssignmentSubmission {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? content;
  final String? fileUrl;
  final DateTime submittedAt;
  final double? grade;
  final String? feedback;
  final StudentInfo? student;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.content,
    this.fileUrl,
    required this.submittedAt,
    this.grade,
    this.feedback,
    this.student,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: _parseInt(json['id']),
      assignmentId: _parseInt(json['assignment_id']),
      studentId: _parseInt(json['student_id']),
      content: json['content']?.toString(),
      fileUrl: json['file_url']?.toString(),
      submittedAt: _parseDateTime(json['submitted_at']),
      grade: _parseDouble(json['grade']),
      feedback: json['feedback'],
      student: json['student'] != null ? StudentInfo.fromJson(json['student']) : null,
    );
  }
}

class StudentInfo {
  final int id;
  final String name;
  final String? avatarUrl;

  StudentInfo({required this.id, required this.name, this.avatarUrl});

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Học viên',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
