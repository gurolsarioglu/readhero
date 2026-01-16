import 'package:flutter/material.dart';

/// Uygulama renk paleti
class AppColors {
  // Ana Renkler
  static const Color primary = Color(0xFFFF8C42); // Turuncu
  static const Color secondary = Color(0xFF88D498); // Yeşil
  static const Color background = Color(0xFFF9F7F2); // Sıcak kağıt rengi
  static const Color accent = Color(0xFFFFD166); // Sarı
  static const Color error = Color(0xFFEF476F); // Kırmızı

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF2D3142); // Koyu gri
  static const Color textSecondary = Color(0xFF6B7280); // Orta gri
  static const Color textLight = Color(0xFFFFFFFF); // Beyaz

  // Arka Plan Renkleri
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = background;

  // Durum Renkleri
  static const Color success = Color(0xFF10B981); // Yeşil
  static const Color warning = Color(0xFFF59E0B); // Turuncu
  static const Color info = Color(0xFF3B82F6); // Mavi

  // Gölge ve Kenarlık
  static const Color shadow = Color(0x1A000000); // %10 siyah
  static const Color border = Color(0xFFE5E7EB); // Açık gri

  // Gradyan Renkleri
  static const List<Color> primaryGradient = [
    Color(0xFFFF8C42),
    Color(0xFFFFB366),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF88D498),
    Color(0xFFA8E6B8),
  ];
}
