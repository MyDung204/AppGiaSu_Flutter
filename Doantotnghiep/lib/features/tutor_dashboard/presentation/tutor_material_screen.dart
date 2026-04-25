import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_material_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TutorMaterialScreen extends ConsumerStatefulWidget {
  const TutorMaterialScreen({super.key});

  @override
  ConsumerState<TutorMaterialScreen> createState() => _TutorMaterialScreenState();
}

class _TutorMaterialScreenState extends ConsumerState<TutorMaterialScreen> {
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath == null) return;
        
        // Show loading
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        // Upload using provider
        final success = await ref.read(tutorMaterialsProvider.notifier).uploadMaterial(filePath);

        if (mounted) {
          Navigator.pop(context); // Close loading
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tải lên tài liệu thành công!'), backgroundColor: Colors.green),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lỗi tải lên tài liệu'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
       }
    }
  }

  Future<void> _deleteMaterial(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
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

    if (confirmed == true) {
      final success = await ref.read(tutorMaterialsProvider.notifier).deleteMaterial(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa tài liệu')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi xóa tài liệu'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _renameMaterial(Map<String, dynamic> material) async {
    final controller = TextEditingController(text: material['name']?.toString() ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên tài liệu'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên tài liệu',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || newName.isEmpty || newName == material['name']) return;

    final success = await ref.read(tutorMaterialsProvider.notifier).updateMaterial(
          material['id'].toString(),
          newName,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã cập nhật tài liệu' : 'Cập nhật tài liệu thất bại'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(tutorMaterialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tutorMaterialsProvider.notifier).fetchMaterials(),
          ),
        ],
      ),
      body: materialsAsync.when(
        data: (materials) => materials.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Chưa có tài liệu nào', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Tải lên ngay'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return _buildMaterialCard(material);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Lỗi: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        label: const Text('Thêm tài liệu'),
        icon: const Icon(Icons.add),
        backgroundColor: EduTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    IconData iconData;
    Color iconColor;
    
    final type = (material['file_type'] ?? '').toUpperCase();

    switch (type) {
      case 'PDF':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'DOCX':
      case 'DOC':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'PPTX':
      case 'PPT':
        iconData = Icons.slideshow_rounded;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${material['file_size']} • ${DateFormat('dd/MM/yyyy').format(DateTime.parse(material['created_at']))}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'rename') {
                _renameMaterial(material);
              } else if (value == 'delete') {
                _deleteMaterial(material['id'].toString());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Sửa tên'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
