import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/assignment.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/assignment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

typedef AssignmentQuery = ({int? courseId, int? studyGroupId, int? studentId});

final courseAssignmentsProvider =
    FutureProvider.family<List<Assignment>, AssignmentQuery>((ref, params) {
      return ref
          .watch(sharedLearningRepositoryProvider)
          .getAssignments(
            courseId: params.courseId,
            studyGroupId: params.studyGroupId,
            studentId: params.studentId,
          );
    });

class ClassAssignmentsTab extends ConsumerStatefulWidget {
  final Course? course;
  final int? studyGroupId;
  final int? studentId;
  final bool isTutor;

  const ClassAssignmentsTab({
    super.key,
    this.course,
    this.studyGroupId,
    this.studentId,
    required this.isTutor,
  });

  @override
  ConsumerState<ClassAssignmentsTab> createState() =>
      _ClassAssignmentsTabState();
}

class _ClassAssignmentsTabState extends ConsumerState<ClassAssignmentsTab> {
  DateTime? _selectedDueDate;

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final parentContext = context;
    _selectedDueDate = null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Giao bài tập mới',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nội dung / Yêu cầu',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập yêu cầu bài tập...',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    helpText: 'Chọn hạn nộp',
                  );
                  if (picked != null) {
                    setState(() => _selectedDueDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: EduTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                        _selectedDueDate == null
                            ? 'Chọn hạn nộp (Không bắt buộc)'
                            : 'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(_selectedDueDate!)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedDueDate == null
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EduTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Đang tạo bài tập...')),
                    );
                  }

                  try {
                    final result = await ref
                        .read(sharedLearningRepositoryProvider)
                        .createAssignment({
                          if (widget.course != null)
                            'course_id': widget.course!.id,
                          if (widget.studyGroupId != null)
                            'study_group_id': widget.studyGroupId,
                          if (widget.studentId != null)
                            'student_id': widget.studentId,
                          'title': titleController.text,
                          'description': contentController.text,
                          'due_date': _selectedDueDate?.toIso8601String(),
                        });

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).hideCurrentSnackBar();
                      if (result != null) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Đã giao bài tập thành công!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        ref.invalidate(
                          courseAssignmentsProvider((
                            courseId: widget.course != null
                                ? int.tryParse(widget.course!.id)
                                : null,
                            studyGroupId: widget.studyGroupId,
                            studentId: widget.studentId,
                          )),
                        );
                      } else {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Có lỗi xảy ra. Vui lòng thử lại.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).hideCurrentSnackBar();
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('❌ Lỗi: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Giao bài'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = (
      courseId: widget.course != null ? int.tryParse(widget.course!.id) : null,
      studyGroupId: widget.studyGroupId,
      studentId: widget.studentId,
    );

    final assignmentsAsync = ref.watch(courseAssignmentsProvider(params));

    return assignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty && !widget.isTutor) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bài tập nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(courseAssignmentsProvider(params)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length + (widget.isTutor ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (widget.isTutor && index == 0) {
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: EduTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: InkWell(
                    onTap: _showCreateDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: EduTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.add_task,
                              color: EduTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Giao bài tập mới...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final itemIndex = widget.isTutor ? index - 1 : index;
              final item = assignments[itemIndex];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentDetailScreen(
                          assignment: item,
                          isTutor: widget.isTutor,
                        ),
                      ),
                    ).then(
                      (_) => ref.refresh(courseAssignmentsProvider(params)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.assignment,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Giao: ${DateFormat('dd/MM').format(item.createdAt)}',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (item.dueDate != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Hạn: ${DateFormat('dd/MM').format(item.dueDate!)}',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (widget.isTutor)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(item.id),
                              )
                            else
                              _buildStudentStatusChip(item),
                          ],
                        ),
                        if (widget.isTutor) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.submissionCount} đã nộp',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const Spacer(),
                                const Text(
                                  'Xem chi tiết',
                                  style: TextStyle(
                                    color: EduTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: EduTheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err')),
    );
  }

  Future<void> _confirmDelete(int assignmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài tập?'),
        content: const Text(
          'Hành động này không thể hoàn tác. Tất cả bài nộp của học viên sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(sharedLearningRepositoryProvider)
          .deleteAssignment(assignmentId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('✅ Đã xóa bài tập')));
          ref.invalidate(
            courseAssignmentsProvider((
              courseId: widget.course != null
                  ? int.tryParse(widget.course!.id)
                  : null,
              studyGroupId: widget.studyGroupId,
              studentId: widget.studentId,
            )),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('❌ Xóa thất bại')));
        }
      }
    }
  }

  Widget _buildStudentStatusChip(Assignment item) {
    if (item.isSubmitted) {
      final submission = item.mySubmission;
      final isGraded = submission?.grade != null;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isGraded ? Colors.blue.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGraded ? Colors.blue.shade200 : Colors.green.shade200,
          ),
        ),
        child: Text(
          isGraded ? 'Điểm: ${submission!.grade}' : 'Đã nộp',
          style: TextStyle(
            color: isGraded ? Colors.blue.shade700 : Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      bool isOverdue =
          item.dueDate != null && item.dueDate!.isBefore(DateTime.now());
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? Colors.red.shade200 : Colors.orange.shade200,
          ),
        ),
        child: Text(
          isOverdue ? 'Quá hạn' : 'Chưa nộp',
          style: TextStyle(
            color: isOverdue ? Colors.red : Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
