import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';

// Mock Data
final _initialMockRequests = [
  TutorRequest(
    id: 'mock-1',
    studentId: 'test-student-id', // Matches current user if we mock auth or use this ID
    studentName: 'Học viên Mẫu',
    subject: 'Toán',
    gradeLevel: 'Lớp 12',
    minBudget: 150000,
    maxBudget: 200000,
    schedule: 'Tối 2-4-6',
    description: 'Cần gia sư kiên nhẫn.',
    location: 'Quận 1',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TutorRequest(
    id: 'mock-2',
    studentId: 'other-student',
    studentName: 'Trần Văn B',
    subject: 'Tiếng Anh',
    gradeLevel: 'IELTS',
    minBudget: 300000,
    maxBudget: 500000,
    schedule: 'Cuối tuần',
    description: 'Mục tiêu 6.5',
    location: 'Online',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];

class TutorRequestsNotifier extends Notifier<List<TutorRequest>> {
  @override
  List<TutorRequest> build() {
    return _initialMockRequests;
  }

  void addRequest(TutorRequest request) {
    state = [request, ...state];
  }

  void removeRequest(String id) {
    state = state.where((req) => req.id != id).toList();
  }
}

final tutorRequestsProvider = NotifierProvider<TutorRequestsNotifier, List<TutorRequest>>(TutorRequestsNotifier.new);
