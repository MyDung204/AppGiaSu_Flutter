import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorMaterialsProvider = StateNotifierProvider<TutorMaterialsNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repository = ref.watch(tutorRepositoryProvider);
  return TutorMaterialsNotifier(repository);
});

class TutorMaterialsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TutorRepository _repository;

  TutorMaterialsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchMaterials();
  }

  Future<void> fetchMaterials({int? courseId, int? studentId, int? studyGroupId}) async {
    state = const AsyncValue.loading();
    try {
      final materials = await _repository.getMyMaterials(
        courseId: courseId, 
        studentId: studentId,
        studyGroupId: studyGroupId,
      );
      state = AsyncValue.data(materials);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> uploadMaterial(String filePath, {int? courseId, int? studentId, int? studyGroupId}) async {
    try {
      await _repository.uploadMaterial(
        filePath, 
        courseId: courseId, 
        studentId: studentId,
        studyGroupId: studyGroupId,
      );
      await fetchMaterials(
        courseId: courseId, 
        studentId: studentId,
        studyGroupId: studyGroupId,
      ); // Refresh list with same context
      return true;
    } catch (e) {
      print('Error in provider upload: $e');
      return false;
    }
  }

  Future<bool> deleteMaterial(String id, {int? courseId, int? studentId, int? studyGroupId}) async {
    try {
      final success = await _repository.deleteMaterial(id);
      if (success) {
        await fetchMaterials(
          courseId: courseId, 
          studentId: studentId,
          studyGroupId: studyGroupId,
        ); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error in provider delete: $e');
      return false;
    }
  }

  Future<bool> updateMaterial(String id, String name, {int? courseId, int? studentId, int? studyGroupId}) async {
    try {
      final success = await _repository.updateMaterial(id, name);
      if (success) {
        await fetchMaterials(
          courseId: courseId, 
          studentId: studentId,
          studyGroupId: studyGroupId,
        );
      }
      return success;
    } catch (e) {
      print('Error in provider update: $e');
      return false;
    }
  }
}
