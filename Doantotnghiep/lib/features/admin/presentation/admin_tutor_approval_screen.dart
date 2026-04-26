import 'package:doantotnghiep/features/admin/data/admin_repository.dart';
import 'package:doantotnghiep/features/admin/data/admin_tutor_request_provider.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminTutorApprovalScreen extends ConsumerStatefulWidget {
  const AdminTutorApprovalScreen({super.key});

  @override
  ConsumerState<AdminTutorApprovalScreen> createState() => _AdminTutorApprovalScreenState();
}

class _AdminTutorApprovalScreenState extends ConsumerState<AdminTutorApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(tutorRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Phê duyệt Gia sư'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: requestsAsync.when(
        data: (tutors) {
          if (tutors.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshTutorRequests,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 64, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có yêu cầu nào đang chờ.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tất cả gia sư đã được duyệt.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTutorRequests,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: tutors.length,
              itemBuilder: (context, index) => _buildCard(tutors[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Future<void> _refreshTutorRequests() async {
    ref.invalidate(tutorRequestsProvider);
    await ref.read(tutorRequestsProvider.future);
  }

  Widget _buildCard(Tutor tutor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: tutor.avatarUrl.isNotEmpty ? NetworkImage(tutor.avatarUrl) : null,
                child: tutor.avatarUrl.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(tutor.subjects.isEmpty ? 'Chưa cập nhật môn dạy' : tutor.subjects.join(', ')),
                    const SizedBox(height: 4),
                    Text(tutor.location.isEmpty ? 'Chưa cập nhật khu vực' : tutor.location),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showReviewDialog(tutor),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Kiểm tra'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReviewDialog(Tutor tutor) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Kiểm tra hồ sơ gia sư',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTutorInfo(tutor),
                const SizedBox(height: 20),
                const Text(
                  'Ảnh bằng chứng eKYC',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildEvidenceImages(tutor),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmReject(dialogContext, tutor),
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _handleApprove(tutor);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Duyệt'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorInfo(Tutor tutor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('Họ tên', tutor.name),
          _buildInfoRow('Số điện thoại', tutor.phone.isEmpty ? 'Chưa cập nhật' : tutor.phone),
          _buildInfoRow('Khu vực', tutor.location.isEmpty ? 'Chưa cập nhật' : tutor.location),
          _buildInfoRow('Địa chỉ', tutor.address.isEmpty ? 'Chưa cập nhật' : tutor.address),
          _buildInfoRow('Môn dạy', tutor.subjects.isEmpty ? 'Chưa cập nhật' : tutor.subjects.join(', ')),
          _buildInfoRow('Trường', tutor.university.isEmpty ? 'Chưa cập nhật' : tutor.university),
          _buildInfoRow('Bằng cấp', tutor.degree.isEmpty ? 'Chưa cập nhật' : tutor.degree),
          _buildInfoRow('Học phí/giờ', '${tutor.hourlyRate.toStringAsFixed(0)}đ'),
          _buildInfoRow('Trạng thái eKYC', tutor.verificationStatus ?? 'Chưa có hồ sơ eKYC'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceImages(Tutor tutor) {
    final frontUrl = tutor.verificationFrontImageUrl;
    final backUrl = tutor.verificationBackImageUrl;
    final hasDistinctBackImage = backUrl != null && backUrl.isNotEmpty && backUrl != frontUrl;

    if (!hasDistinctBackImage) {
      return _buildEvidenceImage('CCCD/CMND/Hộ chiếu', frontUrl);
    }

    return Row(
      children: [
        Expanded(child: _buildEvidenceImage('CCCD/CMND/Hộ chiếu', frontUrl)),
        const SizedBox(width: 12),
        Expanded(child: _buildEvidenceImage('Bằng cấp / ảnh bổ sung', backUrl)),
      ],
    );
  }

  Widget _buildEvidenceImage(String label, String? url) {
    final imageUrl = _resolveImageUrl(url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Text('Không tải được ảnh')),
                  )
                : const Center(child: Text('Chưa có ảnh')),
          ),
        ),
      ],
    );
  }

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final baseUri = Uri.parse(ApiConstants.baseUrl);
    final origin = '${baseUri.scheme}://${baseUri.authority}';
    return Uri.parse(origin).resolve(url).toString();
  }

  Future<void> _confirmReject(BuildContext reviewDialogContext, Tutor tutor) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối hồ sơ gia sư'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lý do từ chối',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do từ chối')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (reviewDialogContext.mounted) {
      Navigator.pop(reviewDialogContext);
    }
    await _handleReject(tutor, reasonController.text.trim());
  }

  Future<bool> _handleApprove(Tutor tutor) async {
    try {
      final success = await ref.read(adminRepositoryProvider).approveTutor(int.tryParse(tutor.id) ?? 0);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã duyệt ${tutor.name}'), backgroundColor: Colors.green),
          );
        }
        ref.invalidate(tutorRequestsProvider);
        return true;
      }
    } catch (e) {
      debugPrint('Error approving tutor: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duyệt gia sư thất bại'), backgroundColor: Colors.red),
      );
    }
    return false;
  }

  Future<bool> _handleReject(Tutor tutor, String reason) async {
    try {
      final success = await ref.read(adminRepositoryProvider).rejectTutor(
            int.tryParse(tutor.id) ?? 0,
            reason: reason,
          );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã từ chối ${tutor.name}'), backgroundColor: Colors.orange),
          );
        }
        ref.invalidate(tutorRequestsProvider);
        return true;
      }
    } catch (e) {
      debugPrint('Error rejecting tutor: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Từ chối gia sư thất bại'), backgroundColor: Colors.red),
      );
    }
    return false;
  }
}
