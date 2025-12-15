import 'package:doantotnghiep/features/chat/data/chat_provider.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor_dashboard/domain/models/tutor_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // Auto-send message about the request
    final text = "Chào bạn, mình thấy bài đăng tìm gia sư môn ${req.subject} (${req.gradeLevel}) của bạn.\nMình rất quan tâm và muốn nhận lớp này.";
    ref.read(chatProvider.notifier).sendMessage(widget.tutor.id, text);
    _scrollToBottom();
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
    // Watch messages from provider for this specific tutor
    final allMessages = ref.watch(chatProvider);
    final messages = allMessages[widget.tutor.id] ?? [
        // Default greeting if empty (also handled in provider but safe here)
        ChatMessage(
          text: 'Chào bạn, mình có thể giúp gì cho bạn?',
          isUser: false,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        )
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
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
              backgroundImage: NetworkImage(widget.tutor.avatarUrl),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tutor.name, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                if (_isTyping)
                  const Text('Đang nhập...', style: TextStyle(color: Colors.blue, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  // If system message, center it
                  if (msg.isSystem) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
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
              ),
            ),
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    // Send via Provider
    ref.read(chatProvider.notifier).sendMessage(
      widget.tutor.id,
      _controller.text,
    );
    _controller.clear();
    _scrollToBottom();
    
    // Simulate Typing
    setState(() => _isTyping = true);

    // Mock reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
        ref.read(chatProvider.notifier).sendMessage(
          widget.tutor.id,
          'Cảm ơn bạn! Mình sẽ xem xét và phản hồi sớm.',
          isUser: false,
        );
        _scrollToBottom();
      }
    });
  }
}
