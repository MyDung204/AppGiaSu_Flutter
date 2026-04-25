/// Tutor Repository
/// 
/// Handles all tutor-related data operations.
library;

import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/core/exceptions/app_exceptions.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/search/domain/models/search_filter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for TutorRepository
final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TutorRepositoryImpl(apiClient);
});

/// Abstract interface for Tutor Repository
abstract class TutorRepository {
  Future<List<Tutor>> getFeaturedTutors();
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter});
  Future<List<Map<String, dynamic>>> getAvailability(String tutorId);
  Future<bool> updateAvailability(List<Map<String, dynamic>> availabilities);
  Future<List<Map<String, dynamic>>> getMyAvailability();
  Future<bool> requestWithdrawal(String bankName, String accountNumber, double amount);
  Future<Tutor?> getTutorById(String id);
  Future<bool> toggleFavorite(String tutorId);
  Future<List<Tutor>> getFavoriteTutors();
  Future<Map<String, dynamic>> getMyStatistics();
  Future<List<Map<String, dynamic>>> getMyTuitions();
  Future<List<Map<String, dynamic>>> getMyMaterials({int? courseId, int? studentId, int? studyGroupId});
  Future<Map<String, dynamic>> uploadMaterial(String filePath, {int? courseId, int? studentId, int? studyGroupId});
  Future<bool> deleteMaterial(String id);
  Future<bool> updateMaterial(String id, String name);
}

/// Implementation of TutorRepository
class TutorRepositoryImpl implements TutorRepository {
  final ApiClient _apiClient;

  TutorRepositoryImpl(this._apiClient);

  @override
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter}) async {
    try {
      final Map<String, dynamic> params = {'search': query};

      if (filter != null) {
        if (filter.minPrice != null) params['min_price'] = filter.minPrice;
        if (filter.maxPrice != null) params['max_price'] = filter.maxPrice;
        if (filter.gender != null && filter.gender != 'Bất kỳ') {
          params['gender'] = filter.gender;
        }
        if (filter.location != null) params['location'] = filter.location;
        if (filter.teachingMode != null && filter.teachingMode!.isNotEmpty) {
          params['mode'] = filter.teachingMode!.join(',');
        }
        if (filter.subjects != null && filter.subjects!.isNotEmpty) {
          params['subjects'] = filter.subjects!.join(',');
        }
      }

      final response = await _apiClient.get(ApiConstants.tutors, queryParameters: params);
      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching tutors: $e');
      return [];
    }
  }

  @override
  Future<List<Tutor>> getFeaturedTutors() async {
    try {
      final response = await _apiClient.get(ApiConstants.tutors, queryParameters: {'featured': 1});
      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting featured tutors: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailability(String tutorId) async {
    try {
      final response = await _apiClient.get('/tutors/$tutorId/availability');
      if (response is List) return List<Map<String, dynamic>>.from(response);
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateAvailability(List<Map<String, dynamic>> availabilities) async {
    try {
      await _apiClient.post('/tutors/availability', data: {'availabilities': availabilities});
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyAvailability() async {
    try {
      final response = await _apiClient.get('/tutors/my-availability');
      if (response is List) return List<Map<String, dynamic>>.from(response);
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> requestWithdrawal(String bankName, String accountNumber, double amount) async {
    try {
      await _apiClient.post('/wallet/withdraw', data: {
        'bank_name': bankName,
        'account_number': accountNumber,
        'amount': amount,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Tutor?> getTutorById(String id) async {
    try {
      final response = await _apiClient.get('/tutors/$id');
      if (response is Map<String, dynamic>) return Tutor.fromJson(response);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> toggleFavorite(String tutorId) async {
    try {
      final response = await _apiClient.post('/tutors/$tutorId/favorite');
      return response['is_favorite'] ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Tutor>> getFavoriteTutors() async {
    try {
      final response = await _apiClient.get('/favorites/tutors');
      if (response is List) return response.map((e) => Tutor.fromJson(e)).toList();
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getMyStatistics() async {
    try {
      final response = await _apiClient.get('/tutors/my-statistics');
      return response as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyTuitions() async {
    try {
      final response = await _apiClient.get('/tutors/my-tuitions');
      if (response is List) return List<Map<String, dynamic>>.from(response);
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyMaterials({int? courseId, int? studentId, int? studyGroupId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (courseId != null) params['course_id'] = courseId;
      if (studentId != null) params['student_id'] = studentId;
      if (studyGroupId != null) params['study_group_id'] = studyGroupId;

      final response = await _apiClient.get('/tutors/materials', queryParameters: params);
      if (response is List) return List<Map<String, dynamic>>.from(response);
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> uploadMaterial(String filePath, {int? courseId, int? studentId, int? studyGroupId}) async {
    try {
      String fileName = filePath.split(RegExp(r'[\\/]')).last;
      final Map<String, dynamic> data = {
        "material": await MultipartFile.fromFile(filePath, filename: fileName),
      };
      if (courseId != null) data['course_id'] = courseId;
      if (studentId != null) data['student_id'] = studentId;
      if (studyGroupId != null) data['study_group_id'] = studyGroupId;

      FormData formData = FormData.fromMap(data);
      final response = await _apiClient.post('/tutors/upload-material', data: formData);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteMaterial(String id) async {
    try {
      await _apiClient.delete('/tutors/materials/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateMaterial(String id, String name) async {
    try {
      await _apiClient.put('/tutors/materials/$id', data: {'name': name});
      return true;
    } catch (e) {
      return false;
    }
  }
}
