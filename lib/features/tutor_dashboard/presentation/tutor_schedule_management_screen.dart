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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Màn hình quản lý lịch dạy của gia sư
/// 
/// **Usage:**
/// - Truy cập từ tutor navigation → "Lịch dạy"
/// - Cho phép gia sư thiết lập lịch rảnh trong tuần
class TutorScheduleManagementScreen extends StatefulWidget {
  const TutorScheduleManagementScreen({super.key});

  @override
  State<TutorScheduleManagementScreen> createState() => _TutorScheduleManagementScreenState();
}

class _TutorScheduleManagementScreenState extends State<TutorScheduleManagementScreen> {
  // Lịch dạy hiện tại (mock data)
  // TODO: Load từ Tutor Model hoặc API
  // Key mapping: '2' = Thứ 2, '3' = Thứ 3, ..., '8' = Chủ Nhật (theo convention VN)
  final Map<String, List<String>> _schedule = {
    '2': [], // Thứ 2
    '3': [], // Thứ 3
    '4': [], // Thứ 4
    '5': [], // Thứ 5
    '6': [], // Thứ 6
    '7': [], // Thứ 7
    '8': [], // Chủ Nhật
  };

  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '14:00 - 16:00',
    '18:00 - 20:00',
    '20:00 - 22:00',
  ];

  final Map<String, String> _dayLabels = {
    '2': 'Thứ 2',
    '3': 'Thứ 3',
    '4': 'Thứ 4',
    '5': 'Thứ 5',
    '6': 'Thứ 6',
    '7': 'Thứ 7',
    '8': 'Chủ Nhật',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lịch dạy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
               // TODO: Tích hợp API để lưu lịch dạy
               // Hiện tại chỉ hiển thị thông báo mock
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu lịch dạy thành công!'),
                    backgroundColor: Colors.green,
                  ),
               );
               context.pop();
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dayLabels.length,
        itemBuilder: (context, index) {
          final dayKey = _dayLabels.keys.elementAt(index);
          final dayName = _dayLabels[dayKey]!;
          final currentSlots = _schedule[dayKey] ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                currentSlots.isEmpty ? 'Chưa có lịch' : '${currentSlots.length} ca dạy',
                style: TextStyle(color: currentSlots.isEmpty ? Colors.grey : Colors.blue),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final isSelected = currentSlots.contains(slot);
                      return FilterChip(
                        label: Text(slot),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _schedule[dayKey]!.add(slot);
                            } else {
                              _schedule[dayKey]!.remove(slot);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
