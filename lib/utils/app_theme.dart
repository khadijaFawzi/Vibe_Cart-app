// app_theme.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان التطبيق الأساسية
  static const Color primary = Color(0xFF4A7EFF);      // أزرق نشط
  static const Color secondary = Color(0xFF00BFA5);    // أخضر للإجراءات الثانوية
  static const Color background = Color(0xFFF5F7FA);   // خلفية فاتحة
  static const Color darkBackground = Color(0xFF1F2937); // خلفية داكنة
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);  // نص أساسي
  static const Color textSecondary = Color(0xFF718096); // نص ثانوي
  static const Color error = Color(0xFFE53E3E);        // أحمر للأخطاء
  static const Color success = Color(0xFF38A169);      // أخضر للنجاح
  static const Color warning = Color(0xFFECC94B);      // أصفر للتحذيرات
  static const Color discount = Color(0xFFE53E3E);     // لون نسبة الخصم

  // حواف موحدة
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;

  // ظلال وتأثيرات
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static BoxShadow bottomNavShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 15,
    offset: const Offset(0, -3),
  );

  // مساحات وهوامش
  static const double paddingXS = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  // أنماط النصوص
  static TextStyle headingLarge = GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle headingMedium = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle headingSmall = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 16,
    color: textPrimary,
  );
  
  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    color: textPrimary,
  );
  
  static TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 12,
    color: textSecondary,
  );
  
  static TextStyle buttonText = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // أسلوب أزرار موحد
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
    ),
    elevation: 0,
  );
  
  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: BorderSide(color: primary),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
    ),
  );

  // أسلوب بطاقات المنتجات
  static BoxDecoration productCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: cardShadow,
  );
  
  // أسلوب شريط التنقل السفلي
  static BottomNavigationBarThemeData bottomNavBarTheme = BottomNavigationBarThemeData(
    backgroundColor: cardColor,
    selectedItemColor: primary,
    unselectedItemColor: textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
  
  // أسلوب الشريط العلوي
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primary,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
  
  // أسلوب شارة الخصم
  static BoxDecoration discountBadgeDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [discount, discount.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(borderRadiusSmall),
      bottomRight: Radius.circular(borderRadiusSmall),
    ),
  );
}
