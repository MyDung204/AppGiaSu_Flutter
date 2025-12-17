import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedLearningRepositoryProvider = Provider<SharedLearningRepository>((ref) {
  return SharedLearningRepository(ref.watch(apiClientProvider));
});

class SharedLearningRepository {
  final ApiClient _client;

  SharedLearningRepository(this._client);

  Future<List<GroupRequest>> getStudyGroups() async {
    try {
      final response = await _client.get('/study-groups');
      if (response is List) {
        return response.map((e) => GroupRequest.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching study groups: $e');
      return [];
    }
  }

  Future<bool> createStudyGroup(GroupRequest req) async {
    try {
      await _client.post('/study-groups', data: {
        'topic': req.subject, 
        'subject': req.subject,
        'grade_level': req.gradeLevel,
        'max_members': req.maxMembers,
        'description': '${req.description}\n\nĐia điểm: ${req.location}\nHọc phí dự kiến: ${req.pricePerSession}',
      });
      return true;
    } catch (e) {
      print('Error creating study group: $e');
      return false;
    }
  }

  Future<List<Course>> getCourses() async {
    try {
      final response = await _client.get('/courses');
      if (response is List) {
        return response.map((e) => Course.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }
}
