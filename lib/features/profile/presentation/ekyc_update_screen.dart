import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EkycUpdateScreen extends StatefulWidget {
  final bool isTutor;

  const EkycUpdateScreen({super.key, this.isTutor = false});

  @override
  State<EkycUpdateScreen> createState() => _EkycUpdateScreenState();
}

class _EkycUpdateScreenState extends State<EkycUpdateScreen> {
  // Mock file selection state
  bool _idCardUploaded = false;
  bool _degreeUploaded = false;
  bool _certificateUploaded = false;
  bool _studentCardUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực danh tính (eKYC)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isTutor
                          ? 'Vui lòng cung cấp CMND/CCCD và Bằng cấp để được duyệt hồ sơ dạy.'
                          : 'Vui lòng cung cấp Thẻ Học sinh/Sinh viên để xác thực tài khoản.',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (widget.isTutor) ...[
              _buildUploadSection(
                title: 'CMND / CCCD / Hộ chiếu',
                description: 'Chụp rõ 2 mặt giấy tờ tùy thân.',
                isUploaded: _idCardUploaded,
                onUpload: () => setState(() => _idCardUploaded = true),
              ),
              const SizedBox(height: 24),
              _buildUploadSection(
                title: 'Bằng cấp chuyên môn',
                description: 'Bằng Đại học, Cao đẳng hoặc Thẻ Sinh viên (nếu đang đi học).',
                isUploaded: _degreeUploaded,
                onUpload: () => setState(() => _degreeUploaded = true),
              ),
              const SizedBox(height: 24),
              _buildUploadSection(
                title: 'Chứng chỉ / Thành tựu (Tùy chọn)',
                description: 'IELTS, TOEIC, Giải thưởng HSG...',
                isUploaded: _certificateUploaded,
                onUpload: () => setState(() => _certificateUploaded = true),
                isOptional: true,
              ),
            ] else ...[
              _buildUploadSection(
                title: 'Thẻ Học sinh / Sinh viên',
                description: 'Chụp rõ mặt trước thẻ để xác nhận trạng thái học viên.',
                isUploaded: _studentCardUploaded,
                onUpload: () => setState(() => _studentCardUploaded = true),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi yêu cầu xác thực thành công!')),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Gửi yêu cầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String description,
    required bool isUploaded,
    required VoidCallback onUpload,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isOptional)
              const Text(' (Tùy chọn)', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 12),
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120, // Reduced height for conciseness
            width: double.infinity,
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded ? Colors.green : Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 1.5,
              ),
               // Dotted border effect simulation skipped for simplicity, using solid grey
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 32,
                  color: isUploaded ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  isUploaded ? 'Đã tải lên' : 'Bấm để tải ảnh lên',
                  style: TextStyle(
                    color: isUploaded ? Colors.green : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
