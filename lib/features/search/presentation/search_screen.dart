import 'package:doantotnghiep/features/search/presentation/widgets/class_listing_tab.dart';
import 'package:doantotnghiep/features/search/presentation/widgets/group_matching_tab.dart';
import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor/presentation/widgets/tutor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

// Provider to filter tutors (mock implementation)
final searchResultsProvider = FutureProvider.autoDispose<List<Tutor>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  return ref.read(tutorRepositoryProvider).searchTutors(query);
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final queryController = TextEditingController(text: ref.read(searchQueryProvider));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: queryController,
            autofocus: false, // Changed to false to avoid keyboard popping on tab switch
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  queryController.clear();
                  ref.read(searchQueryProvider.notifier).update('');
                },
              ),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).update(value);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                _showFilterModal(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tìm Gia sư'),
              Tab(text: 'Học ghép'),
              Tab(text: 'Lớp học'),
            ],
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Tutor Search (Existing)
            searchResults.when(
              data: (tutors) {
                if (tutors.isEmpty) {
                  return const Center(child: Text('Không tìm thấy kết quả nào.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final tutor = tutors[index];
                    return TutorCard(
                      tutor: tutor,
                      onTap: () {
                        context.push('/tutor-detail', extra: tutor);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
            
            // Tab 2: Group Matching
            const GroupMatchingTab(),
            
            // Tab 3: Classes
            const ClassListingTab(),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bộ lọc tìm kiếm',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text('Mức giá (đ/h)', style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: const RangeValues(100000, 500000),
                min: 50000,
                max: 1000000,
                divisions: 20,
                labels: const RangeLabels('100k', '500k'),
                onChanged: null, 
              ),
              const SizedBox(height: 16),
              const Text('Hình thức học', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: ['Online', 'Offline', 'Cả hai'].map((mode) {
                  return FilterChip(
                    label: Text(mode),
                    selected: mode == 'Online',
                    onSelected: (_) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
               const Text('Giới tính Gia sư', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: ['Nam', 'Nữ', 'Bất kỳ'].map((gender) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(gender),
                      selected: gender == 'Bất kỳ',
                      onSelected: (_) {},
                    ),
                  );
                }).toList(),
              ),
               const SizedBox(height: 16),
              const Text('Khu vực', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  hintText: 'Chọn Quận/Huyện',
                ),
                items: ['Q.1', 'Q.3', 'Q.5', 'Q.10', 'Bình Thạnh', 'Hà Nội', 'Đà Nẵng']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              const Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: ['Toán', 'Lý', 'Hóa', 'Tiếng Anh', 'Văn']
                    .map((e) => FilterChip(
                          label: Text(e),
                          selected: e == 'Toán',
                          onSelected: (_) {},
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Áp dụng bộ lọc'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
