import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/group/data/group_request_provider.dart';
import 'package:doantotnghiep/features/chat/data/firebase_chat_repository.dart'; // Added
import 'package:doantotnghiep/features/chat/presentation/group_chat_screen.dart'; // Added
import 'package:cloud_firestore/cloud_firestore.dart'; // Added
import 'package:doantotnghiep/core/exceptions/app_exceptions.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/widgets/class_materials_tab.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/widgets/class_quiz_tab.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final GroupRequest group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  late GroupRequest _group;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncGroupChatMembers();
    });
  }

  Future<void> _syncGroupChatMembers() async {
    // 1. Fetch current members from API
    final repo = ref.read(sharedLearningRepositoryProvider);
    final members = await repo.getGroupMembers(_group.id);

    // 2. Extract IDs
    // Assuming members list contains objects with 'pk' or 'id'
    // Let's inspect member structure if failed, but usually it has 'id'
    // Based on Controller, it returns User objects.

    final List<String> memberIds = [];
    if (members.isNotEmpty) {
      for (var m in members) {
        if (m is Map && m['id'] != null) {
          final status = m['status']?.toString() ?? 'pending';
          // Only add approved members or the creator
          if (status == 'approved' ||
              status == 'member' ||
              m['id'].toString() == _group.creatorId.toString()) {
            memberIds.add(m['id'].toString());
          }
        }
      }
    }

    // Add Creator ID just in case it's not in the list (though it should be)
    final creatorId = _group.creatorId;
    if (!memberIds.contains(creatorId)) {
      memberIds.add(creatorId);
    }

    // 3. Sync to Firestore
    await ref
        .read(firebaseChatRepositoryProvider)
        .createOrUpdateGroupConversation(_group.id, memberIds, _group.topic);
  }

  Future<void> _refreshGroup() async {
    // Ideally fetch fresh data from API
    // For now, we rely on the passed object or could fetch by ID if API supported it
  }

  Future<void> _joinGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia lớp học nhóm?'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng ký tham gia lớp học nhóm này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await ref
            .read(sharedLearningRepositoryProvider)
            .joinGroup(_group.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gửi yêu cầu tham gia thành công')),
            );
            ref.invalidate(groupRequestsProvider);
            context.pop(true);
          }
        }
      } catch (e) {
        if (mounted) {
          String message = 'Lỗi khi tham gia nhóm';
          if (e is ApiException) message = e.userMessage;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveGroup() async {
    final now = DateTime.now();
    final joinedAt = _group.joinedAt;

    if (joinedAt != null) {
      final hoursJoined = now.difference(joinedAt).inHours;
      if (hoursJoined >= 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bạn chỉ có thể rời nhóm trong vòng 12 giờ kể từ khi tham gia.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời khỏi lớp học nhóm?'),
        content: const Text(
          'Bạn có chắc chắn muốn rời khỏi lớp học nhóm này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rời lớp học nhóm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await ref
            .read(sharedLearningRepositoryProvider)
            .leaveGroup(_group.id);
        if (success) {
          // Sync Firestore: Remove myself from conservation group
          final user = ref.read(authRepositoryProvider).currentUser;
          if (user != null) {
            await ref
                .read(firebaseChatRepositoryProvider)
                .removeMemberFromGroupConversation(
                  _group.id,
                  user.id.toString(),
                );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã rời lớp học nhóm thành công')),
            );
            ref.invalidate(myJoinedGroupsProvider); // Refresh list
            context.pop(true);
          }
        }
      } catch (e) {
        if (mounted) {
          String message = 'Lỗi khi rời nhóm';
          if (e is ApiException) message = e.userMessage;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _payTuition() async {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanh toán học phí'),
        content: Text(
          'Bạn sẽ thanh toán ${currencyFormat.format(_group.pricePerSession)} từ ví cá nhân. Tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await ref
            .read(sharedLearningRepositoryProvider)
            .payGroupTuition(_group.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanh toán thành công!')),
            );
            setState(() {
              _group = _group.copyWith(paymentStatus: 'paid');
            });
            ref.invalidate(myJoinedGroupsProvider);
          }
        }
      } catch (e) {
        if (mounted) {
          String message = 'Lỗi khi thanh toán';
          if (e is ApiException) message = e.userMessage;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  bool get _isJoinedOrPending =>
      _group.membershipStatus == 'approved' ||
      _group.membershipStatus == 'member' ||
      _group.membershipStatus == 'pending';

  bool get _isPastLeaveWindow {
    final joinedAt = _group.joinedAt;
    return joinedAt != null &&
        DateTime.now().difference(joinedAt).inHours >= 12;
  }

  bool get _shouldShowPaymentDeadline =>
      _group.status == 'full' &&
      _group.paymentDeadline != null &&
      _group.paymentStatus == 'pending';

  String _paymentDeadlineText() {
    final difference = _group.paymentDeadline!.difference(DateTime.now());
    if (difference.isNegative) return 'Đã quá hạn';

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return 'Còn $hours giờ $minutes phút';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final isCreator = user?.id == _group.creatorId;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lớp học nhóm'),
          actions: [
            if (isCreator)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final updated = await context.push(
                    '/create-group',
                    extra: _group,
                  );
                  if (updated == true) {
                    _refreshGroup();
                    ref.invalidate(groupRequestsProvider);
                  }
                },
              )
            else if (_group.membershipStatus == 'approved' ||
                _group.membershipStatus == 'member' ||
                _group.membershipStatus == 'pending')
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                onPressed: (_isLoading || _isPastLeaveWindow)
                    ? null
                    : _leaveGroup,
                tooltip: 'Rời lớp học nhóm',
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Tài liệu'),
              Tab(text: 'Bài kiểm tra'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Information
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _group.topic,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: EduTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _group.subject,
                                style: TextStyle(
                                  color: EduTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _group.gradeLevel,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (_group.status == 'full') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Full',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Ngày bắt đầu:',
                          DateFormat('dd/MM/yyyy').format(_group.startTime),
                        ),
                        if (_group.expectedOpeningTime != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.timer_outlined,
                            'Dự kiến mở:',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(_group.expectedOpeningTime!),
                          ),
                        ],
                        if (_group.quizId != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.quiz_outlined,
                            'Bài kiểm tra:',
                            'Yêu cầu hoàn thành đầu vào',
                            valueColor: Colors.blue,
                          ),
                        ],
                        if (_shouldShowPaymentDeadline) ...[
                          const SizedBox(height: 12),
                          _buildPaymentDeadlineNotice(),
                        ],
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Địa điểm:',
                          _group.location,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.attach_money,
                          'Chi phí:',
                          '${currencyFormat.format(_group.pricePerSession)}/buổi',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _group.description.isNotEmpty
                        ? _group.description
                        : 'Không có mô tả',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thành viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_group.currentMembers}/${_group.maxMembers}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!isCreator && _isJoinedOrPending) ...[
                    _buildLeaveGroupPanel(),
                    const SizedBox(height: 16),
                  ],
                  if (isCreator)
                    Badge(
                      isLabelVisible: _group.pendingRequestsCount > 0,
                      label: Text('${_group.pendingRequestsCount}'),
                      backgroundColor: Colors.red,
                      offset: const Offset(-5, 5),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/group-management', extra: _group);
                        },
                        icon: const Icon(Icons.manage_accounts),
                        label: const Text('Quản lý thành viên'),
                      ),
                    )
                  else
                    const Text(
                      'Chỉ trưởng nhóm mới có thể xem danh sách chi tiết.',
                    ),
                ],
              ),
            ),

            // Tab 2: Materials
            ClassMaterialsTab(
              studyGroupId: int.tryParse(_group.id),
              isTutor: isCreator, // Assume creator has management rights
            ),

            // Tab 3: Quizzes
            ClassQuizTab(
              studyGroupId: int.tryParse(_group.id),
              isTutor: isCreator,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(isCreator),
        // Floating Chat Bubble
        floatingActionButton:
            (isCreator ||
                _group.membershipStatus == 'approved' ||
                _group.membershipStatus == 'member')
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => GroupChatScreen(group: _group),
                    ),
                  );
                },
                backgroundColor: EduTheme.primary,
                icon: StreamBuilder<DocumentSnapshot>(
                  stream: ref
                      .watch(firebaseChatRepositoryProvider)
                      .getGroupConversationStream(_group.id),
                  builder: (context, snapshot) {
                    int unreadCount = 0;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final unreadMap =
                          data['unread_counts'] as Map<String, dynamic>?;
                      final myId = ref
                          .read(authRepositoryProvider)
                          .currentUser
                          ?.id
                          .toString();
                      if (unreadMap != null && myId != null) {
                        unreadCount = unreadMap[myId] ?? 0;
                      }
                    }

                    return Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text('$unreadCount'),
                      smallSize: 10,
                      backgroundColor: Colors.red,
                      offset: const Offset(4, -4),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                label: const Text(
                  'Chat lớp học nhóm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildBottomBar(bool isCreator) {
    if (isCreator) return const SizedBox.shrink();

    // 1. Not a member or rejected
    if (_group.membershipStatus == null ||
        _group.membershipStatus == 'rejected') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _joinGroup,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: EduTheme.primary,
          ),
          child: const Text(
            'Tham gia lớp học nhóm',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // 2. Member but group is full and hasn't paid
    if (_group.status == 'full' &&
        (_group.membershipStatus == 'approved' ||
            _group.membershipStatus == 'member') &&
        _group.paymentStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _payTuition,
          icon: const Icon(Icons.payment, color: Colors.white),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          label: const Text(
            'Thanh toán học phí',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // 3. Already paid
    if (_group.paymentStatus == 'paid') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          label: const Text(
            'Đã thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (_isJoinedOrPending) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: OutlinedButton.icon(
          onPressed: (_isLoading || _isPastLeaveWindow) ? null : _leaveGroup,
          icon: const Icon(Icons.logout),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: Colors.red,
          ),
          label: Text(
            _isPastLeaveWindow
                ? 'Đã quá 12 giờ, không thể rời'
                : 'Rời lớp học nhóm',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLeaveGroupPanel() {
    final helperText = _isPastLeaveWindow
        ? 'Bạn đã quá 12 giờ kể từ khi tham gia nên không thể rời lớp học nhóm.'
        : 'Bạn có thể rời lớp học nhóm trong vòng 12 giờ kể từ khi tham gia.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            helperText,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: (_isLoading || _isPastLeaveWindow) ? null : _leaveGroup,
            icon: const Icon(Icons.logout),
            label: Text(
              _group.membershipStatus == 'pending'
                  ? 'Hủy yêu cầu tham gia'
                  : 'Rời lớp học nhóm',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDeadlineNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hạn thanh toán còn lại',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _paymentDeadlineText(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPaymentDeadlineRow() {
    final now = DateTime.now();
    final deadline = _group.paymentDeadline!;
    final difference = deadline.difference(now);

    String timeStr;
    if (difference.isNegative) {
      timeStr = "Đã quá hạn";
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      timeStr = "Còn $hours giờ $minutes phút";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hạn thanh toán học phí',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
