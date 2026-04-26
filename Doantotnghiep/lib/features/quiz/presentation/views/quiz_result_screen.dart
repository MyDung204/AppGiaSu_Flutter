import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final Map<String, dynamic> result;
  final bool returnToClass;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.result,
    this.returnToClass = false,
  });

  @override
  Widget build(BuildContext context) {
    final score = (result['score'] as num? ?? 0).toDouble();
    final totalPoints = (result['total_points'] as num? ?? 0).toDouble();
    final correctAnswers = Map<String, dynamic>.from(
      result['correct_answers'] as Map? ?? {},
    );
    final selectedAnswers = Map<String, dynamic>.from(
      result['selected_answers'] as Map? ?? {},
    );
    final percentage = totalPoints == 0 ? 0 : (score / totalPoints) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài thi'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Điểm của bạn',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${score.toStringAsFixed(1)} / ${totalPoints.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 50 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    percentage >= 80
                        ? 'Xuất sắc'
                        : (percentage >= 50 ? 'Đạt yêu cầu' : 'Cần ôn lại'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chi tiết bài làm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                final questionKey = question.id.toString();
                final selectedOptionId = selectedAnswers[questionKey];
                final correctOptionId = correctAnswers[questionKey];
                final isCorrect =
                    selectedOptionId != null &&
                    selectedOptionId == correctOptionId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Câu ${index + 1}: ${question.content}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...question.options.map((option) {
                          final isSelected = option.id == selectedOptionId;
                          final isAnswer = option.id == correctOptionId;
                          final color = isAnswer
                              ? Colors.green
                              : (isSelected ? Colors.red : Colors.grey);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: isAnswer
                                  ? Colors.green[50]
                                  : (isSelected ? Colors.red[50] : null),
                              borderRadius: BorderRadius.circular(8),
                              border: isAnswer || isSelected
                                  ? Border.all(color: color)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isAnswer
                                      ? Icons.check_circle
                                      : (isSelected
                                            ? Icons.cancel
                                            : Icons.radio_button_unchecked),
                                  color: color,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(option.content)),
                                if (isSelected)
                                  const Text(
                                    'Bạn chọn',
                                    style: TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goBack(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EduTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại lớp học'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (returnToClass && context.canPop()) {
      context.pop();
      return;
    }
    context.go('/quizzes');
  }
}
