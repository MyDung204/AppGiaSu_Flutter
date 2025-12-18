import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
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
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. Header Động (SliverAppBar) ---
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: true,
            expandedHeight: 180, // Increased height to prevent overlap
            toolbarHeight: 80,
            leading: const SizedBox(), // Hide default back button
            leadingWidth: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user?.avatarUrl != null 
                            ? NetworkImage(user!.avatarUrl!) 
                            : null,
                        child: user?.avatarUrl == null 
                            ? const Icon(Icons.person, color: Colors.grey, size: 30) 
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Xin chào,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'Người dùng',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white), 
                          onPressed: () => context.push('/notifications')),
                    )
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                height: 70, // Explicit height container for search bar area
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                         Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                         const SizedBox(width: 12),
                         Text('Tìm gia sư, môn học...', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Nâng tầm kiến thức\ncùng gia sư chất lượng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go('/search'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Khám phá', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                       _buildCategoryItem(context, 'Toán', Icons.calculate, Colors.blue),
                       _buildCategoryItem(context, 'Anh', Icons.language, Colors.orange),
                       _buildCategoryItem(context, 'Lý', Icons.flash_on, Colors.purple),
                       _buildCategoryItem(context, 'Hóa', Icons.science, Colors.green),
                       _buildCategoryItem(context, 'Văn', Icons.book, Colors.red),
                       _buildCategoryItem(context, 'Piano', Icons.music_note, Colors.pink),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // --- 4. Banner Cộng đồng (Góc Hỏi Đáp) ---
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => context.push('/community'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFfd79a8), Color(0xFFe84393)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.forum_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Góc Hỏi Đáp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                           SizedBox(height: 4),
                           Text('Cộng đồng hỗ trợ giải bài tập 24/7', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // --- 5. Tiêu đề danh sách ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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
                  InkWell(
                    onTap: () => context.go('/search'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Xem tất cả', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ),
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
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          context.go(Uri(path: '/search', queryParameters: {'subject': label}).toString());
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
