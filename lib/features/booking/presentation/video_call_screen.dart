import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoCallScreen extends StatefulWidget {
  final String bookingId;
  const VideoCallScreen({super.key, required this.bookingId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _micEnabled = true;
  bool _cameraEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Phòng học trực tuyến'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main Video Area (Placeholder)
          Center(
            child: _cameraEnabled 
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.person, size: 200, color: Colors.grey),
                    ),
                  )
                : const Center(
                    child: Text('Camera đã tắt', style: TextStyle(color: Colors.white)),
                  ),
          ),
          
          // Self View (Small Picture-in-Picture)
          if (_cameraEnabled)
            Positioned(
              right: 16,
              bottom: 120,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(child: Text('Bạn', style: TextStyle(color: Colors.white))),
              ),
            ),
            
          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlBtn(
                  icon: _micEnabled ? Icons.mic : Icons.mic_off,
                  color: _micEnabled ? Colors.white : Colors.red,
                  onPressed: () => setState(() => _micEnabled = !_micEnabled),
                ),
                _buildControlBtn(
                  icon: _cameraEnabled ? Icons.videocam : Icons.videocam_off,
                  color: _cameraEnabled ? Colors.white : Colors.red,
                   onPressed: () => setState(() => _cameraEnabled = !_cameraEnabled),
                ),
                 _buildControlBtn(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.white,
                   onPressed: () {
                     // Open chat
                   },
                ),
                // End Call
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                     context.pop(); 
                  },
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
