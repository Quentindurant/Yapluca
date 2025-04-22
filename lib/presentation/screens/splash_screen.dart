import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:yapluca_migration/config/app_colors.dart';
import 'package:yapluca_migration/presentation/providers/auth_provider.dart';
import 'package:yapluca_migration/presentation/screens/login_screen.dart';
import 'package:yapluca_migration/presentation/screens/home_screen.dart';
import 'package:yapluca_migration/presentation/widgets/yapluca_logo.dart';

/// Écran de démarrage de l'application YapluCa
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  String _errorMessage = '';
  bool _showDebugInfo = true; // Afficher les informations de débogage
  bool _showEmergencyButton = false; // Bouton d'urgence pour contourner l'écran de chargement

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Vérifier l'état d'authentification après un délai pour voir le splash screen
    Timer(const Duration(seconds: 2), () {
      _checkAuthAndNavigate();
    });
    
    // Définir un délai maximum pour l'écran de démarrage (5 secondes)
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        // Si nous sommes toujours sur l'écran de démarrage après 5 secondes,
        // naviguer automatiquement vers l'écran de connexion
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Vérifie l'état d'authentification et redirige vers l'écran approprié
  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Lancer la vérification d'authentification
      if (!authProvider.hasCheckedAuth) {
        setState(() {
          _errorMessage = 'Vérification de l\'authentification...';
        });
        
        try {
          await authProvider.checkAuthStatus();
          setState(() {
            _errorMessage = 'Authentification vérifiée avec succès';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Erreur lors de la vérification: $e';
          });
          // Continuer malgré l'erreur
        }
      }
      
      if (!mounted) return;
      
      // Rediriger vers l'écran approprié en fonction de l'état d'authentification
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
      
      if (mounted) {
        // En cas d'erreur, rediriger vers l'écran de connexion
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF373643), // Couleur unie au lieu d'un dégradé
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de l'application sans le cercle blanc
                Hero(
                  tag: 'app_logo',
                  child: YaplucaLogo(height: 150),
                ),
                
                const SizedBox(height: 40),
                
                // Slogan
                const Text(
                  'Rechargez où vous voulez',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Indicateur de chargement
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                
                // Afficher les messages de débogage
                if (_showDebugInfo && _errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Debug: $_errorMessage',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
