import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yapluca_migration/providers/auth_provider.dart';
import 'package:yapluca_migration/presentation/screens/login_screen.dart';

/// Extensions utilitaires pour la gestion de l'authentification
extension AuthContextExtension on BuildContext {
  /// Vérifie si l'utilisateur est authentifié
  /// Retourne true si l'utilisateur est authentifié, sinon redirige vers l'écran de connexion et retourne false
  bool checkAuth() {
    final authProvider = Provider.of<AuthProvider>(this, listen: false);
    
    if (authProvider.isAuthenticated) {
      return true;
    } else {
      // Rediriger vers l'écran de connexion
      Navigator.of(this).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return false;
    }
  }
}
