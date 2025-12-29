/// App Theme Configuration
/// 
/// Defines the visual design system for the entire app using Material 3.
/// Provides consistent colors, typography, and component styles.
/// 
/// **Design Principles:**
/// - Modern Material 3 design language
/// - Clean, professional appearance
/// - Accessible color contrast
/// - Consistent spacing and typography
/// 
/// **Color Palette:**
/// - Primary: Indigo 600 (trust, professionalism)
/// - Secondary: Emerald 500 (success, growth)
/// - Accent: Amber 500 (attention, energy)
/// - Background: Slate 50 (soft, neutral)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Primary brand color - Indigo 600
  /// 
  /// **Usage:**
  /// - Primary buttons
  /// - Active states
  /// - Brand elements
  /// - Links and interactive elements
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  
  /// Secondary color - Emerald 500
  /// 
  /// **Usage:**
  /// - Success states
  /// - Positive actions
  /// - Confirmation indicators
  static const Color secondaryColor = Color(0xFF10B981); // Emerald 500
  
  /// Accent color - Amber 500
  /// 
  /// **Usage:**
  /// - Warning states
  /// - Important highlights
  /// - Attention-grabbing elements
  static const Color accentColor = Color(0xFFF59E0B); // Amber 500
  
  /// Scaffold background color - Slate 50
  /// 
  /// **Usage:**
  /// - Main app background
  /// - Screen backgrounds
  static const Color scaffoldBackgroundColor = Color(0xFFF8FAFC); // Slate 50
  
  /// Surface color - White
  /// 
  /// **Usage:**
  /// - Card backgrounds
  /// - Input field backgrounds
  /// - Elevated surfaces
  static const Color surfaceColor = Colors.white;

  /// Light theme configuration
  /// 
  /// **Returns:**
  /// - `ThemeData`: Complete theme configuration for light mode
  /// 
  /// **Features:**
  /// - Material 3 design system
  /// - Google Fonts (Outfit) for modern typography
  /// - Custom color scheme
  /// - Consistent component styling
  /// 
  /// **Components Styled:**
  /// - AppBar (no elevation, modern look)
  /// - ElevatedButton (rounded, with shadow)
  /// - InputDecoration (filled, rounded borders)
  /// - Cards (elevated with shadow)
  static ThemeData get lightTheme {
    return ThemeData(
      // Enable Material 3 design system
      // Provides modern components, animations, and design tokens
      useMaterial3: true,
      
      // Color scheme generated from seed color with Material 3 design
      // Material 3 automatically generates harmonious color palette
      // Using indigo as primary for trust and professionalism
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor, // Amber for accents
        background: scaffoldBackgroundColor,
        surface: surfaceColor,
        brightness: Brightness.light,
        // Material 3 enhanced colors
        error: const Color(0xFFDC2626), // Red 600 for errors
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1F2937), // Gray 800 for text
        onBackground: const Color(0xFF1F2937),
      ),
      
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      
      // Modern Typography using Google Fonts
      // Outfit font: Clean, modern, professional
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        // Customize specific text styles if needed
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(fontSize: 16),
        bodyMedium: GoogleFonts.outfit(fontSize: 14),
        bodySmall: GoogleFonts.outfit(fontSize: 12),
      ),
      
      // AppBar Theme - Modern, flat design
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0, // No shadow for modern flat design
        scrolledUnderElevation: 1, // Subtle shadow when scrolling
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent, // Material 3: Remove tint
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.black87, 
          fontSize: 22, 
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
          size: 24,
        ),
      ),
      
      // Card Theme - Modern elevated cards with glassmorphism effect
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, // No elevation for modern flat design
        shadowColor: Colors.black.withOpacity(0.08), // Subtle shadow for depth
        surfaceTintColor: Colors.transparent, // Material 3: Remove tint
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // More rounded for modern look
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme - Modern, rounded buttons with gradient effect
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Flat design
          shadowColor: primaryColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32), // More padding for modern look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // More rounded
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600, // Slightly lighter for modern look
            fontSize: 16,
            letterSpacing: 0.5, // Better readability
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Input Decoration Theme - Modern, filled inputs with better visual feedback
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // More padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // More rounded
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 2.5), // Thicker for emphasis
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2.5),
        ),
        labelStyle: GoogleFonts.outfit(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.outfit(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        // Add floating label animation
        floatingLabelStyle: GoogleFonts.outfit(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip Theme - Modern chips for filters and tags
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: GoogleFonts.outfit(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
        space: 1,
      ),
    );
  }
}
