import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/chat/data/firebase_chat_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class GroupManagementScreen extends ConsumerStatefulWidget {
  final GroupRequest group;

  const GroupManagementScreen({super.key, required this.group});

  @override
  ConsumerState<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends ConsumerState<GroupManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _members = [];
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.group.status;
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    final repo = ref.read(sharedLearningRepositoryProvider);
    final members = await repo.getGroupMembers(widget.group.id);
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveMember(String userId) async {
    final repo = ref.read(sharedLearningRepositoryProvider);
    final success = await repo.approveMember(widget.group.id, userId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt thành viên')));
      }
      _fetchMembers();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi duyệt')));
      }
    }
  }

  Future<void> _rejectMember(String userId) async {
    final repo = ref.read(sharedLearningRepositoryProvider);
    final success = await repo.rejectMember(widget.group.id, userId);
    if (success) {
      // Sync Firestore: Remove from conservation group just in case they were in it previously
      await ref.read(firebaseChatRepositoryProvider).removeMemberFromGroupConversation(
        widget.group.id, 
        userId
      );

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối thành viên')));
      _fetchMembers();
    }
  }

  Future<void> _removeMember(String userId) async {
     final confirmed = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Xác nhận'),
         content: const Text('Bạn có chắc muốn mời thành viên này ra khỏi lớp học nhóm?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đồng ý')),
         ],
       ),
     );
     if (confirmed != true) return;

    final repo = ref.read(sharedLearningRepositoryProvider);
    final success = await repo.removeMember(widget.group.id, userId);
    if (success) {
      // Sync Firestore: Remove from conservation group
      await ref.read(firebaseChatRepositoryProvider).removeMemberFromGroupConversation(
        widget.group.id, 
        userId
      );

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã mời ra khỏi lớp học nhóm')));
      _fetchMembers();
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Xác nhận giải tán'),
         content: const Text('Hành động này không thể hoàn tác. Bạn chắc chắn muốn xóa lớp học nhóm?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
           TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Xóa lớp học nhóm')),
         ],
       ),
     );
     if (confirmed != true) return;

     final repo = ref.read(sharedLearningRepositoryProvider);
     final success = await repo.deleteGroup(widget.group.id);
     if (success) {
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã giải tán lớp học nhóm')));
           Navigator.pop(context); // Back to list
       }
     }
  }

  Future<void> _editGroup() async {
    final updated = await context.push<bool>('/create-group', extra: widget.group);
    if (updated == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _toggleStatus(bool isOpen) async {
    final newStatus = isOpen ? 'open' : 'closed';
    final repo = ref.read(sharedLearningRepositoryProvider);
    final success = await repo.toggleGroupStatus(widget.group.id, newStatus);

    if (success) {
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isOpen ? 'Đã mở lại lớp học' : 'Đã đóng lớp học'))
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi cập nhật trạng thái'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lớp học nhóm'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editGroup();
              if (value == 'delete') _deleteGroup();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Sửa lớp học nhóm'),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Giải tán lớp học nhóm', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupInfoCard(),
              const SizedBox(height: 24),
              const Text(
                'Danh sách thành viên',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _members.isEmpty
                      ? const Center(child: Text('Chưa có thành viên nào tham gia'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _members.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            final status = member['status'] ?? 'pending';
                            final isMe = member['id'].toString() == widget.group.creatorId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                              title: Text(member['name'] + (isMe ? ' (Bạn)' : '')),
                              subtitle: Text(
                                'Tham gia: ${_formatDate(member['joined_at'])}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   if (status == 'pending') ...[
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _approveMember(member['id'].toString()),
                                        tooltip: 'Duyệt',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _rejectMember(member['id'].toString()),
                                        tooltip: 'Từ chối',
                                      ),
                                   ]
                                   else if (status == 'rejected')
                                      const Chip(
                                        label: Text('Đã từ chối', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        backgroundColor: Colors.redAccent,
                                      )
                                   else if (!isMe)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () => _removeMember(member['id'].toString()),
                                        tooltip: 'Mời ra khỏi lớp học nhóm',
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    final bool isOpen = _currentStatus == 'open' || _currentStatus == 'full';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(widget.group.subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isOpen ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        isOpen ? 'Đang mở' : 'Đã đóng',
                        style: TextStyle(
                          color: isOpen ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Chủ đề: ${widget.group.topic}'),
                const SizedBox(height: 4),
                Text('Thành viên: ${widget.group.currentMembers}/${widget.group.maxMembers}'),
                const SizedBox(height: 4),
                Text('Học phí: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.group.pricePerSession)}/buổi'),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Trạng thái hiển thị lớp học', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(
              isOpen ? 'Học viên có thể tìm thấy và tham gia' : 'Lớp học bị ẩn khỏi danh sách tìm kiếm',
              style: const TextStyle(fontSize: 12),
            ),
            value: isOpen,
            activeColor: Colors.green,
            onChanged: (value) => _toggleStatus(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
