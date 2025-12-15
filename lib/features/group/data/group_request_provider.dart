
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:uuid/uuid.dart';

final groupRequestsProvider = NotifierProvider<GroupRequestsNotifier, List<GroupRequest>>(GroupRequestsNotifier.new);

class GroupRequestsNotifier extends Notifier<List<GroupRequest>> {
  @override
  List<GroupRequest> build() {
    return [
      GroupRequest(
        id: 'mock-g-1',
        creatorId: 'user-1',
        creatorName: 'Nguyễn Văn A',
        subject: 'Toán',
        gradeLevel: 'Lớp 5',
        pricePerSession: 80000,
        location: 'Quận 3',
        description: 'Tìm bạn học ghép Toán Lớp 5. Mục tiêu: Ôn thi cuối kỳ, học với cô Lan (GV Giỏi).',
        currentMembers: 1,
        maxMembers: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GroupRequest(
        id: 'mock-g-2',
        creatorId: 'user-2',
        creatorName: 'Trần Thị B',
        subject: 'Tiếng Anh',
        gradeLevel: 'IELTS',
        pricePerSession: 150000,
        location: 'Online',
        description: 'Cần tìm 2 bạn luyện Speaking band 6.5+. Học tối 3, 5, 7.',
        currentMembers: 1,
        maxMembers: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void addRequest(GroupRequest req) {
    state = [req, ...state];
  }

  void removeRequest(String id) {
    state = state.where((req) => req.id != id).toList();
  }
}
