import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:doantotnghiep/features/quiz/domain/controllers/quiz_controller.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClassQuizTab extends ConsumerWidget {
  final Course course;
  final bool isTutor;

  const ClassQuizTab({
    super.key,
    required this.course,
    required this.isTutor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(courseQuizzesProvider(int.tryParse(course.id) ?? 0));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(courseQuizzesProvider(int.tryParse(course.id) ?? 0).future),
      child: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
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
              onPressed: () => context.push('/tutor-create-quiz', extra: course.id),
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
          backgroundColor: quiz.isPublished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
             context.push('/quiz-detail/${quiz.id}');
          } else {
             // Student takes quiz
             context.push('/quiz-taking/${quiz.id}');
          }
        },
      ),
    );
  }
}
