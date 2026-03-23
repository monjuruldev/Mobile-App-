import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RC {
  static const String name       = 'BurgerBlast';
  static const String tagline    = 'Flame-grilled. Freshly stacked.';
  static const String phone      = '+91 98765 43210';
  static const String email      = 'hello@burgerblast.com';
  static const String address    = 'Guwahati, Assam';
  static const String currency   = '₹';
  static const double deliveryFee = 40.0;
  static const double freeDelMin  = 399.0;
  static const double taxRate     = 0.05;
  static const String openTime   = '11:00 AM';
  static const String closeTime  = '11:00 PM';
  static const int avgDelivery   = 25;
  static const int maxGuests     = 8;
  static const int totalTables   = 12;
}

class AC {
  static const Color brand     = Color(0xFFFFCC00);
  static const Color brandDeep = Color(0xFFE5A800);
  static const Color fire      = Color(0xFFFF3D00);
  static const Color fireDark  = Color(0xFFCC2000);
  static const Color fireLight = Color(0xFFFF6B35);
  static const Color bg        = Color(0xFF141210);
  static const Color bg2       = Color(0xFF1E1B18);
  static const Color bg3       = Color(0xFF2A2623);
  static const Color surface   = Color(0xFF332F2B);
  static const Color text      = Color(0xFFFFF8F0);
  static const Color text2     = Color(0xFFBDB5AC);
  static const Color text3     = Color(0xFF7A726A);
  static const Color success   = Color(0xFF4ADE80);
  static const Color warning   = Color(0xFFFFB800);
  static const Color error     = Color(0xFFFF4040);
  static const Color gold      = Color(0xFFFFCC00);
  static const Color veg       = Color(0xFF4ADE80);
  static const Color nonVeg    = Color(0xFFFF4040);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AC.bg,
      colorScheme: const ColorScheme.dark(
        primary: AC.fire,
        secondary: AC.brand,
        surface: AC.bg2,
        error: AC.error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AC.bg2,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AC.text),
      ),
      cardTheme: CardThemeData(
        color: AC.bg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0x0DFFFFFF)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AC.fire,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AC.bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x0DFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x0DFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AC.fire, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: AC.text3, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AC.bg3, thickness: 1, space: 0,
      ),
    );
  }
}
