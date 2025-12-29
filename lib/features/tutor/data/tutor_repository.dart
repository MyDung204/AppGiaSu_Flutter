/// Tutor Repository
/// 
/// Handles all tutor-related data operations:
/// - Fetching featured tutors
/// - Searching tutors with filters
/// - Converting API responses to Tutor models
/// 
/// **Repository Pattern:**
/// - Abstracts data source (API) from business logic
/// - Makes code testable (can mock repository)
/// - Centralizes data access logic

import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/core/exceptions/app_exceptions.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/search/domain/models/search_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for TutorRepository
/// 
/// Creates a single repository instance shared across the app.
final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TutorRepositoryImpl(apiClient);
});

/// Abstract interface for Tutor Repository
/// 
/// Defines contract for tutor data operations.
/// Allows for easy testing and future implementations (e.g., offline cache).
abstract class TutorRepository {
  /// Get featured tutors (high-rated tutors)
  Future<List<Tutor>> getFeaturedTutors();
  
  /// Search tutors with query and optional filters
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter});
}

/// Implementation of TutorRepository
/// 
/// Fetches tutor data from Laravel API and converts to Tutor models.
class TutorRepositoryImpl implements TutorRepository {
  /// API client for making HTTP requests
  final ApiClient _apiClient;

  /// Initialize repository with API client
  TutorRepositoryImpl(this._apiClient);

  /// Get featured tutors (highly rated tutors)
  /// 
  /// **Purpose:**
  /// - Fetches tutors with rating >= 4.5
  /// - Used for home screen "Featured Tutors" section
  /// - Limited to 5 results (backend limit)
  /// 
  /// **Returns:**
  /// - `List<Tutor>`: List of featured tutors (empty list on error)
  /// 
  /// **Error Handling:**
  /// - Returns empty list on error (fails gracefully)
  /// - Logs error for debugging
  /// 
  /// **API Endpoint:**
  /// - `GET /tutors?featured=1`
  /// 
  /// **Example:**
  /// ```dart
  /// final featured = await repository.getFeaturedTutors();
  /// // Display on home screen
  /// ```
  @override
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter}) async {
    try {
      // Build query parameters map
      // Always include search query
      final Map<String, dynamic> params = {'search': query};

      // Add filter parameters if filter is provided
      if (filter != null) {
        // Price range filter
        if (filter.minPrice != null) params['min_price'] = filter.minPrice;
        if (filter.maxPrice != null) params['max_price'] = filter.maxPrice;
        
        // Gender filter
        if (filter.gender != null && filter.gender != 'Bất kỳ') {
          params['gender'] = filter.gender;
        }
        
        // Location filter
        if (filter.location != null) params['location'] = filter.location;
        
        // Teaching mode filter (Online/Offline)
        // Backend expects comma-separated string
        if (filter.teachingMode != null && filter.teachingMode!.isNotEmpty) {
          params['mode'] = filter.teachingMode!.join(',');
        }
        
        // Subjects filter
        // Backend expects comma-separated string
        if (filter.subjects != null && filter.subjects!.isNotEmpty) {
          params['subjects'] = filter.subjects!.join(',');
        }
      }

      // Debug: Log search parameters (remove in production)
      print('Searching Tutors with Params: $params'); 

      // Call Laravel API: GET /tutors?search=...&min_price=...&max_price=...
      final response = await _apiClient.get(ApiConstants.tutors, queryParameters: params);

      // Parse response
      // Backend returns List<Map> which we convert to List<Tutor>
      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      
      // Return empty list if response is not a List
      // This handles edge cases where backend returns unexpected format
      return [];
    } on ApiException catch (e) {
      // Handle API errors with user-friendly messages
      print('API Error (Search Tutors): ${e.userMessage}');
      return [];
    } catch (e) {
      // Handle unexpected errors
      print('Unexpected Error (Search Tutors): $e');
      return [];
    }
  }

  @override
  Future<List<Tutor>> getFeaturedTutors() async {
    try {
      // Call Laravel API: GET /tutors?featured=1
      // Backend returns tutors with rating >= 4.5, limited to 5 results
      final response = await _apiClient.get(
        ApiConstants.tutors, 
        queryParameters: {'featured': 1}
      );
      
      // Parse JSON response to Tutor objects
      if (response is List) {
        return response.map((e) => Tutor.fromJson(e)).toList();
      }
      
      // Return empty list if response format is unexpected
      return [];
    } on ApiException catch (e) {
      // Handle API errors gracefully
      // Fail silently to prevent app crash, but log for debugging
      print('API Error (Featured Tutors): ${e.userMessage}');
      return [];
    } catch (e) {
      // Handle unexpected errors
      print('Unexpected Error (Featured Tutors): $e');
      return [];
    }
  }
}
