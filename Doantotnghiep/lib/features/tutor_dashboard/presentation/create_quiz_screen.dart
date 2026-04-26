import 'package:doantotnghiep/features/quiz/domain/controllers/quiz_controller.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  final Quiz? quizToEdit;
  final int? courseId;
  final int? studentId;
  final int? studyGroupId;

  const CreateQuizScreen({
    super.key,
    this.quizToEdit,
    this.courseId,
    this.studentId,
    this.studyGroupId,
  });

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _QuizOptionData {
  TextEditingController contentController;
  bool isCorrect;

  _QuizOptionData({required String content, this.isCorrect = false})
    : contentController = TextEditingController(text: content);
}

class _QuizQuestionData {
  TextEditingController contentController;
  bool isMultipleChoice = true;
  List<_QuizOptionData> options;

  _QuizQuestionData({required String content, required this.options})
    : contentController = TextEditingController(text: content);
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '15');
  bool _isPublished = true;

  final List<_QuizQuestionData> _questions = [];

  @override
  void initState() {
    super.initState();
    final quiz = widget.quizToEdit;
    if (quiz == null) {
      _addQuestion();
    } else {
      _titleController.text = quiz.title;
      _descController.text = quiz.description ?? '';
      _timeLimitController.text = (quiz.timeLimitMinutes ?? 15).toString();
      _isPublished = quiz.isPublished;
      for (final question in quiz.questions) {
        _questions.add(
          _QuizQuestionData(
            content: question.content,
            options: question.options
                .map(
                  (option) => _QuizOptionData(
                    content: option.content,
                    isCorrect: option.isCorrect == true,
                  ),
                )
                .toList(),
          ),
        );
      }
      if (_questions.isEmpty) _addQuestion();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _timeLimitController.dispose();
    for (var q in _questions) {
      q.contentController.dispose();
      for (var o in q.options) {
        o.contentController.dispose();
      }
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        _QuizQuestionData(
          content: '',
          options: [
            _QuizOptionData(content: '', isCorrect: true),
            _QuizOptionData(content: '', isCorrect: false),
          ],
        ),
      );
    });
  }

  void _addOption(_QuizQuestionData question) {
    setState(() {
      question.options.add(_QuizOptionData(content: ''));
    });
  }

  void _removeOption(_QuizQuestionData question, int optIndex) {
    setState(() {
      final opt = question.options.removeAt(optIndex);
      opt.contentController.dispose();
      // Ensure at least one correct option if we removed the only one
      if (opt.isCorrect && question.options.isNotEmpty) {
        question.options.first.isCorrect = true;
      }
    });
  }

  void _removeQuestion(int qIndex) {
    setState(() {
      final q = _questions.removeAt(qIndex);
      q.contentController.dispose();
      for (var o in q.options) {
        o.contentController.dispose();
      }
    });
  }

  void _setCorrectOption(_QuizQuestionData question, int optIndex) {
    setState(() {
      for (int i = 0; i < question.options.length; i++) {
        question.options[i].isCorrect = (i == optIndex);
      }
    });
  }

  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 câu hỏi')),
      );
      return;
    }

    // Validate options
    for (var q in _questions) {
      if (q.options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mỗi câu hỏi cần ít nhất 2 lựa chọn')),
        );
        return;
      }
      if (!q.options.any((o) => o.isCorrect)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mỗi câu hỏi phải chọn 1 đáp án đúng')),
        );
        return;
      }
    }

    final Map<String, dynamic> quizData = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "time_limit": int.tryParse(_timeLimitController.text.trim()) ?? 0,
      "is_published": _isPublished,
      if (widget.courseId != null) "course_id": widget.courseId,
      if (widget.studentId != null) "student_id": widget.studentId,
      if (widget.studyGroupId != null) "study_group_id": widget.studyGroupId,
      "questions": _questions.map((q) {
        return {
          "content": q.contentController.text.trim(),
          "is_multiple_choice": q.isMultipleChoice,
          "points": 1,
          "options": q.options.map((o) {
            return {
              "content": o.contentController.text.trim(),
              "is_correct": o.isCorrect,
            };
          }).toList(),
        };
      }).toList(),
    };

    final quizAction = ref.read(quizActionProvider.notifier);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final savedQuiz = widget.quizToEdit == null
          ? await quizAction.createQuiz(quizData)
          : await quizAction.updateQuiz(widget.quizToEdit!.id, quizData);

      if (savedQuiz == null) {
        throw Exception(
          widget.quizToEdit == null
              ? 'Tạo bài kiểm tra thất bại'
              : 'Cập nhật bài kiểm tra thất bại',
        );
      }

      if (!mounted) return;

      navigator.pop(); // close dialog
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.quizToEdit == null
                ? 'Tạo bài kiểm tra thành công!'
                : 'Cập nhật bài kiểm tra thành công!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh quiz list
      ref.invalidate(quizListProvider(null));
      if (widget.courseId != null) {
        ref.invalidate(courseQuizzesProvider(widget.courseId!));
      }
      if (widget.studentId != null) {
        ref.invalidate(studentQuizzesProvider(widget.studentId!));
      }
      if (widget.studyGroupId != null) {
        ref.invalidate(studyGroupQuizzesProvider(widget.studyGroupId!));
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;

      navigator.pop(); // close dialog
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quizToEdit == null ? 'Tạo Bài Kiểm Tra' : 'Sửa Bài Kiểm Tra',
        ),
        actions: [
          TextButton.icon(
            onPressed: _submitQuiz,
            icon: const Icon(Icons.check, color: Colors.blue),
            label: const Text(
              'Lưu',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quiz Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin chung',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên bài thi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả (tuỳ chọn)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeLimitController,
                            decoration: const InputDecoration(
                              labelText: 'Thời gian (Phút)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Xuất bản ngay'),
                            value: _isPublished,
                            onChanged: (val) =>
                                setState(() => _isPublished = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Questions List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách Câu hỏi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm câu hỏi'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._questions.asMap().entries.map((entry) {
              int qIndex = entry.key;
              _QuizQuestionData q = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.indigo.shade100, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Câu hỏi ${qIndex + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo,
                            ),
                          ),
                          if (_questions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeQuestion(qIndex),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: q.contentController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung câu hỏi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Vui lòng nhập câu hỏi'
                            : null,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Các lựa chọn đáp án (Tick vào đáp án đúng):',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      // Options list for this question
                      ...q.options.asMap().entries.map((optEntry) {
                        int oIndex = optEntry.key;
                        _QuizOptionData o = optEntry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: oIndex,
                                groupValue: q.options.indexWhere(
                                  (opt) => opt.isCorrect,
                                ),
                                onChanged: (val) {
                                  if (val != null) _setCorrectOption(q, val);
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: o.contentController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập đáp án ${oIndex + 1}',
                                    isDense: true,
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Nhập đáp án'
                                      : null,
                                ),
                              ),
                              if (q.options.length > 2)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeOption(q, oIndex),
                                ),
                            ],
                          ),
                        );
                      }).toList(),

                      TextButton.icon(
                        onPressed: () => _addOption(q),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm lựa chọn'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
