import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/search/domain/models/search_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TutorRepositoryImpl(apiClient);
});

abstract class TutorRepository {
  Future<List<Tutor>> getFeaturedTutors();
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter});
}

class TutorRepositoryImpl implements TutorRepository {
  final ApiClient _apiClient;

  TutorRepositoryImpl(this._apiClient);

  @override
  Future<List<Tutor>> getFeaturedTutors() async {
    try {
      // Call Laravel API: GET /tutors?featured=1
      final response = await _apiClient.get(ApiConstants.tutors, queryParameters: {'featured': 1});
      
      // Parse JSON
      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Fail silently or log error for now since backend might not be ready
      print('API Error (Featured Tutors): $e');
      return [];
    }
  }

  @override
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter}) async {
    try {
      final Map<String, dynamic> params = {'search': query};

      if (filter != null) {
        if (filter.minPrice != null) params['min_price'] = filter.minPrice;
        if (filter.maxPrice != null) params['max_price'] = filter.maxPrice;
        if (filter.gender != null) params['gender'] = filter.gender;
        if (filter.location != null) params['location'] = filter.location;
        if (filter.teachingMode != null && filter.teachingMode!.isNotEmpty) {
          params['mode'] = filter.teachingMode!.join(',');
        }
      if (filter.subjects != null && filter.subjects!.isNotEmpty) {
           params['subjects'] = filter.subjects!.join(',');
      } // Corrected closing brace for filter != null (was missing in target?)
      }

      print('Searching Tutors with Params: $params'); 

      // Call Laravel API: GET /tutors?search=...
      final response = await _apiClient.get(ApiConstants.tutors, queryParameters: params);

      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API Error (Search Tutors): $e');
      return [];
    }
  }
}
