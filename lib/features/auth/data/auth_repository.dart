import 'dart:async';
import 'dart:convert';
import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/features/auth/domain/models/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

// Stream provider to listen to auth state changes
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final ApiClient _apiClient;
  final _authStateController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  AuthRepository(this._apiClient) {
    _restoreSession();
  }

  Stream<AppUser?> get authStateChanges => _authStateController.stream;
  AppUser? get currentUser => _currentUser;

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');

    if (token != null && userJson != null) {
      try {
        _currentUser = AppUser.fromJson(jsonDecode(userJson));
        _authStateController.add(_currentUser);
      } catch (e) {
        await signOut();
      }
    } else {
       _authStateController.add(null);
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _apiClient.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final user = AppUser.fromJson(response['user']);

      await _saveSession(token, user);
      return user;
    } catch (e) {
      throw 'Đăng nhập thất bại: ${e.toString()}';
    }
  }

  Future<AppUser?> signUpWithEmailAndPassword(String name, String email, String password, String role) async {
    try {
      final response = await _apiClient.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      final token = response['token'];
      final user = AppUser.fromJson(response['user']);

      await _saveSession(token, user);
      return user;
    } catch (e) {
      throw 'Đăng ký thất bại: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
  }

  Future<void> _saveSession(String token, AppUser user) async {
    _currentUser = user;
    _authStateController.add(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    await prefs.setString('user_role', user.role);
  }

  // Helper for existing code compatibility
  Future<String?> getUserRole(String uid) async {
    return _currentUser?.role;
  }
  
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      await _apiClient.post('/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> saveUserRole(String uid, String role) async {
     // No-op for API (handled by backend)
  }
}
