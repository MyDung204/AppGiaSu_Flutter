
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:uuid/uuid.dart';

final groupRequestsProvider = NotifierProvider<GroupRequestsNotifier, List<GroupRequest>>(GroupRequestsNotifier.new);

class GroupRequestsNotifier extends Notifier<List<GroupRequest>> {
  @override
  List<GroupRequest> build() {
    return [
      GroupRequest(
        id: '1',
        creatorId: 'user1',
        creatorName: 'Nguyễn Văn A',
        subject: 'Tiếng Anh Giao Tiếp',
        gradeLevel: 'Sinh viên',
        pricePerSession: 50000,
        location: 'Q. Cầu Giấy',
        description: 'Cần tìm 3 bạn học chung để share tiền gia sư.',
        currentMembers: 4,
        maxMembers: 5,
        minMembers: 4,
        startTime: DateTime.now().add(const Duration(hours: 20)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'full',
      ),
       GroupRequest(
        id: '2',
        creatorId: 'user2',
        creatorName: 'Trần Thị B',
        subject: 'Toán 12',
        gradeLevel: 'Lớp 12',
        pricePerSession: 150000,
        location: 'Online',
        description: 'Ôn thi đại học cấp tốc.',
        currentMembers: 2,
        maxMembers: 5,
        minMembers: 3,
        startTime: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'open',
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
