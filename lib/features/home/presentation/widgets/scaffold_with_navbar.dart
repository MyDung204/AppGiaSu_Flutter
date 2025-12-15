import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  bool _isMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Global Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFf3e7e9), Color(0xFFe3eeff)], // Updated: Lighter, cleaner pastel
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative Elements (Subtler)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Main Content
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isMenuVisible) setState(() => _isMenuVisible = false);
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isMenuVisible) setState(() => _isMenuVisible = true);
              }
              return true;
            },
            child: widget.navigationShell,
          ),

          // Custom Floating Dock
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic, // Bouncy/Smooth
            bottom: _isMenuVisible ? 24 : -100,
            left: 24,
            right: 24,
            child: Center( // Center to allow width constraints if needed, but here we fill left/right 24
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24), // iOS-like rounding
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Stronger blur
                  child: Container(
                    height: 64, // Sleek height
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85), // Higher opacity for "Solid Glass"
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, index: 0, currentIndex: selectedIndex),
                        _buildNavItem(context, icon: Icons.search_outlined, activeIcon: Icons.search_rounded, index: 1, currentIndex: selectedIndex),
                        _buildNavItem(context, icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_month_rounded, index: 2, currentIndex: selectedIndex),
                        _buildNavItem(context, icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, index: 3, currentIndex: selectedIndex),
                        _buildNavItem(context, icon: Icons.person_outline, activeIcon: Icons.person_rounded, index: 4, currentIndex: selectedIndex),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required IconData activeIcon, required int index, required int currentIndex}) {
    final isSelected = index == currentIndex;
    
    return Expanded( // Expand tap area
      child: GestureDetector(
        onTap: () {
          // Add a tiny vibration or sound here if possible? kept simple for now
          _onItemTapped(context, index);
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          // Hitbox is the whole expanded area, but icon is centered
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack, // Popup effect
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
               borderRadius: BorderRadius.circular(16),
             ),
             child: Icon(
              isSelected ? activeIcon : icon,
              size: 26,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade500, // Tech Blue vs Muted Grey
            ),
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/')) {
      if (location == '/') return 0;
      if (location.startsWith('/search')) return 1;
      if (location.startsWith('/schedule')) return 2;
      if (location.startsWith('/messages')) return 3;
      if (location.startsWith('/profile')) return 4;
      if (location.startsWith('/wallet')) return 4;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/schedule');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
