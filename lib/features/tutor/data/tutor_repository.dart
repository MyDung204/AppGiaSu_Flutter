import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/search/domain/models/search_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  return MockTutorRepository();
});

abstract class TutorRepository {
  Future<List<Tutor>> getFeaturedTutors();
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter});
}

class MockTutorRepository implements TutorRepository {
  final List<Tutor> _tutors = [
    Tutor(
      id: '1',
      name: 'Nguyễn Văn A',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
      rating: 4.8,
      reviewCount: 120,
      hourlyRate: 150000,
      subjects: ['Toán', 'Lý'],
      bio: 'Sinh viên ĐH Bách Khoa, kinh nghiệm gia sư 2 năm. Chuyên dạy lấy gốc.',
      location: 'Quận 10, TP.HCM',
      isVerified: true,
      gender: 'Nam',
      teachingMode: ['Online', 'Offline'],
      address: '123 CMT8, Q.10',
      weeklySchedule: {
        '2': ['08:00 - 10:00', '14:00 - 16:00'],
        '4': ['18:00 - 20:00'],
        '6': ['08:00 - 10:00']
      },
    ),
    Tutor(
      id: '2',
      name: 'Trần Thị B',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      rating: 4.9,
      reviewCount: 50,
      hourlyRate: 200000,
      subjects: ['Tiếng Anh', 'IELTS'],
      bio: 'Giáo viên tiếng Anh, chứng chỉ IELTS 8.0. Dạy giao tiếp và luyện thi.',
      location: 'Quận 1, TP.HCM',
      isVerified: true,
      gender: 'Nữ',
      teachingMode: ['Online'],
      address: '456 Nguyễn Huệ, Q.1',
      weeklySchedule: {
        '3': ['18:00 - 20:00'],
        '5': ['18:00 - 20:00'],
        '7': ['09:00 - 11:00', '14:00 - 16:00']
      },
    ),
    Tutor(
      id: '3',
      name: 'Lê Hoàng C',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
      rating: 4.5,
      reviewCount: 30,
      hourlyRate: 120000,
      subjects: ['Hóa', 'Sinh'],
      bio: 'Sinh viên Y Dược, nhiệt tình, vui vẻ.',
      location: 'Quận 5, TP.HCM',
      isVerified: false,
      gender: 'Nam',
      teachingMode: ['Offline'],
      address: '789 Trần Hưng Đạo, Q.5',
      weeklySchedule: {
        '2': ['19:00 - 21:00'],
        '4': ['19:00 - 21:00'],
        '6': ['19:00 - 21:00']
      },
    ),
    Tutor(
      id: '4',
      name: 'Phạm Minh D',
      avatarUrl: 'https://i.pravatar.cc/150?u=4',
      rating: 5.0,
      reviewCount: 15,
      hourlyRate: 250000,
      subjects: ['Piano', 'Nhạc lý'],
      bio: 'Giảng viên nhạc viện, dạy piano từ cơ bản đến nâng cao.',
      location: 'Đống Đa, Hà Nội',
      isVerified: true,
      gender: 'Nữ',
      teachingMode: ['Online', 'Offline'],
      address: '12 Cát Linh, Đống Đa',
      weeklySchedule: {
        '7': ['08:00 - 10:00'],
        '8': ['08:00 - 10:00', '15:00 - 17:00'],
      },
    ),
  ];

  @override
  Future<List<Tutor>> getFeaturedTutors() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _tutors;
  }

  @override
  Future<List<Tutor>> searchTutors(String query, {SearchFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _tutors.where((tutor) {
      // 1. Text Query
      final matchQuery = query.isEmpty || 
          tutor.name.toLowerCase().contains(query.toLowerCase()) || 
          tutor.subjects.any((s) => s.toLowerCase().contains(query.toLowerCase()));
      if (!matchQuery) return false;

      // 2. Filter
      if (filter != null) {
        // Price
        if (filter.minPrice != null && tutor.hourlyRate < filter.minPrice!) return false;
        if (filter.maxPrice != null && tutor.hourlyRate > filter.maxPrice!) return false;
        
        // Gender
        if (filter.gender != null && filter.gender != 'Bất kỳ' && tutor.gender != filter.gender) return false;
        
        // Location
        if (filter.location != null && filter.location!.isNotEmpty && !tutor.location.contains(filter.location!)) return false;
        
        // Mode
        if (filter.teachingMode != null && filter.teachingMode!.isNotEmpty) {
           // If filter has 'Online' and tutor doesn't have 'Online', fail.
           // Or simplified: if tutor teachingMode has ANY intersection with filter mode?
           // Usually "Filter by Online" means "Show me tutors who teach Online".
           // Ensure tutor.teachingMode contains at least one of the selected filter modes.
           final hasMode = filter.teachingMode!.any((m) => tutor.teachingMode.contains(m));
           if (!hasMode) return false;
        }

        // Subject Filter (Advanced)
        if (filter.subjects != null && filter.subjects!.isNotEmpty) {
           final hasSubject = filter.subjects!.any((s) => tutor.subjects.contains(s));
           if (!hasSubject) return false;
        }
      }
      return true;
    }).toList();
  }
}
