/// Tutor Detail Screen
/// 
/// **Purpose:**
/// - Displays comprehensive information about a tutor
/// - Shows tutor profile, bio, subjects, ratings, and reviews
/// - Provides actions: Chat and Book session
/// 
/// **Features:**
/// - Large avatar with name and location
/// - Statistics (Rating, Reviews, Hourly Rate)
/// - Bio section
/// - Subjects taught (as chips)
/// - Action buttons (Chat, Book)
/// 
/// **Navigation:**
/// - "Nhắn tin" → Opens chat screen with tutor
/// - "Đặt lịch ngay" → Opens booking screen
/// - Reviews count → Opens reviews screen
/// 
/// **Design:**
/// - Clean, scrollable layout
/// - Prominent action buttons at bottom
/// - Modern card-based design

import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen displaying detailed information about a tutor
/// 
/// **Parameters:**
/// - `tutor`: Tutor object to display (passed via route extra)
/// 
/// **Layout:**
/// - AppBar with tutor name
/// - Scrollable body with profile info
/// - Fixed bottom action buttons
class TutorDetailScreen extends StatelessWidget {
  /// Tutor object containing all tutor information
  final Tutor tutor;

  const TutorDetailScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: Text(tutor.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Section
            // Purpose: Display tutor's main information at top of screen
            // Contains: Avatar, Name, Location, Statistics (Rating, Reviews, Price)
            Center(
              child: Column(
                children: [
                  // Large avatar (120x120) for prominent display
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Tutor name (bold, large)
                  Text(
                    tutor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Location (secondary text)
                  Text(
                    tutor.location,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Statistics Row: Rating | Reviews | Price
                  // Reviews is tappable to view all reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(context, 'Rating', '${tutor.rating} ⭐'),
                      _buildDivider(),
                      // Tappable reviews count - navigates to reviews screen
                      InkWell(
                        onTap: () {
                           context.push('/tutor-reviews', extra: tutor);
                        },
                        child: _buildStatItem(context, 'Reviews', '${tutor.reviewCount} (Xem thêm)'),
                      ),
                      _buildDivider(),
                      _buildStatItem(context, 'Giá/h', currencyFormat.format(tutor.hourlyRate)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Bio Section
            // Purpose: Display tutor's self-introduction/bio
            Text(
              'Giới thiệu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              tutor.bio,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Subjects Section
            // Purpose: Display all subjects tutor teaches
            // Design: Chips with primary color background
            Text(
              'Môn dạy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // Wrap subjects in chips for better visual organization
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tutor.subjects
                  .map((subject) => Chip(
                        label: Text(subject),
                        // Light primary color background for visual consistency
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      // Bottom Action Buttons
      // Purpose: Fixed action buttons for primary actions
      // Design: Two buttons side-by-side (Chat and Book)
      // Note: SafeArea ensures buttons are above system UI (notch, etc.)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Chat Button (Secondary Action)
              // Navigates to chat screen to message tutor
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/chat', extra: tutor);
                  },
                  child: const Text('Nhắn tin'),
                ),
              ),
              const SizedBox(width: 16),
              // Book Button (Primary Action)
              // Navigates to booking screen to schedule a session
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/booking', extra: tutor);
                  },
                  child: const Text('Đặt lịch ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a statistics item (value + label)
  /// 
  /// **Parameters:**
  /// - `context`: BuildContext for theme access
  /// - `label`: Label text (e.g., "Rating", "Reviews", "Giá/h")
  /// - `value`: Value text (e.g., "4.5 ⭐", "12 (Xem thêm)", "200,000đ")
  /// 
  /// **Returns:**
  /// - `Widget`: Column with value on top, label below
  /// 
  /// **Usage:**
  /// Used in statistics row to display rating, reviews, and price
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Value (bold, larger)
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // Label (smaller, grey)
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  /// Build vertical divider between statistics items
  /// 
  /// **Returns:**
  /// - `Widget`: Thin vertical line (1px width, 30px height)
  /// 
  /// **Purpose:**
  /// - Visual separator between statistics in the row
  /// - Improves readability and visual organization
  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
