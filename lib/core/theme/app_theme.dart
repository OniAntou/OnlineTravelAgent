import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF176FF2);
  static const Color backgroundGray = Color(0xFFF3F8FE);
  static const Color darkGray = Color(0xFF4D5652);
  static const Color textBlack = Color(0xFF212121);
  static const Color textGray = Colors.grey;

  // Common border radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Common font sizes
  static const double fontSizeCaption = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 13.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeadline = 22.0;

  // Common padding/spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;

  // Common BoxShadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(color: Color(0x4D176FF2), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // API timeout
  static const Duration apiTimeout = Duration(seconds: 10);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.bold,
        color: textBlack,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.bold,
        color: textBlack,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(color: textBlack),
      bodyMedium: GoogleFonts.plusJakartaSans(color: textBlack),
      labelSmall: GoogleFonts.plusJakartaSans(color: textGray, fontSize: 11),
    ),
  );
}
