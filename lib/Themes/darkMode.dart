import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


ThemeData darkMode = ThemeData(
  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white, // Text color
      backgroundColor: Colors.transparent, // Transparent background
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Consistent padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
    ),
  ),

  // Text Theme
  textTheme: GoogleFonts.robotoTextTheme(
    ThemeData.dark().textTheme.copyWith(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white, // High contrast for timer digits
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Headings
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white, // Primary text
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white, // Secondary text
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Button text
          ),
        ),
  ),

  // Color Scheme
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 0, 0, 0), // Background for surfaces
    onSurface: Colors.white, // Text on surfaces
    primary: Color.fromARGB(255, 41, 41, 41), // Primary color (e.g., app bar)
    onPrimary: Colors.white, // Text on primary color
    secondary: Colors.yellow.shade400, // Accent color (e.g., buttons)
    onSecondary: Colors.white, // Text on secondary color
    tertiary: Colors.grey.shade700, // Tertiary color (e.g., dividers)
    inversePrimary: Colors.white, // Inverse primary (e.g., for dialogs)
    background: const Color.fromARGB(255, 0, 0, 0), // App background
    onBackground: Colors.white, // Text on background
  ),

  // Additional Customizations
  scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0), // Scaffold background
  appBarTheme: AppBarTheme(
    color: const Color.fromARGB(255, 0, 0, 0), // App bar background
    elevation: 0, // Remove shadow
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white, // App bar title
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // App bar icons
    ),
  ),

  dividerTheme: DividerThemeData(
    color: Colors.grey.shade700, // Divider color
    thickness: 1, // Divider thickness
  ),
);