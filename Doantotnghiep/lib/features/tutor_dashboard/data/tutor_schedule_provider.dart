import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/booking/data/booking_provider.dart';
import 'package:doantotnghiep/features/group/data/shared_learning_repository.dart';
import 'package:doantotnghiep/features/group/domain/models/course.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/unified_schedule_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for Unified Tutor Schedule
class TutorScheduleState {
  final List<Map<String, dynamic>> availability;
  final List<BookingItem> tuitions;
  final List<Course> courses;
  final List<UnifiedScheduleItem> unifiedSchedule;
  final bool isLoading;

  TutorScheduleState({
    this.availability = const [],
    this.tuitions = const [],
    this.courses = const [],
    this.unifiedSchedule = const [],
    this.isLoading = false,
  });

  TutorScheduleState copyWith({
    List<Map<String, dynamic>>? availability,
    List<BookingItem>? tuitions,
    List<Course>? courses,
    List<UnifiedScheduleItem>? unifiedSchedule,
    bool? isLoading,
  }) {
    return TutorScheduleState(
      availability: availability ?? this.availability,
      tuitions: tuitions ?? this.tuitions,
      courses: courses ?? this.courses,
      unifiedSchedule: unifiedSchedule ?? this.unifiedSchedule,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TutorScheduleNotifier extends StateNotifier<TutorScheduleState> {
  final TutorRepository _tutorRepository;
  final SharedLearningRepository _sharedLearningRepository;
  final Ref _ref;

  TutorScheduleNotifier(this._tutorRepository, this._sharedLearningRepository, this._ref) : super(TutorScheduleState()) {
    fetchData();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true);
    try {
      final avail = await _tutorRepository.getMyAvailability();
      final tuitionsData = await _tutorRepository.getMyTuitions();
      final courses = await _sharedLearningRepository.getMyCourses();
      
      // Convert tuitionsData to BookingItem list
      final tuitions = tuitionsData.map((e) => BookingItem.fromJson(e)).toList();

      final unifiedSchedule = _mergeAndSortSchedule(tuitions, courses);

      state = state.copyWith(
        availability: avail,
        tuitions: tuitions,
        courses: courses,
        unifiedSchedule: unifiedSchedule,
        isLoading: false,
      );
    } catch (e) {
      print('Error fetching tutor schedule data: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  List<UnifiedScheduleItem> _mergeAndSortSchedule(List<BookingItem> tuitions, List<Course> courses) {
    List<UnifiedScheduleItem> items = [];

    // 1. Add Bookings (1-1)
    for (var booking in tuitions) {
      if (booking.status.toLowerCase() == 'cancelled') continue;

      final times = booking.timeSlot.split(' - ');
      if (times.length == 2) {
        final startParts = times[0].split(':');
        final endParts = times[1].split(':');
        
        final startTime = DateTime(
          booking.date.year, booking.date.month, booking.date.day,
          int.parse(startParts[0]), int.parse(startParts[1])
        );
        final endTime = DateTime(
          booking.date.year, booking.date.month, booking.date.day,
          int.parse(endParts[0]), int.parse(endParts[1])
        );

        items.add(UnifiedScheduleItem(
          id: 'booking_${booking.id}',
          title: booking.lessonTopic ?? 'Dạy kèm 1-1',
          subtitle: booking.gradeLevel ?? 'Gia sư',
          startTime: startTime,
          endTime: endTime,
          type: ScheduleType.oneToOne,
          status: booking.status,
          studentName: booking.student?.name,
          originalItem: booking,
        ));
      }
    }

    // 2. Add Courses (Group) - Expand recurring schedule for next 30 days
    for (var course in courses) {
      items.addAll(_expandCourseSchedule(course));
    }

    // 3. Sort by start time
    items.sort((a, b) => a.startTime.compareTo(b.startTime));

    return items;
  }

  List<UnifiedScheduleItem> _expandCourseSchedule(Course course) {
    List<UnifiedScheduleItem> expandedItems = [];
    
    // Format expected: "T2, T4, T6 (08:00 - 10:00)"
    final scheduleStr = course.schedule;
    if (scheduleStr.isEmpty) return [];

    try {
      final parts = scheduleStr.split('(');
      if (parts.length < 2) return [];

      final daysStr = parts[0].trim();
      final timeStr = parts[1].replaceAll(')', '').trim();
      final times = timeStr.split(' - ');
      if (times.length < 2) return [];

      final startParts = times[0].split(':');
      final endParts = times[1].split(':');

      // Map days
      final List<int> weekDays = []; // 1 = Monday, ..., 7 = Sunday
      final days = daysStr.split(',').map((e) => e.trim()).toList();
      for (var d in days) {
        if (d.contains('T2')) weekDays.add(1);
        else if (d.contains('T3')) weekDays.add(2);
        else if (d.contains('T4')) weekDays.add(3);
        else if (d.contains('T5')) weekDays.add(4);
        else if (d.contains('T6')) weekDays.add(5);
        else if (d.contains('T7')) weekDays.add(6);
        else if (d.contains('CN') || d.contains('T8')) weekDays.add(7);
      }

      // Expand for next 30 days starting from max(today, startDate)
      final now = DateTime.now();
      final startSearch = course.startDate.isAfter(now) ? course.startDate : DateTime(now.year, now.month, now.day);
      
      for (int i = 0; i < 30; i++) {
        final date = startSearch.add(Duration(days: i));
        if (weekDays.contains(date.weekday)) {
          final startTime = DateTime(
            date.year, date.month, date.day,
            int.parse(startParts[0]), int.parse(startParts[1])
          );
          final endTime = DateTime(
            date.year, date.month, date.day,
            int.parse(endParts[0]), int.parse(endParts[1])
          );

          expandedItems.add(UnifiedScheduleItem(
            id: 'course_${course.id}_${date.millisecondsSinceEpoch}',
            title: course.title,
            subtitle: '${course.subject} - ${course.gradeLevel}',
            startTime: startTime,
            endTime: endTime,
            type: ScheduleType.group,
            status: course.status,
            location: course.mode == 'Offline' ? course.address : 'Online',
            originalItem: course,
          ));
        }
      }
    } catch (e) {
      print('Error parsing course schedule: $e');
    }

    return expandedItems;
  }

  Future<bool> updateAvailability(List<Map<String, dynamic>> payload) async {
    state = state.copyWith(isLoading: true);
    final success = await _tutorRepository.updateAvailability(payload);
    if (success) {
      await fetchData();
    } else {
      state = state.copyWith(isLoading: false);
    }
    return success;
  }
}

final tutorScheduleProvider = StateNotifierProvider<TutorScheduleNotifier, TutorScheduleState>((ref) {
  final repo = ref.watch(tutorRepositoryProvider);
  final sharedRepo = ref.watch(sharedLearningRepositoryProvider);
  return TutorScheduleNotifier(repo, sharedRepo, ref);
});
