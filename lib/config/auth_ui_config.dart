import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Configuration pour personnaliser l'interface utilisateur d'authentification
class AuthUIConfig {
  // Couleurs de la marque YapluCa
  static const Color primaryColor = AppColors.primaryColor; // #18cb96
  static const Color secondaryColor = Colors.white;
  static const Color textColor = Colors.black87;
  
  // Textes personnalisés pour l'authentification Google
  static const String googleSignInButtonText = 'Continuer avec Google';
  static const String googleSignInTitle = 'Connexion à YapluCa';
  static const String googleSignInSubtitle = 'Accédez à votre compte YapluCa';
  
  // Configuration pour l'écran de connexion Google
  static const double buttonBorderRadius = 8.0;
  static const double buttonHeight = 50.0;
  static const double logoSize = 80.0;
  
  // Styles de texte
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black54,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  // Durée de la session d'authentification (en secondes)
  static const int sessionDuration = 7 * 24 * 60 * 60; // 7 jours
}
