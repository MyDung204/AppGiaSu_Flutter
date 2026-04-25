enum ScheduleType { oneToOne, group }

class UnifiedScheduleItem {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleType type;
  final String? subtitle;
  final String? status;
  final String? studentName;
  final String? location;
  final dynamic originalItem; // BookingItem or Course

  UnifiedScheduleItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.subtitle,
    this.status,
    this.studentName,
    this.location,
    this.originalItem,
  });

  // Helper to check if it's today
  bool isToday() {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }
}
