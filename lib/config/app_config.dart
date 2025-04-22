/// Configuration globale de l'application
class AppConfig {
  /// Indique si Firebase doit être utilisé
  /// Sur Windows, nous désactivons Firebase car il peut y avoir des problèmes de compilation
  static bool useFirebase() {
    // Détection de la plateforme à l'exécution
    final bool isWindows = identical(0, 0.0) && 
        const bool.fromEnvironment('dart.library.io') &&
        const bool.fromEnvironment('dart.library.ffi');
    
    // Désactiver Firebase sur Windows
    if (isWindows) {
      print('AppConfig: Firebase désactivé sur Windows');
      return false;
    }
    
    return true;
  }
}
