import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/core/network/api_client.dart'; 

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';

import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';

class CreateTutorRequestScreen extends ConsumerStatefulWidget {
  final TutorRequest? requestToEdit;
  final bool isTutor;
  final String requestType;

  const CreateTutorRequestScreen({
    super.key, 
    this.requestToEdit, 
    this.isTutor = false,
    this.requestType = '1-1',
  });

  @override
  ConsumerState<CreateTutorRequestScreen> createState() => _CreateTutorRequestScreenState();
}

class _CreateTutorRequestScreenState extends ConsumerState<CreateTutorRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.requestToEdit != null) {
      final req = widget.requestToEdit!;
      _subjectController.text = req.subject;
      _gradeController.text = req.gradeLevel;
      _minBudgetController.text = req.minBudget.toStringAsFixed(0);
      _maxBudgetController.text = req.maxBudget.toStringAsFixed(0);
      _scheduleController.text = req.schedule;
      _locationController.text = req.location;
      _descController.text = req.description;
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final apiClient = ref.read(apiClientProvider);
        final data = {
          'subject': _subjectController.text.trim(),
          'grade_level': _gradeController.text.trim(),
          'min_budget': double.tryParse(_minBudgetController.text.trim()) ?? 0,
          'max_budget': double.tryParse(_maxBudgetController.text.trim()) ?? 0,
          'schedule': _scheduleController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descController.text.trim().isEmpty 
              ? 'Không có mô tả thêm' 
              : _descController.text.trim(),
          'is_tutor_created': widget.isTutor,
          'request_type': widget.requestType,
        };

        if (widget.requestToEdit != null) {
          // Update existing request
          await apiClient.put('/tutor-requests/${widget.requestToEdit!.id}', data: data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công!')),
            );
          }
        } else {
          // Create new request
          await apiClient.post('/tutor-requests', data: data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.isTutor ? 'Đăng tin tuyển học viên cho lớp nhóm thành công!' : 'Đăng yêu cầu dạy kèm 1-1 thành công!')),
            );
          }
        }

        if (mounted) {
          ref.invalidate(tutorRequestsProvider);
          ref.invalidate(myTutorRequestsProvider);
          context.pop();
        }
      } catch (e) {
         if (mounted) {
           print('Error submitting request: $e');
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
         }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Đăng yêu cầu dạy kèm 1-1';
    if (widget.requestToEdit != null) {
      title = 'Cập nhật yêu cầu';
    } else if (widget.isTutor) {
      title = 'Tuyển học viên cho lớp nhóm';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _subjectController.text.isNotEmpty && ['Toán', 'Lý', 'Hóa', 'Tiếng Anh', 'Văn', 'Sinh', 'Sử', 'Địa', 'Tin học', 'Piano', 'Guitar'].contains(_subjectController.text) 
                    ? _subjectController.text 
                    : null,
                items: ['Toán', 'Lý', 'Hóa', 'Tiếng Anh', 'Văn', 'Sinh', 'Sử', 'Địa', 'Tin học', 'Piano', 'Guitar']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _subjectController.text = v!),
                decoration: InputDecoration(
                  labelText: 'Môn học', 
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Chọn môn học' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gradeController.text.isNotEmpty && ['Lớp 1', 'Lớp 2', 'Lớp 3', 'Lớp 4', 'Lớp 5', 'Lớp 6', 'Lớp 7', 'Lớp 8', 'Lớp 9', 'Lớp 10', 'Lớp 11', 'Lớp 12', 'Đại học', 'Người đi làm'].contains(_gradeController.text) 
                    ? _gradeController.text 
                    : null,
                items: ['Lớp 1', 'Lớp 2', 'Lớp 3', 'Lớp 4', 'Lớp 5', 'Lớp 6', 'Lớp 7', 'Lớp 8', 'Lớp 9', 'Lớp 10', 'Lớp 11', 'Lớp 12', 'Đại học', 'Người đi làm']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gradeController.text = v!),
                decoration: InputDecoration(
                  labelText: 'Trình độ lớp', 
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                 validator: (v) => v == null || v.isEmpty ? 'Chọn lớp' : null,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle(widget.isTutor ? 'Học phí dự kiến / Học viên' : 'Ngân sách học phí'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Từ (VNĐ)', 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Nhập số tiền' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Đến (VNĐ)', 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Nhập số tiền' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Thời gian & Địa điểm'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scheduleController,
                decoration: InputDecoration(
                  labelText: 'Thời gian học (VD: Tối 2-4-6)', 
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập thời gian' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Địa điểm / Hình thức (VD: Online, Quận 1)', 
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập địa điểm' : null,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Mô tả chi tiết'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: widget.isTutor ? 'Mô tả về lớp học và yêu cầu với học viên' : 'Yêu cầu thêm (VD: Sinh viên Bách Khoa...)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(
                        widget.requestToEdit != null ? 'Cập nhật' : 'Đăng tin ngay',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
