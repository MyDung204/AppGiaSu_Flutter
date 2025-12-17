class Course {
  final String id;
  final String tutorId;
  final String tutorName;
  final String title;
  final String description;
  final double price;
  final int maxStudents;
  final DateTime startDate;
  final String schedule;
  final String status;

  Course({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.title,
    required this.description,
    required this.price,
    required this.maxStudents,
    required this.startDate,
    required this.schedule,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      tutorId: json['tutor_id']?.toString() ?? '',
      tutorName: json['tutor']?['name'] ?? 'Giảng viên',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      maxStudents: json['max_students'] ?? 0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      schedule: json['schedule'] ?? '',
      status: json['status'] ?? 'open',
    );
  }
}
