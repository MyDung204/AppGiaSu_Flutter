import 'dart:io';

import 'package:doantotnghiep/features/verification/data/verification_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EkycUpdateScreen extends ConsumerStatefulWidget {
  final bool isTutor;

  const EkycUpdateScreen({super.key, this.isTutor = false});

  @override
  ConsumerState<EkycUpdateScreen> createState() => _EkycUpdateScreenState();
}

class _EkycUpdateScreenState extends ConsumerState<EkycUpdateScreen> {
  File? _idCardImage;
  File? _degreeImage;
  File? _certificateImage;
  File? _studentCardImage;
  VerificationState? _currentState;
  bool _isLoadingStatus = true;
  bool _isSubmitting = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  bool get _hasRequiredDocuments {
    return widget.isTutor ? _idCardImage != null : _studentCardImage != null;
  }

  File get _requiredDocument => widget.isTutor ? _idCardImage! : _studentCardImage!;

  Future<void> _loadStatus() async {
    final status = await ref.read(verificationRepositoryProvider).getStatus();
    if (!mounted) return;
    setState(() {
      _currentState = status;
      _isLoadingStatus = false;
    });
  }

  Future<void> _pickImage(ValueChanged<File> onPicked) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tải ảnh lên từ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Chụp ảnh mới'),
              onTap: () => _selectImage(ctx, ImageSource.camera, onPicked),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Chọn từ thư viện ảnh'),
              onTap: () => _selectImage(ctx, ImageSource.gallery, onPicked),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(
    BuildContext sheetContext,
    ImageSource source,
    ValueChanged<File> onPicked,
  ) async {
    Navigator.pop(sheetContext);
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        setState(() => onPicked(File(pickedFile.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_hasRequiredDocuments) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isTutor
                ? 'Vui lòng tải lên CCCD/CMND/Hộ chiếu.'
                : 'Vui lòng tải lên thẻ Học sinh/Sinh viên.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(verificationRepositoryProvider).submitRequest(
          _requiredDocument,
          backImage: _degreeImage,
        );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (success) {
        _currentState = VerificationState(status: VerificationStatus.pending);
      }
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi gửi yêu cầu. Vui lòng thử lại.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đã gửi yêu cầu'),
        content: const Text('Hồ sơ của bạn đã được gửi. Vui lòng chờ Admin phê duyệt.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStatus) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentState?.status == VerificationStatus.pending) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildStatusView(
          icon: Icons.hourglass_top,
          color: Colors.orange,
          title: 'Đang chờ duyệt',
          message: 'Hồ sơ eKYC của bạn đã được gửi. Vui lòng chờ Admin kiểm tra và phê duyệt.',
          showRefresh: true,
        ),
      );
    }

    if (_currentState?.status == VerificationStatus.approved) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildStatusView(
          icon: Icons.verified_user,
          color: Colors.green,
          title: 'Đã xác thực',
          message: 'Bạn đã xác thực danh tính thành công.',
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentState?.status == VerificationStatus.rejected) ...[
              _buildRejectedBox(),
              const SizedBox(height: 16),
            ],
            _buildInfoBox(),
            const SizedBox(height: 24),
            if (widget.isTutor) ...[
              _buildUploadSection(
                title: 'CMND / CCCD / Hộ chiếu',
                description: 'Chụp rõ giấy tờ tùy thân.',
                imageFile: _idCardImage,
                onUpload: () => _pickImage((file) => _idCardImage = file),
              ),
              const SizedBox(height: 24),
              _buildUploadSection(
                title: 'Bằng cấp chuyên môn',
                description: 'Bằng Đại học, Cao đẳng hoặc Thẻ Sinh viên nếu đang đi học.',
                imageFile: _degreeImage,
                onUpload: () => _pickImage((file) => _degreeImage = file),
                isOptional: true,
              ),
              const SizedBox(height: 24),
              _buildUploadSection(
                title: 'Chứng chỉ / Thành tựu',
                description: 'IELTS, TOEIC, giải thưởng học sinh giỏi...',
                imageFile: _certificateImage,
                onUpload: () => _pickImage((file) => _certificateImage = file),
                isOptional: true,
              ),
            ] else ...[
              _buildUploadSection(
                title: 'Thẻ Học sinh / Sinh viên',
                description: 'Chụp rõ mặt trước thẻ để xác nhận trạng thái học viên.',
                imageFile: _studentCardImage,
                onUpload: () => _pickImage((file) => _studentCardImage = file),
              ),
            ],
            const SizedBox(height: 32),
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi yêu cầu'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isTutor
                  ? 'Vui lòng cung cấp CMND/CCCD hoặc Hộ chiếu. Bằng cấp và chứng chỉ là tùy chọn, có thể bổ sung sau.'
                  : 'Vui lòng cung cấp Thẻ Học sinh/Sinh viên để xác thực tài khoản.',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Xác thực danh tính (eKYC)'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
          }
        },
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    bool showRefresh = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            if (showRefresh) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _isLoadingStatus = true);
                  _loadStatus();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới trạng thái'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hồ sơ bị từ chối${(_currentState?.note ?? '').isNotEmpty ? ': ${_currentState!.note}' : '. Vui lòng kiểm tra và gửi lại.'}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String description,
    required File? imageFile,
    required VoidCallback onUpload,
    bool isOptional = false,
  }) {
    final isUploaded = imageFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (isOptional)
              const Text('Tùy chọn', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 12),
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isUploaded ? Colors.black : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded ? Colors.green : Colors.grey[300]!,
                width: 1.5,
              ),
              image: isUploaded
                  ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover, opacity: 0.8)
                  : null,
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
                  isUploaded ? 'Đã chọn ảnh' : 'Bấm để chụp/tải ảnh',
                  style: TextStyle(
                    color: isUploaded ? Colors.white : Colors.grey[600],
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
