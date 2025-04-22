import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Classe qui gère l'interaction avec le code natif pour l'authentification Google
class GoogleSignInPlatform {
  static const MethodChannel _channel = MethodChannel('com.example.yappluca/google_signin');
  
  /// Améliore l'expérience d'authentification Google sur Android
  /// en utilisant des composants natifs pour éviter les redirections
  static Future<bool> enhanceGoogleSignIn() async {
    if (!Platform.isAndroid) {
      return false;
    }
    
    try {
      final bool result = await _channel.invokeMethod('enhanceGoogleSignIn');
      return result;
    } on PlatformException catch (e) {
      print('Erreur lors de l\'amélioration de Google Sign-In: $e');
      return false;
    }
  }
}
