import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/quiz/domain/controllers/quiz_controller.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizDetailScreen extends ConsumerWidget {
  final int quizId;
  final Quiz? initialData;

  const QuizDetailScreen({super.key, required this.quizId, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final quizAsync = ref.watch(quizDetailProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết trắc nghiệm')),
      body: quizAsync.when(
        data: (quiz) {
          final isTutor =
              user?.role == 'tutor' && user?.id == quiz.tutorId.toString();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(quizDetailProvider(quizId).future),
            child: isTutor
                ? _TutorQuizDetail(quiz: quiz)
                : _StudentQuizIntro(quiz: quiz),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}

class _StudentQuizIntro extends StatelessWidget {
  final Quiz quiz;

  const _StudentQuizIntro({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          quiz.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if ((quiz.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(quiz.description!, style: const TextStyle(fontSize: 16)),
        ],
        const SizedBox(height: 24),
        _InfoCard(
          icon: Icons.timer_outlined,
          label: 'Thời gian làm bài',
          value: '${quiz.timeLimitMinutes ?? "Không giới hạn"} phút',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.format_list_numbered,
          label: 'Số câu hỏi',
          value: '${quiz.questions.length} câu',
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () =>
              context.replace('/quiz-taking/${quiz.id}', extra: quiz),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Bắt đầu làm bài'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EduTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _TutorQuizDetail extends ConsumerWidget {
  final Quiz quiz;

  const _TutorQuizDetail({required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                quiz.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/tutor-create-quiz', extra: {'quiz': quiz});
                } else if (value == 'delete') {
                  _confirmDelete(context, ref);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa bài')),
                PopupMenuItem(value: 'delete', child: Text('Xóa bài')),
              ],
            ),
          ],
        ),
        if ((quiz.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(quiz.description!),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.timer_outlined,
                label: 'Thời gian',
                value: '${quiz.timeLimitMinutes ?? "Không giới hạn"} phút',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.quiz_outlined,
                label: 'Câu hỏi',
                value: '${quiz.questions.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'Đã làm', count: quiz.completedStudents.length),
        const SizedBox(height: 8),
        _StudentList(
          students: quiz.completedStudents,
          emptyText: 'Chưa có học viên làm bài.',
          showScore: true,
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'Chưa làm', count: quiz.pendingStudents.length),
        const SizedBox(height: 8),
        _StudentList(
          students: quiz.pendingStudents,
          emptyText: 'Không còn học viên chưa làm bài.',
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài trắc nghiệm?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(quizActionProvider.notifier)
        .deleteQuiz(quiz.id);
    if (!context.mounted) return;

    if (success) {
      ref.invalidate(quizListProvider(null));
      if (quiz.courseId != null) {
        ref.invalidate(courseQuizzesProvider(quiz.courseId!));
      }
      if (quiz.studyGroupId != null) {
        ref.invalidate(studyGroupQuizzesProvider(quiz.studyGroupId!));
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa bài trắc nghiệm.')));
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa bài trắc nghiệm thất bại.')),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: EduTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title ($count)',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _StudentList extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final String emptyText;
  final bool showScore;

  const _StudentList({
    required this.students,
    required this.emptyText,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Text(emptyText, style: TextStyle(color: Colors.grey[600]));
    }

    return Column(
      children: students.map((student) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((student['name'] ?? 'H').toString().substring(0, 1)),
            ),
            title: Text(student['name']?.toString() ?? 'Học viên'),
            subtitle: showScore && student['completed_at'] != null
                ? Text('Hoàn thành: ${student['completed_at']}')
                : (student['email'] != null
                      ? Text(student['email'].toString())
                      : null),
            trailing: showScore
                ? Text(
                    '${student['score'] ?? 0} điểm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
