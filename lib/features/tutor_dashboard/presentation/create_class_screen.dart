import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_class_provider.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedMode = 'Offline'; // Online/Offline
  final List<String> _modes = ['Online', 'Offline'];

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mở lớp học mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên lớp học',
                  hintText: 'VD: Luyện thi Đại học môn Toán Cấp tốc',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên lớp' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedMode,
                decoration: const InputDecoration(labelText: 'Hình thức học', border: OutlineInputBorder()),
                items: _modes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedMode = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Lịch học',
                  hintText: 'VD: T2-T4-T6, 19h00 - 21h00',
                   border: OutlineInputBorder(),
                ),
                 validator: (val) => val!.isEmpty ? 'Vui lòng nhập lịch học' : null,
              ),
              const SizedBox(height: 16),

              if (_selectedMode == 'Offline')
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa điểm học',
                     border: OutlineInputBorder(),
                  ),
                   validator: (val) => val!.isEmpty ? 'Vui lòng nhập địa điểm' : null,
                ),
              if (_selectedMode == 'Offline') const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Học phí trọn gói (VNĐ)',
                   border: OutlineInputBorder(),
                ),
                 validator: (val) => val!.isEmpty ? 'Vui lòng nhập học phí' : null,
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                     backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác nhận Mở lớp'),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  void _submitClass() {
    if (_formKey.currentState!.validate()) {
      final newClass = TutorClass(
        id: const Uuid().v4(),
        tutorId: FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        name: _nameController.text,
        schedule: _scheduleController.text,
        mode: _selectedMode,
        address: _selectedMode == 'Offline' ? _addressController.text : null,
        price: double.tryParse(_priceController.text) ?? 0,
        status: 'upcoming',
      );

      ref.read(tutorClassProvider.notifier).addClass(newClass);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã mở lớp thành công!')),
      );
      context.pop();
    }
  }
}
