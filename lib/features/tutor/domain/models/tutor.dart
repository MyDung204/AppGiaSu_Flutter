class Tutor {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final List<String> subjects;
  final String bio;
  final String location;
  final bool isVerified;
  final String gender;
  final List<String> teachingMode; // ['Online', 'Offline']
  final String address;
  final Map<String, List<String>> weeklySchedule; // e.g. {'2': ['08:00 - 10:00', '14:00 - 16:00'], '3': []}
  final String tier; // 'teacher' | 'student'

  Tutor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.subjects,
    required this.bio,
    required this.location,
    this.isVerified = false,
    required this.gender,
    required this.teachingMode,
    required this.address,
    required this.weeklySchedule,
    this.tier = 'student',
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'].toString(), 
      name: json['name'],
      avatarUrl: json['avatar_url'] ?? '', 
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      subjects: List<String>.from(json['subjects'] ?? []),
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      gender: json['gender'] ?? 'Khác',
      teachingMode: List<String>.from(json['teaching_mode'] ?? ['Online']),
      address: json['address'] ?? '',
      weeklySchedule: Map<String, List<String>>.from(
        (json['weekly_schedule'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ) ?? {}),
      tier: json['tier'] ?? 'student',
    );
  }
}
