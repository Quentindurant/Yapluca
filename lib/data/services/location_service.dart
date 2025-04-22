import 'package:geolocator/geolocator.dart';
import 'dart:async';

/// Service pour gérer la géolocalisation dans l'application YapluCa
class LocationService {
  /// Vérifie si les services de localisation sont activés
  Future<bool> _checkLocationServicesEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Erreur lors de la vérification des services de localisation: $e');
      return false;
    }
  }

  /// Demande la permission de localisation avec une gestion d'erreurs améliorée
  Future<LocationPermission> _requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission;
    } catch (e) {
      print('Erreur lors de la demande de permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Vérifie et demande toutes les permissions nécessaires
  /// Retourne true si toutes les permissions sont accordées
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Vérifier si les services de localisation sont activés
      final servicesEnabled = await _checkLocationServicesEnabled();
      if (!servicesEnabled) {
        return false;
      }

      // Demander la permission
      final permission = await _requestPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  /// Obtient la position actuelle de l'utilisateur avec une stratégie optimisée
  /// Retourne d'abord la dernière position connue pour une réponse rapide
  /// puis met à jour avec une position plus précise
  Future<Position?> getCurrentPosition({
    Function(Position)? onPositionUpdate,
  }) async {
    try {
      // Vérifier les permissions d'abord
      bool hasPermissions = await checkAndRequestPermissions();
      if (!hasPermissions) {
        throw Exception('Permissions de localisation non accordées');
      }

      // Stratégie 1: Essayer d'obtenir la dernière position connue immédiatement
      Position? lastPosition = await getLastKnownPosition();
      
      // Si nous avons une dernière position connue, la retourner immédiatement
      // tout en continuant à chercher une position plus précise en arrière-plan
      if (lastPosition != null && onPositionUpdate != null) {
        // Notifier avec la dernière position connue
        onPositionUpdate(lastPosition);
        
        // Lancer la recherche d'une position plus précise en arrière-plan
        _getPrecisePosition().then((precisePosition) {
          if (precisePosition != null) {
            // Notifier avec la position précise une fois obtenue
            onPositionUpdate(precisePosition);
          }
        }).catchError((e) {
          print('Erreur lors de la mise à jour de la position précise: $e');
          // On a déjà retourné la dernière position connue, donc pas d'erreur fatale
        });
        
        return lastPosition;
      }
      
      // Si pas de dernière position connue, essayer d'obtenir une position directement
      return await _getPrecisePosition();
    } catch (e) {
      print('Erreur de géolocalisation: $e');
      return null;
    }
  }

  /// Méthode privée pour obtenir une position précise avec plusieurs tentatives
  Future<Position?> _getPrecisePosition() async {
    try {
      // Stratégie 2: Essayer d'abord avec une précision moyenne qui est plus rapide
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        print('Erreur avec précision moyenne, tentative avec précision basse: $e');
        
        // Stratégie 3: Si la précision moyenne échoue, essayer avec une précision basse
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 3),
          );
        } catch (e) {
          print('Erreur avec précision basse, tentative avec précision haute: $e');
          
          // Stratégie 4: Dernier recours, essayer avec une précision haute mais un timeout plus long
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );
        }
      }
    } catch (e) {
      print('Toutes les tentatives d\'obtention de position ont échoué: $e');
      return null;
    }
  }

  /// Obtient la dernière position connue de l'utilisateur
  /// Utile pour obtenir rapidement une position approximative
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Erreur lors de la récupération de la dernière position: $e');
      return null;
    }
  }

  /// Ouvre les paramètres de l'application pour permettre à l'utilisateur d'activer les permissions
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('Erreur lors de l\'ouverture des paramètres: $e');
      return false;
    }
  }

  /// Ouvre les paramètres de localisation du système
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Erreur lors de l\'ouverture des paramètres de localisation: $e');
      return false;
    }
  }

  /// Calcule la distance en kilomètres entre deux positions
  double calculateDistance(
    double startLatitude, 
    double startLongitude,
    double endLatitude, 
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude, 
      startLongitude, 
      endLatitude, 
      endLongitude,
    ) / 1000; // Convertir en kilomètres
  }
}
