import 'package:flutter/material.dart';
import '../models/charging_station.dart';
import '../services/charging_station_service.dart';

class ChargingStationProvider with ChangeNotifier {
  final ChargingStationService _stationService = ChargingStationService();
  
  List<ChargingStation> _nearbyStations = [];
  List<ChargingStation> _favoriteStations = [];
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<ChargingStation> get nearbyStations => _nearbyStations;
  List<ChargingStation> get favoriteStations => _favoriteStations;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Méthode pour récupérer les stations à proximité
  Future<void> fetchNearbyStations({double? latitude, double? longitude}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      // Utiliser les coordonnées fournies ou des coordonnées par défaut si non spécifiées
      final double lat = latitude ?? 48.8566;
      final double lng = longitude ?? 2.3522;
      
      final stations = await _stationService.getNearbyStations(lat, lng);
      _nearbyStations = stations;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des stations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Méthode pour récupérer les stations favorites
  Future<void> fetchFavoriteStations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      // Dans une vraie application, on récupérerait les favoris depuis la base de données
      final stations = await _stationService.getFavoriteStations();
      _favoriteStations = stations;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des favoris: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Méthode pour ajouter une station aux favoris
  Future<void> addToFavorites(ChargingStation station) async {
    try {
      await _stationService.addToFavorites(station.id);
      if (!_favoriteStations.any((s) => s.id == station.id)) {
        _favoriteStations.add(station);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de l\'ajout aux favoris: $e';
      notifyListeners();
    }
  }
  
  // Méthode pour retirer une station des favoris
  Future<void> removeFromFavorites(String stationId) async {
    try {
      await _stationService.removeFromFavorites(stationId);
      _favoriteStations.removeWhere((s) => s.id == stationId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du retrait des favoris: $e';
      notifyListeners();
    }
  }
  
  // Méthode pour vérifier si une station est dans les favoris
  bool isFavorite(String stationId) {
    return _favoriteStations.any((s) => s.id == stationId);
  }
  
  // Méthode pour effacer l'erreur
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
