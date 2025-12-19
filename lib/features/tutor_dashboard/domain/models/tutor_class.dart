

class TutorClass {
  final String id;
  final String tutorId;
  final String name;
  final String description;
  final String schedule;
  final String mode; // 'Online', 'Offline'
  final String? address;
  final double price;
  final int enrolledStudentCount;
  final String status; // 'upcoming', 'ongoing', 'completed'
  
  // SaaS Features
  final List<String> studentIds;
  final Map<String, String> paymentStatus; // Key: StudentId, Value: 'paid' | 'unpaid' | 'overdue'
  final DateTime? nextPaymentDate;

  TutorClass({
    required this.id,
    required this.tutorId,
    required this.name,
    this.description = '', 
    required this.schedule,
    required this.mode,
    this.address,
    required this.price,
    this.enrolledStudentCount = 0,
    this.status = 'upcoming',
    this.studentIds = const [],
    this.paymentStatus = const {},
    this.nextPaymentDate,
  });
}
