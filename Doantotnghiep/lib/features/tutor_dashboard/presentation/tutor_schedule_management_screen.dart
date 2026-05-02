/// Tutor Schedule Management Screen
/// 
/// **Purpose:**
/// - Quản lý lịch dạy của gia sư
/// - Cho phép gia sư chọn các time slots rảnh trong tuần
/// 
/// **Features:**
/// - Xem lịch theo từng ngày trong tuần (Thứ 2 - Chủ Nhật)
/// - Chọn các time slots rảnh (08:00-10:00, 10:00-12:00, v.v.)
/// - Lưu lịch dạy (hiện tại là mock, cần tích hợp API)
/// 
/// **Time Slots:**
/// - 08:00 - 10:00
/// - 10:00 - 12:00
/// - 14:00 - 16:00
/// - 18:00 - 20:00
/// - 20:00 - 22:00
/// 
/// **TODO:**
/// - Tích hợp API để lưu lịch dạy
/// - Load lịch hiện tại từ backend
/// - Validate lịch dạy (không trùng với booking đã có)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_schedule_provider.dart';
import 'package:doantotnghiep/core/theme/edu_theme.dart';
import 'package:intl/intl.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/unified_schedule_item.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/class_detail_screen.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/session_detail_screen.dart';

/// Màn hình quản lý lịch dạy của gia sư
/// 
/// **Usage:**
/// - Truy cập từ tutor navigation → "Lịch dạy"
/// - Cho phép gia sư thiết lập lịch rảnh trong tuần
class TutorScheduleManagementScreen extends ConsumerStatefulWidget {
  const TutorScheduleManagementScreen({super.key});

  @override
  ConsumerState<TutorScheduleManagementScreen> createState() => _TutorScheduleManagementScreenState();
}

class _TutorScheduleManagementScreenState extends ConsumerState<TutorScheduleManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Key mapping: '2' = Thứ 2, '3' = Thứ 3, ..., '8' = Chủ Nhật
  final Map<String, List<String>> _schedule = {
    '2': [], '3': [], '4': [], '5': [], '6': [], '7': [], '8': [],
  };

  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '14:00 - 16:00',
    '18:00 - 20:00',
    '20:00 - 22:00',
  ];

  final Map<String, String> _dayLabels = {
    '2': 'Thứ 2', '3': 'Thứ 3', '4': 'Thứ 4', '5': 'Thứ 5', '6': 'Thứ 6', '7': 'Thứ 7', '8': 'Chủ Nhật',
  };

  bool _isLoading = true;
  String? _lastSyncedAvailabilitySignature;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (mounted) setState(() {});
  }

  String _availabilitySignature(List<Map<String, dynamic>> availabilities) {
    final parts = availabilities
        .map((item) => '${item['id'] ?? ''}:${item['day_of_week']}:${item['start_time']}:${item['end_time']}')
        .toList()
      ..sort();
    return parts.join('|');
  }

  void _syncLocalSchedule(List<Map<String, dynamic>> availabilities) {
    // Clear current
    for (var key in _schedule.keys) {
      _schedule[key] = [];
    }

    // Populate
    for (var item in availabilities) {
      final day = item['day_of_week'].toString();
      final startTime = _parseTime(item['start_time'].toString());
      final endTime = _parseTime(item['end_time'].toString());
      final slot = '$startTime - $endTime';
      
      if (_schedule.containsKey(day)) {
        if (!_schedule[day]!.contains(slot)) {
          _schedule[day]!.add(slot);
        }
      }
    }
  }

  String _parseTime(String time) {
    if (time.isEmpty) return '00:00';
    try {
      final parts = time.split(':');
      final h = parts[0].padLeft(2, '0');
      final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
      return '$h:$m';
    } catch (e) {
      return time.length >= 5 ? time.substring(0, 5) : time;
    }
  }

  Future<void> _showCustomTimePicker(String dayKey) async {
    // Pick Start Time
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Chọn giờ BẮT ĐẦU',
    );
    if (start == null) return;

    if (!mounted) return;

    // Pick End Time
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour >= 23 ? 23 : start.hour + 1, minute: start.minute),
      helpText: 'Chọn giờ KẾT THÚC',
    );
    if (end == null) return;

    // Validate
    final double startDouble = start.hour + start.minute / 60.0;
    final double endDouble = end.hour + end.minute / 60.0;

    if (endDouble <= startDouble) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Format HH:mm
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    final slot = '$startStr - $endStr';

    setState(() {
      if (!_schedule[dayKey]!.contains(slot)) {
        _schedule[dayKey]!.add(slot);
        _schedule[dayKey]!.sort();
      }
    });
  }

  Future<void> _saveSchedule() async {
    List<Map<String, dynamic>> apiPayload = [];
    _schedule.forEach((day, slots) {
      for (var slot in slots) {
        final times = slot.split(' - ');
        apiPayload.add({
          'day_of_week': int.parse(day),
          'start_time': '${times[0]}:00', // Append seconds
          'end_time': '${times[1]}:00',   // Append seconds
        });
      }
    });

    final success = await ref.read(tutorScheduleProvider.notifier).updateAvailability(apiPayload);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu lịch dạy thành công!'), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu lịch dạy'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(tutorScheduleProvider);
    
    // Sync only when API availability changes. Do not overwrite local edits on every setState.
    if (!scheduleState.isLoading) {
      final signature = _availabilitySignature(scheduleState.availability);
      if (signature != _lastSyncedAvailabilitySignature) {
        _syncLocalSchedule(scheduleState.availability);
        _lastSyncedAvailabilitySignature = signature;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lịch dạy & Giảng dạy'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EduTheme.primary,
          labelColor: EduTheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Lịch sắp tới'),
            Tab(text: 'Lịch sử dạy'),
            Tab(text: 'Lịch rảnh (Availability)'),
          ],
        ),
        actions: [
          if (scheduleState.isLoading)
             const Padding(padding: EdgeInsets.all(16), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))))
          else if (_tabController.index == 2)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSchedule,
            )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeachingSchedule(_upcomingItems(scheduleState.unifiedSchedule), emptyText: 'Chưa có lịch dạy nào sắp tới'),
          _buildTeachingSchedule(_historyItems(scheduleState.unifiedSchedule), emptyText: 'Chưa có buổi dạy nào đã hoàn thành'),
          _buildAvailabilityManager(scheduleState.isLoading),
        ],
      ),
    );
  }

  List<UnifiedScheduleItem> _upcomingItems(List<UnifiedScheduleItem> items) {
    final now = DateTime.now();
    return items.where((item) {
      final status = item.status?.toLowerCase() ?? '';
      if (status == 'completed' || status == 'cancelled') return false;
      return item.endTime.isAfter(now);
    }).toList();
  }

  List<UnifiedScheduleItem> _historyItems(List<UnifiedScheduleItem> items) {
    final now = DateTime.now();
    final history = items.where((item) {
      final status = item.status?.toLowerCase() ?? '';
      return status == 'completed' || item.endTime.isBefore(now);
    }).toList();
    history.sort((a, b) => b.startTime.compareTo(a.startTime));
    return history;
  }

  Widget _buildTeachingSchedule(List<UnifiedScheduleItem> items, {required String emptyText}) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: EduTheme.primary,
        onRefresh: () => ref.read(tutorScheduleProvider.notifier).fetchData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(emptyText, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: EduTheme.primary,
      onRefresh: () => ref.read(tutorScheduleProvider.notifier).fetchData(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildScheduleCard(item);
        },
      ),
    );
  }

  Widget _buildScheduleCard(UnifiedScheduleItem item) {
    final bool isGroup = item.type == ScheduleType.group;
    final bool isCompleted = item.status?.toLowerCase() == 'completed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isCompleted ? Colors.grey[200]! : (isGroup ? Colors.orange.withOpacity(0.1) : EduTheme.primary.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isGroup ? Colors.orange : EduTheme.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGroup ? Icons.group : Icons.person,
                  color: isGroup ? Colors.orange : EduTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.subtitle ?? (isGroup ? 'Lớp học nhóm' : 'Dạy kèm 1-1'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isGroup ? Colors.orange : _getStatusColor(item.status ?? '')).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isGroup ? 'Lớp học nhóm' : _getStatusText(item.status ?? 'upcoming'),
                  style: TextStyle(
                    color: isGroup ? Colors.orange : _getStatusColor(item.status ?? ''),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          if (item.studentName != null) ...[
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Học viên: ${item.studentName}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(item.startTime),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (item.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.location!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _openScheduleDetail(item);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isGroup ? Colors.orange : EduTheme.primary),
                foregroundColor: isGroup ? Colors.orange : EduTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Chi tiết buổi học'),
            ),
          ),
        ],
      ),
    );
  }

  void _openScheduleDetail(UnifiedScheduleItem item) {
    if (item.type == ScheduleType.oneToOne && item.originalItem is BookingItem) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(
            booking: item.originalItem as BookingItem,
            isReadOnly: false,
          ),
        ),
      );
      return;
    }

    if (item.type == ScheduleType.group && item.originalItem is Course) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassDetailScreen(
            course: item.originalItem as Course,
          ),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'confirmed':
        return 'Sắp tới';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Widget _buildAvailabilityManager(bool isLoading) {
    return RefreshIndicator(
      color: EduTheme.primary,
      onRefresh: () => ref.read(tutorScheduleProvider.notifier).fetchData(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _dayLabels.length,
        itemBuilder: (context, index) {
          final dayKey = _dayLabels.keys.elementAt(index);
          final dayName = _dayLabels[dayKey]!;
          final currentSlots = _schedule[dayKey] ?? [];

          return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3142))),
              subtitle: Text(
                currentSlots.isEmpty ? 'Chưa có lịch' : '${currentSlots.length} ca dạy đã chọn',
                style: TextStyle(color: currentSlots.isEmpty ? Colors.grey[500] : const Color(0xFF4F5D75), fontSize: 14),
              ),
              leading: CircleAvatar(
                backgroundColor: currentSlots.isEmpty ? Colors.grey[100] : const Color(0xFFE5E9FF),
                child: Icon(
                  Icons.calendar_view_day_rounded,
                  color: currentSlots.isEmpty ? Colors.grey[400] : const Color(0xFF4D6AFF),
                  size: 20,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      if (currentSlots.isNotEmpty) ...[
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Đã chọn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F5D75))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: currentSlots.map((slot) {
                            return InputChip(
                              label: Text(slot),
                              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              backgroundColor: const Color(0xFF4D6AFF),
                              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                              onDeleted: () {
                                setState(() {
                                  _schedule[dayKey]!.remove(slot);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          SizedBox(width: 8),
                          Text('Gợi ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F5D75))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _timeSlots.where((slot) => !currentSlots.contains(slot)).map((slot) {
                          return ActionChip(
                            label: Text(slot),
                            labelStyle: const TextStyle(color: Color(0xFF2D3142), fontSize: 13),
                            backgroundColor: const Color(0xFFF0F2F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                            onPressed: () {
                              setState(() {
                                _schedule[dayKey]!.add(slot);
                                _schedule[dayKey]!.sort();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () => _showCustomTimePicker(dayKey),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D6AFF).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4D6AFF).withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.more_time_rounded, size: 20, color: Color(0xFF4D6AFF)),
                                SizedBox(width: 10),
                                Text(
                                  'Thêm khung giờ khác',
                                  style: TextStyle(color: Color(0xFF4D6AFF), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
