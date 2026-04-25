import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';

class LocationBubble extends StatelessWidget {
  final String locationString;
  final bool isUser;
  final DateTime time;
  final bool isRead;

  const LocationBubble({
    super.key,
    required this.locationString,
    required this.isUser,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final parts = locationString.split(',');
    double? lat, lng;
    if (parts.length == 2) {
      lat = double.tryParse(parts[0]);
      lng = double.tryParse(parts[1]);
    }

    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final point = LatLng(lat, lng);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 260,
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview
            GestureDetector(
              onTap: () => context.push('/map', extra: point),
              child: Stack(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: point,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Overlay for "Open Map" feeling
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, size: 14, color: Colors.blueAccent),
                          const SizedBox(width: 4),
                          const Text('Xem bản đồ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 16,
                        color: isUser ? Colors.white.withOpacity(0.9) : Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vị trí hiện tại',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toạ độ: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: isUser ? Colors.white60 : Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.check,
                          size: 14,
                          color: isRead ? Colors.blue[200] : Colors.white60,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
