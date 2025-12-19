import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorRequestsNotifier extends AsyncNotifier<List<TutorRequest>> {
  @override
  Future<List<TutorRequest>> build() async {
    final repo = ref.watch(sharedLearningRepositoryProvider);
    try {
      final groups = await repo.getStudyGroups();
      
      return groups.map((g) => TutorRequest(
        id: g.id,
        studentId: g.creatorId,
        studentName: g.creatorName,
        subject: g.subject,
        gradeLevel: g.gradeLevel,
        minBudget: 0,
        maxBudget: 0,
        schedule: 'Thỏa thuận',
        description: g.description,
        location: 'Tùy chọn',
        createdAt: g.createdAt,
      )).toList();
    } catch (e) {
      print('Error fetching requests: $e');
      return [];
    }
  }

  Future<void> addRequest(TutorRequest request) async {
    final repo = ref.read(sharedLearningRepositoryProvider);
    // TODO: Implement proper ID generation or let backend handle it
    // Mapping TutorRequest back to GroupRequest requires importing GroupRequest model
    // For now, we print to fix compilation and invalidate.
    print('Adding request: ${request.subject}');
    ref.invalidateSelf();
  }

  Future<void> removeRequest(String id) async {
     print('Removing request: $id');
     ref.invalidateSelf();
  }
}

final tutorRequestsProvider = AsyncNotifierProvider<TutorRequestsNotifier, List<TutorRequest>>(TutorRequestsNotifier.new);
