import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedMode = 'Offline'; // Online/Offline
  final List<String> _modes = ['Online', 'Offline'];

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
                  onPressed: () {
                     if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã mở lớp thành công!')),
                      );
                      context.pop();
                    }
                  },
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
}
