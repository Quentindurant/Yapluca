import 'dart:convert';
import 'dart:math';
import '../models/charging_station.dart';

class ChargingStationService {
  // Méthode pour récupérer les stations à proximité
  Future<List<ChargingStation>> getNearbyStations(double latitude, double longitude) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Dans une vraie application, on ferait une requête API
    // Pour le développement, on génère des données fictives
    return _generateMockStations(latitude, longitude);
  }
  
  // Méthode pour récupérer les stations favorites
  Future<List<ChargingStation>> getFavoriteStations() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Dans une vraie application, on récupérerait les favoris depuis une API
    // Pour le développement, on génère des données fictives
    return _generateMockFavorites();
  }
  
  // Méthode pour ajouter une station aux favoris
  Future<void> addToFavorites(String stationId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dans une vraie application, on enverrait une requête à l'API
    // Pour le développement, on ne fait rien
    return;
  }
  
  // Méthode pour retirer une station des favoris
  Future<void> removeFromFavorites(String stationId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dans une vraie application, on enverrait une requête à l'API
    // Pour le développement, on ne fait rien
    return;
  }
  
  // Méthode pour générer des stations fictives
  List<ChargingStation> _generateMockStations(double latitude, double longitude) {
    final random = Random();
    final List<ChargingStation> stations = [];
    
    // Noms de lieux parisiens
    final List<String> placeNames = [
      'Café de Paris',
      'Bistro Eiffel',
      'Galeries Lafayette',
      'Le Marais Shop',
      'Montmartre Café',
      'Louvre Museum',
      'Notre Dame Plaza',
      'Champs-Élysées',
      'Saint-Germain',
      'Opéra Garnier',
    ];
    
    // Adresses parisiennes
    final List<String> addresses = [
      '15 Rue de Rivoli, 75001 Paris',
      '27 Avenue des Champs-Élysées, 75008 Paris',
      '8 Boulevard Haussmann, 75009 Paris',
      '35 Rue du Faubourg Saint-Honoré, 75008 Paris',
      '22 Rue Montorgueil, 75001 Paris',
      '1 Place du Trocadéro, 75016 Paris',
      '6 Place Saint-Michel, 75006 Paris',
      '12 Rue de la Paix, 75002 Paris',
      '44 Rue de Rivoli, 75004 Paris',
      '3 Boulevard Saint-Germain, 75005 Paris',
    ];
    
    // Générer entre 3 et 8 stations
    final count = random.nextInt(6) + 3;
    
    for (int i = 0; i < count; i++) {
      // Générer un ID unique
      final id = 'station_${DateTime.now().millisecondsSinceEpoch}_$i';
      
      // Choisir un nom et une adresse aléatoires
      final name = placeNames[random.nextInt(placeNames.length)];
      final address = addresses[random.nextInt(addresses.length)];
      
      // Générer des coordonnées proches de la position donnée
      final lat = latitude + (random.nextDouble() - 0.5) * 0.02;
      final lng = longitude + (random.nextDouble() - 0.5) * 0.02;
      
      // Générer des valeurs aléatoires pour les batteries
      final totalBatteries = random.nextInt(6) + 5; // Entre 5 et 10 batteries
      final availableBatteries = random.nextInt(totalBatteries + 1); // Entre 0 et totalBatteries
      
      // Créer la station
      final station = ChargingStation(
        id: id,
        name: name,
        address: address,
        latitude: lat,
        longitude: lng,
        totalBatteries: totalBatteries,
        availability: availableBatteries,
        isOpen: random.nextBool(),
        openingHours: '9:00 - 22:00',
        imageUrl: 'https://picsum.photos/200/300?random=$i',
      );
      
      stations.add(station);
    }
    
    return stations;
  }
  
  // Méthode pour générer des favoris fictifs
  List<ChargingStation> _generateMockFavorites() {
    final random = Random();
    final List<ChargingStation> favorites = [];
    
    // Noms de lieux parisiens favoris
    final List<String> favoriteNames = [
      'Mon Bureau',
      'Café Préféré',
      'Salle de Sport',
      'Restaurant Favori',
    ];
    
    // Adresses parisiennes
    final List<String> addresses = [
      '15 Rue de Rivoli, 75001 Paris',
      '27 Avenue des Champs-Élysées, 75008 Paris',
      '8 Boulevard Haussmann, 75009 Paris',
      '35 Rue du Faubourg Saint-Honoré, 75008 Paris',
    ];
    
    // Coordonnées parisiennes
    final List<List<double>> coordinates = [
      [48.856614, 2.3522219],
      [48.858844, 2.2943506],
      [48.873792, 2.3298169],
      [48.863692, 2.3380449],
    ];
    
    // Générer entre 2 et 4 favoris
    final count = random.nextInt(3) + 2;
    
    for (int i = 0; i < count; i++) {
      // Générer un ID unique
      final id = 'favorite_${DateTime.now().millisecondsSinceEpoch}_$i';
      
      // Choisir un nom et une adresse
      final name = favoriteNames[i % favoriteNames.length];
      final address = addresses[i % addresses.length];
      final coords = coordinates[i % coordinates.length];
      
      // Générer des valeurs aléatoires pour les batteries
      final totalBatteries = random.nextInt(6) + 5; // Entre 5 et 10 batteries
      final availableBatteries = random.nextInt(totalBatteries + 1); // Entre 0 et totalBatteries
      
      // Créer la station
      final station = ChargingStation(
        id: id,
        name: name,
        address: address,
        latitude: coords[0],
        longitude: coords[1],
        totalBatteries: totalBatteries,
        availability: availableBatteries,
        isOpen: true,
        openingHours: '9:00 - 22:00',
        imageUrl: 'https://picsum.photos/200/300?random=${i+10}',
      );
      
      favorites.add(station);
    }
    
    return favorites;
  }
}
