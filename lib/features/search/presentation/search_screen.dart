import 'package:doantotnghiep/features/search/presentation/widgets/class_listing_tab.dart';
import 'package:doantotnghiep/features/search/presentation/widgets/group_matching_tab.dart';
import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/search/domain/models/search_filter.dart';
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

final searchFilterProvider = NotifierProvider.autoDispose<SearchFilterNotifier, SearchFilter?>(SearchFilterNotifier.new);

class SearchFilterNotifier extends Notifier<SearchFilter?> {
  @override
  SearchFilter? build() => null;

  void update(SearchFilter? filter) {
    state = filter;
  }
}

// Provider to filter tutors (mock implementation)
final searchResultsProvider = FutureProvider.autoDispose<List<Tutor>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  return ref.read(tutorRepositoryProvider).searchTutors(query, filter: filter);
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
                _showFilterModal(context, ref);
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

  void _showFilterModal(BuildContext context, WidgetRef ref) {
    // Read current filter or default
    final currentFilter = ref.read(searchFilterProvider) ?? const SearchFilter(
      minPrice: 50000, maxPrice: 1000000, 
      gender: 'Bất kỳ',
      teachingMode: [],
      subjects: []
    );

    // Temp state for modal
    double minPrice = currentFilter.minPrice ?? 50000;
    double maxPrice = currentFilter.maxPrice ?? 1000000;
    List<String> selectedModes = List.from(currentFilter.teachingMode ?? []);
    String selectedGender = currentFilter.gender ?? 'Bất kỳ';
    String? selectedLocation = currentFilter.location;
    List<String> selectedSubjects = List.from(currentFilter.subjects ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height usage if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 24
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bộ lọc tìm kiếm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                             ref.read(searchFilterProvider.notifier).update(null); // Clear
                             context.pop();
                          },
                          child: const Text('Xóa lọc'),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Mức giá: ${(minPrice/1000).toInt()}k - ${(maxPrice/1000).toInt()}k', style: const TextStyle(fontWeight: FontWeight.bold)),
                    RangeSlider(
                      values: RangeValues(minPrice, maxPrice),
                      min: 50000,
                      max: 1000000,
                      divisions: 19,
                      labels: RangeLabels('${(minPrice/1000).toInt()}k', '${(maxPrice/1000).toInt()}k'),
                      onChanged: (values) {
                        setModalState(() {
                          minPrice = values.start;
                          maxPrice = values.end;
                        });
                      }, 
                    ),
                    const SizedBox(height: 16),
                    const Text('Hình thức học', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Online', 'Offline'].map((mode) {
                        final isSelected = selectedModes.contains(mode);
                        return FilterChip(
                          label: Text(mode),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedModes.add(mode);
                              } else {
                                selectedModes.remove(mode);
                              }
                            });
                          },
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
                            selected: selectedGender == gender,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedGender = gender);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                     const SizedBox(height: 16),
                    const Text('Khu vực', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        hintText: 'Chọn Quận/Huyện',
                      ),
                      items: ['Q.1', 'Q.3', 'Q.5', 'Q.10', 'Bình Thạnh', 'Hà Nội', 'Đà Nẵng']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                         setModalState(() => selectedLocation = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Toán', 'Lý', 'Hóa', 'Tiếng Anh', 'Văn', 'IELTS', 'Piano']
                          .map((e) => FilterChip(
                                label: Text(e),
                                selected: selectedSubjects.contains(e),
                                onSelected: (selected) {
                                   setModalState(() {
                                     if (selected) selectedSubjects.add(e);
                                     else selectedSubjects.remove(e);
                                   });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply Filter
                          final newFilter = SearchFilter(
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            teachingMode: selectedModes,
                            gender: selectedGender,
                            location: selectedLocation,
                            subjects: selectedSubjects,
                          );
                          ref.read(searchFilterProvider.notifier).update(newFilter);
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Áp dụng bộ lọc'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
