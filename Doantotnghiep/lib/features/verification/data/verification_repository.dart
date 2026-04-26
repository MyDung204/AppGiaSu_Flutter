import 'dart:io';

import 'package:dio/dio.dart';
import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.watch(apiClientProvider));
});

enum VerificationStatus { none, pending, approved, rejected }

class VerificationState {
  final VerificationStatus status;
  final String? note;

  VerificationState({this.status = VerificationStatus.none, this.note});

  factory VerificationState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return VerificationState();

    final statusStr = json['status'] ?? 'none';
    final status = switch (statusStr) {
      'pending' => VerificationStatus.pending,
      'approved' => VerificationStatus.approved,
      'rejected' => VerificationStatus.rejected,
      _ => VerificationStatus.none,
    };

    return VerificationState(status: status, note: json['note']);
  }
}

class VerificationRepository {
  final ApiClient _client;

  VerificationRepository(this._client);

  Future<VerificationState> getStatus() async {
    try {
      final response = await _client.get('/verification/status');
      if (response == null) return VerificationState();
      return VerificationState.fromJson(response);
    } catch (e) {
      return VerificationState();
    }
  }

  Future<bool> submitRequest(File frontImage, {File? backImage}) async {
    try {
      final formData = FormData.fromMap({
        'front_image': await MultipartFile.fromFile(frontImage.path),
        if (backImage != null && backImage.path != frontImage.path)
          'back_image': await MultipartFile.fromFile(backImage.path),
      });

      await _client.post('/verification/submit', data: formData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
