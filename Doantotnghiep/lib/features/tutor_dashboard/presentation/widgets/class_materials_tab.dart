import 'dart:io';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_material_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassMaterialsTab extends ConsumerStatefulWidget {
  final int? courseId;
  final int? studentId;
  final int? studyGroupId;
  final bool isTutor;

  const ClassMaterialsTab({
    super.key,
    this.courseId,
    this.studentId,
    this.studyGroupId,
    required this.isTutor,
  });

  @override
  ConsumerState<ClassMaterialsTab> createState() => _ClassMaterialsTabState();
}

class _ClassMaterialsTabState extends ConsumerState<ClassMaterialsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tutorMaterialsProvider.notifier).fetchMaterials(
        courseId: widget.courseId,
        studentId: widget.studentId,
        studyGroupId: widget.studyGroupId,
      );
    });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final success = await ref.read(tutorMaterialsProvider.notifier).uploadMaterial(
        result.files.single.path!,
        courseId: widget.courseId,
        studentId: widget.studentId,
        studyGroupId: widget.studyGroupId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Tải lên thành công' : 'Tải lên thất bại'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(tutorMaterialsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(tutorMaterialsProvider.notifier).fetchMaterials(
        courseId: widget.courseId,
        studentId: widget.studentId,
        studyGroupId: widget.studyGroupId,
      ),
      child: materialsAsync.when(
        data: (materials) {
          if (materials.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return _MaterialItemCard(
                material: material,
                isTutor: widget.isTutor,
                courseId: widget.courseId,
                studentId: widget.studentId,
                studyGroupId: widget.studyGroupId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài liệu nào',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (widget.isTutor) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickAndUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Tải lên tài liệu'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MaterialItemCard extends ConsumerWidget {
  final Map<String, dynamic> material;
  final bool isTutor;
  final int? courseId;
  final int? studentId;
  final int? studyGroupId;

  const _MaterialItemCard({
    required this.material,
    required this.isTutor,
    this.courseId,
    this.studentId,
    this.studyGroupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = material['name'] ?? 'Không tên';
    final String? fileUrl = material['file_url'];
    final String type = material['type'] ?? 'file';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          _getIconForType(type),
          color: _getColorForType(type),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Đã tải lên: ${material['created_at_human'] ?? 'Vừa xong'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.blue),
              onPressed: () async {
                if (fileUrl != null) {
                  final uri = Uri.parse(fileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
            if (isTutor)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final confirmed = await _showDeleteConfirm(context);
                  if (confirmed == true) {
                    await ref.read(tutorMaterialsProvider.notifier).deleteMaterial(
                      material['id'].toString(),
                      courseId: courseId,
                      studentId: studentId,
                      studyGroupId: studyGroupId,
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('pdf')) return Icons.picture_as_pdf;
    if (type.contains('image')) return Icons.image;
    if (type.contains('word') || type.contains('text')) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getColorForType(String type) {
    if (type.contains('pdf')) return Colors.red;
    if (type.contains('image')) return Colors.orange;
    if (type.contains('word')) return Colors.blue;
    return Colors.grey;
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: const Text('Bạn có chắc chắn muốn xóa tài liệu này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
