import 'package:doantotnghiep/features/tutor/data/tutor_repository.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor/presentation/widgets/tutor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final featuredTutorsProvider = FutureProvider<List<Tutor>>((ref) {
  return ref.watch(tutorRepositoryProvider).getFeaturedTutors();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorsAsyncValue = ref.watch(featuredTutorsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. Header Động (SliverAppBar) ---
          // Chứa Avatar, lời chào và thanh tìm kiếm
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            pinned: true, // Giữ lại khi cuộn
            floating: true, // Hiện lại ngay khi cuộn lên
            expandedHeight: 130, // Space for greeting + search
            toolbarHeight: 80, // Height when collapsed (just search)
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Mock Avatar
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Xin chào,', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const Text('Người dùng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                      child: IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () => context.push('/notifications')),
                    )
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                         const Icon(Icons.search_rounded, color: Colors.blueAccent),
                         const SizedBox(width: 12),
                         Text('Tìm gia sư, môn học...', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- 2. Banner Chính (Khuyến mãi/Intro) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  // Lớp phủ Gradient để chữ dễ đọc hơn
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Nâng tầm kiến thức\ncùng gia sư chất lượng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => context.go('/search'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tìm gia sư ngay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- 3. Danh mục môn học (Cuộn ngang) ---
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                   _buildCategoryItem(context, 'Toán', Icons.calculate, Colors.blue),
                   _buildCategoryItem(context, 'Tiếng Anh', Icons.language, Colors.orange),
                   _buildCategoryItem(context, 'Vật Lý', Icons.flash_on, Colors.purple),
                   _buildCategoryItem(context, 'Hóa Học', Icons.science, Colors.green),
                   _buildCategoryItem(context, 'Văn Học', Icons.book, Colors.red),
                   _buildCategoryItem(context, 'Âm Nhạc', Icons.music_note, Colors.pink),
                ],
              ),
            ),
          ),
          
          // --- 4. Banner Cộng đồng (Góc Hỏi Đáp) ---
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => context.push('/community'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFfd79a8), Color(0xFFe84393)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                     BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Góc Hỏi Đáp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                           Text('Cộng đồng hỗ trợ giải bài tập 24/7', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
          ),
          
          // --- 5. Tiêu đề danh sách ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gia sư nổi bật',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/search'),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),
          ),

          // --- 6. Danh sách Gia sư (Grid/List) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: tutorsAsyncValue.when(
              data: (tutors) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tutor = tutors[index];
                    return TutorCard(
                      tutor: tutor,
                      onTap: () {
                        context.push('/tutor-detail', extra: tutor);
                      },
                    );
                  },
                  childCount: tutors.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                )),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Lỗi: $err')),
              ),
            ),
          ),
          // Add some bottom padding for the FAB usually, but now we have bottom nav
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
