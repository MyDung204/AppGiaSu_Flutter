import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'quiz_question.dart';

class Quiz {
  final int id;
  final int tutorId;
  final String title;
  final String? description;
  final int? timeLimitMinutes;
  final bool isPublished;
  final List<QuizQuestion> questions;
  final Tutor? tutor;
  final int? courseId;
  final int? studentId;
  final int? studyGroupId;
  final List<Map<String, dynamic>> completedStudents;
  final List<Map<String, dynamic>> pendingStudents;

  Quiz({
    required this.id,
    required this.tutorId,
    required this.title,
    this.description,
    this.timeLimitMinutes,
    required this.isPublished,
    this.questions = const [],
    this.tutor,
    this.courseId,
    this.studentId,
    this.studyGroupId,
    this.completedStudents = const [],
    this.pendingStudents = const [],
  });

  int get questionsCount => questions.length;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      tutorId: json['tutor_id'],
      title: json['title'],
      description: json['description'],
      timeLimitMinutes: json['time_limit_minutes'],
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      courseId: json['course_id'],
      studentId: json['student_id'],
      studyGroupId: json['study_group_id'],
      questions:
          (json['questions'] as List?)
              ?.map((e) => QuizQuestion.fromJson(e))
              .toList() ??
          [],
      tutor: json['tutor'] != null ? Tutor.fromJson(json['tutor']) : null,
      completedStudents:
          (json['completed_students'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      pendingStudents:
          (json['pending_students'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'title': title,
      'description': description,
      'time_limit_minutes': timeLimitMinutes,
      'is_published': isPublished,
      'course_id': courseId,
      'student_id': studentId,
      'study_group_id': studyGroupId,
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }
}
