import 'package:doantotnghiep/features/quiz/domain/controllers/quiz_controller.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClassQuizTab extends ConsumerWidget {
  final int? courseId;
  final int? studentId;
  final int? studyGroupId;
  final bool isTutor;

  const ClassQuizTab({
    super.key,
    this.courseId,
    this.studentId,
    this.studyGroupId,
    required this.isTutor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = studyGroupId != null
        ? ref.watch(studyGroupQuizzesProvider(studyGroupId!))
        : studentId != null
        ? ref.watch(studentQuizzesProvider(studentId!))
        : ref.watch(courseQuizzesProvider(courseId ?? 0));

    return RefreshIndicator(
      onRefresh: () => studyGroupId != null
          ? ref.refresh(studyGroupQuizzesProvider(studyGroupId!).future)
          : studentId != null
          ? ref.refresh(studentQuizzesProvider(studentId!).future)
          : ref.refresh(courseQuizzesProvider(courseId ?? 0).future),
      child: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _QuizItemCard(quiz: quiz, isTutor: isTutor);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Future<void> _openCreateQuiz(BuildContext context, WidgetRef ref) async {
    final Map<String, dynamic> extra = {};
    if (courseId != null) extra['course_id'] = courseId;
    if (studentId != null) extra['student_id'] = studentId;
    if (studyGroupId != null) extra['study_group_id'] = studyGroupId;

    final created = await context.push<bool>(
      '/tutor-create-quiz',
      extra: extra,
    );
    if (created != true) return;

    if (studyGroupId != null) {
      ref.invalidate(studyGroupQuizzesProvider(studyGroupId!));
    } else if (studentId != null) {
      ref.invalidate(studentQuizzesProvider(studentId!));
    } else {
      ref.invalidate(courseQuizzesProvider(courseId ?? 0));
    }
    ref.invalidate(quizListProvider(null));
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài trắc nghiệm nào',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (isTutor) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openCreateQuiz(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tạo bài trắc nghiệm'),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizItemCard extends StatelessWidget {
  final Quiz quiz;
  final bool isTutor;

  const _QuizItemCard({required this.quiz, required this.isTutor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: quiz.isPublished
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            Icons.quiz,
            color: quiz.isPublished ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${quiz.timeLimitMinutes ?? 0} phút • ${quiz.questionsCount} câu hỏi',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isTutor) {
            context.push('/quiz-detail/${quiz.id}', extra: quiz);
          } else {
            context.push('/quiz-detail/${quiz.id}', extra: quiz);
          }
        },
      ),
    );
  }
}
