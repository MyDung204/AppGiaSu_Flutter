import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';

class CreateTutorRequestScreen extends ConsumerStatefulWidget {
  const CreateTutorRequestScreen({super.key});

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

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      try {
        final user = FirebaseAuth.instance.currentUser;
        // Allow mock user if not logged in for testing
        final studentId = user?.uid ?? 'test-user-id';
        final studentName = user?.displayName ?? user?.email ?? 'Học viên Mới';

        final request = TutorRequest(
          id: const Uuid().v4(),
          studentId: studentId,
          studentName: studentName,
          subject: _subjectController.text.trim(),
          gradeLevel: _gradeController.text.trim(),
          minBudget: double.parse(_minBudgetController.text.trim()),
          maxBudget: double.parse(_maxBudgetController.text.trim()),
          schedule: _scheduleController.text.trim(),
          description: _descController.text.trim(),
          location: _locationController.text.trim(),
          createdAt: DateTime.now(),
        );

        // Add to Mock Provider
        ref.read(tutorRequestsProvider.notifier).addRequest(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng yêu cầu thành công!')),
          );
          context.pop();
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
         }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng yêu cầu tìm gia sư')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Môn học (VD: Toán, Lý...)', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập môn học' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Lớp (VD: Lớp 12)', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập lớp' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ngân sách từ (VNĐ)', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Nhập số tiền' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Đến (VNĐ)', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Nhập số tiền' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Thời gian học (VD: Tối 2-4-6)', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập thời gian' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Địa điểm / Hình thức (VD: Online, Quận 1)', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập địa điểm' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Yêu cầu thêm (VD: Sinh viên Bách Khoa...)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Đăng tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
