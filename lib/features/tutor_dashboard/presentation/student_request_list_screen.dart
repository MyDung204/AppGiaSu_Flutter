import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentRequestListScreen extends ConsumerWidget {
  const StudentRequestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(tutorRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tìm Học Viên', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
       // Removed filter button for simplicity or keep it
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text("Chưa có yêu cầu nào."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${req.subject} - ${req.gradeLevel}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Text(
                          '${(req.minBudget/1000).toInt()}k - ${(req.maxBudget/1000).toInt()}k', 
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      req.description.isEmpty ? 'Không có mô tả' : req.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(req.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const Spacer(),
                        const Text('Vừa xong', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Create Dummy Tutor representing the Student
                          final studentAsTarget = Tutor(
                            id: req.studentId,
                            name: req.studentName,
                            bio: 'Học viên',
                            hourlyRate: 0,
                            subjects: [],
                            rating: 0,
                            avatarUrl: 'https://i.pravatar.cc/150?u=${req.studentId}',
                            reviewCount: 0,
                            location: req.location, 
                            gender: 'Khác',
                            teachingMode: [],
                            address: '',
                            weeklySchedule: {},
                          );
                          
                          // Pass both Target and Request Context
                          context.push('/chat', extra: {
                            'tutor': studentAsTarget,
                            'request': req,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Trao đổi ngay'),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
