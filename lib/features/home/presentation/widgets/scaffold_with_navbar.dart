/// Custom Scaffold with Modern Bottom Navigation Bar
/// 
/// **Purpose:**
/// - Provides main app navigation with floating bottom bar
/// - Implements glassmorphism design (blurred glass effect)
/// - Auto-hides navigation bar when scrolling down
/// - Modern iOS-like navigation experience
/// 
/// **Features:**
/// - 5 main navigation items (Home, Search, Schedule, Messages, Profile)
/// - Smooth animations for show/hide
/// - Gradient background with decorative elements
/// - Backdrop blur effect for modern look
/// 
/// **Usage:**
/// Used as shell route in GoRouter to wrap main app screens.
/// Automatically handles navigation state and visual feedback.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

/// Scaffold with custom floating navigation bar
/// 
/// **Parameters:**
/// - `navigationShell`: The child widget (usually a NavigationShell from GoRouter)
/// 
/// **Design:**
/// - Glassmorphism bottom navigation (blurred glass effect)
/// - Auto-hide on scroll down, show on scroll up
/// - Gradient background with decorative circles
/// - Smooth animations for all interactions
class ScaffoldWithNavBar extends StatefulWidget {
  /// Navigation shell widget from GoRouter
  /// Contains the actual screen content
  final Widget navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  /// Controls visibility of bottom navigation bar
  /// - `true`: Navigation bar is visible
  /// - `false`: Navigation bar is hidden (when scrolling down)
  /// 
  /// **Logic:**
  /// - Set to false when user scrolls down (hides bar)
  /// - Set to true when user scrolls up (shows bar)
  /// - Provides better content viewing experience
  bool _isMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    // Calculate which navigation item should be highlighted
    // Based on current route path
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
          
          // Main Content with Scroll Detection
          // Purpose: Auto-hide/show navigation bar based on scroll direction
          // Logic: Hide when scrolling down, show when scrolling up
          // This provides better UX by giving more screen space when reading content
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              // Scroll down: Hide navigation bar
              if (notification.direction == ScrollDirection.reverse) {
                if (_isMenuVisible) {
                  setState(() => _isMenuVisible = false);
                }
              } 
              // Scroll up: Show navigation bar
              else if (notification.direction == ScrollDirection.forward) {
                if (!_isMenuVisible) {
                  setState(() => _isMenuVisible = true);
                }
              }
              return true; // Consume notification to prevent further propagation
            },
            child: widget.navigationShell,
          ),

          // Custom Floating Navigation Bar (Glassmorphism Design)
          // Purpose: Modern iOS-like floating navigation bar with blur effect
          // Features:
          // - Auto-hide/show animation based on scroll direction
          // - Backdrop blur for glassmorphism effect
          // - Smooth animations with easing curves
          // - Elevated shadow for depth perception
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic, // Smooth easing for natural feel
            // Position: Visible at bottom when _isMenuVisible is true, hidden below screen when false
            bottom: _isMenuVisible ? 24 : -100,
            left: 24,
            right: 24,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24), // Rounded corners for modern look
                child: BackdropFilter(
                  // Glassmorphism effect: Blurs content behind the bar
                  // Creates modern "frosted glass" appearance
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 64, // Optimal height for touch targets (44px minimum + padding)
                    decoration: BoxDecoration(
                      // Semi-transparent white for glass effect
                      // Higher opacity (0.85) for better readability
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      // Shadow for depth and elevation perception
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8), // Slight upward shadow
                          spreadRadius: 0,
                        ),
                      ],
                      // Subtle border for definition
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5), 
                        width: 1.5
                      ),
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

  /// Build individual navigation item
  /// 
  /// **Parameters:**
  /// - `icon`: Icon to show when item is not selected (outlined style)
  /// - `activeIcon`: Icon to show when item is selected (filled style)
  /// - `index`: Navigation item index (0-4)
  /// - `currentIndex`: Currently selected navigation index
  /// 
  /// **Returns:**
  /// - `Widget`: Navigation item widget with tap handling
  /// 
  /// **Visual States:**
  /// - Selected: Filled icon, blue color, background highlight
  /// - Unselected: Outlined icon, grey color, transparent background
  /// 
  /// **Animations:**
  /// - Smooth transition between states (250ms)
  /// - Popup effect when selected (easeOutBack curve)
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;
    
    return Expanded(
      // Expand tap area for better UX (easier to tap)
      child: GestureDetector(
        onTap: () {
          // Navigate to corresponding route
          _onItemTapped(context, index);
          // TODO: Add haptic feedback for better UX
        },
        behavior: HitTestBehavior.translucent, // Allow taps on transparent areas
        child: Container(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack, // Bouncy popup effect when selected
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Highlight selected item with subtle background
              color: isSelected 
                  ? Colors.blueAccent.withOpacity(0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              // Show filled icon when selected, outlined when not
              isSelected ? activeIcon : icon,
              size: 26, // Optimal size for touch targets
              color: isSelected 
                  ? const Color(0xFF2563EB) // Blue for selected
                  : Colors.grey.shade500, // Grey for unselected
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate which navigation item should be highlighted
  /// 
  /// **Purpose:**
  /// - Determines current route and maps it to navigation index
  /// - Used to highlight the correct navigation item
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext to access GoRouter state
  /// 
  /// **Returns:**
  /// - `int`: Navigation index (0-4) corresponding to current route
  /// 
  /// **Route Mapping:**
  /// - `/` → 0 (Home)
  /// - `/search` → 1 (Search)
  /// - `/schedule` → 2 (Schedule)
  /// - `/messages` → 3 (Messages)
  /// - `/profile` or `/wallet` → 4 (Profile)
  /// 
  /// **Note:** Wallet is mapped to Profile index since it's a sub-page
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    
    if (location.startsWith('/')) {
      if (location == '/') return 0; // Home
      if (location.startsWith('/search')) return 1; // Search
      if (location.startsWith('/schedule')) return 2; // Schedule
      if (location.startsWith('/messages')) return 3; // Messages
      if (location.startsWith('/profile')) return 4; // Profile
      if (location.startsWith('/wallet')) return 4; // Wallet (sub-page of Profile)
    }
    
    // Default to Home if route doesn't match
    return 0;
  }

  /// Handle navigation item tap
  /// 
  /// **Purpose:**
  /// - Navigates to corresponding route when user taps navigation item
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext for navigation
  /// - `index`: Index of tapped navigation item (0-4)
  /// 
  /// **Navigation Mapping:**
  /// - 0 → `/` (Home)
  /// - 1 → `/search` (Search)
  /// - 2 → `/schedule` (Schedule)
  /// - 3 → `/messages` (Messages)
  /// - 4 → `/profile` (Profile)
  /// 
  /// **Note:** Uses `context.go()` for navigation (replaces current route)
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/'); // Navigate to Home
        break;
      case 1:
        context.go('/search'); // Navigate to Search
        break;
      case 2:
        context.go('/schedule'); // Navigate to Schedule
        break;
      case 3:
        context.go('/messages'); // Navigate to Messages
        break;
      case 4:
        context.go('/profile'); // Navigate to Profile
        break;
    }
  }
}
