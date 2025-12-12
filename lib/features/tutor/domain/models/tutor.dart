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
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      hourlyRate: json['hourlyRate'].toDouble(),
      subjects: List<String>.from(json['subjects']),
      bio: json['bio'],
      location: json['location'],
      isVerified: json['isVerified'] ?? false,
      gender: json['gender'] ?? 'Khác',
      teachingMode: List<String>.from(json['teachingMode'] ?? ['Online']),
      address: json['address'] ?? '',
      weeklySchedule: Map<String, List<String>>.from(
        (json['weeklySchedule'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ) ?? {}),
    );
  }
}
