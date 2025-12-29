/// Student Request List Screen
/// 
/// **Purpose:**
/// - Hiển thị danh sách yêu cầu tìm gia sư từ học viên
/// - Cho phép gia sư tìm kiếm và liên hệ với học viên
/// 
/// **Features:**
/// - Filter theo môn học và trình độ
/// - Xem chi tiết yêu cầu (môn học, cấp độ, ngân sách, mô tả)
/// - Trao đổi ngay: Mở chat với học viên
/// 
/// **Filter:**
/// - Môn học: Toán, Lý, Hóa, Văn, Anh, Piano, Khác
/// - Trình độ: Lớp 1-12, Đại học
/// 
/// **Action:**
/// - Click "Trao đổi ngay" → Mở chat với học viên (tạo Tutor object từ request)

import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình danh sách yêu cầu tìm gia sư
/// 
/// **Usage:**
/// - Truy cập từ tutor navigation → "Tìm lớp"
/// - Hoặc từ dashboard → "Xem tất cả" trong section "Học viên đang tìm lớp"
class StudentRequestListScreen extends ConsumerStatefulWidget {
  const StudentRequestListScreen({super.key});

  @override
  ConsumerState<StudentRequestListScreen> createState() => _StudentRequestListScreenState();
}

class _StudentRequestListScreenState extends ConsumerState<StudentRequestListScreen> {
  String? _selectedSubject;
  String? _selectedGrade;

  final List<String> _subjects = ['Toán', 'Lý', 'Hóa', 'Văn', 'Anh', 'Piano', 'Khác'];
  final List<String> _grades = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'ĐH'];

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(tutorRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tìm Học Viên', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _buildFilterChip(
                    label: _selectedSubject ?? 'Môn học',
                    isSelected: _selectedSubject != null,
                    onTap: () => _showFilterSheet(context, 'Chọn Môn học', _subjects, (val) {
                      setState(() => _selectedSubject = val);
                    }),
                    onClear: _selectedSubject != null ? () => setState(() => _selectedSubject = null) : null,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _selectedGrade != null ? 'Lớp $_selectedGrade' : 'Trình độ',
                    isSelected: _selectedGrade != null,
                    onTap: () => _showFilterSheet(context, 'Chọn Trình độ', _grades, (val) {
                      setState(() => _selectedGrade = val);
                    }),
                     onClear: _selectedGrade != null ? () => setState(() => _selectedGrade = null) : null,
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                // local filtering
                final filtered = requests.where((req) {
                  if (_selectedSubject != null && req.subject != _selectedSubject) return false;
                  if (_selectedGrade != null && !req.gradeLevel.contains(_selectedGrade!)) return false;
                  return true;
                }).toList();

                // Empty state: Hiển thị khi không tìm thấy yêu cầu nào sau filter
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "Không tìm thấy yêu cầu nào.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (_selectedSubject != null || _selectedGrade != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Thử thay đổi bộ lọc.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final req = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${req.subject} - ${req.gradeLevel}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              Text(
                                '${(req.minBudget/1000).toInt()}k - ${(req.maxBudget/1000).toInt()}k', 
                                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            req.description.isEmpty ? 'Không có mô tả' : req.description,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(req.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const Spacer(),
                              const Text('Vừa xong', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final studentAsTarget = Tutor(
                                  id: req.studentId,
                                  name: req.studentName,
                                  bio: 'Học viên',
                                  hourlyRate: 0,
                                  subjects: [],
                                  rating: 0,
                                  avatarUrl: 'https://i.pravatar.cc/150?u=${req.studentId}',
                                  reviewCount: 0,
                                  location: req.location, 
                                  gender: 'Khác',
                                  teachingMode: [],
                                  address: '',
                                  weeklySchedule: {},
                                );
                                
                                context.push('/chat', extra: {
                                  'tutor': studentAsTarget,
                                  'request': req,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Trao đổi ngay'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip widget
  /// 
  /// **Purpose:**
  /// - Hiển thị filter chip với khả năng clear
  /// - Sử dụng trong filter bar để lọc yêu cầu
  /// 
  /// **Parameters:**
  /// - `label`: Text hiển thị trên chip
  /// - `isSelected`: Trạng thái selected
  /// - `onTap`: Callback khi click vào chip
  /// - `onClear`: Callback khi click vào nút clear (optional)
  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap, VoidCallback? onClear}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: Colors.blue),
              )
            ] else 
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Hiển thị bottom sheet để chọn filter
  /// 
  /// **Purpose:**
  /// - Hiển thị danh sách options để chọn (môn học hoặc trình độ)
  /// - Cho phép user chọn một option
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext để hiển thị bottom sheet
  /// - `title`: Tiêu đề của bottom sheet
  /// - `items`: Danh sách options để chọn
  /// - `onSelect`: Callback khi chọn một option
  void _showFilterSheet(BuildContext context, String title, List<String> items, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index], textAlign: TextAlign.center),
                    onTap: () {
                      onSelect(items[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
