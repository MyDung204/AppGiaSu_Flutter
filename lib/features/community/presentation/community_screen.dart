
import 'package:doantotnghiep/features/community/data/community_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _selectedTopic = 'Tất cả';
  final List<String> _topics = ['Tất cả', 'Toán', 'Văn', 'Anh', 'Vật lý', 'Hóa'];
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(communityProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm câu hỏi...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              )
            : const Text('Góc Hỏi Đáp', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchText = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return _buildChip(topic, isSelected: topic == _selectedTopic);
              },
            ),
          ),
          Expanded(
            child: questionsAsync.when(
              data: (questions) {
                // Lọc theo topic (subject)
                // Sử dụng toLowerCase() để so sánh không phân biệt hoa thường
                var filtered = _selectedTopic == 'Tất cả'
                    ? questions
                    : questions.where((q) => 
                        q.subject.toLowerCase().contains(_selectedTopic.toLowerCase())
                      ).toList();

                // Lọc theo search text nếu có
                if (_searchText.isNotEmpty) {
                  filtered = filtered.where((q) =>
                      q.content.toLowerCase().contains(_searchText) ||
                      q.userName.toLowerCase().contains(_searchText) ||
                      q.subject.toLowerCase().contains(_searchText)
                  ).toList();
                }

                // Hiển thị empty state nếu không có kết quả
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy câu hỏi nào${_selectedTopic != 'Tất cả' ? ' cho môn $_selectedTopic' : ''}.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final q = filtered[index];
                    return InkWell(
                      onTap: () => context.push('/question-detail/${q.id}'),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(q.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(
                                        DateFormat('dd/MM HH:mm').format(q.createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(q.subject, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(q.content, style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildAction(Icons.thumb_up_outlined, '${q.likeCount} Thích'),
                                  _buildAction(Icons.comment_outlined, '${q.answerCount} Trả lời'),
                                  _buildAction(Icons.share_outlined, 'Chia sẻ'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-question'),
        label: const Text('Đặt câu hỏi'),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedTopic = label),
        child: Chip(
          label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
          backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[200],
          side: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
