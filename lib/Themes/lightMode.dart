

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


ThemeData lightMode = ThemeData(
  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black, // Text color
      backgroundColor: Colors.transparent, // Transparent background
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Consistent padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
    ),
  ),

  // Text Theme
  textTheme: GoogleFonts.robotoTextTheme(
    ThemeData.light().textTheme.copyWith(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black, // High contrast for timer digits
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Headings
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800, // Primary text
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600, // Secondary text
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Button text
          ),
        ),
  ),

  // Color Scheme
  colorScheme: ColorScheme.light(
    surface: Colors.brown.shade50, // Background for surfaces
    onSurface: Colors.black, // Text on surfaces
    primary: Colors.grey.shade100, // Primary color (e.g., app bar)
    onPrimary: Colors.black, // Text on primary color
    secondary: Colors.yellow.shade600, // Accent color (e.g., buttons)
    onSecondary: Colors.white, // Text on secondary color
    tertiary: Colors.white, // Tertiary color (e.g., dividers)
    inversePrimary: Colors.grey.shade900, // Inverse primary (e.g., for dialogs)
    background: Colors.brown.shade50, // App background
    onBackground: Colors.black, // Text on background
  ),

  // Additional Customizations
  scaffoldBackgroundColor: Colors.brown.shade50, // Scaffold background
  appBarTheme: AppBarTheme(
    color: Colors.brown.shade50, // App bar background
    elevation: 0, // Remove shadow
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black, // App bar title
    ),
    iconTheme: IconThemeData(
      color: Colors.black, // App bar icons
    ),
  ),
 
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade300, // Divider color
    thickness: 1, // Divider thickness
  ),
  
);