import 'package:flutter/foundation.dart';
import 'package:yapluca_migration/data/models/charging_station.dart';
import 'package:yapluca_migration/data/services/charging_station_service.dart';

class StationProvider extends ChangeNotifier {
  final ChargingStationService _stationService = ChargingStationService();
  List<ChargingStation> _stations = [];
  ChargingStation? _selectedStation;
  bool _isLoading = false;
  String _error = '';

  List<ChargingStation> get stations => _stations;
  ChargingStation? get selectedStation => _selectedStation;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadStations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _stations = await _stationService.getChargingStations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getStationDetails(String stationId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _selectedStation = await _stationService.getStationById(stationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectStation(ChargingStation station) {
    _selectedStation = station;
    notifyListeners();
  }

  void clearSelectedStation() {
    _selectedStation = null;
    notifyListeners();
  }

  List<ChargingStation> getNearbyStations(double latitude, double longitude, double radiusInKm) {
    if (_stations.isEmpty) return [];
    
    return _stations.where((station) {
      final distance = station.calculateDistance(latitude, longitude);
      return distance <= radiusInKm;
    }).toList()
      ..sort((a, b) {
        final distanceA = a.calculateDistance(latitude, longitude);
        final distanceB = b.calculateDistance(latitude, longitude);
        return distanceA.compareTo(distanceB);
      });
  }
}
