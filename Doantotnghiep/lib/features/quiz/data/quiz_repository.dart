import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../domain/models/quiz.dart';
import '../domain/models/quiz_attempt.dart';

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  Future<List<Quiz>> getQuizzes({int? tutorId, int? courseId, int? studentId, int? studyGroupId}) async {
    final Map<String, dynamic> params = {};
    if (tutorId != null) params['tutor_id'] = tutorId;
    if (courseId != null) params['course_id'] = courseId;
    if (studentId != null) params['student_id'] = studentId;
    if (studyGroupId != null) params['study_group_id'] = studyGroupId;
    
    final response = await _apiClient.get(
      '/quizzes',
      queryParameters: params.isEmpty ? null : params,
    );
    
    final List listData = response is List ? response : (response['data'] ?? []);
    return listData.map((e) => Quiz.fromJson(e)).toList();
  }

  Future<Quiz> getQuizDetail(int id) async {
    final response = await _apiClient.get('/quizzes/$id');
    return Quiz.fromJson(response);
  }

  Future<Quiz> createQuiz(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/quizzes', data: data);
    return Quiz.fromJson(response);
  }

  Future<Quiz> updateQuiz(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/quizzes/$id', data: data);
    return Quiz.fromJson(response);
  }

  Future<void> deleteQuiz(int id) async {
    await _apiClient.delete('/quizzes/$id');
  }

  Future<Map<String, dynamic>> submitQuiz(int id, List<Map<String, dynamic>> answers) async {
    final response = await _apiClient.post(
      '/quizzes/$id/submit',
      data: {'answers': answers},
    );
    return response;
  }

  Future<List<QuizAttempt>> getAttempts() async {
    final response = await _apiClient.get('/my-quiz-attempts');
    return (response as List).map((e) => QuizAttempt.fromJson(e)).toList();
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(apiClientProvider));
});
