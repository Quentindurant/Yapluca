import 'package:flutter/material.dart';
import 'package:yapluca_migration/config/app_colors.dart';

/// Classe contenant les styles pour les écrans d'authentification
class AuthStyles {
  // Styles pour le conteneur principal
  static BoxDecoration backgroundDecoration = const BoxDecoration(
    color: Colors.black,
  );

  // Styles pour le conteneur du formulaire
  static BoxDecoration formContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Style pour le titre
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.15,
  );

  // Style pour le texte des boutons
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Style pour le texte du diviseur
  static const TextStyle dividerTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF78909C),
  );

  // Style pour les liens
  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF18cb96),
    decoration: TextDecoration.underline,
  );

  // Style pour le bouton principal
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF18cb96),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
    textStyle: buttonTextStyle,
  );

  // Style pour le bouton Google
  static final ButtonStyle googleButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF455A64),
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: const BorderSide(color: Color(0xFFE0E0E0)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    textStyle: buttonTextStyle,
  );

  // Padding horizontal standard
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 24);

  // Padding standard pour les conteneurs
  static const EdgeInsets standardPadding = EdgeInsets.all(24);

  // Style pour le texte d'erreur
  static const TextStyle errorTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.red,
  );

  // Style pour les textes d'aide
  static const TextStyle helperTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF78909C),
  );

  // Style pour le texte de l'en-tête
  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
