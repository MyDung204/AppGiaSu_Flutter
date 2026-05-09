import 'package:doantotnghiep/features/tutor_dashboard/data/tutor_request_provider.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class _EduTheme {
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}

class StudentRequestListScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const StudentRequestListScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<StudentRequestListScreen> createState() =>
      _StudentRequestListScreenState();
}

class _StudentRequestListScreenState
    extends ConsumerState<StudentRequestListScreen> {
  String? _selectedSubject;
  String? _selectedGrade;

  final List<String> _subjects = [
    'Toán',
    'Lý',
    'Hóa',
    'Văn',
    'Anh',
    'Sinh',
    'Sử',
    'Địa',
    'Tin',
    'Piano',
    'Khác',
  ];

  final List<String> _grades = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    'ĐH',
  ];

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(tutorRequestsProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: _EduTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterSection(),
            Expanded(
              child: requestsAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(error.toString()),
                data: (requests) {
                  final filtered = requests.where((req) {
                    if (req.requestType != '1-1') return false;
                    if (req.isTutorCreated) return false;
                    if (_selectedSubject != null &&
                        req.subject != _selectedSubject) {
                      return false;
                    }
                    if (_selectedGrade != null &&
                        !req.gradeLevel.contains(_selectedGrade!)) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(tutorRequestsProvider.future),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildRequestCard(
                          context,
                          filtered[index],
                          currencyFormat,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: _EduTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Học viên 1-1',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _EduTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Danh sách học viên đang tìm gia sư',
                  style: TextStyle(fontSize: 13, color: _EduTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: _EduTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Môn học',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _subjects
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Lớp',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _grades
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGrade = value),
            ),
          ),
          IconButton(
            tooltip: 'Xóa lọc',
            onPressed: () {
              setState(() {
                _selectedSubject = null;
                _selectedGrade = null;
              });
            },
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    TutorRequest request,
    NumberFormat currencyFormat,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _EduTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _EduTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_search, color: _EduTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _EduTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${request.subject} - ${request.gradeLevel}',
                        style: const TextStyle(color: _EduTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request.description.isNotEmpty)
              Text(
                request.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _EduTheme.textPrimary),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.schedule, text: request.schedule),
                _InfoChip(icon: Icons.location_on_outlined, text: request.location),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  text:
                      '${currencyFormat.format(request.minBudget)} - ${currencyFormat.format(request.maxBudget)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(tutorRequestsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 64,
                      color: _EduTheme.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có học viên 1-1 phù hợp',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _EduTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Các yêu cầu tìm gia sư từ học viên sẽ hiển thị tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _EduTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Không tải được danh sách học viên: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _EduTheme.textSecondary),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _EduTheme.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _EduTheme.textSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: _EduTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
