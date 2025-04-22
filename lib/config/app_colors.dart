import 'package:flutter/material.dart';

/// Classe contenant les couleurs principales de l'application YapluCa
class AppColors {
  // Couleurs principales définies dans le cahier des charges
  static const Color primaryColor = Color(0xFF18cb96); // Vert vif
  static const Color primaryColorDark = Color(0xFF0FB37F); // Version plus foncée du vert principal
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF373643); // Remplacé #000000 par #373643 selon demande client
  
  // Nuances de gris
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Couleurs de statut
  static const Color error = Color(0xFFE53935);
  static const Color errorColor = Color(0xFFE53935); // Alias pour error
  static const Color success = Color(0xFF4CAF50);
  static const Color successColor = Color(0xFF4CAF50); // Alias pour success
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Couleurs spécifiques à l'application
  static const Color mapMarker = primaryColor;
  static const Color availableBattery = primaryColor;
  static const Color unavailableBattery = Color(0xFFE53935);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryColorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
