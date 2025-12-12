import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TutorScheduleManagementScreen extends StatefulWidget {
  const TutorScheduleManagementScreen({super.key});

  @override
  State<TutorScheduleManagementScreen> createState() => _TutorScheduleManagementScreenState();
}

class _TutorScheduleManagementScreenState extends State<TutorScheduleManagementScreen> {
  // Mock initial schedule. In real app, load from Tutor Model
  final Map<String, List<String>> _schedule = {
    '2': [], // Monday, keys map to weekday (2=Mon, 8=Sun per VN convention)
    '3': [],
    '4': [],
    '5': [],
    '6': [],
    '7': [],
    '8': [],
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
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu lịch dạy thành công!')),
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
