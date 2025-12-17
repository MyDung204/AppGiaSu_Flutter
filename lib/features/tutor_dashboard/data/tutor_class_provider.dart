
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorClassNotifier extends Notifier<List<TutorClass>> {
  @override
  List<TutorClass> build() {
    return [
      TutorClass(
        id: 'class-1',
        tutorId: 'current-user-id',
        name: 'Toán Lớp 12 - Ôn thi ĐH',
        schedule: 'T2-T4-T6, 19:30 - 21:00',
        mode: 'Online',
        price: 2000000,
        enrolledStudentCount: 2, // Updated to match students
        status: 'ongoing',
        studentIds: ['student1', 'student2'],
        paymentStatus: {'student1': 'paid', 'student2': 'unpaid'},
        nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
      ),
       TutorClass(
        id: 'class-2',
        tutorId: 'current-user-id',
        name: 'Tiếng Anh Giao Tiếp Cơ Bản',
        schedule: 'T3-T5, 18:00 - 19:30',
        mode: 'Offline',
        address: 'Quận 3, TP.HCM',
        price: 1500000,
        enrolledStudentCount: 1,
        status: 'ongoing',
        studentIds: ['student3'],
        paymentStatus: {'student3': 'overdue'},
        nextPaymentDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void addClass(TutorClass newClass) {
    state = [newClass, ...state];
  }
}

final tutorClassProvider = NotifierProvider<TutorClassNotifier, List<TutorClass>>(TutorClassNotifier.new);
