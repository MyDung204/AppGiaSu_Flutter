import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorClassNotifier extends AsyncNotifier<List<TutorClass>> {
  @override
  Future<List<TutorClass>> build() async {
    final repo = ref.watch(sharedLearningRepositoryProvider);
    try {
      final courses = await repo.getCourses();
      
      return courses.map((c) => TutorClass(
        id: c.id,
        tutorId: c.tutorId,
        name: c.title,
        schedule: c.schedule,
        mode: 'Offline', 
        price: c.price,
        enrolledStudentCount: 0, // Pending backend support
        status: 'ongoing',
      )).toList();
      return [];
    } catch (e) {
      print('Error loading tutor classes: $e');
      return [];
    }
  }

  Future<void> addClass(TutorClass newClass) async {
    // TODO: Connect to Real Create Course API
    print('Creating class: ${newClass.name}');
    // Optimistic update or just reload
    ref.invalidateSelf();
  }
}

final tutorClassProvider = AsyncNotifierProvider<TutorClassNotifier, List<TutorClass>>(TutorClassNotifier.new);
