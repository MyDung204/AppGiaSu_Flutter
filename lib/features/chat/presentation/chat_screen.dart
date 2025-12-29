import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:doantotnghiep/features/chat/domain/models/course_offer.dart';
import 'package:doantotnghiep/features/chat/domain/models/chat_message.dart';
import 'package:doantotnghiep/features/chat/presentation/widgets/offer_bubble.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Tutor tutor;
  final TutorRequest? initialRequest;

  const ChatScreen({super.key, required this.tutor, this.initialRequest});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendContextMessage(widget.initialRequest!);
      });
    }
  }

  void _sendContextMessage(TutorRequest req) {
    // Check if we already have messages to avoid duplicate context?
    // For now, we trust the user intent or just send it.
    // Ideally, check: if (ref.read(chatDetailProvider(widget.tutor.id)).value?.isEmpty ?? true)
    
    final text = "Chào bạn, mình thấy bài đăng tìm gia sư môn ${req.subject} (${req.gradeLevel}) của bạn.\nMình rất quan tâm và muốn nhận lớp này.";
    ref.read(chatControllerProvider(widget.tutor.id)).sendMessage(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.tutor.id));
    final pendingMessages = ref.watch(pendingMessagesProvider(widget.tutor.id));

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        // ... (omitted)
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 18,
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tutor.name, style: const TextStyle(color: Colors.black87, fontSize: 16)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng gọi điện đang được phát triển')),
              );
            },
            tooltip: 'Gọi điện',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng gọi video đang được phát triển')),
              );
            },
            tooltip: 'Gọi video',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child:Builder(
                builder: (context) {
                  // Handle Loading Initial State
                  if (messagesAsync.isLoading && !messagesAsync.hasValue) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Handle Error State
                  if (messagesAsync.hasError && !messagesAsync.hasValue) {
                    return Center(child: Text('Lỗi: ${messagesAsync.error}'));
                  }

                  final serverMessages = messagesAsync.asData?.value ?? [];
                  final allMessages = [...serverMessages, ...pendingMessages];

                  if (allMessages.isEmpty) {
                     return const Center(child: Text("Bắt đầu cuộc trò chuyện...", style: TextStyle(color: Colors.white70)));
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final msg = allMessages[index];
                      
                      // System Message
                      if (msg.isSystem) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        );
                      }

                      // Offer Message
                      if (msg.offer != null) {
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: OfferBubble(offer: msg.offer!, isUser: msg.isUser),
                        );
                      }

                      // Normal Text Message
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: msg.isUser ? Colors.blueAccent : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(color: Colors.black54, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.orange, size: 30),
                    onPressed: _showActionSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
              title: const Text('Tạo đề xuất khóa học'),
              subtitle: const Text('Gửi báo giá và lịch học'),
              onTap: () {
                Navigator.pop(context);
                _showCreateOfferModal();
              },
            ),
            // Send Image - TODO: Implement image picker and upload
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('Gửi ảnh'),
              subtitle: const Text('Tính năng đang được phát triển'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng gửi ảnh đang được phát triển')),
                );
              },
            ),
            // Send Location - TODO: Implement location picker and send
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Gửi vị trí'),
              subtitle: const Text('Tính năng đang được phát triển'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng gửi vị trí đang được phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOfferModal() {
    final subjectCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController();
    final priceCtrl = TextEditingController(); // Per session
    final sessionsCtrl = TextEditingController(text: '2');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo đề xuất khóa học', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Môn học', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: scheduleCtrl, decoration: const InputDecoration(labelText: 'Lịch học (VD: T3, T5 19h)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Học phí/buổi (VNĐ)', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: sessionsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số buổi/tuần', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (subjectCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                  
                  final offer = CourseOffer(
                    id: const Uuid().v4(),
                    tutorId: widget.tutor.id,
                    tutorName: widget.tutor.name,
                    subject: subjectCtrl.text,
                    schedule: scheduleCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    sessionsPerWeek: int.tryParse(sessionsCtrl.text) ?? 2,
                  );

                  ref.read(chatControllerProvider(widget.tutor.id)).sendMessage(
                    'Đã gửi đề xuất: ${offer.subject}',
                    offer: offer,
                  );
                  Navigator.pop(context);
                  _scrollToBottom();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Gửi đề xuất'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    // Send via Provider
    ref.read(chatControllerProvider(widget.tutor.id)).sendMessage(_controller.text);
    _controller.clear();
    _scrollToBottom();
  }
}
