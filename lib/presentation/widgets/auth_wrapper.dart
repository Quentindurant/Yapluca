import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yapluca_migration/providers/auth_provider.dart';
import 'package:yapluca_migration/presentation/screens/login_screen.dart';

/// Widget qui vérifie l'état d'authentification et redirige vers la page de connexion
/// si l'utilisateur n'est pas connecté.
class AuthWrapper extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Si l'authentification n'est pas requise, afficher directement l'écran
    if (!requireAuth) {
      return child;
    }
    
    // Vérifier l'état d'authentification
    if (authProvider.isLoading) {
      // Afficher un indicateur de chargement pendant la vérification
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authProvider.isAuthenticated) {
      // L'utilisateur est authentifié, afficher l'écran demandé
      return child;
    } else {
      // L'utilisateur n'est pas authentifié, rediriger vers la page de connexion
      return const LoginScreen();
    }
  }
}
