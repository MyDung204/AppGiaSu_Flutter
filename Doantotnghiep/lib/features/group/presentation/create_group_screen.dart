import 'package:doantotnghiep/features/group/data/group_request_provider.dart';
import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/group_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/features/quiz/domain/models/quiz.dart' as quiz_model;
import 'package:doantotnghiep/features/quiz/domain/controllers/quiz_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  final GroupRequest? group;
  const CreateGroupScreen({super.key, this.group});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _maxMembersController = TextEditingController(text: '3');
  DateTime? _selectedOpeningTime;
  int? _selectedQuizId;
  String? _selectedQuizTitle;
  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern('vi_VN');

  @override
  void initState() {
    super.initState();
    // _priceController.addListener(_onPriceChanged); // Moved to inputFormatters
    if (widget.group != null) {
      _topicController.text = widget.group!.topic;
      _subjectController.text = widget.group!.subject;
      _gradeController.text = widget.group!.gradeLevel;
      _locationController.text = widget.group!.location;
      _priceController.text = _currencyFormatter.format(widget.group!.pricePerSession);
      _descController.text = widget.group!.description;
      _maxMembersController.text = widget.group!.maxMembers.toString();
      _selectedOpeningTime = widget.group!.expectedOpeningTime;
      _selectedQuizId = int.tryParse(widget.group!.quizId ?? '');
    }
  }

  void _onPriceChanged() {
    // Deprecated: Moving formatting to InputFormatters for better UX
  }

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    _gradeController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(profileViewModelProvider);
    final isTutor = userAsync.value?.role == 'tutor';

    if (!isTutor && widget.group == null) {
       return Scaffold(
         appBar: AppBar(title: const Text('Thông báo')),
         body: const Center(
           child: Padding(
             padding: EdgeInsets.all(24.0),
             child: Text(
               'Chỉ Gia sư mới có quyền tạo lớp học nhóm. Vui lòng nâng cấp tài khoản hoặc liên hệ Admin.',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 16),
             ),
           ),
         ),
       );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.group != null ? 'Chỉnh sửa lớp học nhóm' : 'Tạo lớp học nhóm mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf3e7e9), Color(0xFFe3eeff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Thông tin lớp học nhóm'),
                    _buildTextField(
                      controller: _topicController,
                      label: 'Tiêu đề lớp học nhóm',
                      hint: 'VD: Lớp ôn thi Đại học cấp tốc...',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _subjectController,
                      label: 'Môn học',
                      hint: 'VD: Toán, Tiếng Anh...',
                      icon: Icons.book_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _gradeController,
                      label: 'Trình độ / Lớp',
                      hint: 'VD: Lớp 5, IELTS 6.0...',
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Chi tiết lớp học'),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Khu vực / Hình thức',
                      hint: 'VD: Quận 3 hoặc Online',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _maxMembersController,
                            label: 'Số lượng tối đa',
                            hint: 'VD: 3',
                            icon: Icons.group_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descController,
                      label: 'Mô tả lớp học',
                      hint: 'Mô tả chi tiết nội dung, lộ trình học...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      required: false,
                    ),
                    const SizedBox(height: 16),
                    _buildQuizPicker(context),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      title: const Text('Thời gian mở lớp dự kiến'),
                      subtitle: Text(_selectedOpeningTime == null 
                        ? 'Chưa chọn' 
                        : DateFormat('dd/MM/yyyy HH:mm').format(_selectedOpeningTime!)),
                      trailing: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedOpeningTime ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_selectedOpeningTime ?? DateTime.now()),
                            );
                            if (time != null) {
                              setState(() => _selectedOpeningTime = DateTime(
                                date.year, date.month, date.day, time.hour, time.minute
                              ));
                            }
                          }
                        },
                        child: const Text('Chọn thời gian'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(widget.group != null ? 'Cập nhật lớp học nhóm' : 'Tạo lớp học nhóm', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildQuizPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bài kiểm tra đầu vào', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final quizzes = await ref.read(quizListProvider(null).future);
            if (!mounted) return;
            final selected = await showModalBottomSheet<quiz_model.Quiz>(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chọn bài kiểm tra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (quizzes.isEmpty)
                      const Text('Bạn chưa tạo bài kiểm tra nào')
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            final q = quizzes[index];
                            return ListTile(
                              title: Text(q.title),
                              onTap: () => Navigator.pop(context, q),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
            if (selected != null) {
              setState(() {
                _selectedQuizId = selected.id;
                _selectedQuizTitle = selected.title;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.quiz_outlined, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedQuizTitle ?? (_selectedQuizId != null ? 'Đã chọn ID: $_selectedQuizId' : 'Chọn bài kiểm tra (tuỳ chọn)'),
                    style: TextStyle(color: _selectedQuizId != null ? Colors.black87 : Colors.grey.shade600),
                  ),
                ),
                if (_selectedQuizId != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() {
                      _selectedQuizId = null;
                      _selectedQuizTitle = null;
                    }),
                  )
                else
                  const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: required ? (value) => value!.isEmpty ? 'Vui lòng nhập $label' : null : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Học phí dự kiến (VNĐ)',
        hintText: 'VD: 1.500.000',
        prefixIcon: const Icon(Icons.attach_money, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập học phí' : null,
    );
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOpeningTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thời gian mở lớp dự kiến.')),
        );
        return;
      }

      final isEditing = widget.group != null;
      final price = double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0;
      final maxMembers = int.tryParse(_maxMembersController.text) ?? 3;

      if (isEditing) {
        final success = await ref.read(sharedLearningRepositoryProvider).updateGroup(
          widget.group!.id,
          {
            'topic': _topicController.text,
            'subject': _subjectController.text,
            'grade_level': _gradeController.text,
            'price': price,
            'location': _locationController.text,
            'description': _descController.text,
            'max_members': maxMembers,
            'expected_opening_time': _selectedOpeningTime!.toIso8601String(),
            'quiz_id': _selectedQuizId,
          }
        );

        if (success && mounted) {
           ref.invalidate(groupRequestsProvider);
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Đã cập nhật lớp học nhóm thành công!'), backgroundColor: Colors.green),
           );
           // Navigate back and ideally signal refresh
           context.pop(true);
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Lỗi khi cập nhật lớp học nhóm. Vui lòng thử lại.')),
           );
        }
      } else {
        final newRequest = GroupRequest(
          id: '', 
          creatorId: '',
          creatorName: '',
          topic: _topicController.text,
          subject: _subjectController.text,
          gradeLevel: _gradeController.text,
          pricePerSession: price,
          location: _locationController.text,
          description: _descController.text,
          maxMembers: maxMembers,
          currentMembers: 0, // Mặc định khi tạo nhóm số lượng là 0
          minMembers: 2,
          createdAt: DateTime.now(),
          startTime: _selectedOpeningTime!,
          expectedOpeningTime: _selectedOpeningTime,
          quizId: _selectedQuizId?.toString(),
        );

        final newGroup = await ref.read(sharedLearningRepositoryProvider).createStudyGroup(newRequest);

        if (newGroup != null && mounted) {
          ref.invalidate(groupRequestsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo lớp học nhóm thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pushReplacement('/group-management', extra: newGroup);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi tạo lớp học nhóm. Vui lòng thử lại.')),
          );
        }
      }
    }
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Nếu xóa hết thì trả về rỗng
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Nếu người dùng đang xóa ký tự separator (dấu chấm)
    // thì ta xóa luôn ký tự số đứng trước nó
    String text = newValue.text;
    if (oldValue.text.length > newValue.text.length) {
       // Đang thực hiện thao tác xóa
       int selectionIndex = newValue.selection.end;
       if (oldValue.text.substring(selectionIndex, selectionIndex + 1) == separator) {
          // Người dùng vừa xóa dấu chấm -> ta cần xóa ký tự số trước đó
          String left = text.substring(0, selectionIndex - 1);
          String right = text.substring(selectionIndex);
          text = left + right;
       }
    }

    // Chỉ lấy các ký tự số
    String baseText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (baseText.isEmpty) return const TextEditingValue(text: '');

    final formatter = NumberFormat.decimalPattern('vi_VN');
    int value = int.parse(baseText);
    String formattedText = formatter.format(value);

    // Tính toán lại vị trí con trỏ
    int cursorOffset = formattedText.length;
    
    // Nếu không phải đang ở cuối chuỗi, ta cố gắng giữ vị trí tương đối (tạm thời để ở cuối cho đơn giản nhưng chắc chắn)
    // Thực tế việc ép về cuối chuỗi là cách ổn định nhất để tránh lỗi nhảy con trỏ khi có dấu phân cách động
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
