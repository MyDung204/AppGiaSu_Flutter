
import 'package:doantotnghiep/features/community/data/community_provider.dart';
import 'package:doantotnghiep/features/community/domain/models/answer.dart';
import 'package:doantotnghiep/features/community/domain/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(communityProvider);

    return questionsAsync.when(
      data: (questions) {
        final question = questions.firstWhere(
          (q) => q.id == widget.questionId,
          orElse: () => Question(
            id: 'error', userId: '', userName: '', userAvatar: '', 
            subject: '', content: 'Không tìm thấy câu hỏi', 
            createdAt: DateTime.now()
          ),
        );

        if (question.id == 'error') {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Lỗi: Câu hỏi không tồn tại.')));
        }

        return Scaffold(
          appBar: AppBar(title: Text(question.subject)),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Content
                      _buildQuestionCard(question),
                      const SizedBox(height: 24),
                      const Text('Câu trả lời', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      // Answers List
                      if (question.answers.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('Chưa có câu trả lời nào. Hãy là người đầu tiên!', style: TextStyle(color: Colors.grey)),
                        ))
                      else
                        ...question.answers.map((a) => _buildAnswerItem(a)),
                    ],
                  ),
                ),
              ),
              
              // Input Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Viết câu trả lời...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _submitAnswer(question.id),
                      icon: const Icon(Icons.send, color: Colors.blue),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(appBar: AppBar(), body: Center(child: Text('Lỗi: $e'))),
    );
  }

  Widget _buildQuestionCard(Question q) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(q.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                   Text(DateFormat('dd/MM HH:mm').format(q.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (q.isSolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                  child: const Text('Đã giải quyết', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(q.content, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
               const Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey),
               const SizedBox(width: 4),
               Text('${q.likeCount}'),
               const SizedBox(width: 24),
               const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
               const SizedBox(width: 4),
               Text('${q.answerCount} trả lời'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnswerItem(Answer a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: a.isAcccepted ? Colors.green.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: a.isAcccepted ? Border.all(color: Colors.green.withValues(alpha: 0.5)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(a.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              if (a.isAcccepted)
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const Spacer(),
              Text(DateFormat('HH:mm').format(a.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.content),
          const SizedBox(height: 8),
          Row(
            children: [
               Icon(Icons.favorite_border, size: 16, color: Colors.grey[400]),
               const SizedBox(width: 4),
               Text('${a.likeCount}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  void _submitAnswer(String questionId) {
    if (_answerController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final newAnswer = Answer(
      id: const Uuid().v4(),
      questionId: questionId,
      userId: user?.uid ?? 'guest',
      userName: user?.displayName ?? 'Tôi',
      userAvatar: user?.photoURL ?? 'https://i.pravatar.cc/150?u=me',
      content: _answerController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(communityProvider.notifier).addAnswer(questionId, newAnswer);
    _answerController.clear();
    FocusScope.of(context).unfocus(); // Request focus drop but keep scroll
  }
}
