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

  Future<void> fetchMaterials() async {
    state = const AsyncValue.loading();
    try {
      final materials = await _repository.getMyMaterials();
      state = AsyncValue.data(materials);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> uploadMaterial(String filePath) async {
    try {
      await _repository.uploadMaterial(filePath);
      await fetchMaterials(); // Refresh list
      return true;
    } catch (e) {
      print('Error in provider upload: $e');
      return false;
    }
  }

  Future<bool> deleteMaterial(String id) async {
    try {
      final success = await _repository.deleteMaterial(id);
      if (success) {
        await fetchMaterials(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error in provider delete: $e');
      return false;
    }
  }
}
